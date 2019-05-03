
local Scene = require 'Scene'
local Timer = require 'Timer'

-- エイリアス
local lg = love.graphics

-- タイトル
local Title = Scene:newState 'title'

-- 次のステートへ
function Title:nextState(...)
    self:gotoState 'select'
end

-- 読み込み
function Title:load()
end

-- ステート開始
function Title:enteredState(...)
    -- 親
    Scene.enteredState(self, ...)

    self.state.action = true
    self.state.visiblePressAnyKey = true

    self.state.fade = { 0, 0, 0, 1 }

    self.state.timer = Timer()
    self.state.timer:tween(
        1,
        self.state.fade,
        { [4] = 0 },
        'in-out-cubic',
        function ()
            self.state.timer:every(
                0.5,
                function ()
                    self.state.visiblePressAnyKey = not self.state.visiblePressAnyKey
                end
            )
            self.state.action = false
        end
    )

    -- ＢＧＭ
    self.musics.outgame:play()
end

-- ステート終了
function Title:exitedState(...)
    self.state.timer:destroy()
end

-- 更新
function Title:update(dt)
    self.state.timer:update(dt)
end

-- 描画
function Title:draw()
    -- タイトル
    lg.setColor(1, 1, 1)
    lg.printf('TOP\nDOWN\nSHOOTER', self.font64, 16, self.height - self.font64:getHeight() * 3, self.width, 'left')

    -- キー入力表示
    if self.state.visiblePressAnyKey and not self.state.action then
        lg.printf('PRESS ANY KEY', self.font32, -8, 8, self.width, 'right')
    end

    -- フェード
    if self.state.fade[4] > 0 then
        lg.setColor(unpack(self.state.fade))
        lg.rectangle('fill', 0, 0, self.width, self.height)
    end
end

-- キー入力
function Title:keypressed(key, scancode, isrepeat)
    if not self.state.action then
        self.state.action = true
        self.state.timer:tween(
            1,
            self.state.fade,
            { [4] = 1 },
            'in-out-cubic',
            function ()
                self:nextState()
                self.state.action = false
            end
        )

        -- ＳＥ
        self.sounds.start:seek(0)
        self.sounds.start:play()
    end
end

-- マウス入力
function Title:mousepressed(x, y, button, istouch, presses)
    self:keypressed('space')
end

return Title
