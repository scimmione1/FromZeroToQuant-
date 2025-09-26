# -*- coding: utf-8 -*-
"""
Created on Sat Aug 10 23:55:20 2024

@author: Mohamed Hassan
"""

import MetaTrader5 as mt5
import pandas as pd
import plotly.express as px
from plotly.offline import plot

from datetime import datetime

print ("MetaTrader5 PKG version: ",mt5.__version__)
print ("MetaTrader5 PKG author: ",mt5.__author__)

if mt5.initialize(login=51761832, server="ICMarketsSC-Demo",password="Demo1234!"):

    print ("MT5 initialized Successfully")
    
else: print ("MT5 initialization Failed, Error code ",mt5.last_error())

xauusd_data=pd.DataFrame(mt5.copy_rates_range("XAUUSD", mt5.TIMEFRAME_D1, datetime(2023,8,1), datetime.now()))
xauusd_data['time'] = pd.to_datetime(xauusd_data['time'],unit='s')


print(xauusd_data)

fig = px.line(xauusd_data, x=xauusd_data['time'], y=xauusd_data['close'])
plot(fig)



