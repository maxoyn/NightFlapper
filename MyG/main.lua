local sti = require "sti"

function love.load()
	map = sti("NightMap1.lua", { "box2d" })
	loadf()
	--characterX = 20
	--characterY = 200
	yVelocity = 0
	xVelocity = 120
	windowWidth  = love.graphics.getWidth()
    windowHeight = love.graphics.getHeight()
	playerHeight = 32
	playerWidth = 32
	tileWidth = 64
	tileHeight = 64
	mapWidth = 25
	mapHeight = 10
	tx = 0;
	jump = false
	dead = false
	start = false
	scored = false

	score = 0
	timedead = 0
	
	font = love.graphics.newFont("Neon.ttf",25)
	love.graphics.setFont(font)
	
	love.physics.setMeter(32)
	world = love.physics.newWorld(0, 0)
	map:box2d_init(world)
	map:addCustomLayer("Sprite Layer",3)

	music = love.audio.newSource("MyS.mp3")
	music:setVolume(0.1)
	music:setLooping(true)
	if not restart then
		music:play()
	end
	restart = false
	crash = love.audio.newSource("crash.ogg", "static")
	crash:setVolume(0.2)
	crash:setLooping(false)
	
	local quad = love.graphics.newQuad
	iteration = 1
	timer = 0
	quads = {}
	for i=1,4 do
		quads[i] = quad((i-1)*32, 0, 32, 32, 128, 32)
	end
	
	local spriteLayer = map.layers["Sprite Layer"]
	spriteLayer.sprites = {
	 player = {
	 image = love.graphics.newImage("mychar.png"),x = 50, y = 250, r = 0,
	 }
	}
	
	function spriteLayer:update(dt)
		if start then
			timer = timer + 1
			if timer > 10 then
				iteration = iteration + 1
				timer = 0 
			end
			if iteration > 4 then
				iteration = 1
			end
			for _, sprite in pairs(self.sprites) do
				
				if jump and not dead then
					yVelocity = 420
					jump = false
				end

				x,y,d,i,o = getGroundBelowCharacter(sprite.x+(playerWidth/2), sprite.y+playerHeight-20)
				--check Y collision bottom
				if sprite.y + playerHeight > (i - 1) * tileHeight  then 
					sprite.y = (i - 1) * tileHeight - playerHeight
					yVelocity = 0
					xVelocity = 0
					dead = true
				end    
				
				--check Y collision top + score
				if x > 3 and x % 2 == 0 and x < 23 then
					if y * tileHeight == (i-3)*tileHeight then
						sprite.y = (i - 3) *tileHeight - playerHeight
						xVelocity = 0
						yVelocity = 0
						dead = true
					end
					if not dead and not scored then
						score = score + math.ceil(dt*1)
						scored = true
					else
						scored = false
					end
				end	
				--check X collision
				if sprite.x + playerWidth > (o - 1) * tileWidth then
					sprite.x = (o - 1) * tileWidth - playerWidth
					yVelocity = 0
					xVelocity = 0
					dead = true
				end
				
				sprite.y = sprite.y - dt*yVelocity
				yVelocity = yVelocity - 20
				sprite.x = sprite.x + dt*xVelocity
				--rewind level
				if x >= 21 then
				 x = 3
				 sprite.x = 3
				 tx = 0
				end
			end
		end
	end
	
	function spriteLayer:draw()
		for _, sprite in pairs(self.sprites) do
			local x = math.floor(sprite.x)
			local y = math.floor(sprite.y)
			local r = sprite.r
			love.graphics.draw(sprite.image, quads[iteration], x, y, r)
			isDead(dead)
		 end
	end
		
		
	data = {
		{0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0},
		{0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0},
		{0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0},
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0},
		{0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0},
		{0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0},
		{0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0},
		{0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0},
		{0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0},
		{0, 0, 0, 9, 6, 7, 8, 9, 6, 7, 8, 9, 6, 7, 8, 9, 6, 7, 8, 9, 6, 7, 8, 9, 7}
		}
		
end

function getGroundBelowCharacter(x,y)	

    local xCoordInTiles = math.floor(x/tileWidth) + 1
    local yCoordInTiles = math.ceil(y/tileWidth)
	
	if yCoordInTiles < 1 then yCoordInTiles = 1 end
	if xCoordInTiles < 1 then xCoordInTiles = 1 end
	
	local i, k

	if yCoordInTiles == mapHeight then
		i = yCoordInTiles
	else
		i = yCoordInTiles + 1
	end
	
	if xCoordInTiles == mapWidth then
		k = xCoordInTiles
	else
		k = xCoordInTiles + 1
	end
	
    while data[i][xCoordInTiles] == 0 and i < mapHeight do
        i = i + 1
    end
    
    while data[yCoordInTiles][k] == 0 and k < mapWidth do
        k = k + 1
    end
    
    return xCoordInTiles, yCoordInTiles, data[yCoordInTiles][xCoordInTiles], i, k
end

	
function love.update(dt) 

	if start and not dead then
		world:update(dt);
		map:update(dt)
		if tx + windowWidth < tileWidth*mapWidth then
			tx = tx + 50 * dt
		end
	end
end


function love.draw()
	
	-- Draw map
		love.graphics.setColor(255, 255, 255)
		map:draw(-tx, 0)
		
		-- Draw physics objects
		love.graphics.setColor(255, 0, 255)
		map:box2d_draw(-tx, 0)
		love.graphics.setColor(148,0,211,255)
		love.graphics.print("Highscore: " .. highscore, 0, 0)
		love.graphics.setColor(255,255,255,255)
		love.graphics.print("Score: " .. score, 0, 20)
		
		if not start then
			love.graphics.setColor(255,255,255,64)
			love.graphics.rectangle("fill",0,0,windowWidth, windowHeight)
			love.graphics.setColor(255,0,0,255)
			love.graphics.print("Press S to start!", 50, 200, 0, 2, 2)
		end
end

function love.keyreleased(key)
   if key == "q" then
      love.event.quit()
   
   end
end

love.keyboard.setKeyRepeat(false)

function love.keypressed(key) 
	if key == "w" and not jump then
		jump = true
	end
	if key == "s" then
		start = true
	end
	if key == "r" then
		restart = true
		love.load()
	end
end

function love.mousereleased(x, y, button)
	if button == 1 and not jump then
		jump = true
	end
end

function isDead(dead)

   if dead then 
		timedead = timedead + 1
		if timedead == 1 then
			crash:play()
			save()
		end
		middleX = windowWidth/4
		middleY = windowHeight/4
        love.graphics.setColor(255,0,0,128)
        love.graphics.rectangle("fill", middleX + tx, middleY, windowWidth/2, windowHeight/2)
        love.graphics.setColor(255,255,255,255)
        love.graphics.print("Game Over :(", windowWidth/6 + tx + middleX, middleY)
        love.graphics.print("SCORE: " .. score, windowWidth/6 + tx + middleX + 20, middleY + 150)
	end
end
function loadf()
	if love.filesystem.exists("save.txt") then
		local s = love.filesystem.read("save.txt")
		highscore = s
	else
		highscore = 0
	end
end

function save()
	if score > tonumber(highscore) then
		love.filesystem.write("save.txt", score)
	end
end

