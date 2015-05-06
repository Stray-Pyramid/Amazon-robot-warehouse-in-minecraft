--Server One
--Manages incoming orders and updates to orders
--[[

NOTES

Order type for Placing and removing chests?

Update order.hold code to remove the order from active orders and input into hold orders, 
update database and assign the turtle a new order

Resume order needs code to handle differences between (input / output / transfer)
--Transfers
  --Should only take up one station
  --Need more than two turtles to complete

]]--
  
  
local compID = os.getComputerID()
local debugActive = true
local warehouseStatus = 'OFFLINE'


local orderArray = {}
local turtleArray = {}
local chestArray = {}
local nodeArray = {}
local itemArray = {}
local eventArray = {}
local stationArray = {}

local completedJobs = 0

local svr = {
  patherID = 42,
  orderID = 41,
  inputID = 81,
  databaseID = 43,
  masterID = 44
}

rednet.open('top')

function sendMessage(id, msg)
  local response
  print('Sending Message to '..id)
  repeat
    rednet.send(id,msg)
    response, rmsg = rednet.receive(5)
  until response == id
  print('Done!')
  return response, rmsg
end

term.clear()
term.setCursorPos(1,1)

--Step 1: Get Chest Info
print('Getting Chest info')
local _,chestArray = sendMessage(svr.databaseID, {id='chests', action='getAll'})

--Step 2: Get Item Info
print('Getting Item info')
local _,itemArray = sendMessage(svr.databaseID, {id='items', action='getAll'})

--Step 3: Get Station Info
print('Getting Station Info')
local _,stationArray = sendMessage(svr.databaseID, {id='stations', action='getStationData'})

--Step 4: Get Node Info
print('Getting Node Info')
local _,nodeArray = sendMessage(svr.databaseID, {id='nodes', action='getAllNodes'})

--Step 5: Get waiting orders
print('Getting orders')
local _,orderArray = sendMessage(svr.databaseID, {id='orders', action='getWaitingOrders'})

function getItemsInArray(array, index, value)
  local output = {}
  for i,v in pairs(array) do
    if v[index] == value then
	  output[i] = v
	end
  end
  return output
end

function getOrders(status)
  local output = {}
  for _,order in pairs(orderArray) do
    if order.status == status then
      table.insert(order)
   end
  end
  return output
end

--[[term.clear()
term.setCursorPos(19, 9)
term.write('ORDERS SERVER')
term.setCursorPos(14, 11)
term.write('WAITING FOR MASTER SERVER')
term.setCursorPos(40, 19)
term.write('My ID is '..os.getComputerID())

repeat
  id,msg = rednet.receive()
  if msg == 'server.rollcall' then
    rednet.send(id, 'server.database')
    id,msg = rednet.receive()
  end
until msg == 'ok'

local masterID = id

term.clear()
term.setCursorPos(14,9)
term.write('CONNECTION ESTABLISHED')
term.setCursorPos(14, 11)
term.write('WAITING FOR GO SIGNAL')

repeat
  id,msg = rednet.receive()
until id == masterID and msg ~= 'server.rollcall'
svr = msg 

--]]

function debug(msg)
  if debugActive == true then
    print(msg)
  end
end

function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function logError(msg)
  rednet.send(svr.errorID, msg)
end

function eventAdd(msg)

	table.insert(eventArray, v)
	
	while #eventArray > 19 do
	  table.remove(eventArray, 1)
	end
	for i, v in pairs(eventArray) do
		term.setCursorPos(1,i)
		term.write('                                  ')
		term.setCursorPos(1,i)
		term.write(v)
	end
end

