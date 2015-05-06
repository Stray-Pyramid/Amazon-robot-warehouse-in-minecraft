--Server Six
--Display issues in chat and sound alarm


local chatBox 	= peripheral.wrap('bottom')
local speaker 	= peripheral.wrap('right')
local alarmSide = 'back'
local compID 	= os.getComputerID()

local chat_enabled 	= true
local voice_enabled 	= true
local alarm_enabled 	= true
local eventArray = {}
local svr = {databaseID = 43}
local menuPos = 1
local id,msg


rednet.open('top')
--[[
term.setCursorPos(13, 9)
term.write('WAITING FOR MASTER SERVER')

repeat
  id,msg = rednet.receive()
  if msg == 'server.rollcall' then
    rednet.send(id, 'server.error')
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

for i=1, 19 do
  term.setCursorPos(35, i)
  term.write('||')
end

term.setCursorPos(37,1)
term.write('My ID is '..compID)
term.setCursorPos(37,4)
term.write('ChatBox is ON')
term.setCursorPos(37,7)
term.write('Speaker is ON')
term.setCursorPos(37,10)
term.write('Alarm is ON')
term.setCursorPos(1,1)

term.write('Waiting for error messages...')

local function updateMenu()
    term.setCursorPos(37,3)
    term.write('               ')
	term.setCursorPos(37,5)
    term.write('               ')
    term.setCursorPos(37,6)
    term.write('               ')
	term.setCursorPos(37,8)
    term.write('               ')
    term.setCursorPos(37,9)
    term.write('               ')
	term.setCursorPos(37,11)
    term.write('               ')
  if menuPos == 1 then
    term.setCursorPos(37,3)
    term.write('---------------')
	term.setCursorPos(37,5)
    term.write('---------------')
  elseif menuPos == 2 then
    term.setCursorPos(37,6)
    term.write('---------------')
	term.setCursorPos(37,8)
    term.write('---------------')
  else
    term.setCursorPos(37,9)
    term.write('---------------')
	term.setCursorPos(37,11)
    term.write('---------------')
  end
end

local function textWrap( strRaw, limit, indent )

   local space = indent or ''
   local t={} ; i=1
   local here = 1 - #space

   local strSplit = strRaw:gsub( "(%s+)()(%S+)()",
      function( sp, st, word, fi )
        if fi-here > limit then
            here = st
            return "/"..word
        end
    end )

	for str in string.gmatch(strSplit, "([^/]+)") do
               t[i] = str
               i = i + 1
    end
    return t
end

local function eventAdd(id, msg)

	local text = textWrap(id..': '..msg,39,"     ")
	for k,v in pairs(text) do table.insert(eventArray, v) end
	
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

local function alert(id, msg, category)
  id = tostring(id)
  if chat_enabled then
    chatBox.say(id..':'..msg)
  end
  if alarm_enabled then
    rs.setOutput(alarmSide, true)
    os.sleep(0.5)
    rs.setOutput(alarmSide, false)
  end
  if voice_enabled then
    speaker.speak('Error received from turtle with id '..id)
	--Add differentiation between servers and turtles
  end

end

local function uploadError(id, category, text)
 repeat
  	rednet.send(svr.databaseID, {id='error', origin=id, category=category, text=text})
  	local id, msg = rednet.receive(1)
 until msg ~= nil
end

updateMenu(menuPos)

--Begin
while true do
  local event, id, infoA, infoB = os.pullEvent()
  if event == 'key' then
    if id == 28 then
      if menuPos == 1 then
  	    term.setCursorPos(37,4)
        if chat_enabled then
      		  chat_enabled = false
      		  term.write('ChatBox is OFF')
      		else
      		  chat_enabled = true
      		  term.write('ChatBox is ON ')
      		end
      elseif menuPos == 2 then
        term.setCursorPos(37,7)
      		if voice_enabled then
      		  voice_enabled = false
      		  term.write('Speaker is OFF')
      		else
      		  voice_enabled = true
      		  term.write('Speaker is ON ')
      		end
      elseif menuPos == 3 then
        term.setCursorPos(37,10)
      		if alarm_enabled then
      		  alarm_enabled = false
      		  term.write('Alarm is OFF')
      		else
      		  alarm_enabled = true
      		  term.write('Alarm is ON ')
      		end
      end
    elseif id == 200 then
      if menuPos ~= 1 then
        menuPos = menuPos - 1
        updateMenu(menuPos)
    	 end
    elseif id == 208 then
      if menuPos ~= 3 then
        menuPos = menuPos + 1
        updateMenu(menuPos)
      end
    elseif id == 207 then
      os.restart()
    end
  elseif event == 'mouse_click' then
	if (infoA >= 37 and infoA <= 51) and (infoB >= 3 and infoB <= 5) then
	  menuPos = 1
      updateMenu(menuPos)
	  term.setCursorPos(37,4)
      if chat_enabled then
        chat_enabled = false
        term.write('ChatBox is OFF')
      else
        chat_enabled = true
        term.write('ChatBox is ON ')
      end
	elseif (infoA >= 37 and infoA <= 51) and (infoB >= 6 and infoB <= 8) then
	  menuPos = 2
      updateMenu(menuPos)
	  term.setCursorPos(37,7)
      if voice_enabled then
        voice_enabled = false
        term.write('Speaker is OFF')
      else
        voice_enabled = true
        term.write('Speaker is ON ')
      end
	elseif (infoA >= 37 and infoA <= 51) and (infoB >= 9 and infoB <= 11) then
	  menuPos = 3
      updateMenu(menuPos)
	  term.setCursorPos(37,10)
      if alarm_enabled then
        alarm_enabled = false
        term.write('Alarm is OFF')
      else
        alarm_enabled = true
        term.write('Alarm is ON ')
      end
	end
  elseif event == 'rednet_message' then
    if infoA.action == 'ERROR' then
	  rednet.send(id, 'MESSAGE_RECEIVED')
	  local category = infoA.category or 'unknown'
	  eventAdd(infoA.origin, infoA.error)
      alert(infoA.origin, infoA.error, category)
	  uploadError(infoA.origin, category, infoA.error)
	end
  end
end
