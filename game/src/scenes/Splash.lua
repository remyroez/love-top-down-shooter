
local Scene = require 'Scene'

-- クラス
local o_ten_one = require 'o-ten-one'

-- エイリアス
local lg = love.graphics

-- スプラッシュスクリーン
local Splash = Scene:newState 'splash'

-- 次のステートへ
function Splash:nextState(...)
    self:gotoState 'title'
end

-- 読み込み
function Splash:load()
    self.state.splash = o_ten_one{ base_folder = 'lib', background = { 0, 0, 0 } }
    self.state.splash.onDone = function ()
        self:nextState()
    end
end

-- 更新
function Splash:update(dt)
    self.state.splash:update(dt)
end

-- 描画
function Splash:draw()
    self.state.splash:draw()
end

-- キー入力
function Splash:keypressed(key, scancode, isrepeat)
    self.state.splash:skip()
end

-- マウス入力
function Splash:mousepressed(x, y, button, istouch, presses)
    self.state.splash:skip()
end

return Splash
