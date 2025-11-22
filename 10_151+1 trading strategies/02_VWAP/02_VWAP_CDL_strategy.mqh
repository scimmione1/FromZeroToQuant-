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

   return

   
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

   // === Market Open condition (skip closure hours) ===
   if(hour < 1 || hour > 20) return;

   // === Gap Up condition ===
   double gapPct = (Open[0] - Close[1]) / Close[1];
   if(gapPct >= gap && TradeDayOfWeek() && IsTradeAllowed())
   {
      // Avoid multiple trades
      if(TradesCount(OP_BUY) == 0)
      {
         double atr = iATR(NULL, 0, ATR_Period, 0);
         double sl = Ask - ATR_Mult_SL * atr;
         double tp = Ask + ATR_Mult_TP * atr;
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