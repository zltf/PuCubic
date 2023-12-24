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

static int l_restart(lua_State *L)
{
    ESP.restart();
    return 0;
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

static int l_list_file(lua_State *L)
{
    const char *path = lua_tostring(L, 1);
    lua_pushstring(L, tf.listDir(path, 0).c_str());
    return 1;
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

static int l_web_on(lua_State *L)
{
    const char *route = lua_tostring(L, 1);
    const char *callback = lua_tostring(L, 2);

    char *destination = (char *)malloc(strlen(callback) + 1);
    if (destination == NULL) {
        log_i("l_web_on malloc error");
        return 0;
    }  
    strcpy(destination, callback);  
    server.on(route, [L, destination] () {
        int result = luaL_dostring(L, destination);
        if (result != LUA_OK) {
            const char* errorMsg = lua_tostring(L, -1);
            log_i("Error executing script: %s", errorMsg);
        }
    });
    return 0;
}

static int l_web_begin(lua_State *L)
{
    server.begin();
    return 0;
}

static int l_web_arg(lua_State *L)
{
    const char *name = lua_tostring(L, 1);
    String value = server.arg(name);
    lua_pushstring(L, value.c_str());
    return 1;
}

static int l_web_send(lua_State *L)
{
    lua_Integer code = lua_tointeger(L, 1);
    const char *content_type = lua_tostring(L, 2);
    const char *content = lua_tostring(L, 3);
    server.send(code, content_type, content);
    return 0;
}

static int l_web_loop(lua_State *L)
{
    server.handleClient();
    return 0;
}

static int l_web_post(lua_State *L)
{
    const char *url = lua_tostring(L, 1);
    const char *json = lua_tostring(L, 2);
    httpClient.begin(url);
    httpClient.addHeader("Content-Type", "application/json");
    int httpResponseCode = httpClient.POST(json);
    if (httpResponseCode <= 0) {
        log_i("Error sending data. Error code: %s", String(httpResponseCode));
    }
    lua_pushinteger(L, httpResponseCode);
    lua_pushstring(L, httpClient.getString().c_str());
    httpClient.end();
    return 2;
}

static int l_tft_img(lua_State *L)
{
    lua_Integer x = lua_tointeger(L, 1);
    lua_Integer y = lua_tointeger(L, 2);
    lua_Integer w = lua_tointeger(L, 3);
    lua_Integer h = lua_tointeger(L, 4);
    uint16_t img[w * h];
    for(int i = 0; i < w * h; i++) {
        lua_geti(L, 5, i + 1);
        img[i] = lua_tointeger(L, -1);
        lua_pop(L, 1);
    }
    tft.pushImage(x, y, w, h, img);
    return 0;
}

static int l_tft_img_string(lua_State *L)
{
    const char *str = lua_tostring(L, 1);
    lua_Integer x = lua_tointeger(L, 2);
    lua_Integer y = lua_tointeger(L, 3);
    lua_Integer font = lua_tointeger(L, 4);
    int ret = tft.drawString(str, x, y, font);
    lua_pushinteger(L, ret);
    return 1;
}

static int l_tft_fill(lua_State *L)
{
    lua_Integer x = lua_tointeger(L, 1);
    lua_Integer y = lua_tointeger(L, 2);
    lua_Integer w = lua_tointeger(L, 3);
    lua_Integer h = lua_tointeger(L, 4);
    lua_Integer color = lua_tointeger(L, 5);
    tft.fillRect(x, y, w, h, color);
    return 0;
}

static int l_time_set(lua_State *L)
{
    lua_Integer yr = lua_tointeger(L, 1);
    lua_Integer mt = lua_tointeger(L, 2);
    lua_Integer dy = lua_tointeger(L, 3);
    lua_Integer hr = lua_tointeger(L, 4);
    lua_Integer mn = lua_tointeger(L, 5);
    lua_Integer sc = lua_tointeger(L, 6);
    rtc.setTime(sc, mn, hr, dy, mt, yr);
    return 0;
}

static int l_time_get(lua_State *L)
{
    lua_pushinteger(L, rtc.getYear());
    lua_pushinteger(L, rtc.getMonth() + 1);
    lua_pushinteger(L, rtc.getDay());
    lua_pushinteger(L, rtc.getHour(true));
    lua_pushinteger(L, rtc.getMinute());
    lua_pushinteger(L, rtc.getSecond());
    return 6;
}

static const struct luaL_Reg arduinoLib[] = {
    // misc
    {"delay", l_delay},
    {"millis", l_millis},
    {"restart", l_restart},
    // serial
    {"log_i", l_log_i},
    // file
    {"read_file", l_read_file},
    {"write_file", l_write_file},
    {"delete_file", l_delete_file},
    {"list_file", l_list_file},
    // mpu
    {"get_mpu_info", l_get_mpu_info},
    // wifi
    {"open_ap", l_open_ap},
    {"conn_wifi", l_conn_wifi},
    // web
    {"web_on", l_web_on},
    {"web_begin", l_web_begin},
    {"web_arg", l_web_arg},
    {"web_send", l_web_send},
    {"web_loop", l_web_loop},
    {"web_post", l_web_post},
    // tft
    {"tft_img", l_tft_img},
    {"tft_string", l_tft_img_string},
    {"tft_fill", l_tft_fill},
    // time
    {"time_set", l_time_set},
    {"time_get", l_time_get},
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
