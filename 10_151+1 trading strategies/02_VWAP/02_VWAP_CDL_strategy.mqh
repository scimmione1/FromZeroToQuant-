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
bool CDLHAMMER(MqlRates &rates[])
  {
   if(ArraySize(rates) < 1)
      return false;
   double bodySize = MathAbs(rates[0].open - rates[0].close);
   double totalRange = rates[0].high - rates[0].low;
   double lowerShadow = MathMin(rates[0].open, rates[0].close) - rates[0].low;
   double upperShadow = rates[0].high - MathMax(rates[0].open, rates[0].close);
   if(totalRange == 0)
      return false;
   return (bodySize / totalRange < 0.3 && lowerShadow >= 2 * bodySize && upperShadow <= bodySize * 0.5);
  }

//+------------------------------------------------------------------+
//| CDLINVERTEDHAMMER Pattern Detection Function                     |
//+------------------------------------------------------------------+
bool CDLINVERTEDHAMMER(MqlRates &rates[])
  {
   if(ArraySize(rates) < 1)
      return false;
   double bodySize = MathAbs(rates[0].open - rates[0].close);
   double totalRange = rates[0].high - rates[0].low;
   double lowerShadow = MathMin(rates[0].open, rates[0].close) - rates[0].low;
   double upperShadow = rates[0].high - MathMax(rates[0].open, rates[0].close);
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
bool CDLMORNINGDOJISTAR(MqlRates &rates[])
  {
   if(ArraySize(rates) < 1)
      return false;
   double bodySize = MathAbs(rates[0].open - rates[0].close);
   double totalRange = rates[0].high - rates[0].low;
   if(totalRange == 0)
      return false;
   return (bodySize / totalRange < 0.1);
  }


//+------------------------------------------------------------------+
//| CDLENGULFING Pattern Detection Function                          |
//+------------------------------------------------------------------+
bool CDLENGULFING(int index, const MqlRates &rates[])
{
   // Make sure we have at least 2 bars from 'index'
   if(index+1 >= ArraySize(rates))
      return false;

   double prevOpen  = rates[index+1].open;
   double prevClose = rates[index+1].close;
   double currOpen  = rates[index].open;
   double currClose = rates[index].close;

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
bool CDLPIERCING(int i)
{
   // Ensure we have the previous candle
   if (i+1 >= Bars) 
      return false;

   // Candle 1 (previous)
   double prevOpen   = Open[i+1];
   double prevClose  = Close[i+1];
   double prevHigh   = High[i+1];
   double prevLow    = Low[i+1];

   // Candle 2 (current)
   double currOpen   = Open[i];
   double currClose  = Close[i];
   double currHigh   = High[i];
   double currLow    = Low[i];

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
   bool prevLongBody = (prevBody > iMA(NULL, 0, 14, 0, MODE_EMA, PRICE_BODY, i));

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
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| CDL3WHITESOLDIERS Pattern Detection Function                             |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Three White Soldiers - Bullish Pattern Detection                 |
//+------------------------------------------------------------------+
bool CdlThreeWhiteSoldiersBullish(int i)
{
   // We need i, i+1, i+2
   if(i+2 >= Bars)
      return false;

   // Candle 0 (current)
   double o0 = Open[i];
   double c0 = Close[i];
   double h0 = High[i];
   double l0 = Low[i];

   // Candle 1
   double o1 = Open[i+1];
   double c1 = Close[i+1];
   double h1 = High[i+1];
   double l1 = Low[i+1];

   // Candle 2
   double o2 = Open[i+2];
   double c2 = Close[i+2];
   double h2 = High[i+2];
   double l2 = Low[i+2];

   // Body sizes
   double body0 = MathAbs(c0 - o0);
   double body1 = MathAbs(c1 - o1);
   double body2 = MathAbs(c2 - o2);

   // Body average (EMA of 14 periods, PineScript equivalent)
   double bodyAvg = iMA(NULL, 0, 14, 0, MODE_EMA, PRICE_CLOSE, i);

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
//+------------------------------------------------------------------+
//| Rising Three Methods - Bullish Pattern Detection                 |
//+------------------------------------------------------------------+
bool CDLRISEFALL3METHODS(int i)
{
   // We need candles i..i+4
   if(i+4 >= Bars)
      return false;

   // Extract OHLC
   double o0 = Open[i];     double c0 = Close[i];     double h0 = High[i];     double l0 = Low[i];
   double o1 = Open[i+1];   double c1 = Close[i+1];   double h1 = High[i+1];   double l1 = Low[i+1];
   double o2 = Open[i+2];   double c2 = Close[i+2];   double h2 = High[i+2];   double l2 = Low[i+2];
   double o3 = Open[i+3];   double c3 = Close[i+3];   double h3 = High[i+3];   double l3 = Low[i+3];
   double o4 = Open[i+4];   double c4 = Close[i+4];   double h4 = High[i+4];   double l4 = Low[i+4];

   // Body sizes
   double body0 = MathAbs(c0 - o0);
   double body1 = MathAbs(c1 - o1);
   double body2 = MathAbs(c2 - o2);
   double body3 = MathAbs(c3 - o3);
   double body4 = MathAbs(c4 - o4);

   // Body average via EMA 14 (TA equivalent)
   double bodyAvg = iMA(NULL,0,14,0,MODE_EMA,PRICE_CLOSE,i);

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
   bool upTrend4 = (c4 > iMA(NULL,0,50,0,MODE_SMA,PRICE_CLOSE,i+4));

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

//+------------------------------------------------------------------+
//| CDLABANDONEDBABY Pattern Detection Function                      |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| CDLLADDERBOTTOM Pattern Detection Function                       |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| CDLMATCHINGLOW Pattern Detection Function                        |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| CDLUNIQUE3RIVER Pattern Detection Function                       |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| CDL3INSIDE Pattern Detection Function                            |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| CDL3OUTSIDE Pattern Detection Function                           |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| CDBELTHOLD Pattern Detection Function                            |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| CDLBREAKAWAY Pattern Detection Function                          |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| CDLKICKING Pattern Detection Function                            |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| CDLKICKINGBYLENGTH Pattern Detection Function                    |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| CDLSTICKSANDWICH Pattern Detection Function                      |
//+------------------------------------------------------------------+



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