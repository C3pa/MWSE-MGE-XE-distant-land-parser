# Introduction

This module implements conversion functions between IEEE-754 floating point numbers with 16, 32 and 64 bits of precision. For a more detailed description of formats see [Wikipedia article](https://en.wikipedia.org/wiki/IEEE_754) on the format.

# Usage


To use this library in MWSE Lua, the built dll can be dynamically loaded using the `ffi` module.

```lua

local ffi = require("ffi")
ffi.cdef[[
	double half_to_double(const unsigned short x);
	float half_to_float(const unsigned short x);
]]
local h = ffi.load(".\\Data Files\\MWSE\\mods\\World Map\\util\\chalf.dll")

local half = {}

function half.toDouble(half)
	return tonumber(h.half_to_double(half))
end

function half.toFloat(half)
	return h.half_to_float(half)
end

return half
```

# Building

To build this module you will need a C compiler. MSYS2 distribution of GCC is used here.

To start the 32 bit bash on 64 bit Windows run the following command in CMD:
```bat
C:\\msys64\\mingw32.exe bash
```

To compile run the two following commands in bash:
```bat
gcc -c libhalf.c -o libhalf.o
gcc -shared -o libhalf.dll libhalf.o
```
