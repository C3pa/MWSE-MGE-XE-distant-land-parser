local ffi = require("ffi")

local half = require("distant land parser.half")
local MaterialProperty = require("distant land parser.propertyHelper.material")
local TexturingProperty = require("distant land parser.propertyHelper.texturing")

local mathDefines = require("distant land parser.defines.math")
local niDefines = require("distant land parser.defines.ni")
local worldFilePath = require("distant land parser.defines.paths").world

ffi.cdef[[
	typedef struct {
		Vector3 location;
		// These are compressed as 16-bit floats
		uint16_t texCoord[2];
	} CompressedVertex;
]]

---@param file file*
---@param struct ffi.ct*
---@param size integer?
local function read(file, struct, size)
	size = size or ffi.sizeof(struct)
	local result = ffi.cast(struct .. "*", file:read(size))
	return result[0]
end

---@param file file*
---@param struct ffi.ct*
---@param length integer
local function readArray(file, struct, length)
	local size = ffi.sizeof(struct) * length
	local src = file:read(size)
	local dst = ffi.new(struct .. "[?]", length)
	ffi.copy(dst, src, size)
	return dst
end

local NiTriShapeDataPtr = ffi.typeof("NiTriShapeData*")
local addressOf = mwse.memory.convertFrom.niObject

---@return niNode
local function parseWorld()
	local root = niNode.new() --[[@as niNode]]
	root.name = "Distant Land"

	local file = assert(io.open(worldFilePath, "rb"))
	local numMeshes = read(file, "unsigned int")
	local texturingProperty = TexturingProperty.new("c:\\users\\vlasnik\\desktop\\staro\\mwse dev\\data files\\distantland\\world.dds")-- "distantland\\world.dds")
	local materialProperty = MaterialProperty.new()

	for i = 1, numMeshes do
		read(file, "BoundingSphere")
		read(file, "BoundingBox")
		local numVertices = read(file, "unsigned int")
		local numTriangles = read(file, "unsigned int")

		local shape = niTriShape.new(numVertices, false, false, 1, numTriangles)
		local data = ffi.cast(NiTriShapeDataPtr, addressOf(shape.data)) --[[@as niTriShapeData]]
		root:attachChild(shape)

		-- Read vertices and texture coordinates
		local vertices = readArray(file, "CompressedVertex", numVertices)
		for j = 0, numVertices - 1 do
			ffi.copy(data.vertices[j], vertices[j].location, ffi.sizeof("Vector3"))
			-- Convert the texture coordinates to floats
			local coords = ffi.new("Vector2") --[[@as worldMap_NiPoint2]]
			coords.x = half.toFloat(vertices[j].texCoord[0])
			coords.y = half.toFloat(vertices[j].texCoord[1])

			ffi.copy(data.texCoords[j], coords, ffi.sizeof("Vector2"))
		end

		-- Read triangles
		if numVertices <= 0xFFFF and numTriangles <= 0xFFFF then
			local size = ffi.sizeof("Triangle") * numTriangles
			ffi.copy(data.triangles, file:read(size), size)
		else
			local triangles = readArray(file, "TriangleLarge", numTriangles)
			for j = 0, numVertices - 1 do
				local src = triangles[j]
				local dst = data.triangles[j]
				dst[0] = src.x
				dst[1] = src.y
				dst[2] = src.z
			end
		end

		-- Label the mesh for easier inspection when exported to a nif file.
		shape.name = tostring(i - 1)
		shape:attachProperty(texturingProperty)
		shape:attachProperty(materialProperty)
		shape.data:updateModelBound()
	end

	file:close()

	root:update()

	return root
end

return parseWorld
