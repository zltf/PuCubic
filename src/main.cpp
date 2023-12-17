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

lua_State *L;

#define USE_CODE_LUA 1
String lua_code = R"(
function setup()
    arduino.log_i("setup")
    arduino.log_i(string.format("content: %s", arduino.read_file("/init.lua")))
    arduino.write_file("/main.lua", 'print("hello")')
    arduino.delete_file("/init.lua")

    local ap_ip = arduino.open_ap("小女警的家", "pupupupu")
    arduino.log_i(string.format("ap_ip %s", ap_ip))
    local wifi_ip = arduino.conn_wifi("3/218-F", "jh589999")
    arduino.log_i(string.format("wifi_ip %s", wifi_ip))
end

function loop()
    --arduino.log_i("loop")
    local ax, ay, az = arduino.get_mpu_info()
    --arduino.log_i(string.format("ms:%d ,ax:%f, ay:%f, az:%f", arduino.millis(), ax, ay, az))
    arduino.delay(1000)
end
)";

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
    #if USE_CODE_LUA
        code = lua_code;
    #endif
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

void setup() {
    delay(2000);
    setCpuFrequencyMhz(240); // 设置主频到最高
    Serial.begin(115200);
    tft_init();
    tf.init();
    mpu_init();
    lua_init();
    run_lua_setup();
}

void loop() {
    run_lua_loop();
}
