local ffi = require("ffi")

ffi.cdef[[
	typedef struct {
		float x;
		float y;
	} Vector2;

	// These are compressed as 16-bit floats
	typedef struct {
		uint16_t x;
		uint16_t y;
		uint16_t z;
	} HalfVector3;

	typedef struct {
		float x;
		float y;
		float z;
	} Vector3;

	typedef struct {
		uint32_t x;
		uint32_t y;
		uint32_t z;
	} TriangleLarge;

	typedef struct {
		uint16_t x;
		uint16_t y;
		uint16_t z;
	} Triangle;

	typedef struct {
		Vector3 min;
		Vector3 max;
	} BoundingBox;

	typedef struct {
		float radius;
		Vector3 center;
	} BoundingSphere;
]]
