//+------------------------------------------------------------------+
//| Expert Advisor - VWAP with CDL Pattern                           |
//+------------------------------------------------------------------+
#property strict

// === Parameters generali ===
extern int    MagicNumber       = 253;      // Magic Number EA
extern double AccountRisk       = 0.01;     // Account risk per trade
extern double RiskPercent       = 1.0;      // % risk per trade
extern double MaxLot            = 0.1;      // Maximum allowed lot
extern bool UseFixedLot         = true;     // true = use fixed lot, false = percentage calculation
extern double FixedLot          = 0.05;     // Fixed lot when UseFixedLot = true
extern int   VWAP_Period        = 14;       // VWAP calculation period

// === Dynamic ATR Parameters ===
extern int    ATR_Period        = 14;
extern double ATR_Mult_SL       = 2.0;
extern double ATR_Mult_TP       = 3.0;
extern int Slippage             = 3;

// === CDL Patterns ===
//Bullish reversal patterns
extern bool CDLHAMMER           = false;
extern bool CDLINVERTEDHAMMER   = false;
extern bool CDLMORNINGSTAR      = false;
extern bool CDLMORNINGDOJISTAR  = false;  
extern bool CDLENGULFING        = false;
extern bool CDLPIERCING         = false;
extern bool CDLHARAMI           = false;
extern bool CDLHARAMICROSS      = false;
extern bool CDLTAKURI           = true;

//Bullish continuation patterns  
extern bool CDL3WHITESOLDIERS      = false;
extern bool CDLRISEFALL3METHODS    = false;
extern bool CDLMATHOLD             = false;
extern bool CDLSEPARATINGLINES     = false;
extern bool CDLTASUKIGAP           = false;

//Bullish bottom patterns
extern bool CDLABANDONEDBABY       = false;
extern bool CDLLADDERBOTTOM        = false;
extern bool CDLMATCHINGLOW         = false;
extern bool CDLUNIQUE3RIVER        = false;

//Bullish special patterns
extern bool CDL3INSIDE             = false;
extern bool CDL3OUTSIDE            = false;
extern bool CDBELTHOLD             = false;
extern bool CDLBREAKAWAY           = false;
extern bool CDLKICKING             = false;
extern bool CDLKICKINGBYLENGTH     = false;
extern bool CDLSTICKSANDWICH       = false;

//+------------------------------------------------------------------+
//| Dynamic lot calculation based on risk                            |
//+------------------------------------------------------------------+
double CalculateLotSize(double stopLossPips)
{
   if (UseFixedLot)
      return MathMin(FixedLot, MaxLot); // Use fixed lot, limited to MaxLot

   double riskAmount = AccountBalance() * (RiskPercent / 100.0);
   double lotSize = 0.0;
   double pipValue = MarketInfo(Symbol(), MODE_TICKVALUE);
   double tickSize = MarketInfo(Symbol(), MODE_TICKSIZE);
   double pipPerLot = pipValue / tickSize * Point;

   if (stopLossPips > 0)
      lotSize = riskAmount / (stopLossPips * pipPerLot);
   else
      lotSize = 0.01;

   // Limit the maximum lot size anyway
   lotSize = MathMin(lotSize, MaxLot);
   return NormalizeDouble(lotSize, 2);
}

//+------------------------------------------------------------------+
//| Function to close all open positions                             |
//+------------------------------------------------------------------+
void CloseAllPositions()
{
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         int type = OrderType();
         if (type == OP_BUY)
            OrderClose(OrderTicket(), OrderLots(), Bid, 3, clrRed);
         else if (type == OP_SELL)
            OrderClose(OrderTicket(), OrderLots(), Ask, 3, clrRed);
      }
   }
}

//+------------------------------------------------------------------+
//| Function to return candle patterns with value "true"             |
//+------------------------------------------------------------------+
void GetActiveCandlePattern(bool &isBullish)
{
   isBullish = false;

   if(CDLHAMMER && iCandlestickPattern(NULL,0,0) == 1) isBullish = true;
   else if(CDLINVERTEDHAMMER && iCandlestickPattern(NULL,0,0) == 2) isBullish = true;
   else if(CDLMORNINGSTAR && iCandlestickPattern(NULL,0,0) == 3) isBullish = true;
   else if(CDLMORNINGDOJISTAR && iCandlestickPattern(NULL,0,0) == 4) isBullish = true;
   else if(CDLENGULFING && iCandlestickPattern(NULL,0,0) == 5) isBullish = true;
   else if(CDLPIERCING && iCandlestickPattern(NULL,0,0) == 6) isBullish = true;
   else if(CDLHARAMI && iCandlestickPattern(NULL,0,0) == 7) isBullish = true;
   else if(CDLHARAMICROSS && iCandlestickPattern(NULL,0,0) == 8) isBullish = true;
   else if(CDLTAKURI && iCandlestickPattern(NULL,0,0) == 9) isBullish = true;
   else if(CDL3WHITESOLDIERS && iCandlestickPattern(NULL,0,0) == 10) isBullish = true;
   else if(CDLRISEFALL3METHODS && iCandlestickPattern(NULL,0,0) == 11) isBullish = true;
   else if(CDLMATHOLD && iCandlestickPattern(NULL,0,0) == 12) isBullish = true;
   else if(CDLSEPARATINGLINES && iCandlestickPattern(NULL,0,0) == 13) isBullish = true;
   else if(CDLTASUKIGAP && iCandlestickPattern(NULL,0,0) == 14) isBullish = true;
   else if(CDLABANDONEDBABY && iCandlestickPattern(NULL,0,0) == 15) isBullish = true;
   else if(CDLLADDERBOTTOM && iCandlestickPattern(NULL,0,0) == 16) isBullish = true;
   else if(CDLMATCHINGLOW && iCandlestickPattern(NULL,0,0) == 17) isBullish = true;
   else if(CDLUNIQUE3RIVER && iCandlestickPattern(NULL,0,0) == 18) isBullish = true;
   else if(CDL3INSIDE && iCandlestickPattern(NULL,0,0) == 19) isBullish = true;
   else if(CDL3OUTSIDE && iCandlestickPattern(NULL,0,0) == 20) isBullish = true;
   else if(CDBELTHOLD && iCandlestickPattern(NULL,0,0) == 21) isBullish = true;
   else if(CDLBREAKAWAY && iCandlestickPattern(NULL,0,0) == 22) isBullish = true;
   else if(CDLKICKING && iCandlestickPattern(NULL,0,0) == 23) isBullish = true;
   else if(CDLKICKINGBYLENGTH && iCandlestickPattern(NULL,0,0) == 24) isBullish = true;
   else if(CDLSTICKSANDWICH && iCandlestickPattern(NULL,0,0) == 25) isBullish = true;
   // Add other patterns as needed

   return ;
}

