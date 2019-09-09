local Image = require "widgets/image"
local Text = require "widgets/text"
local Widget = require "widgets/widget"

local DEFAULT_ATLAS = "images/inventoryimages.xml"

local NAMES_DEFAULTS = {
	MOON_ALTAR = "MOON_ALTAR",
}

local ItemTile = Class(Widget, function(self, invitem)
		Widget._ctor(self, "ItemTile")
		self.oitem = invitem
		self.item = TOOMANYITEMS.LIST.prefablist[invitem] or invitem
		self.desc = self:DescriptionInit()

		if TOOMANYITEMS.LIST.showimagelist[self.item] or TOOMANYITEMS.DATA.listinuse == "special" or TOOMANYITEMS.DATA.listinuse == "others" then
			self:TrySetImage()
		else
			if self:IsShowImage() then
				self:SetImage()
			else
				self:SetText()
			end
		end

	end)

function ItemTile:SetText()
	self.image = self:AddChild( Image("images/global.xml", "square.tex") )
	self.image:SetTint(0,0,0,.8)

	self.text = self.image:AddChild(Text(BODYTEXTFONT, 36, ""))
	self.text:SetHorizontalSqueeze(.85)
	self.text:SetMultilineTruncatedString(self:GetDescriptionString(), 2, 68, 8, true)
end

function ItemTile:SetImage()
	local atlas, image = self:GetAsset()

	self.image = self:AddChild(Image(atlas, image, "blueprint.tex"))

end

function ItemTile:TrySetImage()
	local atlas, image = self:GetAsset(true)
	self.image = self:AddChild(Image(atlas, image))
	local w,h = self.image:GetSize()
	if math.max(w,h) < 50 then
		self.image:Kill()
		self.image = nil
		self:SetText()
	end
end

function ItemTile:GetAsset(find)
	local itematlas = DEFAULT_ATLAS
	if self.item == nil then
		self.item = ""
	end
	local itemimage = self.item .. ".tex"

	if find then
		if STRINGS.CHARACTER_NAMES[self.item] then
			local character_item = "skull_"..self.item
			itematlas = DEFAULT_ATLAS
			itemimage = character_item .. ".tex"
		elseif AllRecipes[self.item] and AllRecipes[self.item].atlas and AllRecipes[self.item].image then
			itematlas = AllRecipes[self.item].atlas
			itemimage = AllRecipes[self.item].image
		elseif PREFABDEFINITIONS[self.item] then
			for _,asset in ipairs(PREFABDEFINITIONS[self.item].assets) do
				if asset.type == "INV_IMAGE" then
					itemimage = asset.file..'.tex'
				elseif asset.type == "ATLAS" then
					itematlas = asset.file
				end
			end
		end
	end

	return itematlas, itemimage
end

function ItemTile:OnControl(control, down)
	self:UpdateTooltip()
	return false
end

function ItemTile:UpdateTooltip()
	self:SetTooltip(self:GetDescriptionString())
end

function ItemTile:IsShowImage()
	local name = TOOMANYITEMS.DATA.listinuse
	if name == "living" then
		return false
	elseif name == "building" then
		return false
	end
	return true
end

function ItemTile:GetDescriptionString()
	return self.desc
end

function ItemTile:DescriptionInit()
	local str = self.item

	if self.item ~= nil and self.item ~= "" then
		local itemtip = string.upper(self.item)
		if STRINGS.NAMES[itemtip] ~= nil and STRINGS.NAMES[itemtip] ~= "" then
			str = STRINGS.NAMES[itemtip]
		end
	end

	if TOOMANYITEMS.LIST.desclist[self.item] then
		str = TOOMANYITEMS.LIST.desclist[self.item]
	end

	if TOOMANYITEMS.LIST.desclist[self.oitem] then
		str = TOOMANYITEMS.LIST.desclist[self.oitem]
	end
	
	if type(str) == "table" then
		local itemtip = string.upper(self.item)
		if NAMES_DEFAULTS[itemtip] ~= nil then
			str = str[NAMES_DEFAULTS[itemtip]]
		else
			local _, v = next(str)
			str = v
		end
	end

	return str
end

function ItemTile:OnGainFocus()
	self:UpdateTooltip()
end

return ItemTile
