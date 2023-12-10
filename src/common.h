#include <TFT_eSPI.h>
#include "driver/sd_card.h"
#include "driver/imu.h"

#define GET_SYS_MILLIS xTaskGetTickCount

extern SdCard tf;
extern TFT_eSPI tft;
extern IMU mpu;
extern ImuAction act_info;

boolean doDelayMillisTime(unsigned long interval,
                          unsigned long *previousMillis,
                          boolean state);
