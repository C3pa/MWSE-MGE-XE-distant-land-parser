local ffi = require("ffi")

local mathDefines = require("distant land parser.defines.math")


ffi.cdef[[
	typedef struct {
		uint8_t b;
		uint8_t g;
		uint8_t r;
		uint8_t a;
	} NiPackedColor;

	typedef struct {
		void* vtable;
		int refCount;
		unsigned short vertexCount;
		unsigned short textureSets;
		Vector3 center;
		float radius;
		Vector3* vertices;
		Vector3* normal;
		NiPackedColor* colors;
		Vector2* texCoords;
		unsigned int uniqueID;
		unsigned short revisionID;
		char padding[2];
		unsigned short triangleCount;
		unsigned int triangleListLength;
		Triangle* triangles;
		void* sharedNormals;
		unsigned short sharedNormalsArraySize;
	} NiTriShapeData;
]]
