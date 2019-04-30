
local class = require 'middleclass'

-- クラス
local Timer = require 'Timer'

-- ビヘイビア
local Behavior = class 'Behavior'
Behavior:include(require 'stateful')

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


-- 初期化
function Behavior:initialize(character, baseState)
    self.character = character
    self.baseState = baseState
    self.timer = Timer()
    self:gotoBaseState()
end

-- 破棄
function Behavior:destroy()
    self.timer:destroy()
end

-- 更新
function Behavior:update(dt)
    self.timer:update(dt)
end

-- 描画
function Behavior:draw()
    love.graphics.print(_getCurrentStateName(self), self.character.x, self.character.y)
end

-- ステート開始
function Behavior:enteredState(...)
end

-- ステート終了
function Behavior:exitedState(...)
    self.timer:destroy()
end

-- ベースステートへ
function Behavior:gotoBaseState()
    if self.baseState then
        self:gotoState(self.baseState)
    end
end

-- キャラクターのステート設定
function Behavior:setCharacterState(...)
    self.character:gotoState(...)
end

return Behavior
