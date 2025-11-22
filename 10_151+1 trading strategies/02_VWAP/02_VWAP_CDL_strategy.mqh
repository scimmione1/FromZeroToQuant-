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
extern bool CDLTAKURI           = false;

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