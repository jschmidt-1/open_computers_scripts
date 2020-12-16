local monitor = peripheral.wrap("top")
local terminal = term.redirect(monitor)
local door = true
local spawner = true

local file = "state.txt"
if fs.exists(file) then
	local openFile = assert(fs.open(file, "r"))
	if openFile.readLine() == "false" then
		door = false
	end
	if openFile.readLine() == "false" then
		spawner = false
	end	
	openFile.close()
end

while true do
	redstone.setOutput("left",door)
	redstone.setOutput("back",spawner)
	term.setBackgroundColor(colors.black)
	term.clear()
	if door then
		paintutils.drawFilledBox(1,1,7,2,colors.green)
		term.setBackgroundColor(colors.green)
		term.setTextColor(colors.white)
		term.setCursorPos(1,1)
		term.write("Door")
		term.setCursorPos(1,2)
		term.write("Closed")
	else
		paintutils.drawFilledBox(1,1,7,2,colors.red)
		term.setBackgroundColor(colors.red)
		term.setTextColor(colors.white)
		term.setCursorPos(1,1)
		term.write("Door")
		term.setCursorPos(1,2)
		term.write("Opened")
	end
	
	if spawner then
		paintutils.drawFilledBox(1,4,7,5,colors.red)
		term.setBackgroundColor(colors.red)
		term.setTextColor(colors.white)
		term.setCursorPos(1,4)
		term.write("Spawner")
		term.setCursorPos(1,5)
		term.write("Offline")
	else
		paintutils.drawFilledBox(1,4,7,5,colors.green)
		term.setBackgroundColor(colors.green)
		term.setTextColor(colors.white)
		term.setCursorPos(1,4)
		term.write("Spawner")
		term.setCursorPos(1,5)
		term.write("Online")
	end
	
	_,_,xPos,yPos = os.pullEvent("monitor_touch")
	if yPos <= 2 then
		door = not door
	elseif yPos >= 4 then
		spawner = not spawner
	end
	local fileHandle = fs.open(file,"w")
	fileHandle.write(tostring(door).."\n")
	fileHandle.write(tostring(spawner))
	fileHandle.close()
end
