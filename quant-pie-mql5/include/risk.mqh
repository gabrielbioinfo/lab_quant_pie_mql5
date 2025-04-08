//+------------------------------------------------------------------+
//| quant-pie-mql5 - risk.mqh                                       |
//| Risk management utilities (SL, BE, Trailing Stop)               |
//+------------------------------------------------------------------+

#ifndef _QUANT_RISK_MQH_
#define _QUANT_RISK_MQH_

// Sets a fixed Stop Loss and Take Profit for an open position
bool SetFixedSLTP(string symbol, double stopLossPoints, double takeProfitPoints)
{
    if (!PositionSelect(symbol)) return false;

    ulong ticket = PositionGetInteger(POSITION_TICKET);
    double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
    double sl = 0;
    double tp = 0;

    ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

    if (type == POSITION_TYPE_BUY) {
        sl = openPrice - stopLossPoints * _Point;
        tp = openPrice + takeProfitPoints * _Point;
    } else if (type == POSITION_TYPE_SELL) {
        sl = openPrice + stopLossPoints * _Point;
        tp = openPrice - takeProfitPoints * _Point;
    }

    MqlTradeRequest request;
    MqlTradeResult result;

    ZeroMemory(request);
    ZeroMemory(result);

    request.action = TRADE_ACTION_SLTP;
    request.symbol = symbol;
    request.sl = sl;
    request.tp = tp;
    request.position = ticket;

    return OrderSend(request, result) && result.retcode == TRADE_RETCODE_DONE;
}

// Applies trailing stop to the active position
bool ApplyTrailingStop(string symbol, double trailPoints)
{
    if (!PositionSelect(symbol)) return false;

    ulong ticket = PositionGetInteger(POSITION_TICKET);
    double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
    double currentPrice = SymbolInfoDouble(symbol, POSITION_TYPE_BUY ? SYMBOL_BID : SYMBOL_ASK);
    ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
    double newSL = 0;

    if (type == POSITION_TYPE_BUY) {
        newSL = currentPrice - trailPoints * _Point;
        if (newSL <= PositionGetDouble(POSITION_SL)) return false;
    } else if (type == POSITION_TYPE_SELL) {
        newSL = currentPrice + trailPoints * _Point;
        if (newSL >= PositionGetDouble(POSITION_SL)) return false;
    }

    MqlTradeRequest request;
    MqlTradeResult result;
    ZeroMemory(request);
    ZeroMemory(result);

    request.action = TRADE_ACTION_SLTP;
    request.symbol = symbol;
    request.sl = newSL;
    request.tp = PositionGetDouble(POSITION_TP);
    request.position = ticket;

    return OrderSend(request, result) && result.retcode == TRADE_RETCODE_DONE;
}

// Moves Stop Loss to breakeven if price is beyond a certain threshold
bool ApplyBreakEven(string symbol, double triggerPoints)
{
    if (!PositionSelect(symbol)) return false;

    ulong ticket = PositionGetInteger(POSITION_TICKET);
    double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
    ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
    double currentPrice = SymbolInfoDouble(symbol, type == POSITION_TYPE_BUY ? SYMBOL_BID : SYMBOL_ASK);
    double distance = MathAbs(currentPrice - openPrice) / _Point;

    if (distance < triggerPoints) return false;

    double newSL = openPrice;

    MqlTradeRequest request;
    MqlTradeResult result;
    ZeroMemory(request);
    ZeroMemory(result);

    request.action = TRADE_ACTION_SLTP;
    request.symbol = symbol;
    request.sl = newSL;
    request.tp = PositionGetDouble(POSITION_TP);
    request.position = ticket;

    return OrderSend(request, result) && result.retcode == TRADE_RETCODE_DONE;
}

#endif
