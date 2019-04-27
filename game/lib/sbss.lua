sbss = {}

function sbss:new(fileName)
	local o = {}

	setmetatable(o, self)
	self.__index = self

	init(self, fileName)

	return o
end

function sbss:draw(imageName, x, y) 
	if self.quad[imageName] ~= nil then
		love.graphics.draw(self.spriteSheet, self.quad[imageName], x, y)
	else
		error("Error: " .. imageName .. " does not exist in " .. self.fileName .. ".")
	end
end

function init(self, fileName)
	self.quad = {}
	self.fileName = fileName

	parse(self, fileName)
end

function parse(self, fileName)
	local contents = love.filesystem.read(fileName)
	local filePath = string.match(fileName, "^.*%/") or ""

	for s in contents:gmatch("[^\r\n]+") do
		if s:find("<TextureAtlas") ~= nil then
			local fileName = getAttributeData(s, "imagePath")

			--if love.filesystem.exists(filePath .. fileName) then
			if  love.filesystem.getInfo(filePath .. fileName) ~= nil then
				self.spriteSheet = love.graphics.newImage(filePath .. fileName)
			else
				error("Error: " .. filePath .. fileName .. " does not exist.")
			end

		elseif s:find("<SubTexture") ~= nil then
			local name, x, y, width, height = getTextureData(s)
			self.quad[name] = love.graphics.newQuad(x, y, width, height, self.spriteSheet:getDimensions())
		end
	end
end

function getAttributeData(s, key)
	local searchKey = key .. "="

	if s:find(searchKey) == nil then
		return nil
	end

	local s1, e1 = s:find(searchKey)
	local s2, e2 = s:find("\"", e1 + 2)

	return s:sub(e1 + 2, s2 - 1)
end

function getTextureData(s)
	return  getAttributeData(s, "name"),
			getAttributeData(s, "x"),
			getAttributeData(s, "y"),
			getAttributeData(s, "width"),
			getAttributeData(s, "height")
end
