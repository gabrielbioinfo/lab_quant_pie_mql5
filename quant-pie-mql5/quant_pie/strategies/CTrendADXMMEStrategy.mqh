// === CTrendADXMMEStrategy.mqh ===
#ifndef __C_TREND_ADX_MME_STRATEGY_MQH__
#define __C_TREND_ADX_MME_STRATEGY_MQH__

#include <Indicators\Indicators.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\Trade.mqh>
#include <quant_pie/core/StrategyBase.mqh>
#include <quant_pie/core/TradeExecutor.mqh>
#include <quant_pie/core/constants.mqh>
#include <quant_pie/session/SessionCandleFilter.mqh>

class CTrendADXMMEStrategy : public CStrategyBase
{
private:
    int short_ma_period;
    int long_ma_period;
    int adx_period;
    double adx_threshold;

    int short_ma_handle;
    int long_ma_handle;
    int adx_handle;
    ulong magic;
    double lot;
    ENUM_OPERATION_MODE mode;
    datetime last_trade_time;
    int last_trade_type;
    bool has_initialized_direction;
    bool verbose_log;
    bool is_trade_pending;

    double GetMinimumLot()
    {
        double step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
        double min = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
        return NormalizeDouble(MathMax(min, step), 3);
    }

    bool WaitForPosition(string symbol, ulong magic, int retries = 5, int delay = 100)
    {
        for (int i = 0; i < retries; i++)
        {
            if (IsOwnPositionOpen(symbol, magic)) return true;
            Sleep(delay);
        }
        return false;
    }

    bool HasEnoughMargin(int type)
    {
        double freeMargin = AccountInfoDouble(ACCOUNT_FREEMARGIN);
        double margin = 0.0;
        double price = (type == ORDER_TYPE_BUY) ? SymbolInfoDouble(symbol, SYMBOL_ASK) : SymbolInfoDouble(symbol, SYMBOL_BID);

        if (!OrderCalcMargin((ENUM_ORDER_TYPE)type, symbol, lot, price, margin))
        {
            Print("❌ Failed to calculate margin");
            return false;
        }

        if (freeMargin - margin <= 0.0)
        {
            PrintFormat("❌ Not enough margin for %s | Lot: %.3f | Free: %.2f | Needed: %.2f", 
                        type == ORDER_TYPE_BUY ? "BUY" : "SELL", lot, freeMargin, margin);
            return false;
        }
        return true;
    }

    bool TryBuy(datetime candle_time)
    {
        if (is_trade_pending) return false;
        if (!HasEnoughMargin(ORDER_TYPE_BUY)) return false;
        is_trade_pending = true;

        if (OpenMarketOrder(symbol, ORDER_TYPE_BUY, lot, "trend_adx_mme", magic))
        {
            if (WaitForPosition(symbol, magic))
            {
                if (use_sl_tp) SetFixedSLTP(symbol, stop_loss, take_profit);
                last_trade_type = 1;
                last_trade_time = candle_time;
                is_trade_pending = false;
                return true;
            }
        }
        is_trade_pending = false;
        return false;
    }

    bool TrySell(datetime candle_time)
    {
        if (is_trade_pending) return false;
        if (!HasEnoughMargin(ORDER_TYPE_SELL)) return false;
        is_trade_pending = true;

        if (OpenMarketOrder(symbol, ORDER_TYPE_SELL, lot, "trend_adx_mme", magic))
        {
            if (WaitForPosition(symbol, magic))
            {
                if (use_sl_tp) SetFixedSLTP(symbol, stop_loss, take_profit);
                last_trade_type = 0;
                last_trade_time = candle_time;
                is_trade_pending = false;
                return true;
            }
        }
        is_trade_pending = false;
        return false;
    }

    void TryCloseBuy(datetime candle_time)
    {
        CloseOwnPosition(symbol, magic);
        last_trade_type = 0;
        last_trade_time = candle_time;
        is_trade_pending = false;
    }

