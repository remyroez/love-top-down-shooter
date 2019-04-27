
local class = require 'middleclass'
local stateful = require 'stateful'

-- 現在のステートを返す
local function _getCurrentState(self)
    return self.__stateStack[#self.__stateStack]
end

-- ステート名を返す
local function _getStateName(self, target)
    for name, state in pairs(self.class.static.states) do
        if state == target then return name end
    end
end

-- 現在のステート名を返す
local function _getCurrentStateName(self)
    return _getStateName(self, _getCurrentState(self))
end

-- シーン
local Scene = class 'Scene'
Scene:include(stateful)

-- 初期化
function Scene:initialize()
    self.stateObjects = {}
end

-- 読み込み
function Scene:load()
end

-- 更新
function Scene:update(dt)
end

-- 描画
function Scene:draw()
end

-- ステートの描画
function Scene:printStates()
    love.graphics.print('states: ' .. table.concat(self:getStateStackDebugInfo(), '/'))
end

-- ステート用テーブル
function Scene:getState(name)
    local isCurrent = name == nil
    local name = name or _getCurrentStateName(self)

    -- 現在のステート用テーブルが無ければ準備, load を呼ぶ
    if self.stateObjects[name] == nil then
        self.stateObjects[name] = {}
        if isCurrent then
            self.state = self.stateObjects[name]
        end
        self:load()
    else
        if isCurrent then
            self.state = self.stateObjects[name]
        end
    end

    return self.stateObjects[name]
end

-- ステート開始
function Scene:enteredState(...)
    -- 現在のステート用テーブルを準備
    self:getState()
end

-- ステート終了
function Scene:exitedState(...)
end

-- ステートプッシュ
function Scene:pushedState(...)
end

-- ステートポップ
function Scene:poppedState(...)
end

-- ステート停止
function Scene:pausedState(...)
end

-- ステート再開
function Scene:continuedState(...)
end

-- 次のステートへ
function Scene:nextState(...)
end

-- キー入力
function Scene:keypressed(key, scancode, isrepeat)
end

-- マウス入力
function Scene:mousepressed(x, y, button, istouch, presses)
end

return Scene
