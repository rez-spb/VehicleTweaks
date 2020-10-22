-- author: rez
-- version: 0.2.0 (2020-10-22)
-- based on: 40.43

--[[
	Set engine quality, power and loudness (admin only).
	
	COPYRIGHT:
	The idea, artwork, placement, English and Russian translations,
	code and other things introduced in this mod are copyrighted 
	to Rez.
	Localizations are copyrighted to steam users who provided them
	(see localization files).
	Base game functions are copyrighted to The Indie Stone.
]]--

require "Vehicles/ISUI/ISVehicleMechanics";

ISVehicleTweaks = ISVehicleMechanics:derive("ISVehicleTweaks");

function ISVehicleTweaks:initialise()
	original_class.initialise(self);
end

function debug_print(_msg)
	local m = '[ISVehicleTweaks]: ' .. tostring(_msg);
	print(m);
end

function ISVehicleTweaks:setEngine()
	local _quality = tonumber(self.se_ui_entry_quality:getText());
	local _hp = tonumber(self.se_ui_entry_hp:getText());
	local _loudness = tonumber(self.se_ui_entry_loudness:getText());
	debug_print('entered quality: ' .. _quality);
	debug_print('entered hp: ' .. _hp);
	debug_print('entered loudness: ' .. _loudness);
	ISVehicleTweaks.se_vehicle:setEngineFeature(_quality, _loudness, _hp);
end

function ISVehicleTweaks:onCallSetEngineFeature(_vehicle)
	ISVehicleTweaks.se_vehicle = _vehicle or {};
	window = ISVehicleSetEngineWindow:new(450, 280, 150, 125);
end

