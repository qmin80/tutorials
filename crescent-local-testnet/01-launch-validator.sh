
# VARIABLES - CRESCENT
CRE_BRANCH=v4.0.0

CHAIN_ID=local-mooncat
PORT_PREFIX=11
NODE_MONIKER=MyValidator

VHOME=$HOME/$CHAIN_ID
BINARY=crescentd

# Build crescentd
cd $HOME
git clone https://github.com/crescent-network/crescent
cd crescent
git checkout $CRE_BRANCH
make install


# git clone hands-on repo to $HOME directory
cd $HOME
git clone https://github.com/qmin80/tutorials.git

# get an wallet address for Crescent and its mnemonic
TDIR=$HOME/tutorials/crescent-local-testnet
RELAYER_MNEMONIC=$(cat $TDIR/MNEMONIC_RELAYER)
VALIDATOR_1_MNEMONIC=$(cat $TDIR/MNEMONIC_VALIDATOR_1)
VALIDATOR_2_MNEMONIC=$(cat $TDIR/MNEMONIC_VALIDATOR_2)


# Initialize chain config
rm -rf $VHOME
$BINARY init $NODE_MONIKER --chain-id $CHAIN_ID --home $VHOME

$BINARY config node tcp://localhost:1${PORT_PREFIX}57 --home $VHOME
$BINARY config chain-id $CHAIN_ID --home $VHOME
$BINARY config keyring-backend test --home $VHOME
$BINARY config output json --home $VHOME


# Change genesis parameters
sed -i.bak -e 's/minimum-gas-prices = \"\"/minimum-gas-prices = \"0ucre,0bcre\"/g' $VHOME/config/app.toml
sed -i.bak -e 's/"stake"/"ucre"/g' $VHOME/config/genesis.json
sed -i.bak -e 's/"bstake"/"ubcre"/g' $VHOME/config/genesis.json
sed -i.bak -e 's%"amount": "10000000"%"amount": "1"%g' $VHOME/config/genesis.json
sed -i.bak -e 's%"max_deposit_period": "172800s"%"max_deposit_period": "300s"%g' $VHOME/config/genesis.json
sed -i.bak -e 's%"voting_period": "172800s"%"voting_period": "300s"%g' $VHOME/config/genesis.json
sed -i.bak -e 's%"inflation": "0.130000000000000000",%"inflation": "0.500000000000000000",%g' $VHOME/config/genesis.json
sed -i.bak -e 's%"unbonding_time": "1814400s",%"unbonding_time": "300s",%g' $VHOME/config/genesis.json
sed -i.bak -e 's%"downtime_jail_duration": "600s",%"downtime_jail_duration": "60s",%g' $VHOME/config/genesis.json

# Add whitelist validator
sed -i.bak -e 's%"whitelisted_validators": \[\],%"whitelisted_validators": \[{\"validator_address\": \"crevaloper1jputs32a6c5m6f572tp9cpk0n7pvnk4r0awcp6\",\"target_weight\": \"1\"}\],%g' $VHOME/config/genesis.json


# Change other options and ports
sed -i.bak -e "s/^enable = false/enable = true/" $VHOME/config/app.toml
sed -i.bak -e "s/^swagger = false/swagger = true/" $VHOME/config/app.toml
sed -i.bak -e "s/^enabled-unsafe-cors = false/enabled-unsafe-cors = true/" $VHOME/config/app.toml
sed -i.bak -e "s/^cors_allowed_origins = \[\]/cors_allowed_origins = \[\"*\"\]/" $VHOME/config/config.toml

sed -i.bak -e "s/^address = \"tcp:\/\/0.0.0.0:1317\"/address = \"tcp:\/\/0.0.0.0:1${PORT_PREFIX}17\"/" $VHOME/config/app.toml
sed -i.bak -e "s/^address = \":8080\"/address = \":1${PORT_PREFIX}80\"/" $VHOME/config/app.toml
sed -i.bak -e "s/^address = \"0.0.0.0:9090\"/address = \"0.0.0.0:1${PORT_PREFIX}90\"/" $VHOME/config/app.toml
sed -i.bak -e "s/^address = \"0.0.0.0:9091\"/address = \"0.0.0.0:1${PORT_PREFIX}91\"/" $VHOME/config/app.toml

