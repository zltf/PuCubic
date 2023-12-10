#include "tft_api.h"

static const struct luaL_Reg tftLib[] = {
    {NULL, NULL},
};

int luaopen_tft(lua_State *L)
{
	luaL_newlib(L, tftLib);
	return 1;
}

int luaregister_tft(lua_State *L)
{
	luaL_requiref(L, "tft", luaopen_tft, 1);
	lua_pop(L, 1);
	return 1;
}
