#include "ExecutionAlgorithm.mqh"

//+------------------------------------------------------------------+
//| Volume-Weighted Average Price (VWAP) Algorithm                    |
//+------------------------------------------------------------------+
class CVWAP : public CExecutionAlgorithm
{
private:
   int               m_intervals;           // Number of time intervals
   int               m_currentInterval;     // Current interval
   datetime          m_nextExecutionTime;   // Next execution time
   double            m_volumeProfile[];     // Historical volume profile
   double            m_intervalVolumes[];   // Volume per interval based on profile
   bool              m_adaptiveMode;        // Whether to adapt to real-time volume
   ENUM_ORDER_TYPE   m_orderType;           // Order type (buy or sell)
   int               m_historyDays;         // Number of days to analyze for volume profile
   bool              m_profileLoaded;       // Flag indicating if profile was loaded
   
public:
   // Constructor
   CVWAP(string symbol, double volume, datetime startTime, datetime endTime, 
         int intervals, ENUM_ORDER_TYPE orderType, int historyDays = 5,
         bool adaptiveMode = true, int slippage = 3);
   
   // Destructor
   ~CVWAP();
   
   // Implementation of virtual methods
   virtual bool      Initialize() override;
   virtual bool      Execute() override;
   virtual bool      Update() override;
   virtual bool      Terminate() override;
   
   // VWAP specific methods
   bool              LoadVolumeProfile();
   void              CalculateIntervalVolumes();
   void              AdjustToRealTimeVolume();
   datetime          CalculateNextExecutionTime();
   double            GetCurrentVWAP();
};

//+------------------------------------------------------------------+
//| Constructor                                                       |
//+------------------------------------------------------------------+
CVWAP::CVWAP(string symbol, double volume, datetime startTime, datetime endTime, 
            int intervals, ENUM_ORDER_TYPE orderType, int historyDays,
            bool adaptiveMode, int slippage)
   : CExecutionAlgorithm(symbol, volume, startTime, endTime, slippage)
{
   m_intervals = intervals;
   m_currentInterval = 0;
   m_adaptiveMode = adaptiveMode;
   m_orderType = orderType;
   m_nextExecutionTime = 0;
   m_historyDays = historyDays;
   m_profileLoaded = false;
   
   // Initialize arrays
   ArrayResize(m_volumeProfile, m_intervals);
   ArrayResize(m_intervalVolumes, m_intervals);
   
   // Initialize with zeros
   ArrayInitialize(m_volumeProfile, 0.0);
   ArrayInitialize(m_intervalVolumes, 0.0);
}

//+------------------------------------------------------------------+
//| Destructor                                                        |
//+------------------------------------------------------------------+
CVWAP::~CVWAP()
{
   // Clean up resources if needed
}

//+------------------------------------------------------------------+
//| Initialize the VWAP algorithm                                     |
//+------------------------------------------------------------------+
bool CVWAP::Initialize()
{
   if(!CExecutionAlgorithm::Initialize())
      return false;
      
   // Load historical volume profile
   if(!LoadVolumeProfile())
   {
      Print("VWAP: Failed to load volume profile. Using equal distribution.");
      // If we can't load the profile, use equal distribution
      for(int i = 0; i < m_intervals; i++)
         m_volumeProfile[i] = 1.0 / m_intervals;
      
      m_profileLoaded = false;
   }
   else
   {
      m_profileLoaded = true;
   }
   
   // Calculate the volume for each interval based on the profile
   CalculateIntervalVolumes();
   
   // Calculate the time for the first execution
   m_nextExecutionTime = CalculateNextExecutionTime();
   
   m_isActive = true;
   
   Print("VWAP algorithm initialized for ", m_symbol, 
         ". Total volume: ", DoubleToString(m_totalVolume, 2), 
         ", Intervals: ", m_intervals);
   
   return true;
}

//+------------------------------------------------------------------+
//| Execute the VWAP algorithm                                        |
//+------------------------------------------------------------------+
bool CVWAP::Execute()
{
   if(!m_isActive)
      return false;
      
   // Check if it's time to execute the next order
   datetime currentTime = TimeCurrent();
   
   if(currentTime < m_nextExecutionTime)
      return true; // Not time yet
      
   // If in adaptive mode, adjust volumes based on real-time market volume
   if(m_adaptiveMode && m_profileLoaded)
      AdjustToRealTimeVolume();
      
   // Get the volume for this interval
   double volumeToExecute = m_intervalVolumes[m_currentInterval];
   
   // Ensure we don't exceed the remaining volume
   if(volumeToExecute > m_remainingVolume)
      volumeToExecute = m_remainingVolume;
      
   // Get current market price
   double price = 0.0;
   if(m_orderType == ORDER_TYPE_BUY)
      price = SymbolInfoDouble(m_symbol, SYMBOL_ASK);
   else
      price = SymbolInfoDouble(m_symbol, SYMBOL_BID);
      
   // Place the order
   if(!PlaceOrder(m_orderType, volumeToExecute, price))
   {
      Print("VWAP: Failed to place order for interval ", m_currentInterval);
      return false;
   }
   
   // Update interval counter
   m_currentInterval++;
   
   // Calculate the time for the next execution
   if(m_currentInterval < m_intervals && m_remainingVolume > 0)
      m_nextExecutionTime = CalculateNextExecutionTime();
   else
      m_isActive = false; // All intervals completed or no volume left
      
   Print("VWAP: Executed ", DoubleToString(volumeToExecute, 2), 
         " at price ", DoubleToString(price, _Digits), 
         ". Remaining: ", DoubleToString(m_remainingVolume, 2));
         
   return true;
}

