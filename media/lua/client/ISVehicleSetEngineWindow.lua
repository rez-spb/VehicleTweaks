-- author: rez
-- version: 0.2.0 (2020-10-22)
-- based on: 40.43

--[[
	Auxiliary file for getting engine parameters from user.
	
	COPYRIGHT:
	The idea, artwork, placement, English and Russian translations,
	code and other things introduced in this mod are copyrighted 
	to Rez.
	Localizations are copyrighted to steam users who provided them
	(see localization files).
	Base game functions are copyrighted to The Indie Stone.
]]--

ISVehicleSetEngineWindow = ISCollapsableWindow:derive("ISVehicleSetEngineWindow");

function ISVehicleSetEngineWindow:initialise()
	ISCollapsableWindow.initialise(self);
end

function ISVehicleSetEngineWindow:createChildren()
	ISCollapsableWindow.createChildren(self);
	local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small);

	-- entry fields
	self.se_ui_entry_quality = ISTextEntryBox:new('100', 5, 20, 60, FONT_HGT_SMALL + 2 * 2);
	self.se_ui_entry_quality.font = UIFont.Small;
	self.se_ui_entry_quality:initialise();
	self.se_ui_entry_hp = ISTextEntryBox:new('5000', 5, 45, 60, FONT_HGT_SMALL + 2 * 2);
	self.se_ui_entry_hp.font = UIFont.Small;
	self.se_ui_entry_hp:initialise();
	self.se_ui_entry_loudness = ISTextEntryBox:new('27', 5, 70, 60, FONT_HGT_SMALL + 2 * 2);
	self.se_ui_entry_loudness.font = UIFont.Small;
	self.se_ui_entry_loudness:initialise();

	-- entry labels
	self.se_ui_text_quality = ISLabel:new(80, 20, FONT_HGT_SMALL + 2 * 2, "Quality", 1, 1, 1, 1, UIFont.Small, true);
	self.se_ui_text_quality:initialise();
	self.se_ui_text_hp = ISLabel:new(80, 45, FONT_HGT_SMALL + 2 * 2, "Power", 1, 1, 1, 1, UIFont.Small, true);
	self.se_ui_text_hp:initialise();
	self.se_ui_text_loudness = ISLabel:new(80, 70, FONT_HGT_SMALL + 2 * 2, "Loudness", 1, 1, 1, 1, UIFont.Small, true);
	self.se_ui_text_loudness:initialise();

	-- save button
	self.se_ui_save = ISButton:new(5, 95, 140, 25, getText("UI_characreation_BuildSave"), self, ISVehicleTweaks.setEngine);
	self.se_ui_save:initialise();

	-- stick to collapsable window
	self:addChild(self.se_ui_entry_quality);
	self:addChild(self.se_ui_text_quality);
	self:addChild(self.se_ui_entry_hp);
	self:addChild(self.se_ui_text_hp);
	self:addChild(self.se_ui_entry_loudness);
	self:addChild(self.se_ui_text_loudness);
	self:addChild(self.se_ui_save);

	-- cannot change property until added as a child: not instantiated
	self.se_ui_entry_quality:setOnlyNumbers(true);
	self.se_ui_entry_hp:setOnlyNumbers(true);
	self.se_ui_entry_loudness:setOnlyNumbers(true);
end

function ISVehicleSetEngineWindow:new(x, y, width, height)
	o = {};
	o = ISCollapsableWindow:new(x, y, width, height);
	setmetatable(o, self);
	self.__index = self;
	o.title = "Set Parameters";
	o.pin = true;
	o:setResizable(false);
	o:setVisible(true);
	o:initialise();
	o:addToUIManager();
	--o:noBackground();
	return o;
end