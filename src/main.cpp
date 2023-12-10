#include "common.h"

#include "lua_api/arduino_api.h"

static const uint16_t screenWidth  = 240;
static const uint16_t screenHeight = 240;

TFT_eSPI tft = TFT_eSPI(screenWidth, screenHeight);
SdCard tf;
IMU mpu;
ImuAction act_info;

lua_State *L;

#define USE_CODE_LUA 1
String lua_code = R"(
function setup()
    arduino.log_i("setup")
    arduino.log_i(string.format("content: %s", arduino.read_file("/init.lua")))
    arduino.write_file("/main.lua", 'print("hello")')
    arduino.delete_file("/init.lua")
end

function loop()
    -- arduino.log_i("loop")
    local ax, ay, az, gx, gy, gz = arduino.get_mpu_info()
    arduino.log_i(string.format("ms:%d ,ax:%d, ay:%d, az:%d, gx:%d, gy:%d, gz:%d", arduino.millis(), ax, ay, az, gx, gy, gz))
    arduino.delay(200)
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

void mpu_init() {
    SysMpuConfig sys_mpu_config = {0, 0, 0, 0, 0, 0};
    mpu.init(4, 1, &sys_mpu_config);
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
