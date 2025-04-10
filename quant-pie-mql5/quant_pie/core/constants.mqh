// === constants.mqh ===
#ifndef __CONSTANTS_MQH__
#define __CONSTANTS_MQH__

// Define operation modes for strategy behavior
enum ENUM_OPERATION_MODE
{
    MODE_ALTERNATE = 0,   // Buy/Sell alternated
    MODE_ONLY_BUY = 1,    // Only Buy allowed
    MODE_ONLY_SELL = 2    // Only Sell allowed
};

#endif // __CONSTANTS_MQH__