sed -i.bak -e "s/^proxy_app = \"tcp:\/\/127.0.0.1:26658\"/proxy_app = \"tcp:\/\/127.0.0.1:1${CHAIN_CODE}58\"/" $VHOME/config/config.toml
sed -i.bak -e "s/^laddr = \"tcp:\/\/127.0.0.1:26657\"/laddr = \"tcp:\/\/0.0.0.0:1${PORT_PREFIX}57\"/" $VHOME/config/config.toml
sed -i.bak -e "s/^pprof_laddr = \"localhost:6060\"/pprof_laddr = \"localhost:1${PORT_PREFIX}66\"/" $VHOME/config/config.toml
sed -i.bak -e "s/^laddr = \"tcp:\/\/0.0.0.0:26656\"/laddr = \"tcp:\/\/0.0.0.0:1${PORT_PREFIX}56\"/" $VHOME/config/config.toml
sed -i.bak -e "s/^prometheus_listen_addr = \":26660\"/prometheus_listen_addr = \":1${PORT_PREFIX}60\"/" $VHOME/config/config.toml


# Add aliases for shortcut

alias ${PORT_PREFIX}st='$BINARY status --node tcp://127.0.0.1:1${PORT_PREFIX}57 2>&1 | jq'
alias ${PORT_PREFIX}info='curl -sS http://127.0.0.1:1${PORT_PREFIX}57/net_info | egrep "n_peers|moniker"'


# Create keys of validator and relayer
VALIDATOR_1=$(echo "$VALIDATOR_1_MNEMONIC" | $BINARY keys add validator --recover --keyring-backend test --output json --home $VHOME 2>&1| jq -r '.address')
VALIDATOR_2=$(echo "$VALIDATOR_2_MNEMONIC" | $BINARY keys add validator2 --recover --keyring-backend test --output json --home $VHOME 2>&1| jq -r '.address')
RELAYER=$(echo "$RELAYER_MNEMONIC" | $BINARY keys add relayer --recover  --keyring-backend test  --output json --home $VHOME 2>&1 | jq -r '.address')


# Fund wallets of validator and relayer in genesis.json
AMOUNT=10000000000000ucre
$BINARY add-genesis-account $VALIDATOR_1 $AMOUNT --home $VHOME
$BINARY add-genesis-account $VALIDATOR_2 $AMOUNT --home $VHOME
$BINARY add-genesis-account $RELAYER $AMOUNT --home $VHOME


# Add new valiadtor into genesis.json
AMOUNT=10000000000ucre
$BINARY gentx validator $AMOUNT \
	--keyring-backend test \
    --moniker $MONIKER \
    --chain-id $CHAIN_ID \
    --commission-max-change-rate 0.1 \
    --commission-max-rate 1.0  \
    --commission-rate 0.1 \
    --min-self-delegation 1 \
    --pubkey=$($BINARY tendermint show-validator --home $VHOME)  \
    --from validator \
    --home $VHOME
$BINARY collect-gentxs $VHOME/config/gentx --home $VHOME

$BINARY tendermint unsafe-reset-all --home $VHOME


# Open new terminal 
# Terminal 2 : Make the crescent process keep running in this dedicated terminal
VHOME=$HOME/local-mooncat
BINARY=$(which crescentd)

$BINARY start --home $VHOME


# Return to the previous terminal 
# Terminal 1 : change the default config
crescentd config node tcp://0.0.0.0:1${PORT_PREFIX}57
crescentd config chain-id local-mooncat
crescentd config keyring-backend test 

# Check the balances and test send tx

$BINARY keys list --home $VHOME --keyring-backend test
RELAYER_WALLET=cre1e2r48kgec2twyp5t3yc6lr6ad9mrzy9yx6wl0e
VALIDATOR_1_WALLET=cre1jputs32a6c5m6f572tp9cpk0n7pvnk4rdfwhvs
VALIDATOR_2_WALLET=cre1856zhx99w9a0xtdxlgp36j7jyuw30hshm44nj6

$BINARY q bank balances $RELAYER_WALLET 
$BINARY q bank balances $VALIDATOR_1_WALLET
$BINARY q bank balances $VALIDATOR_2_WALLET

$BINARY tx bank send relayer $VALIDATOR_1_WALLET 1ucre --home $VHOME  -y
$BINARY q bank balances $RELAYER_WALLET 
$BINARY q bank balances $VALIDATOR_1_WALLET
