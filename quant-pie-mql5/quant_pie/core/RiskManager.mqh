// === RiskManager.mqh ===
#ifndef __RISK_MANAGER_MQH__
#define __RISK_MANAGER_MQH__

#include <quant_pie/core/TradeExecutor.mqh>

class CRiskManager
{
protected:
    string symbol;
    double break_even_trigger;
    double trailing_points;
    double stop_loss;
    double take_profit;

    bool use_break_even;
    bool use_trailing;
    bool use_sl_tp;

public:
    CRiskManager(
        string _symbol,
        double _sl,
        double _tp,
        double _break_trigger,
        double _trail,
        bool _use_sl_tp,
        bool _use_break,
        bool _use_trail
    )
    {
        symbol = _symbol;
        stop_loss = _sl;
        take_profit = _tp;
        break_even_trigger = _break_trigger;
        trailing_points = _trail;
        use_sl_tp = _use_sl_tp;
        use_break_even = _use_break;
        use_trailing = _use_trail;
    }

    void Apply()
    {
        if (use_break_even)
            ApplyBreakEven(symbol, break_even_trigger);
        if (use_trailing)
            ApplyTrailingStop(symbol, trailing_points);
    }

    void SetInitialSLTP()
    {
        if (use_sl_tp)
            SetFixedSLTP(symbol, stop_loss, take_profit);
    }
};

#endif // __RISK_MANAGER_MQH__