//+------------------------------------------------------------------+
//| Update the VWAP algorithm state                                   |
//+------------------------------------------------------------------+
bool CVWAP::Update()
{
   if(!m_isActive)
      return false;
      
   // Check if the end time has been reached
   if(TimeCurrent() >= m_endTime)
   {
      Print("VWAP: End time reached. Terminating algorithm.");
      return Terminate();
   }
   
   // Check if all volume has been executed
   if(m_remainingVolume <= 0)
   {
      Print("VWAP: All volume executed. Terminating algorithm.");
      return Terminate();
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Terminate the VWAP algorithm                                      |
//+------------------------------------------------------------------+
bool CVWAP::Terminate()
{
   if(!m_isActive)
      return false;
      
   // If there's remaining volume and we want to execute it all at once
   if(m_remainingVolume > 0)
   {
      Print("VWAP: Terminating with remaining volume: ", DoubleToString(m_remainingVolume, 2));
      
      // Get current market price
      double price = 0.0;
      if(m_orderType == ORDER_TYPE_BUY)
         price = SymbolInfoDouble(m_symbol, SYMBOL_ASK);
      else
         price = SymbolInfoDouble(m_symbol, SYMBOL_BID);
         
      // Place the final order for remaining volume
      if(!PlaceOrder(m_orderType, m_remainingVolume, price))
      {
         Print("VWAP: Failed to place final order");
      }
   }
   
   m_isActive = false;
   
   Print("VWAP algorithm terminated. Total executed volume: ", 
         DoubleToString(m_executedVolume, 2));
         
   return true;
}

//+------------------------------------------------------------------+
//| Load historical volume profile                                    |
//+------------------------------------------------------------------+
bool CVWAP::LoadVolumeProfile()
{
   // This function analyzes historical data to create a volume profile
   // for the trading day, divided into the specified number of intervals
   
   // Calculate the interval duration in seconds
   int totalSeconds = (int)(m_endTime - m_startTime);
   int intervalSeconds = totalSeconds / m_intervals;
   
   // Initialize volume profile array
   ArrayInitialize(m_volumeProfile, 0.0);
   
   // Calculate start time for historical data (e.g., 5 days ago)
   datetime historyStartTime = m_startTime - m_historyDays * 24 * 60 * 60;
   
   // Load historical data
   MqlRates rates[];
   int copied = CopyRates(m_symbol, PERIOD_M1, historyStartTime, m_endTime, rates);
   
   if(copied <= 0)
   {
      Print("VWAP: Failed to copy historical rates. Error: ", GetLastError());
      return false;
   }
   
   // Aggregate volume by interval
   double totalVolume = 0.0;
   
   for(int i = 0; i < copied; i++)
   {
      // Skip data outside our time window
      if(rates[i].time < m_startTime || rates[i].time >= m_endTime)
         continue;
         
      // Calculate which interval this bar belongs to
      int intervalIndex = (int)((rates[i].time - m_startTime) / intervalSeconds);
      
      // Ensure index is within bounds
      if(intervalIndex >= 0 && intervalIndex < m_intervals)
      {
         m_volumeProfile[intervalIndex] += rates[i].tick_volume;
         totalVolume += rates[i].tick_volume;
      }
   }
   
   // Normalize the profile
   if(totalVolume > 0)
   {
      for(int i = 0; i < m_intervals; i++)
         m_volumeProfile[i] /= totalVolume;
   }
   else
   {
      // If no volume data, use equal distribution
      for(int i = 0; i < m_intervals; i++)
         m_volumeProfile[i] = 1.0 / m_intervals;
         
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Calculate the volume for each interval based on the profile       |
//+------------------------------------------------------------------+
void CVWAP::CalculateIntervalVolumes()
{
   for(int i = 0; i < m_intervals; i++)
   {
      m_intervalVolumes[i] = m_totalVolume * m_volumeProfile[i];
      
      // Ensure the volume is within valid bounds
      double minVolume = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MIN);
      double maxVolume = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MAX);
      double stepVolume = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_STEP);
      
      // Normalize to volume step
      m_intervalVolumes[i] = MathFloor(m_intervalVolumes[i] / stepVolume) * stepVolume;
      
      // Ensure within min/max bounds
      m_intervalVolumes[i] = MathMax(minVolume, MathMin(maxVolume, m_intervalVolumes[i]));
   }
   
   // Log the calculated volumes
   string volumeLog = "VWAP: Interval volumes calculated: ";
   for(int i = 0; i < m_intervals; i++)
      volumeLog += DoubleToString(m_intervalVolumes[i], 2) + " ";
      
   Print(volumeLog);
}

//+------------------------------------------------------------------+
//| Adjust volumes based on real-time market volume                   |
//+------------------------------------------------------------------+
void CVWAP::AdjustToRealTimeVolume()
{
   // This function adjusts the remaining interval volumes based on 
   // real-time market volume compared to the historical profile
   
   // Only adjust if we have more than one interval left
   if(m_currentInterval >= m_intervals - 1)
      return;
      
   // Calculate how much of the total time has passed
   datetime currentTime = TimeCurrent();
   double timeProgress = (double)(currentTime - m_startTime) / (m_endTime - m_startTime);
   
   // Calculate how much of the total volume should have been executed by now
   double expectedVolumeProgress = 0.0;
   for(int i = 0; i < m_currentInterval; i++)
      expectedVolumeProgress += m_volumeProfile[i];
      
   // Calculate the actual volume progress
   double actualVolumeProgress = m_executedVolume / m_totalVolume;
   
   // Calculate the adjustment factor
   double adjustmentFactor = 1.0;
   if(expectedVolumeProgress > 0)
      adjustmentFactor = actualVolumeProgress / expectedVolumeProgress;
      
   // Limit the adjustment factor to reasonable bounds
   adjustmentFactor = MathMax(0.5, MathMin(2.0, adjustmentFactor));
   
   // Adjust the remaining interval volumes
   double remainingVolume = m_remainingVolume;
   double totalRemainingProfile = 0.0;
   
   // Calculate total remaining profile weight
   for(int i = m_currentInterval; i < m_intervals; i++)
      totalRemainingProfile += m_volumeProfile[i];
      
   // Adjust each remaining interval
   if(totalRemainingProfile > 0)
   {
      for(int i = m_currentInterval; i < m_intervals; i++)
      {
         // Normalize the profile for remaining intervals
         double normalizedProfile = m_volumeProfile[i] / totalRemainingProfile;
         
         // Apply the adjustment factor
         m_intervalVolumes[i] = remainingVolume * normalizedProfile * adjustmentFactor;
         
         // Ensure the volume is within valid bounds
         double minVolume = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MIN);
         double maxVolume = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MAX);
         double stepVolume = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_STEP);
         
         // Normalize to volume step
         m_intervalVolumes[i] = MathFloor(m_intervalVolumes[i] / stepVolume) * stepVolume;
         
         // Ensure within min/max bounds
         m_intervalVolumes[i] = MathMax(minVolume, MathMin(maxVolume, m_intervalVolumes[i]));
      }
   }
   
   Print("VWAP: Adjusted volumes based on real-time market activity. Adjustment factor: ", 
         DoubleToString(adjustmentFactor, 2));
}

