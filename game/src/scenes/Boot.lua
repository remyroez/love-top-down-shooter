
local Scene = require 'Scene'

-- エイリアス
local lg = love.graphics
local la = love.audio

-- ブート
local Boot = Scene:addState('boot', Scene)

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
end

-- 更新
function Boot:update()
    self:nextState()
end

return Boot