function ISVehicleTweaks:doPartContextMenu(part, x, y)
	--[[
		PZ internal function with added options.
	]]--
	if UIManager.getSpeedControls():getCurrentGameSpeed() == 0 then return; end
	
	local playerObj = getSpecificPlayer(self.playerNum);
	self.context = ISContextMenu.get(self.playerNum, x + self:getAbsoluteX(), y + self:getAbsoluteY())
	local option;
	
	if part:getItemType() and not part:getItemType():isEmpty() then
		if part:getInventoryItem() then
			local fixingList = FixingManager.getFixes(part:getInventoryItem());
			if part:getScriptPart():isRepairMechanic() and not fixingList:isEmpty() then
				local fixOption = self.context:addOption(getText("ContextMenu_Repair"), nil, nil);
				local subMenuFix = ISContextMenu:getNew(self.context);
				self.context:addSubMenu(fixOption, subMenuFix);
				for i=0,fixingList:size()-1 do
					ISInventoryPaneContextMenu.buildFixingMenu(part:getInventoryItem(), playerObj:getPlayerNum(), fixingList:get(i), fixOption, subMenuFix, part)
				end
			end
			
			if part:getTable("uninstall") then
				option = self.context:addOption(getText("IGUI_Uninstall"), playerObj, ISVehiclePartMenu.onUninstallPart, part)
				self:doMenuTooltip(part, option, "uninstall");
				if not ISVehicleMechanics.cheat and not part:getVehicle():canUninstallPart(playerObj, part) then
					option.notAvailable = true;
				end
			end
		else
			if part:getTable("install") then
				option = self.context:addOption(getText("IGUI_Install"), playerObj, nil)
				if not ISVehicleMechanics.cheat and not part:getVehicle():canInstallPart(playerObj, part) then
					option.notAvailable = true;
					self:doMenuTooltip(part, option, "install", nil);
				else
					local subMenu = ISContextMenu:getNew(self.context);
					self.context:addSubMenu(option, subMenu);
					local typeToItem = VehicleUtils.getItems(self.chr:getPlayerNum())
					-- display all possible item that can be installed
					for i=0,part:getItemType():size() - 1 do
						local name = part:getItemType():get(i);
						local item = InventoryItemFactory.CreateItem(name);
						if item then name = item:getName(); end
						local itemOpt = subMenu:addOption(name, playerObj, nil);
						self:doMenuTooltip(part, itemOpt, "install", part:getItemType():get(i));
						if not typeToItem[part:getItemType():get(i)] then
							itemOpt.notAvailable = true;
						else
							-- display every item the player posess
							local subMenuItem = ISContextMenu:getNew(subMenu);
							self.context:addSubMenu(itemOpt, subMenuItem);
							for j,v in ipairs(typeToItem[part:getItemType():get(i)]) do
								local itemOpt = subMenuItem:addOption(v:getDisplayName() .. " (" .. v:getCondition() .. "%)", playerObj, ISVehiclePartMenu.onInstallPart, part, v);
								self:doMenuTooltip(part, itemOpt, "install", part:getItemType():get(i));
							end
						end
					end
				end
			end
		end
	end
	
	if part:getWindow() and (not part:getItemType() or part:getInventoryItem()) then
		local window = part:getWindow()
		if window:isOpenable() and not window:isDestroyed() and playerObj:getVehicle() then
			if window:isOpen() then
				option = self.context:addOption(getText("ContextMenu_Close_window"), playerObj, ISVehiclePartMenu.onOpenCloseWindow, part, false)
			else
				option = self.context:addOption(getText("ContextMenu_Open_window"), playerObj, ISVehiclePartMenu.onOpenCloseWindow, part, true)
			end
		end
		if not window:isDestroyed() then
			option = self.context:addOption(getText("ContextMenu_Smash_window"), playerObj, ISVehiclePartMenu.onSmashWindow, part)
		end
	end
	
	if part:isContainer() and part:getContainerContentType() == "Air" and part:getInventoryItem() then
		option = self.context:addOption(getText("IGUI_InflateTire"), playerObj, ISVehiclePartMenu.onInflateTire, part)
		if part:getContainerContentAmount() >= part:getContainerCapacity() then
			option.notAvailable = true
		end
		local tirePump = InventoryItemFactory.CreateItem("Base.TirePump");
		if not self.chr:getInventory():contains("TirePump", true) then
			option.notAvailable = true
			local tooltip = ISToolTip:new();
			tooltip:initialise();
			tooltip:setVisible(false);
			tooltip.description = "<RGB:1,0,0> " .. getText("Tooltip_craft_Needs") .. ": <LINE> " .. tirePump:getDisplayName() .. " 0/1";
			option.toolTip = tooltip;
		else
			local tooltip = ISToolTip:new();
			tooltip:initialise();
			tooltip:setVisible(false);
			tooltip.description = "<RGB:1,1,1> " .. getText("Tooltip_craft_Needs") .. ":  <LINE> " .. tirePump:getDisplayName() .. " 1/1";
			option.toolTip = tooltip;
		end
		option = self.context:addOption(getText("IGUI_DeflateTire"), playerObj, ISVehiclePartMenu.onDeflateTire, part)
		if part:getContainerContentAmount() == 0 then
			option.notAvailable = true
		end
	end
	local condInfo = getTextOrNull("IGUI_Vehicle_CondInfo" .. part:getId());
	if condInfo then
		option = self.context:addOption(getText("ContextMenu_PartInfo"), playerObj, nil)
		local tooltip = ISToolTip:new();
		tooltip:initialise();
		tooltip:setVisible(false);
		tooltip.description = condInfo;
		option.toolTip = tooltip;
	end
	
	if part:getId() == "Engine" and not VehicleUtils.RequiredKeyNotFound(part, self.chr) then
		-- custom option for admin
		-- if ISVehicleMechanics.cheat or playerObj:getAccessLevel() ~= "None" then
		option = self.context:addOption("MOD: Set Engine Parameters", playerObj, self.onCallSetEngineFeature, self.vehicle);
		-- end

		if part:getCondition() > 10 and self.chr:getPerkLevel(Perks.Mechanics) >= part:getVehicle():getScript():getEngineRepairLevel() and self.chr:getInventory():contains("Spanner") then
			option = self.context:addOption(getText("IGUI_TakeEngineParts"), playerObj, ISVehicleMechanics.onTakeEngineParts, part);
			self:doMenuTooltip(part, option, "takeengineparts");
		else
			option = self.context:addOption(getText("IGUI_TakeEngineParts"), nil, nil);
			self:doMenuTooltip(part, option, "takeengineparts");
			option.notAvailable = true;
		end
		if part:getCondition() < 100 and self.chr:getInventory():getNumberOfItem("EngineParts", false, true) > 0 and self.chr:getPerkLevel(Perks.Mechanics) >= part:getVehicle():getScript():getEngineRepairLevel() and self.chr:getInventory():contains("Spanner") then
			local option = self.context:addOption(getText("IGUI_RepairEngine"), playerObj, ISVehicleMechanics.onRepairEngine, part);
			self:doMenuTooltip(part, option, "repairengine");
		else
			local option = self.context:addOption(getText("IGUI_RepairEngine"), playerObj, ISVehicleMechanics.onRepairEngine, part);
			self:doMenuTooltip(part, option, "repairengine");
			option.notAvailable = true;
		end
	end
	if ((part:getId() == "HeadlightLeft") or (part:getId() == "HeadlightRight")) and part:getInventoryItem() then
		if part:getLight():canFocusingUp() and self.chr:getPerkLevel(Perks.Mechanics) >= part:getVehicle():getScript():getHeadlightConfigLevel() then
			option = self.context:addOption(getText("IGUI_HeadlightFocusingUp"), playerObj, ISVehicleMechanics.onConfigHeadlight, part, 1);
			self:doMenuTooltip(part, option, "configheadlight");
		else
			option = self.context:addOption(getText("IGUI_HeadlightFocusingUp"), nil, nil);
			self:doMenuTooltip(part, option, "configheadlight");
			option.notAvailable = true;
		end
		if part:getLight():canFocusingDown() and self.chr:getPerkLevel(Perks.Mechanics) >= part:getVehicle():getScript():getHeadlightConfigLevel() then
			option = self.context:addOption(getText("IGUI_HeadlightFocusingDown"), playerObj, ISVehicleMechanics.onConfigHeadlight, part, -1);
			self:doMenuTooltip(part, option, "configheadlight");
		else
			option = self.context:addOption(getText("IGUI_HeadlightFocusingDown"), nil, nil);
			self:doMenuTooltip(part, option, "configheadlight");
			option.notAvailable = true;
		end
	end

	if ISVehicleMechanics.cheat or playerObj:getAccessLevel() ~= "None" then
		option = self.context:addOption("CHEAT: Get Key", playerObj, ISVehicleMechanics.onCheatGetKey, self.vehicle)
		if self.vehicle:isHotwired() then
			self.context:addOption("CHEAT: Remove Hotwire", playerObj, ISVehicleMechanics.onCheatHotwire, self.vehicle, false, false)
		else
			self.context:addOption("CHEAT: Hotwire", playerObj, ISVehicleMechanics.onCheatHotwire, self.vehicle, true, false)
		end
		option = self.context:addOption("CHEAT: Repair Part", playerObj, ISVehicleMechanics.onCheatRepairPart, part)
		option = self.context:addOption("CHEAT: Repair Vehicle", playerObj, ISVehicleMechanics.onCheatRepair, self.vehicle)
		if part:isContainer() and part:getContainerContentType() then
			option = self.context:addOption("CHEAT: Set Content Amount", playerObj, ISVehicleMechanics.onCheatSetContentAmount, part)
		end
		option = self.context:addOption("CHEAT: Remove Vehicle", playerObj, ISVehicleMechanics.onCheatRemove, self.vehicle)
	end

	if getDebug() then
		if ISVehicleMechanics.cheat then
			self.context:addOption("DBG: ISVehicleMechanics.cheat=false", playerObj, ISVehicleMechanics.onCheatToggle)
		else
			self.context:addOption("DBG: ISVehicleMechanics.cheat=true", playerObj, ISVehicleMechanics.onCheatToggle)
		end
	end
	
	if self.context.numOptions == 1 then self.context:setVisible(false) end
	
	if JoypadState.players[self.playerNum+1] and self.context:getIsVisible() then
		self.context.mouseOver = 1
		self.context.origin = self
		JoypadState.players[self.playerNum+1].focus = self.context
		updateJoypadFocus(JoypadState.players[self.playerNum+1])
	end
end

function ISVehicleTweaks:new(x, y, character, vehicle)
	local o = original_class:new(x, y, character, vehicle);
	setmetatable(o, self);
	self.__index = self;
	self.se_vehicle = nil;
	return o;
end

original_class = ISVehicleMechanics;
ISVehicleMechanics = ISVehicleTweaks;