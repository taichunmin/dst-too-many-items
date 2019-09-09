local Image = require "widgets/image"
local Text = require "widgets/text"
local TextButton = require "widgets/textbutton"
local Widget = require "widgets/widget"

local SearchScreen = require "screens/TMI_searchscreen"
local TMI_inventorybar = require "widgets/TMI_inventorybar"
local TMI_Menu = require "TMI/menu"

local function GetPrettyStr(str)
	return string.lower(TrimString(str))
end

local TMI_Menubar = Class(Widget, function(self, owner)
		Widget._ctor(self, "TMI_Menubar")
		self.owner = owner
		self:Init()
	end)

function TMI_Menubar:Init()
	self:InitSidebar()
	self:InitSearch()
	self:InitMenu()
	local function SetPage(currentpage, maxpages)
		self.pagetext:SetString(currentpage.." / "..maxpages)
		if currentpage <= 1 then
			self.TMI_Menu.mainbuttons["prevbutton"]:Hide()
		else
			self.TMI_Menu.mainbuttons["prevbutton"]:Show()
		end

		if currentpage >= maxpages then
			self.TMI_Menu.mainbuttons["nextbutton"]:Hide()
		else
			self.TMI_Menu.mainbuttons["nextbutton"]:Show()
		end
	end

	self.inventory = self:AddChild(TMI_inventorybar(SetPage))
	self:LoadSearchData()
end

function TMI_Menubar:InitMenu()
	local fontsize = 36
	local spacing = 40
	local left = self.sidebar_width - self.owner.shieldsize_x * .5 + 20
	local right = self.owner.shieldsize_x * .5 - 20
	local mid = self.sidebar_width * .5
	local pos = {
		left,
		left + spacing,
		left + spacing * 2,
		mid - spacing * .5,
		mid + spacing * .5,
		right - spacing * 2,
		right - spacing,
		right,
	}

	self.TMI_Menu = TMI_Menu(self, pos)

	self.pagetext = self:AddChild(Text(NEWFONT_OUTLINE, fontsize))
	self.pagetext:SetString("1 / 2")
	-- self.pagetext:SetTooltip("Current Page/Max Pages")
	self.pagetext:SetColour(1,1,1,0.6)
	self.pagetext:SetPosition(mid, -218, 0)
end

function TMI_Menubar:InitSidebar()
	self.sidebar_width = 0
	self.sidebarlists = {
		{
			show = STRINGS.TOO_MANY_ITEMS_UI.SIDEBAR_S,
			tip = STRINGS.TOO_MANY_ITEMS_UI.SIDEBAR_TIPS,
			fn = self:GetSideButtonFn("special"),
		},
		{
			show = STRINGS.TOO_MANY_ITEMS_UI.SIDEBAR_A,
			tip = STRINGS.TOO_MANY_ITEMS_UI.SIDEBAR_TIPA,
			fn = self:GetSideButtonFn("all"),
		},
		{
			show = STRINGS.TOO_MANY_ITEMS_UI.SIDEBAR_F,
			tip = STRINGS.TOO_MANY_ITEMS_UI.SIDEBAR_TIPF,
			fn = self:GetSideButtonFn("food"),
		},
		{
			show = STRINGS.TOO_MANY_ITEMS_UI.SIDEBAR_R,
			tip = STRINGS.TOO_MANY_ITEMS_UI.SIDEBAR_TIPR,
			fn = self:GetSideButtonFn("resource"),
		},
		{
			show = STRINGS.TOO_MANY_ITEMS_UI.SIDEBAR_W,
			tip = STRINGS.TOO_MANY_ITEMS_UI.SIDEBAR_TIPW,
			fn = self:GetSideButtonFn("weapon"),
		},
		{
			show = STRINGS.TOO_MANY_ITEMS_UI.SIDEBAR_T,
			tip = STRINGS.TOO_MANY_ITEMS_UI.SIDEBAR_TIPT,
			fn = self:GetSideButtonFn("tool"),
		},
		{
			show = STRINGS.TOO_MANY_ITEMS_UI.SIDEBAR_C,
			tip = STRINGS.TOO_MANY_ITEMS_UI.SIDEBAR_TIPC,
			fn = self:GetSideButtonFn("clothe"),
		},
		{
			show = STRINGS.TOO_MANY_ITEMS_UI.SIDEBAR_G,
			tip = STRINGS.TOO_MANY_ITEMS_UI.SIDEBAR_TIPG,
			fn = self:GetSideButtonFn("gift"),
		},
		{
			show = STRINGS.TOO_MANY_ITEMS_UI.SIDEBAR_L,
			tip = STRINGS.TOO_MANY_ITEMS_UI.SIDEBAR_TIPL,
			fn = self:GetSideButtonFn("living"),
		},
		{
			show = STRINGS.TOO_MANY_ITEMS_UI.SIDEBAR_B,
			tip = STRINGS.TOO_MANY_ITEMS_UI.SIDEBAR_TIPB,
			fn = self:GetSideButtonFn("building"),
		},
		{
			show = STRINGS.TOO_MANY_ITEMS_UI.SIDEBAR_O,
			tip = STRINGS.TOO_MANY_ITEMS_UI.SIDEBAR_TIPO,
			fn = self:GetSideButtonFn("others"),
		},
	}

	local function MakeSidebar(buttonlist)
		local fontsize = 26
		local left = -self.owner.shieldsize_x * .5
		local spacing = 18.5
		local top = self.owner.shieldsize_y * .5

		for i = 1, #buttonlist do
			local button = self:AddChild(TextButton())
			button:SetFont(NEWFONT)
			button:SetText(buttonlist[i].show)
			button:SetTooltip(buttonlist[i].tip)
			button:SetTextSize(fontsize)
			button:SetColour(0.9,0.8,0.6,1)
			button:SetOnClick(buttonlist[i].fn)

			local width, height = button.text:GetRegionSize()
			button.image:SetSize(width * 0.9, height)
			if width > self.sidebar_width then
				self.sidebar_width = width
			end

			button:SetPosition(left + width * .5, top - height * .5, 0)
			top = top - height - spacing
		end
	end
	MakeSidebar(self.sidebarlists)
