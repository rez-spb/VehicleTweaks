-- author: rez
-- version: 0.2.0 (2020-10-22)
-- based on: 40.43

--[[
	Auxiliary file.
	Uses vanilla server counterpart.
]]--

require "TimedActions/ISBaseTimedAction";

ISVehicleTweaksResetTrunkCommand = ISBaseTimedAction:derive("ISVehicleTweaksResetTrunkCommand");

function ISVehicleTweaksResetTrunkCommand:isValid()
	-- won't perform() without true
	return self.part ~= nil and self.character ~= nil
end

function ISVehicleTweaksResetTrunkCommand:update()
end

function ISVehicleTweaksResetTrunkCommand:start()
end

function ISVehicleTweaksResetTrunkCommand:stop()
	ISBaseTimedAction.stop(self);
end

function ISVehicleTweaksResetTrunkCommand:perform()
	local part = self.part;
	local item = part:getInventoryItem();
	local vehicle = part:getVehicle();
	local args = {
		vehicle = part:getVehicle():getId(),
		part = part:getId(),
		condition = item:getCondition(),
		haveBeenRepaired = 0
	}
	sendClientCommand(self.character, 'vehicle', 'fixPart', args);

	-- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self);
end

function ISVehicleTweaksResetTrunkCommand:new(character, part)
	local o = {};
	setmetatable(o, self);
	self.__index = self;
	o.character = character;
	o.part = part;
	o.maxTime = 1;  -- almost instant, with almost being important part for MP
	return o
end