//+------------------------------------------------------------------+
//| CDLHAMMER Pattern Detection Function                             |
//+------------------------------------------------------------------+
bool CDLHAMMER(int shift = 0)
{
   if(Bars < shift + 1)
      return false;
   
   double O = Open[shift];
   double C = Close[shift];
   double H = High[shift];
   double L = Low[shift];
   
   double bodySize = MathAbs(O - C);
   double totalRange = H - L;
   double lowerShadow = MathMin(O, C) - L;
   double upperShadow = H - MathMax(O, C);
   
   if(totalRange == 0)
      return false;
   
   return (bodySize / totalRange < 0.3 && lowerShadow >= 2 * bodySize && upperShadow <= bodySize * 0.5);
}

//+------------------------------------------------------------------+
//| CDLINVERTEDHAMMER Pattern Detection Function                     |
//+------------------------------------------------------------------+
bool CDLINVERTEDHAMMER(int shift = 0)
{
   if(Bars < shift + 1)
      return false;
   
   double O = Open[shift];
   double C = Close[shift];
   double H = High[shift];
   double L = Low[shift];
   
   double bodySize = MathAbs(O - C);
   double totalRange = H - L;
   double lowerShadow = MathMin(O, C) - L;
   double upperShadow = H - MathMax(O, C);
   
   if(totalRange == 0)
      return false;
   
   return (bodySize / totalRange < 0.3 && upperShadow >= 2 * bodySize && lowerShadow <= bodySize * 0.5);
}

//+------------------------------------------------------------------+
//| CDLMORNINGSTAR Pattern Detection Function                        |
//+------------------------------------------------------------------+
bool CDLMORNINGSTAR(int shift = 0)
{
   // We need at least 3 bars (current, -1, -2)
   if(Bars < shift + 3)
      return false;

   // Get bar data for the 3 candles
   // Current bar (shift + 0)
   double O0 = Open[shift];
   double C0 = Close[shift];
   double H0 = High[shift];
   double L0 = Low[shift];
   
   // Previous bar (shift + 1)
   double O1 = Open[shift + 1];
   double C1 = Close[shift + 1];
   double H1 = High[shift + 1];
   double L1 = Low[shift + 1];
   
   // Two bars ago (shift + 2)
   double O2 = Open[shift + 2];
   double C2 = Close[shift + 2];
   double H2 = High[shift + 2];
   double L2 = Low[shift + 2];

   // Morning Star pattern conditions
   bool condition1 = (O2 > C2);                                    // First candle is bearish
   bool condition2 = (5 * (O2 - C2) > 3 * (H2 - L2));             // First candle has a large bearish body
   bool condition3 = (C2 > O1);                                    // Second candle opens below first close
   bool condition4 = (2 * MathAbs(O1 - C1) < MathAbs(O2 - C2));   // Second candle has small body
   bool condition5 = (H1 - L1 > 3 * MathAbs(C1 - O1));            // Second candle has long shadows
   bool condition6 = (C0 > O0);                                    // Third candle is bullish
   bool condition7 = (O0 > O1);                                    // Third candle opens above second open
   bool condition8 = (O0 > C1);                                    // Third candle opens above second close

   // Return true if all conditions are met
   if(condition1 && condition2 && condition3 && condition4 && 
      condition5 && condition6 && condition7 && condition8)
      return true;

   return false;
}

//+------------------------------------------------------------------+
//| CDLMORNINGDOJISTAR Pattern Detection Function                    |
//+------------------------------------------------------------------+
/*
// simple Doji detection function:
bool isDoji(int index, const MqlRates &rates[])
{
   if(index >= ArraySize(rates))
      return false;

   double open  = rates[index].open;
   double close = rates[index].close;
   double high  = rates[index].high;
   double low   = rates[index].low;

   double body  = MathAbs(close - open);
   double range = high - low;

   // Define the ratio threshold for Doji
   double dojiRatio = 0.1; // 10% of total range

   if(body <= (range * dojiRatio))
      return true;

   return false;
}
*/
bool CDLMORNINGDOJISTAR(int shift = 0)
{
   if(Bars < shift + 1)
      return false;
   
   double O = Open[shift];
   double C = Close[shift];
   double H = High[shift];
   double L = Low[shift];
   
   double bodySize = MathAbs(O - C);
   double totalRange = H - L;
   
   if(totalRange == 0)
      return false;
   
   return (bodySize / totalRange < 0.1);
}

