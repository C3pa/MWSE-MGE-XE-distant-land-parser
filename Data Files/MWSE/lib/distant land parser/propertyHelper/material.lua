local this = {}

---@type niMaterialProperty
local materialProperty

---@class DistantLandParserMaterialProperty.create.params.color
---@field b number
---@field g number
---@field r number

---@class DistantLandParserMaterialProperty.create.params
---@field alpha number?
---@field diffuse DistantLandParserMaterialProperty.create.params.color?
---@field emissive number? Average emissive color.

---@param color niColor
---@param new DistantLandParserMaterialProperty.create.params.color
local function setColor(color, new)
	color.b = new.b
	color.g = new.b
	color.r = new.r
end

---@nodiscard
---@param params DistantLandParserMaterialProperty.create.params?
---@return niMaterialProperty
function this.new(params)
	params = params or {}
	materialProperty = materialProperty or
						tes3.loadMesh("m\\misc_com_tankard_01.nif"):clone().children[1].materialProperty
	assert(materialProperty ~= nil, "Couldn't get any niMaterialProperty!")
	local prop = materialProperty:clone()
	if params.alpha then
		prop.alpha = params.alpha
	end
	if params.diffuse then
		setColor(prop.diffuse, params.diffuse)
	end
	if params.emissive then
		setColor(prop.emissive, {
			b = params.emissive,
			g = params.emissive,
			r = params.emissive,
		})
	end

	return prop
end

return this
