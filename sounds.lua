sounds = {}

function sounds:load()
	self.titleSong = love.audio.newSource("sounds/title.wav", "stream")
	self.titleSong:setLooping(true)

	self.titleSong:play()
end

function sounds:update(dt) end

function sounds:draw() end
