extern "C" {
    #include "lua.h"
    #include "lualib.h"
    #include "lauxlib.h"
}

#include "Arduino.h"
#include "common.h"

int luaregister_file(lua_State *L);
