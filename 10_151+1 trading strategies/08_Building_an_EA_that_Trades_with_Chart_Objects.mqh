//+------------------------------------------------------------------+
//|                              Project 17 Trend Line Object EA.mq5 |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property version   "1.00"
#include <Trade/Trade.mqh>
CTrade trade;

int MagicNumber = 266;

input string down_trend = ""; // Down Trend Line
input string up_trend = ""; // Up Trend Line
input ENUM_TIMEFRAMES time_frame = PERIOD_CURRENT; // TIME FRAME

/*
TO DO:
Add Stocks Version with int LOT SIZE
delete sell orders, keep only buy

*/

//input int lot_size = 10; // LOT SIZE
input double lot_size = 0.02; // LOT SIZE

enum line_type
  {
   reversal = 0, //REVERSAL
   break_out = 1, //BREAK-OUT
   reverse_break = 2 // REVERSAL AND BREAK-OUT
  };
input line_type line_exe =  reverse_break; // MODE

ulong chart_id = ChartID();

double close_price[];
double open_price[];
double low_price[];
double high_price[];
datetime time_price[];

double td_line_value;
double td1_line_value;
double td2_line_value;
double td3_line_value;

datetime lastTradeBarTime = 0;
double ask_price;
double take_profit;

double t_line_value;
double t1_line_value;
double t2_line_value;
double t3_line_value;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   ArraySetAsSeries(close_price, true);
   ArraySetAsSeries(open_price, true);
   ArraySetAsSeries(low_price, true);
   ArraySetAsSeries(high_price, true);
   ArraySetAsSeries(time_price, true);
   
   
   trade.SetExpertMagicNumber(MagicNumber);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   ObjectSetInteger(chart_id,down_trend,OBJPROP_RAY_RIGHT,true);
   ObjectSetInteger(chart_id,up_trend,OBJPROP_RAY_RIGHT,true);

   CopyOpen(_Symbol, time_frame, 1, 5, open_price);
   CopyClose(_Symbol, time_frame, 1, 5, close_price);
   CopyLow(_Symbol, time_frame, 1, 5, low_price);
   CopyHigh(_Symbol, time_frame, 1, 5, high_price);
   CopyTime(_Symbol, time_frame, 1, 5, time_price);

