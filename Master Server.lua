--Server Four
rednet.open('top')
term.setTextColor(colors.white)
term.setBackgroundColor(colors.black)

local status = 'OFFLINE'

local svr = {
  masterID   = os.getComputerID(),
  databaseID = 43,
  errorID = 46,
  patherID = 42,
  orderID = 41,
  monitorID = 84

}

local menuSelected = 1

function sendMessage(id, msg)
  local response
  repeat
    rednet.send(id,msg)
    response, rmsg = rednet.receive(5)
  until response == id
  return response, rmsg
end

local _,itemData = sendMessage(svr.orderID, {action='getItemData'})

local _,orderData = sendMessage(svr.orderID, {action='getOrderData'})

local _,turtleData = sendMessage(svr.orderID, {action='getTurtleData'})

local _,stationData = sendMessage(svr.orderID, {action='getStationData'})

--[[
term.setCursorPos(1,3)
print('All servers must be online')
print(' ')
print('Database: OFFLINE')
print('Error:    OFFLINE')
print('Pather:   OFFLINE')
print('Order:    OFFLINE')
print('Input:    OFFLINE')
print('Monitor:  OFFLINE')

repeat
  rednet.broadcast('server.rollcall')
  local id,msg = rednet.receive(1)
  if id then
  rednet.send(id, 'ok')
  os.sleep(0.5)
  if msg == 'server.database' then
    svr.databaseID = id
   	term.setCursorPos(11,5)
   	term.write('ONLINE ')
  elseif msg == 'server.error' then 
    svr.errorID = id
  	 term.setCursorPos(11,6)
  	 term.write('ONLINE ')
  elseif msg == 'server.pather' then
    svr.patherID = id
   	term.setCursorPos(11,7)
   	term.write('ONLINE ')
  elseif msg == 'server.order' then
    svr.orderID = id
   	term.setCursorPos(11,8)
   	term.write('ONLINE ')
  elseif msg == 'server.input' then
    svr.inputID = id
   	term.setCursorPos(11,9)
   	term.write('ONLINE ')
  elseif msg == 'server.monitor' then
    svr.monitorID = id
   	term.setCursorPos(11,10)
   	term.write('ONLINE ')
  end
  end
until svr.databaseID and svr.errorID

rednet.broadcast(svr)
--]]

--[[
function drawHalfBorder(x, y, lengthX, lengthY, colour)
  for i=0, lengthX-1 do
    term.setCursorPos(x+i, y)
	term.write(' ')
  end
  
  for i=0, lengthY-1 do
    term.setCursorPos(x, y+i)
	term.write(' ')
  end
end

function drawHalfBorderOpp(x, y, lengthX, lengthY, colour)
  for i=lengthX-1, 0, -1 do
    term.setCursorPos(x-i, y)
	term.write(' ')
  end
  
  for i=lengthY-1, 0, -1 do
    term.setCursorPos(x, y-i)
	term.write(' ')
  end
end]]--

function makeSpaces(count)
  --Makes a string of (count) number of spaces
  if type(count) ~= 'number' then 
    print('makeSpaces needs a number as input!')
  end
  
  local output = ''
  for i=1, count do
    output = output..' '
  end
  return output
end

