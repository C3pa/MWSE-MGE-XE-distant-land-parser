
local ffi = require("ffi")

ffi.cdef[[
	double half_to_double(const unsigned short x);
	float half_to_float(const unsigned short x);
	unsigned short float_to_half(const float x);
	unsigned short double_to_half(const double x);
]]
local h = ffi.load(".\\Data Files\\MWSE\\lib\\distant land parser\\half\\libhalf.dll")

local half = {}

function half.toDouble(half)
	-- TODO check if tonumber is necessary
	return tonumber(h.half_to_double(half))
end

function half.fromDouble(double)
	return h.double_to_half(double)
end

function half.toFloat(half)
	return h.half_to_float(half)
end

function half.fromFloat(float)
	return h.float_to_half(float)
end

return half
