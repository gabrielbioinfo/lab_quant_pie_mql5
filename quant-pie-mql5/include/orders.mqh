//+------------------------------------------------------------------+
//| quant-pie-mql5 - orders.mqh                                                 |
//| Order management module for EA development                             |
//+------------------------------------------------------------------+

#ifndef _QUANT_ORDERS_MQH_
#define _QUANT_ORDERS_MQH_

// Opens a market order (BUY or SELL)
bool OpenMarketOrder(string symbol, ENUM_ORDER_TYPE orderType, double lotSize, string comment = "")
{
    double price = (orderType == ORDER_TYPE_BUY) ? SymbolInfoDouble(symbol, SYMBOL_ASK) : SymbolInfoDouble(symbol, SYMBOL_BID);
    double sl = 0; // Stop Loss placeholder
    double tp = 0; // Take Profit placeholder

    MqlTradeRequest request;
    MqlTradeResult result;

    ZeroMemory(request);
    ZeroMemory(result);

    request.action = TRADE_ACTION_DEAL;
    request.symbol = symbol;
    request.volume = lotSize;
    request.type = orderType;
    request.price = price;
    request.sl = sl;
    request.tp = tp;
    request.deviation = 10;
    request.magic = 123456;
    request.comment = comment;

    if (!OrderSend(request, result)) {
        Print("OrderSend error: ", result.retcode);
        return false;
    }

    return result.retcode == TRADE_RETCODE_DONE;
}

// Closes all open positions for the given symbol
void CloseAllOrders(string symbol)
{
    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        ulong ticket = PositionGetTicket(i);
        if (PositionSelectByTicket(ticket))
        {
            if (PositionGetString(POSITION_SYMBOL) == symbol)
            {
                double volume = PositionGetDouble(POSITION_VOLUME);
                ENUM_ORDER_TYPE closeType = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;
                double price = (closeType == ORDER_TYPE_BUY) ? SymbolInfoDouble(symbol, SYMBOL_ASK) : SymbolInfoDouble(symbol, SYMBOL_BID);

                MqlTradeRequest request;
                MqlTradeResult result;
                ZeroMemory(request);
                ZeroMemory(result);

                request.action = TRADE_ACTION_DEAL;
                request.symbol = symbol;
                request.volume = volume;
                request.type = closeType;
                request.price = price;
                request.deviation = 10;
                request.magic = 123456;
                request.comment = "quant-pie-mql5 close";

                OrderSend(request, result);
            }
        }
    }
}

#endif