function writeLine(x, y, msg, options)
  if options == nil or options.align == 'left' then
  term.setCursorPos(x, y)
  term.write(msg)
  
  elseif options.align == 'right' then
    term.setCursorPos(((x-#msg)+1), y)
	term.write(msg)
	
  elseif options.align == 'center' then
    term.setCursorPos(x-math.floor((#msg/2)) ,y)
    term.write(msg)
	
  end
end

function cPrint(text)
  local x2,y2 = term.getCursorPos()
  term.setCursorPos(x2-math.floor((#text/2)) ,y2)
  term.write(text)
end

function mainMenu()
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)
  term.clear()
  term.setTextColor(colors.white)
  if status == 'OFFLINE' then
    term.setBackgroundColor(colors.red)
	writeLine(30, 6, '    OFFLINE     ')
	drawBorder(colors.red)
  elseif status == 'ONLINE' then
   term.setBackgroundColor(colors.green)
   writeLine(30, 6, '     ONLINE     ')
   drawBorder(colors.green)
  elseif status == 'REPEAT' then
    term.setBackgroundColor(colors.blue)
	writeLine(30, 6, '     REPEAT     ')
	drawBorder(colors.blue)
  elseif status == 'PAUSE' then
    term.setBackgroundColor(colors.orange)
	writeLine(30, 6, '     PAUSE      ')
	drawBorder(colors.orange)
  end
  
  writeLine(30, 3, '                ')
  writeLine(30, 4, ' CURRENT STATUS ')
  writeLine(30, 5, '                ')
  writeLine(30, 7, '                ')
  
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)

  writeLine(8, 4, '---------------')
  writeLine(8, 5, ' MASTER SERVER ')
  writeLine(8, 6, '---------------')
  
  term.setBackgroundColor(colors.white)
  term.setTextColor(colors.black)
  
  writeLine(4, 12, '           ')
  writeLine(4, 13, '   VIEW    ')
  writeLine(4, 14, ' INVENTORY ')
  writeLine(4, 15, '           ')
  
  writeLine(16, 12, '          ')
  writeLine(16, 13, '   VIEW   ')
  writeLine(16, 14, ' STATIONS ')
  writeLine(16, 15, '          ')
  
  writeLine(29, 12, '        ')
  writeLine(29, 13, '  VIEW  ')
  writeLine(29, 14, ' ORDERS ')
  writeLine(29, 15, '        ')
  
  writeLine(38, 12, '          ')
  writeLine(38, 13, '  VIEW    ')
  writeLine(38, 14, ' TURTLES  ')
  writeLine(38, 15, '          ')


end

function currentStatusMenu()
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)
  term.clear()
  
  writeLine(16, 4, 'SET CURRENT STATUS')
  writeLine(15, 5, '--------------------')
  
  term.setBackgroundColor(colors.green)
  writeLine(16, 7, '        ')
  writeLine(16, 8, ' ONLINE ')
  writeLine(16, 9, '        ')
  term.setBackgroundColor(colors.blue)
  writeLine(26, 7, '         ')
  writeLine(26, 8, ' REPEAT  ')
  writeLine(26, 9, '         ')
  term.setBackgroundColor(colors.orange)
  writeLine(16, 11, '        ')
  writeLine(16, 12, ' PAUSE  ')
  writeLine(16, 13, '        ')
  term.setBackgroundColor(colors.red)
  writeLine(26, 11, '         ')
  writeLine(26, 12, ' OFFLINE ')
  writeLine(26, 13, '         ')
end

function viewInventoryMenu(page, filter)
  --All item index
  --Show itemName, count, dmg, [itemName, modID]
  local resultCount = 0
  local filter = filter or ''
  local itemResults = {}
  
  if filter == '' then
  --If no filter, just collect first 8 results for page
    for i,item in ipairs(itemData) do
	  if isItemAvailable(item) then
	    resultCount = resultCount + 1
	    if resultCount > (page*8)-8 and #itemResults < 8 then
	      --Need to display 8 items per page, from index (page*8)-8
		  table.insert(itemResults, item)
        end
		if resultCount > (page*8)+1 then
	      break
	    end
	  end
    end
  else
    
	--Filter Exists
	local filter = string.lower(filter)
    for i, item in ipairs(itemData) do
	  if (string.find(string.lower(item.itemName), filter) or string.find(string.lower(item.displayName), filter) or string.find(string.lower(item.modName), filter)) and isItemAvailable(item)  then
        resultCount = resultCount + 1
		if resultCount > (page*8)-8 and #itemResults < 8 then
		  table.insert(itemResults, item)
	    end
	  end
    end
  end
  
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)
  term.clear()
  
  for i, item in ipairs(itemResults) do
    if #item.displayName > 29 then
	  writeLine(2, (2*i)-1, string.sub(item.displayName, 0, 26)..'...')
	else
      writeLine(2, (2*i)-1, item.displayName)
    end
	writeLine(31, (2*i)-1, 'QTY:'..item.count)
    writeLine(39, (2*i)-1, 'DMG:'..item.dmg)
  end
  
  --Filter based on displayName, itemName and modName
  
  term.setTextColor(colors.white)
  writeLine(2, 18, 'SEARCH')
  term.setBackgroundColor(colors.lightGray)
  term.setTextColor(colors.black)
  writeLine(9, 18, '                    ')
  if #filter >= 20 then
     writeLine(9, 18,string.sub(filter, (#filter)-19, #filter))
  else
    writeLine(9, 18, filter)
  end
  
  term.setCursorPos(37, 18)
  cPrint(tostring(page))
  
  if page == 1 then term.setTextColor(colors.gray) else term.setTextColor(colors.white) end
  writeLine(31, 18, '<<')
  if (page*8) >= resultCount then term.setTextColor(colors.gray) else term.setTextColor(colors.white) end
  writeLine(42, 18, '>>')
  
  
  term.setBackgroundColor(colors.white)
  term.setTextColor(colors.black)
  writeLine(46, 17, '      ')
  writeLine(46, 18, ' EXIT ')
  writeLine(46, 19, '      ')
  
  --More pages available?
  if (page*8) >= resultCount then
    return false
  else
    return true
  end
end

function drawItemRequestWindow(infoA, infoB, currentPage, filter)
  local itemSelected 
  local rowOnPage = math.ceil(infoB/2)
  local itemIndex = ((currentPage-1)*8)+rowOnPage
  
  local resultCount = 0
  local itemResults = {}
  local itemInfo
  
  if not filter then
  --Collect itemData not involved with orders, up to count of itemIndex
    for i,item in pairs(itemData) do
      if isItemAvailable(item) then
	    table.insert(itemResults, item)
	    if #itemResults == itemIndex then
	      itemInfo = itemResults[itemIndex]
		  break
	    end
	  end
    end
  else
	--Filter Exists
	local filter = string.lower(filter)
    for i, item in ipairs(itemData) do
	  if (string.find(string.lower(item.itemName), filter) or string.find(string.lower(item.displayName), filter) or string.find(string.lower(item.modName), filter)) and isItemAvailable(item) then
	    table.insert(itemResults, item)
	    if #itemResults == itemIndex then
	      itemInfo = itemResults[itemIndex]
		  break
	    end
	  end
    end
  end

  if itemInfo then
    
	local itemNameSize = #itemInfo.displayName
	
    --If an item is found at this index, draw the request window.
    for i=1, 10 do
      writeLine(25, i+4, makeSpaces(math.max(16, itemNameSize+2)), {align='center'})
    end

    term.setTextColor(colors.black)
    writeLine(25, 6, itemInfo.displayName,{align='center'})
    writeLine(25, 8, 'How many?', {align='center'})
    writeLine(25, 10, '/'..itemInfo.count)
	writeLine(24, 10, itemInfo.count, {align='right'})
    term.setTextColor(colors.green)
    writeLine(19, 13, 'Do it')
    term.setTextColor(colors.red)
    writeLine(26, 13, 'Cancel')
    
	
	return math.max(16, itemNameSize+2), itemInfo.count, itemInfo.id, itemInfo.count
  end
  
end

function isItemAvailable(itemData)
  if #orderData > 0 then
    for i,order in pairs(orderData) do
      if order.itemID == itemData.id then
	    return false
	  end
    end
  end
  return true
end

function requestItem(itemID, reqCount)
  sendMessage(svr.orderID, {type='NEW_ORDER', orderType='OUTPUT', itemID=itemID, reqCount=reqCount})
end

function viewStationsMenu(page)
  --14 stations displayed per page
  term.setBackgroundColor(colors.black)
  term.clear()
  
  local stationResults = {}
  for i,station in ipairs(stationData) do
    if i > ((page-1)*14) then
	  table.insert(stationResults, station)
	end
	if #stationResults == 8 then
	  break
	end
  end
  
  --Page divider
  term.setTextColor(colors.gray)
  for i=1,  13 do
    writeLine(26, i+3, '|')
  end
  
  term.setTextColor(colors.white)
  writeLine(22, 2, 'STATIONS')
  local c = 1
  for i, station in ipairs(stationResults) do
	writeLine(c, (2*i)+2, 'ID:'..station.computerID)
    writeLine(c+10, (2*i)+2, 'MODE: '..station.mode)
	if i == 7 then
	  c = 26
	end
  end
  
  writeLine(2 ,18, 'TOTAL STATIONS: '..#stationData)
  
  writeLine(37, 18, tostring(page), {align='center'})
  
  if page == 1 then term.setTextColor(colors.gray) else term.setTextColor(colors.white) end
  writeLine(31, 18, '<<')
  if (page*14) >= #stationData then term.setTextColor(colors.gray) else term.setTextColor(colors.white) end
  writeLine(42, 18, '>>')
  
  term.setBackgroundColor(colors.white)
  term.setTextColor(colors.black)
  writeLine(46, 17, '      ')
  writeLine(46, 18, ' EXIT ')
  writeLine(46, 19, '      ')
  
  --More pages available?
  if (page*14) >= #stationData then
    return false
  else
    return true
  end
end

function viewStationDetails(index)
  local stationDetails
  for i,station in ipairs(stationData) do
	if i == index then
	  stationDetails = station
	  break
	end
  end
  
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)
  term.clear()
  
  --!!Code for finding orders assigned to station needs to be modified and efficient
  local orderCount = 0
  for i,order in pairs(orderData) do
	if (order.destinationID == stationDetails.nodeID) then
	  orderCount = orderCount + 1
	elseif (order.createdBy == stationDetails.computerID) then
	  orderCount = orderCount + 1
	end
  end
  
  
  writeLine(2,7,'STATION')
  writeLine(21,7,stationDetails.nodeID, {align='right'})
  writeLine(2,9,'COMPUTER ID')
  writeLine(21,9,stationDetails.computerID, {align='right'})
  writeLine(2,11, '# OF ORDERS')
  writeLine(21,11,tostring(orderCount),{align='right'})
  
  --Option to switch mode
  drawTurtleCurrentMode(stationDetails.mode, stationDetails.transitionInto)
  
  term.setBackgroundColor(colors.white)
  term.setTextColor(colors.black)
  writeLine(46, 17, '      ')
  writeLine(46, 18, ' EXIT ')
  writeLine(46, 19, '      ')
  
end

function drawTurtleCurrentMode(mode, transitionInto)
  term.setTextColor(colors.white)
  
  if not transitionInto then
    if mode == 'INPUT' then
      term.setBackgroundColor(colors.green)
      for i=1, 5 do
        writeLine(33, 6+i, '               ')
      end
	  writeLine(38, 10, 'INPUT')
    elseif mode == 'OUTPUT' then
      term.setBackgroundColor(colors.blue)
      for i=1, 5 do
       writeLine(33, 6+i, '               ')
      end
	  writeLine(38, 10, 'OUTPUT')
    elseif mode == 'TRANSFER' then
      term.setBackgroundColor(colors.purple)
      for i=1, 5 do
        writeLine(33, 6+i, '               ')
      end
	  writeLine(37, 10, 'TRANSFER')
    elseif mode == 'OFFLINE' then
      term.setBackgroundColor(colors.red)
      for i=1, 5 do
        writeLine(33, 6+i, '               ')
      end
	  writeLine(37, 10, 'OFFLINE')
    end
	writeLine(34, 8, 'CURRENT  MODE')
  
  elseif transitionInto then
	term.setBackgroundColor(colors.yellow)
    term.setTextColor(colors.black)
	for i=1, 5 do
      writeLine(33, 6+i, '               ')
    end
	writeLine(34, 8, 'TRANSITIONING')
    writeLine(39, 10, 'TO '..transitionInto, {align='center'})
  end
  

end

function drawStationModesWindow()
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)
  term.clear()
  
  writeLine(17, 5, 'SELECT STATION MODE')
  
  term.setBackgroundColor(colors.green)
  writeLine(16, 7, '          ')
  writeLine(16, 8, '  INPUT   ')
  writeLine(16, 9, '          ')
  
  term.setBackgroundColor(colors.blue)
  writeLine(27, 7, '          ')
  writeLine(27, 8, '  OUTPUT  ')
  writeLine(27, 9, '          ')
  
  term.setBackgroundColor(colors.purple)
  writeLine(16, 11, '          ')
  writeLine(16, 12, ' TRANSFER ')
  writeLine(16, 13, '          ')
  
  term.setBackgroundColor(colors.red)
  writeLine(27, 11, '          ')
  writeLine(27, 12, ' OFFLINE  ')
  writeLine(27, 13, '          ')
end

function viewOrdersMenu(page)
  --Index of orders
  --Possible data shown:
  --orderType, itemID, reqCount, creationTime, status, assignTo, assignTime, destinationID, destinationPos
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)
  term.clear()
  
  if #orderData ~= 0 then
  
    local orderResults = {}
    for i,order in ipairs(orderData) do
      if i > ((page-1)*6) then
	    table.insert(orderResults, order)
	  end
	  if #orderResults == 6 then
	    break
	  end
    end
  
    writeLine(23, 2, 'ORDERS')
  
    for i=1, math.min(#orderResults, 3)  do
	  local row = ((i-1)*17)+1
	  writeLine(row,4, 'ID:')
      writeLine(row,5, 'TYPE:')
      writeLine(row,6, 'STATUS:')
      writeLine(row,7, 'ITEM ID:')
      writeLine(row,8, 'REQ AMOUNT:')
	  writeLine(row+15,4, orderResults[i].id,            {align='right'})
      writeLine(row+15,5, orderResults[i].orderType, {align='right'})
      writeLine(row+15,6, orderResults[i].status,      {align='right'})
      writeLine(row+15,7, orderResults[i].itemID,    	{align='right'})
      writeLine(row+15,8, orderResults[i].reqCount, 	{align='right'})
    end
    for i=4, #orderResults do
      local row = ((i-4)*17)+1
	  writeLine(row,10, 'ID:')
      writeLine(row,11, 'TYPE:')
      writeLine(row,12, 'STATUS:')
      writeLine(row,13, 'ITEM ID:')
      writeLine(row,14, 'REQ AMOUNT:')
	  writeLine(row+15,10, orderResults[i].id,            {align='right'})
      writeLine(row+15,11, orderResults[i].orderType, {align='right'})
      writeLine(row+15,12, orderResults[i].status,      {align='right'})
      writeLine(row+15,13, orderResults[i].itemID,    	{align='right'})
      writeLine(row+15,14, orderResults[i].reqCount, 	{align='right'})
    end
  
    term.setTextColor(colors.lightGray)
    for i=3, 14 do
      writeLine(17, i, '|')
    end
    for i=3, 14 do
      writeLine(34, i, '|')
    end
    for i=3, 14 do
      writeLine(51, i, '|')
    end
    writeLine(1, 3, '---------------------------------------------------')
    writeLine(1, 9, '---------------------------------------------------')
    writeLine(1, 15, '---------------------------------------------------')
  else
    writeLine(25, 7, 'NO ORDERS TO DISPLAY', {align='center'})
  end
  
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)
  writeLine(1 ,18, 'TOTAL ORDERS: '..#orderData)
  
  term.setCursorPos(37, 18)
  cPrint(tostring(page))
  
  if page == 1 then term.setTextColor(colors.gray) else term.setTextColor(colors.white) end
  writeLine(31, 18, '<<')
  if (page*6) >= #orderData then term.setTextColor(colors.gray) else term.setTextColor(colors.white) end
  writeLine(42, 18, '>>')
  
  term.setBackgroundColor(colors.white)
  term.setTextColor(colors.black)
  writeLine(46, 17, '      ')
  writeLine(46, 18, ' EXIT ')
  writeLine(46, 19, '      ')
  
  --More pages available?
  if (page*6) >= #orderData then
    return false
  else
    return true
  end
  
end

function viewOrderDetails(orderID, page)
  --Find id in orderData
  print(orderID)
  local orderInfo
    
  --Collect orders that were on the page
  local orderResults = {}
  for i,order in ipairs(orderData) do
    if i == ((page-1)*8 + orderID) then
      orderInfo = order
      break
	end
  end

  --Find item in orderData
  local itemInfo
  for _, item in pairs(itemData) do
	if item.id == orderInfo.itemID then
	  itemInfo = item
	  break
	end
  end
  
  
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)
  term.clear()  

  writeLine(25, 2, 'ORDER '..orderInfo.id, {align='center'})
  
  writeLine(3, 5, 'ORDER TYPE')
  writeLine(22, 5, orderInfo.orderType, {align='right'})
  writeLine(3, 7, 'ITEM NAME')
  writeLine(22, 7, itemInfo.displayName, {limit=13, align='right'})
  writeLine(3, 9, 'REQ AMOUNT')
  writeLine(22, 9, orderInfo.reqCount, {align='right'})
  writeLine(3, 11, 'STATUS')
  writeLine(22, 11, orderInfo.status, {align='right'})
  writeLine(3, 13, 'ITEM LOCATION')
  writeLine(22, 13, itemInfo.locationID, {align='right'})
  writeLine(3, 15, 'ITEM POSITION')
  writeLine(22, 15, itemInfo.locationPos, {align='right'})
  
  writeLine(3, 17, 'CREATED ON')
  writeLine(3, 18, orderInfo.creationTime)
  
  if orderInfo.status == 'new' then
    writeLine(33, 9, 'WAITING FOR')
    writeLine(33, 11, 'ASSIGNMENT')
    
  elseif orderInfo.status == 'active' then
    writeLine(29, 5, 'ASSIGNED TO')
    writeLine(50, 5, orderInfo.assignTo, {align='right'})
	
    writeLine(29, 7, 'DESTINATION ID')
    writeLine(50, 7, orderInfo.destinationID, {align='right'})
	
    writeLine(29, 9, 'DESTINATION POS')
    writeLine(50, 9, orderInfo.destinationPos, {align='right'})
	
    writeLine(29, 11, 'ASSIGN TIME')
    writeLine(29, 12, orderInfo.assignTime)
	
  else --Hold, complete, cancelled
    writeLine(28, 8, 'ECH')
  end
  
  term.setBackgroundColor(colors.white)
  term.setTextColor(colors.black)
  writeLine(46, 17, '      ')
  writeLine(46, 18, ' BACK ')
  writeLine(46, 19, '      ')
  
  writeLine(30, 17, '         ')
  writeLine(30, 18, ' OPTIONS ')
  writeLine(30, 19, '         ')
  
end

function drawOrderOptionsWindow()
  term.setBackgroundColor(colors.white)
  term.setTextColor(colors.black)
  for i=1, 11 do
    writeLine(19, i+4, '            ')
  end

  writeLine(21, 6, '>CANCEL')
  writeLine(21, 8, '>EDIT')
  writeLine(21, 10, '>REASSIGN')
  writeLine(21, 12, '>PAUSE')
  writeLine(21, 14, '>BACK')

end

function viewTurtlesMenu(page)
  --What info to display?
    --Confirmed:
	  --Turtle ID
	  --Current status
	--Possible:
      --Current position
	  --Current fuel level
	  --Could get from monitorID ???
	  
  term.setBackgroundColor(colors.black)
  term.clear()
  
  local turtleResults = {}
  for i,turtle in ipairs(turtleData) do
    if i > ((page-1)*6) then
	  table.insert(turtleResults, turtle)
	end
	if #turtleResults == 8 then
	  break
	end
  end
  
  term.setTextColor(colors.white)
  
  for i, turtle in ipairs(turtleResults) do
	writeLine(2, (2*i)-1, 'ID:'..turtle.id)
    writeLine(12, (2*i)-1, 'Current Status: '..turtle.status)
  end
  
  writeLine(2 ,18, 'TOTAL TURTLES: '..#turtleData)

  writeLine(36, 18, tostring(page), {align='center'})
  
  if page == 1 then term.setTextColor(colors.gray) else term.setTextColor(colors.white) end
  writeLine(30, 18, '<<')
  if (page*8) >= #turtleData then term.setTextColor(colors.gray) else term.setTextColor(colors.white) end
  writeLine(41, 18, '>>')
  
  term.setBackgroundColor(colors.white)
  term.setTextColor(colors.black)
  writeLine(46, 17, '      ')
  writeLine(46, 18, ' EXIT ')
  writeLine(46, 19, '      ')
  
end

function viewTurtleInfo(turtleIndex)
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)
  term.clear()
  
  writeLine(25, 9, '--LOADING--', {align='center'})
  
  --Get Turtle Info from turtle, turn on auto updating
  local turtleID = turtleData[turtleIndex].id
  
  local _,turtleInfo = sendMessage(turtleID, {action='GET_STATUS', option='AUTO_UPDATE'})
  --fuelCount, curX, curY, dir
  local _,turtleStatistics = sendMessage(svr.databaseID, {id='turtles', action='getStatistics', turtleID=turtleID})
  --totalOrders, completedCount, totalFuel, averageFuelPerOrder, completionRate, averageTime
  --Draw info
  
  term.clear()
  
  writeLine(2,2,'MANAGE TURTLE '..turtleID)
  writeLine(22,2,'FUEL COUNT')
  writeLine(48, 2, turtleInfo.fuelCount, {align='right'})
  writeLine(22,5,'CURRENT POSITION')
  writeLine(48,5,turtleInfo.curX..':'..turtleInfo.curY..':'..turtleInfo.dir, {align='right'})
  
  
  writeLine(21,8,'STATISTICS')
  --Gotten from database, using procedure 'getTurtleStatistics'
  
  writeLine(21,11,'Total orders assigned  :')
  writeLine(21,10,'Total orders completed :')
  writeLine(21,12,'Average completion time:')
  writeLine(21,13,'Completion rate        :')
  writeLine(21,14,'Total fuel usage       :')
  writeLine(21,15,'Average fuel per order :')
  writeLine(51,10,turtleStatistics.totalOrders, {align='right'})
  writeLine(51,11,turtleStatistics.completedCount, {align='right'})
  writeLine(51,12,turtleStatistics.averageTime, {align='right'})
  writeLine(51,13,(turtleStatistics.completionRate*100)..'%', {align='right'})
  if turtleInfo.fuelCount ~= 'unlimited' then
    writeLine(51,14,turtleStatistics.totalFuel-turtleInfo.fuelCount, {align='right'})
  else
    writeLine(51,14,turtleStatistics.totalFuel, {align='right'})
  end
  writeLine(51,15,turtleStatistics.averageFuelPerOrder, {align='right'})
  
  
  writeLine(2,5,'CURRENT STATUS')
  
  if turtleInfo.status == 'REFUELING' then
    writeLine(2,7,'REFUELING')
  elseif turtleInfo.status == 'RETURNING_TO_HARBOUR' then
    writeLine(2,7,'RETURNING TO')
    writeLine(2,8,'HARBOUR')
  elseif turtleInfo.status == 'READY' then
    writeLine(2,7,'READY')
  elseif turtleInfo.status == 'DOING_ORDER' then
    writeLine(2,7,'DOING ORDER ???')
	writeLine(2,8,'Time since')
	writeLine(2,9,'order assigned')
	writeLine(2,10,'???')
  elseif turtleInfo.status == 'OFFLINE' then
    writeLine(2,7,'OFFLINE')
  elseif turtleInfo.status == 'PAUSED' then
    writeLine(2,7,'PAUSE')
  end
  
  term.setBackgroundColor(colors.white)
  term.setTextColor(colors.black)
  writeLine(1, 17, '         ')
  writeLine(1, 18, ' OPTIONS ')
  writeLine(1, 19, '         ')
  writeLine(46, 17, '      ')
  writeLine(46, 18, ' BACK ')
  writeLine(46, 19, '      ')
end

function drawTurtleOptions()
  term.setBackgroundColor(colors.white)
  for i=1, 13 do
    writeLine(19, i+3, '                ')
  end
  
  --Options that are not yet available (Haven't been coded)
  term.setTextColor(colors.lightGray)
  writeLine(20, 5, 'CANCEL ORDER')
  writeLine(20, 7, 'RETURN TO BASE')
  writeLine(20, 9, 'CHANGE STATUS')
  writeLine(20, 11, 'FORCE REFUEL')
  writeLine(20, 13, 'PAUSE')
  
  --Options that are available
  term.setTextColor(colors.black)
  writeLine(20, 15, 'BACK')
end

function drawBorder(color)
  term.setBackgroundColor(color)
  writeLine(1,1, '                                                   ')
  writeLine(1,19, '                                                   ')
  for i=2, 18 do
    writeLine(1, i, ' ')
    writeLine(51, i, ' ')
  end
end

function changeStatus(newStatus)
  --No need to change the status to the same one
  if status ~= newStatus then
  
  --Update locally
  status = newStatus
  
  --Update Order (Takes priority over monitor because more important)
  sendMessage(svr.orderID, {action='changeStatus', newStatus=newStatus})
  
  --Update Monitor
  sendMessage(svr.monitorID, {action='newStatus', newStatus=newStatus})
  end
end

function rednetUpdate(id, currentMenu, msg, infoA, infoB, infoC)
  if msg.action ~= nil then
    if msg.action == 'getFacilityStatus' then
      rednet.send(id, status)
	
	elseif msg.action == 'ADD_TURTLE' then
      rednet.send(id, 'MESSAGE_RECEIEVED')
	  
	  --Check if turtle is already added
	  for i,turtle in pairs(turtleData) do
	    if turtle.id == msg.turtleID then
		  return
		end
	  end
	  
	  --If not, add turtle
	  table.insert(turtleData, {id=msg.turtleID, status=msg.status})
    
	elseif msg.action == 'ADD_STATION' then
	  rednet.send(id, 'MESSAGE_RECEIEVED')
	  --Check if station is already added
	  for i,station in pairs(stationData) do
	    if station.id == msg.stationID then
		  return
		end
	  end
	  
	  --If not, add station
	  table.insert(stationData, {id=msg.stationID, mode=msg.mode})
	  
	elseif msg.action == 'UPDATE_TURTLE' then
      rednet.send(id, 'MESSAGE_RECEIEVED')
	  for i,turtle in pairs(turtleData) do
	    if turtle.id == msg.turtleID then
	  	  turtleData[i].status = msg.status
		  return
	    end
	  end
	
	elseif msg.action == 'UPDATE_STATION' then
      rednet.send(id, 'MESSAGE_RECEIEVED')
	  for i,stations in ipairs(stationData) do
		if tonumber(stations.computerID) == msg.computerID then
		  stationData[i].mode = msg.mode
		  stationData[i].transitionInto = msg.transitionInto
		  if currentMenu == 'stationsMenu' and infoA == (math.ceil(i/14)) then
			--Update status on stationsMenu
			term.setBackgroundColor(colors.black)
			term.setTextColor(colors.white)
			
			if i-((infoA-1)*14) < 26 then
			  --Left of divider
			  writeLine(17, math.ceil((i-3)/2), msg.mode)
			else
			  --Right of divider
			  writeLine(43, math.ceil((i-3)/2), msg.mode)
			end
			
		  elseif currentMenu == 'stationView' and infoA == tonumber(msg.computerID) then
			drawTurtleCurrentMode(msg.mode, msg.transitionInto)
		  end
		  break
		end
	  end
	end  
  end
end

--Begin Listening
mainMenu()

local currentMenu = 'mainMenu'
while true do
  local event, id,  infoA, infoB = os.pullEvent()
  if event == 'mouse_click' then
	if (infoA >= 30 and infoA <= 45) and (infoB >= 3 and infoB <= 7) then
    --Current Status
	  currentStatusMenu()
	  currentMenu = 'orderMenu'
	  
	  local closeMenu
	  repeat
	    local event, id, infoA, infoB = os.pullEvent()
		if event == 'mouse_click' then
		  if (infoA >= 16 and infoA <= 23) and (infoB >= 7 and infoB <= 9) then
	      --Online
			changeStatus('ONLINE')
			closeMenu = true
		  elseif (infoA >= 26 and infoA <= 34) and (infoB >= 7 and infoB <= 9) then
		  --Repeat
		    changeStatus('REPEAT')
		    closeMenu = true
		  elseif (infoA >= 16 and infoA <= 23) and (infoB >=11 and infoB <= 13) then
		  --Pause
		   changeStatus('PAUSE')
		    closeMenu = true
		  elseif (infoA >= 26 and infoA <= 34) and (infoB >= 11 and infoB <= 13) then
		  --Offline
		    changeStatus('OFFLINE')
		    closeMenu = true
		  end
		elseif event == 'rednet_message' then
		  rednetUpdate(id, currentMenu, infoA)
		end
	  until closeMenu
      mainMenu()

	elseif (infoA >= 4 and infoA <= 14) and (infoB >= 12 and infoB <= 15) then
	--View Inventory
	----Get item info from orderID, start update cycle
	  currentMenu = 'inventoryMenu'
	  
	  local currentPage = 1
	  local searchString
	  local closeMenu
	  
	  local itemRequestWindowActive = false
	  local requestWindowWidth = 0
	  local itemID = 0
	  local reqCount = 0
	  local reqCountLimit = 0
	  
	  local hasMorePages = viewInventoryMenu(currentPage)
	  repeat
	    local event, id, infoA, infoB = os.pullEvent()
		if event == 'mouse_click' then
		  writeLine(1,1, infoA..':'..infoB)
		  
		  --!!Get coordinates of request window via window size
		  if itemRequestWindowActive and (infoA >= 25-(requestWindowWidth/2) and infoA <= 25+(requestWindowWidth/2)) and (infoB >= 5 and infoB <= 14) then
		    --The itemRequestWindow was clicked
			writeLine(1,2,requestWindowWidth)
			
			if (infoA >= 19 and infoA <= 23) and (infoB >= 13 and infoB <= 13) then
			  --'Do it' was clicked
			  
			  if tonumber(reqCount) > 0 and type(reqCount) == 'number' then
			    requestItem(itemID, reqCount)
			  end
			  
			  viewInventoryMenu(currentPage, searchString)
			  itemRequestWindowActive = false		  
			elseif (infoA >= 26 and infoA <= 31) and (infoB >= 13 and infoB <= 16) then
		      --'Cancel' was clicked		
			  viewInventoryMenu(currentPage, searchString)
			  itemRequestWindowActive = false
			end

		  elseif (infoA >= 1 and infoA <= 51) and (infoB >= 1 and infoB <= 16) then
		    --A menu item was clicked
			viewInventoryMenu(currentPage, searchString)
			requestWindowWidth, reqCount, itemID, reqCountLimit = drawItemRequestWindow(infoA, infoB, currentPage, searchString)
		    itemRequestWindowActive = true
			
		  elseif (infoA >= 31 and infoA <= 32) and (infoB >= 18 and infoB <= 18) and currentPage ~= 1 then
		  --Previous item page
		  itemRequestWindowActive = false
		  currentPage = currentPage - 1
		  hasMorePages = viewInventoryMenu(currentPage, searchString)
		 
		 elseif hasMorePages and (infoA >= 42 and infoA <= 43) and (infoB >= 18 and infoB <= 18) then
          --Next item page
		  itemRequestWindowActive = false
		  currentPage = currentPage + 1
		  hasMorePages = viewInventoryMenu(currentPage, searchString)
		  	  
		  elseif (infoA >= 46 and infoA <= 51) and (infoB >= 17 and infoB <= 19) then
	      --Back button was clicked
			closeMenu = true
		  end
		  
		elseif event == 'char' then
		  if itemRequestWindowActive then
		    if tonumber(id) then
			  if reqCount == 0 then reqCount = '' end
		      local newCount = reqCount..tonumber(id)
			  if tonumber(newCount) <= tonumber(reqCountLimit) then
		        reqCount = newCount
			    writeLine(24,10, reqCount, {align='right'})
			  end
			end
		  else
		    if searchString == nil then
		      searchString = id
		    else
              searchString = searchString..id
		    end
		    itemRequestWindowActive = false
		    currentPage = 1
		    hasMorePages = viewInventoryMenu(currentPage, searchString)
		  end
		  
		elseif event == 'key' and id == 14 then
		  if itemRequestWindowActive then
		    newCount = string.sub(tostring(reqCount), 0, #tostring(reqCount)-1)
			if newCount == '' then
			  reqCount = 0
			else
			  reqCount = tonumber(newCount)
			end
			term.setBackgroundColor(colors.white)
			term.setTextColor(colors.black)
			
			writeLine(22,10, '   ')
			writeLine(24,10, tostring(reqCount), {align='right'})
			
			
		  else
		    if #searchString > 0 then
		 	  searchString = string.sub(searchString, 0, #searchString-1)
		      currentPage = 1
		      hasMorePages = viewInventoryMenu(currentPage, searchString)
		    end
		  end
		elseif event == 'rednet_message' then
		  rednetUpdate(id, currentMenu, infoA)
		end
	  until closeMenu
      mainMenu()
	  --Stop update cycle from orderID
	
	elseif (infoA >= 16 and infoA <= 25) and (infoB >= 12 and infoB <= 15) then
    --View Stations
	  currentMenu = 'stationsMenu'
	  local currentPage = 1
	  local closeMenu
	  
	  local hasMorePages = viewStationsMenu(currentPage)
	  
	  repeat
	    local event, id, infoA, infoB = os.pullEvent()
		if event == 'mouse_click' then
		  if (infoA >= 1 and infoA <= 51) and (infoB >= 4 and infoB <= 16) and (infoA ~= 26) then
	      --Station was selected
		    --Find index
			local column = math.ceil(infoA/25) -- 1 or 2
			local row = math.ceil((infoB-3)/2)  -- between 1 and 7
			
			local index = ((currentPage-1)*14)+((column-1)*7)+row
            local modesWindowActive = false
		    currentMenu = 'stationView'
		    
			if stationData[index] ~= nil then
			viewStationDetails(index)
			
			local closeView
			repeat
			  local event, id, infoA, infoB = os.pullEvent()
			  if event == 'mouse_click' then
			    if not modesWindowActive then
				  if (infoA >= 33 and infoA <= 47) and (infoB >= 7 and infoB <= 11) then
			      --Change mode clicked
				    drawStationModesWindow()
                    modesWindowActive = true
				  
				  elseif (infoA >= 46 and infoA <= 51) and (infoB >= 17 and infoB <= 19) then
				  --Back clicked
				    closeView = true
				    viewStationsMenu(currentPage)
				  end
			    else
				  if (infoA >= 16 and infoA <= 25) and (infoB >= 7 and infoB <= 9) then
				  --Input
				    if stationData[index].mode ~= 'INPUT' then
				      sendMessage(svr.orderID, {action='CHANGE_STATION_MODE', mode='INPUT', computerID=tonumber(stationData[index].computerID)})
					end
					modesWindowActive = false
				    viewStationDetails(index)
				  elseif (infoA >= 27 and infoA <= 36) and (infoB >= 7 and infoB <= 9) then
				  --Output
				   if stationData[index].mode ~= 'OUTPUT' then
				     sendMessage(svr.orderID, {action='CHANGE_STATION_MODE', mode='OUTPUT', computerID=tonumber(stationData[index].computerID)})
				   end
				   modesWindowActive = false
				   viewStationDetails(index)
				 elseif (infoA >= 16 and infoA <= 25) and (infoB >= 11 and infoB <= 13) then
				  --Transfer
				    if stationData[index].mode ~= 'TRANSFER' then
					  sendMessage(svr.orderID, {action='CHANGE_STATION_MODE', mode='TRANSFER', computerID=tonumber(stationData[index].computerID)})
					end
					modesWindowActive = false
					viewStationDetails(index)
				  elseif (infoA >= 27 and infoA <= 36) and (infoB >= 11 and infoB <= 13) then
				  --Offline
				    if stationData[index].mode ~= 'OFFLINE' then
					  sendMessage(svr.orderID, {action='CHANGE_STATION_MODE', mode='OFFLINE', computerID=tonumber(stationData[index].computerID)})
				    end
					modesWindowActive = false
					viewStationDetails(index)
				  end
				end
			  elseif event == 'rednet_message' then
				rednetUpdate(id, currentMenu, infoA, tonumber(stationData[index].computerID))
		      end
			until closeView
			currentMenu = 'stationsMenu'
		    end
		  elseif (infoA >= 31 and infoA <= 32) and (infoB == 18) then
		  --Previous page
		    if currentPage ~= 1 then
			  currentPage = currentPage + 1
			  hasMorePages = viewStationsMenu(currentPage)
			end
		  elseif (infoA >= 42 and infoA <= 43) and (infoB == 18) then
		  --Next page
		    if hasMorePages then
		      currentPage = currentPage + 1
			  hasMorePages = viewStationsMenu(currentPage)
			end
		  elseif (infoA >= 46 and infoA <= 51) and (infoB >= 17 and infoB <= 19) then
		  --Back
		    closeMenu = true
		  end
		elseif event == 'rednet_message' then
		  rednetUpdate(id, currentMenu, infoA, currentPage)
		end
      until closeMenu
	  mainMenu()
	
	elseif (infoA >= 29 and infoA <= 36) and (infoB >= 12 and infoB <= 15) then
	--View Orders
	----Get order info from orderID, start update cycle
	  local currentPage = 1
	  local closeMenu
	  currentMenu = 'orderMenu'
	  
	  local hasMorePages = viewOrdersMenu(currentPage)
      repeat
	    local event, id, infoA, infoB = os.pullEvent()
		if event == 'mouse_click' then
		  if (infoA >= 31 and infoA <= 32) and (infoB >= 18 and infoB <= 18) and currentPage ~= 1 then
		  --Previous Page
		    currentPage = currentPage - 1
			hasMorePages = viewOrdersMenu(currentPage)
			
		  elseif hasMorePages and (infoA >= 42 and infoA <= 43) and (infoB >= 18 and infoB <= 18) then
		  --Next Page
		    currentPage = currentPage + 1
			hasMorePages = viewOrdersMenu(currentPage)
	      elseif (infoA <= 50) and (infoB >= 4 and infoB <= 14) and (infoB ~= 9) and (infoA ~= 17 and infoA ~= 34) then
		  --One of the orders was selected

			local row = math.ceil(infoA/17)
			local column = math.ceil((infoB-3)/6)
			local orderID = ((currentPage-1)*6)+((column-1)*3)+row

			currentMenu = 'orderView'
		    viewOrderDetails(orderID, currentPage)
			local closeView
			repeat
			  local event, id, infoA, infoB = os.pullEvent()
			  if event == 'mouse_click' then
			    if (infoA >= 30 and infoA <= 38) and (infoB >= 17 and infoB <= 19) then
				--Options click
				  drawOrderOptionsWindow()
				elseif (infoA >= 46 and infoA <= 51) and (infoB >= 17 and infoB <= 19) then
				--Back clicked
				  closeView = true
				  hasMorePages = viewOrdersMenu(currentPage)
				end
			  elseif event == 'rednet_message' then
		        rednetUpdate(id, infoA)
		      end
			until closeView
		  
		  elseif (infoA >= 46) and (infoB >= 17 and infoB <= 19) then
		  --Exit clicked
		    closeMenu = true
			mainMenu()
		  end
		elseif event == 'rednet_message' then
		  rednetUpdate(id, currentMenu, infoA)
		end
	  until closeMenu
	  mainMenu()
	   --Stop update cycle from orderID
	  
	elseif (infoA >= 38 and infoA <= 47) and (infoB >= 12 and infoB <= 15) then
	--View Turtles
	----Get turtle info from orderID, start update cycle
      local currentPage = 1
	  local turtleID
	  local closeMenu
	  
	  local hasMorePages = viewTurtlesMenu(currentPage)
	  
	  repeat
	    local event, id, infoA, infoB = os.pullEvent()
		if event == 'mouse_click' then
		  if (infoA >= 1 and infoA <= 51) and (infoB >= 1 and infoB <= 16) then
		  --Turtle was selected
		  
		    local Index = math.ceil(((currentPage-1)*8)+(infoB/2))
		  
		    if #turtleData >= Index then
		      local closeView
		      local optionsWindowActive = false
		      viewTurtleInfo(Index)
		    
			  repeat
		        local event, id, infoA, infoB = os.pullEvent()
			    if event == 'mouse_click' then
			      if (infoA >= 1 and infoA <= 9) and (infoB >= 17 and infoB <= 19) then
			        --Options selected
				    if optionsWindowActive ~= true then
				      optionsWindowActive = true
			          drawTurtleOptions()
				    end
			      elseif (infoA >= 46 and infoA <= 51) and (infoB >= 17 and infoB <= 19) then
			        --Back clicked
				    closeView = true
					
		          elseif optionsWindowActive and (infoA >= 19 and infoA <= 34) and (infoB >= 4 and infoB <= 16) then
				    --Options window was clicked
				    --Option menu will not close.
				    if (infoA >= 20 and infoA <= 33) then
                    --An option menu was clicked
				      if (infoB ==  5) then
				      --Cancel order
				        optionsWindowActive = false
				        viewTurtleInfo(Index)
				      elseif (infoB ==  7) then
				      --Return to base
				        optionsWindowActive = false
				        viewTurtleInfo(Index)
				      elseif (infoB ==  9) then
				      --Change status
				        optionsWindowActive = false
				        viewTurtleInfo(Index)
				      elseif  (infoB ==  11) then
				      --Force refuel
				        optionsWindowActive = false
				        viewTurtleInfo(Index)
				      elseif (infoB ==  13) then
				      --Pause Turtle
				        optionsWindowActive = false
				        viewTurtleInfo(Index)
				      elseif (infoB ==  15) then
				      --Back
				  	    optionsWindowActive = false
				        viewTurtleInfo(Index)
				      end
				    end
			      elseif optionsWindowActive then
			      --Redraw viewTurtleInfo to remove TurtleOptions
				    optionsWindowActive = false
				    viewTurtleInfo(Index)
			      end
			    elseif event == 'rednet_message' then
		          rednetUpdate(id, infoA)
		        end
              until closeView
			  hasMorePages = viewTurtlesMenu(currentPage)
			end
		  elseif (infoA >= 46 and infoA <= 51) and (infoB >= 17 and infoB <= 19) then
	      --Back
		    closeMenu = true
		  end
		elseif event == 'rednet_message' then
		  rednetUpdate(id, currentMenu, infoA)
		end
	  until closeMenu
	  mainMenu()
	end
  elseif event == 'rednet_message' then
	rednetUpdate(id, currentMenu, infoA)
  end
end
