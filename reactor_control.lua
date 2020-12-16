-- /home/jannis/Projekte/ReactorControl/reactor_control.lua

TURBINE_DEFAULT_FLUID_CONSUMPTION = 2000
TURBINE_MINIMUM_RUNTIME = 1800
REACTOR_MAX_TEMPERATURE = 500
REACTOR_MAX_FLUID_STORED = 14000
REACTOR_WAIT_POWERUP = 15
REACTOR_JUMP_THRESHOLD = 500
REACTOR_JUMP_HEIGHT = 5

local modem = peripheral.wrap("bottom")
modem.open(1)

local Generator = {}
Generator.__index = Generator

function Generator.new(r)
	local self = setmetatable({}, Generator)
	while not peripheral.isPresent(r) do
		sleep(5)
	end
	self.reactorName = r
	self.reactor = peripheral.wrap(r)
	self.turbine = {}
	self.controlRodLevel = self.reactor.getControlRodLevel(1)
	self.reactorPowerUpTime = 0
	self.turbinePowerUpTime = 0
	return self
end

function Generator:addTurbine(t)
	while not peripheral.isPresent(t) do
		sleep(5)
	end
	table.insert(self.turbine,peripheral.wrap(t))
end

function Generator:getPowerProduction()
	local sum = 0
	for key,value in ipairs(self.turbine) do
		sum = sum + value.getEnergyProducedLastTick()
	end
	return sum
end

function Generator:getHotFluidProduced()
	return self.reactor.getHotFluidProducedLastTick()
end

function Generator:getWasteAmount()
	return self.reactor.getWasteAmount()
end

function Generator:getCoreTemperature()
	return self.reactor.getFuelTemperature()
end

function Generator:getCaseTemperature()
	return self.reactor.getCasingTemperature()
end

function Generator:setControlRod(level)
	self.reactor.setAllControlRodLevels(level)
	self.controlRodLevel = level
end

function Generator:increaseControlRod(num)
	local value = num or 1
	if self.controlRodLevel < 100 then
		self.controlRodLevel = self.controlRodLevel + value
		if self.controlRodLevel > 100 then
			self.controlRodLevel = 100
		end
		self.reactor.setAllControlRodLevels(self.controlRodLevel)
	end
end

function Generator:decreaseControlRod(num)
	local value = num or 1
	if self.controlRodLevel > 0 then
		self.controlRodLevel = self.controlRodLevel - value
		if self.controlRodLevel < 0 then
			self.controlRodLevel = 0
		end
		self.reactor.setAllControlRodLevels(self.controlRodLevel)
	end
end

function Generator:getHotFluidRequired()
	local sum = 0
	for key,value in ipairs(self.turbine) do
		sum = sum + value.getFluidFlowRateMax()
	end
	return sum
end

function Generator:getHotFluidStored()
	return self.reactor.getHotFluidAmount()
end

function Generator:getMaxHotFluidStored()
	return self.reactor.getHotFluidAmountMax()
end

function Generator:powerUpReactor()
	if not self.reactor.getActive() then
		self.reactor.setActive(true)
		self:setControlRod(99)
		self.reactorPowerUpTime = os.clock()
	end
end

function Generator:powerDownReactor()
	if self:getHotFluidRequired() == 0 then
		self:setControlRod(100)
		self.reactor.setActive(false)
	end
end

function Generator:powerUpTurbine()
	for key,value in ipairs(self.turbine) do
		if value.getFluidFlowRateMax() == 0 then
			value.setFluidFlowRateMax(TURBINE_DEFAULT_FLUID_CONSUMPTION)
			self.turbinePowerUpTime = os.clock()
			self:powerUpReactor()
			break
		end
	end
end

function Generator:powerDownTurbine()
	if self.turbinePowerUpTime + TURBINE_MINIMUM_RUNTIME > os.clock() then
		return
	end
	for key,value in ipairs(self.turbine) do
		if value.getFluidFlowRateMax() > 0 then
			value.setFluidFlowRateMax(0)
			break
		end
	end
end

function Generator:regulateReactor()
	local fluidProduced = self:getHotFluidProduced()
	local fluidRequired = self:getHotFluidRequired()
	if self.reactor.getActive() then
		if fluidRequired == 0 then
			self:powerDownReactor()
		elseif self.controlRodLevel < 99 and self:getCoreTemperature() > REACTOR_MAX_TEMPERATURE then
			self:increaseControlRod()
		elseif os.clock() > self.reactorPowerUpTime + REACTOR_WAIT_POWERUP then
			if fluidProduced < fluidRequired then
				if fluidProduced + REACTOR_JUMP_THRESHOLD < fluidRequired then
					self:decreaseControlRod(REACTOR_JUMP_HEIGHT)
				else
					self:decreaseControlRod()
				end
			elseif self:getHotFluidStored() > REACTOR_MAX_FLUID_STORED and fluidProduced >= fluidRequired then
				self:increaseControlRod()
			end
		end
	elseif fluidRequired > 0 then
		self:powerUpReactor()
	end
end

function Generator:sendData()
	local data = {}
	data["reactor_name"] = self.reactorName
	data["reactor_rods"] = self.controlRodLevel
	data["reactor_core"] = self:getCoreTemperature()
	
	data["turbine_1_rpm"] = self.turbine[1].getRotorSpeed()
	data["turbine_1_power"] = self.turbine[1].getEnergyProducedLastTick()
	
	data["turbine_2_rpm"] = self.turbine[2].getRotorSpeed()
	data["turbine_2_power"] = self.turbine[2].getEnergyProducedLastTick()
	
	data["turbine_3_rpm"] = self.turbine[3].getRotorSpeed()
	data["turbine_3_power"] = self.turbine[3].getEnergyProducedLastTick()
	
	modem.transmit(1,1,data)
end

function Generator:receiveCommands()

end

term.clear()
term.setCursorPos(1,1)
print("Setting up connections...")
--sleep(60)

r1 = Generator.new("BigReactors-Reactor_0")
r1:addTurbine("BigReactors-Turbine_2")
r1:addTurbine("BigReactors-Turbine_3")
r1:addTurbine("BigReactors-Turbine_0")

r2 = Generator.new("BigReactors-Reactor_1")
r2:addTurbine("BigReactors-Turbine_5")
r2:addTurbine("BigReactors-Turbine_4")
r2:addTurbine("BigReactors-Turbine_1")

term.clear()
term.setCursorPos(1,1)
print("Running ReactorControl...")

while true do
	r1:regulateReactor()
	r2:regulateReactor()
	r1:sendData()
	r2:sendData()
	
	sleep(3)
end
