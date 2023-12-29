local ffi = require("ffi")

local half = require("distant land parser.half")
local time = require("distant land parser.parser.time")
local AlphaProperty = require("distant land parser.propertyHelper.alpha")
local MaterialProperty = require("distant land parser.propertyHelper.material")
local TexturingProperty = require("distant land parser.propertyHelper.texturing")

local mathDefines = require("distant land parser.defines.math")
local niDefines = require("distant land parser.defines.ni")
local dlformatDefines = require("distant land parser.defines.dlformat")
local distantlandDefines = require("distant land parser.defines.distantland")
local paths = require("distant land parser.defines.paths")

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

---@param file file*
---@param dst any
---@param length integer
local function readCharArray(file, dst, length)
	ffi.copy(dst, readArray(file, "char", length), length)
end

local NiTriShapeDataPtr = ffi.typeof("NiTriShapeData*")
local addressOf = mwse.memory.convertFrom.niObject

local staticTypeName = {
	[0] = "STATIC_AUTO",
	[1] = "STATIC_NEAR",
	[2] = "STATIC_FAR",
	[3] = "STATIC_VERY_FAR",
	[4] = "STATIC_GRASS",
	[5] = "STATIC_TREE",
	[6] = "STATIC_BUILDING"
}

---@param saveBinary boolean
local function parseStatics(saveBinary)
	local t1 = time()
	local file = assert(io.open(paths.usage_data, "rb"))

	local distantStaticCount = read(file, "uint32_t")
	file:close()
	local file = assert(io.open(paths.static_meshes, "rb"))


	local rootNode = niNode.new()
	rootNode.name = "Root"

	-- This is a 0-indexed table
	---@type niNode[]
	local statics = table.new(distantStaticCount, 0)
	local sizeOfTriange = ffi.sizeof("Triangle")

	for i = 0, distantStaticCount - 1 do
		local numSubsets = read(file, "uint32_t")
		read(file, "BoundingSphere")
		local staticType = read(file, "uint8_t")

		local staticNode = niNode.new()
		staticNode.name = staticTypeName[staticType]

		for j = 0, numSubsets - 1 do
			read(file, "BoundingSphere")
			read(file, "BoundingBox")
			local numVertices = read(file, "uint32_t")
			local numTriangles = read(file, "uint32_t")

			local shape = niTriShape.new(numVertices, false, true, 1, numTriangles)
			local data = ffi.cast(NiTriShapeDataPtr, addressOf(shape.data)) --[[@as niTriShapeData]]

			local vertices = readArray(file, "CompressedVert", numVertices)
			for k = 0, numVertices - 1 do
				local compressed = vertices[k]
				-- Padding should always be 1.0f in 16-bit float, which is 0x3C00
				assert(compressed.padding == 0x3C00, string.format("Expected 0x3C00 padding, got: %s.", compressed.padding))

				local v = data.vertices[k]
				v.x = half.toFloat(compressed.position.x)
				v.y = half.toFloat(compressed.position.y)
				v.z = half.toFloat(compressed.position.z)
				data.colors[k] = compressed.diffuse
				-- TODO: convert normals
				local tc = data.texCoords[k]
				tc.x = half.toFloat(compressed.texCoord[0])
				tc.y = half.toFloat(compressed.texCoord[1])
			end

			local size = sizeOfTriange * numTriangles
			ffi.copy(data.triangles, file:read(size), size)

			-- Handle properties
			local materialProp = MaterialProperty.new({
				emissive = vertices[0].emissiveAverage
			})
			shape:attachProperty(materialProp)

			local hasAlpha = read(file, "bool")
			if hasAlpha then
				local prop = AlphaProperty.new()
				shape:attachProperty(prop)
			end

			local hasUVController = read(file, "bool")
			local pathSize = read(file, "uint16_t")
			local textureName = "textures\\" .. ffi.string(readArray(file, "char", pathSize), pathSize)

			local texturingProp = TexturingProperty.new(textureName)
			shape:attachProperty(texturingProp)
			shape.data:updateModelBound()

			staticNode:attachChild(shape)
		end

		if saveBinary then
			rootNode:attachChild(staticNode)
		end

		statics[i] = staticNode
	end

	file:close()

	if saveBinary then
		rootNode:update()
		rootNode:saveBinary("static_meshes.nif")
	end
	local t2 = time()
	mwse.log("static_meshes parsing successfully finished in: %.2f ms", (t2 - t1) * 1000)
	t1 = time()
	return statics
end

