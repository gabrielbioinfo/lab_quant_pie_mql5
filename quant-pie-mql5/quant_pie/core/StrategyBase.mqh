// === StrategyBase.mqh ===
#ifndef __STRATEGY_BASE_MQH__
#define __STRATEGY_BASE_MQH__

#include <quant_pie/session/SessionCandleFilter.mqh>

class CStrategyBase
{
protected:
    string symbol;
    ENUM_TIMEFRAMES timeframe;
    CSimpleCandleFilter* candle_filter;

    double stop_loss;
    double take_profit;
    double break_even_trigger;
    double trailing_points;

    bool use_sl_tp;
    bool use_break_even;
    bool use_trailing;

public:
    CStrategyBase(
        double _sl,
        double _tp,
        double _break,
        double _trail,
        bool _use_sl_tp,
        bool _use_break,
        bool _use_trail,
        bool _enable_candle_filter,
        string _symbol,
        ENUM_TIMEFRAMES _timeframe)
    {
        symbol = _symbol;
        timeframe = _timeframe;
        candle_filter = new CSimpleCandleFilter(_enable_candle_filter);

        stop_loss = _sl;
        take_profit = _tp;
        break_even_trigger = _break;
        trailing_points = _trail;

        use_sl_tp = _use_sl_tp;
        use_break_even = _use_break;
        use_trailing = _use_trail;
    }

    virtual ~CStrategyBase()
    {
        if (candle_filter != NULL)
            delete candle_filter;
    }

    virtual bool Init() = 0;
    virtual void Deinit() = 0;
    virtual void OnTick() = 0;

    bool ShouldProcess()
    {
        return candle_filter != NULL && candle_filter.IsNewCandle();
    }
};

#endif // __STRATEGY_BASE_MQH__