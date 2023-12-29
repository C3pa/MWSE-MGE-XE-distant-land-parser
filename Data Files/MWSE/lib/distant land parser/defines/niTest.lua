local ffi = require("ffi")

local mathDefines = require("distant land parser.defines.math")


ffi.cdef[[
	typedef struct {
		Vector3 m0;
		Vector3 m1;
		Vector3 m2;
	} NiMatrix33;

	typedef struct {
		NiMatrix33 rotation;
		Vector3 translation;
		float scale;
	} NiTransform;

	typedef struct {
		Vector3 center;
		float radius;
	} NiBound;

	typedef struct {
		unsigned char b;
		unsigned char g;
		unsigned char r;
		unsigned char a;
	} NiPackedColor;

	typedef struct {
		void* vTable
		int refCount;
	} NiObject;

	typedef struct {
		NiObject super;
		unsigned short vertexCount;
		unsigned short textureSets;
		NiBound bounds;
		Vector3* vertex;
		Vector3* normal;
		NiPackedColor* color;
		Vector2* textureCoords;
		unsigned int uniqueID;
		unsigned short revisionID;
		bool unknown_0x32;
	} NiGeometryData;

	typedef struct {
		NiGeometryData super;
		unsigned short triangleCount;
	} TriBasedGeometryData;

	typedef struct {
		TriBasedGeometryData super;
		unsigned int triangleListLength;
		Triange* triangleList;
		void* sharedNormals;
		unsigned short sharedNormalsArraySize;
	} NiTriShapeData;

	typedef struct {
		void* vTable;
		int refCount;
		unsigned short vertexCount;
		unsigned short textureSets;
		Vector3 center;
		float radius;
		Vector3* vertex;
		Vector3* normal;
		void* color;
		Vector2* textureCoords;
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
