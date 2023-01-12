# VARIABLES
CHAIN_ID=local-mooncat
PORT_PREFIX=12
NODE_MONIKER=ValidatorNode

VHOME=$HOME/${CHAIN_ID}2
BINARY=crescentd

# get an wallet address for Crescent and its mnemonic
TDIR=$HOME/tutorials/crescent-local-testnet
VALIDATOR_2_MNEMONIC=$(cat $TDIR/mnemonics/MNEMONIC_VALIDATOR_2)


# Initialize chain config
echo $VHOME
rm -rf $VHOME
$BINARY init $NODE_MONIKER --chain-id $CHAIN_ID --home $VHOME

$BINARY config node tcp://localhost:1${PORT_PREFIX}57 --home $VHOME
$BINARY config chain-id $CHAIN_ID --home $VHOME
$BINARY config keyring-backend test --home $VHOME
$BINARY config output json --home $VHOME
$BINARY config --home $VHOME

cp $HOME/${CHAIN_ID}/config/genesis.json $VHOME/config/genesis.json


# Change other options and ports
sed -i.bak -e "s/^enable = false/enable = true/"  $VHOME/config/app.toml
sed -i.bak -e "s/^swagger = false/swagger = true/"  $VHOME/config/app.toml
sed -i.bak -e "s/^enabled-unsafe-cors = false/enabled-unsafe-cors = true/"  $VHOME/config/app.toml
sed -i.bak -e "s/^cors_allowed_origins = \[\]/cors_allowed_origins = \[\"*\"\]/"  $VHOME/config/config.toml

sed -i.bak -e "s/^address = \"tcp:\/\/0.0.0.0:1317\"/address = \"tcp:\/\/0.0.0.0:1${PORT_PREFIX}17\"/"  $VHOME/config/app.toml
sed -i.bak -e "s/^address = \":8080\"/address = \":1${PORT_PREFIX}80\"/"  $VHOME/config/app.toml
sed -i.bak -e "s/^address = \"0.0.0.0:9090\"/address = \"0.0.0.0:1${PORT_PREFIX}90\"/"  $VHOME/config/app.toml
sed -i.bak -e "s/^address = \"0.0.0.0:9091\"/address = \"0.0.0.0:1${PORT_PREFIX}91\"/"  $VHOME/config/app.toml

sed -i.bak -e "s/^proxy_app = \"tcp:\/\/127.0.0.1:26658\"/proxy_app = \"tcp:\/\/127.0.0.1:1${CHAIN_CODE}58\"/"  $VHOME/config/config.toml
sed -i.bak -e "s/^laddr = \"tcp:\/\/127.0.0.1:26657\"/laddr = \"tcp:\/\/0.0.0.0:1${PORT_PREFIX}57\"/"  $VHOME/config/config.toml
sed -i.bak -e "s/^pprof_laddr = \"localhost:6060\"/pprof_laddr = \"localhost:1${PORT_PREFIX}66\"/"  $VHOME/config/config.toml
sed -i.bak -e "s/^laddr = \"tcp:\/\/0.0.0.0:26656\"/laddr = \"tcp:\/\/0.0.0.0:1${PORT_PREFIX}56\"/"  $VHOME/config/config.toml
sed -i.bak -e "s/^prometheus_listen_addr = \":26660\"/prometheus_listen_addr = \":1${PORT_PREFIX}60\"/"  $VHOME/config/config.toml


