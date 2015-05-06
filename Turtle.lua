--Version 1.00

local xDefPos = 5
local yDefPos = 11
local xChsPos = 21
local yChsPos = 17
local xCurrent = xDefPos
local yCurrent = yDefPos
local rotationDef = 0

turtle.refuel()

function forward()
  while bool == 'false' do
    local bool = turtle.forward()
  end
end

function gotoChest(xPos, yPos)
  print('Going to X: '..xPos..' Y: '..yPos) 
  for i=xCurrent + 1, xPos do
    turtle.forward()
    xCurrent = xCurrent + 1
  end
  if yPos > yCurrent then
    turtle.turnRight()
  else
    turtle.turnLeft()
  end
  for i=yCurrent + 1, yPos, 1 do
    turtle.forward()
    yCurrent = yCurrent + 1
  end
end

function gotoDefault()
  print('Current Pos X: '..xCurrent..' Y: '..yCurrent)
  print('Going to X: '..xDefPos..' Y: '..yDefPos)
  for i=yCurrent + 1, yDefPos, -1 do
    turtle.forward()
  end
  if xDefPos > xCurrent then
    turtle.turnRight()
  else
    turtle.turnLeft()
  end
  for i=xCurrent + 1, xDefPos, -1 do
    turtle.forward()
  end
end

gotoChest(xChsPos - 1, yChsPos)
turtle.turnLeft()
turtle.turnLeft()
gotoDefault()
turtle.turnLeft()
turtle.turnLeft()
