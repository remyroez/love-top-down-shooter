
local Scene = require 'Scene'

-- エイリアス
local lg = love.graphics
local la = love.audio

-- ブート
local Boot = Scene:newState 'boot'

-- 次のステートへ
function Boot:nextState(...)
    self:gotoState 'game'
end

-- 読み込み
function Boot:load()
    -- 画面のサイズ
    local width, height = lg.getDimensions()
    self.width = width
    self.height = height

    -- スプライトシートの読み込み
    self.spriteSheet = sbss:new('assets/spritesheet.xml')
end

-- 更新
function Boot:update()
    self:nextState()
end

return Boot
