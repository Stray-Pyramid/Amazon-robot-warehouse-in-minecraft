--Implement priority in mapSettings
--Use switch statement for nodes + chests
--For turtles, use getNode(x, y), if exists, get priority etc else write

local monitor = peripheral.wrap('right')
local svr = {
  databaseID = 43,
  masterID    = 44,
  orderID       = 41,
  patherID = 42,
  fuelID = 87,
  commandID = 104
}

local warehouseSize = {x=25, y=50}
local currentMenu = 'mainMenu'

local colorList = {
  colors.white,
  colors.orange,
  colors.magenta,
  colors.lightBlue,
  colors.yellow,
  colors.lime,
  colors.pink,
  colors.gray,
  colors.lightGray,
  colors.cyan,
  colors.purple,
  colors.blue,
  colors.brown,
  colors.green,
  colors.red,
  colors.black,
}

--Default map settings
local sizeofMapSettings = 6
local mapSettings = {
  ['turtle'] = {priority=1 ,status='on', backColor=colors.green, character='T', textColor=colors.green},
  ['chest'] = {priority=2 ,status='on', backColor=colors.yellow, character='C', textColor=colors.green},
  ['chestSlot'] = {priority=3 ,status='on', backColor=colors.yellow, character='.', textColor=colors.green},
  ['station'] =   {priority=4 ,status='on', backColor=colors.orange, character='S', textColor=colors.green},
  ['obstacle'] = {priority=5 ,status='on', backColor=colors.red, character='*', textColor=colors.green},
  ['harbour'] = {priority=6 ,status='on', backColor=colors.gray, character='H', textColor=colors.green}
}

function saveMapSettings()
  local mergedOutput = ''
  
  --Implode Data into single string
  for i,v in pairs(mapSettings) do
    local concat = i..':'..v.priority..':'..v.status..':'..v.backColor..':'..v.character..':'..v.textColor
    mergedOutput = mergedOutput..'^'..concat
  end  
  
  --Open and write to mapSettings.txt
  local settingsFile = fs.open('mapSettings.txt', 'w')
  settingsFile.write(mergedOutput)
  settingsFile.close()
end

function loadMapSettings()
  local settingsOutput = {}
  if fs.exists('mapSettings.txt') then

    local settingsFile = fs.open('mapSettings.txt', 'r')
	local settingsString = settingsFile.readLine()
	settingsFile.close()
	
	--Explode data
	local t={} ; i=1
    for str in string.gmatch(settingsString, "([^%^]+)") do
      settingsOutput[i] = str
      i = i + 1
    end
		
	for n,v in pairs(settingsOutput) do
	  settingsOutput[n] = {}
	  local t={} ; i=1
	  for str in string.gmatch(v, "([^:]+)") do
        settingsOutput[n][i] = str
        i = i + 1
      end
	  mapSettings[settingsOutput[n][1]] = {}
	  mapSettings[settingsOutput[n][1]] = {priority =tonumber(settingsOutput[n][2]), status=settingsOutput[n][3], backColor=tonumber(settingsOutput[n][4]), character=settingsOutput[n][5], textColor=tonumber(settingsOutput[n][6])}
	end
  else
    saveMapSettings()
  end
end

function sendMessage(id, msg)
  local response
  local count = 1
  repeat
    print(count..'. Sending message to '..id)
    rednet.send(id,msg)
    response, rmsg = rednet.receive(2)
    count = count + 1
  until response == id
  return response, rmsg
end

function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function writeMonitor(x, y, msg)
  monitor.setCursorPos(x, y)
  monitor.write(msg)
end

function drawFacilityMap(x ,y)
  monitor.setBackgroundColor(colors.black)
  monitor.setTextColor(colors.green)
  for int=0, warehouseSize.x+1 do
    for v=0, warehouseSize.y+1 do
      if int == 0 or int == warehouseSize.x+1 then
        monitor.setCursorPos(int+x, v+y)
        monitor.write('|')
      elseif v == 0 or v == warehouseSize.y+1 then
        monitor.setCursorPos(int+x, v+y)
        monitor.write('-')
      end
    end
  end
end

function clearFacilityMap(x, y)
  monitor.setBackgroundColor(colors.black)
  for i=1, 50 do
    writeMonitor(x, y+i, '                          ')
  end
end

function drawNodes(x, y, filter, useSettings)
  if type(filter) ~= 'table' then
    print('Filter was replaced')
	filter = {'station', 'obstacle', 'chestSlot', 'harbour'}
  end
  
  if useSettings == nil then
    useSettings = false
  end
  
  monitor.setBackgroundColor(colors.black)
  monitor.setTextColor(colors.green)
  
  for i,v in pairs(nodes) do
    if table.contains(filter, v.type) then
	  if useSettings then
	    if mapSettings[v.type].status == 'on' then
	    monitor.setBackgroundColor(mapSettings[v.type].backColor)
        monitor.setTextColor(mapSettings[v.type].textColor)
		writeMonitor(v.x+1, v.y+1, mapSettings[v.type].character)
		end
	  else
	    writeMonitor(v.x+1, v.y+1, mapSettings[v.type].character)
	  end
	else
	end
  end
end

function drawChests(settings)
  settings.useSettings = settings.useSettings or false
  if settings.useSettings == true then
    monitor.setBackgroundColor(mapSettings['chest'].backColor)
	monitor.setTextColor(mapSettings['chest'].textColor)
  else
  	monitor.setBackgroundColor(colors.green)
	monitor.setTextColor(colors.green)
  end
  
  for _,chest in pairs(chests) do
    local nodeInfo = getNodeByID(chest.nodeID)
	if settings.useSettings then
	  writeMonitor(nodeInfo.x+1, nodeInfo.y+1, mapSettings['chest'].character)
	else
	  writeMonitor(nodeInfo.x+1, nodeInfo.y+1, mapSettings['chest'].character)
	end
  end
end

function loadingScreen()
  monitor.setBackgroundColor(colors.black)
  monitor.setTextColor(colors.white)
  monitor.setTextScale(1)
  monitor.clear()
  
  -- Find a modem
  local sModemSide = nil
  for n,sSide in ipairs( rs.getSides() ) do
    if peripheral.getType( sSide ) == "modem" and peripheral.call( sSide, "isWireless" ) then	
      sModemSide = sSide
      break
    end
  end
  
  if sModemSide == nil then
    print( "No wireless modems found. 1 required." )
    return false
  end
  rednet.open(sModemSide)
  
  
  writeMonitor(2,2, 'LOADING DATA')

  writeMonitor(2,5,'Nodes...')
  _,nodes = sendMessage(svr.databaseID, {id='nodes', action='getAllNodes'})
  writeMonitor(23, 5, 'LOADED')
  
  writeMonitor(2,7,'Chests...')
  _,chests = sendMessage(svr.databaseID, {id='chests', action='getAll'})
  writeMonitor(23, 7, 'LOADED')
  
  writeMonitor(2,9,'Items...')
  _,items = sendMessage(svr.orderID, {action='getItemData'})
  writeMonitor(23, 9, 'LOADED')
  
  writeMonitor(2,11,'Order Count...')
  _,orderCount = sendMessage(svr.orderID, {action='getOrderCount'})
  writeMonitor(23, 11, 'LOADED')
  
  writeMonitor(2,13,'Orders...')
  _,orders = sendMessage(svr.orderID, {action='getOrderData'})
  writeMonitor(23, 13, 'LOADED')

  writeMonitor(2,15,'Turtles...')
  _,turtles = sendMessage(svr.orderID, {action='getTurtleData'})
  writeMonitor(23, 15, 'LOADED')
  
  writeMonitor(2,17,'Facility Status...')
  _,facilityStatus = sendMessage(svr.masterID, {action='getFacilityStatus'})
  writeMonitor(23, 17, 'LOADED')
  
  writeMonitor(2,19,'Station Positions...')
  _,stations = sendMessage(svr.databaseID, {id='stations', action='getStationData'})
  writeMonitor(23, 19, 'LOADED')
  
  writeMonitor(2,21,'Fuel Count...')
  _,fuelAmount = sendMessage(svr.fuelID , {action='fuelCount'})
  writeMonitor(23, 21, 'LOADED')--]]
  
  return true
