--Server Two
--Pathing Server
--Uses A* pathing algorithm

local openNodes = {}
local closedNodes = {}
local showActivity = false


local xWall = 25  --Size of area in blocks
local yWall = 50
local setNodes = {}
local svr = {
  databaseID = 43,
  monitorID = 84
}

rednet.open('top')

function sendMessage(id, msg)
  local response
  repeat
    print('Sending message to '..id)
    rednet.send(id,msg)
    response, rmsg = rednet.receive(2)
  until response == id
  return response, rmsg
end

function reportToMonitor(msg)
  if showActivity then
    sendMessage(svr.monitorID, msg)
    os.sleep(0.05)
  end
end

function getSetNodes()
  local id,msg
  repeat
    rednet.send(svr.databaseID, {id='nodes',action='getAllNodes'})
    id,msg = rednet.receive(10)
  until id == svr.databaseID
  print('Got Set Nodes')
  return msg
end

--obstacles
function isSetNode(x, y, filter)
  if filter == nil then
    print('isSetNode requires a filter!')
	return
  end
  for k,v in pairs(setNodes) do
    if x == tonumber(v.x) and y == tonumber(v.y) and v.type == filter then
      return true
    end
  end
  return false
end

function isNode(x, y)
  for k,v in pairs(openNodes) do
    if x == v.x and y == v.y then
      return true
    end
  end
  for k,v in pairs(closedNodes) do
    if x == v.x and y == v.y then
      return true
    end
  end
  return false
end

function calculateCost(nodex, nodey, destx, desty, parentx, parenty)

  local normal = 5
  local restricted = 10
  local express = 2
  
  --Note: not currently implemented.
  --Implementing differing path costs would
  --require a database of nodes with customized
  --path costs
  --G = Movement cost from original position
  --H = Estimated movement cost till destination
  
  local g
  local h
  local parentID = 0
  
  for k,v in pairs(openNodes) do
	if parentx == v.x and parenty == v.y then
      parentID = k
    end
  end
  g = openNodes[parentID].g + normal
  
  x = math.abs(nodex - destx)
  y = math.abs(nodey - desty)
  h = (x + y) * normal
  
  return g,h
end

