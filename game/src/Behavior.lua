
local class = require 'middleclass'

-- クラス
local Timer = require 'Timer'

-- ビヘイビア
local Behavior = class 'Behavior'
Behavior:include(require 'stateful')

-- 初期化
function Behavior:initialize(character, baseState)
    self.character = character
    self.baseState = baseState
    self.timer = Timer()
end

-- 破棄
function Behavior:destroy()
    self.timer:destroy()
end

-- 更新
function Behavior:update(dt)
    self.timer:update(dt)
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
