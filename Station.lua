--Station template Server

--Stations should be able to switch between 3 different modes ( input / output / transfer )
--Input stations will generated orders to store items in their input chests
--Output stations will collect items waiting for output + send messages to order server 
--Transfer stations will collect all items on an order and store them until ready

--Stations do not handle updates to item positions.

rednet.open('top')

local chestEnder = peripheral.wrap('left')
local chestWork = peripheral.wrap('bottom')
local chestInterface = peripheral.wrap('right')
local timers = {}
local timeID
local svr = {}
local updateMasterID = false

print('Station starting...')

--Send message to svr.orderID 
local id, msg
repeat
  rednet.broadcast({action='ROLLCALL_STATION'})
  id, msg = rednet.receive(5)
until msg ~= nil

if msg.action == 'ROLLCALL_ERROR' then
  print('Station does not exist in the database!')
  print('Please remove the station.')
  return
end

local mode = msg.mode
local stationID = msg.stationID

local chestWorkFreeSlots = chestWork.getInventorySize() - #chestWork.getAllStacks()

function getFreeInterfaceSlots()
  return chestInterface.getInventorySize() - #chestInterface.getAllStacks()
end

--[[Check Working Chest for existing items
if chestWorkFreeSlots ~= chestWork.getInventorySize() then
  Sort through working chest until empty
    while chestWorkingFreeSlots ~= chestWork.getInventorySize() do
      Check OutputChest for free slots
	  print('yes')
  end
end]]--

function broadcastMessage(id, msg)
  local comp, response
  repeat
    print('Sending Message to '..id)
    rednet.broadcast(id,msg)
    comp, response = rednet.receive(1)
  until response ~= nil
  return comp, response
end

function sendMessage(id, msg)
  local comp, response
  repeat
    print('Sending Message to '..id)
    rednet.send(id,msg)
    comp, response = rednet.receive(1)
  until response == id
  return comp, response
end

