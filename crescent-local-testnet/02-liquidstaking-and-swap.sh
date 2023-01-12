# VARIABLES - CRESCENT
CHAIN_ID=local-mooncat
VHOME=$HOME/$CHAIN_ID

#----------------------------------------------------------------------#
# check current list of liquid validators
crescentd q liquidstaking liquid-validators --home $VHOME

# Liquid staking - get bcre
WALLET=relayer
AMOUNT=100000000000ucre
FEES=1000ucre
crescentd tx liquidstaking liquid-stake $AMOUNT \
    --from $WALLET --home $VHOME --gas 1000000 --fees $FEES -y

crescentd q bank balances $(crescentd keys show $WALLET -a --home $VHOME) --home $VHOME


#----------------------------------------------------------------------#
# Create a pair
BASE="ucre"
QUOTE="ubcre"
crescentd tx liquidity create-pair $BASE  $QUOTE \
--from $WALLET  \
--chain-id $CHAIN_ID -b block \
--fees $FEES \
--home $VHOME -y

crescentd q liquidity pairs --home $VHOME
crescentd q liquidity pair 1 --home $VHOME | jq .


#----------------------------------------------------------------------#
# Swap to initiate last price : Limit Order - BUY
PAIRID=1
DIRECTION=buy
OFFER_COIN=1000000ubcre
DEMAND_COIN_DENOM=ucre
PRICE=1.00
AMOUNT=1000000
ORDER_LIFESPAN=1m
FEES=1000ucre

crescentd tx liquidity limit-order $PAIRID $DIRECTION $OFFER_COIN $DEMAND_COIN_DENOM $PRICE $AMOUNT \
    --from $WALLET \
    --fees $FEES \
    --home $VHOME -y \
    --order-lifespan=$ORDER_LIFESPAN

crescentd query liquidity orders --pair-id 1 --home $VHOME  | jq .
crescentd query liquidity orders --pair-id 1 --home $VHOME  | jq . | grep status
crescentd query liquidity orders --pair-id 1 --home $VHOME | jq . | grep \"id\"

# Check the last price after 1m
crescentd q liquidity pair 1 --home $VHOME | jq .


# Submit BUY limit order again, then sell at below.
# Swap to initiate last price : Limit Order - SELL
PAIRID=1
DIRECTION=sell
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

crescentd query liquidity orders --pair-id 1 --home $VHOME  | jq .
crescentd query liquidity orders --pair-id 1 --home $VHOME  | jq . | grep status


#----------------------------------------------------------------------#
# Market Order
# A market making order is a set of limit orders for each buy/sell side.
# You can leave one side(but not both) empty by passing 0 as its arguments.
# crescentd tx liquidity mm-order [pair-id] [max-sell-price] [min-sell-price] [sell-amount] [max-buy-price] [min-buy-price] [buy-amount] [flags]

# REPEAT SELL - BUY 
## Observation : The previous orders are canceled if new order arrived

# SELL
PAIR_ID=1
MAX_SELL=1.04
MIN_SELL=0.99
SELL_AMOUNT=100000000
MAX_BUY=0
MIN_BUY=0
BUY_AMOUNT=0
ORDER_LIFESPAN=3m
FEES=1000ucre
WALLET=relayer

crescentd tx liquidity mm-order $PAIR_ID \
    $MAX_SELL  $MIN_SELL  $SELL_AMOUNT \
    $MAX_BUY  $MIN_BUY  $BUY_AMOUNT \
    --order-lifespan=$ORDER_LIFESPAN \
    --gas auto --fees $FEES \
    --from $WALLET \
    --home $VHOME \
    -y 

crescentd query liquidity orders --pair-id=1 -o json --home $VHOME | jq . | egrep "direction|status|price"

crescentd q liquidity order-books 1 --num-ticks=3 --home $VHOME | jq


# BUY
PAIR_ID=1
MAX_SELL=0
MIN_SELL=0
SELL_AMOUNT=0
MAX_BUY=1.0
MIN_BUY=0.95
BUY_AMOUNT=100000000
ORDER_LIFESPAN=3m
FEES=1000ucre
WALLET=relayer

crescentd tx liquidity mm-order $PAIR_ID \
    $MAX_SELL  $MIN_SELL  $SELL_AMOUNT \
    $MAX_BUY  $MIN_BUY  $BUY_AMOUNT \
    --order-lifespan=$ORDER_LIFESPAN \
    --gas auto --fees $FEES \
    --from $WALLET \
    --home $VHOME \
    -y 

crescentd query liquidity orders --pair-id=1 -o json --home $VHOME | jq . | egrep "direction|status|price"

crescentd q liquidity order-books 1 --num-ticks=3 --home $VHOME | jq


# BUY AND SELL
PAIR_ID=1
MAX_SELL=1.04
MIN_SELL=0.99
SELL_AMOUNT=100000000
MAX_BUY=1.0
MIN_BUY=0.96
BUY_AMOUNT=100000000
ORDER_LIFESPAN=3m
FEES=1000ucre
WALLET=relayer

crescentd tx liquidity mm-order $PAIR_ID \
    $MAX_SELL  $MIN_SELL  $SELL_AMOUNT \
    $MAX_BUY  $MIN_BUY  $BUY_AMOUNT \
    --order-lifespan=$ORDER_LIFESPAN \
    --gas auto --fees $FEES \
    --from $WALLET \
    --home $VHOME \
    -y 

crescentd query liquidity orders --pair-id=1 -o json --home $VHOME | jq . | egrep "direction|status|price"
