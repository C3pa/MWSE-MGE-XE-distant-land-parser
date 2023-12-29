local ffi = require("ffi")

local statics = require("distant land parser.parser.statics")
local parseWorld = require("distant land parser.parser.world")
local paths = require("distant land parser.defines.paths")

local supportedDistantLandVersion = 7

local function checkVersion()
	local versionFile = assert(io.open(paths.version, "rb"))
	local version = ffi.cast("uint8_t*", versionFile:read(1))[0]
	versionFile:close()
	if version < supportedDistantLandVersion then
		error("[Distant Land Parser]: Distant land version is too old. Please update your MGE XE installation.")
	elseif version > supportedDistantLandVersion then
		error("[Distant Land Parser]: Unsupported distant land version. Try updating your installation of Distant Land Parser.")
	end
end

checkVersion()

local this = {}

function this.parseLand()
	return parseWorld()
end

---@param saveBinary boolean
---@return niNode
function this.parseStatic(saveBinary)
	return statics.parseUsedStatics(saveBinary)
end

---@param saveBinary boolean
---@return DistantLandParserStaticTableEntry[]
function this.parseStaticMeshes(saveBinary)
	return statics.parseStatics(saveBinary)
end

return this
