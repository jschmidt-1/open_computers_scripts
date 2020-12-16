local modem = peripheral.wrap("bottom")
local monitor = peripheral.wrap("monitor_0")

local powerFillStatus = 0
local generator = {}
generator[1] = {}
generator[2] = {}

generator[1].rods = 0
generator[1].temperature = 0
generator[1].rpm1 = 0
generator[1].rpm2 = 0
generator[1].rpm3 = 0
generator[1].power1 = 0 
generator[1].power2 = 0
generator[1].power3 = 0
generator[2].rods = 0
generator[2].temperature = 0
generator[2].rpm1 = 0
generator[2].rpm2 = 0
generator[2].rpm3 = 0
generator[2].power1 = 0 
generator[2].power2 = 0
generator[2].power3 = 0

modem.open(1)
modem.open(2)

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function getMessages()
	while true do
		local _,_,receiveChannel,replyChannel,message = os.pullEvent("modem_message")
		if receiveChannel == 1 then
			if message["reactor_name"] ~= nil then
				local reactorNumber = 2
				if message["reactor_name"] == "BigReactors-Reactor_0" then
					reactorNumber = 1
				end
				if message["reactor_rods"] ~= nil then
					generator[reactorNumber].rods = message["reactor_rods"]
				end
				if message["reactor_core"] ~= nil then
					generator[reactorNumber].temperature = message["reactor_core"]
				end
				if message["turbine_1_rpm"] ~= nil then
					generator[reactorNumber].rpm1 = message["turbine_1_rpm"]
				end
				if message["turbine_1_power"] ~= nil then
					generator[reactorNumber].power1 = message["turbine_1_power"]
				end
				if message["turbine_2_rpm"] ~= nil then
					generator[reactorNumber].rpm2 = message["turbine_2_rpm"]
				end
				if message["turbine_2_power"] ~= nil then
					generator[reactorNumber].power2 = message["turbine_2_power"]
				end
				if message["turbine_3_rpm"] ~= nil then
					generator[reactorNumber].rpm3 = message["turbine_3_rpm"]
				end
				if message["turbine_3_power"] ~= nil then
					generator[reactorNumber].power3 = message["turbine_3_power"]
				end
			end
		elseif receiveChannel == 2 then
			if message["energy_core"] ~= nil then
				powerFillStatus = message["energy_core"]
			end
		end
	end
end

function drawScreen()
	monitor.setTextScale(0.5)
	local terminal = term.redirect(monitor)
	
	while true do
		
		term.setBackgroundColor(colors.black)
		term.clear()
		paintutils.drawBox(2,2,25,15,colors.green)
		paintutils.drawBox(28,2,51,15,colors.blue)
		paintutils.drawBox(52,2,75,15,colorslue)
		paintutils.drawBox(76,2,99,15,colors.blue)
		
		paintutils.drawBox(2,17,25,30,colors.green)
		paintutils.drawBox(28,17,51,30,colors.blue)
		paintutils.drawBox(52,17,75,30,colors.blue)
		paintutils.drawBox(76,17,99,30,colors.blue)
		
		paintutils.drawBox(2,32,99,37,colors.red)
		
		--paintutils.drawFilledBox(4,34,97,35,colors.white)
		for i = 0,powerFillStatus-1 do
			local x1 = 6+6*i
			local x2 = 10+6*i
			paintutils.drawFilledBox(x1,34,x2,35,colors.white)

		end
		
		term.setBackgroundColor(colors.black)
		term.setTextColor(colors.white)
		term.setCursorPos(5,2)
		term.write(" Reactor A ")
		term.setCursorPos(31,2)
		term.write(" Turbine A1 ")
		term.setCursorPos(55,2)
		term.write(" Turbine A2 ")
		term.setCursorPos(79,2)
		term.write(" Turbine A3 ")
		
		term.setCursorPos(5,17)
		term.write(" Reactor B ")
		term.setCursorPos(31,17)
		term.write(" Turbine B1 ")
		term.setCursorPos(55,17)
		term.write(" Turbine B2 ")
		term.setCursorPos(79,17)
		term.write(" Turbine B3 ")		
		
		term.setCursorPos(5,32)
		term.write(" RF Stored ")
		--monitor.setCursorPos(1,1)
		--monitor.write("Time: "..os.clock())
		--monitor.setCursorPos(1,2)
		--monitor.write("Power: "..powerFillStatus)
		
		for i=1,2 do
			term.setCursorPos(5,6+(i-1)*15)
			term.write("Control Rod Level:")
			term.setCursorPos(7,7+(i-1)*15)
			term.write(tostring(generator[i].rods).."%")
			term.setCursorPos(5,10+(i-1)*15)
			term.write("Core Temperature:")
			term.setCursorPos(7,11+(i-1)*15)
			term.write(round(generator[i].temperature,2).." C")
			
			term.setCursorPos(31,6+(i-1)*15)
			term.write("Rotor Speed:")
			term.setCursorPos(33,7+(i-1)*15)
			term.write(round(generator[i].rpm1,2).." RPM")
			term.setCursorPos(31,10+(i-1)*15)
			term.write("Energy Output:")
			term.setCursorPos(33,11+(i-1)*15)
			term.write(round(generator[i].power1,2).." RF/t")
			
			term.setCursorPos(55,6+(i-1)*15)
			term.write("Rotor Speed:")
			term.setCursorPos(57,7+(i-1)*15)
			term.write(round(generator[i].rpm2,2).." RPM")
			term.setCursorPos(55,10+(i-1)*15)
			term.write("Energy Output:")
			term.setCursorPos(57,11+(i-1)*15)
			term.write(round(generator[i].power2,2).." RF/t")
			
			term.setCursorPos(79,6+(i-1)*15)
			term.write("Rotor Speed:")
			term.setCursorPos(81,7+(i-1)*15)
			term.write(round(generator[i].rpm3,2).." RPM")
			term.setCursorPos(79,10+(i-1)*15)
			term.write("Energy Output:")
			term.setCursorPos(81,11+(i-1)*15)
			term.write(round(generator[i].power3,2).." RF/t")
			
		end
		
		
		--generator[1].rpm1
		--generator[1].rpm2
		--generator[1].rpm3
		--generator[1].power1
		--generator[1].power2
		--generator[1].power3
		--generator[2].rods
		--generator[2].temperature
		--generator[2].rpm1
		--generator[2].rpm2
		--generator[2].rpm3
		--generator[2].power1
		--generator[2].power2
		--generator[2].power3

		sleep(2)		
	end
	term.redirect(terminal)
end

parallel.waitForAll(
	getMessages,
	drawScreen
)
