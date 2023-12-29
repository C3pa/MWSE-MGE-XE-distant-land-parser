local ffi = require("ffi")

local mathDefines = require("distant land parser.defines.math")
local niDefines = require("distant land parser.defines.ni")

ffi.cdef[[

	typedef struct {
		HalfVector3 position;
		// Compressed as 16-bit float
		uint16_t padding;
		uint8_t normal[3];
		uint8_t emissiveAverage;
		NiPackedColor diffuse;
		// These are compressed as 16-bit floats
		uint16_t texCoord[2];
	} CompressedVert;
]]

--[[
	typedef struct {
		BoundingSphere boundingSphere;
		BoundingBox boundingBox;
		uint32_t numVertices;
		uint32_t numTriangles;
		CompressedVert* vertices;
		Triangle* triangles;
		bool alphaEnabled;
		bool hasUVController;
		uint16_t pathSize;
		char* textureName;
	} Subset;

	typedef struct {
		uint32_t numSubsets;
		BoundingSphere boundingSphere;
		uint8_t staticType;
		Subset* subsets;
	} DistantStatic;
]]
