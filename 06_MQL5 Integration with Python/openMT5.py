# -*- coding: utf-8 -*-
"""
Created on Sat Aug 10 19:32:45 2024

@author: Mohamed Hassan
"""

import MetaTrader5 as mt5

print ("MetaTrader5 PKG version: ",mt5.__version__)

if mt5.initialize(login=51761832, server="ICMarketsSC-Demo",password="Demo1234!"):

    print ("MT5 initialized Successfully")
    
else: print ("MT5 initialization Failed, Error code ",mt5.last_error())
 