end

function TMI_Menubar:GetSideButtonFn(name)
	return function()
		TOOMANYITEMS.DATA.listinuse = name
		TOOMANYITEMS.DATA.issearch = false
		self:ShowNormal()
		self:SaveData()
	end
end

function TMI_Menubar:ShowNormal()
	self.inventory:TryBuild()
end

function TMI_Menubar:ShowSearch()
	TOOMANYITEMS.DATA.issearch = true
	self.inventory.currentpage = 1
	self.inventory:TryBuild()
end

function TMI_Menubar:InitSearch()
	self.searchbar_width = self.owner.shieldsize_x - self.sidebar_width
	self.search_fontsize = 30

	self.searchshield = self:AddChild( Image("images/ui.xml", "black.tex") )
	self.searchshield:SetScale(1,1,1)
	self.searchshield:SetTint(1,1,1,.2)
	self.searchshield:SetSize(self.searchbar_width, self.search_fontsize)
	self.searchshield:SetPosition(self.sidebar_width - self.sidebar_width * .5, self.owner.shieldsize_y * .5 - self.search_fontsize * .5, 0)

	self.searchbarbutton = self.searchshield:AddChild(TextButton())
	self.searchbarbutton:SetFont(NEWFONT)
	self.searchbarbutton:SetTextSize(self.search_fontsize)
	self.searchbarbutton:SetColour(0.9,0.8,0.6,1)
	self.searchbarbutton:SetText(STRINGS.TOO_MANY_ITEMS_UI.SEARCH_TEXT)
	self.searchbarbutton:SetTooltip(STRINGS.TOO_MANY_ITEMS_UI.SEARCH_TIP)
	self.searchbarbutton:SetOnClick( function() self:Search(TOOMANYITEMS.DATA.search) end)
	self.searchbarbutton_width = self.searchbarbutton.text:GetRegionSize()
	self.searchbarbutton.image:SetSize(self.searchbarbutton_width * .9, self.search_fontsize)
	self.searchbarbutton_posx = self.searchbar_width * .5 - self.searchbarbutton_width * .5 - 5
	self.searchbarbutton:SetPosition(self.searchbarbutton_posx, 0, 0)

	self.searchtext_limitwidth = self.searchbar_width - self.searchbarbutton_width - 20
	self:InitSearchScreen()

	self.searchhelptip = self.searchshield:AddChild(TextButton())
	self.searchhelptip:SetFont(NEWFONT)
	self.searchhelptip:SetTextSize(self.search_fontsize)
	self.searchhelptip:SetText(STRINGS.TOO_MANY_ITEMS_UI.SEARCHBAR_TEXT)
	self.searchhelptip:SetTooltip(STRINGS.TOO_MANY_ITEMS_UI.SEARCHBAR_TIP)
	self.searchhelptip:SetOnClick( function() self:SearchKeyWords() end)
	self.searchhelptip.text:SetRegionSize(self.searchtext_limitwidth, self.search_fontsize)
	self.searchhelptip.image:SetSize(self.searchtext_limitwidth * .9, self.search_fontsize)
	self.searchhelptip:SetPosition(self.searchtext_limitwidth * .5 - self.searchbar_width * .5 + 5, 0, 0)

	self.searchtext = self.searchshield:AddChild(Text(NEWFONT, self.search_fontsize))
	self.searchtext:SetColour(0.9,0.8,0.6,1)

	self:SearchTipSet()
end

function TMI_Menubar:SearchTipSet()
	if TOOMANYITEMS.DATA.search ~= "" then
		self.searchtext:SetString(TOOMANYITEMS.DATA.search)
		self.searchhelptip:SetColour(0.9,0.8,0.6,0)
		self.searchhelptip:SetOverColour(0.9,0.8,0.6,0)

		local searchtext_width, searchtext_height = self.searchtext:GetRegionSize()
		if searchtext_width > self.searchtext_limitwidth then
			self.searchtext:SetRegionSize( self.searchtext_limitwidth, searchtext_height )
			self.searchtext:SetPosition(self.searchtext_limitwidth * .5 - self.searchbar_width * .5, 0, 0)
		else
			self.searchtext:SetPosition(searchtext_width * .5 - self.searchbar_width * .5 + 5, 0, 0)
		end
	else
		self.searchtext:SetString("")
		self.searchhelptip:SetColour(0.9,0.8,0.6,1)
		self.searchhelptip:SetOverColour(0.9,0.8,0.6,1)
	end