/*
//DOWN TREND
   td_line_value = ObjectGetValueByTime(chart_id,down_trend,time_price[0],0);
   td1_line_value = ObjectGetValueByTime(chart_id,down_trend,time_price[1],0);
   td2_line_value = ObjectGetValueByTime(chart_id,down_trend,time_price[2],0);
   td3_line_value = ObjectGetValueByTime(chart_id,down_trend,time_price[3],0);

   bool prev_touch_down = false;

   if((high_price[1] > td1_line_value && close_price[1] < open_price[1])
      ||
      (high_price[2] > td2_line_value && close_price[2] < open_price[2])
     )
     {

      prev_touch_down = true;

     }


   int no_bars_down = 0;

   for(int i = 0; i <= 3; i++)
     {

      if(high_price[i] > ObjectGetValueByTime(chart_id,down_trend,time_price[i],0) && open_price[i] < ObjectGetValueByTime(chart_id,down_trend,time_price[i],0))
        {

         for(int j = i; j >= 0; j--)
           {

            if(close_price[j] < open_price[j] && close_price[j] < ObjectGetValueByTime(chart_id,down_trend,time_price[j],0))
              {

               no_bars_down = Bars(_Symbol,time_frame,time_price[j],TimeCurrent());


               break;

              }


           }
         break;

        }


     }
     
     
   ask_price = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   datetime currentBarTime = iTime(_Symbol, time_frame, 0);


   if(((high_price[1] >= td1_line_value && open_price[1] < td1_line_value) || (high_price[2] >= td2_line_value && open_price[2] < td2_line_value)
       || (high_price[3] >= td3_line_value && open_price[3] < td3_line_value) || (high_price[0] >= td_line_value))
      && (close_price[0] < td_line_value && close_price[0] < open_price[0] && open_price[1] < td1_line_value)
      && (no_bars_down < 3)
      && prev_touch_down == false
      && (currentBarTime != lastTradeBarTime)
      && (line_exe == reversal || line_exe == reverse_break)
     )
     {

      take_profit = MathAbs(ask_price - ((high_price[0] - ask_price) * 4));

      trade.Sell(lot_size,_Symbol,ask_price, high_price[0], take_profit);
      lastTradeBarTime = currentBarTime;

     }

// DOWNTREND BREAKOUT AND RETEST
 bool prev_touch_break_out_down = false;

   if((low_price[1] < td1_line_value && close_price[1] > open_price[1]) ||
      (low_price[2] < td2_line_value && close_price[2] > open_price[2] && open_price[2] > td2_line_value))
     {
      prev_touch_break_out_down = true;
     }

   int no_bars_down_breakout = 0;

   for(int i = 0; i <= 3; i++)
     {

      if(low_price[i] < ObjectGetValueByTime(chart_id, down_trend, time_price[i], 0) &&
         open_price[i] > ObjectGetValueByTime(chart_id, down_trend, time_price[i], 0))
        {

         for(int j = i; j >= 0; j--)
           {
            if(close_price[j] > open_price[j] &&
               close_price[j] > ObjectGetValueByTime(chart_id, down_trend, time_price[j], 0))
              {

               no_bars_down_breakout = Bars(_Symbol, time_frame, time_price[j], TimeCurrent());
               break;
              }
           }
         break;
        }
     }

   if(
      ((low_price[0] < td_line_value && open_price[0] > td_line_value) ||
       (low_price[1] < td1_line_value && open_price[1] > td1_line_value) ||
       (low_price[2] < td2_line_value && open_price[2] > td2_line_value) ||
       (low_price[3] < td3_line_value && open_price[3] > td3_line_value)) &&
      (close_price[0] > open_price[0]) && close_price[0] > td_line_value &&
      (no_bars_down_breakout < 3) &&
      (prev_touch_break_out_down == false) &&
      (currentBarTime != lastTradeBarTime)
      &&  (line_exe == break_out || line_exe == reverse_break)
   )
     {
      take_profit = MathAbs(ask_price + ((ask_price - low_price[0]) * 4));

      trade.Buy(lot_size, _Symbol, ask_price, low_price[0], take_profit);
      

      
      lastTradeBarTime = currentBarTime;
     }
*/  
// UP TREND
   ask_price = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   datetime currentBarTime = iTime(_Symbol, time_frame, 0);
   
   t_line_value = ObjectGetValueByTime(chart_id,up_trend,time_price[0],0);
   t1_line_value = ObjectGetValueByTime(chart_id,up_trend,time_price[1],0);
   t2_line_value = ObjectGetValueByTime(chart_id,up_trend,time_price[2],0);
   t3_line_value = ObjectGetValueByTime(chart_id,up_trend,time_price[3],0);

   int no_bars_up = 0;

   for(int i = 0; i <= 3; i++)
     {
      if(low_price[i] < ObjectGetValueByTime(chart_id, up_trend, time_price[i], 0) &&
         open_price[i] > ObjectGetValueByTime(chart_id, up_trend, time_price[i], 0))
        {
         for(int j = i; j >= 0; j--)
           {
            if(close_price[j] > open_price[j] &&
               close_price[j] > ObjectGetValueByTime(chart_id, up_trend, time_price[j], 0))
              {
               no_bars_up = Bars(_Symbol, time_frame, time_price[j], TimeCurrent());
               break;
              }
           }
         break;
        }
     }

   bool prev_touch_up = false;

   if((low_price[1] < t1_line_value && close_price[1] > open_price[1]) ||
      (low_price[2] < t2_line_value && close_price[2] > open_price[2]))
     {
      prev_touch_up = true;  // Flag that a recent touch already occurred
     }

   if(
      ((low_price[0] < t_line_value && open_price[0] > t_line_value) ||
       (low_price[1] < t1_line_value && open_price[1] > t1_line_value) ||
       (low_price[2] < t2_line_value && open_price[2] > t2_line_value) ||
       (low_price[3] < t3_line_value && open_price[3] > t3_line_value))
      &&
      (close_price[0] > open_price[0]) && close_price[0] > t_line_value
      &&
      (no_bars_up < 3)
      &&
      prev_touch_up == false
      &&
      (currentBarTime != lastTradeBarTime)
       && 
       (line_exe == reversal || line_exe == reverse_break)
   )
     {
      take_profit = MathAbs(ask_price + ((ask_price - low_price[0]) * 4));

      trade.Buy(lot_size, _Symbol, ask_price, low_price[0],take_profit);
      lastTradeBarTime = currentBarTime; // Update last trade bar time to avoid duplicate signals
     }
     
// UPTREND BREAKOUT AND RETEST
   bool prev_touch_break_out_up = false;

   if((high_price[1] > td1_line_value && close_price[1] < open_price[1])
      ||
      (high_price[2] > td2_line_value && close_price[2] < open_price[2])
     )
     {
      prev_touch_break_out_up = true;
     }

   int no_bars_up_break_out = 0;

   for(int i = 0; i <= 3; i++)
     {
      if(high_price[i] > ObjectGetValueByTime(chart_id,down_trend,time_price[i],0) && open_price[i] < ObjectGetValueByTime(chart_id,down_trend,time_price[i],0)
        )
        {
         for(int j = i; j >= 0; j--)
           {
            if(close_price[j] < open_price[j] && close_price[j] < ObjectGetValueByTime(chart_id,down_trend,time_price[j],0))
              {
               no_bars_up_break_out = Bars(_Symbol,time_frame,time_price[j],TimeCurrent());
               break;
              }
           }
         break;
        }
     }
   if(((high_price[1] >= t1_line_value && open_price[1] < t1_line_value) || (high_price[2] >= t2_line_value && open_price[2] < t2_line_value)
       || (high_price[3] >= t3_line_value && open_price[3] < t3_line_value) || (high_price[0] >= t_line_value))
      && (close_price[0] < t_line_value && close_price[0] < open_price[0] && open_price[1] < t1_line_value)
      && (no_bars_up_break_out < 3)
      && (no_bars_up_break_out == false)
      && (currentBarTime != lastTradeBarTime)
      && (line_exe == break_out || line_exe == reverse_break)
     )
     {
      take_profit = MathAbs(ask_price - ((high_price[0] - ask_price) * 4));
      trade.Sell(lot_size,_Symbol,ask_price,high_price[0], take_profit);
      lastTradeBarTime = currentBarTime;
     }
  }