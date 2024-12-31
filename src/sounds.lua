Sounds = {}

function Sounds:load(soundFile)
	-- Stop current song
	self:unload()

	self.currentSong = love.audio.newSource(soundFile, "stream")
	self.currentSong:setVolume(0.5)
	self.currentSong:setLooping(true)

	self.currentSong:play()
end

function Sounds:unload()
	if self.currentSong then
		self.currentSong:stop()
	end
end

function Sounds:update(dt) end

function Sounds:draw() end
