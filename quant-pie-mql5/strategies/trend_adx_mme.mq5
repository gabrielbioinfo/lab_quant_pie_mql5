//+------------------------------------------------------------------+
//| trend_adx_mme.mq5 - Quant Pie MQL5 Starter Strategy              |
//+------------------------------------------------------------------+

#include <Indicators\Indicators.mqh>    // Needed for MODE_MAIN
#include <Trade\Trade.mqh>              // Optional: MT5 trade functions
#include <quant_pie/orders.mqh>
#include <quant_pie/risk.mqh>

input ENUM_TIMEFRAMES user_timeframe = PERIOD_H1;

input int short_ma_period = 10;
input int long_ma_period  = 50;
input int adx_period      = 14;
input double adx_threshold = 25.0;

input double stop_loss_points     = 200;
input double take_profit_points   = 400;
input double break_even_trigger   = 150;
input double trailing_points      = 100;

input double lot_size = 0.1;

int short_ma_handle;
int long_ma_handle;
int adx_handle;

int OnInit()
{
   string symbol = _Symbol;
   int tf = _Period;

   short_ma_handle = iMA(symbol, user_timeframe, short_ma_period, 0, MODE_EMA, PRICE_CLOSE);
   long_ma_handle  = iMA(symbol, user_timeframe, long_ma_period, 0, MODE_EMA, PRICE_CLOSE);
   adx_handle      = iADX(symbol, user_timeframe, adx_period);

   if (short_ma_handle == INVALID_HANDLE ||
       long_ma_handle == INVALID_HANDLE ||
       adx_handle == INVALID_HANDLE)
   {
      Print("Error creating indicator handles");
      return INIT_FAILED;
   }

   Print("trend_adx_mme EA initialized.");
   return INIT_SUCCEEDED;
}

void OnTick()
{
   string symbol = _Symbol;

   double ma_short_buf[2];
   double ma_long_buf[2];
   double adx_buf[2];

   if (CopyBuffer(short_ma_handle, 0, 0, 2, ma_short_buf) < 0 ||
       CopyBuffer(long_ma_handle, 0, 0, 2, ma_long_buf) < 0 ||
       CopyBuffer(adx_handle, 0, 0, 2, adx_buf) < 0)
   {
      Print("Error copying indicator buffers");
      return;
   }

   double ma_short_current = ma_short_buf[0];
   double ma_short_prev    = ma_short_buf[1];
   double ma_long_current  = ma_long_buf[0];
   double ma_long_prev     = ma_long_buf[1];
   double adx              = adx_buf[0];

   // Filter: only trade in trend
   if (adx < adx_threshold) return;

   // Risk management
   if (PositionSelect(symbol)) {
      ApplyBreakEven(symbol, break_even_trigger);
      ApplyTrailingStop(symbol, trailing_points);
      return;
   }

   // Buy signal
   if (ma_short_prev < ma_long_prev && ma_short_current > ma_long_current) {
      if (OpenMarketOrder(symbol, ORDER_TYPE_BUY, lot_size, "trend_adx_mme buy")) {
         Sleep(500);
         bool sltp_set = SetFixedSLTP(symbol, stop_loss_points, take_profit_points);
         Print("SLTP set:", sltp_set, " ", stop_loss_points, " ",take_profit_points);
      }
   }

   // Sell signal
   if (ma_short_prev > ma_long_prev && ma_short_current < ma_long_current) {
      if (OpenMarketOrder(symbol, ORDER_TYPE_SELL, lot_size, "trend_adx_mme sell")) {
         Sleep(500);
         SetFixedSLTP(symbol, stop_loss_points, take_profit_points);
      }
   }
}
