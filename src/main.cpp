#include "common.h"

#include "lua_api/tft_api.h"
#include "lua_api/serial_api.h"
#include "lua_api/file_api.h"

static const uint16_t screenWidth  = 240;
static const uint16_t screenHeight = 240;

TFT_eSPI tft = TFT_eSPI(screenWidth, screenHeight);
SdCard tf;

uint16_t img[240 * 240];

lua_State *L;

#define USE_CODE_LUA 1
String lua_code = R"(
function setup()
    serial.log_i("setup")
    serial.log_i(string.format("content: %s", file.read_file("/init.lua")))
    file.write_file("/main.lua", 'print("hello")')
    file.delete_file("/init.lua")
end

function loop()
    -- serial.log_i("loop")
end
)";

void lua_init() {
    L = luaL_newstate();
    luaL_openlibs(L);
    luaregister_tft(L);
    luaregister_serial(L);
    luaregister_file(L);
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

void setup() {
    delay(2000);

    tf.init();
    lua_init();
    tft.init();
    tft.fillScreen(TFT_BLACK);
    Serial.begin(115200);

    run_lua_setup();
}

void loop() {
    run_lua_loop();
}
