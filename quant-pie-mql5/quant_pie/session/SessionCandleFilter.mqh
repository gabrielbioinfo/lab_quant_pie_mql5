// === SessionCandleFilter.mqh ===
#ifndef __SESSION_CANDLE_FILTER_MQH__
#define __SESSION_CANDLE_FILTER_MQH__

class CSimpleCandleFilter
{
private:
    datetime last_candle_time;
    bool enabled;

public:
    CSimpleCandleFilter(bool _enabled = true) {
        last_candle_time = 0;
        enabled = _enabled;
    }

    void SetEnabled(bool value) {
        enabled = value;
    }

    bool IsNewCandle()
    {
        if (!enabled)
            return true;

        datetime times[];
        if (CopyTime(_Symbol, _Period, 1, 1, times) <= 0)
            return false;

        datetime candle_time = times[0];

        if (candle_time != last_candle_time) {
            last_candle_time = candle_time;
            return true;
        }

        return false;
    }
};

#endif // __SESSION_CANDLE_FILTER_MQH__
