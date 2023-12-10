#include "serial_api.h"

static int l_log_i(lua_State *L)
{
    const char *msg = lua_tostring(L, 1);
    log_i("%s", msg);
    Serial.flush();
    return 0;
}

static const struct luaL_Reg serialLib[] = {
    {"log_i", l_log_i},
    {NULL, NULL},
};

int luaopen_serial(lua_State *L)
{
	luaL_newlib(L, serialLib);
	return 1;
}

int luaregister_serial(lua_State *L)
{
	luaL_requiref(L, "serial", luaopen_serial, 1);
	lua_pop(L, 1);
	return 1;
}
