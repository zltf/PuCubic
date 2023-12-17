#ifndef COMMON_H
#define COMMON_H

#include <TFT_eSPI.h>
#include <MPU6050_light.h>
#include "driver/sd_card.h"

#define GET_SYS_MILLIS xTaskGetTickCount

struct MPUInfo {
    double angleX;
    double angleY;
    double angleZ;
};

extern SdCard tf;
extern TFT_eSPI tft;
extern MPUInfo mpuInfo;
extern SemaphoreHandle_t semaphoreMPUInfo;

#endif
