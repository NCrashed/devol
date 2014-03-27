/**
*   Copyright: © 2012-2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module ant.util;

/// fromStringz
/**
*   Returns new string formed from C-style (null-terminated) string $(D msg). Usefull
*   when interfacing with C libraries. For D-style to C-style convertion use std.string.toStringz
*
*   Example:
*   ----------
*   char[] cstring = "some string".dup ~ cast(char)0;
*
*   assert(fromStringz(cstring.ptr) == "some string");
*   ----------
*/
string fromStringz(const char* msg) nothrow
{
    try
    {
        if(msg is null) return "";

        auto buff = new char[0];
        uint i = 0;
            while(msg[i]!=cast(char)0)
                buff ~= msg[i++];
        return buff.idup;
    } catch(Exception e)
    {
        return "";
    }
}

unittest
{
    char[] cstring = "some string".dup ~ cast(char)0;

    assert(fromStringz(cstring.ptr) == "some string");
}