end

function getWarehouseCapacity()
  local itemNumber = #items
  local chests = #chests
  
  --Number of chests * chest capacity = total chest slots
  local totalSlots = chests * 15
  
  --Calculating the percentage slots used
  local percentage = math.floor((itemNumber / totalSlots)*100)
  
  return percentage..'% '..itemNumber..'/'..totalSlots..' SLOTS'
end

function drawSideBar()
  monitor.setBackgroundColor(colors.black)
  monitor.setTextColor(colors.white)

  writeMonitor(34, 6, ' CURRENT STATUS ')
  writeMonitor(34, 7, '----------------')
  
  writeMonitor(34, 12, ' ACTIVE TURTLES ')
  writeMonitor(34, 13, '----------------')
  writeMonitor(41, 14, ' '..#turtles..' ')
  
  writeMonitor(34, 18, ' NUMBER OF ITEMS ')
  writeMonitor(34, 19, '-----------------')
  writeMonitor(34, 20, '      '..#items..'       ')
  
  writeMonitor(32, 24, ' WAREHOUSE CAPACITY ')
  writeMonitor(32, 25, '--------------------')
  writeMonitor(32, 26, ' '..getWarehouseCapacity()..' ')

  writeMonitor(34, 30, ' FUEL REMAINING ')
  writeMonitor(34, 31, '----------------')
  writeMonitor(34, 32, '  '..fuelAmount..' PIECES   ')
  writeMonitor(34, 33, '    OF COAL     ')
  
  writeMonitor(34, 37, ' CURRENT ORDERS ')
  writeMonitor(34, 38, '----------------')
  writeMonitor(34, 39, '  W:'..orderCount.waiting..' A:'..orderCount.active..' H:'..orderCount.hold)
  
  if facilityStatus == 'ONLINE' then
    monitor.setTextColor(colors.green)
  elseif facilityStatus == 'REPEAT' then
    monitor.setTextColor(colors.blue)
  elseif facilityStatus == 'PAUSE' then
    monitor.setTextColor(colors.yellow)
  elseif facilityStatus == 'OFFLINE' then
    monitor.setTextColor(colors.red)
  end
  writeMonitor(39, 8, facilityStatus)
  
  monitor.setTextColor(colors.white)
  monitor.setBackgroundColor(colors.red)
  writeMonitor(38, 43, '       ')
  writeMonitor(38, 44, ' ERROR ')
  writeMonitor(38, 45, '       ')
  
  monitor.setBackgroundColor(colors.white)
  monitor.setTextColor(colors.black)
  writeMonitor(37, 48, '         ')
  writeMonitor(37, 49, ' OPTIONS ')
  writeMonitor(37, 50, '         ')
end

function errorMenu()
  monitor.setTextScale(1)
  monitor.setBackgroundColor(colors.black)
  monitor.setTextColor(colors.white)
  monitor.clear()
  
  writeMonitor(2,2, 'ERRORS')
  writeMonitor(2,3, '-------')
  
  writeMonitor(2,5, 'There are no errors yet')
  writeMonitor(2,6, 'The day is still fresh')
  
  monitor.setBackgroundColor(colors.white)
  monitor.setTextColor(colors.black)
  writeMonitor(23, 23, '      ')
  writeMonitor(23, 24, ' BACK ')
  writeMonitor(23, 25, '      ')
  
end


function optionsMenu()
  monitor.setTextScale(1)
  monitor.setBackgroundColor(colors.black)
  monitor.setTextColor(colors.white)
  monitor.clear()
  
  writeMonitor(11, 2, '---------')
  writeMonitor(11, 3, ' OPTIONS ')
  writeMonitor(11, 4, '---------')
  
  writeMonitor(8, 6, 'MAP VISIBILITY')
  writeMonitor(11, 7, 'OPTIONS')
  
  monitor.setBackgroundColor(colors.white)
  monitor.setTextColor(colors.black)
  
  writeMonitor(4, 17, '                      ')
  writeMonitor(4, 18, ' VIEW PATHER ACTIVITY ')
  writeMonitor(4, 19, '                      ')
  
  writeMonitor(2, 22, '        ')
  writeMonitor(2, 23, ' MANAGE ')
  writeMonitor(2, 24, ' CHESTS ')
  writeMonitor(2, 25, '        ')
  
  writeMonitor(11, 22, '        ')
  writeMonitor(11, 23, ' MANAGE ')
  writeMonitor(11, 24, ' NODES  ')
  writeMonitor(11, 25, '        ')
  
  writeMonitor(23, 23, '      ')
  writeMonitor(23, 24, ' BACK ')
  writeMonitor(23, 25, '      ')
  
  for int, value in pairs(mapSettings) do
	if value.priority == 1 then
	  monitor.setBackgroundColor(colors.black)
	  monitor.setTextColor(colors.gray)
	  writeMonitor(2, 9+value.priority, '^')
	  
	  monitor.setBackgroundColor(colors.white)
	  monitor.setTextColor(colors.black)
	  writeMonitor(3, 9+value.priority, 'V')
	  
	elseif value.priority == sizeofMapSettings then
	  monitor.setBackgroundColor(colors.white)
	  monitor.setTextColor(colors.black)
	  writeMonitor(2, 9+value.priority, '^')
	  
	  monitor.setBackgroundColor(colors.black)
	  monitor.setTextColor(colors.gray)
	  writeMonitor(3, 9+value.priority, 'V')
	
	else 
	  monitor.setBackgroundColor(colors.white)
	  monitor.setTextColor(colors.black)
	  writeMonitor(2, 9+value.priority, '^V')
	end
	
	if value.status == 'on' then
	  monitor.setBackgroundColor(colors.green)
	  monitor.setTextColor(colors.black)
	  
	  writeMonitor(15, 9+value.priority, 'ON')
	  monitor.setBackgroundColor(colors.black)
	  monitor.setTextColor(colors.white)
	  writeMonitor(17, 9+value.priority, '-')
	  
	  monitor.setBackgroundColor(colors.white)
	  monitor.setTextColor(colors.lightGray)
	  writeMonitor(18, 9+value.priority, 'OFF')
	else
	  monitor.setBackgroundColor(colors.white)
	  monitor.setTextColor(colors.lightGray)
	  writeMonitor(15, 9+value.priority, 'ON')
	  
	  monitor.setBackgroundColor(colors.black)
	  monitor.setTextColor(colors.white)
	  writeMonitor(17, 9+value.priority, '-')
	  
	  monitor.setBackgroundColor(colors.red)
	  monitor.setTextColor(colors.black)
	  writeMonitor(18, 9+value.priority, 'OFF')
	end
	
	monitor.setBackgroundColor(value.backColor)
	writeMonitor(22, 9+value.priority, '     ')
	
	monitor.setBackgroundColor(colors.black)
	monitor.setTextColor(colors.white)
	writeMonitor(5, 9+value.priority, int)
	
    monitor.setTextColor(value.textColor)
	writeMonitor(28, 9+value.priority, value.character)
	
  end
  
end

function chestsMenu()
  monitor.setTextScale(0.5)
  monitor.setBackgroundColor(colors.black)
  monitor.clear()
  drawFacilityMap(1, 1)
  
  writeMonitor(29, 36, '<---  SELECT A CHEST')
  
  monitor.setTextColor(colors.white)
  --Draw chest nodes
  drawNodes(1,1, {'chestSlot'})
  
  --Status
  --ready: green
  --busy: red

  --Draw chest 'C' where there is a chest
  for i,chest in pairs(chests) do
    local nodeInfo = getNodeByID(chest.nodeID)
    if chest.status == 'ready' then
	  monitor.setTextColor(colors.green)
	  writeMonitor(nodeInfo.x+1, nodeInfo.y+1, 'C')
	elseif chest.status == 'busy' then
	  monitor.setTextColor(colors.red)
	  writeMonitor(nodeInfo.x+1, nodeInfo.y+1, 'C')
	end
  end
  
  --Draw stations, Capacity of 54 items, normally all with items with orders.
  --Have ability to cancel order for items in stations, but force to create a replacement order
  --Input, send item to a chest with capacity. Chests without capacity will be marked in red
  --Output, send item to green-ender-chest immediately.
  monitor.setTextColor(colors.yellow)
  for i,v in pairs(stations) do
    local stationNode = getNodeByID(v.nodeID)
    writeMonitor(stationNode.x+1, stationNode.y+1, 'S')
  end
  
  
  monitor.setBackgroundColor(colors.white)
  monitor.setTextColor(colors.black)
  writeMonitor(51, 49, '      ')
  writeMonitor(51, 50, ' BACK ')
  writeMonitor(51, 51, '      ')
end

function getNodesOfType(nodeType)
  local nodesOutput = {}
  for i,v in pairs(nodes) do
    if v.type == nodeType then
	  table.insert(nodesOutput, v)
	end
  end
  return nodesOutput
end

function isNode(x, y, filter)
  local filter = filter or {'chestSlot', 'obstacle', 'station', 'harbour'}
  for i,v in pairs(nodes) do
    print(x..':'..y..' '..v.x..':'..v.y)
	if tonumber(v.x) == x and tonumber(v.y) == y and table.contains(filter, v.type) then
	  return true
	end
  end
  return false
end

function getNode(x, y)
  for i,v in pairs(nodes) do
    if tonumber(v.x) == tonumber(x) and tonumber(v.y) == tonumber(y) then
	  print(i, v.id, v.type, v.x, v.y)
	  return {index=i, id=v.id, type=v.type, x=v.x, y=v.y}
	end
  end
  print('NO NODE FOUND')
  return
end

function isChestBusy(nodeID)
  for i,v in pairs(chests) do
    if v.nodeID == nodeID then
	  if v.status == 'busy' then
	    return true
	  else
	    return false
	  end
	end
  end
end

function getOrdersByStatus(status)
  local output = {}
  for i,v in pairs(orders) do
    if v.status == status then
      table.insert(v)
   end
  end
  return output
end

function getOrder(itemInfo)
  --Get order type
  
  --Light blue, blackText : New
  --Red , whiteText:    Active
  --Yellow, blackText : Hold

    for i,v in pairs(orders) do
	
	if v.itemID == itemInfo.id then
      return v
	end
  end
  print('No order assigned to item '..itemInfo.id)
  return
end

function nodesMenu()
  monitor.setTextScale(0.5)
  monitor.setBackgroundColor(colors.black)
  monitor.clear()
  drawFacilityMap(1,1)
  drawNodes(1, 1)
  
  monitor.setBackgroundColor(colors.black)
  monitor.setTextColor(colors.green)
  
  writeMonitor(35, 12, ' TOTAL OBSTACLES')
  writeMonitor(35, 13, '----------------')
  writeMonitor(35, 14, '      '..#getNodesOfType('obstacle')..'       ')
  
  writeMonitor(35, 16, ' TOTAL STATIONS')
  writeMonitor(35, 17, '----------------')
  writeMonitor(35, 18, '      '..#stations..'       ')
  
  writeMonitor(32, 20, ' TOTAL CHEST SLOT NODES')
  writeMonitor(32, 21, '------------------------')
  writeMonitor(34, 22, '       '..#getNodesOfType('chestSlot')..'       ')
  
  writeMonitor(34, 24, ' TOTAL HARBOUR NODES')
  writeMonitor(34, 25, '---------------------')
  writeMonitor(34, 26, '       '..#getNodesOfType('harbour')..'       ')
  
  writeMonitor(31, 30, '<---  SELECT A NODE')
  
  monitor.setBackgroundColor(colors.white)
  monitor.setTextColor(colors.black)
  writeMonitor(51, 49, '      ')
  writeMonitor(51, 50, ' BACK ')
  writeMonitor(51, 51, '      ')
end

function newNodeMenu(x, y)
  monitor.setBackgroundColor(colors.black)
  writeMonitor(31, 30, '                  ')
  writeMonitor(40, 31, '                  ')
  monitor.setBackgroundColor(colors.white)
  monitor.setTextColor(colors.black)
  writeMonitor(31, 30, 'CREATE NEW NODE AT')
  writeMonitor(40, 31, x..':'..y)
  
  writeMonitor(30, 33, 'CHEST SLOT')
  writeMonitor(30, 35, 'OBSTACLE  ')
  writeMonitor(30, 37, 'HARBOUR   ')
  writeMonitor(30, 39, 'STATION   ')
end

function editNodeMenu(x, y)
  monitor.setBackgroundColor(colors.white)
  monitor.setTextColor(colors.black)
  
  local nodeInfo = getNode(x, y)
  if nodeInfo.type == 'chest' and #getNodesOfType('chest')-1 <= #chests then
    --If # of chest nodes == # of chests, there will be no other place to put the chest
	--when the chest node it is on is deleted
	writeMonitor(30, 30, ' CANNOT DELETE CHEST NODE ')
    writeMonitor(30, 31, ' NO PLACES TO PUT CHEST ')
  else
    writeMonitor(31, 30, ' DELETE '..string.upper(nodeInfo.type)..' NODE AT ')
    writeMonitor(40, 31, ''..x..':'..y..' ?')
    writeMonitor(30, 33, 'CONFIRM')
  end
end

function drawConfirmButton(x, y, isDisabled)
  local isDisabled = isDisabled or false
  if isDisabled == true then
    monitor.setBackgroundColor(colors.red)
    monitor.setTextColor(colors.white)
  else
    monitor.setBackgroundColor(colors.red)
    monitor.setTextColor(colors.white)
  end
  writeMonitor(x, y, '         ')
  writeMonitor(x, y+1, ' CONFIRM ')
  writeMonitor(x, y+2, '         ')
end

function clearActionMenu()
  monitor.setBackgroundColor(colors.black)
  for i=0, 13 do
    writeMonitor(29, 30+i, '                            ')
  end
end

function createNode(x, y, nodeType, direction)
  monitor.setBackgroundColor(colors.black)
  monitor.setTextColor(colors.white)  
  clearActionMenu()
  writeMonitor(34, 34, 'INITILAZING NODE')
  
  print(x)
  print(y)
  print(nodeType)
  print(direction)
  
  if nodeType == 'station' then
    --Shit goes down.
	--Create station in warehouse
	local _,computerID = sendMessage(svr.commandID, {id='buildStation', x=x, y=y, direction=direction})
	local ob1, ob2, ob3
	local _,nodeID
	
	--Create obstacles for station
	if direction == 'NORTH' then
	  ob1 = createNode(x, y-1, 'obstacle')
	  ob2 = createNode(x, y-2, 'obstacle')
	  ob3 = createNode(x, y-3, 'obstacle')
	elseif direction == 'SOUTH' then
	  ob1 = createNode(x, y+1, 'obstacle')
	  ob2 = createNode(x, y+2, 'obstacle')
	  ob3 = createNode(x, y+3, 'obstacle')
	elseif direction == 'EAST' then
      ob1 = createNode(x+1, y, 'obstacle')
	  ob2 = createNode(x+2, y, 'obstacle')
	  ob3 = createNode(x+3, y, 'obstacle')
	elseif direction == 'WEST' then
	  ob1 = createNode(x-1, y, 'obstacle')
	  ob2 = createNode(x-2, y, 'obstacle')
	  ob3 = createNode(x-3, y, 'obstacle')
	end

	--Create station node
	local _,nodeID = sendMessage(svr.databaseID, {id='nodes', action='insert', type='station', x=x, y=y})
	
    --Add locally
	table.insert(stations, {compuerID=computerID, nodeID=nodeID, direction=direction, mode='offline', ob1=ob1, ob2=ob2, ob3=ob3})
    table.insert(nodes, {id=nodeID, type=nodeType, x=x, y=y})

	--Create station in database
	sendMessage(svr.databaseID, {id='stations', action='insert', computerID=computerID, nodeID=nodeID, direction=direction, mode='offline', ob1=ob1, ob2=ob2, ob3=ob3})
		
	--Add to orderID
    sendMessage(svr.orderID, {action='addStation', computerID=computerID, nodeID=nodeID, mode='offline', ob1=ob1, ob2=ob2, ob3=ob3})
	
	--Add to patherID
    sendMessage(svr.patherID, {action='addSetNode', data={type='station', x=x, y=y}})

  else
    --Piece of cake.
	_,nodeID = sendMessage(svr.databaseID, {id='nodes', action='insert', type=nodeType, x=x, y=y })
    sendMessage(svr.patherID, {action='addSetNode', data={nodeID=nodeID, type=nodeType, x=x, y=y }})
	table.insert(nodes, {id=nodeID, type=nodeType, x=x, y=y})
    
	if nodeType == 'chest' then
	  sendMessage(svr.orderID, {action='addChestSlot', id=nodeID, x=x, y=y, nodeType=nodeType})
	end
  end

  writeMonitor(33, 34, string.upper(nodeType)..' NODE CREATED ')
  
  os.sleep(1)
  nodesMenu()
  return nodeID
end

function deleteNode(x, y)
  --Similar format to create node
  print('x: '..x)
  print('y: '..y)
  local nodeData = getNode(x, y)
  

  if nodeData.type == 'station' then
	 --Delete node locally + database
	 --Get station Data
	 
	 local stationIndex
	 local stationData
	 print(#stations)
	 for i,v in pairs(stations) do
	   print(nodeData.id..':'..v.nodeID)
	   if nodeData.id == v.nodeID then
	     stationData = v
		 stationIndex = i
		 print('Station found')
		 break
	   end
	 end
	 
	 --ob1, ob2, ob3
	 --Delete three obstacles that are associated with station
     local obstacle_1 = getNodeByID(stationData.ob1)
	 local obstacle_2 = getNodeByID(stationData.ob2)
	 local obstacle_3 = getNodeByID(stationData.ob3)
	 
	 --Getting the direction of the station by the position of the obstacles attached to it
	 --Because fuck simplicity
	 local diffX = x-obstacle_1.x
	 local diffY = y-obstacle_1.y
	 local direction
	 if diffX > 0 then
	   direction = 'west'
	 elseif diffX < 0 then
	   direction = 'east'
	 elseif diffY < 0 then
	   direction = 'south'
	 elseif diffY > 0 then
	   direction = 'north'
	 end
	 
	 --Delete station in warehouse
	 sendMessage(svr.commandID, {id='removeStation', x=nodeData.x, y=nodeData.y, direction=direction})
	 
	 --Delete station node
	 table.remove(nodes, nodeData.index)
	 
	 deleteNode(obstacle_1.x, obstacle_1.y)
     deleteNode(obstacle_2.x, obstacle_2.y)
     deleteNode(obstacle_3.x, obstacle_3.y)
	 
	 --Delete station node
	 sendMessage(svr.databaseID, {id='nodes', action='delete', nodeID=nodeData.id})
	 
	 --Delete station info
	 sendMessage(svr.databaseID, {id='stations', action='delete', nodeID=nodeData.id})
	 table.remove(stations, stationIndex)
	 
	 --Remove station from pather
	 sendMessage(svr.patherID, {action='deleteSetNode', stationID=nodeData.id})
	 
	 --This will cause a real shit storm when this is sent...
	 sendMessage(svr.orderID, {action='deleteStation', station=stationData.nodeID})	 
	 
  else
    --Delete node locally + database, send message to pather to update
	print('Deleting node with id '..nodeData.id)
	sendMessage(svr.databaseID, {id='nodes', action='delete', nodeID=nodeData.id})
    sendMessage(svr.patherID, {action='deleteSetNode', nodeID=nodeData.id})
	table.remove(nodes, nodeData.index)
	
	if nodeData.type == 'chest' then
	  sendMessage(svr.orderID, {action='deleteChestSlot', id=nodeData.id})
	end

  end
  
  clearActionMenu()
  monitor.setTextColor(colors.white)
  writeMonitor(35, 30, ' NODE DELETED')
  os.sleep(1)
  
  nodesMenu()
  
end

function getNodeByID(nodeID)
  for i,v in pairs(nodes) do
    if tonumber(v.id) == tonumber(nodeID) then
	  return {index=i, id=v.id, type=v.type, x=v.x, y=v.y}
	end
  end
  print('Could not find node with ID of '..nodeID)
  return false
end

function patherMenu()
  monitor.setTextScale(0.5)
  monitor.setBackgroundColor(colors.black)
  monitor.clear()
  drawFacilityMap(1,1)
  drawNodes(1,1, {'obstacle'})
  
  monitor.setBackgroundColor(colors.black)
  monitor.setTextColor(colors.white)
  writeMonitor(38, 6, 'TURTLE ID')
  writeMonitor(37, 7, '-------------')
  
  writeMonitor(35, 11, 'START POSITION')
  writeMonitor(34, 12, '------------------')
  
  writeMonitor(37, 16, 'END POSITION')
  writeMonitor(36, 17, '--------------')
  
  writeMonitor(35, 21, 'NUM OF OBSTACLES')
  writeMonitor(34, 22, '------------------')
  writeMonitor(42, 23, tostring(#getNodesOfType('obstacle')))
  --Added tostring otherwise 13 will appear as 13.0
  
  writeMonitor(35, 26, 'NUM OF OPEN NODES')
  writeMonitor(34, 27, '-------------------')
  
  writeMonitor(34, 31, 'NUM OF CLOSED NODES')
  writeMonitor(33, 32, '---------------------')

  writeMonitor(37, 36, 'CURRENT NODE')
  writeMonitor(36, 37, '--------------')
  
  monitor.setTextColor(colors.black)
  monitor.setBackgroundColor(colors.pink)
  writeMonitor(31, 49, '                ')
  writeMonitor(31, 50, '  CONNECTING    ')
  writeMonitor(31, 51, '                ')
  
  monitor.setBackgroundColor(colors.white)
  writeMonitor(51, 49, '      ')
  writeMonitor(51, 50, ' BACK ')
  writeMonitor(51, 51, '      ')
  
end

function resetNodeOnMap(nodeX, nodeY)
  --Possible : Add position of map on monitor
  local nodeData = getNode(nodeX, nodeY)
  monitor.setBackgroundColor(colors.black)
  monitor.setTextColor(colors.green)
  if nodeData == nil then
    writeMonitor(nodeX+1, nodeY+1, ' ')
  else 
    writeMonitor(nodeX+1, nodeY+1, mapSettings[nodeData.type].character)
  end 
end

function highlightNodeOnMap(nodeX, nodeY)
  local nodeData = getNode(nodeX, nodeY)
  monitor.setBackgroundColor(colors.white)
  monitor.setTextColor(colors.red)
  if nodeData == nil then
    writeMonitor(nodeX+1, nodeY+1, ' ')
  else 
    writeMonitor(nodeX+1, nodeY+1, mapSettings[nodeData.type].character)
  end 
end

function canCreateStation(x, y, direction)
  if direction == 'north' and (y < 4                               or (isNode(x,y-1) or isNode(x,y-2) or isNode(x,y-3))) then
    print('Cannot create station at '..x..':'..y..' facing '..direction)
	return false
  elseif direction == 'south' and (y > warehouseSize.y-3 or (isNode(x,y+1) or isNode(x,y+2) or isNode(x,y+3))) then
    print('Cannot create station at '..x..':'..y..' facing '..direction)
	return false
  elseif direction == 'east' and (x > warehouseSize.x-3   or (isNode(x+1,y) or isNode(x+2,y) or isNode(x+3,y))) then
	print('Cannot create station at '..x..':'..y..' facing '..direction)
	return false
  elseif direction == 'west' and (x < 4                           or (isNode(x-1,y) or isNode(x-2,y) or isNode(x-3,y))) then
    print('Cannot create station at '..x..':'..y..' facing '..direction)
	return false
  end
  print('Can create station at '..x..':'..y..' facing '..direction)
  return true
end

function drawStationDirection(x, y)
  monitor.setBackgroundColor(colors.gray)
  monitor.setTextColor(colors.lightGray)
  writeMonitor(43, 34, '^')
  writeMonitor(43, 35, '|')
  writeMonitor(41, 36, '<- ->')
  writeMonitor(43, 37, '|')
  writeMonitor(43, 38, 'V')
  
  monitor.setBackgroundColor(colors.white)
  monitor.setTextColor(colors.black)
  if canCreateStation(x, y, 'north') == true then 
    writeMonitor(43, 34, '^')
    writeMonitor(43, 35, '|')
  end
  if canCreateStation(x, y, 'east') == true then 
    writeMonitor(44, 36, '->')
  end
  if canCreateStation(x, y, 'west') == true then
    writeMonitor(41, 36, '<-')
  end
  if canCreateStation(x, y, 'south') == true then
    writeMonitor(43, 37, '|')
    writeMonitor(43, 38, 'V')
  end
end

function hasChest(x,y)
  local chestNode = getNode(x, y)
  if chestNode ~= nil then
    for _,chest in pairs(chests) do
      if chest.nodeID == chestNode.id then
	    print('Chest Found at '..x..':'..y)
	    return true
	  end
    end
  end
  print('Chest not found')
  return false
end

function clearChestMenu()
  monitor.setBackgroundColor(colors.black)
  
  for i=1, 48 do
    writeMonitor(28, i, '                              ')
  end
  
  for i=1, 4 do
    writeMonitor(28, i+48, '                       ')
  end
end

function editChestMenu(nodeInfo)
  --Get info of chest
  clearChestMenu()

  --nodeInfo: x, y, type, id
  local chestInfo
  local chestItems = {}
  
  if nodeInfo.type ~= nil then
    if nodeInfo.type == 'chestSlot' then
      if hasChest(nodeInfo.x,nodeInfo.y) then
	  --Get chest info
	  for _,chest in pairs(chests) do
        if chest.nodeID ==  nodeInfo.id then
	      chestInfo = chest
	      break
	    end
      end
	  
	  
      --Get array of items in chest
      for i,item in pairs(items) do
        if chestInfo.nodeID == item.locationID then
	      chestItems[tonumber(item.locationPos)] = item
	    end
      end

      monitor.setBackgroundColor(colors.black)
      monitor.setTextColor(colors.green)
      
	  --Display contents of chest
	  if chestInfo.status == 'busy' then
	    monitor.setTextColor(colors.red)
	    writeMonitor(51, 13, '(BUSY)')
	  end
	  writeMonitor(28, 13, 'CONTENTS OF CHEST '..nodeInfo.id)
	  writeMonitor(28, 14, nodeInfo.x..':'..nodeInfo.y)
	  --Capacity of chest
      writeMonitor(38, 14, #chestItems..'/'..chestInfo.capacity)
	  
	  
      monitor.setTextColor(colors.green)
	
	  --Maximum of 15 items can be displayed because of size of monitor. 
	  --Fortunately, chests can only hold 15 items at this time
	  --Light blue, blackText : New
      --Red , whiteText:    Active
      --Yellow, blackText : Hold
	  
	  for i=1, 15 do
	    if chestItems[i] ~= nil then
		  local order = getOrder(chestItems[i])
		  if order == nil or order.status == 'cancelled' or order.status == 'complete' then
		    --Item has no order attached to it (That is active, new or hold)
			monitor.setBackgroundColor(colors.black)
		    monitor.setTextColor(colors.green)
		    writeMonitor(47, 16+(2*i), 'REQ TRANS')
		  
		  elseif order.status == 'active' then
	        monitor.setBackgroundColor(colors.red)
			monitor.setTextColor(colors.white)
			
		    writeMonitor(28, 15+(2*i), '                              ')
		    writeMonitor(28, 16+(2*i), '                              ')
			writeMonitor(47, 16+(2*i), 'VIEW ORDER')
			
	      elseif order.status == 'new' then
		    monitor.setBackgroundColor(colors.lightBlue)
			monitor.setTextColor(colors.black)
            
			writeMonitor(28, 15+(2*i), '                              ')
		    writeMonitor(28, 16+(2*i), '                              ')
			writeMonitor(47, 16+(2*i), 'VIEW ORDER')
          elseif order.status == 'hold' then
		    monitor.setBackgroundColor(colors.yellow)
			monitor.setTextColor(colors.black)
		    
			writeMonitor(28, 15+(2*i), '                              ')
		    writeMonitor(28, 16+(2*i), '                              ')
			writeMonitor(47, 16+(2*i), 'VIEW ORDER')
		  end
		  writeMonitor(28, 15+(2*i), i..':')
	      writeMonitor(31, 15+(2*i), chestItems[i].displayName)
	      writeMonitor(31, 16+(2*i), 'QTY:'..chestItems[i].count)
	      writeMonitor(38, 16+(2*i), 'DMG:'..chestItems[i].dmg)
		  
	    else
		  monitor.setBackgroundColor(colors.black)
		  monitor.setTextColor(colors.green)
		  writeMonitor(28, 15+(2*i), i..':')
	      writeMonitor(31, 15+(2*i), 'NO ITEM')
	    end
      end
	
      --Option to move chest
      writeMonitor(30, 49, '>MOVE CHEST')
  
      --Option to delete chest
      writeMonitor(30, 51, '>DELETE CHEST')
	else --If chestSlot with no chest
	  writeMonitor(37, 35, nodeInfo.x..':'..nodeInfo.y)
      writeMonitor(37, 36, 'CHEST SLOT')
    end
  elseif nodeInfo.type == 'station' then
   
  end
  else
    writeMonitor(37, 35, nodeInfo.x..':'..nodeInfo.y)
    writeMonitor(37, 36, 'NO CHEST OR STATION')
  end
end

function mainMenu()
  monitor.setTextScale(0.5)
  monitor.setBackgroundColor(colors.black)
  monitor.clear()
  drawFacilityMap(1,1)
  drawNodes(1, 1, _, true)
  
  if mapSettings['chest'].status == 'on' then
    drawChests({useSettings=true})
  end
  
  drawSideBar()
end

function createColorPalette()
  local paletteWindow = window.create(monitor, 2, 10, 27, 6)
  paletteWindow.setBackgroundColor(colors.lightGray)
  paletteWindow.clear()
  
  paletteWindow.setCursorPos(7, 2)
  paletteWindow.write('CHOOSE A COLOR')
  
  paletteWindow.setCursorPos(11, 6)
  paletteWindow.write('CANCEL')
  
  for i,v in ipairs(colorList) do
    paletteWindow.setCursorPos(i+5, 4)
    paletteWindow.setBackgroundColor(v)
	paletteWindow.write(' ')
  end
end

function rednetUpdate(id, msg)  
  --It begins
  if msg.id == 'pather' then
    if currentMenu == 'patherMenu' then
	  monitor.setTextColor(colors.white)
      monitor.setBackgroundColor(colors.black)
      if msg.action == 'newPath' then
	    clearFacilityMap(1,1)
	    drawFacilityMap(1,1)
        drawNodes(1,1, {'obstacle'})
	  
	    --Draw nodes will set text colour to green, need to change it back
	    monitor.setTextColor(colors.white)
        monitor.setBackgroundColor(colors.black)

	    writeMonitor(31, 49, '                    ')
	    writeMonitor(31, 50, '    FINDING PATH    ')
	    writeMonitor(31, 51, '                    ')
	  
	    writeMonitor(40, 8, msg.turtleID)
	    writeMonitor(40, 13, msg.startPos)
	    writeMonitor(40, 18, msg.endPos)
	    writeMonitor(32, 28, '                 ')
	    writeMonitor(32, 33, '                 ')
	    writeMonitor(32, 38, '                 ')
	  
	  
	  elseif msg.action == 'foundPath' then
	    writeMonitor(31, 49, '                  ')
	    writeMonitor(31, 50, '   PATH FOUND     ')
	    writeMonitor(31, 51, '                  ')
	  
	    monitor.setBackgroundColor(colors.green)
	    monitor.setTextColor(colors.white)
	    for i,v in pairs(msg.path) do
	      writeMonitor(v.x+1, v.y+1, 'C')
	    end
	  
	  elseif msg.action == 'cannotFindPath' then
	    writeMonitor(31, 49, '                    ')
	    writeMonitor(31, 50, '    NO PATH     ')
	    writeMonitor(31, 51, '                    ')
	  
	  elseif msg.action == 'addOpenNode' then
	    writeMonitor(42, 28, tostring(msg.count))
	    writeMonitor(msg.x+1, msg.y+1, 'O')

	  elseif msg.action == 'addClosedNode' then
	    --Increment number of closed node
	    --Decrement number of open nodes
        --Add closed node on map
	    --Closed node is current node
	    writeMonitor(42, 33, tostring(msg.Ccount))
	    writeMonitor(42, 28, tostring(msg.Ocount))
	    writeMonitor(msg.x+1, msg.y+1, 'C')
	    writeMonitor(40, 38, msg.x..':'..msg.y..' ')
	  
      end
	  --end
    end
    rednet.send(id, 'ok')
  elseif id == svr.masterID then
    if msg.action == 'newStatus' then
	  facilityStatus = msg.newStatus
	  rednet.send(id, 'ok')
	  if currentMenu == 'mainMenu' then
	    monitor.setBackgroundColor(colors.black)
	    writeMonitor(39, 8, '        ')
	    if facilityStatus == 'ONLINE' then
		  monitor.setTextColor(colors.green)
		elseif facilityStatus == 'REPEAT' then
		  monitor.setTextColor(colors.blue)
		elseif facilityStatus == 'PAUSE' then
		  monitor.setTextColor(colors.yellow)
		elseif facilityStatus == 'OFFLINE' then
		  monitor.setTextColor(colors.red)
		end
	    writeMonitor(39, 8, facilityStatus)
	  end
	end
  end
end

--Get map settings from mapSettings.txt
loadMapSettings()

--Load data from servers
if not loadingScreen() then return end

--Draw the main menu
mainMenu()

--Start main loop
while true do
  local event, id, infoA, infoB = os.pullEvent()
  if event == 'monitor_touch' then
	print(infoA..':'..infoB)
    if (infoA >= 38 and infoA <= 44) and (infoB >= 43 and infoB <= 45) then --Error Menu

	  local closeMenu = false
	  currentMenu = 'errorMenu'
      errorMenu()
	  
	  repeat
	    local event, id, infoA, infoB = os.pullEvent()

	    if event == 'rednet_message' then
	      rednetUpdate(id, infoA)
	    elseif event == 'monitor_touch' then
	       print('Mark Zero')
		   print(infoA..':'..infoB)
		   if (infoA >= 23 and infoA <= 28) and (infoB >= 23 and infoB <= 25) then --Back
		     closeMenu = true
			 print('Mark MainMenu')
			 currentMenu = 'mainMenu'
			 mainMenu()
		   end
	    end
	  until closeMenu == true
	  
    elseif (infoA >= 37 and infoA <= 45) and (infoB >= 48 and infoB <= 50) then 
	--Options Menu
   
	  local closeMenu = false
	  local rowName
	  local colorPalette = {
	    isActive = false
	  }
	  currentMenu = 'optionsMenu'
	  optionsMenu()
	  
	  repeat
	    local event, id, infoA, infoB = os.pullEvent()
		  if event == 'monitor_touch' then
	       print(event..':'..infoA..':'..infoB)
		   if (infoA >= 2 and infoA <= 28) and (infoB >= 10 and infoB <= 15) then  
		     --Something related to map settings was selected
		     print('Something related to map settings was selected')
		     --Find row that was clicked
			 if not colorPalette.isActive then
			   local row = infoB-9
		       for i,v in pairs(mapSettings) do
		         if v.priority == row then
			       rowName = i
			       break
			     end
		       end

			   if (infoA >= 2 and infoA <= 2) then
			   --Priority Up
			     if mapSettings[rowName].priority ~= 1 then
			       for i,v in pairs(mapSettings) do
				     if v.priority == mapSettings[rowName].priority-1 then
					   mapSettings[i].priority = mapSettings[i].priority+1
					   break
					 end
				   end
				   mapSettings[rowName].priority = mapSettings[rowName].priority-1
			       --Get rowName of row above current rowName, and decrement priority
			       
				 end
			     optionsMenu()
			 
			   elseif (infoA >= 3 and infoA <= 3) then
			   --Priority Down
			     if mapSettings[rowName].priority ~= sizeofMapSettings then
			       for i,v in pairs(mapSettings) do
				     if v.priority == mapSettings[rowName].priority+1 then
					   mapSettings[i].priority = mapSettings[i].priority-1
					   break
					 end
				   end
				   mapSettings[rowName].priority = mapSettings[rowName].priority+1
			       --Get rowName of row above current rowName, and increment priority
			       
				 end
			     optionsMenu()
			    
			   elseif (infoA >= 15 and infoA <= 16) then
			   --Turn on
			     mapSettings[rowName].status = 'on'
			     optionsMenu()
			   
			   elseif (infoA >= 18 and infoA <= 20) then
			   --Turn off
			     mapSettings[rowName].status = 'off'
			     optionsMenu()
			   
			   elseif (infoA >= 22 and infoA <= 25) then
  			   --Change background colour
  			   --Display a window with a color pallet 
                 print('Mark')
				 createColorPalette()
				 print('UnMark')
				 colorPalette.isActive = true
				 colorPalette['for'] = 'backColor'
				elseif (infoA >= 28 and infoA <= 28) then
			    --Change colour of text symbol
			      print('Mark')
				  createColorPalette()
				  print('UnMark')
				  colorPalette.isActive = true
				  colorPalette['for'] = 'textColor'
			    end
				saveMapSettings()
			  else --Color Palette window is active
			    if (infoA >= 7 and infoA <= 22) and (infoB >= 13 and infoB <= 13) then
				  --Color was selected
				  local colorNumber = infoA-6
				  mapSettings[rowName][colorPalette['for']] = colorList[colorNumber]
				  optionsMenu()
				  saveMapSettings()
				elseif (infoA >= 12 and infoA <= 17) and (infoB >= 15 and infoB <= 15) then
				  --Cancel was selected
				  colorPalette['isActive'] = false
				  optionsMenu()
				end
			  end
		   elseif (infoA >= 4 and infoA <= 25) and (infoB >= 17 and infoB <= 19) then  
		   --View Pather Activity
			 local closeMenu = false
			 colorPalette.isActive = false
			 currentMenu = 'patherMenu'
			 --Show pather menu
			 patherMenu()
			 --Tell pather to send activity messages to monitor
			 sendMessage(svr.patherID, {action='activateDisplay'})
			 --Mode successfully switched
			 monitor.setTextColor(colors.black)
             monitor.setBackgroundColor(colors.pink)
             writeMonitor(31, 49, '                ')
             writeMonitor(31, 50, '    WAITING  ')
             writeMonitor(31, 51, '                ')
			 
			 repeat
			   local event, id, infoA, infoB = os.pullEvent()
			   if event == 'monitor_touch' then
			     if (infoA >= 51 and infoA <= 56) and (infoB >= 49 and infoB <= 51) then
				 -- Back
				   closeMenu = true
				   currentMenu = 'optionsMenu'
                   sendMessage(svr.patherID, {action='disableDisplay'})
				   optionsMenu()
				 end
			   elseif event == 'rednet_message' then
				 rednetUpdate(id, infoA)
			   end
			 until closeMenu == true
			 
		   elseif (infoA >= 2 and infoA <= 9) and (infoB >= 22 and infoB <= 25) then 
		   --Manage Chests / Stations
			 colorPalette.isActive = false
			 local closeMenu = false
			 local nodeInfo
			 
			 currentMenu = 'chestsMenu'
			 chestsMenu()
			 repeat
               local event, id, infoA, infoB = os.pullEvent()
			   if event == 'monitor_touch' then
			     if (infoA >= 2 and infoA <= 26) and (infoB >= 2 and infoB <= 51) then
				   if nodeInfo == nil or (nodeInfo.x ~= infoA-1 or nodeInfo.y ~= infoB-1) then
				     if nodeInfo ~= nil then
				       
					   --Reset previous nodes background to black
					   monitor.setBackgroundColor(colors.black)
				       if nodeInfo.type==nil then
					     writeMonitor(nodeInfo.x+1, nodeInfo.y+1, ' ')
					   elseif nodeInfo.type=='chestSlot' then
					     if hasChest(nodeInfo.x, nodeInfo.y) then
						   if isChestBusy(nodeInfo.id) then
					         monitor.setTextColor(colors.red)
					         writeMonitor(nodeInfo.x+1, nodeInfo.y+1, 'C')
						   else
						     monitor.setTextColor(colors.green)
					         writeMonitor(nodeInfo.x+1, nodeInfo.y+1, 'C')
						   end
						 else
						   monitor.setTextColor(colors.green)
						   writeMonitor(nodeInfo.x+1, nodeInfo.y+1, '.')
						 end
					   elseif nodeInfo.type=='station' then
					     monitor.setTextColor(colors.yellow)
					     writeMonitor(nodeInfo.x+1, nodeInfo.y+1, 'S')
					   end
				     end
				   
				     monitor.setBackgroundColor(colors.white)
				     monitor.setTextColor(colors.red)
					 nodeInfo = getNode(infoA-1, infoB-1)
				     if(nodeInfo == nil) then
					   writeMonitor(infoA, infoB, ' ')
					   nodeInfo = {x=infoA-1, y=infoB-1}
					   editChestMenu(nodeInfo)
					 elseif(nodeInfo.type=='chestSlot') then
				       if hasChest(nodeInfo.x, nodeInfo.y) then
					     writeMonitor(infoA, infoB, 'C')
				       else 
					     writeMonitor(infoA, infoB, '.')
					   end
					   editChestMenu(nodeInfo)
					 elseif(nodeInfo.type=='station') then
					   writeMonitor(infoA, infoB, 'S')
					   editChestMenu(nodeInfo)
				     end
				   else
				     print('same node')
				   end
				 elseif nodeInfo~=nil and (infoA > 47 and infoA < 49) and (infoB >= 18 and infoB <= 46) then
				 --Request item - Send item to station
				 --local itemPos = (infoB - 16) / 2
				 --local itemInfo = getItem(itemNumber)
				 
				 
				 elseif nodeInfo~=nil and ((infoA > 51 and infoA < 55) and (infoB >= 18 and infoB <= 46)) then
				 --Transfer item to another chest
				 local itemNumber = (infoB - 16) / 2
				 
				 elseif nodeInfo~=nil and ((infoA >= 30 and infoA <= 40) and (infoB >= 49 and infoB <= 49)) then
				 --Move Chest
				 --Draw all chest node
				 --Available nodes should be green,
				 --Others should be red
				 --Active should be white
				 
				 --Transfer Chest at 16:18 to 20:20 ?
				 --Confirm Button
				 
				 elseif nodeInfo~=nil and ((infoA >= 30 and infoA <= 42) and (infoB >= 51 and infoB <= 51)) then
				 --Delete chest
				 --Show confirm button
				 
				 
				 elseif (infoA >= 51 and infoA <= 56) and (infoB >= 49 and infoB <= 51) then 
				 -- Back
				   closeMenu = true
				   currentMenu = 'optionsMenu'
                   optionsMenu()
				 end
			   elseif event == 'rednet_message' then
				 rednetUpdate(id, infoA)
			   end
			 until closeMenu == true
			 
		   elseif (infoA >= 11 and infoA <= 21) and (infoB >= 22 and infoB <= 25) then --Manage Nodes
		     --Manage nodes
		     colorPalette.isActive = false
			 local closeMenu = false
			 local nodeSelected = false
			 local emptyNodeSelected = false
			 local selectedNode
			 local nodeToCreate
			 local direction
			 
			 currentMenu = 'nodesMenu'
			 nodesMenu()
			 
			 repeat
               local event, id, infoA, infoB = os.pullEvent()
			   if infoA ~= nil and infoB ~= nil then
			     print(infoA..':'..infoB)
			   end
			   if event == 'monitor_touch' then
			     print(nodeToCreate)
				 if selectedNode ~= nil then
				   print('Currently selected node: '..selectedNode.x..':'..selectedNode.y)
				 end
				 if (infoA >= 2 and infoA <= 26) and (infoB >= 2 and infoB <= 51) then
				   --New Node selected
				   clearActionMenu()
				   if selectedNode ~= nil then
				     --Reset previous nodes background to black
				     resetNodeOnMap(selectedNode.x, selectedNode.y)
				   end
				   nodeSelected = true
				   monitor.setBackgroundColor(colors.white)
				   highlightNodeOnMap(infoA-1, infoB-1)
				   selectedNode = {x=infoA-1, y=infoB-1}
				   print('New node Selected: '..selectedNode.x..':'..selectedNode.y)
				   if(isNode(infoA-1, infoB-1)) then
					 nodeSelected = true
					 emptyNodeSelected = false
					 editNodeMenu(infoA-1, infoB-1)
				   else
				     nodeSelected = false
					 emptyNodeSelected = true
				     newNodeMenu(infoA-1, infoB-1)
				   end
				 elseif nodeSelected == true and (infoA >= 30 and infoA <= 36) and (infoB >= 33 and infoB <= 33) then
				   --Delete a node
				   if (nodeToCreate == 'chestSlot' and #getNodesOfType('chestSlot')-1 <= #chests) == false then
				     deleteNode(selectedNode.x, selectedNode.y)
				     nodeSelected = false
				   end
				   
				 elseif emptyNodeSelected == true and (infoA >= 30 and infoA <= 39) and (infoB >= 33 and infoB <= 33) then
				   --Create a chest
				   nodeToCreate = 'chestSlot'
				   clearActionMenu()
				   newNodeMenu(selectedNode.x, selectedNode.y)
				   
                   monitor.setBackgroundColor(colors.red)
				   monitor.setTextColor(colors.white)
				   writeMonitor(30, 33, 'CHEST SLOT')
				   
				   drawConfirmButton(47, 35)
				   
				 elseif emptyNodeSelected == true and (infoA >= 30 and infoA <= 39) and (infoB >= 35 and infoB <= 35) then
				   --Create an obstacle
                   nodeToCreate = 'obstacle'
				   clearActionMenu()
				   newNodeMenu(selectedNode.x, selectedNode.y)
				   
				   monitor.setBackgroundColor(colors.red)
				   monitor.setTextColor(colors.white)
				   writeMonitor(30, 35, 'OBSTACLE  ')
				   drawConfirmButton(47, 35)
				 elseif emptyNodeSelected == true and (infoA >= 30 and infoA <= 39) and (infoB >= 37 and infoB <= 37) then
                   --Create a harbour
				   nodeToCreate = 'harbour'
				   clearActionMenu()
				   newNodeMenu(selectedNode.x, selectedNode.y)
				   monitor.setBackgroundColor(colors.red)
				   monitor.setTextColor(colors.white)
				   writeMonitor(30, 37, 'HARBOUR   ')
				   drawConfirmButton(47, 35)
				   
				 elseif emptyNodeSelected == true and (infoA >= 30 and infoA <= 39) and (infoB >= 39 and infoB <= 39) then
				   
				   --Create a station
				   nodeToCreate = 'station'
				   clearActionMenu()
				   newNodeMenu(selectedNode.x, selectedNode.y)
				   drawStationDirection(selectedNode.x, selectedNode.y)
				   monitor.setBackgroundColor(colors.red)
				   monitor.setTextColor(colors.white)
				   writeMonitor(30, 39, 'STATION   ')
				   
				 elseif nodeToCreate == 'station' and canCreateStation(selectedNode.x, selectedNode.y, 'north') == true and (infoA >= 43 and infoA <= 43) and (infoB >= 34 and infoB <= 35) then
				   
				   --Set Station Direction NORTH
				   direction = 'NORTH'
				   drawStationDirection(selectedNode.x, selectedNode.y)
				   monitor.setBackgroundColor(colors.red)
				   monitor.setTextColor(colors.white)
				   writeMonitor(43, 34, '^')
				   writeMonitor(43, 35, '|')
				   drawConfirmButton(47, 35)
				 
				 elseif nodeToCreate == 'station' and canCreateStation(selectedNode.x, selectedNode.y, 'west') == true and (infoA >= 41 and infoA <= 42) and (infoB >= 36 and infoB <= 36) then
				   
				   --Set Station Direction WEST
				   direction = 'WEST'
                   drawStationDirection(selectedNode.x, selectedNode.y)
				   monitor.setBackgroundColor(colors.red)
				   monitor.setTextColor(colors.white)
				   writeMonitor(41, 36, '<-')
				   drawConfirmButton(47, 35)

				   
				elseif nodeToCreate == 'station' and canCreateStation(selectedNode.x, selectedNode.y, 'east') == true and (infoA >= 44 and infoA <= 45) and (infoB >= 36 and infoB <= 36) then
				  
				  --Set Station Direction EAST
				   direction = 'EAST'
				   drawStationDirection(selectedNode.x, selectedNode.y)
                   monitor.setBackgroundColor(colors.red)
				   monitor.setTextColor(colors.white)
				   writeMonitor(44, 36, '->')
				   drawConfirmButton(47, 35)

				   
				 elseif nodeToCreate == 'station' and canCreateStation(selectedNode.x, selectedNode.y, 'south') == true and (infoA >= 43 and infoA <= 43) and (infoB >= 37 and infoB <= 38) then
                  
				  --Set Station Direction SOUTH
				   direction = 'SOUTH'
				   drawStationDirection(selectedNode.x, selectedNode.y)
				   monitor.setBackgroundColor(colors.red)
				   monitor.setTextColor(colors.white)
				   writeMonitor(43, 37, '|')
				   writeMonitor(43, 38, 'V')
				   drawConfirmButton(47, 35)
				 
				 elseif (infoA >= 51 and infoA <= 56) and (infoB >= 49 and infoB <= 51) then 
				   -- Back
				   closeMenu = true
				   currentMenu = 'optionsMenu'
                   optionsMenu()
				 
				 elseif nodeToCreate ~= nil and (infoA >= 46 and infoA <= 54) and (infoB >= 35 and infoB <= 37) then 
				   -- Confirm node creation
				   --LUA version of '!' ?
				   if (nodeToCreate == 'station' and direction == nil) == false then
				     --Make sure if station is selected, it has a direction
					 createNode(selectedNode.x, selectedNode.y, nodeToCreate, direction)

					 --Unset Variables
					 selectedNode = nil
					 nodeToCreate = nil
					 direction = nil
					 
				     print('Created Node')
				   end
				 end
			   elseif event == 'rednet_message' then
				 rednetUpdate(id, infoA)
			   end
			 until closeMenu == true
			 
		   elseif (infoA >= 23 and infoA <= 28) and (infoB >= 23 and infoB <= 25) then --Back
		     closeMenu = true
			 currentMenu = 'mainMenu'
			 mainMenu()
		   end
	     end
	  until closeMenu
    end
   
  elseif event == 'rednet_message' then
    rednetUpdate(id, infoA)
  elseif event == 'key' then
    if id == 207 then
	  os.reboot()
	end
  end
end