V1_PORT_PREFIX=11
NODEID=$($BINARY status --node tcp://127.0.0.1:1${V1_PORT_PREFIX}57 | jq | grep \"id\" | awk -F"\"" '{print $4}')
sed -i.bak -e "s/^persistent_peers = \".*\"/persistent_peers = \"${NODEID}@127.0.0.1:1${V1_PORT_PREFIX}56\"/" $VHOME/config/config.toml

# Add aliases for shortcut

alias ${PORT_PREFIX}st='$BINARY status --node tcp://127.0.0.1:1${PORT_PREFIX}57 2>&1 | jq'
alias ${PORT_PREFIX}info='curl -sS http://127.0.0.1:1${PORT_PREFIX}57/net_info | egrep "n_peers|moniker"'


# Open new terminal 
# Terminal 2 : Make the crescent process keep running in this dedicated terminal
CHAIN_ID=local-mooncat
VHOME=$HOME/${CHAIN_ID}2
BINARY=$(which crescentd)

$BINARY start --home $VHOME
## Wait until sync completed

# Create keys of validator and relayer
VALIDATOR_2=$(echo "$VALIDATOR_2_MNEMONIC" | $BINARY keys add validator --recover --keyring-backend test --output json --home $VHOME 2>&1| jq -r '.address')
ls $VHOME/keyring-test

# Add new valiadtor into genesis.json
AMOUNT=10000000000ucre
VALIDATOR_MONIKER=imaValidator
FEES=1000ucre
$BINARY tx staking create-validator $AMOUNT \
	--keyring-backend test \
    --moniker $VALIDATOR_MONIKER \
    --chain-id $CHAIN_ID \
    --amount $AMOUNT \
    --commission-max-change-rate 0.1 \
    --commission-max-rate 1.0  \
    --commission-rate 0.1 \
    --min-self-delegation 1 \
    --pubkey=$($BINARY tendermint show-validator --home $VHOME)  \
    --from validator \
    --home $VHOME \
    --fees $FEES \
    -y

## wait 6 seconds then check the result
12st


# Terminal 1 : Check balances
VHOME=$HOME/local-mooncat2
BINARY=$(which crescentd)

$BINARY keys list --home $VHOME --keyring-backend test
RELAYER_WALLET=cre1e2r48kgec2twyp5t3yc6lr6ad9mrzy9yx6wl0e
VALIDATOR_1_WALLET=cre1jputs32a6c5m6f572tp9cpk0n7pvnk4rdfwhvs
VALIDATOR_2_WALLET=cre1856zhx99w9a0xtdxlgp36j7jyuw30hshm44nj6

$BINARY q bank balances $RELAYER_WALLET --home $VHOME | jq
$BINARY q bank balances $VALIDATOR_1_WALLET  --home $VHOME  | jq
$BINARY q bank balances $VALIDATOR_2_WALLET  --home $VHOME | jq


# check current list of liquid validators
crescentd q liquidstaking liquid-validators --home $VHOME

# write new whitelist validator info into json
NEW_LSV=$(crescentd keys show validator --bech=val -a --home $VHOME)
OLD_LSV=$(crescentd keys show validator --bech=val -a --home $HOME/$CHAIN_ID)

cat << EOF | tee > $HOME/add-liquid-validator.json
{
    "title": "WhitelistedValidators",
    "description": "WhitelistedValidators",
    "changes":
    [
        {
            "subspace": "liquidstaking",
            "key": "WhitelistedValidators",
            "value":
            [
                {
                    "validator_address": "${OLD_LSV}",
                    "target_weight": "1"
                },
                {
                    "validator_address": "${NEW_LSV}",
                    "target_weight": "1"
                }
            ]
        }
    ],
    "deposit": "500000000ucre"
}
EOF


# Submit proposal and vote
VHOME=$HOME/$CHAIN_ID

crescentd tx gov submit-proposal param-change $HOME/add-liquid-validator.json \
    --from validator \
    --gas 1000000 \
    --fees 10000ucre \
    --home $VHOME -y

crescentd q gov proposals --home $VHOME

crescentd tx gov vote 1  yes  --home $VHOME --from validator -y
## Vote then wait until the proposal has passed

crescentd q liquidstaking liquid-validators --home $VHOME | jq

# Liquid staking
WALLET=relayer
AMOUNT=10000000000ucre
FEES=1000ucre

crescentd q liquidstaking liquid-validators --home $VHOME | jq

crescentd tx  liquidstaking  liquid-stake $AMOUNT \
    --from $WALLET \
    --home $VHOME \
    --gas 1000000 --fees $FEES \
    -y

12st
crescentd q liquidstaking liquid-validators --home $VHOME | jq

