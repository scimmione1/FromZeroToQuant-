//+------------------------------------------------------------------+
//|                                                VWAP Expert.mql5  |
//|                        Copyright 2025, Christian Benjamin        |
//|                                  https://www.mql5.com            |
//+------------------------------------------------------------------+
#property copyright "2025, Christian Benjamin"
#property link      "https://www.mql5.com/en/users/lynnchris"
#property version   "1.3"
#property strict

input string pythonUrl = "http://127.0.0.1:5080/vwap";  // Python server endpoint
input int timeout = 5000;                               // Timeout in milliseconds
input int signalIntervalMinutes = 5;                    // Time interval (minutes) between updates
input int confirmationInterval = 2;                     // Number of intervals before confirming a signal
input int numCandles = 150;                             // Number of candles to collect for analysis

datetime lastSignalTime = 0;        // Tracks the last update time
string lastSignal = "";             // Stores the last received signal
int signalConfirmationCount = 0;    // Tracks how many times the signal has been confirmed

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("VWAP Expert initialized.");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Print("VWAP Expert deinitialized.");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Ensure requests are only sent after the specified time interval
   if (TimeCurrent() - lastSignalTime < signalIntervalMinutes * 60) return;

   // Update the last signal time to throttle requests
   lastSignalTime = TimeCurrent();

   // Gather and send data only after the interval
   string csvData = "date,high,low,open,close,volume\n";

   // Ensure we have enough bars available
   int totalBars = iBars(Symbol(), Period());
   if (totalBars < numCandles)
   {
      Print("Error: Not enough candles on the chart to collect ", numCandles, " candles.");
      return;
   }

   // Collect data for the last `numCandles` candles
   for (int i = numCandles - 1; i >= 0; i--)
   {
      datetime currentTime = iTime(Symbol(), Period(), i);
      if (currentTime == 0) continue; // Skip invalid times

      double high = iHigh(Symbol(), Period(), i);
      double low = iLow(Symbol(), Period(), i);
      double close = iClose(Symbol(), Period(), i);
      double open = iOpen(Symbol(), Period(), i);
      long volume = iVolume(Symbol(), Period(), i);

      // Skip invalid or missing data
      if (high == 0 || low == 0 || close == 0 || volume == 0)
      {
         Print("Skipping invalid data at ", TimeToString(currentTime, TIME_DATE | TIME_MINUTES));
         continue;
      }

      csvData += StringFormat("%s,%.5f,%.5f,%.5f,%.5f,%ld\n",
                              TimeToString(currentTime, TIME_DATE | TIME_MINUTES),
                              high, low, open, close, volume);
   }

   // Write the data to a CSV file
   string fileName = StringFormat("%s_vwap_data.csv", Symbol());
   string filePath = "MQL5\\Files\\" + fileName;  // Ensure it is saved in the correct directory
   int fileHandle = FileOpen(filePath, FILE_WRITE | FILE_CSV | FILE_ANSI);
   if (fileHandle == INVALID_HANDLE)
   {
      Print("Error: Failed to create CSV file at ", filePath);
      return;
   }
   FileWriteString(fileHandle, csvData);
   FileClose(fileHandle);
   Print("CSV file created: ", filePath);

   // Prepare the WebRequest
   char data[]; 
   StringToCharArray(csvData, data);

   string headers = "Content-Type: text/csv\r\n";
   char result[]; 
   string resultHeaders;
   int responseCode = WebRequest(
                         "POST",
                         pythonUrl,
                         headers,
                         timeout,
                         data,
                         result,
                         resultHeaders
                      );

   if (responseCode == 200)
   {
      string response = CharArrayToString(result);
      Print("Server response: ", response);

      // Validate and parse the JSON response
      if (StringFind(response, "\"vwap\":") == -1 || StringFind(response, "\"signal_explanation\":") == -1)
      {
         Print("Error: Invalid response from server. Response: ", response);
         return;
      }

      string vwap = ExtractValueFromJSON(response, "vwap");
      string explanation = ExtractValueFromJSON(response, "signal_explanation");
      string majorSupport = ExtractValueFromJSON(response, "major_support");
      string majorResistance = ExtractValueFromJSON(response, "major_resistance");
      string minorSupport = ExtractValueFromJSON(response, "minor_support");
      string minorResistance = ExtractValueFromJSON(response, "minor_resistance");

      if (vwap != "" && explanation != "")
      {
         string newSignal = "VWAP: " + vwap + "\nExplanation: " + explanation
                            + "\nMajor Support: " + majorSupport + "\nMajor Resistance: " + majorResistance
                            + "\nMinor Support: " + minorSupport + "\nMinor Resistance: " + minorResistance;

         // Confirm the signal multiple times before updating
         if (newSignal != lastSignal)
         {
            signalConfirmationCount++;
         }

         if (signalConfirmationCount >= confirmationInterval)
         {
            lastSignal = newSignal;
            signalConfirmationCount = 0;  // Reset confirmation count
            Print("New VWAP signal: ", newSignal);
            Alert("New VWAP Signal Received:\n" + newSignal);
         }
      }
   }
   else
   {
      Print("Error: WebRequest failed with code ", responseCode, ". Response headers: ", resultHeaders);
   }
}

//+------------------------------------------------------------------+
//| Extract value from JSON function                                 |
//+------------------------------------------------------------------+
string ExtractValueFromJSON(string json, string key)
{
   int startPos = StringFind(json, "\"" + key + "\":");
   if (startPos == -1) return "";
   int endPos = StringFind(json, ",", startPos);
   if (endPos == -1) endPos = StringFind(json, "}", startPos);
   if (endPos == -1) return ""; // Handle malformed JSON

   string value = StringSubstr(json, startPos + StringLen(key) + 3, endPos - startPos - StringLen(key) - 3);
   return value;
}
