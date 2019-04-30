
local class = require 'middleclass'
local lume = require 'lume'

-- ビヘイビア
local Behavior = require 'Behavior'

-- ゾンビ・ビヘイビア
local ZombieBehavior = class('ZombieBehavior', Behavior)

-- 初期化
function ZombieBehavior:initialize(character, baseState)
    Behavior.initialize(self, character, baseState or 'search')
    self:gotoBaseState()
end

-- 更新
function ZombieBehavior:update(dt)
    Behavior.update(self, dt)
end

-- 新規ステート
function ZombieBehavior:newState(name)
    return ZombieBehavior:addState(name, ZombieBehavior)
end

-- 待機
local Wait = ZombieBehavior:newState 'wait'

-- 待機: ステート開始
function Wait:enteredState(duration, nextState, ...)
    local args = {...}

    -- 一定時間後に次のステートへ
    self.timer:after(
        duration,
        function()
            self:gotoState(nextState, unpack(args))
        end
    )
end

-- 検索
local Search = ZombieBehavior:newState 'search'

-- 検索: ステート開始
function Search:enteredState(rotate)
    rotate = rotate or (math.pi / 2)

    -- 一定間隔で左右を見る
    self.timer:tween(
        1,
        self.character,
        { rotation = self.character.rotation + rotate },
        'in-out-cubic',
        function ()
            self:gotoState('wait', 1, 'search', -rotate)
        end
    )
end

return ZombieBehavior
