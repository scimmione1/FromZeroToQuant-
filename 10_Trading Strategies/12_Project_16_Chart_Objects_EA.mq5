//+------------------------------------------------------------------+
//|                                   Project 16 Chart Object EA.mq5 |
//|                                             Abioye Israel Pelumi |
//|                             https://linktr.ee/abioyeisraelpelumi |
//+------------------------------------------------------------------+
#property copyright "Abioye Israel Pelumi"
#property link      "https://linktr.ee/abioyeisraelpelumi"
#property version   "1.00"
#include <Trade/Trade.mqh>
CTrade trade;
int MagicNumber = 533915;  // Unique Number
double lot_size = 0.2; // Lot Size


input string reistance = ""; // Resistance Object Name
input string support = ""; // Support Object Name
input ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT; // TIME-FRAME
input double RRR = 2; // Risk Reward Ratio



ulong chart_id = ChartID();

double res_anchor1_price;
double res_anchor2_price;

double res_max_price;
double res_min_price;

long res_anchor1_time;
long res_anchor2_time;

datetime res_start_time;
datetime res_end_time;

int res_total_bars;
double res_close[];
double res_open[];
double res_high[];
double res_low[];
datetime res_time[];

double high;
datetime high_time;
double low;
datetime low_time;

double higher_low;
datetime higher_low_time;
double higher_high;
datetime higher_high_time;


int max_high_index;
double max_high;

double ask_price;
double take_profit;
datetime lastTradeBarTime = 0;

double sup_anchor1_price;
double sup_anchor2_price;

double sup_max_price;
double sup_min_price;

long sup_anchor1_time;
long sup_anchor2_time;

datetime sup_start_time;
datetime sup_end_time;

int sup_total_bars;
double sup_close[];
double sup_open[];
double sup_high[];
double sup_low[];
datetime sup_time[];

double lower_high;
datetime lower_high_time;
double lower_low;
datetime lower_low_time;

