local modem = peripheral.wrap("top")
local message = {}
while true do
	message["energy_core"] = redstone.getAnalogInput("back")
	modem.transmit(2,2,message)
	term.clear()
	term.setCursorPos(1,1)
	print("Current Signal Strength: ",message["energy_core"])
	sleep(30)
end
