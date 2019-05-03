
local Scene = require 'Scene'
local Timer = require 'Timer'

-- エイリアス
local lg = love.graphics

-- レベルセレクト
local Select = Scene:newState 'select'

-- レベルリスト
local levels = {
    { title = 'HITMAN VS. ZOMBIES', description = 'ENDLESS', path = 'assets/levels/simple.lua' }
}

-- 次のステートへ
function Select:nextState(...)
    self:gotoState('game', ...)
end

-- 読み込み
function Select:load()
end

-- ステート開始
function Select:enteredState(...)
    -- 親
    Scene.enteredState(self, ...)

    self.state.action = true
    self.state.visiblePressAnyKey = true
    self.state.offset = 0

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
function Select:exitedState(...)
    self.state.timer:destroy()
end

-- 更新
function Select:update(dt)
    self.state.timer:update(dt)
end

-- 描画
function Select:draw()
    -- レベル選択
    lg.setColor(1, 1, 1)
    lg.printf('SELECT LEVEL', self.font16, 0, self.height * 0.25 - self.font16:getHeight(), self.width, 'center')

    -- レベル名
    do
        local level = levels[self.selectedLevel]
        lg.printf(self.selectedLevel .. '. ' .. level.title, self.font32, self.state.offset, self.height * 0.5 - self.font32:getHeight(), self.width, 'center')
        lg.printf(level.description, self.font16, self.state.offset, self.height * 0.5 + self.font16:getHeight(), self.width, 'center')
    end

    -- クリアウェーブ
    if self.clearWave[self.selectedLevel] then
        local h = self.height * 0.75
        lg.printf('BEST WAVE', self.font16, self.state.offset, h - self.font16:getHeight(), self.width, 'center')
        lg.printf(self.clearWave[self.selectedLevel], self.font32, self.state.offset, h, self.width, 'center')
    end

    -- フェード
    if self.state.fade[4] > 0 then
        lg.setColor(unpack(self.state.fade))
        lg.rectangle('fill', 0, 0, self.width, self.height)
    end
end

-- キー入力
function Select:keypressed(key, scancode, isrepeat)
    if not self.state.action then
        if key == 'return' or key == 'space' then
            self.state.action = true
            self.state.timer:tween(
                1,
                self.state.fade,
                { [4] = 1 },
                'in-out-cubic',
                function ()
                    self.musics.outgame:stop()
                    self:nextState(levels[self.selectedLevel].path)
                    self.state.action = false
                end
            )

            -- ＳＥ
            self.sounds.start:seek(0)
            self.sounds.start:play()

        elseif key == 'left' or key == 'a' then
            -- 前のレベル
            self.selectedLevel = self.selectedLevel - 1
            if self.selectedLevel < 1 then
                self.selectedLevel = #levels
            end

            self.state.offset = 64
            self.state.timer:tween(
                0.2,
                self.state,
                { offset = 0 },
                'out-elastic',
                'select'
            )

            -- ＳＥ
            self.sounds.select:seek(0)
            self.sounds.select:play()

        elseif key == 'right' or key == 'd' then
            -- 次のレベル
            self.selectedLevel = self.selectedLevel + 1
            if self.selectedLevel > #levels then
                self.selectedLevel = 1
            end

            self.state.offset = -64
            self.state.timer:tween(
                0.2,
                self.state,
                { offset = 0 },
                'out-elastic',
                'select'
            )

            -- ＳＥ
            self.sounds.select:seek(0)
            self.sounds.select:play()
        end
    end
end

-- マウス入力
function Select:mousepressed(x, y, button, istouch, presses)
    self:keypressed('return')
end

return Select
