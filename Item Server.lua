--Sorts items from storage or generate new items

rednet.open('bottom')

local outputChest = peripheral.wrap('right')
local workChest = peripheral.wrap('top')

local maxItemGeneration = 30
local generateItems = 'on'
local mode = 'takeFromInput' --or generateItems

local svr = {
  databaseID = 43
}

function sendMessage(id, msg)
  local comp, response
  repeat
    print('Sending Message to '..id)
    rednet.send(id,msg)
    comp, response = rednet.receive(5)
  until comp == id
  return comp, response
end

function setBlock(blockData)
  local bool, result = commands.exec(blockData)
  if bool == false then
    print(result[1])
  end
end

function getOutputChestCapacity() 
  local items = 0
  for i=1, outputChest.getInventorySize() do
    if outputChest.getStackInSlot(i) then
      items = items + 1
    end
  end
  return outputChest.getInventorySize() - items
end

function moveToOutput(slot, number)
  local i = 1
  while outputChest.getStackInSlot(i) ~= nil do
    i = i + 1
  end

  workChest.pushItem('east', slot)
  outputChest.pullItem('up', 1, number, i)
end


local _,itemIndex 		= sendMessage(svr.databaseID, {id='items', action='getItemIndex'})
local _,itemsToSpawn  = sendMessage(svr.databaseID, {id='items', action='getItemsToSpawn'})
if type(itemIndex) ~= 'table' then
  print('itemIndex is not a table!')
  return
elseif type(itemsToSpawn) ~= 'table' then
  print('itemsToSpawn is not a table!')
  return
end

print('Items in index: '..#itemIndex)
print('Items to spawn: '..#itemsToSpawn)

--Main()
while true do
  local action, id, msg = os.pullEvent()
  if action == 'redstone' then
    
	local outputChestSpace = getOutputChestCapacity()
    print('Output Capacity: '..outputChestSpace)	
	
	if outputChestSpace ~= 0 then
      
	  if mode=='generateItems' then
        if #itemsToSpawn ~= 0 then
		  while outputChestSpace ~= 0 do
		    --generate item
		    local randNum = math.ceil(math.random(1, #itemsToSpawn))
		    setBlock('setblock ~ ~+1 ~ minecraft:air')
		    setBlock('setblock ~ ~+1 ~ IronChest:BlockIronChest 6 delete {Items:[{id:'..itemsToSpawn[randNum].itemID..', Count:'..math.ceil(math.random(1, itemsToSpawn[randNum].maxStack))..', Damage:'..itemsToSpawn[randNum].dmg..'}]}')
	        print('Spawning new item: '..itemsToSpawn[randNum].itemName)
	        item = workChest.getStackInSlot(1)

            --Split item stack if qty over random number between 16 and 64
            local randNum = math.ceil(math.random(16, 64))--Random number between 16 and 64
            if item.qty > randNum and outputChestSpace > 1 then
              --Move extra to output free slots
              moveToOutput(1, randNum)
            end

            --Move item to output free slots
            moveToOutput(1 ,64)

	        --Get output spaces left
	        outputChestSpace = getOutputChestCapacity()
	      end
	    else
		  print('Generator has no items it can spawn!')
		end

	  elseif mode=='takeFromInput' then
	    --Get item from input chest
	    while outputChestSpace ~= 0 do
		
		  local slot = 0
	      local item
	      repeat
	        slot = slot + 1
		    workChest.pullItem('west', slot)
		    item = workChest.getStackInSlot(1)
	      until item ~= nil or slot == 108
        
		  --If no more items found in input, no need to continue looping
		  if item == nil and slot == 108 then
		    print('No more items found in input')
		    break
		  end
		  
		  --See if item is already added in list of items to spawn
		  local alreadyExists = false
		  for i,itemToSpawn in pairs(itemsToSpawn) do
		    if itemToSpawn.itemName == item.display_name and tonumber(itemToSpawn.dmg) == item.dmg then
			  print('Item already added in itemsToSpawn. Breaking loop.')
			  alreadyExists = true
			  break
			end
	      end

	      if not alreadyExists then
			--Item was not found in itemsToSpawn, so create it.
			
			for _,itemIndexInfo in pairs(itemIndex) do
			  print(itemIndexInfo.itemName)
			  print(item.id)
			  if itemIndexInfo.itemName == item.id then

			    local _,rowID = sendMessage(svr.databaseID, {id='items', action='addItemToSpawn', itemID=itemIndexInfo.itemID, itemName=item.display_name, dmg=item.dmg, mod=item.mod_id, maxStack=item.max_size})
			    if type(tonumber(rowID)) ~= 'number' then
				  print('Something went wrong')
				  print(rowID)
				else
				  table.insert(itemsToSpawn, {id=rowID, itemID=itemIndexInfo.itemID, itemName=item.display_name, dmg=item.dmg, mod=item.mod_id, maxStack=item.max_size})
				end
				break
		      end
			end
	      end
		 
		  --Split item stack if qty over random number between 16 and 64
          local randNum = math.ceil(math.random(16, 64))--Random number between 16 and 64
          if item.qty > randNum and outputChestSpace > 1 then
            --Move extra to output free slots
            moveToOutput(1, randNum)
          end

          --Move item to output free slots
          moveToOutput(1 ,64)

	      --Get output spaces left
	      outputChestSpace = getOutputChestCapacity()
        end
	  end
    end
  elseif action == 'rednet_message' then
    if msg.id == 'generateItems_on' then
      generateItems = 'on'
    elseif msg.id == 'generateItems_off' then
	  generateItems = 'off'
	end
  elseif action == 'key' and id == 207 then
    if mode == 'generateItems' then
	  mode = 'takeFromInput'
	  print('Mode switched to takeFromInput')
	elseif mode == 'takeFromInput' then
	  mode = 'generateItems'
	  print('Mode switched to generateItems')
	end
  end
end
