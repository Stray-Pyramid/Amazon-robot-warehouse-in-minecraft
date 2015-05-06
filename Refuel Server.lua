local fuelChest = peripheral.wrap('back')

rednet.open('bottom')

--Get inital count of fuel
local stacks = fuelChest.getAllStacks()
local fuelCount = 0
for int, value in pairs(stacks) do

  fuelCount = fuelCount + value.qty  
end

print('Fuel Server')
print(fuelCount..' units of fuel left')


while true do
  local event, id, infoA, infoB = os.pullEvent()
  if event == 'rednet_message' then
    if infoA.action == 'refuelRequest' then
      repeat 
        --infoA.qty = amount of fuel requested
        --If Not enough fuel?
        --If no fuel?
        
        --Search stacks in chest, transfer to turtle
        --until number of infoA.qty == 0
      until infoA.qty == 0
    elseif infoA.action == 'fuelCount' then
      rednet.send(id, fuelCount)
    end 
  end
end