int min_low_index;
double min_low;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   ArraySetAsSeries(res_close,true);
   ArraySetAsSeries(res_open,true);
   ArraySetAsSeries(res_high,true);
   ArraySetAsSeries(res_low,true);
   ArraySetAsSeries(res_time,true);

   ArraySetAsSeries(sup_close,true);
   ArraySetAsSeries(sup_open,true);
   ArraySetAsSeries(sup_high,true);
   ArraySetAsSeries(sup_low,true);
   ArraySetAsSeries(sup_time,true);

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
   res_anchor1_price = NormalizeDouble(ObjectGetDouble(chart_id,reistance,OBJPROP_PRICE,0),_Digits);
   res_anchor2_price = NormalizeDouble(ObjectGetDouble(chart_id,reistance,OBJPROP_PRICE,1),_Digits);

   res_max_price = NormalizeDouble(MathMax(res_anchor1_price,res_anchor2_price),_Digits);
   res_min_price = NormalizeDouble(MathMin(res_anchor1_price,res_anchor2_price),_Digits);


   res_anchor1_time =  ObjectGetInteger(chart_id,reistance,OBJPROP_TIME,0);
   res_anchor2_time = ObjectGetInteger(chart_id,reistance,OBJPROP_TIME,1);

   res_start_time = (datetime)MathMin(res_anchor1_time,res_anchor2_time);
   res_end_time = (datetime)MathMax(res_anchor1_time,res_anchor2_time);


   res_total_bars = Bars(_Symbol,timeframe,TimeCurrent(),res_start_time);

   CopyOpen(_Symbol, timeframe, TimeCurrent(), res_start_time, res_open);
   CopyClose(_Symbol, timeframe, TimeCurrent(), res_start_time, res_close);
   CopyLow(_Symbol, timeframe, TimeCurrent(), res_start_time,  res_low);
   CopyHigh(_Symbol, timeframe, TimeCurrent(), res_start_time, res_high);
   CopyTime(_Symbol, timeframe, TimeCurrent(), res_start_time, res_time);

   datetime currentBarTime = iTime(_Symbol, timeframe, 0);
   ask_price = SymbolInfoDouble(_Symbol,SYMBOL_ASK);




   for(int i = 4; i < res_total_bars-3; i++)
     {

      if(IsSwingHigh(res_high, i, 3))
        {

         higher_high = res_high[i];
         higher_high_time = res_time[i];


         for(int j = i; j < res_total_bars-3; j++)
           {

            if(IsSwingLow(res_low,j,3))
              {
               higher_low = res_low[j];
               higher_low_time = res_time[j];

               for(int k = j; k < res_total_bars-3; k++)
                 {

                  if(IsSwingHigh(res_high, k, 3))
                    {

                     high = res_high[k];
                     high_time = res_time[k];

                     for(int l = k; l < res_total_bars-3; l++)
                       {

                        if(IsSwingLow(res_low,l,3))
                          {

                           //   ObjectCreate(chart_id,"kk",OBJ_VLINE,0,res_time[l],0);
                           ObjectDelete(chart_id,"kk");

                           low = res_low[l];
                           low_time = res_time[l];

                           for(int m = i; m > 0; m--)
                             {

                              if(res_close[m] < higher_low && res_open[m] > higher_low)
                                {


                                 if(higher_low < higher_high && high > higher_low && high < higher_high && low < high && low < higher_low)
                                   {

                                    ObjectCreate(chart_id,"HHHL",OBJ_TREND,0,higher_high_time,higher_high,higher_low_time,higher_low);
                                    ObjectSetInteger(chart_id,"HHHL",OBJPROP_COLOR,clrRed);
                                    ObjectSetInteger(chart_id,"HHHL",OBJPROP_WIDTH,2);


                                    ObjectCreate(chart_id,"HLH",OBJ_TREND,0,higher_low_time,higher_low,high_time,high);
                                    ObjectSetInteger(chart_id,"HLH",OBJPROP_COLOR,clrRed);
                                    ObjectSetInteger(chart_id,"HLH",OBJPROP_WIDTH,2);

                                    ObjectCreate(chart_id,"HL",OBJ_TREND,0,high_time,high,low_time,low);
                                    ObjectSetInteger(chart_id,"HL",OBJPROP_COLOR,clrRed);
                                    ObjectSetInteger(chart_id,"HL",OBJPROP_WIDTH,2);

                                    ObjectCreate(chart_id,"Cross Line",OBJ_TREND,0,higher_low_time,higher_low,res_time[m],higher_low);
                                    ObjectSetInteger(chart_id,"Cross Line",OBJPROP_COLOR,clrRed);
                                    ObjectSetInteger(chart_id,"Cross Line",OBJPROP_WIDTH,2);

                                    max_high_index = ArrayMaximum(res_high,0,res_total_bars);
                                    max_high = res_high[max_high_index];

                                    if(max_high < res_max_price && higher_high > res_min_price && higher_high < res_max_price)
                                      {

                                       if(res_time[1] == res_time[m] && currentBarTime != lastTradeBarTime)
                                         {

                                          take_profit = MathAbs(ask_price - ((high - ask_price) * RRR));

                                          trade.Sell(lot_size,_Symbol,ask_price,high,take_profit);
                                          lastTradeBarTime = currentBarTime;

                                         }

                                      }


                                   }

                                 break;
                                }
                             }

                           break;
                          }
                       }

                     break;
                    }
                 }

               break;
              }
           }

         break;

        }
     }




   sup_anchor1_price = NormalizeDouble(ObjectGetDouble(chart_id,support,OBJPROP_PRICE,0),_Digits);
   sup_anchor2_price = NormalizeDouble(ObjectGetDouble(chart_id,support,OBJPROP_PRICE,1),_Digits);

   sup_max_price = NormalizeDouble(MathMax(sup_anchor1_price,sup_anchor2_price),_Digits);
   sup_min_price = NormalizeDouble(MathMin(sup_anchor1_price,sup_anchor2_price),_Digits);

   sup_anchor1_time =  ObjectGetInteger(chart_id,support,OBJPROP_TIME,0);
   sup_anchor2_time = ObjectGetInteger(chart_id,support,OBJPROP_TIME,1);

   sup_start_time = (datetime)MathMin(sup_anchor1_time,sup_anchor2_time);
   sup_end_time = (datetime)MathMax(sup_anchor1_time,sup_anchor2_time);

   sup_total_bars = Bars(_Symbol,timeframe,TimeCurrent(),sup_start_time);

   CopyOpen(_Symbol, timeframe, TimeCurrent(), sup_start_time, sup_open);
   CopyClose(_Symbol, timeframe, TimeCurrent(), sup_start_time, sup_close);
   CopyLow(_Symbol, timeframe, TimeCurrent(), sup_start_time,  sup_low);
   CopyHigh(_Symbol, timeframe, TimeCurrent(), sup_start_time, sup_high);
   CopyTime(_Symbol, timeframe, TimeCurrent(), sup_start_time, sup_time);


   for(int i = 4; i < sup_total_bars-3; i++)
     {
      if(IsSwingLow(sup_low, i, 3))
        {

         lower_low = sup_low[i];
         lower_low_time = sup_time[i];

         for(int j = i; j < sup_total_bars-3; j++)
           {

            if(IsSwingHigh(sup_high,j,3))
              {

               lower_high = sup_high[j];
               lower_high_time = sup_time[j];

               for(int k = j; k < sup_total_bars-3; k++)
                 {

                  if(IsSwingLow(sup_low, k, 3))
                    {

                     low = sup_low[k];
                     low_time = sup_time[k];

                     for(int l = k; l < sup_total_bars-3; l++)
                       {

                        if(IsSwingHigh(sup_high,l,3))
                          {

                           high = sup_high[l];
                           high_time = sup_time[l];

                           for(int m = i; m > 0; m--)
                             {

                              if(sup_close[m] > lower_high && sup_open[m] < lower_high)
                                {

                                 if(lower_high > lower_low && low < lower_high && low > lower_low && high > low && high > lower_high)
                                   {

                                    ObjectCreate(chart_id,"LLLH",OBJ_TREND,0,lower_low_time,lower_low,lower_high_time,lower_high);
                                    ObjectSetInteger(chart_id,"LLLH",OBJPROP_COLOR,clrRed);
                                    ObjectSetInteger(chart_id,"LLLH",OBJPROP_WIDTH,2);


                                    ObjectCreate(chart_id,"LHL",OBJ_TREND,0,lower_high_time,lower_high,low_time,low);
                                    ObjectSetInteger(chart_id,"LHL",OBJPROP_COLOR,clrRed);
                                    ObjectSetInteger(chart_id,"LHL",OBJPROP_WIDTH,2);

                                    ObjectCreate(chart_id,"LH",OBJ_TREND,0,low_time,low,high_time,high);
                                    ObjectSetInteger(chart_id,"LH",OBJPROP_COLOR,clrRed);
                                    ObjectSetInteger(chart_id,"LH",OBJPROP_WIDTH,2);

                                    ObjectCreate(chart_id,"S Cross Line",OBJ_TREND,0,lower_high_time,lower_high,sup_time[m],lower_high);
                                    ObjectSetInteger(chart_id,"S Cross Line",OBJPROP_COLOR,clrRed);
                                    ObjectSetInteger(chart_id,"S Cross Line",OBJPROP_WIDTH,2);

                                    min_low_index = ArrayMinimum(sup_low,0,sup_total_bars);
                                    min_low = sup_low[min_low_index];

                                    if(min_low > sup_min_price && lower_low < sup_max_price && lower_low > sup_min_price)
                                      {

                                       if(sup_time[1] == sup_time[m] && currentBarTime != lastTradeBarTime)
                                         {

                                          take_profit = MathAbs(ask_price + ((ask_price - low) * RRR));

                                          trade.Buy(lot_size,_Symbol,ask_price,low,take_profit);
                                          lastTradeBarTime = currentBarTime;

                                         }



                                      }

                                   }


                                 break;
                                }

                             }

                           break;
                          }
                       }

                     break;
                    }
                 }



               break;
              }
           }


         break;
        }


     }





  }
//+------------------------------------------------------------------+
//| FUNCTION FOR SWING LOW                                           |
//+------------------------------------------------------------------+
bool IsSwingLow(const double &low_price[], int index, int lookback)
  {
   for(int i = 1; i <= lookback; i++)
     {
      if(low_price[index] > low_price[index - i] || low_price[index] > low_price[index + i])
         return false;
     }
   return true;
  }


//+------------------------------------------------------------------+
//| FUNCTION FOR SWING HIGH                                          |
//+------------------------------------------------------------------+
bool IsSwingHigh(const double &high_price[], int index, int lookback)
  {
   for(int i = 1; i <= lookback; i++)
     {
      if(high_price[index] < high_price[index - i] || high_price[index] < high_price[index + i])
         return false; // If the current high is not the highest, return false.
     }
   return true;
  }
//+------------------------------------------------------------------+