function getFreeChests()
  local count = 0
  for i=1, #chestArray do
    print(chestArray[i].status..':'..#getChestItems(chestArray[i].id)..':'..tonumber(chestArray[i].capacity))
    if chestArray[i].status == 'ready' and #getChestItems(chestArray[i].id) ~= tonumber(chestArray[i].capacity) then
      count = count + 1
    end
  end
  print('Number of free chests: '..count)
  return count
end

function getChestItems(chestID)
  local results = {}
  for i,v in pairs(itemArray) do
    if v.locationType == 'chest' and v.locationID == chestID then
	  table.insert(results, v)
	end
  end
  return results
end

function updateConsole()
  term.setCursorPos(41,12)
  term.write(#waitingOrders)
  term.setCursorPos(41,13)
  term.write(#activeOrders)
  term.setCursorPos(41,14)
  term.write(#holdOrders)
  term.setCursorPos(41,15)
  term.write(completedJobs)
  term.setCursorPos(41,16)
  term.write(#freeTurtles)
  term.setCursorPos(41,17)
  term.write(#activeTurtles)
end

function assignOrder(id)
  --Need to change for output / transfer orders
  local order = waitingOrders[1]
  
  --If no turtle id was specified, find the first 'ready' in turtleArray
  if id == nil then
    for i,_ in pairs(turtleArray) do
	  if turtleArray[i].status == 'READY' then
	    id = turtleArray[i].id
		break
	  end
	end
  end
  
  changeTurtleStatus(id, 'DOING_ORDER')
  print('Assigning order to Turtle '..id)
  
  --Find a chest to store the item 
  local destinationType, destinationID, destinationPos
  for i=1, #chestArray do
    if chestArray[i].status == 'READY' and #getChestItems(chestArray[i].id) ~= tonumber(chestArray[i].capacity) then
      chestArray[i].status = 'BUSY'
	  
	  destinationID = chestArray[i].id
	  destinationPos = #getChestItems(chestArray[i].id) + 1

	  sendMessage(svr.databaseID, {id='chests', action='update', chestID=chestArray[i].id, status=chestArray[i].status})
      break
    end
  end
  
  if destinationID == 'nil' then
    print('No available chests!')
	return
  end
  
  table.remove(waitingOrders, 1)
  
  --Debug
  debug(order.orderID)
  debug(order.orderType)
  debug(order.itemName)
  debug(order.displayName)
  debug(order.count)
  debug(order.dmg)
  debug(order.originType)
  debug(order.originID)
  debug(order.originPos)
  debug('Assigned to '..id)
  debug(destinationType)
  debug(destinationID)
  debug(destinationPos)
 
  --Step 3: Update order in database
  print('Assignning order')
  sendMessage(svr.databaseID, {id='orders', action='assign', orderID=order.orderID, assignTo=id, destinationType=destinationType, destinationID=destinationID, destinationPos=destinationPos})
  
  print('Updating status of order')
  sendMessage(svr.databaseID, {id='orders', action='updateStatus', orderID=order.orderID, status=1})
  
  --Step 5: Update order in activeOrders Array
  table.insert(activeOrders, {orderID=order.orderID, orderType=order.orderType, itemName=order.itemName, displayName=order.displayName, count=order.count, dmg=order.dmg, originType=order.originType, originID=order.originID, originPos=order.originPos, assignTo=id, destinationType=destinationType, destinationID=destinationID, destinationPos=destinationPos})

  --Step 6: Get current inventory of selected chest
  local chestInv = {}
  for i,v in pairs(itemArray) do
    if locationType == 'chest' and locationID == chestID then
      table.insert(chestInv, v)
    end
  end

  --Step 7: Give Turtle the order
  sendMessage(id, {option='newOrder',
                              chestInv=chestInv, 
							  orderID=order.orderID, 
							  orderType=order.orderType, 
							  itemName=order.itemName, 
							  displayName=order.displayName,
							  count=order.count, 
							  dmg=order.dmg, 
							  originType=order.originType, 
							  originID=order.originID, 
							  originPos=order.originPos, 
							  destinationType=destinationType, 
							  destinationID=destinationID, 
							  destinationPos=destinationPos})

  --Debug
  print('Gave Job '..order.orderID..' to Turtle '..id)
end

function resumeOrder(id)
  --Get order info that was assigned to this turtle
  changeTurtleStatus(id, 'busy') --Making sure. Defiantly unnecessary.
  
  local order = getItemsInArray(activeOrders, 'assignTo', id)
  local order = order[1] --Unpack array
  
  --Get Contents of chest to pickup
  local chestInv = {}
  for i,v in pairs(itemArray) do
    if locationType == 'chest' and locationID == chestID then
      table.insert(chestInv, v)
    end
  end

  --Send order to Turtle
  sendMessage(id, {option='resumeOrder',
                              chestInv=chestInv, 
							  orderID=order.orderID, 
							  orderType=order.orderType, 
							  itemName=order.itemName, 
							  displayName=order.displayName,
							  count=order.count, 
							  dmg=order.dmg, 
							  originType=order.originType, 
							  originID=order.originID, 
							  originPos=order.originPos, 
							  destinationType=order.destinationType, 
							  destinationID=order.destinationID, 
							  destinationPos=order.destinationPos})
							  
  print('Resume order successfully sent to Turtle '..id)
end

function updateItemLocation(itemRowID, locationType, locationID)
  --Update item in itemArray
  for i,v in pairs(itemArray) do
    if v.id == itemRowID then
	  itemArray[i].locationType = locationType
	  itemArray[i].locationID = locationID
	  break
	end
  end
  
  --Update item in Database
  sendMessage(svr.databaseID, {action='items', option='updateLocation', locationType=locationType, locationID=locationID})
end

function changeTurtleStatus(turtleID, status)
  for i,v in pairs(turtleArray) do
    if v.id == turtleID then
	  print('Changing status of Turtle '..turtleID..' to '..status)
	  turtleArray[i].status = status
	  sendMessage(svr.masterID, {action='UPDATE_TURTLE', turtleID=turtleID, status=status})
	  return
	end
  end
  
  --If Turtle doesn't exist, add to the list of turtles
  
  print('Turtle '..turtleID..' has been added, status: '..status)
  table.insert(turtleArray, {id=turtleID, status=status})
end

term.clear()
term.setCursorPos(1,1)
term.write('Waiting for activity...')

function drawConsole()
  for i=1, 19 do
    term.setCursorPos(35, i)
    term.write('||')
  end
  term.setCursorPos(37,2)
  term.write('ORDERS')
  term.setCursorPos(37,3)
  term.write('SERVER')
  term.setCursorPos(37,5)
  term.write('---------------')
  term.setCursorPos(37,7)
  term.write('My ID')
  term.setCursorPos(37,8)
  term.write('is '..compID)
  term.setCursorPos(37,10)
  term.write('---------------')
  term.setCursorPos(37,12)
  term.write('W:')
  term.setCursorPos(37,13)
  term.write('A:')
  term.setCursorPos(37,14)
  term.write('H:')
  term.setCursorPos(37,15)
  term.write('C:')
  term.setCursorPos(37,16)
  term.write('Ta:')
  term.setCursorPos(37,17)
  term.write('Tb:')
end

function switchStationMode(computerID, mode)
  print('Mark')
  for i,station in pairs(stationArray) do
    if tonumber(station.computerID) == computerID then
	  print('Mark')
	  
	  
	  stationArray[i]['mode'] = mode
	  --Send message to station
      sendMessage(computerID, {action='CHANGE_MODE', mode=mode})
      --Send message to database
      sendMessage(svr.databaseID, {id='stations', action='update', computerID=computerID, mode=mode})
      --Send message to master
      sendMessage(svr.masterID, {action='UPDATE_STATION', mode=mode, computerID=computerID})

	  break
	end
  end
end

function stationHasOrder(computerID)
  for i,station in pairs(stationArray) do
    if station.computerID == computerID then
	  for oI, order in pairs(orderArray) do
	    
		--Output
		if order.destinationID == station.nodeID then
		  return true
		end
		
		--Input
		if order.createdBy == station.computerID and orderType == 'INPUT' then
		  return true
		end
		
		--transfer?
		--Dunno. Get orders related to station via databaseID maybe?
		
	  end
	  return false
	end
  end
end


--updateConsole()

while true do
 	local action,id,msg = os.pullEvent()
 	if action == 'rednet_message' or action == 'key' then
	  print(action..' : '..id)
	end
	
 	if action == 'rednet_message' then
	
----------------------------------------------
	
 	  if msg.type == 'NEW_ITEM' then
	  --Received from stations from INPUT cycles
	        rednet.send(id, 'MESSAGE_RECEIVED')
	    	print('Got a new item')
		    print(msg.orderType..', Item: '..msg.displayName..' QTY: '..msg.count)
			print('Number of turtles ready: '..#getItemsInArray(turtleArray, 'status', 'ready'))
			
			--Input item into database, master and monitor
			local _, itemID = sendMessage(svr.databaseID, {id='items', action='new', itemName=msg.itemName, displayName=msg.displayName, modName=msg.modName, count=msg.count, dmg=msg.dmg, locationID=msg.locationID, locationPos=msg.locationPos})
		    table.insert(itemArray, {id=itemID, itemName=msg.itemName, displayName=msg.displayName, modName=msg.modName, count=msg.count, dmg=msg.dmg, locationID=msg.locationID, locationPos=msg.locationPos})
			--sendMessage(svr.masterID, {})
			--sendMessage(svr.monitorID, {})
			print(msg.count)
			
			--Input Order into database
		    local _, orderID = sendMessage(svr.databaseID, {id='orders', action='new', orderType=msg.orderType, itemID=itemID, reqCount=msg.count, createdBy=id})
		    table.insert(orderArray, {id=orderID, status='new', orderType=msg.orderType, itemID=msg.itemID, reqCount=msg.count, createdBy=id})
            --sendMessage(svr.masterID, {})
			--sendMessage(svr.monitorID, {})
			
			--[[
			if #getItemsInArray(turtleArray, 'status', 'ready') > 0 then
			  if getFreeChests() > 0 then 
		        print('Got a new order, assigning to available turtle')
				assignOrder()
    		  else
			    print('Got a new order, but no chests were available to store it')
			  end
			else
			  print('Got a new order, but no turtles were available to store it')
			  for i,v in pairs(turtleArray) do
			    print(v.id..':'..v.status)
			  end
    		end
			--]]
----------------------------------------------

	   elseif msg.type == 'NEW_ORDER' then
	     rednet.send(id, 'MESSAGE_RECEIVED')
	     print('Got a new order')
	     print(msg.orderType..', Item: '..msg.itemID..' QTY: '..msg.reqCount)
	     print('Number of turtles ready: '..#getItemsInArray(turtleArray, 'status', 'ready'))

		 --Input Order into database
		 local _, orderID = sendMessage(svr.databaseID, {id='orders', action='new', orderType=msg.orderType, itemID=itemID, reqCount=msg.reqCount, createdBy=id})
		 table.insert(orderArray, {id=orderID, status='new', orderType=msg.orderType, itemID=msg.itemID, reqCount=msg.reqCount, createdBy=id})
         --sendMessage(svr.masterID, {})
	     --sendMessage(svr.monitorID, {})
			
			
			--[[
			if #getItemsInArray(turtleArray, 'status', 'ready') > 0 then
			  if getFreeChests() > 0 then 
		        print('Got a new order, assigning to available turtle')
				assignOrder()
    		  else
			    print('Got a new order, but no chests were available to store it')
			  end
			else
			  print('Got a new order, but no turtles were available to store it')
			  for i,v in pairs(turtleArray) do
			    print(v.id..':'..v.status)
			  end
    		end
			--]]	 

----------------------------------------------
			
	   elseif msg.type == 'ORDER_COMPLETE' then
	   
		 debug(id)
		 debug(msg.orderID)
		 print('Turtle '..id..' completed order '..msg.orderID)

		 --Confirm
	     rednet.send(id, 'ok')
		 
		 --Mark chest as Available
		 chestArray[msg.chestID].status = 'READY'
		 sendMessage(svr.databaseID, {id='chests', action='update', chestID=msg.chestID , status='ready'})
		 print('Chest '..msg.chestID..' had its status changed to ready')
		 
		 --Update order in database
	     sendMessage(svr.databaseID, {id='orders', action='updateStatus', orderID=msg.orderID, status=2})
		 
		 --Update Item location in database
		 sendMessage(svr.databaseID, {id='items', action='update', itemID=msg.count, count=msg.count, locationType=msg.locationType, locationID=msg.locationID})
		 
		 --Update item location in table
		 for i,v in pairs(itemArray) do
		   if v.id == msg.itemID then
		     itemArray[i].locationType = msg.locationType
		     itemArray[i].locationID = msg.locationID
			 itemArray[i].locationPos = msg.locationPos
			 debug('Item location changed to '..msg.locationType..':'..msg.locationID..':'..msg.locationPos)
			 break
		   end
		 end
		 
	   	 --remove from activeOrders
	     for i,v in pairs(activeOrders) do
		   if v.id == msg.orderID then
             table.remove(activeOrders, i)
			 print('Order was removed from activeOrders')
			 break
		   end
		 end
		 
		 --Increment completed jobs
		 completedJobs = completedJobs + 1

	     if #getOrders('new') == 0 or getFreeChests() == 0 then
           --If no waiting orders or no free space in warehouse,
		   --Tell turtle to return to base
		   sendMessage(id, {option='returnToBase'})
           print('Turtle '..id..' is returning to base')
		   changeTurtleStatus(id, 'returningToBase')

	     else --If there are orders waiting to be assigned
		  print('Assigning Job to Turtle '..id)
		  assignOrder(id)
	     end
		 
	   elseif msg.type == 'order.hold' then
	     --Handles events such as orders that cannot be finished
		 print('Turtle '..id..' could not finish its order. Reason: '..msg.reason)
		 --sendMessage(svr.databaseID, {id='orders', action='updateStatus', orderID=msg.orderID, status=msg.status})
		 
----------------------------------------------
		 
	   elseif msg.action == 'ROLLCALL_TURTLE' then
	     --Confirm Acquisition
		 print('Rollcall Request Received')
		 rednet.send(id, {action='ROLLCALL_CONFIRM', data=svr})
		 
		 --ENGAGE.
		 if(#getItemsInArray(turtleArray, 'id', id) > 0) then
		  
		  --Turtle is present in turtleArray
		   local turtle = getItemsInArray(turtleArray, 'id', id)
		   local turtle = turtle[1]
		   
		   if(turtle.status == 'DOING_ORDER') then
		     --Turtle has an order assigned
			 print('Turtle '..id..' is resuming its order')
			 resumeOrder(id)
		   else
		     --Turtle does not have an order assigned
		     if(#getOrders('new') ~= 0) then
		       assignOrder(id)
		     else
		       changeTurtleStatus(id, 'RETURNING_TO_HARBOUR')
			   sendMessage(id, {option='RETURN_TO_HARBOUR'})
		       sendMessage(svr.masterID, {action='ADD_TURTLE', turtleID=id, status='RETURNING_TO_HARBOUR'})
			 end
		   end
		 --Turtle is not already added
		 else
		   if #getOrders('waiting') ~= 0 and getFreeChests() ~= 0 then
			 print('Gave order to turtle '..id)
			 assignOrder(id)
		     sendMessage(svr.masterID, {action='ADD_TURTLE', turtleID=id, status='DOING_ORDER'})
		   else
		     print('Turtle '..id..' is returning to its harbour')
		     changeTurtleStatus(id, 'RETURNING_TO_HARBOUR')
			 sendMessage(id, {option='RETURN_TO_HARBOUR'})
			 sendMessage(svr.masterID, {action='ADD_TURTLE', turtleID=id, status='RETURNING_TO_HARBOUR'})
		   end
		 end

----------------------------------------------
		 
	   elseif msg.action == 'ROLLCALL_STATION' then
		 print('Station Rollcall Received with ID of '..id)
         
		 --Find station in stationArray
		 local stationIndex		 
		 local stationInfo
		 for i,station in pairs(stationArray) do
		   if tonumber(station.computerID) == id then
		     stationIndex = i
			 stationInfo = station
		     break
		   end
		 end
		 
		 
		 if (stationInfo) then
		   --Station exists
		   --At the moment, station mode is based off what is in the database.
		   --In future, mode should depend on what mix of orders need to be completed
		   print('STATION '..id..' WAS ADDED TO STATION LIST')
		   rednet.send(id, {action='ROLLCALL_CONFIRM', mode=stationInfo.mode, stationID=stationInfo.nodeID, stationDirection=stationInfo.direction, orderID=svr.orderID})
		   stationArray[stationIndex]['active'] = true
		 else
		   --Station data is added to the database by the monitor server.
		   --If the server is not found, it is not in the database and will need to be readded.
		   print('ERROR: STATION NOT FOUND')
		   rednet.send(id, {action='ROLLCALL_ERROR', error='DOES_NOT_EXIST'})
		   --sendMessage(svr.errorID, {action='NEW_ERROR', error='Requested received from invalid station', priority=1})
		 end

---------------------------------------------- 
		 
	   elseif msg.action == 'turtle.ready' then
	     --Sent if a turtle is in a situation to complete an order
		 print('Turtle '..id..' is ready')
		 if #getOrders('new') ~= 0 and getFreeChests() ~= 0 then
			   print('Assigning order to '..id)
			   rednet.send(id, 'order_assign')
		       assignOrder(id)
		     else
			   --Should the turtle wait if the volume of jobs is high?
			   print('No order to give Turtle '..id..', sending to Harbour')
		       changeTurtleStatus(id, 'READY')
			   rednet.send(id, 'ROGER THAT CHARLIE')
		     end
		
----------------------------------------------
		
	   elseif msg.action == 'item.update' then
	     print('Turtle '..id..' updated item location')
		 sendMessage(svr.databaseID, {id='items', action='updateLocation', msg.locationType, msg.locationID, msg.locationPos})
         
	   elseif msg.action == 'getItemData' then
	     --Request sent by monitor and main server
		 print('Received request for item data from Computer'..id)
	     rednet.send(id, itemArray)
	   
	   elseif msg.action == 'getOrderCount' then
	     --Request sent by monitor
		 print('Received request for order count from Computer'..id)
		 rednet.send(id, {waiting=#getOrders('new') ,active=#getOrders('active'), hold=#getOrders('hold'), finished=completedJobs})
	   
	   elseif msg.action == 'getOrderData' then
	     --Request sent by monitor and main server
		 print('Received request for order data from Computer'..id)
		 rednet.send(id, orderArray)
	   
	   elseif msg.action == 'getTurtleData' then
	     --Request send by main server
		 print('Received request for turtle data from Computer'..id)
		 rednet.send(id, turtleArray)
	   
	   elseif msg.action == 'getStationData' then
	     --Request send by main server
		 print('Received request for station data from Computer'..id)
		 rednet.send(id, stationArray)
	   
	   elseif msg.action == 'addChestSlot' then
	     --Request send by monitor
		 --Add chest slot to node array
		 print('TODO: Adding chest node')
		 rednet.send(id, 'ok')
		 
	   elseif msg.action == 'deleteChestSlot' then
	     --Request send by monitor
		 --Delete chest slot, check if chest was in slot
		 --If chest was in slot, generate order to move that chest
		 print('TODO: Deleting chest node')
		 rednet.send(id, 'ok') 
		 
--------------------------------------
		 
	   elseif msg.action == 'CHANGE_STATION_MODE' then
	     --Received from masterID to change a station's mode
		 print('Changing station '..msg.computerID..' to '..msg.mode)
		 rednet.send(id, 'MESSAGE_RECEIVED')
		 
		 for i,station in pairs(stationArray) do
		   if tonumber(station.computerID) == msg.computerID then
		   
		     if stationArray[i].mode == msg.mode then
		     --If mode is already the same as requested, no need to change
		     else
		   
		       if stationArray[i].mode == 'OFFLINE' then
		         --Station is offline, has no orders, can switch instantly
		         switchStationMode(msg.computerID, msg.mode)
		       else
		         if stationHasOrder(stationArray[i].computerID) then
		           --Begin transition
				   --Set new station mode
			       stationArray[i]['transitionInto'] = msg.mode
				   
				   sendMessage(svr.databaseID, {id='stations', action='transition', computerID=stationArray[i].computerID, newMode=msg.mode})
		           
				   sendMessage(svr.masterID, {action='UPDATE_STATION', computerID=stationArray[i].computerID, mode= stationArray[i].mode, newMode=msg.mode})
				 else
			       --Station has no orders, can switch instantly
		           switchStationMode(msg.computerID, msg.mode)
		         end
               end
		     end
             print('Station mode switched')
		     break
		   end
		 end
		 

	   
-------------------------------------
   
	   elseif msg.action == 'deleteStation' then
	     --Request send by monitor
		 --All active orders with current station assigned to them need to be reassigned
		 --Hold orders should be check for missing stations when resumed
		 print('TODO: Deleting station')
		 rednet.send(id, 'ok')
	   
	   elseif msg.action == 'changeStatus' then
	     --Request send by main server
		 print('CHANGING STATUS TO '..msg.newStatus)
		 status = msg.newStatus
		 --Other things:
		   --If Repeat: generating orders if below a certain number
		   --If Offline: Send messages to all turtles to pause jobs/cancel jobs and return home
		   --If Pause: Tell all turtles to hold in place
		   --If Online: Assign orders at will, need a kickstart to get process going
		 rednet.send(id, 'ok')
	   end
	 elseif action=='key' and id==207 then
	   os.reboot()
	 end

	 --updateConsole()
end

