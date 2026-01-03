//+------------------------------------------------------------------+
//|                              Project 17 Trend Line Object EA.mq5 |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property version   "1.00"
#include <Trade/Trade.mqh>
CTrade trade;

input int MagicNumber = 266;

input string up_trend = ""; // Up Trend Line
input ENUM_TIMEFRAMES time_frame = PERIOD_CURRENT; // TIME FRAME

/*
Original Idea taken from https://www.mql5.com/en/articles/19968
*/

/*
Issue	Before	After
Trend line references	td1_line_value, td2_line_value (down_trend)	t1_line_value, t2_line_value (up_trend)
Object reference	down_trend	up_trend
Previous touch check	Bearish candles (close < open)	Bullish candles (close > open && close > line)
Breakout confirmation	Bearish close below line	Bullish close above line
Retest condition	Price breaking down through line	Price touching line from above (low <= line && open > line)
Entry confirmation	Bearish candle below line	Bullish candle closing above line
*/

input bool use_int_lot = false;       // Use Integer Lot Size (Stocks)
input int lot_size_int = 10;          // LOT SIZE (Integer for Stocks)
input double lot_size_double = 0.02;  // LOT SIZE (Double for Forex)

enum line_type
  {
   //reversal = 0, //REVERSAL
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

datetime lastTradeBarTime = 0;
double ask_price;
double take_profit;

double t_line_value;
double t1_line_value;
double t2_line_value;
double t3_line_value;

int atr_handle; // ATR indicator handle

//+------------------------------------------------------------------+
//| Get lot size based on user selection                             |
//+------------------------------------------------------------------+
double GetLotSize()
  {
   return use_int_lot ? (double)lot_size_int : lot_size_double;
  }

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
   
   // Initialize ATR indicator
   atr_handle = iATR(_Symbol, time_frame, ATR_Period);
   if(atr_handle == INVALID_HANDLE)
     {
      Print("Error creating ATR indicator handle");
      return(INIT_FAILED);
     }

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   if(atr_handle != INVALID_HANDLE)
      IndicatorRelease(atr_handle);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   ObjectSetInteger(chart_id,up_trend,OBJPROP_RAY_RIGHT,true);

   CopyOpen(_Symbol, time_frame, 1, 5, open_price);
   CopyClose(_Symbol, time_frame, 1, 5, close_price);
   CopyLow(_Symbol, time_frame, 1, 5, low_price);
   CopyHigh(_Symbol, time_frame, 1, 5, high_price);
   CopyTime(_Symbol, time_frame, 1, 5, time_price);

// UP TREND
/*
// UP TREND — Support Bounce
Scenario: Price bounces OFF the trend line (line acts as support)

Aspect	Logic
Detection	low_price < line && open_price > line
Meaning	Candle opened above line, wick dipped below, then closed back above
Pattern	Price testing support and bouncing
Mode	Only when line_exe == reverse_break
*/
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
      (line_exe == reverse_break)
   )
     {
      // Get ATR value
      double atr_buffer[];
      ArraySetAsSeries(atr_buffer, true);
      if(CopyBuffer(atr_handle, 0, 0, 1, atr_buffer) > 0)
        {
         double atr = atr_buffer[0];
         double stop_loss = ask_price - (ATR_Mult_SL * atr);
         double take_profit = ask_price + (ATR_Mult_TP * atr);
         
         trade.Buy(GetLotSize(), _Symbol, ask_price, stop_loss, take_profit);
         lastTradeBarTime = currentBarTime; // Update last trade bar time to avoid duplicate signals
        }
     }
     
// UPTREND BREAKOUT AND RETEST
/*
// UPTREND BREAKOUT AND RETEST — Resistance Breakout
Scenario: Price breaks THROUGH the trend line, then retests it (line flips from resistance → support)

Aspect	Logic
Breakout Detection	high_price > line && open_price < line
Meaning	Candle opened below line, broke above (initial breakout)
Retest Detection	low_price <= line && open_price > line
Meaning	After breakout, price comes back to touch line from above (retest)
Mode	When line_exe == break_out OR line_exe == reverse_break
Visual (matches your image):
*/

// Descending trend line breakout: price breaks above, retests from above, bullish confirmation = Buy
   bool prev_touch_break_out_up = false;

   // Check if a recent breakout-retest interaction already occurred (to avoid duplicate trades)
   if((low_price[1] < t1_line_value && close_price[1] > open_price[1] && close_price[1] > t1_line_value)
      ||
      (low_price[2] < t2_line_value && close_price[2] > open_price[2] && close_price[2] > t2_line_value)
     )
     {
      prev_touch_break_out_up = true;
     }

   int no_bars_up_break_out = 0;

   // Find the breakout candle: high pierced above the line, open was below (initial breakout)
   for(int i = 0; i <= 3; i++)
     {
      if(high_price[i] > ObjectGetValueByTime(chart_id, up_trend, time_price[i], 0) && 
         open_price[i] < ObjectGetValueByTime(chart_id, up_trend, time_price[i], 0))
        {
         // Look for confirming bullish candle that closed above the line
         for(int j = i; j >= 0; j--)
           {
            if(close_price[j] > open_price[j] && 
               close_price[j] > ObjectGetValueByTime(chart_id, up_trend, time_price[j], 0))
              {
               no_bars_up_break_out = Bars(_Symbol, time_frame, time_price[j], TimeCurrent());
               break;
              }
           }
         break;
        }
     }

   // Entry condition: retest touch from above + bullish confirmation
   if(
      // Retest: low touches/pierces the line from above (open was above line)
      ((low_price[0] <= t_line_value && open_price[0] > t_line_value) ||
       (low_price[1] <= t1_line_value && open_price[1] > t1_line_value) ||
       (low_price[2] <= t2_line_value && open_price[2] > t2_line_value) ||
       (low_price[3] <= t3_line_value && open_price[3] > t3_line_value))
      &&
      // Bullish confirmation: current candle is bullish and closed above the line
      (close_price[0] > open_price[0]) && close_price[0] > t_line_value
      &&
      // Not too many bars since last breakout setup
      (no_bars_up_break_out < 3)
      &&
      // No recent breakout touch already recorded
      (prev_touch_break_out_up == false)
      &&
      // One trade per candle
      (currentBarTime != lastTradeBarTime)
      &&
      // Mode allows breakout trades
      (line_exe == break_out || line_exe == reverse_break)
     )
     {
      // Get ATR value for SL and TP calculation
      double atr_buffer[];
      ArraySetAsSeries(atr_buffer, true);
      if(CopyBuffer(atr_handle, 0, 0, 1, atr_buffer) > 0)
        {
         double atr = atr_buffer[0];
         double stop_loss = ask_price - (ATR_Mult_SL * atr);
         double take_profit = ask_price + (ATR_Mult_TP * atr);
         
         trade.Buy(GetLotSize(), _Symbol, ask_price, stop_loss, take_profit);
         lastTradeBarTime = currentBarTime;
        }
     }
  }

  /*
Summary
Feature	UP TREND	UPTREND BREAKOUT AND RETEST
Line role	Support	Resistance → becomes Support
Entry type	Bounce	Break + Retest + Confirm
Requires prior breakout	No	Yes (high pierced above line)
Best for	Ascending support lines	Descending resistance lines
  */