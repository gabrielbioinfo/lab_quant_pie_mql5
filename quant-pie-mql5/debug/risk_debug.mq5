#include <quant_pie/risk.mqh>
#include <quant_pie/orders.mqh>

input ENUM_ORDER_TYPE orderType = ORDER_TYPE_BUY;
input double lotSize = 0.1;
input double sl_points = 200;
input double tp_points = 400;

int OnInit()
{
   Print("risk_debug started");
   return INIT_SUCCEEDED;
}

void OnTick()
{
   string symbol = _Symbol;

   // Only run once
   static bool executed = false;
   if (executed || PositionSelect(symbol)) return;

   executed = true;

   bool opened = OpenMarketOrder(symbol, orderType, lotSize, "risk_debug");

   if (!opened) {
      Print("❌ Failed to open market order");
      return;
   }

   Sleep(1000); // Give time to open

   bool result = SetFixedSLTP(symbol, sl_points, tp_points);
   Print("✅ SL/TP set: ", result);
}
