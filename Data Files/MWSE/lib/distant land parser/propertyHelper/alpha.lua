local bit = require("bit")

local alphaBlendEnable = 0x01
local GL_SRC_ALPHA = 0x0C
local GL_NEVER = 0xE0

local alphaFlags = bit.bor(
	alphaBlendEnable,
	GL_SRC_ALPHA,
	GL_NEVER
)

---@type niAlphaProperty
local alphaProp

local this = {}

function this.new()
	if not alphaProp then
		alphaProp = niAlphaProperty.new()
		alphaProp.propertyFlags = alphaFlags
	end
	return alphaProp
end

return this
