
# VARIABLES - CRESCENT
CHAIN_ID=local-mooncat
VHOME=$HOME/$CHAIN_ID

# check current list of liquid validators
crescentd q liquidstaking liquid-validators

# Liquid staking - get bcre
WALLET=relayer
AMOUNT=100000000000ucre
FEES=1000ucre
crescentd tx liquidstaking liquid-stake $AMOUNT \
    --from $WALLET --home $VHOME --gas 1000000 --fees $FEES -y

crescentd q bank balances $(crescentd keys show $WALLET -a --home $VHOME)


# Create a pair
BASE="ucre"
QUOTE="ubcre"
crescentd tx liquidity create-pair $BASE  $QUOTE \
--from $WALLET  \
--chain-id $CHAIN_ID -b block \
--fees $FEES \
--home $VHOME -y

crescentd q liquidity pairs


# Swap to initiate last price : Limit Order
PAIRID=1
DIRECTION=buy
OFFER_COIN=1000000ucre
DEMAND_COIN_DENOM=ubcre
PRICE=1.00
AMOUNT=1000000
ORDER_LIFESPAN=1m
FEES=1000ucre

crescentd tx liquidity limit-order $PAIRID $DIRECTION $OFFER_COIN $DEMAND_COIN_DENOM $PRICE $AMOUNT \
    --from $WALLET \
    --fees $FEES \
    --home $VHOME -y \
    --order-lifespan=$ORDER_LIFESPAN

crescentd query liquidity orders --pair-id 1 | jq . | grep \"id\"

PRICE=0.10
AMOUNT=10000000
crescentd tx liquidity limit-order $PAIRID $DIRECTION $OFFER_COIN $DEMAND_COIN_DENOM $PRICE $AMOUNT \
    --from $WALLET \
    --fees $FEES \
    --home $VHOME -y \
    --order-lifespan=$ORDER_LIFESPAN

crescentd query liquidity orders --pair-id 1 | jq . | grep \"id\"

crescentd q liquidity order-books 1 --num-ticks=2 | jq .


# Market Order
# A market making order is a set of limit orders for each buy/sell side.
# You can leave one side(but not both) empty by passing 0 as its arguments.
# crescentd tx liquidity mm-order [pair-id] [max-sell-price] [min-sell-price] [sell-amount] [max-buy-price] [min-buy-price] [buy-amount] [flags]

PAIR_ID=1
MAX_SELL=1.4
MIN_SELL=1.0
SELL_AMOUNT=100000000
MAX_BUY=0
MIN_BUY=0
BUY_AMOUNT=0
ORDER_LIFESPAN=5m
FEES=1000ucre
WALLET=relayer

crescentd tx liquidity mm-order $PAIR_ID \
    $MAX_SELL  $MIN_SELL  $SELL_AMOUNT \
    $MAX_BUY  $MIN_BUY  $BUY_AMOUNT \
    --order-lifespan=$ORDER_LIFESPAN \
    --gas auto --fees $FEES \
    --from $WALLET \
    -y 

crescentd query liquidity orders --pair-id=1 -o json | jq .
crescentd query liquidity orders --pair-id=1 -o json | jq . | grep \"id\"


# BUY
PAIR_ID=1
MAX_SELL=0
MIN_SELL=0
SELL_AMOUNT=0
MAX_BUY=1.1
MIN_BUY=0.99
BUY_AMOUNT=100000000
ORDER_LIFESPAN=5m
FEES=1000ucre
WALLET=relayer

crescentd tx liquidity mm-order $PAIR_ID \
    $MAX_SELL  $MIN_SELL  $SELL_AMOUNT \
    $MAX_BUY  $MIN_BUY  $BUY_AMOUNT \
    --order-lifespan=$ORDER_LIFESPAN \
    --gas auto --fees $FEES \
    --from $WALLET \
    -y 

crescentd query liquidity orders --pair-id=1 -o json | jq .
crescentd query liquidity orders --pair-id=1 -o json | jq . | grep \"id\"

