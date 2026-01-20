//+------------------------------------------------------------------+
//|                   Horizontal_Resistance_Breakout_EA_with_ATR.mq5 |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property version   "1.00"
#include <Trade/Trade.mqh>
CTrade trade;

input int MagicNumber = 266;

input string resistance_line = "H1 Horizontal Line 58065"; // Horizontal Resistance Line
input ENUM_TIMEFRAMES time_frame = PERIOD_CURRENT; // TIME FRAME

/*
Horizontal Resistance Breakout Strategy:
- Detects when price breaks above a horizontal resistance line
- Enters long when price retests the resistance (now support) from above
- Uses ATR-based stop loss and take profit
- Supports both breakout and reversal modes
*/

input bool use_int_lot = false;       // Use Integer Lot Size (Stocks)
input int lot_size_int = 10;          // LOT SIZE (Integer for Stocks)
input double lot_size_double = 0.02;  // LOT SIZE (Double for Forex)

// === Dynamic ATR Parameters ===
input int    ATR_Period        = 14;       // ATR Period
input double ATR_Mult_SL       = 2.0;      // ATR Multiplier for Stop Loss
input double ATR_Mult_TP       = 3.0;      // ATR Multiplier for Take Profit

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

double resistance_value; // Current resistance line value

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
   CopyOpen(_Symbol, time_frame, 1, 5, open_price);
   CopyClose(_Symbol, time_frame, 1, 5, close_price);
   CopyLow(_Symbol, time_frame, 1, 5, low_price);
   CopyHigh(_Symbol, time_frame, 1, 5, high_price);
   CopyTime(_Symbol, time_frame, 1, 5, time_price);

   ask_price = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   datetime currentBarTime = iTime(_Symbol, time_frame, 0);
   
   // Get horizontal resistance line value
   resistance_value = ObjectGetDouble(chart_id, resistance_line, OBJPROP_PRICE, 0);
   
   // Validate that the line exists and has a valid price
   if(resistance_value <= 0)
     {
      Print("Error: Resistance line not found or invalid price");
      return;
     }

// RESISTANCE BOUNCE (Support Retest after becoming support)
/*
Scenario: Price bounces OFF the horizontal line (line acts as support after being resistance)

Aspect	Logic
Detection	low_price < resistance && open_price > resistance
Meaning	Candle opened above line, wick dipped below, then closed back above
Pattern	Price testing support and bouncing (line was previously resistance)
Mode	Only when line_exe == reverse_break
*/

   int no_bars_up = 0;

   for(int i = 0; i <= 3; i++)
     {
      if(low_price[i] < resistance_value && open_price[i] > resistance_value)
        {
         for(int j = i; j >= 0; j--)
           {
            if(close_price[j] > open_price[j] && close_price[j] > resistance_value)
              {
               no_bars_up = Bars(_Symbol, time_frame, time_price[j], TimeCurrent());
               break;
              }
           }
         break;
        }
     }

   bool prev_touch_up = false;

   if((low_price[1] < resistance_value && close_price[1] > open_price[1]) ||
      (low_price[2] < resistance_value && close_price[2] > open_price[2]))
     {
      prev_touch_up = true;  // Flag that a recent touch already occurred
     }

   if(
      ((low_price[0] < resistance_value && open_price[0] > resistance_value) ||
       (low_price[1] < resistance_value && open_price[1] > resistance_value) ||
       (low_price[2] < resistance_value && open_price[2] > resistance_value) ||
       (low_price[3] < resistance_value && open_price[3] > resistance_value))
      &&
      (close_price[0] > open_price[0]) && close_price[0] > resistance_value
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
     
// RESISTANCE BREAKOUT AND RETEST
/*
Scenario: Price breaks THROUGH the horizontal resistance, then retests it (line flips from resistance → support)

Aspect	Logic
Breakout Detection	high_price > resistance && open_price < resistance
Meaning	Candle opened below resistance, broke above (initial breakout)
Retest Detection	low_price <= resistance && open_price > resistance
Meaning	After breakout, price comes back to touch resistance (now support) from above (retest)
Mode	When line_exe == break_out OR line_exe == reverse_break
*/

   bool prev_touch_break_out_up = false;

   // Check if a recent breakout-retest interaction already occurred (to avoid duplicate trades)
   if((low_price[1] < resistance_value && close_price[1] > open_price[1] && close_price[1] > resistance_value)
      ||
      (low_price[2] < resistance_value && close_price[2] > open_price[2] && close_price[2] > resistance_value)
     )
     {
      prev_touch_break_out_up = true;
     }

   int no_bars_up_break_out = 0;

   // Find the breakout candle: high pierced above resistance, open was below (initial breakout)
   for(int i = 0; i <= 3; i++)
     {
      if(high_price[i] > resistance_value && open_price[i] < resistance_value)
        {
         // Look for confirming bullish candle that closed above the resistance
         for(int j = i; j >= 0; j--)
           {
            if(close_price[j] > open_price[j] && close_price[j] > resistance_value)
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
      // Retest: low touches/pierces the resistance from above (open was above resistance)
      ((low_price[0] <= resistance_value && open_price[0] > resistance_value) ||
       (low_price[1] <= resistance_value && open_price[1] > resistance_value) ||
       (low_price[2] <= resistance_value && open_price[2] > resistance_value) ||
       (low_price[3] <= resistance_value && open_price[3] > resistance_value))
      &&
      // Bullish confirmation: current candle is bullish and closed above resistance
      (close_price[0] > open_price[0]) && close_price[0] > resistance_value
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
Feature	RESISTANCE BOUNCE	RESISTANCE BREAKOUT AND RETEST
Line role	Support (after flip)	Resistance → becomes Support
Entry type	Bounce	Break + Retest + Confirm
Requires prior breakout	No	Yes (high pierced above resistance)
Best for	Horizontal support after flip	Horizontal resistance breakouts
  */