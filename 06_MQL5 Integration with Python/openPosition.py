# -*- coding: utf-8 -*-
"""
Created on Sat Aug 10 23:12:23 2024

@author: Mohamed Hassan
"""

import MetaTrader5 as mt5

print ("MetaTrader5 PKG version: ",mt5.__version__)
print ("MetaTrader5 PKG author: ",mt5.__author__)

if mt5.initialize(login=51761832, server="ICMarketsSC-Demo",password="Demo1234!"):

    print ("MT5 initialized Successfully")
    
else: print ("MT5 initialization Failed, Error code ",mt5.last_error())

symbol="XAUUSD"
lot=0.01
point=mt5.symbol_info(symbol).point
order_type=mt5.ORDER_TYPE_BUY
price=mt5.symbol_info_tick(symbol).ask
sl=mt5.symbol_info_tick(symbol).ask-100
tp=mt5.symbol_info_tick(symbol).ask+150
deviation=10
magic=2222222
comment="python order"
type_time=mt5.ORDER_TIME_GTC
type_filling=mt5.ORDER_FILLING_IOC


point=mt5.symbol_info(symbol).point
request={
    "action":mt5.TRADE_ACTION_DEAL,
    "symbol":symbol,
    "volume":lot,
    "type":order_type,
    "price":price,
    "sl":sl,
    "tp":tp,
    "deviation":deviation,
    "magic":magic,
    "comment":comment,
    "type_time":type_time,
    "type_filling":type_filling,
    }
    
result=mt5.order_check(request)

result=mt5.order_send(request)

mt5.shutdown()
    
    
    
    
    