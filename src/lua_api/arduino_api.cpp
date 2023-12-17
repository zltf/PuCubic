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

static int l_open_ap(lua_State *L)
{
    const char *ssid = lua_tostring(L, 1);
    const char *pwd = lua_tostring(L, 2);

    IPAddress local_ip(192, 168, 4, 2);
    IPAddress gateway(192, 168, 4, 2);
    IPAddress subnet(255, 255, 255, 0);

    WiFi.enableAP(true);
    WiFi.softAP(ssid, pwd);
    WiFi.softAPConfig(local_ip, gateway, subnet);

    lua_pushstring(L, WiFi.softAPIP().toString().c_str());
    return 1;
}

static int l_conn_wifi(lua_State *L)
{
    const char *ssid = lua_tostring(L, 1);
    const char *pwd = lua_tostring(L, 2);

    WiFi.enableSTA(true);
    WiFi.setSleep(false);
    WiFi.begin(ssid, pwd);

    while(WiFi.status() != WL_CONNECTED) {
        delay(500);
    }

    lua_pushstring(L, WiFi.localIP().toString().c_str());
    return 1;
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
    // wifi
    {"open_ap", l_open_ap},
    {"conn_wifi", l_conn_wifi},
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