//+------------------------------------------------------------------+
//| Calculate the time for the next execution                         |
//+------------------------------------------------------------------+
datetime CVWAP::CalculateNextExecutionTime()
{
   // Calculate the duration of each interval
   int totalSeconds = (int)(m_endTime - m_startTime);
   int intervalSeconds = totalSeconds / m_intervals;
   
   // Calculate the next execution time
   datetime nextTime;
   
   if(m_currentInterval == 0) {
      // First interval - start at the defined start time
      nextTime = m_startTime;
   } else {
      // For subsequent intervals, ensure proper spacing from current time
      datetime currentTime = TimeCurrent();
      nextTime = currentTime + intervalSeconds;
      
      // Make sure we don't exceed the end time
      if(nextTime > m_endTime)
         nextTime = m_endTime;
   }
   
   Print("VWAP: Next execution time set to ", TimeToString(nextTime));
   return nextTime;
}

//+------------------------------------------------------------------+
//| Get the current market VWAP                                       |
//+------------------------------------------------------------------+
double CVWAP::GetCurrentVWAP()
{
   // This function calculates the current market VWAP
   // from the start time until now
   
   datetime currentTime = TimeCurrent();
   
   // Load market data from start time until now
   MqlRates rates[];
   int copied = CopyRates(m_symbol, PERIOD_M1, m_startTime, currentTime, rates);
   
   if(copied <= 0)
   {
      Print("VWAP: Failed to copy rates for VWAP calculation. Error: ", GetLastError());
      return 0.0;
   }
   
   double volumeSum = 0.0;
   double priceVolumeSum = 0.0;
   
   for(int i = 0; i < copied; i++)
   {
      // Calculate typical price
      double typicalPrice = (rates[i].high + rates[i].low + rates[i].close) / 3.0;
      
      // Add to sums
      volumeSum += rates[i].tick_volume;
      priceVolumeSum += typicalPrice * rates[i].tick_volume;
   }
   
   // Calculate VWAP
   if(volumeSum > 0)
      return priceVolumeSum / volumeSum;
   else
      return 0.0;
}
//+------------------------------------------------------------------+
