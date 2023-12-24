#ifndef COMMON_H
#define COMMON_H

#include "Arduino.h"
#include "TFT_eSPI.h"
#include "MPU6050_light.h"
#include "WebServer.h"
#include "WiFi.h"
#include "HTTPClient.h"
#include "driver/sd_card.h"
#include "ESP32Time.h"

struct MPUInfo {
    double angleX;
    double angleY;
    double angleZ;
};

extern SdCard tf;
extern TFT_eSPI tft;
extern MPUInfo mpuInfo;
extern SemaphoreHandle_t semaphoreMPUInfo;
extern WebServer server;
extern HTTPClient httpClient;
extern ESP32Time rtc;

#endif
