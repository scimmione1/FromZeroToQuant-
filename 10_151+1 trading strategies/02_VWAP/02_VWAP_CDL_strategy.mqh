//+------------------------------------------------------------------+
//| Expert Advisor - VWAP with CDL Pattern                           |
//+------------------------------------------------------------------+
#property strict

// === Parameters generali ===
extern int    MagicNumber      = 22222;
extern double RiskPercent      = 1.0;      // % risk per trade
extern double MaxLot = 0.1;           // Lotto massimo consentito
extern bool UseFixedLot = true;      // true = usa lotto fisso, false = calcolo percentuale
extern double FixedLot = 0.05;        // Lotto fisso quando UseFixedLot = true

// === Parameters ATR dinamico ===
extern int    ATR_Period       = 14;
extern double ATR_Mult_SL      = 2.0;
extern double ATR_Mult_TP      = 3.0;
extern int Slippage         = 3;

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