--Server Three
--Connects to the database, gives position
--of items and obstacles

local mainID = os.getComputerID()
local svr = {}
local event,id,msg

local mainURL = 'http://192.168.1.79/turtle/'
local nodesURL = 'nodes.php'
local errorsURL = 'errors.php'
local ordersURL = 'orders.php'
local itemsURL = 'items.php'
local chestsURL = 'chests.php'
local stationsURL = 'stations.php'
local turtlesURL = 'turtles.php'

rednet.open('top')

--[[term.clear()
term.setCursorPos(19, 9)
term.write('DATABASE SERVER')
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

term.clear()
term.setCursorPos(1,1)

function logError(msg)
  rednet.send(svr.errorID, msg)
end

function split(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={} ; i=1
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                t[i] = str
                i = i + 1
        end
        return t
end

function splitData(inputstr, innerSplit, outerSplit)
  local innerSplit = innerSplit or '|'
  local outerSplit = outerSplit or '\^'
  
  local output = {}
  
  local data = split(inputstr, outerSplit)
  
  for i,v in pairs(data) do
    output[i] = split(v, innerSplit)
  end
  
  return output
end

function interpretArray(array, settings)
  local output = {}
  local settings = settings or {}
  
  if array == nil then
    print('No data to interpret!')
    return
  end
  
  for i=2, #array do
    output[i-1] = {}
	for n=1, #array[i] do
      --Note: If error is here, means that the separation characters (|, ^) are already in use
	  --By the data that is being retrieved.
	  --You need to find other characters to use that the data does not.
	  output[i-1][array[1][n]] = array[i][n]
    end
  end
  
  if settings.single == true then
    return output[1]
  else 
    return output
  end
end

function parseURL(url)
  local output = string.gsub(url, "%s", "%%20")
  return output
end

function getWebpage(requestURL)
  print('Getting webpage')
  http.request(parseURL(requestURL))
  local event, url, text
  local timer = os.startTimer(5)
  repeat
    event, url, text = os.pullEvent()
	if event == 'http_failure' then
	  print('HTTP REQUEST FAILED!')
	  http.request(requestURL)
	elseif event == 'timer' and url == timer then
	  print('Timer expired!')
	  http.request(requestURL)
	end
  until event == 'http_success'
  print('Got Data')
  return event, url, text
end

while true do
  local event, id, msg = os.pullEvent('rednet_message')
  
  if msg.id == 'nodes' then
    if msg.action == 'insert' then
	  print(id..' : Added a new node into the database')
	  local event,url,text = getWebpage(mainURL..nodesURL..'?action=insert&type='..msg.type..'&x='..msg.x..'&y='..msg.y)
	  rednet.send(id, text.readAll())
	  print('Done')
	  
   elseif msg.action == 'edit' then
      print(id..' : Edited an existing node in the database')
	  local event,url,text = getWebpage(mainURL..nodesURL..'?action=edit&id='..msg.id..'&type='..msg.type..'&x='..msg.x..'&y='..msg.y)
	  rednet.send(id, text.readAll())

    elseif msg.action == 'delete' then
	  print(id..' : Deleted a node in the database with id of '..msg.nodeID)
	  local event,url,text = getWebpage(mainURL..nodesURL..'?action=delete&id='..msg.nodeID)
	  rednet.send(id, text.readAll())
      print('Done')
	  
	elseif msg.action == 'getAllNodes' then
      print(id..' : Requested all node data')
      local event,url,text = getWebpage(mainURL..nodesURL..'?action=getAllNodes')
	  rednet.send(id, interpretArray(splitData(text.readAll())))
    			
	elseif msg.action == 'getNodeCoor' then
	  print(id..' : Requested Node Coordinates')
	  print(msg.nodeType)
	  print(msg.nodeID)
	  local event,url,text = getWebpage(mainURL..nodesURL..'?action=getNodeCoor&nodeType='..msg.nodeType..'&nodeID='..msg.nodeID)
	  local text = text.readAll()
	  print(text)
	  rednet.send(id, interpretArray(splitData(text), {single=true}))
	  
	else
	  print('ID Nodes had no action!')
	  if msg.action ~= nil then
	    print(msg.action..' : Invalid action!')
	  end
	end
	  
  elseif msg.id == 'chests' then
    if msg.action == 'insert' then
	  print(id..' : Inserted a new chest')
	  http.request(mainURL..chestsURL..'?action=insert&x='..msg.x..'&y='..msg.y..'&capacity='..msg.capacity..'&status='..msg.status)
	  local event,url,text = os.pullEvent('http_success')
	  rednet.send(id, text.readAll())
	  

	elseif msg.action == 'update' then
	  print(id..' : Edited a chest')
	  http.request(mainURL..chestsURL..'?action=edit&chestID='..msg.chestID..'&status='..msg.status)
	  local event,url,text = os.pullEvent('http_success')
	  rednet.send(id, text.readAll())
	
	elseif msg.action == 'remove' then
	  print(id..' : Removed a chest')
	  http.request(mainURL..chestsURL..'?action=remove&chestID='..msg.chestID)
	  local event,url,text = os.pullEvent('http_success')
	  rednet.send(id, text.readAll())
	
	elseif msg.action == 'getAll' then
	  print(id..' : Requested all chest data')
	  local event,url,text = getWebpage(mainURL..chestsURL..'?action=getAll')
	  rednet.send(id, interpretArray(splitData(text.readAll())))
	
	else
	  print('ID Chests had invalid action!')
	end
  
  elseif msg.id == 'stations' then
    if msg.action == 'insert' then
	  print(id..' : Inserted a new station')
	  local event,url,text = getWebpage(mainURL..stationsURL..'?action=insert&computerID='..msg.computerID..'&nodeID='..msg.nodeID..'&direction='..msg.direction..'&mode='..msg.mode..'&ob1='..msg.ob1..'&ob2='..msg.ob2..'&ob3='..msg.ob3)
	  local text = text.readAll()
	  print(text)
	  rednet.send(id, text)
	  
	elseif msg.action == 'update' then
	  print(id.." : Updated a station's mode")
	  print(msg.computerID)
	  print(msg.mode)
	  
	  local event,url,text = getWebpage(mainURL..stationsURL..'?action=update&computerID='..msg.computerID..'&mode='..msg.mode)
	  rednet.send(id, text.readAll())
	
	elseif msg.action == 'transition' then
	  print(id.." : Updated a station's mode")
	  print(msg.computerID)
	  print(msg.transtionInto)
	  local event,url,text = getWebpage(mainURL..stationsURL..'?action=transition&computerID='..msg.computerID..'&transitionInto='..msg.transtionInto)
	  rednet.send(id, text.readAll())
	
	
	elseif msg.action == 'delete' then
	  print(id..' : Deleted a station')
      local event,url,text = getWebpage(mainURL..stationsURL..'?action=delete&nodeID='..msg.nodeID)
	  rednet.send(id, text.readAll())
	  print('Done')
	
	elseif msg.action == 'getStationData' then
	  print(id..' : Requested all station data')
	  local event,url,text = getWebpage(mainURL..stationsURL..'?action=getAll')
	  rednet.send(id, interpretArray(splitData(text.readAll())))
	else
	  print('ID Stations had invalid action')
	end
  
  elseif msg.id == 'error' then
    print(id..' :  Added a new error')
    local event,url,text = getWebpage(mainURL..errorsURL.."?origin="..msg.origin.."&category="..msg.category.."&text="..msg.text)
	rednet.send(id, text.readAll())

  
  elseif msg.id == 'orders' then
    if msg.action == 'new' then
		 print(id..' :  Added a new order to the DB')
         print(msg.orderType)
         print(msg.itemID)
	     print(msg.reqCount)
		 print(msg.createdBy)
		 
		 http.request(parseURL(mainURL..ordersURL.."?action=new&status=new&orderType="..msg.orderType.."&itemID="..msg.itemID.."&reqCount="..msg.reqCount.."&createdBy="..msg.createdBy))
		 print('Data sent')
		 local event,url,text = os.pullEvent('http_success')
		 local result = text.readAll()
	     print(result)
	     rednet.send(id, result)
    
	elseif msg.action == 'assign' then
		print(id..' : Assign an order to turtle '..msg.assignTo)
	    http.request(mainURL..ordersURL.."?action=assign&orderID="..msg.orderID.."&assignTo="..msg.assignTo.."&destinationType="..msg.destinationType.."&destinationID="..msg.destinationID.."&destinationPos="..msg.destinationPos)
	    print('Data sent')
		local event, url, text = os.pullEvent('http_success')
		rednet.send(id, text.readAll())
		
	elseif msg.action == 'updateStatus' then
  	     print(id..' :  Updated an order in the DB')
		 http.request(mainURL..ordersURL.."?action=updateStatus&orderID="..msg.orderID.."&status="..msg.status)
		 print('Data sent')
	     local event,url,text = os.pullEvent('http_success')
		 rednet.send(id, text.readAll())

	 elseif msg.action == 'getWaitingOrders' then
	     print(id..' :  Requested all active orders')
		 http.request(mainURL..ordersURL.."?action=getWaitingOrders")
	     local event,url,text = os.pullEvent('http_success')
		 rednet.send(id, interpretArray(splitData(text.readAll())))
	  else
	    print('ID Orders had invalid action!')
	  end

  elseif msg.id == 'items' then
    if msg.action == 'new' then
	   print(id..' :  Added a new item to the DB')
	   print(msg.itemName)
	   print(msg.displayName)
	   print(msg.modName)
	   print(msg.count)
	   print(msg.dmg)
	   print(msg.locationID)
	   print(msg.locationPos)
	   http.request(parseURL(mainURL..itemsURL.."?action=new&itemName="..msg.itemName.."&displayName="..msg.displayName.."&modName="..msg.modName.."&count="..msg.count.."&dmg="..msg.dmg.."&locationID="..msg.locationID.."&locationPos="..msg.locationPos))
	   print('Data sent')
       local event,url,text = os.pullEvent('http_success')
	   local result = text.readAll()
	   print(result)
	   rednet.send(id, result)

	elseif msg.action == 'updateLocation' then
	   print(id.." :  Updated an item's location in the DB")
       http.request(mainURL..itemsURL.."?action=updateLocation&itemID="..msg.itemID.."&locationID="..msg.locationID.."&locationPos="..msg.locationPos)
	   print('Data sent')
       local event,url,text = os.pullEvent('http_success')
	   rednet.send(id, text.readAll())

	elseif msg.action == 'updateCount' then
	   print(id.." :  Updated an item's count in the DB")
       http.request(mainURL..itemsURL.."?action=updateCount&itemID="..msg.itemID.."&count="..msg.count)
	   print('Data sent')
       local event,url,text = os.pullEvent('http_success')
	   rednet.send(id, text.readAll())
	
	elseif msg.action == 'remove' then
	   print(id..' : Removed an item in the DB with itemID of '..msg.itemID)
	   http.request(mainURL..itemsURL.."?action=remove&itemID="..msg.itemID)
	   print('Data sent')
       local event,url,text = os.pullEvent('http_success')
	   rednet.send(id, text.readAll())

	 elseif msg.action == 'getAll' then
	   print(id..' : Requested all item information')
	   http.request(mainURL..itemsURL.."?action=getAll")
       print('Data sent')
       local event,url,text = os.pullEvent('http_success')
	   rednet.send(id, interpretArray(splitData(text.readAll(), '#')))
	   
	 elseif msg.action == 'getItemIndex' then
	   print(id..' : Requested item index information')
	   http.request(mainURL..itemsURL.."?action=getItemIndex")
	   local event, url, text = os.pullEvent('http_success')
	   local text = text.readAll()
	   
	   if text == 'error' then
	     print('Something went wrong, replacing result with empty array')
		 text = {}
	   else
	      text = interpretArray(splitData(text, '#'))
	   end
	   rednet.send(id, text)
	 
	 elseif msg.action == 'getItemsToSpawn' then
	   print(id..' : Requested items to spawn')
	   http.request(mainURL..itemsURL.."?action=getItemsToSpawn")
	   local event, url, text = os.pullEvent('http_success')
	   local text = text.readAll()
	   
	   if text == 'error' then
	     print('Something went wrong, replacing result with empty array')
		 text = {}
	   else
	      text = interpretArray(splitData(text, '#'))
	   end
	   rednet.send(id, text)
	 
	 elseif msg.action == 'addItemToSpawn' then
	   print(id..' : Added an item to spawn')
	   http.request(parseURL(mainURL..itemsURL.."?action=addItemToSpawn&itemID="..msg.itemID.."&itemName="..msg.itemName.."&dmg="..msg.dmg.."&mod="..msg.mod.."&maxStack="..msg.maxStack))
	   local event, url, text = os.pullEvent('http_success') 
	   rednet.send(id, text.readAll())
	 
	 else
	  print('ID Items had invalid action!')
	 end
  elseif msg.id == 'turtles' then
    if msg.action == 'getStatistics' then
	  print(id..' : Getting statistics for turtle '..msg.turtleID)
	  local event,url,text = getWebpage(mainURL..turtlesURL..'?action=getStatistics&turtleID='..msg.turtleID)
	  rednet.send(id, interpretArray(splitData(text.readAll()), {single=true}))
	end
  
  else
    print('Invalid ID!')
	print('Come from '..id)
	for i,v in ipairs(msg) do
	  print(i)
	  print(v)
	end
  end
end
