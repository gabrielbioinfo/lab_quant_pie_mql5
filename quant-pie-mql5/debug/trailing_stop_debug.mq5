#include <quant_pie/risk.mqh>
#include <quant_pie/orders.mqh>

input ENUM_ORDER_TYPE orderType = ORDER_TYPE_BUY;
input double lotSize = 0.1;
input double trail_points = 3000;
input int ticks_wait = 20;

int tick_counter = 0;
bool position_opened = false;

int OnInit()
{
    Print("✅ trailing_stop_debug EA initialized.");
    return INIT_SUCCEEDED;
}

void OnTick()
{
    string symbol = _Symbol;

    if (!position_opened) {
        if (!PositionSelect(symbol)) {
            bool opened = OpenMarketOrder(symbol, orderType, lotSize, "trailing_stop_debug");
            if (!opened) {
                Print("❌ Failed to open order");
                return;
            }
            position_opened = true;
            Print("🚀 Position opened, waiting to trigger trailing...");
            return;
        }
    }

    tick_counter++;

    if (tick_counter >= ticks_wait) {
        bool applied = ApplyTrailingStop(symbol, trail_points);
        Print("🔁 Trailing stop attempt → result: ", applied);
        tick_counter = 0;
    }
}
