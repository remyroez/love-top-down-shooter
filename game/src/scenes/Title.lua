
local Scene = require 'Scene'

-- タイトル
local Title = Scene:newState 'title'

-- 次のステートへ
function Title:nextState(...)
    self:gotoState 'game'
end

-- 読み込み
function Title:load()
end

-- ステート開始
function Title:enteredState(...)
    -- 親
    Scene.enteredState(self, ...)
end

-- ステート終了
function Title:exitedState(...)
end

-- 更新
function Title:update(dt)
end

-- 描画
function Title:draw()
end

-- キー入力
function Title:keypressed(key, scancode, isrepeat)
    self:nextState()
end

-- マウス入力
function Title:mousepressed(x, y, button, istouch, presses)
    self:nextState()
end

return Title
