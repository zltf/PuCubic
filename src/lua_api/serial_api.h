extern "C" {
    #include "lua.h"
    #include "lualib.h"
    #include "lauxlib.h"
}

#include "Arduino.h"

int luaregister_serial(lua_State *L);
