int OnInit()
{
    string symbol = _Symbol;

    Print("🔍 Symbol Info Debug for ", symbol);
    Print("Digits: ", (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS));
    Print("Point: ", SymbolInfoDouble(symbol, SYMBOL_POINT));
    Print("Min Lot: ", SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN));
    Print("Lot Step: ", SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP));
    Print("Stops Level (min SL/TP distance): ", SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL));
    Print("Min SL/TP (price): ", SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL) * SymbolInfoDouble(symbol, SYMBOL_POINT));
    Print("Tick Size: ", SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE));
    Print("Tick Value: ", SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE));
    Print("Margin Initial: ", SymbolInfoDouble(symbol, SYMBOL_MARGIN_INITIAL));
    Print("Leverage: ", SymbolInfoInteger(symbol, SYMBOL_TRADE_CALC_MODE));
    return INIT_SUCCEEDED;
}

void OnTick() { }
