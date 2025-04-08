#include <quant_pie/orders.mqh>

input ENUM_ORDER_TYPE orderType = ORDER_TYPE_BUY;
input double lotSize = 0.1;
input bool closeAfter = true;
input int waitTicks = 10;

int tick_counter = 0;
bool executed = false;

int OnInit()
{
    Print("✅ orders_debug EA initialized.");
    return INIT_SUCCEEDED;
}

void OnTick()
{
    string symbol = _Symbol;

    if (!executed) {
        if (!PositionSelect(symbol)) {
            bool opened = OpenMarketOrder(symbol, orderType, lotSize, "orders_debug");
            if (!opened) {
                Print("❌ Failed to open order");
                return;
            }
            Print("🟢 Order sent.");
            executed = true;
        }
    }

    if (executed && closeAfter) {
        tick_counter++;
        if (tick_counter >= waitTicks) {
            Print("🔁 Closing position manually...");
            CloseAllOrders(symbol);
            tick_counter = 0;
        }
    }
}
