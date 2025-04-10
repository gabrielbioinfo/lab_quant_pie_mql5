// === TradeExecutor.mqh ===
#ifndef __TRADE_EXECUTOR_MQH__
#define __TRADE_EXECUTOR_MQH__

#include <Trade\Trade.mqh>
#include <quant_pie/session/SessionCandleFilter.mqh>
CTrade trade;

CSimpleCandleFilter candle_filter;

bool OpenMarketOrder(string symbol, ENUM_ORDER_TYPE type, double lot, string comment = "", ulong magic = 0)
{
    double price = (type == ORDER_TYPE_BUY) ? SymbolInfoDouble(symbol, SYMBOL_ASK)
                                            : SymbolInfoDouble(symbol, SYMBOL_BID);

    if (type == ORDER_TYPE_BUY)
        return trade.Buy(lot, symbol, price, 0, 0, comment);
    if (type == ORDER_TYPE_SELL)
        return trade.Sell(lot, symbol, price, 0, 0, comment);
    return false;
}

void CloseOwnPosition(string symbol, ulong magic = 0)
{
    if (!PositionSelect(symbol)) return;
    if (PositionGetInteger(POSITION_MAGIC) != (long)magic) return;

    ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
    ulong ticket = (ulong)PositionGetInteger(POSITION_TICKET);

    if (type == POSITION_TYPE_BUY)
        trade.PositionClose(ticket);
    if (type == POSITION_TYPE_SELL)
        trade.PositionClose(ticket);
}

bool IsOwnPositionOpen(string symbol, ulong magic = 0)
{
    if (!PositionSelect(symbol)) return false;
    return PositionGetInteger(POSITION_MAGIC) == (long)magic;
}

int GetPositionDirection(string symbol)
{
    if (!PositionSelect(symbol)) return -1;
    return (int)PositionGetInteger(POSITION_TYPE);
}

void SetFixedSLTP(string symbol, double sl_points, double tp_points)
{
    if (!PositionSelect(symbol)) return;
    double entry_price = PositionGetDouble(POSITION_PRICE_OPEN);
    ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

    double sl = 0, tp = 0;
    if (type == POSITION_TYPE_BUY) {
        sl = entry_price - sl_points * _Point;
        tp = entry_price + tp_points * _Point;
    }
    else if (type == POSITION_TYPE_SELL) {
        sl = entry_price + sl_points * _Point;
        tp = entry_price - tp_points * _Point;
    }

    trade.PositionModify(PositionGetInteger(POSITION_TICKET), sl, tp);
}

void ApplyBreakEven(string symbol, double trigger_points)
{
    if (!PositionSelect(symbol)) return;
    ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
    double entry = PositionGetDouble(POSITION_PRICE_OPEN);
    double price = (type == POSITION_TYPE_BUY) ? SymbolInfoDouble(symbol, SYMBOL_BID)
                                               : SymbolInfoDouble(symbol, SYMBOL_ASK);

    double profit_points = MathAbs(price - entry) / _Point;
    if (profit_points < trigger_points) return;

    double sl = entry;
    double tp = PositionGetDouble(POSITION_TP);
    trade.PositionModify(PositionGetInteger(POSITION_TICKET), sl, tp);
}

void ApplyTrailingStop(string symbol, double trail_points)
{
    if (!PositionSelect(symbol)) return;
    ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
    double entry = PositionGetDouble(POSITION_PRICE_OPEN);
    double sl = PositionGetDouble(POSITION_SL);
    double price = (type == POSITION_TYPE_BUY) ? SymbolInfoDouble(symbol, SYMBOL_BID)
                                               : SymbolInfoDouble(symbol, SYMBOL_ASK);

    double new_sl = 0;
    if (type == POSITION_TYPE_BUY)
    {
        new_sl = price - trail_points * _Point;
        if (sl == 0 || new_sl > sl)
            trade.PositionModify(PositionGetInteger(POSITION_TICKET), new_sl, PositionGetDouble(POSITION_TP));
    }
    else if (type == POSITION_TYPE_SELL)
    {
        new_sl = price + trail_points * _Point;
        if (sl == 0 || new_sl < sl)
            trade.PositionModify(PositionGetInteger(POSITION_TICKET), new_sl, PositionGetDouble(POSITION_TP));
    }
}

#endif // __TRADE_EXECUTOR_MQH__