    void TryCloseSell(datetime candle_time)
    {
        CloseOwnPosition(symbol, magic);
        last_trade_type = 1;
        last_trade_time = candle_time;
        is_trade_pending = false;
    }

public:
    CTrendADXMMEStrategy(
        int _short_ma,
        int _long_ma,
        int _adx_period,
        double _adx_threshold,
        double _sl,
        double _tp,
        double _break,
        double _trail,
        bool _use_sl_tp,
        bool _use_break,
        bool _use_trail,
        bool _enable_candle_filter,
        double _lot,
        ulong _magic,
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        ENUM_OPERATION_MODE _mode,
        bool _verbose = false
    ) : CStrategyBase(_sl, _tp, _break, _trail, _use_sl_tp, _use_break, _use_trail, _enable_candle_filter, _symbol, _tf)
    {
        short_ma_period = _short_ma;
        long_ma_period = _long_ma;
        adx_period = _adx_period;
        adx_threshold = _adx_threshold;
        magic = _magic;
        mode = _mode;
        verbose_log = _verbose;
        last_trade_time = 0;
        last_trade_type = -1;
        has_initialized_direction = false;
        is_trade_pending = false;
        lot = NormalizeDouble(MathMax(_lot, GetMinimumLot()), 3);
    }

    bool Init()
    {
        short_ma_handle = iMA(symbol, timeframe, short_ma_period, 0, MODE_EMA, PRICE_CLOSE);
        long_ma_handle = iMA(symbol, timeframe, long_ma_period, 0, MODE_EMA, PRICE_CLOSE);
        adx_handle = iADX(symbol, timeframe, adx_period);

        return short_ma_handle != INVALID_HANDLE &&
               long_ma_handle != INVALID_HANDLE &&
               adx_handle != INVALID_HANDLE;
    }

    void Deinit()
    {
        IndicatorRelease(short_ma_handle);
        IndicatorRelease(long_ma_handle);
        IndicatorRelease(adx_handle);
    }

    void OnTick()
    {
        datetime candle_time[1];
        if (CopyTime(symbol, timeframe, 1, 1, candle_time) <= 0)
            return;

        double ma_short[3], ma_long[3], adx[3];
        if (CopyBuffer(short_ma_handle, 0, 0, 3, ma_short) < 0 ||
            CopyBuffer(long_ma_handle, 0, 0, 3, ma_long) < 0 ||
            CopyBuffer(adx_handle, 0, 0, 3, adx) < 0)
        {
            Print("❌ Error copying buffers");
            return;
        }

        if (use_break_even) ApplyBreakEven(symbol, break_even_trigger);
        if (use_trailing) ApplyTrailingStop(symbol, trailing_points);

        bool has_position = IsOwnPositionOpen(symbol, magic);
        int direction = GetPositionDirection(symbol);

        double adx_curr = adx[1];
        if (!has_position && adx_curr < adx_threshold) return;

        double ma_short_prev = ma_short[2];
        double ma_short_curr = ma_short[1];
        double ma_long_prev = ma_long[2];
        double ma_long_curr = ma_long[1];

        bool is_exact_buy_cross = (ma_short_prev < ma_long_prev && ma_short_curr >= ma_long_curr);
        bool is_exact_sell_cross = (ma_short_prev > ma_long_prev && ma_short_curr <= ma_long_curr);
        bool is_exact_cross = is_exact_buy_cross || is_exact_sell_cross;

        if (!has_position && !is_exact_cross) return;

        bool position_direction_is_the_same = (direction == POSITION_TYPE_BUY && is_exact_buy_cross)
                || (direction == POSITION_TYPE_SELL && is_exact_sell_cross);
        if (position_direction_is_the_same) return;

        if(!has_position && is_exact_cross) {
            if (is_exact_buy_cross && (mode == MODE_ALTERNATE || mode == MODE_ONLY_BUY) && last_trade_type != 1)
                TryBuy(candle_time[0]);

            if (is_exact_sell_cross && (mode == MODE_ALTERNATE || mode == MODE_ONLY_SELL) && last_trade_type != 0)
                TrySell(candle_time[0]);
            return;
        }

        if(has_position && !position_direction_is_the_same && !use_sl_tp) {
            Print("We have to close our position if we dont have sl set");
            if (direction == POSITION_TYPE_BUY)
                TryCloseBuy(candle_time[0]);
            else
                TryCloseSell(candle_time[0]);
        }
    }
};

#endif // __C_TREND_ADX_MME_STRATEGY_MQH__
