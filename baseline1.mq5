#include<Trade\Trade.mqh>

CTrade trade;

input int TakeProfit = 100;
input int StopLoss = 100;
input int LotSizeFactor = 10000;

double equity1;
double equity2;
double equity_dif;
string last_order;


void OnTick()
  {
   //--------------------------------------EVERY BOT STUFF-----------------------------------------------
   //Get ask and bid
   double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
   double Spread = Ask-Bid;
   
   
   //Calculate Lot Size
   double LotSize = AccountInfoDouble(ACCOUNT_EQUITY)/LotSizeFactor;
   LotSize = MathRound(LotSize);
   
   
   //--------------------------------------FIRST TRADE---------------------------------------------
   
   //Have there been any orders?
   
   //This line loads the history
   HistorySelect(0,TimeCurrent());
   //This line checks how many orders there have been
   int historical = HistoryOrdersTotal();
   
   //If there have been no orders placed, enter a buy
   if (historical == 0)
      {
      equity1 = AccountInfoDouble(ACCOUNT_EQUITY);
      trade.Sell(LotSize,NULL,Bid,Bid + (StopLoss*_Point),Bid - (TakeProfit*_Point),NULL);
      last_order = "Sell";
      }


      
   //--------------------------------------ALL OTHER TRADES---------------------------------------------
   
   //Check to see if there are any open positions   
   if ((OrdersTotal() == 0) && (PositionsTotal() == 0))
      {
      //compare the previous equity to the current equity as well as the previous order to determine buy or sell
      equity2 = AccountInfoDouble(ACCOUNT_EQUITY);
      
      //Enter a buy if the equity has fallen and the previous order was a sell
      if ((equity1>equity2) && (last_order == "Sell"))
         {
         equity1 = AccountInfoDouble(ACCOUNT_EQUITY);
         trade.Buy(LotSize,NULL,Ask,Ask - (StopLoss*_Point),Ask + (TakeProfit*_Point),NULL);
         last_order = "Buy";
         }
      
      //Enter a buy if the equity has risen and the previous order was a buy   
      if ((equity1<equity2) && (last_order == "Buy"))
         {
         equity1 = AccountInfoDouble(ACCOUNT_EQUITY);
         trade.Buy(LotSize,NULL,Ask,Ask - (StopLoss*_Point),Ask + (TakeProfit*_Point),NULL);
         last_order = "Buy";
         }
               
      //Enter a sell if the equity has fallen and the previous order was a buy   
      if ((equity1>equity2) && (last_order == "Buy"))
         {
         equity1 = AccountInfoDouble(ACCOUNT_EQUITY);
         trade.Sell(LotSize,NULL,Bid,Bid + (StopLoss*_Point),Bid - (TakeProfit*_Point),NULL);
         last_order = "Sell";
         }
                        
      //Enter a sell if the equity has risen and the previous order was a sell   
      if ((equity1<equity2) && (last_order == "Sell"))
         {
         equity1 = AccountInfoDouble(ACCOUNT_EQUITY);
         trade.Sell(LotSize,NULL,Bid,Bid + (StopLoss*_Point),Bid - (TakeProfit*_Point),NULL);
         last_order = "Sell";
         }     
      }
   
   
   
   
  }