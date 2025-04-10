// === trend_adx_mme.mq5 ===
#include <quant_pie/strategies/CTrendADXMMEStrategy.mqh>
#include <quant_pie/core/constants.mqh>

input int short_ma_period = 8;
input int long_ma_period  = 20;
input int adx_period      = 14;
input double adx_threshold = 25.0;

input double stop_loss_points      = 5000;
input double take_profit_points    = 10000;
input double break_even_trigger    = 3000;
input double trailing_points       = 1500;
input double lot_size              = 0.1;
input ulong MAGIC_NUMBER           = 123456;

input bool enable_sl_tp            = false;
input bool enable_break_even       = false;
input bool enable_trailing_stop    = false;
input bool enable_candle_filter    = true;
input int operation_mode           = MODE_ALTERNATE;
input bool verbose_log             = true;

CTrendADXMMEStrategy* strategy;

int OnInit()
{
    strategy = new CTrendADXMMEStrategy(
        short_ma_period,
        long_ma_period,
        adx_period,
        adx_threshold,
        stop_loss_points,
        take_profit_points,
        break_even_trigger,
        trailing_points,
        enable_sl_tp,
        enable_break_even,
        enable_trailing_stop,
        enable_candle_filter,
        lot_size,
        MAGIC_NUMBER,
        _Symbol,
        _Period,
        (ENUM_OPERATION_MODE)operation_mode,
        verbose_log
    );

    if (!strategy.Init())
    {
        Print("❌ Strategy failed to initialize");
        delete strategy;
        return INIT_FAILED;
    }

    Print("✅ trend_adx_mme loaded");
    return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
    if (strategy != NULL)
    {
        strategy.Deinit();
        delete strategy;
    }
}

void OnTick()
{
    if (strategy != NULL)
        strategy.OnTick();
}
