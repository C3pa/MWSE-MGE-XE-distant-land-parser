local ffi = require("ffi")

ffi.cdef[[
	typedef struct {
		int32_t begin;
		int32_t end;
	} Range;

	typedef struct {
		uint8_t source;
		char id[64];
		uint8_t rangeCount;
		Range ranges[8];
	} DynamicVisGroup;
]]
