extern "C" {
    #include "lua.h"
    #include "lualib.h"
    #include "lauxlib.h"
}

#include "Arduino.h"
#include "common.h"

int luaregister_arduino(lua_State *L);
