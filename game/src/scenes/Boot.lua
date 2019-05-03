
local Scene = require 'Scene'

-- エイリアス
local lg = love.graphics
local la = love.audio

-- ブート
local Boot = Scene:newState 'boot'

-- 次のステートへ
function Boot:nextState(...)
    self:gotoState 'splash'
end

-- 読み込み
function Boot:load()
    -- 画面のサイズ
    local width, height = lg.getDimensions()
    self.width = width
    self.height = height

    -- スプライトシートの読み込み
    self.spriteSheet = sbss:new('assets/spritesheet.xml')

    -- 照準
    self.crosshair = lg.newImage('assets/crosshair038.png')

    local font = 'assets/Kenney Thick.ttf'
    self.font16 = love.graphics.newFont(font, 16)
    self.font32 = love.graphics.newFont(font, 32)
    self.font64 = love.graphics.newFont(font, 64)
end

-- 更新
function Boot:update()
    self:nextState()
end

return Boot