function startTimer(i)
  timeID = os.startTimer(i)
  table.insert(timers, timeID)
  print(#timers)
end

function isPresent(array, data)
  for i,v in pairs(array) do
    if v == data then
      return true
    end
  end
  return false
end

function switchMode(newMode)
 
  mode = newMode
  if mode == 'input' then
     
	 --Change enderchest to inputMode
	 chestEnder.setColors(colors.green, colors.green, colors.green)
	 
	 --Start input timer cycle
     startTimer(5)
	 
  elseif mode == 'output' then
    	   
    --Change enderchest to outputMode
    chestEnder.setColros(colors.red, colors.red, colors.red)
	
    --Cancel all current timers
    for i,v in pairs(timers) do
      os.cancelTimer(v)
    end
    timers = {}
  
  elseif mode == 'transfer' then
    
	--Change enderchest to transferMode
	chestEnder.setColors(colors.white, colors.white, colors.white)
	
    --Cancel all current timers
    for i,v in pairs(timers) do
      os.cancelTimer(v)
    end
    timers = {}
	
  end  
end




--The four functions of a station

function inputFunction()
  --Verify Item in Hold Slot matches turtles order
  local itemDetails = chestInterface.getStackInSlot(msg.itemPos)
  print(msg.itemPos)
  print(itemDetails.id)
  print(msg.itemID)
	  
  --Check for errors
  if itemDetails.id ~= msg.itemName then
    print('Input Server has received an invalid order from a turtle. It cannot find the item requested')
	rednet.send(id, {action='error', reason='cannot find item'})
  elseif itemDetails.qty ~= msg.qty then
    print('Input Server has received an invalid order from a turtle. It does not have enough items to fufill the order.')
    rednet.send(id, {action='error', reason='not enough items'})
  elseif itemDetails.dmg ~= msg.dmg then
    print('Station has received an invalid order from a turtle. The item in the requested slot does not have the same dmg value has the one requested')
    rednet.send(id, {action='error', reason='invalid dmg value'})
  else
    --Transfer item to Turtle's Chest
    chestInterface.pushItem('north', msg.itemPos, 64, 15)
	rednet.send(id, {action='ok'})
  end

  --Perfectionism. Perfectionism. Perfectionism. 
  --It'll kill me one day.
  generateOrders()
	  
end

function outputFunction()
  
  --Transfer item
  chestInterface.pullItem('north', msg.itemPos)
  
  --Verify item
  local itemDetails = chestInterface.getStackInSlot(1)
  
  if itemDetails.qty ~= msg.qty then
    print('Output Server has received an invalid order from a turtle. It does not have enough items to fufill the order.')
    rednet.send(id, {action='error', reason='not enough items'})
  elseif itemDetails.id ~= msg.itemName then
    print('Output Server has received an invalid order from a turtle. It cannot find the item requested')
	rednet.send(id, {action='error', reason='invalid item'})
  elseif itemDetails.display_name ~= msg.displayName then
    print('Output Server has received an invalid order from a turtle. It cannot find the item requested')
	rednet.send(id, {action='error', reason='invalid item'})
  elseif itemDetails.dmg ~= msg.dmg then
    print('Output has received an invalid order from a turtle. The item it recieved does not have the same dmg value has the one requested')
    rednet.send(id, {action='error', reason='invalid dmg value'})
  else
    --Everythings ok, send turtle on its way
	rednet.send(id, {action='ok'})
  end
  
  --Send item to chestEnder
  chestInterface.pushItemIntoSlot('down', 1, 64)
  chestWork.pullItemIntoSlot('north', 1, 64)
  chestWork.pushItemIntoSlot('south', 1, 64)
  chestEnder.pullItemIntoSlot('down', 1, 64) 
end

function transferFunction()
  --When your up to this part, a good job has been done.
end

function generateOrders()

  --Cancel all current timers
  for i,v in pairs(timers) do
    os.cancelTimer(v)
  end
  timers = {}
	
    print('Beginning order generation cycle')
  
    local spaces = getFreeOutputSlots()
    local slotNum = 1
	local itemCount = 0
  
    print('Output has '..spaces..' open spaces')
  
    --Transfer items to working
    while spaces ~= 0 and slotNum <= chestEnder.getInventorySize() do
	  local item = chestEnder.getStackInSlot(slotNum)
	  if item ~= nil then
	    spaces = spaces - 1
	    chestEnder.pushItem('down', slotNum)
	    chestWork.pullItem('south', 1)
	    itemCount = itemCount + 1
	  end
	  slotNum = slotNum + 1
    end
  
    --One by one, Make work orders for each item and send them to an open slot in holdChest
    if #chestWork.getAllStacks() ~= 0 then
      local stackCount = #chestWork.getAllStacks()
      for i=1, stackCount do
        local itemInfo = chestWork.getStackInSlot(i)
		
		--Find an open slot in holdChest
		local slot = 0
		repeat
		  slot = slot + 1 
		until chestInterface.getStackInSlot(slot) == nil
		
		--Transfer item to the open slot
		chestWork.pushItem('north', i)
	    chestInterface.pullItem('down', 1, 64, slot)
		
		--Send a new input order to the order server
	    sendMessage(svr.orderID, {type='new.order',
		                                          orderType='input',
												  itemName=itemInfo.id,
												  displayName=itemInfo.display_name,
												  count=itemInfo.qty,
												  dmg=itemInfo.dmg,
												  locationType='input', 
												  locationID=stationID,
												  locationPos=slot})
	  end
    end
	
	--Create a new timer
	startTimer(5)
	
    print('Order Generation complete')
end




print('Station started!')
print('Beginning loop')
while true do
  --Start inital timer if station is input
  if mode == 'input' then
    startTimer(5)
  end
  
  local action,id,msg = os.pullEvent()
  
  if action == 'rednet_message' then
    if msg.action == 'switch mode' then
	  switchMode(msg.mode)
	elseif msg.action == 'doInput' then
	  inputFunction()
    elseif msg.action == 'doOutput' then
      outputFunction()
    elseif msg.action == 'doTransfer' then
      transferFunction()
    elseif msg.action == 'GET_INFO' then
	  rednet.send(id, {capacity=#chestInterface.getAllStacks(), mode=mode})
	  if msg.auto_update ~= nil and msg.auto_update == true then
	    updateMasterID = true
	  end
	end
  elseif action == 'timer' and isPresent(timers, id) and mode == 'input' then
    print('TICK')
	generateOrders()
  end
end