//+------------------------------------------------------------------+
//| CDLENGULFING Pattern Detection Function                          |
//+------------------------------------------------------------------+
bool CDLENGULFING(int shift = 0)
{
   // Make sure we have at least 2 bars from 'shift'
   if(Bars < shift + 2)
      return false;

   double prevOpen  = Open[shift + 1];
   double prevClose = Close[shift + 1];
   double currOpen  = Open[shift];
   double currClose = Close[shift];

   // Check if current candle bullish and fully engulfs previous body
   if(currClose > currOpen &&       // Current bullish
      prevClose < prevOpen &&       // Previous bearish
      currOpen < prevClose &&       // Current's open below previous close
      currClose > prevOpen)         // Current's close above previous open
   {
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| CDLPIERCING Pattern Detection Function                           |
//+------------------------------------------------------------------+
bool CDLPIERCING(int shift = 0)
{
   // Ensure we have the previous candle
   if(Bars < shift + 2)
      return false;

   // Candle 1 (previous)
   double prevOpen   = Open[shift + 1];
   double prevClose  = Close[shift + 1];
   double prevHigh   = High[shift + 1];
   double prevLow    = Low[shift + 1];

   // Candle 2 (current)
   double currOpen   = Open[shift];
   double currClose  = Close[shift];
   double currHigh   = High[shift];
   double currLow    = Low[shift];

   // Body calculations
   double prevBodyHi = MathMax(prevOpen, prevClose);
   double prevBodyLo = MathMin(prevOpen, prevClose);
   double prevBody   = prevBodyHi - prevBodyLo;
   double prevMid    = prevBodyLo + prevBody / 2.0;

   double currBodyHi = MathMax(currOpen, currClose);
   double currBodyLo = MathMin(currOpen, currClose);
   double currBody   = currBodyHi - currBodyLo;

   // Trend condition from Pine: previous was in downtrend
   // Simplified → previous candle bearish + long body
   bool prevBearish = (prevClose < prevOpen);
   bool prevLongBody = (prevBody > iMA(NULL, 0, 14, 0, MODE_EMA, PRICE_BODY, shift));

   // Current must be bullish
   bool currBullish = (currClose > currOpen);

   // Piercing key conditions:
   bool cond1 = prevBearish;          // previous bearish
   bool cond2 = currBullish;          // current bullish
   bool cond3 = currOpen <= prevLow;  // current opens below previous low (gap down)
   bool cond4 = currClose > prevMid;  // closes above previous midpoint
   bool cond5 = currClose < prevOpen; // closes below previous open (not fully engulfing)

   if(cond1 && cond2 && cond3 && cond4 && cond5)
      return true;

   return false;
}

//+------------------------------------------------------------------+
//| CDLHARAMI Pattern Detection Function                             |
//+------------------------------------------------------------------+
bool CDLHARAMI(int shift = 0)
{
   // We need at least 11 bars for the 10-period average
   if(Bars < shift + 11)
      return false;

   // Current bar (shift + 0)
   double O0 = Open[shift];
   double C0 = Close[shift];
   double H0 = High[shift];
   double L0 = Low[shift];
   
   // Previous bar (shift + 1)
   double O1 = Open[shift + 1];
   double C1 = Close[shift + 1];
   double H1 = High[shift + 1];
   double L1 = Low[shift + 1];

   // Calculate 10-period average of High and Low (shifted by 1)
   // AVGH10_1 = Average of High from bars [shift+2] to [shift+11]
   // AVGL10_1 = Average of Low from bars [shift+2] to [shift+11]
   double sumHigh = 0.0;
   double sumLow = 0.0;
   
   for(int i = shift + 2; i <= shift + 11; i++)
   {
      sumHigh += High[i];
      sumLow += Low[i];
   }
   
   double AVGH10_1 = sumHigh / 10.0;
   double AVGL10_1 = sumLow / 10.0;

   // Harami pattern conditions
   bool condition1 = (10 * (O1 - C1) >= 7 * (H1 - L1));              // Previous candle has large bearish body
   bool condition2 = (H1 - L1 >= AVGH10_1 - AVGL10_1);               // Previous candle range >= average range
   bool condition3 = (C0 > O0);                                       // Current candle is bullish
   bool condition4 = (O0 > C1);                                       // Current open above previous close
   bool condition5 = (O1 > C0);                                       // Previous open above current close
   bool condition6 = (6 * (O1 - C1) >= 10 * (C0 - O0));             // Current candle is smaller (fits inside previous)

   // Return true if all conditions are met
   if(condition1 && condition2 && condition3 && condition4 && 
      condition5 && condition6)
      return true;

   return false;
}

//+------------------------------------------------------------------+
//| CDLHARAMICROSS - Bullish Pattern Detection                         |
//+------------------------------------------------------------------+
bool CDLHaramicrossBullish(int i)
{
   // Ensure we have previous candle
   if (i+1 >= Bars)
      return false;

   // Previous candle OHLC
   double prevOpen   = Open[i+1];
   double prevClose  = Close[i+1];
   double prevHigh   = High[i+1];
   double prevLow    = Low[i+1];

   // Current candle OHLC
   double currOpen   = Open[i];
   double currClose  = Close[i];
   double currHigh   = High[i];
   double currLow    = Low[i];

   // Previous body
   double prevBodyHi = MathMax(prevOpen, prevClose);
   double prevBodyLo = MathMin(prevOpen, prevClose);
   double prevBody   = prevBodyHi - prevBodyLo;

   // Current body
   double currBodyHi = MathMax(currOpen, currClose);
   double currBodyLo = MathMin(currOpen, currClose);
   double currBody   = currBodyHi - currBodyLo;

   // Candle range
   double currRange  = currHigh - currLow;

   // Doji condition (similar to Pine: body <= 5% of range)
   bool isDoji = false;
   if(currRange > 0.0)
      isDoji = (currBody <= currRange * 0.05);

   // Trend filter simplified (downtrend last candle):
   bool prevDownTrend = (prevClose < prevOpen);

   // Previous candle should have long body (compared to EMA of body)
   double prevBodyAvg = iMA(NULL, 0, 14, 0, MODE_EMA, PRICE_CLOSE, i);  
   bool prevLongBody = (prevBody > prevBodyAvg);

   // Harami Cross Bullish conditions:
   bool cond_prev_bearish   = (prevClose < prevOpen);
   bool cond_prev_long      =  prevLongBody;
   bool cond_prev_downtrend =  prevDownTrend;

   bool cond_curr_doji      = isDoji;

   // Current candle fully inside previous body (Harami logic)
   bool cond_inside_body =
      (currHigh <= prevBodyHi) &&
      (currLow  >= prevBodyLo);

   if(cond_prev_bearish &&
      cond_prev_long &&
      cond_prev_downtrend &&
      cond_curr_doji &&
      cond_inside_body)
   {
      return true;
   }

   return false;
}

//+------------------------------------------------------------------+
//| CDLTAKURI Pattern Detection Function                             |
//| Takuri (Dragonfly Doji with very long lower shadow)              |
//| Converted from QuantConnect Takuri indicator                     |
//| Must have:                                                       |
//| - doji body (very small body)                                    |
//| - open and close at the high = no or very short upper shadow     |
//| - very long lower shadow                                         |
//| Returns true if pattern detected (always bullish signal)         |
//+------------------------------------------------------------------+
bool CDLTAKURI(int shift = 0)
{
   // Need enough bars for averaging
   if(Bars < shift + 11)
      return false;
   
   double O = Open[shift];
   double C = Close[shift];
   double H = High[shift];
   double L = Low[shift];
   
   double bodySize = MathAbs(O - C);
   double totalRange = H - L;
   double upperShadow = H - MathMax(O, C);
   double lowerShadow = MathMin(O, C) - L;
   
   // Avoid division by zero
   if(totalRange == 0)
      return false;
   
   // Calculate average body size over last 10 bars for doji comparison
   double avgBodySize = 0.0;
   double avgRange = 0.0;
   for(int i = shift + 1; i <= shift + 10; i++)
   {
      avgBodySize += MathAbs(Open[i] - Close[i]);
      avgRange += High[i] - Low[i];
   }
   avgBodySize /= 10.0;
   avgRange /= 10.0;
   
   // Doji body threshold (body <= 10% of average range or very small compared to avg body)
   double dojiThreshold = MathMax(avgRange * 0.1, avgBodySize * 0.1);
   bool isDojiBody = (bodySize <= dojiThreshold);
   
   // Very short upper shadow (upper shadow < 5% of total range or < 10% of avg range)
   double veryShortShadowThreshold = MathMax(totalRange * 0.05, avgRange * 0.1);
   bool hasVeryShortUpperShadow = (upperShadow < veryShortShadowThreshold);
   
   // Very long lower shadow (lower shadow > 60% of total range or > average range)
   double veryLongShadowThreshold = MathMin(totalRange * 0.6, avgRange);
   bool hasVeryLongLowerShadow = (lowerShadow > veryLongShadowThreshold);
   
   // Pattern is valid when all conditions are met
   if(isDojiBody && hasVeryShortUpperShadow && hasVeryLongLowerShadow)
      return true;
   
   return false;
}

//+------------------------------------------------------------------+
//| CDL3WHITESOLDIERS Pattern Detection Function                     |
//+------------------------------------------------------------------+
bool CDL3WHITESOLDIERS(int shift = 0)
{
   // We need shift, shift+1, shift+2
   if(Bars < shift + 3)
      return false;

   // Candle 0 (current)
   double o0 = Open[shift];
   double c0 = Close[shift];
   double h0 = High[shift];
   double l0 = Low[shift];

   // Candle 1
   double o1 = Open[shift + 1];
   double c1 = Close[shift + 1];
   double h1 = High[shift + 1];
   double l1 = Low[shift + 1];

   // Candle 2
   double o2 = Open[shift + 2];
   double c2 = Close[shift + 2];
   double h2 = High[shift + 2];
   double l2 = Low[shift + 2];

   // Body sizes
   double body0 = MathAbs(c0 - o0);
   double body1 = MathAbs(c1 - o1);
   double body2 = MathAbs(c2 - o2);

   // Body average (EMA of 14 periods, PineScript equivalent)
   double bodyAvg = iMA(NULL, 0, 14, 0, MODE_EMA, PRICE_CLOSE, shift);

   bool long0 = body0 > bodyAvg;
   bool long1 = body1 > bodyAvg;
   bool long2 = body2 > bodyAvg;

   // White bodies (bullish candles)
   bool white0 = (c0 > o0);
   bool white1 = (c1 > o1);
   bool white2 = (c2 > o2);

   // Up shadows
   double upShadow0 = h0 - MathMax(o0, c0);
   double upShadow1 = h1 - MathMax(o1, c1);
   double upShadow2 = h2 - MathMax(o2, c2);

   // Candle ranges
   double range0 = h0 - l0;
   double range1 = h1 - l1;
   double range2 = h2 - l2;

   // Shadow condition: small upper shadow
   double shadowLimit0 = range0 * 0.05;
   double shadowLimit1 = range1 * 0.05;
   double shadowLimit2 = range2 * 0.05;

   bool smallUpShadow0 = (upShadow0 < shadowLimit0);
   bool smallUpShadow1 = (upShadow1 < shadowLimit1);
   bool smallUpShadow2 = (upShadow2 < shadowLimit2);

   // Three White Soldiers logic
   bool cond_long_bodies =
         long0 && long1 && long2;

   bool cond_white_bodies =
         white0 && white1 && white2;

   bool cond_close_increasing =
         (c0 > c1) && (c1 > c2);

   // Opens inside previous body
   bool cond_open_positions =
         (o0 < c1 && o0 > o1) &&
         (o1 < c2 && o1 > o2);

   // Small upper shadows
   bool cond_small_up_shadows =
         smallUpShadow0 && smallUpShadow1 && smallUpShadow2;

   // Final pattern decision
   if(cond_long_bodies &&
      cond_white_bodies &&
      cond_close_increasing &&
      cond_open_positions &&
      cond_small_up_shadows)
   {
      return true;
   }

   return false;
}

//+------------------------------------------------------------------+
//| CDLRISEFALL3METHODS Pattern Detection Function                   |
//+------------------------------------------------------------------+
bool CDLRISEFALL3METHODS(int shift = 0)
{
   // We need candles shift..shift+4
   if(Bars < shift + 5)
      return false;

   // Extract OHLC
   double o0 = Open[shift];     double c0 = Close[shift];     double h0 = High[shift];     double l0 = Low[shift];
   double o1 = Open[shift+1];   double c1 = Close[shift+1];   double h1 = High[shift+1];   double l1 = Low[shift+1];
   double o2 = Open[shift+2];   double c2 = Close[shift+2];   double h2 = High[shift+2];   double l2 = Low[shift+2];
   double o3 = Open[shift+3];   double c3 = Close[shift+3];   double h3 = High[shift+3];   double l3 = Low[shift+3];
   double o4 = Open[shift+4];   double c4 = Close[shift+4];   double h4 = High[shift+4];   double l4 = Low[shift+4];

   // Body sizes
   double body0 = MathAbs(c0 - o0);
   double body1 = MathAbs(c1 - o1);
   double body2 = MathAbs(c2 - o2);
   double body3 = MathAbs(c3 - o3);
   double body4 = MathAbs(c4 - o4);

   // Body average via EMA 14 (TA equivalent)
   double bodyAvg = iMA(NULL,0,14,0,MODE_EMA,PRICE_CLOSE,shift);

   bool long0 = body0 > bodyAvg;
   bool long4 = body4 > bodyAvg;

   bool small1 = body1 < bodyAvg;
   bool small2 = body2 < bodyAvg;
   bool small3 = body3 < bodyAvg;

   // Candle colors
   bool white0 = (c0 > o0);
   bool white4 = (c4 > o4);

   bool black1 = (c1 < o1);
   bool black2 = (c2 < o2);
   bool black3 = (c3 < o3);

   // Trend check equivalent to C_UpTrend[4]
   bool upTrend4 = (c4 > iMA(NULL,0,50,0,MODE_SMA,PRICE_CLOSE,shift+4));

   // Middle three candles inside candle 4 range
   bool inside1 = (o1 < h4 && c1 > l4);
   bool inside2 = (o2 < h4 && c2 > l4);
   bool inside3 = (o3 < h4 && c3 > l4);

   // Final bullish candle closes above candle 4 close
   bool strongBullishFinish = (white0 && long0 && c0 > c4);

   // Pattern logic
   if( upTrend4 &&
       long4 && white4 &&
       small3 && black3 && inside3 &&
       small2 && black2 && inside2 &&
       small1 && black1 && inside1 &&
       strongBullishFinish )
   {
      return true;
   }

   return false;
}

//+------------------------------------------------------------------+
//| CDLMATHOLD Pattern Detection Function                            |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| CDLSEPARATINGLINES Pattern Detection Function                    |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| CDLTASUKIGAP Pattern Detection Function                          |
//+------------------------------------------------------------------+
bool CDLTASUKIGAP(int i)
{  
   // Need candles i, i+1, i+2
   if(i+2 >= Bars)
      return false;

   // Extract OHLC
   double o0 = Open[i];     double c0 = Close[i];     double h0 = High[i];     double l0 = Low[i];
   double o1 = Open[i+1];   double c1 = Close[i+1];   double h1 = High[i+1];   double l1 = Low[i+1];
   double o2 = Open[i+2];   double c2 = Close[i+2];   double h2 = High[i+2];   double l2 = Low[i+2];

   // Bodies
   double body0 = MathAbs(c0 - o0);
   double body1 = MathAbs(c1 - o1);
   double body2 = MathAbs(c2 - o2);

   // Body average (EMA 14)
   double bodyAvg = iMA(NULL,0,14,0,MODE_EMA,PRICE_CLOSE,i);

   bool long2  = body2 > bodyAvg;
   bool small1 = body1 < bodyAvg;

   // Candle colors
   bool white2 = (c2 > o2);
   bool white1 = (c1 > o1);
   bool black0 = (c0 < o0);

   // Trend check (equivalent to C_UpTrend in PineScript)
   bool upTrend = (c2 > iMA(NULL,0,50,0,MODE_SMA,PRICE_CLOSE,i+2));

   // Gap between candle 2 and candle 1:
   // C_BodyLo[1] > C_BodyHi[2]
   double bodyHi2 = MathMax(c2,o2);
   double bodyLo2 = MathMin(c2,o2);

   double bodyHi1 = MathMax(c1,o1);
   double bodyLo1 = MathMin(c1,o1);

   double bodyHi0 = MathMax(c0,o0);
   double bodyLo0 = MathMin(c0,o0);

   bool gapUp = (bodyLo1 > bodyHi2);   // proper upside gap

   // Candle 0 closes inside the gap but does NOT close it fully
   bool closesInsideGap =
      (bodyLo0 >= bodyHi2) &&   // stays above candle 2 high
      (bodyLo0 <= bodyLo1);     // but within candle 1 low

   // Final combined logic from PineScript
   if( long2 &&
       small1 &&
       upTrend &&
       white2 &&
       gapUp &&
       white1 &&
       black0 &&
       closesInsideGap )
   {
      return true;
   }

   return false;
}

//+------------------------------------------------------------------+
//| CDLABANDONEDBABY Pattern Detection Function                      |
//+------------------------------------------------------------------+
bool CDLABANDONEDBABY(int i)
{
   // Need candles i, i+1, i+2
   if(i+2 >= Bars)
      return false;

   // OHLC extraction
   double o0 = Open[i];     double c0 = Close[i];     double h0 = High[i];     double l0 = Low[i];
   double o1 = Open[i+1];   double c1 = Close[i+1];   double h1 = High[i+1];   double l1 = Low[i+1];
   double o2 = Open[i+2];   double c2 = Close[i+2];   double h2 = High[i+2];   double l2 = Low[i+2];

   // Body sizes
   double body0 = MathAbs(c0 - o0);
   double body1 = MathAbs(c1 - o1);
   double body2 = MathAbs(c2 - o2);

   // Body average (EMA 14)
   double bodyAvg = iMA(NULL,0,14,0,MODE_EMA,PRICE_CLOSE,i);

   bool long2  = body2 > bodyAvg;    // Candle 2 long
   bool doji1  = ( (h1 - l1) > 0 && body1 <= (h1 - l1) * 0.05 ); // Doji = 5% body threshold

   // Candle colors
   bool white0 = (c0 > o0);
   bool black2 = (c2 < o2);

   // Check Again
   // Trend rule: Downtrend using SMA50 (same as PineScript)
   double sma50_2 = iMA(NULL,0,50,0,MODE_SMA,PRICE_CLOSE,i+2);
   bool downtrend = (c2 < sma50_2);

   // Body High/Low for correct engulf/gap checking
   double bodyHi2 = MathMax(c2,o2);
   double bodyLo2 = MathMin(c2,o2);

   double bodyHi1 = MathMax(c1,o1);
   double bodyLo1 = MathMin(c1,o1);

   double bodyHi0 = MathMax(c0,o0);
   double bodyLo0 = MathMin(c0,o0);

   // Condition from PineScript:
   // low[2] > high[1]   => gap between candle 2 and doji
   bool gapDownDoji = (l2 > h1);

   // high[1] < low      => gap up between doji and candle 0
   bool gapUpReversal = (h1 < l0);

   // FINAL PATTERN LOGIC
   if( downtrend && 
       black2 && long2 &&
       doji1 &&
       gapDownDoji &&
       white0 &&
       gapUpReversal )
   {
      return true;
   }

   return false;
}

//+------------------------------------------------------------------+
//| CDLLADDERBOTTOM Pattern Detection Function                       |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| CDLMATCHINGLOW Pattern Detection Function                        |
//+------------------------------------------------------------------+
bool CDLMATCHINGLOW(int i, double tolerancePoints = 0.0)
{
   // Need at least two candles: i and i+1
   if(i+1 >= Bars) return false;

   double o0 = Open[i];
   double c0 = Close[i];
   double o1 = Open[i+1];
   double c1 = Close[i+1];

   // 1. Both candles must be bearish
   bool black0 = (c0 < o0);
   bool black1 = (c1 < o1);

   if(!black0 || !black1)
      return false;

   // 2. Matching closes (TA-Lib allows small tolerance)
   double diff = MathAbs(c0 - c1);

   if(tolerancePoints <= 0)
      tolerancePoints = Point;  // default 1 pip or 1 tick

   if(diff > tolerancePoints)
      return false;

   // 3. Downtrend filter (SMA50)
   double sma50 = iMA(NULL, 0, 50, 0, MODE_SMA, PRICE_CLOSE, i+1);
   if(Close[i+1] > sma50)
      return false;

   return true;
}

//+------------------------------------------------------------------+
//| CDLUNIQUE3RIVER Pattern Detection Function                       |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| CDL3INSIDE Pattern Detection Function (Bullish & Bearish)        |
//| Converted from TradingFinder - Three Inside Bar Pattern          |
//+------------------------------------------------------------------+
bool CDL3INSIDE(int i)
{
   // Must have candles i, i+1, i+2
   if(i+2 >= Bars) return false;

   //----------------------------------------------------------------
   // Candle features
   //----------------------------------------------------------------
   double high0 = High[i];
   double low0  = Low[i];
   double open0 = Open[i];
   double close0= Close[i];

   double high1 = High[i+1];
   double low1  = Low[i+1];
   double open1 = Open[i+1];
   double close1= Close[i+1];

   double high2 = High[i+2];
   double low2  = Low[i+2];
   double open2 = Open[i+2];
   double close2= Close[i+2];

   double range0 = high0 - low0;
   double body0  = close0 - open0;

   bool posCandle0 = (body0 > 0);   // bullish
   bool negCandle0 = (body0 < 0);   // bearish

   double range2 = high2 - low2;
   double body2  = close2 - open2;

   bool posCandle2 = (body2 > 0);
   bool negCandle2 = (body2 < 0);

   // Body size proportion (in Pine they used abs(body/range))
   double fullBody = 0;
   if(range0 > 0)
      fullBody = MathAbs(body0 / range0);

   //----------------------------------------------------------------
   // Conditions replicated from PineScript logic
   //----------------------------------------------------------------

   // === Three Inside Up – Weak ===
   bool inside_bull_W =
      negCandle2 &&
      posCandle0 &&
      fullBody >= 0.6 &&
      fullBody <= 0.8 &&
      close0 > high1 &&
      close0 > (low2 + high2) / 2.0 &&
      high1 < high2 &&
      low2 > low1;

   // === Three Inside Up – Strong ===
   bool inside_bull_S =
      negCandle2 &&
      posCandle0 &&
      fullBody > 0.8 &&
      close0 > high1 &&
      close0 > (low2 + high2) / 2.0 &&
      high1 < high2 &&
      low2 > low1;

   // === Three Inside Down – Weak ===
   bool inside_bear_W =
      negCandle0 &&
      posCandle2 &&
      fullBody >= 0.6 &&
      fullBody <= 0.8 &&
      close0 < low1 &&
      close0 < (low2 + high2) / 2.0 &&
      high1 > high2 &&
      low2 < low1;

   // === Three Inside Down – Strong ===
   bool inside_bear_S =
      negCandle0 &&
      posCandle2 &&
      fullBody > 0.8 &&
      close0 < low1 &&
      close0 < (low2 + high2) / 2.0 &&
      high1 > high2 &&
      low2 < low1;

   //----------------------------------------------------------------
   // Final condition (return TRUE if any of the patterns is triggered)
   //----------------------------------------------------------------
   if(inside_bull_W || inside_bull_S || inside_bear_W || inside_bear_S)
      return true;

   return false;
}

//+------------------------------------------------------------------+
//| CDL3OUTSIDEUP Pattern Detection (Bullish Reversal)               |
//| Conversion from TradingView code1                                |
//+------------------------------------------------------------------+
bool CDL3OUTSIDEUP(int i)
{
   // Ensure enough candles
   if(i+2 >= Bars) return false;

   //----------------------------------------------------------------
   // Extract candle data
   //----------------------------------------------------------------
   double o0 = Open[i];
   double c0 = Close[i];
   double h0 = High[i];

   double o1 = Open[i+1];
   double c1 = Close[i+1];
   double h1 = High[i+1];

   double o2 = Open[i+2];
   double c2 = Close[i+2];

   //----------------------------------------------------------------
   // Pattern logic (Three Outside Up)
   //----------------------------------------------------------------
   bool candle2_bearish = (c2 < o2);
   bool candle1_bullish = (c1 > o1);

   // Engulfing body condition
   bool engulfing =
      (c1 >= o2) &&     // close1 >= open2
      (c2 >= o1) &&     // close2 >= open1
      ((c1 - o1) > (o2 - c2)); // body1 > body2

   // Third candle must be bullish and confirm breakout above high[1]
   bool bullish_confirmation =
      (c0 > o0) &&
      (c0 > h1);

   if(candle2_bearish && candle1_bullish && engulfing && bullish_confirmation)
      return true;

   return false;
}

//+------------------------------------------------------------------+
//| CDBELTHOLD Pattern Detection Function                            |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Belt-Hold Candlestick Pattern (Bullish = +1, Bearish = -1)       |
//| MQL4 adaptation from QuantConnect BeltHold indicator             |
//+------------------------------------------------------------------+
int CDBELTHOLD(int shift = 0)
{
   // Safety check: need at least one candle
   if (shift + 1 >= Bars) return 0;

   // Parameters (can be externalized)
   int BodyLongPeriod      = 10;   // average period for long real body
   int ShadowVeryShortPeriod = 10; // average period for very short shadow

   //--------------------------------------------------------------
   // Compute averages for: real body, upper shadow, lower shadow
   //--------------------------------------------------------------
   double bodySum = 0;
   double shadowShortSum = 0;

   for(int i = shift + 1; i <= shift + BodyLongPeriod; i++)
   {
      if(i >= Bars - 1) break;
      double body = MathAbs(Close[i] - Open[i]);
      bodySum += body;
   }
   double avgLongBody = bodySum / BodyLongPeriod;

   for(int i = shift + 1; i <= shift + ShadowVeryShortPeriod; i++)
   {
      if(i >= Bars - 1) break;
      double upShadow   = High[i] - MathMax(Open[i], Close[i]);
      double dnShadow   = MathMin(Open[i], Close[i]) - Low[i];
      double shadowRange = (upShadow + dnShadow) / 2.0;
      shadowShortSum += shadowRange;
   }
   double avgVeryShortShadow = shadowShortSum / ShadowVeryShortPeriod;

   //--------------------------------------------------------------
   // Current candle data
   //--------------------------------------------------------------
   double o = Open[shift];
   double c = Close[shift];
   double h = High[shift];
   double l = Low[shift];

   double realBody = MathAbs(c - o);

   double upperShadow = h - MathMax(o, c);
   double lowerShadow = MathMin(o, c) - l;

   bool white = (c > o);
   bool black = (o > c);

   //--------------------------------------------------------------
   // Pattern conditions
   //--------------------------------------------------------------

   // Body must be long
   bool condLongBody = (realBody > avgLongBody);

   // For bullish Belt-Hold:
   // Long white body and lower shadow almost absent
   bool bullish =
      white &&
      condLongBody &&
      (lowerShadow < avgVeryShortShadow);

   // For bearish Belt-Hold:
   // Long black body and upper shadow almost absent
   bool bearish =
      black &&
      condLongBody &&
      (upperShadow < avgVeryShortShadow);

   if(bullish) return +1;
   if(bearish) return -1;

   return 0;
}

//+------------------------------------------------------------------+
//| CDLBREAKAWAY Pattern Detection Function                          |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Breakaway Candlestick Pattern Detection                         |
//| Returns: +1 = Bullish Breakaway, -1 = Bearish Breakaway, 0 = no |
//+------------------------------------------------------------------+
int CDLBREAKAWAY(int shift = 0)
{
   // Need at least 5 candles
   if (shift + 4 >= Bars) return 0;

   // Adjustable parameter
   int BodyLongPeriod = 10;

   // Compute average long body based on candle #4 back
   double bodySum = 0.0;
   for (int i = shift + 4; i < shift + 4 + BodyLongPeriod; i++)
   {
      if (i >= Bars) break;
      bodySum += MathAbs(Close[i] - Open[i]);
   }
   double avgLongBody = bodySum / BodyLongPeriod;

   // Candles:
   // c4 = 1st candle back
   // c3 = 2nd
   // c2 = 3rd
   // c1 = 4th
   // c0 = current (5th candle)
   int c4 = shift + 4;
   int c3 = shift + 3;
   int c2 = shift + 2;
   int c1 = shift + 1;
   int c0 = shift;

   // Candle color check
   bool white(int i) { return Close[i] > Open[i]; }
   bool black(int i) { return Open[i] > Close[i]; }

   // Gaps
   bool gapDown = (Open[c3] < Close[c4] && Close[c3] < Open[c4]);
   bool gapUp   = (Open[c3] > Close[c4] && Close[c3] > Open[c4]);

   // Long body condition (1st candle)
   bool isLong = MathAbs(Close[c4] - Open[c4]) > avgLongBody;

   // Colors: 1st, 2nd, 4th same; 5th opposite to 4th
   bool sameColor_1_2_4 =
      ((white(c4) && white(c3) && white(c1)) ||
       (black(c4) && black(c3) && black(c1)));

   bool fifthOpposite =
      (white(c1) && black(c0)) ||
      (black(c1) && white(c0));

   // ---------------------------------------------------------
   // CONDITIONS FOR BEARISH BREAKAWAY
   // 1st = long black
   // 2nd = gaps down
   // 3rd lower highs/lows
   // 4th lower highs/lows
   // 5th closes inside gap
   // ---------------------------------------------------------
   bool bearishPattern =
      black(c4) && isLong &&
      sameColor_1_2_4 &&
      fifthOpposite &&
      gapDown &&
      High[c2] < High[c3] && Low[c2] < Low[c3] &&
      High[c1] < High[c2] && Low[c1] < Low[c2] &&
      Close[c0] > Open[c3] && Close[c0] < Close[c4];

   // ---------------------------------------------------------
   // CONDITIONS FOR BULLISH BREAKAWAY
   // Exact mirror of bearish case
   // ---------------------------------------------------------
   bool bullishPattern =
      white(c4) && isLong &&
      sameColor_1_2_4 &&
      fifthOpposite &&
      gapUp &&
      High[c2] > High[c3] && Low[c2] > Low[c3] &&
      High[c1] > High[c2] && Low[c1] > Low[c2] &&
      Close[c0] < Open[c3] && Close[c0] > Close[c4];

   if (bullishPattern) return +1;
   if (bearishPattern) return -1;

   return 0;
}

//+------------------------------------------------------------------+
//| CDLKICKING Pattern Detection Function                            |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| CDL Kicking Pattern Detection                                    |
//| Returns: +1 bullish, -1 bearish, 0 no pattern                    |
//+------------------------------------------------------------------+
int CDLKICKING(int shift = 0)
{
   // Need at least 2 candles
   if (shift + 1 >= Bars) return 0;

   // Adjustable "settings" similar to QC
   int BodyLongPeriod = 10;
   int ShadowVeryShortPeriod = 10;

   //---------------------------------------------------------
   // Compute averages for the last 10 candles
   //---------------------------------------------------------
   double bodyLongAvg[2] = {0.0, 0.0};       // 0 = current, 1 = previous
   double shadowShortAvg[2] = {0.0, 0.0};

   for (int i = 0; i < BodyLongPeriod; i++)
   {
      if (shift + i >= Bars) break;
      bodyLongAvg[1] += MathAbs(Close[shift + 1 + i] - Open[shift + 1 + i]);
      bodyLongAvg[0] += MathAbs(Close[shift + i] - Open[shift + i]);
   }

   bodyLongAvg[1] /= BodyLongPeriod;
   bodyLongAvg[0] /= BodyLongPeriod;

   for (int i = 0; i < ShadowVeryShortPeriod; i++)
   {
      if (shift + i >= Bars) break;

      shadowShortAvg[1] += (High[shift + 1 + i] - MathMax(Open[shift + 1 + i], Close[shift + 1 + i])); // upper shadow prev
      shadowShortAvg[1] += (MathMin(Open[shift + 1 + i], Close[shift + 1 + i]) - Low[shift + 1 + i]);  // lower shadow prev

      shadowShortAvg[0] += (High[shift + i] - MathMax(Open[shift + i], Close[shift + i])); // upper shadow current
      shadowShortAvg[0] += (MathMin(Open[shift + i], Close[shift + i]) - Low[shift + i]);  // lower shadow current
   }

   shadowShortAvg[1] /= (2 * ShadowVeryShortPeriod);
   shadowShortAvg[0] /= (2 * ShadowVeryShortPeriod);

   //---------------------------------------------------------
   // Candle identifiers
   //---------------------------------------------------------
   int c1 = shift + 1;   // first candle (older)
   int c0 = shift;       // second candle (current)

   //---------------------------------------------------------
   // Helper definitions
   //---------------------------------------------------------
   bool white(int i) { return Close[i] > Open[i]; }
   bool black(int i) { return Open[i] > Close[i]; }

   double body(int i)  { return MathAbs(Close[i] - Open[i]); }
   double upper(int i) { return High[i] - MathMax(Open[i], Close[i]); }
   double lower(int i) { return MathMin(Open[i], Close[i]) - Low[i]; }

   //---------------------------------------------------------
   // Conditions
   //---------------------------------------------------------

   // Opposite colors
   bool oppositeColor = 
         (white(c1) && black(c0)) ||
         (black(c1) && white(c0));

   // Marubozu = long body + very small shadows
   bool marubozu1 =
      body(c1) > bodyLongAvg[1] &&
      upper(c1) < shadowShortAvg[1] &&
      lower(c1) < shadowShortAvg[1];

   bool marubozu0 =
      body(c0) > bodyLongAvg[0] &&
      upper(c0) < shadowShortAvg[0] &&
      lower(c0) < shadowShortAvg[0];

   // Gaps
   bool gapUp = (Open[c0] > High[c1] && Close[c0] > High[c1]);
   bool gapDown = (Open[c0] < Low[c1] && Close[c0] < Low[c1]);

   //---------------------------------------------------------
   // Final Kicking pattern logic
   //---------------------------------------------------------
   bool bullish =
      oppositeColor &&
      marubozu1 &&
      marubozu0 &&
      black(c1) && white(c0) &&
      gapUp;

   bool bearish =
      oppositeColor &&
      marubozu1 &&
      marubozu0 &&
      white(c1) && black(c0) &&
      gapDown;

   if (bullish) return +1;
   if (bearish) return -1;

   return 0;
}

//+------------------------------------------------------------------+
//| CDLKICKINGBYLENGTH Pattern Detection Function                    |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| CDL Kicking By Length Pattern Detection                          |
//| Returns: +1 bullish, -1 bearish, 0 no pattern                    |
//+------------------------------------------------------------------+
int CDLKICKINGBYLENGTH(int shift = 0)
{
   // Occorrono almeno 2 candele
   if (shift + 1 >= Bars) return 0;

   //---------------------------------------------------------
   // Parametri equivalenti ai CandleSettings QC
   //---------------------------------------------------------
   int BodyLongPeriod        = 10;
   int ShadowVeryShortPeriod = 10;

   double bodyLongAvg[2] = {0.0, 0.0};     // 0 = current, 1 = previous
   double shadowShortAvg[2] = {0.0, 0.0};

   //---------------------------------------------------------
   // Calcolo delle medie
   //---------------------------------------------------------
   for (int i = 0; i < BodyLongPeriod; i++)
   {
      if (shift + i >= Bars) break;

      bodyLongAvg[1] += MathAbs(Close[shift + 1 + i] - Open[shift + 1 + i]);
      bodyLongAvg[0] += MathAbs(Close[shift + i]     - Open[shift + i]);
   }
   bodyLongAvg[1] /= BodyLongPeriod;
   bodyLongAvg[0] /= BodyLongPeriod;

   for (int i = 0; i < ShadowVeryShortPeriod; i++)
   {
      if (shift + i >= Bars) break;

      // prev candle shadows
      shadowShortAvg[1] += (High[shift + 1 + i] - MathMax(Open[shift + 1 + i], Close[shift + 1 + i])); 
      shadowShortAvg[1] += (MathMin(Open[shift + 1 + i], Close[shift + 1 + i]) - Low[shift + 1 + i]);

      // curr candle shadows
      shadowShortAvg[0] += (High[shift + i] - MathMax(Open[shift + i], Close[shift + i]));
      shadowShortAvg[0] += (MathMin(Open[shift + i], Close[shift + i]) - Low[shift + i]);
   }
   shadowShortAvg[1] /= (2.0 * ShadowVeryShortPeriod);
   shadowShortAvg[0] /= (2.0 * ShadowVeryShortPeriod);

   //---------------------------------------------------------
   // Candle indexes
   //---------------------------------------------------------
   int c1 = shift + 1;   // first (previous)
   int c0 = shift;       // second (current)

   //---------------------------------------------------------
   // Helper definitions
   //---------------------------------------------------------
   bool white(int i) { return Close[i] > Open[i]; }
   bool black(int i) { return Open[i] > Close[i]; }

   double body(int i)  { return MathAbs(Close[i] - Open[i]); }
   double upper(int i) { return High[i] - MathMax(Open[i], Close[i]); }
   double lower(int i) { return MathMin(Open[i], Close[i]) - Low[i]; }

   //---------------------------------------------------------
   // Opposite colors
   //---------------------------------------------------------
   bool opposite =
         (white(c1) && black(c0)) ||
         (black(c1) && white(c0));

   //---------------------------------------------------------
   // Marubozu: long body + very short shadows
   //---------------------------------------------------------
   bool marubozu1 =
         body(c1) > bodyLongAvg[1] &&
         upper(c1) < shadowShortAvg[1] &&
         lower(c1) < shadowShortAvg[1];

   bool marubozu0 =
         body(c0) > bodyLongAvg[0] &&
         upper(c0) < shadowShortAvg[0] &&
         lower(c0) < shadowShortAvg[0];

   //---------------------------------------------------------
   // GAP rules
   //---------------------------------------------------------
   bool gapUp   = (Open[c0] > High[c1] && Close[c0] > High[c1]);
   bool gapDown = (Open[c0] < Low[c1]  && Close[c0] < Low[c1]);

   //---------------------------------------------------------
   // Pattern check
   //---------------------------------------------------------
   bool validPattern =
      opposite &&
      marubozu1 &&
      marubozu0 &&
      (
        (black(c1) && white(c0) && gapUp) ||
        (white(c1) && black(c0) && gapDown)
      );

   if (!validPattern) return 0;

   //---------------------------------------------------------
   // KickingByLength: il colore è determinato dal marubozu più lungo
   //---------------------------------------------------------
   double body1 = body(c1);
   double body0 = body(c0);

   // pattern bullish se la candela con corpo più lungo è bianca
   if (body0 > body1)
      return white(c0) ? +1 : -1;
   else
      return white(c1) ? +1 : -1;
}

//+------------------------------------------------------------------+
//| CDLSTICKSANDWICH Pattern Detection Function                      |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Stick Sandwich Pattern Detection                                 |
//| Return: +1 = bullish, 0 = none                                   |
//+------------------------------------------------------------------+
int CDLSTICKSANDWICH(int shift = 0)
{
   // Pattern composto da 3 candele:
   // window[2] = shift+2  (prima)
   // window[1] = shift+1  (seconda)
   // input    = shift    (terza)
   if (shift + 2 >= Bars) return 0;

   //-------------------------------------------------------------
   // Parametri equivalenti a CandleSettings(Equal) di QC
   //-------------------------------------------------------------
   int EqualPeriod = 10;

   double equalTotal = 0.0;

   // Calcolo della media dei range "equal"
   for (int i = 0; i < EqualPeriod; i++)
   {
      int idx = shift + 2 + i;
      if (idx >= Bars) break;
      equalTotal += MathAbs(Close[idx] - Open[idx]);
   }
   double equalAvg = equalTotal / EqualPeriod;

   //-------------------------------------------------------------
   // Indici più leggibili
   //-------------------------------------------------------------
   int c2 = shift + 2;   // First candle
   int c1 = shift + 1;   // Second candle
   int c0 = shift;       // Third candle (current)

   //-------------------------------------------------------------
   // Helper functions
   //-------------------------------------------------------------
   bool white(int i) { return Close[i] > Open[i]; }
   bool black(int i) { return Open[i] > Close[i]; }

   //-------------------------------------------------------------
   // Condizioni del pattern Stick Sandwich
   //-------------------------------------------------------------
   bool firstBlack  = black(c2);
   bool secondWhite = white(c1);
   bool thirdBlack  = black(c0);

   bool secondLowAboveFirstClose = Low[c1] > Close[c2];

   bool closesEqual =
         (Close[c0] <= Close[c2] + equalAvg) &&
         (Close[c0] >= Close[c2] - equalAvg);

   //-------------------------------------------------------------
   // Condizione finale
   //-------------------------------------------------------------
   if (firstBlack && secondWhite && thirdBlack &&
       secondLowAboveFirstClose && closesEqual)
   {
      return 1;  // Always bullish
   }

   return 0;
}


//+------------------------------------------------------------------+
//| VWAP Calculation function                                        |
//+------------------------------------------------------------------+
double CalculateVWAP(int period)
{
   double cumulativeTPV = 0.0; // Cumulative Typical Price * Volume
   double cumulativeVolume = 0.0; // Cumulative Volume

   for(int i = 0; i < period; i++)
   {
      double typicalPrice = (High[i] + Low[i] + Close[i]) / 3.0;
      double volume = Volume[i];

      cumulativeTPV += typicalPrice * volume;
      cumulativeVolume += volume;
   }

   if(cumulativeVolume == 0)
      return 0.0;

   return cumulativeTPV / cumulativeVolume;
}


//+------------------------------------------------------------------+
//| OnTick()                                                         |
//+------------------------------------------------------------------+
void OnTick()
{
   // === Trade only on new candle ===
   // Check if really required
   static datetime lastCandle = 0;
   if(Time[0] == lastCandle) return;
   lastCandle = Time[0];

    // === VWAP Calculation ===
    double vwap = CalculateVWAP(VWAP_Period); 

    // === Entry Condition: Ysterday's Close higher than VWAP and CDL Pattern is Bullish ===
    double yesterdayClose = iClose(NULL, 0, 1);
    if(yesterdayClose > vwap)
    {
      // === Check for Bullish Candle Pattern ===
      bool isBullish = false;
      GetActiveCandlePattern(isBullish);


    // === Calculate ATR, SL, TP and Lot Size ===
    double atr = iATR(NULL, 0, ATR_Period, 0);
    double sl = Bid - ATR_Mult_SL * atr;
    double tp = Bid + ATR_Mult_TP * atr;
    double lot = CalculateLotSize(sl);



         RefreshRates();
         int ticket = OrderSend(Symbol(), OP_BUY, lot, Ask, Slippage, sl, tp,
                                "Gap Up Buy", MagicNumber, 0, clrGreen);

         if(ticket > 0)
            Print("✓ Trade opened. Gap=", DoubleToString(gapPct*100,2),
                  "% ATR=", DoubleToString(atr,5),
                  " SL=", DoubleToString(sl,5),
                  " TP=", DoubleToString(tp,5),
                  " Lot=", DoubleToString(lot,2));
         else
            Print("✗ Failed to open trade. Error=", GetLastError());
      }
   }
}