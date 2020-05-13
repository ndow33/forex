#include<Trade\Trade.mqh>
CTrade   trade;

//This number is multiplied by the price
//to find the difference between the take profit and stop loss
input int      Chasm_factor = 1;

//Determines the factor by which the TP or SL will be divided
//Creating a larger or smaller chasm
input int      TP_Factor = 1;
input int      SL_Factor = 1;

//Determines how many candles back the EA will take into consideration
//when calculating the highest price minus the lowest price.
//Minimum number of candles is 2
input int      Candles = 2;
 
void OnTick()
  {
      //create an array for the price data
      MqlRates PriceInformation[];
      
      //sort the array from the current candle downwards
      ArraySetAsSeries(PriceInformation, true);
      
      //fill in the array with data
      int Data = CopyRates(_Symbol,_Period,0,10,PriceInformation);
      
      //create variable for the highest and lowest candle
      int HighestCandle;
      int LowestCandle;
      
      //create an array for price data
      double High[];
      double Low[];
      
      //sort the array from the current candle downwards
      ArraySetAsSeries(High,true);
      ArraySetAsSeries(Low, true);
      
      //fill the array with high prices. 
      //The number before 'HIGH' is how many candles back you want to go
      CopyHigh(_Symbol,_Period,0,Candles,High);
      CopyLow(_Symbol,_Period,0,Candles,Low);
      
      //get the highest candle price
      //the last number in parenthases is how many candles back you want to go
      HighestCandle = ArrayMaximum(High,1,Candles);
      LowestCandle = ArrayMinimum(Low,1,Candles);
      
      //set object properties for a line
      ObjectCreate(_Symbol, "Line1", OBJ_HLINE,0,0,PriceInformation[HighestCandle].high);
      ObjectCreate(_Symbol, "Line2", OBJ_HLINE,0,0,PriceInformation[LowestCandle].low);
      
      //set object color
      ObjectSetInteger(0,"Line1", OBJPROP_COLOR,clrMagenta);
      ObjectSetInteger(0,"Line2", OBJPROP_COLOR,clrMagenta);
      
      //set object width
      ObjectSetInteger(0,"Line1",OBJPROP_WIDTH, 3);
      ObjectSetInteger(0,"Line2",OBJPROP_WIDTH, 3);
      
      //move the line when price changes
      ObjectMove(_Symbol, "Line1",0,0,PriceInformation[HighestCandle].high);
      ObjectMove(_Symbol, "Line2",0,0,PriceInformation[LowestCandle].low);
      
      //comment
      Comment("Highest price ", PriceInformation[HighestCandle].high);
      Comment("Lowest price ", PriceInformation[LowestCandle].low);
      
      //get stop loss and take profit limits by subtracting the lowest price of the candles from the highest price of the candles
      //Divide by the TP and SL Factors to get how large the chasm will be
      double Take_Profit = (PriceInformation[HighestCandle].high - PriceInformation[LowestCandle].low)/TP_Factor;
      double Stop_Loss = (PriceInformation[HighestCandle].high - PriceInformation[LowestCandle].low)/SL_Factor;
      
      //get the lotsize
      double LotSize = AccountInfoDouble(ACCOUNT_EQUITY)/10000;
      LotSize = MathRound(LotSize);
      
      
      double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
      double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
      double Spread = Ask-Bid;
      
      double BuyPrice = PriceInformation[HighestCandle].high;
      double SellPrice = PriceInformation[LowestCandle].low;
      
      //if we have no open orders or positions
      if ((OrdersTotal() == 0) && (PositionsTotal() == 0))
      {
        
         trade.SellStop(LotSize, SellPrice, _Symbol, SellPrice+Stop_Loss, SellPrice-Take_Profit,ORDER_TIME_DAY,0,NULL);
         trade.BuyStop(LotSize, BuyPrice,_Symbol, BuyPrice-Stop_Loss, BuyPrice+Take_Profit, ORDER_TIME_DAY,0,NULL);
      }
      
  }  
    
    
 