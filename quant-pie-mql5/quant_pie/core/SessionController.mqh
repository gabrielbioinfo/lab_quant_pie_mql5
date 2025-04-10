// === SessionController.mqh ===
#ifndef __SESSION_CONTROLLER_MQH__
#define __SESSION_CONTROLLER_MQH__

class CSessionController
{
protected:
    int start_hour;
    int end_hour;
    bool restrict_weekend;

public:
    CSessionController(int _start_hour, int _end_hour, bool _restrict_weekend = true)
    {
        start_hour = _start_hour;
        end_hour = _end_hour;
        restrict_weekend = _restrict_weekend;
    }

    bool IsWithinSession()
    {
        datetime now = TimeCurrent();
        MqlDateTime tm;
        TimeToStruct(now, tm);

        int hour = tm.hour;
        int day  = tm.day_of_week;

        if (restrict_weekend && (day == 0 || day == 6)) // Sunday or Saturday
            return false;

        return hour >= start_hour && hour < end_hour;
    }
};

#endif // __SESSION_CONTROLLER_MQH__