end

function TMI_Menubar:Search(str)
	if str == TOOMANYITEMS.DATA.search then
		self:ShowSearch()
	else
		local search_str = GetPrettyStr(str)
		if search_str ~= "" then

			local history = {}
			local history_num = #TOOMANYITEMS.DATA.searchhistory
			for i = 1, history_num do
				local value = TOOMANYITEMS.DATA.searchhistory[i]
				if value ~= search_str then
					table.insert(history, value)
				end
			end
			table.insert(history, search_str)
			TOOMANYITEMS.DATA.searchhistory = history
			TOOMANYITEMS.DATA.search = search_str
			self:ShowSearch()
		else
			TOOMANYITEMS.DATA.issearch = false
			TOOMANYITEMS.DATA.search = ""
			self:ShowNormal()
		end
		self:SearchTipSet()
	end
	self:SaveData()
end

function TMI_Menubar:InitSearchScreen()
	local function SearchScreenActive()
		self.searchhelptip:Hide()
		self.searchtext:Hide()
	end
	local function SearchScreenAccept(str)
		if str then
			self:Search(str)
		end
	end
	local function SearchScreenClose()
		self.searchhelptip:Show()
		self.searchtext:Show()
	end
	local function SearchScreenRawKey(key, screen)
		if key == KEY_UP then
			local len = #TOOMANYITEMS.DATA.searchhistory
			if len > 0 then
				if self.history_idx ~= nil then
					self.history_idx = math.max( 1, self.history_idx - 1 )
				else
					self.history_idx = len
				end
				screen:OverrideText( TOOMANYITEMS.DATA.searchhistory[ self.history_idx ] )
			end
		elseif key == KEY_DOWN then
			local len = #TOOMANYITEMS.DATA.searchhistory
			if len > 0 then
				if self.history_idx ~= nil then
					if self.history_idx == len then
						screen:OverrideText( "" )
					else
						self.history_idx = math.min( len, self.history_idx + 1 )
						screen:OverrideText( TOOMANYITEMS.DATA.searchhistory[ self.history_idx ] )
					end
				else
					self.history_idx = len
					screen:OverrideText( "" )
				end
			end
		end
	end

	self.SearchScreenConfig = {
		fontsize = self.search_fontsize,
		size = {self.searchtext_limitwidth, self.search_fontsize},
		isediting = true,
		pos = Vector3(self.owner.shieldpos_x - self.owner.shieldsize_x * .5 + self.searchtext_limitwidth * .5 + self.sidebar_width + 5, self.owner.shieldsize_y * .5 - self.search_fontsize * .5, 0),
		acceptfn = SearchScreenAccept,
		closefn = SearchScreenClose,
		activefn = SearchScreenActive,
		rawkeyfn = SearchScreenRawKey,
	}
end

function TMI_Menubar:SearchKeyWords()
	if self.searchbar then
		self.searchbar:KillAllChildren()
		self.searchbar:Kill()
		self.searchbar = nil
	end
	self.searchbar = SearchScreen(self.SearchScreenConfig)
	ThePlayer.HUD:OpenScreenUnderPause(self.searchbar)
	if TheFrontEnd:GetActiveScreen() == self.searchbar then
		self.searchbar.edit_text:SetHAlign(ANCHOR_LEFT)
		self.searchbar.edit_text:SetIdleTextColour(0.9,0.8,0.6,1)
		self.searchbar.edit_text:SetEditTextColour(1,1,1,1)
		self.searchbar.edit_text:SetEditCursorColour(1,1,1,1)
		self.searchbar.edit_text:SetTextLengthLimit(200)
		self.searchbar.edit_text:EnableWordWrap(false)
		self.searchbar.edit_text:EnableRegionSizeLimit(true)
		self.searchbar.edit_text:EnableScrollEditWindow(false)
		self.searchbar.edit_text:SetString(TOOMANYITEMS.DATA.search)
		self.searchbar.edit_text.validrawkeys[KEY_UP] = true
		self.searchbar.edit_text.validrawkeys[KEY_DOWN] = true
	end
end

function TMI_Menubar:LoadSearchData()
	if TOOMANYITEMS.DATA.issearch then
		self:Search(TOOMANYITEMS.DATA.search)
	else
		self:ShowNormal()
	end
end

function TMI_Menubar:SaveData()
	if TOOMANYITEMS.DATA_SAVE == 1 then
		TOOMANYITEMS.SaveNormalData()
	end
end

function TMI_Menubar:OnControl(control, down)
	if TMI_Menubar._base.OnControl(self,control, down) then
		return true
	end

	return true
end

function TMI_Menubar:OnRawKey(key, down)
	if TMI_Menubar._base.OnRawKey(self, key, down) then return true end
end

return TMI_Menubar
