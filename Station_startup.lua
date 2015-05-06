rednet.open('top')

local id,msg
repeat
 rednet.broadcast('station_built')
 id, msg = rednet.receive(5)
until msg == 'ok'

print('Setting up Station...')

fs.copy("disk/startup.file", "startup")

rednet.broadcast('station_built')

shell.run('startup')