function findNewNodes(x ,y, xDest, yDest)
  for i=0, 3 do
    if i == 0 then
      nodeX = x
      nodeY = y + 1
    elseif i == 1 then
      nodeX = x + 1
      nodeY = y
    elseif i == 2 then
      nodeX = x
      nodeY = y - 1
    elseif i == 3 then
      nodeX = x - 1
      nodeY = y
    end
    if isSetNode(nodeX, nodeY, 'obstacle') then
      --print(nodeX..';'..nodeY..' was an obstacle')
    elseif isNode(nodeX, nodeY)  then
      --print(nodeX..';'..nodeY..' has already been added')
    elseif nodeX==0 or nodeX>xWall or nodeY==0 or nodeY>yWall then
      --print('Node was out of bounds')
	else
      local gCost,hCost = calculateCost(nodeX, nodeY, xDest, yDest, x, y)
      table.insert(openNodes, {x=nodeX, y=nodeY, px=x, py=y , g=gCost , h=hCost })
      reportToMonitor({id='pather', action='addOpenNode', x=nodeX, y=nodeY, count=#openNodes})
	  --print('Node x:'..nodeX..' y:'..nodeY..' was added. Cost g: '..gCost..' h: '..hCost)
    end
  end
end

function findLowestCost(openNodes)
  local lowestId = 1
  --print('Finding node with lowest cost...')
  for k, v in pairs(openNodes) do
    --print(k..': '..v.x..'|'..v.y..': '..v.g..'+'..v.h..' < '..openNodes[lowestId].g..' + '..openNodes[lowestId].h)
    if(v.g + v.h) <= (openNodes[lowestId].g + openNodes[lowestId].h) then
      nodeX = v.x
      nodeY = v.y
      lowestId = k
      --print('lowestId is now '..k)
      --print('x: '..nodeX..' y: '..nodeY)
      --print('g:'..openNodes[lowestId].g..' h:'..openNodes[lowestId].h)
    end
  end
  return nodeX, nodeY 
end

function moveToClosed(x, y)
  local id
  for k,v in pairs(openNodes) do
	if v.x == x and v.y == y then
		id = k
	end
  end
  local data = openNodes[id]
  --print('node '..openNodes[id].x..':'..openNodes[id].y..' was moved to the closed list')
  table.remove(openNodes, id)
  table.insert(closedNodes, data)

end

function goalInClosed(x, y)
  for k,v in pairs(closedNodes) do 
    if x == v.x and y==v.y then
      return true
    end
  end
  return false
end

function findNodeID(x ,y, list)
  for k,v in pairs(list) do
    if v.x == x and v.y == y then
      return k
    end
  end
end

function traceRoute(goalx, goaly, closedNodes)
  local routeTable = {}
  local activeID = findNodeID(goalx, goaly, closedNodes)
  table.insert(routeTable, {x=closedNodes[activeID].x, y=closedNodes[activeID].y})
  while closedNodes[activeID].px and closedNodes[activeID].py do
    activeID = findNodeID(closedNodes[activeID].px, closedNodes[activeID].py, closedNodes)
	if closedNodes[activeID].px then
		table.insert(routeTable, {x=closedNodes[activeID].x, y=closedNodes[activeID].y})
	end
  end
  return routeTable
end

function findRoute(xOrigin, yOrigin, xDest, yDest)
  openNodes = {}
  closedNodes = {}
  
  local routeFound = false
  local xCurrent = xOrigin
  local yCurrent = yOrigin
  print('Finding route from '..xOrigin..':'..yOrigin..' to '..xDest..':'..yDest)
  
  if xDest==0 or xDest>xWall or yDest==0 or yDest>yWall then
	reportToMonitor({id='pather', action=cannotFindPath})
	return 'Destination is out of bounds!'
  
  elseif xOrigin==0 or xOrigin>xWall or yOrigin==0 or yOrigin>yWall then
    reportToMonitor({id='pather', action=cannotFindPath})
	return 'Origin is out of bounds!'

  elseif isSetNode(xDest, yDest, 'obstacle') then
    reportToMonitor({id='pather', action=cannotFindPath})
	return 'Destination is an obstacle!'
	
  elseif isSetNode(xOrigin, yOrigin, 'obstacle') then
    reportToMonitor({id='pather', action=cannotFindPath})
	return 'Origin is an obstacle'
  end
  
  --Add origin node to open list
  table.insert(openNodes, {x=xOrigin, y=yOrigin, g=0, h=0})
  
  
  --Find First available Nodes
  while goalInClosed(xDest, yDest) == false do
    findNewNodes(xCurrent, yCurrent, xDest, yDest)
    moveToClosed(xCurrent, yCurrent)
    reportToMonitor({id='pather', action='addClosedNode', x=xCurrent, y=yCurrent, Ccount=#closedNodes, Ocount=#openNodes})
	xCurrent, yCurrent = findLowestCost(openNodes)
  end
  route = traceRoute(xDest, yDest, closedNodes) 
  route = reverseTable(route)
  reportToMonitor({id='pather', action='foundPath', path=route})
  return route
end

function reverseTable(t)
    local reversedTable = {}
    local itemCount = #t
    for k, v in ipairs(t) do
        reversedTable[itemCount + 1 - k] = v
    end
    return reversedTable
end


term.clear()
term.setCursorPos(1,1)
print('PATHING SERVER')
print('Waiting for request...')

setNodes = getSetNodes()

while true do
  print('Starting Cycle')
  local category,id,msg = os.pullEvent()
  if category == 'rednet_message' then
    print('Rednet message from '..id)
    if msg.action ~= nil then
	  print(msg.action)
	end
	if msg.action == 'findPath' then
      reportToMonitor({id='pather', action='newPath', turtleID=id, startPos=msg.Ox..':'..msg.Oy, endPos=msg.Dx..':'..msg.Dy})
	  local result = findRoute(msg.Ox, msg.Oy, msg.Dx, msg.Dy)
      rednet.send(id, result)
	  if type(result) ~= 'table' then
	    print(result)
	  else
	    for i,v in pairs(result) do
	      print(i..'>'..v.x..' : '..v.y)
	    end
      end
    elseif msg.action == 'addSetNode' then
      print('Added node at '..msg['data'].x..':'..msg['data'].y)
	  table.insert(setNodes, {id=msg['data'].nodeID, type=msg['data'].type, x=msg['data'].x, y=msg['data'].y})
	  rednet.send(id, 'ok')
	elseif msg.action == 'deleteSetNode' then
	  for i,v in pairs(setNodes) do
	    if v.id == msg.nodeID then
		  print('Deleted node at '..v.x..':'..v.y)
		  table.remove(setNodes, i)

		  break
		end
	  end
	  rednet.send(id, 'ok')
	elseif msg.action == 'activateDisplay' then
	  showActivity = true
	  rednet.send(id, 'ok')
	elseif msg.action == 'disableDisplay' then
	  showActivity = false
	  rednet.send(id, 'ok')
	end
  end
end