---@param saveBinary boolean
local function parseUsedStatics(saveBinary)
	local t1 = time()
	local statics = parseStatics(false)
	local file = assert(io.open(paths.usage_data, "rb"))

	read(file, "uint32_t") -- distantStaticCount
	local dynamicVisGroupCount = read(file, "uint32_t")

	local visGroups = ffi.new("DynamicVisGroup[?]", dynamicVisGroupCount)
	for i = 0, dynamicVisGroupCount - 1 do
		local visGroup = visGroups[i]
		visGroup.source = read(file, "uint8_t")
		-- readCharArray(file, visGroup.id, 64)
		ffi.copy(visGroup.id, readArray(file, "char", 64), 64)
		visGroup.rangeCount = read(file, "uint8_t")
		-- readCharArray(file, visGroup.ranges, 16)
		ffi.copy(visGroup.ranges, readArray(file, "int32_t", 16), 16)
	end


	local distantStaticsRoot = niNode.new()
	distantStaticsRoot.name = "Root"
	local exteriorRoot = niNode.new()
	exteriorRoot.name = "ExteriorWorldspace"
	distantStaticsRoot:attachChild(exteriorRoot)


	local numReferences = read(file, "uint32_t")
	mwse.log("Exterior references to read: %s", numReferences)

	---@class DistantStaticParserCurrentChunkTable
	---@field counter integer
	---@field child integer
	---@field chunk niNode

	---@type table<string, DistantStaticParserCurrentChunkTable>
	local currentChunk = {}
	for _, staticType in pairs(staticTypeName) do
		local root = niNode.new()
		local name = staticType .. "_ROOT"
		root.name = name
		exteriorRoot:attachChild(root)
		local chunk = niNode.new()
		currentChunk[name] = {
			counter = 0,
			child = 0,
			chunk = chunk
		}
		chunk.name = tostring(currentChunk[name].counter)
		root:attachChild(chunk)
	end

	-- When testing, can reduce this for faster, but incomplete export
	local n = numReferences
	-- local n = 20000

	for i = 1, numReferences do
		-- mwse.log("Parsing used distant static: %s", i)
		local id = read(file, "uint32_t")
		local visIndex = read(file, "uint16_t")

		local static = statics[id]:clone() --[[@as niNode]]
		static.translation.x = read(file, "float")
		static.translation.y = read(file, "float")
		static.translation.z = read(file, "float")
		local rot = tes3matrix33.new()
		rot:fromEulerXYZ(
			read(file, "float"),
			read(file, "float"),
			read(file, "float")
		)

		static.rotation = rot
		static.worldTransform.scale = read(file, "float")

		local name = static.name .."_ROOT"
		local current = currentChunk[name]
		if i < n then
			current.chunk:attachChild(static)
			current.child = current.child + 1
		end

		-- Let's split these under different nodes. This improves the speed of attachChild.
		-- Attaching to the common exteriorRoot can be 2 orders of magnitude slower when
		-- the exteriorRoot has ~ 8000 children
		if (current.child > 0) and (current.child % 200 == 0) then
			current.counter = current.counter + 1
			current.child = 0
			local newchunk = niNode.new()
			newchunk.name = tostring(current.counter)
			current.chunk.parent:attachChild(newchunk)
			current.chunk = newchunk
		end
	end
	local remaining = numReferences - n
	mwse.log("Exterior references read: %s, skipped: %s", n, remaining)

	local interiorsRoot = niNode.new()
	interiorsRoot.name = "InteriorWorldspaces"
	distantStaticsRoot:attachChild(interiorsRoot)
	-- Reading of interior references
	while true do
		local numReferences = read(file, "uint32_t")

		-- Have we reached the terminator? It's 0
		if numReferences <= 0 then
			break
		end
		local cellName = ffi.string(readArray(file, "char", 64), 64)
		-- mwse.log("Reading usage.data for interior cell: \"%s\"", cellName)
		local cellRoot = niNode.new()
		cellRoot.name = cellName
		interiorsRoot:attachChild(cellRoot)

		for i = 1, numReferences do
			local id = read(file, "uint32_t")
			local visIndex = read(file, "uint16_t")
			local static = statics[id]:clone() --[[@as niNode]]
			local pos = tes3vector3.new(
				read(file, "float"),
				read(file, "float"),
				read(file, "float")
			)
			local rot = tes3matrix33.new()
			rot:fromEulerXYZ(
				read(file, "float"),
				read(file, "float"),
				read(file, "float")
			)
			static.translation = pos
			static.rotation = rot
			static.worldTransform.scale = read(file, "float")

			cellRoot:attachChild(static)
		end
	end

	local minStaticSize = read(file, "float")
	mwse.log("minStaticSize: %d", minStaticSize)
	file:close()

	local t2 = time()
	mwse.log("usage.data parsing successfully finished in: %.2f ms", (t2 - t1) * 1000)

	if saveBinary then
		-- local world = tes3.loadMesh("..\\..\\world.nif")
		mwse.log("Exporting Distant Worldspace statics:")
		for _, root in pairs(exteriorRoot.children) do
			-- local r = world:clone()
			-- root:attachChild(r)
			local name = root.name .. ".nif"
			mwse.log(" - Exporting exterior statics to: \"%s\".", name)
			root:saveBinary(name)
		end
		local intName = "InteriorWorldspaces.nif"
		mwse.log(" - Exporting interior statics to: \"%s\".", intName)
		interiorsRoot:saveBinary(intName)
	end

	return distantStaticsRoot
end

return {
	parseStatics = parseStatics,
	parseUsedStatics = parseUsedStatics,
}
