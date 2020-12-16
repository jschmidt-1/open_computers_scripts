local monitor = peripheral.wrap("top")
local terminal = term.redirect(monitor)
local spawner = true

local file = "state.txt"
if fs.exists(file) then
	local openFile = assert(fs.open(file, "r"))
	if openFile.readLine() == "false" then
		spawner = false
	end	
	openFile.close()
end

while true do
	redstone.setOutput("left",spawner)
	term.setBackgroundColor(colors.black)
	term.clear()
	
	if spawner then
		paintutils.drawFilledBox(1,1,7,5,colors.red)
		term.setBackgroundColor(colors.red)
		term.setTextColor(colors.white)
		term.setCursorPos(1,2)
		term.write("Spawner")
		term.setCursorPos(1,4)
		term.write("Offline")
	else
		paintutils.drawFilledBox(1,1,7,5,colors.green)
		term.setBackgroundColor(colors.green)
		term.setTextColor(colors.white)
		term.setCursorPos(1,2)
		term.write("Spawner")
		term.setCursorPos(1,4)
		term.write("Online")
	end
	
	_,_,xPos,yPos = os.pullEvent("monitor_touch")
	spawner = not spawner

	local fileHandle = fs.open(file,"w")
	fileHandle.write(tostring(spawner))
	fileHandle.close()
end
