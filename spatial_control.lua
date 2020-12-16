local spatialIO = peripheral.wrap("tilespatialioport_1")
local monitor = peripheral.wrap("monitor_1")
local chest = peripheral.wrap("left")
local file = "state.txt"

local slots = {
	"Slot 1",
	"Slot 2",
	"Slot 3",
	"Slot 4",
	"Slot 5",
	"Slot 6",
	"Slot 7",
	"Slot 8",
	"Slot 9",
	"Slot 10",
	"Slot 11",
	"Slot 12",
}

local buttons = {}
local width = 19
local height = 12
local offsetX = 2
local offsetY = 2
for key,value in ipairs(slots) do
	buttons[key] = {}
	buttons[key].name = value
	local colIndex = (key-1)%4
	local rowIndex = math.floor((key-1)/4)
	buttons[key].x1 = 1+colIndex*width+offsetX
	buttons[key].x2 = (colIndex+1)*width-1+offsetX
	buttons[key].y1 = 1+rowIndex*height+offsetY
	buttons[key].y2 = (rowIndex+1)*height-1+offsetY
end

SPATIAL_DIRECTION_CHEST = "east"
monitor.setTextScale(0.5)

local activeSlot = 0

if fs.exists(file) then
	local openFile = assert(fs.open(file, "r"))
	activeSlot = tonumber(openFile.readLine())
	openFile.close()
end

function activateSpatialIO()
	redstone.setOutput("bottom",true)
	sleep(0.5)
	redstone.setOutput("bottom",false)
end

function loadSpatial(slot)
	if activeSlot > 0 then
		spatialIO.pullItem(SPATIAL_DIRECTION_CHEST,activeSlot,1,1)
		activateSpatialIO()
		spatialIO.pushItem(SPATIAL_DIRECTION_CHEST,2,1,activeSlot)
		sleep(1)
	end
	if activeSlot == slot then
		activeSlot = 0
	else
		spatialIO.pullItem(SPATIAL_DIRECTION_CHEST,slot,1,1)
		activateSpatialIO()
		spatialIO.pushItem(SPATIAL_DIRECTION_CHEST,2,1,slot)
		activeSlot = slot
	end
	
	local fileHandle = fs.open(file,"w")
	fileHandle.write(activeSlot)
	fileHandle.close()
end

function drawSelection()
	local terminal = term.redirect(monitor)
	term.setBackgroundColor(colors.black)
	term.clear()

	for key,value in ipairs(buttons) do
		local backGroundColor = colors.blue
		if key == activeSlot then
			backGroundColor = colors.purple
		end
				
		paintutils.drawFilledBox(value.x1,value.y1,value.x2,value.y2,backGroundColor)
		term.setBackgroundColor(backGroundColor)
		term.setTextColor(colors.white)
		term.setCursorPos(value.x1+math.floor(height/2),value.y1+2)
		term.write(value.name)		
	end
	term.redirect(terminal)
end

function drawWorking()
	local terminal = term.redirect(monitor)
	for i=1,4 do
		term.setBackgroundColor(colors.black)
		term.clear()
		paintutils.drawFilledBox(1,9,79,30,colors.red)
		paintutils.drawFilledBox(2,10,78,29,colors.white)
		term.setBackgroundColor(colors.white)
		term.setTextColor(colors.red)
		term.setCursorPos(34,12)
		term.write("- Warning -")
		term.setTextColor(colors.black)
		term.setCursorPos(25,17)
		term.write("Spatial Storage activates in "..tostring(4-i).."s")
		term.setCursorPos(30,20)
		term.write("Do not enter the area!")
		sleep(1)
	end
	term.setBackgroundColor(colors.black)
	term.clear()
	paintutils.drawFilledBox(1,9,79,30,colors.purple)
	paintutils.drawFilledBox(2,10,78,29,colors.white)
	term.setBackgroundColor(colors.white)
	term.setTextColor(colors.red)
	term.setCursorPos(35,12)
	term.write("- Active -")
	term.setTextColor(colors.black)
	term.setCursorPos(20,17)
	term.write("Spatial Storage is currently working")
	term.setCursorPos(30,20)
	term.write("Loading data...")
	sleep(1)
	term.redirect(terminal)
end

function drawDone()
	local terminal = term.redirect(monitor)
	term.setBackgroundColor(colors.black)
	term.clear()
	paintutils.drawFilledBox(1,9,79,30,colors.green)
	paintutils.drawFilledBox(2,10,78,29,colors.white)
	term.setBackgroundColor(colors.white)
	term.setTextColor(colors.green)
	term.setCursorPos(34,12)
	term.write("- Success -")
	term.setTextColor(colors.black)
	term.setCursorPos(27,17)
	term.write("Spatial Storage activated")
	term.setCursorPos(33,20)
	if activeSlot > 0 then
		term.write(buttons[activeSlot].name.." loaded")
	else
		term.write("Area cleared")
	end
	sleep(3)

	term.redirect(terminal)
end

while true do
	drawSelection()
	_,_,xPos,yPos = os.pullEvent("monitor_touch")
	for key,value in ipairs(buttons) do
		if value.x1 <= xPos and value.x2 >= xPos and value.y1 <= yPos and value.y2 >= yPos then
			redstone.setOutput("top",true)
			drawWorking()
			loadSpatial(key)
			redstone.setOutput("top",false)
			drawDone()
		end	
	end
end
