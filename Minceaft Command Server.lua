rednet.open('top')

--0, 0 of warehouse relative to minecraft world
local x = 740       --     -x
local y = 84         -- +z   -z
local z = -809       --    +x

function setBlock(x, z, y, blocktype, data, itemData)
  local data = data or 0
  local itemData = itemData or ''
  local command = 'setblock '..x..' '..y..' '..z..' '..blocktype..' '..data..' replace '..itemData
  print(command)
  local bool, result = commands.exec(command)
  if bool == false then
    print(result[1])
  end
end

function buildStation(zCor, xCor, direction)
  local x = x + xCor
  local z = z - zCor
  local id, msg
  
  if direction == 'north' then
    setBlock(x-2, z, y, 'ComputerCraft:CC-Peripheral', 3)
    setBlock(x-2, z, y+1, 'minecraft:hopper',0, '{Items:[{Count:1, id:5037, Damage:10}]}')
    setBlock(x-2, z, y+1, 'ComputerCraft:CC-Computer', 11)
	setBlock(x-3, z, y, 'IronChest:BlockIronChest')
    setBlock(x-1, z, y, 'IronChest:BlockIronChest')
    setBlock(x-1, z, y+1, 'IronChest:BlockIronChest')
    setBlock(x-3, z, y+1, 'EnderStorage:enderChest')
    setBlock(x, z, y-1, 'minecraft:lapis_block')
    setBlock(x-2, z, y+2, 'ComputerCraft:CC-Peripheral')
  
    print('Please start the station.')
  
    repeat
      id, msg = rednet.receive(1)
    until msg == 'station_built'
  
    setBlock(x-2, z, y, 'minecraft:lava')
    os.sleep(0.5)
	setBlock(x-2, z, y, 'IronChest:BlockIronChest')
    
  elseif direction == 'south' then
    
	setBlock(x+2, z, y, 'ComputerCraft:CC-Peripheral', 3)
    setBlock(x+2, z, y+1, 'minecraft:hopper',0, '{Items:[{Count:1, id:5037, Damage:10}]}')
    setBlock(x+2, z, y+1, 'ComputerCraft:CC-Computer', 10)
    setBlock(x+3, z, y, 'IronChest:BlockIronChest')
    setBlock(x+1, z, y, 'IronChest:BlockIronChest')
    setBlock(x+1, z, y+1, 'IronChest:BlockIronChest')
    setBlock(x+3, z, y+1, 'EnderStorage:enderChest')
    setBlock(x, z, y-1, 'minecraft:lapis_block')
    setBlock(x+2, z, y+2, 'ComputerCraft:CC-Peripheral')
  
    print('Please start the station.')
  
    repeat
      id, msg = rednet.receive(1)
    until msg == 'station_built'
  
    setBlock(x+2, z, y, 'minecraft:lava')
    os.sleep(0.5)
	setBlock(x+2, z, y, 'IronChest:BlockIronChest')
  
  elseif direction == 'east' then
  
    setBlock(x, z-2, y, 'ComputerCraft:CC-Peripheral', 5)
    setBlock(x, z-2, y+1, 'minecraft:hopper',0, '{Items:[{Count:1, id:5037, Damage:10}]}')
    setBlock(x, z-2, y+1, 'ComputerCraft:CC-Computer', 12)
    setBlock(x, z-3, y, 'IronChest:BlockIronChest')
    setBlock(x, z-1, y, 'IronChest:BlockIronChest')
    setBlock(x, z-1, y+1, 'IronChest:BlockIronChest')
    setBlock(x, z-3, y+1, 'EnderStorage:enderChest')
    setBlock(x, z, y-1, 'minecraft:lapis_block')
    setBlock(x, z-2, y+2, 'ComputerCraft:CC-Peripheral')
  
    print('Please start the station.')
  
    repeat
      id, msg = rednet.receive(1)
    until msg == 'station_built'
	
    setBlock(x, z-2, y, 'minecraft:lava')
    os.sleep(0.5)
	setBlock(x, z-2, y, 'IronChest:BlockIronChest')
	
  elseif direction == 'west' then
   
	setBlock(x, z+2, y, 'ComputerCraft:CC-Peripheral', 4)
	setBlock(x, z+2, y+1, 'minecraft:hopper',0, '{Items:[{Count:1, id:5037, Damage:10}]}')
	setBlock(x, z+2, y+1, 'ComputerCraft:CC-Computer', 13)
    setBlock(x, z+3, y, 'IronChest:BlockIronChest')
	setBlock(x, z+1, y, 'IronChest:BlockIronChest')
    setBlock(x, z+1, y+1, 'IronChest:BlockIronChest')
    setBlock(x, z+3, y+1, 'EnderStorage:enderChest')
    setBlock(x, z, y-1, 'minecraft:lapis_block')
    setBlock(x, z+2, y+2, 'ComputerCraft:CC-Peripheral')
  
    print('Please start the station.')
    
	
    repeat
      id, msg = rednet.receive()
    until msg ~= nil and msg == 'station_built'
  
    setBlock(x, z+2, y, 'minecraft:lava')
    os.sleep(0.5)
	setBlock(x, z+2, y, 'IronChest:BlockIronChest')
  end
  return id
