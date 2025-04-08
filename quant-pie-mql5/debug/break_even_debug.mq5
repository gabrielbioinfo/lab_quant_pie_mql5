#include <quant_pie/risk.mqh>
#include <quant_pie/orders.mqh>

// === User configuration ===
input ENUM_ORDER_TYPE orderType = ORDER_TYPE_BUY;
input double lotSize = 0.1;
input double break_even_trigger = 3000; // in points
input int ticks_wait = 20; // how many ticks to wait before checking break even

int tick_counter = 0;
bool position_opened = false;

int OnInit()
{
   Print("✅ break_even_debug EA initialized.");
   return INIT_SUCCEEDED;
}

void OnTick()
{
   string symbol = _Symbol;

   if (!position_opened) {
      if (!PositionSelect(symbol)) {
         bool opened = OpenMarketOrder(symbol, orderType, lotSize, "break_even_debug");
         if (!opened) {
            Print("❌ Failed to open order");
            return;
         }
         position_opened = true;
         Print("🚀 Position opened, waiting to trigger break even...");
         return;
      }
   }

   tick_counter++;

   if (tick_counter >= ticks_wait) {
      bool applied = ApplyBreakEven(symbol, break_even_trigger);
      Print("🔁 Break even attempt → result: ", applied);
      tick_counter = 0; // optional: apply again after next wait
   }
}
