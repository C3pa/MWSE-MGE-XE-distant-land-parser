local this = {}

---@type niTexturingProperty
local texturingProperty

---@nodiscard
---@param path string Relative to `Data Files\\`. Needs to include the file extension.
---@return niTexturingProperty
function this.new(path)
	local sourceTexture = niSourceTexture.createFromPath(path)
	local map = niTexturingPropertyMap.new({
		texture = sourceTexture,
		-- clampMode = ni.texturingPropertyClampMode.clampSclampT
	})
	texturingProperty = texturingProperty or
						tes3.loadMesh("m\\misc_com_tankard_01.nif"):clone().children[1].texturingProperty
	assert(texturingProperty ~= nil, "Couldn't get any niTexturingProperty!")
	local textureProp = texturingProperty:clone()
	textureProp.baseMap = map

	return textureProp
end

return this
