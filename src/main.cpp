#include "common.h"

#include "lua_api/arduino_api.h"

static const uint16_t screenWidth  = 240;
static const uint16_t screenHeight = 240;

TFT_eSPI tft = TFT_eSPI(screenWidth, screenHeight);
SdCard tf;
MPU6050 mpu(Wire);
MPUInfo mpuInfo;
SemaphoreHandle_t semaphoreMPUInfo;
WebServer server(80);
HTTPClient httpClient;

lua_State *L;

void lua_init() {
    L = luaL_newstate();
    luaL_openlibs(L);
    luaregister_arduino(L);
    if (L == NULL) {
        log_i("Failed to create Lua state.");
        return;
    }
    String code = tf.readFile("/main.lua");
    log_i("%s", code.c_str());
    int result = luaL_dostring(L, code.c_str());
    if (result != LUA_OK) {
        const char* errorMsg = lua_tostring(L, -1);
        log_i("Error executing script: %s", errorMsg);
        return;
    }
}

void run_lua_setup() {
    lua_getglobal(L, "setup");
    if (!lua_isfunction(L, -1)) {
        log_i("Invalid function type for 'setup'.");
        lua_pop(L, 1);
        return;
    }
    int result = lua_pcall(L, 0, 0, 0);
    if (result != LUA_OK) {
        const char* errorMsg = lua_tostring(L, -1);
        log_i("Error calling Lua function: %s", errorMsg);
        lua_pop(L, 1);
        return;
    }
}

void run_lua_loop() {
    lua_getglobal(L, "loop");
    if (!lua_isfunction(L, -1)) {
        log_i("Invalid function type for 'loop'.");
        lua_pop(L, 1);
        return;
    }
    int result = lua_pcall(L, 0, 0, 0);
    if (result != LUA_OK) {
        const char* errorMsg = lua_tostring(L, -1);
        log_i("Error calling Lua function: %s", errorMsg);
        lua_pop(L, 1);
        return;
    }
}

void tft_init() {
    tft.init();
    tft.fillScreen(TFT_BLACK);
    tft.setRotation(4);
}

void mpuTask(void *param) {
    while(true) {
        if(xSemaphoreTake(semaphoreMPUInfo, portMAX_DELAY)) {
            mpu.update();
            mpuInfo.angleX = mpu.getAngleX();
            mpuInfo.angleY = mpu.getAngleY();
            mpuInfo.angleZ = mpu.getAngleZ();
            xSemaphoreGive(semaphoreMPUInfo);
        }
        delay(5);
    }
}

void mpu_init() {
    Wire.begin(41, 42);
    mpu.begin();
    mpu.calcGyroOffsets();
    semaphoreMPUInfo = xSemaphoreCreateMutex();
    xTaskCreatePinnedToCore(mpuTask, "mpuTask", 4096, NULL, 5, NULL, 1);
}

// void printMemoryInfo() {  
//   int freeMemory;  
//   int totalMemory = ESP.getFreeSketchSpace() - 0x1000; // 减去保留的内存空间  
//   freeMemory = ESP.getFreeHeap();  
//   log_i("Memory Info:");  
//   log_i("Total memory: ");  
//   log_i("%d", totalMemory);  
//   log_i(" bytes");  
//   log_i("Free memory: ");  
//   log_i("%d", freeMemory);  
//   log_i(" bytes");  
//   log_i("Used memory: ");  
//   log_i("%d", totalMemory - freeMemory);  
//   log_i(" bytes");  
// }

void setup() {
    delay(2000);
    setCpuFrequencyMhz(240); // 设置主频到最高
    Serial.begin(115200);
    tft_init();
    tf.init();
    mpu_init();
    lua_init();
    run_lua_setup();
    // printMemoryInfo();
}

void loop() {
    run_lua_loop();
    // printMemoryInfo();
}
