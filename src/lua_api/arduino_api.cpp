#include "arduino_api.h"

static int l_delay(lua_State *L)
{
    lua_Integer ms = lua_tointeger(L, 1);
    delay(ms);
    return 0;
}

static int l_millis(lua_State *L)
{
    int ret = millis();
    lua_pushinteger(L, ret);
    return 1;
}

static int l_log_i(lua_State *L)
{
    const char *msg = lua_tostring(L, 1);
    log_i("%s", msg);
    Serial.flush();
    return 0;
}

static int l_read_file(lua_State *L)
{
    const char *path = lua_tostring(L, 1);
    String ret = tf.readFile(path);
    lua_pushstring(L, ret.c_str());
    return 1;
}

static int l_write_file(lua_State *L)
{
    const char *path = lua_tostring(L, 1);
    const char *content = lua_tostring(L, 2);
    tf.writeFile(path, content);
    return 0;
}

static int l_delete_file(lua_State *L)
{
    const char *path = lua_tostring(L, 1);
    tf.deleteFile(path);
    return 0;
}

static int l_get_mpu_info(lua_State *L)
{
    double angleX, angleY, angleZ;
    if(xSemaphoreTake(semaphoreMPUInfo, portMAX_DELAY)) {
        angleX = mpuInfo.angleX;
        angleY = mpuInfo.angleY;
        angleZ = mpuInfo.angleZ;
        xSemaphoreGive(semaphoreMPUInfo);
    }
    lua_pushnumber(L, angleX);
    lua_pushnumber(L, angleY);
    lua_pushnumber(L, angleZ);
    return 3;
}

static const struct luaL_Reg arduinoLib[] = {
    // misc
    {"delay", l_delay},
    {"millis", l_millis},
    // serial
    {"log_i", l_log_i},
    // file
    {"read_file", l_read_file},
    {"write_file", l_write_file},
    {"delete_file", l_delete_file},
    // mpu
    {"get_mpu_info", l_get_mpu_info},
    {NULL, NULL},
};

int luaopen_arduino(lua_State *L)
{
	luaL_newlib(L, arduinoLib);
	return 1;
}

int luaregister_arduino(lua_State *L)
{
	luaL_requiref(L, "arduino", luaopen_arduino, 1);
	lua_pop(L, 1);
	return 1;
}
