
CHAIN_ID=local-mooncat
VHOME=$HOME/$CHAIN_ID
WALLET=relayer

# Create a pool 
BASE=10000000000ucre
QUOTE=10000000000ubcre

PAIRID=1
MINPRICE=0.95
MAXPRICE=1.05
INITPRICE=1
CHAINID=local-mooncat
FEES=1000ucre

crescentd tx liquidity create-ranged-pool $PAIRID \
    $BASE,$QUOTE  $MINPRICE  $MAXPRICE  $INITPRICE \
    --from $WALLET \
    --chain-id $CHAINID -b block \
    --fees $FEES \
    --home $VHOME \
    -y

crescentd q liquidity pools --home $VHOME | jq .

# Deposit
BASE=10000000ucre
QUOTE=10000000ubcre
POOLID=1
CHAINID=local-mooncat

crescentd tx liquidity deposit $POOLID \
    $BASE,$QUOTE \
    --from $WALLET \
    --chain-id $CHAINID -b block \
    --fees $FEES \
    --home $VHOME \
    -y

crescentd q liquidity pools --home $VHOME | jq .