end

function removeStation(zCor, xCor, direction)
  local x = x + xCor
  local z = z - zCor
  
  if direction == 'north' then
    setBlock(x-2, z, y+2, 'minecraft:air')
    setBlock(x-1, z, y+1, 'minecraft:air')
    setBlock(x-2, z, y+1, 'minecraft:air')
    setBlock(x-3, z, y+1, 'minecraft:air')

    setBlock(x-3, z, y, 'minecraft:air')
    setBlock(x-2, z, y, 'minecraft:air')
    setBlock(x-1, z, y, 'minecraft:air')
	
    setBlock(x, z, y-1, 'minecraft:stone')
 
  elseif direction == 'south' then
    setBlock(x+2, z, y+2, 'minecraft:air')
    setBlock(x+3, z, y+1, 'minecraft:air')
    setBlock(x+2, z, y+1, 'minecraft:air')
    setBlock(x+1, z, y+1, 'minecraft:air')

    setBlock(x+1, z, y, 'minecraft:air')
    setBlock(x+2, z, y, 'minecraft:air')
    setBlock(x+3, z, y, 'minecraft:air')
	
    setBlock(x, z, y-1, 'minecraft:stone')
  elseif direction == 'west' then
        
	setBlock(x, z+2, y+2, 'minecraft:air')
    setBlock(x, z+1, y+1, 'minecraft:air')
    setBlock(x, z+2, y+1, 'minecraft:air')
    setBlock(x, z+3, y+1, 'minecraft:air')

    setBlock(x, z+3, y, 'minecraft:air')
    setBlock(x, z+2, y, 'minecraft:air')
    setBlock(x, z+1, y, 'minecraft:air')
	
    setBlock(x, z, y-1, 'minecraft:stone')

  elseif direction == 'east' then
	
	setBlock(x, z-2, y+2, 'minecraft:air')
    setBlock(x, z-1, y+1, 'minecraft:air')
    setBlock(x, z-2, y+1, 'minecraft:air')
    setBlock(x, z-3, y+1, 'minecraft:air')

    setBlock(x, z-3, y, 'minecraft:air')
    setBlock(x, z-2, y, 'minecraft:air')
    setBlock(x, z-1, y, 'minecraft:air')
	
    setBlock(x, z, y-1, 'minecraft:stone')
  end
end

term.clear()
term.setCursorPos(1,1)
term.write('Command Server')
term.setCursorPos(1,2)
term.write('For setting up stations')
while true do  
  local action, id, msg = os.pullEvent()
  if action == 'rednet_message' then
    if msg.id ~= nil then
	  print(msg.id)
	end
    if msg.id == 'buildStation' then
      local stationID = buildStation(msg.x, msg.y, msg.direction)
	  rednet.send(id, stationID)
    elseif msg.id == 'removeStation' then
	  print(msg.x)
	  print(msg.y)
	  print(msg.direction)
	  print('Removing station at '..msg.x..':'..msg.y..' Direction: '..msg.direction)
	  removeStation(msg.x, msg.y, msg.direction)
	  rednet.send(id, 'ok')
    end
  end
end

