
-- クラス
local Scene = require 'Scene'
local Character = require 'Character'

-- ゲーム
local Game = Scene:newState 'game'

-- 読み込み
function Game:load()
    self.state.character = Character{
        spriteSheet = self.spriteSheet,
        spriteName = 'hitman1_gun.png',
        x = self.width * 0.5,
        y = self.height * 0.5,
        h_align = 'center'
    }
end

-- ステート開始
function Game:enteredState(...)
    -- 親
    Scene.enteredState(self, ...)
end

-- ステート終了
function Game:exitedState(...)
end

-- 更新
function Game:update(dt)
    self.state.character:setRotationTo(love.mouse.getPosition())
    self.state.character:update(dt)
end

-- 描画
function Game:draw()
    self.state.character:draw()
    self.state.character:drawRectangle()
end

-- キー入力
function Game:keypressed(key, scancode, isrepeat)
end

-- マウス入力
function Game:mousepressed(x, y, button, istouch, presses)
end

return Game
