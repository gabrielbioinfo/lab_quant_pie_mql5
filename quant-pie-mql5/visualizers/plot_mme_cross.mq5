input int fast_period = 8;
input int slow_period = 20;
input color buy_color  = clrLime;
input color sell_color = clrRed;

int fast_handle, slow_handle;

int OnInit()
{
    fast_handle = iMA(_Symbol, _Period, fast_period, 0, MODE_EMA, PRICE_CLOSE);
    slow_handle = iMA(_Symbol, _Period, slow_period, 0, MODE_EMA, PRICE_CLOSE);

    if (fast_handle == INVALID_HANDLE || slow_handle == INVALID_HANDLE)
    {
        Print("❌ Failed to create indicator handles");
        return INIT_FAILED;
    }

    Print("✅ MME Cross Visualizer initialized");
    return INIT_SUCCEEDED;
}

void OnTick()
{
    static datetime last_bar_time = 0;
    datetime current_time = iTime(_Symbol, _Period, 0);

    if (current_time == last_bar_time)
        return;

    last_bar_time = current_time;

    double fast_ma[2];
    double slow_ma[2];

    if (CopyBuffer(fast_handle, 0, 1, 2, fast_ma) < 0 ||
         CopyBuffer(slow_handle, 0, 1, 2, slow_ma) < 0)
    {
        Print("❌ Error copying buffers");
        return;
    }

    double fast_prev = fast_ma[1];
    double fast_curr = fast_ma[0];
    double slow_prev = slow_ma[1];
    double slow_curr = slow_ma[0];

    if (fast_prev < slow_prev && fast_curr > slow_curr)
    {
        // BUY signal
        DrawSignalArrow(Time[0], Low[0], buy_color, "buy");
    }
    else if (fast_prev > slow_prev && fast_curr < slow_curr)
    {
        // SELL signal
        DrawSignalArrow(Time[0], High[0], sell_color, "sell");
    }
}

// Draws arrow on chart
void DrawSignalArrow(datetime time, double price, color arrow_color, string label_prefix)
{
    string id = label_prefix + "_" + IntegerToString(time);
    int direction = (label_prefix == "buy") ? 233 : 234; // Arrow code

    ObjectCreate(0, id, OBJ_ARROW, 0, time, price);
    ObjectSetInteger(0, id, OBJPROP_ARROWCODE, direction);
    ObjectSetInteger(0, id, OBJPROP_COLOR, arrow_color);
    ObjectSetInteger(0, id, OBJPROP_WIDTH, 2);
    ObjectSetInteger(0, id, OBJPROP_BACK, false);
}
