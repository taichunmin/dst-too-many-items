local ItemSlot = require "widgets/itemslot"

local function SendCommand(fnstr)
	local x, _, z = TheSim:ProjectScreenPos(TheSim:GetPosition())
	local is_valid_time_to_use_remote = TheNet:GetIsClient() and TheNet:GetIsServerAdmin()
	if is_valid_time_to_use_remote then
		TheNet:SendRemoteExecute(fnstr, x, z)
	else
		ExecuteConsoleCommand(fnstr)
	end
end

local function GetCharacter()
	return "UserToPlayer('"..TOOMANYITEMS.CHARACTER_USERID.."')"
end

local InvSlot = Class(ItemSlot, function(self, owner, atlas, bgim, item)
		ItemSlot._ctor(self, atlas, bgim, owner)
		self.owner = owner
		self.item = item
	end)

function InvSlot:OnControl(control, down)
	if InvSlot._base.OnControl(self, control, down) then return true end

	if down then

		if control == CONTROL_ACCEPT then
			self:Click(false)
		elseif control == CONTROL_SECONDARY then
			self:Click(true)
		end

		return true
	end

end

function InvSlot:Click(stack_mod)
	if self.item then
		print ("[TooManyItems] SpawnPrefab: "..self.item)
		if TheInput:IsKeyDown(KEY_CTRL) then
			local specialitems = {}
			if table.contains(TOOMANYITEMS.DATA.specialitems, self.item) then
				for i = 1, #TOOMANYITEMS.DATA.specialitems do
					if TOOMANYITEMS.DATA.specialitems[i] ~= self.item then
						table.insert(specialitems, TOOMANYITEMS.DATA.specialitems[i])
					end
				end
				TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/research_unlock")
			else
				table.insert(specialitems, self.item)
				for i = 1, #TOOMANYITEMS.DATA.specialitems do
					table.insert(specialitems, TOOMANYITEMS.DATA.specialitems[i])
				end
				TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/research_available")
			end
			TOOMANYITEMS.DATA.specialitems = specialitems
			if TOOMANYITEMS.DATA.listinuse == "special" then
				if TOOMANYITEMS.DATA.issearch then
					self.owner:Search()
				else
					self.owner:TryBuild()
				end
			end
			if TOOMANYITEMS.DATA_SAVE == 1 then
				TOOMANYITEMS.SaveNormalData()
			end
		elseif TheInput:IsKeyDown(KEY_SHIFT) then
			local fnstr = 'local player = %s local function tmi_give(item) if player ~= nil and player.Transform then local x,y,z = player.Transform:GetWorldPosition() if item ~= nil and item.components then if item.components.inventoryitem ~= nil then if player.components and player.components.inventory then player.components.inventory:GiveItem(item) end else item.Transform:SetPosition(x,y,z) end end end end local function tmi_mat(name) local recipe = AllRecipes[name] if recipe then for _, iv in pairs(recipe.ingredients) do for i = 1, iv.amount do local item = SpawnPrefab(iv.type) tmi_give(item) end end end end for i = 1, %s or 1 do tmi_mat("%s") end'
			SendCommand(string.format(fnstr, GetCharacter(), stack_mod and TOOMANYITEMS.R_CLICK_NUM or TOOMANYITEMS.L_CLICK_NUM, self.item))
			TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_object")
		else
			local fnstr = "local player = %s if player ~= nil and player.Transform then local x,y,z = player.Transform:GetWorldPosition() for i = 1, %s or 1 do local inst = SpawnPrefab('%s') if inst ~= nil and inst.components then if inst.components.inventoryitem ~= nil then if player.components and player.components.inventory then player.components.inventory:GiveItem(inst) end else inst.Transform:SetPosition(x,y,z) end end end end"
			SendCommand(string.format(fnstr, GetCharacter(), stack_mod and TOOMANYITEMS.R_CLICK_NUM or TOOMANYITEMS.L_CLICK_NUM, self.item))
			TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_object")
		end
	end

end

return InvSlot
