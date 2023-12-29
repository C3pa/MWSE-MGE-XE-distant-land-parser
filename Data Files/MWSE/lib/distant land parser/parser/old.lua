local ffi = require("ffi")
ffi.cdef[[
	// UsedDistantStatic
	typedef struct {
		uint32_t id;
		uint16_t visIndex;
		Vector3 location;
		// yaw, pitch, roll
		Vector3 rotation;
		float scale;
	} Reference; // Size: 34

	typedef struct {
		uint32_t numReferences;
		Reference* references;
	} Exterior;

	typedef struct {
		uint32_t numReferences;
		char cellName[64];
		Reference* references;
	} Interior;

	void* malloc(size_t _Size);
	void free(void *_Memory);
]]

-- local exterior = ffi.new("Exterior")
-- local R = ffi.C.malloc(ffi.sizeof("Reference", exterior.numReferences))
-- exterior.references = ffi.C.malloc(ffi.sizeof("Reference", exterior.numReferences))
-- exterior.references = ffi.cast("Reference*", R)
-- ffi.gc(exterior.references, ffi.C.free)