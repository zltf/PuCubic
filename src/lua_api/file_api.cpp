#include "file_api.h"

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

static const struct luaL_Reg fileLib[] = {
    {"read_file", l_read_file},
    {"write_file", l_write_file},
    {"delete_file", l_delete_file},
    {NULL, NULL},
};

int luaopen_file(lua_State *L)
{
	luaL_newlib(L, fileLib);
	return 1;
}

int luaregister_file(lua_State *L)
{
	luaL_requiref(L, "file", luaopen_file, 1);
	lua_pop(L, 1);
	return 1;
}
