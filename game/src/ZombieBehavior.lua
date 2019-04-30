
local class = require 'middleclass'
local lume = require 'lume'

-- ビヘイビア
local Behavior = require 'Behavior'

-- ゾンビ・ビヘイビア
local ZombieBehavior = class('ZombieBehavior', Behavior)

-- 初期化
function ZombieBehavior:initialize(character, baseState)
    Behavior.initialize(self, character, baseState or 'search')
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

    -- キャラクターは立ち状態に
    self:setCharacterState('stand')

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

    -- キャラクターは立ち状態に
    self:setCharacterState('stand')

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

    -- 視界内の相手を探す
    self.timer:every(
        0.1,
        function ()
            -- 手前の円の範囲にいるコライダーを探す
            local x, y = self.character:forward(64)
            local colliders = self.character.world:queryCircleArea(x + self.character.x, y + self.character.y, 64, { 'player', 'friend' })
            local target = nil
            for _, collider in pairs(colliders) do
                -- 視線の邪魔が無ければターゲットにする
                local isFound = true
                local cx, cy = collider:getPosition()
                local founds = self.character.world:queryLine(cx, cy, self.character.x, self.character.y, { 'All', except = { 'enemy' } })
                for __, found in pairs(founds) do
                    if found ~= collider then
                        isFound = false
                        break
                    end
                end

                -- ターゲットを定めた
                if isFound then
                    target = collider:getObject()
                    break
                end
            end

            -- ターゲットを定めたら攻撃へ
            if target then
                self:gotoState('attack', target)
            end
        end
    )
end

-- 描画
function Search:draw()
    ZombieBehavior.draw(self)
    local x, y = self.character:forward(64)
    love.graphics.circle('line', x + self.character.x, y + self.character.y, 64)
end

-- 攻撃
local Attack = ZombieBehavior:newState 'attack'

-- 攻撃: ステート開始
function Attack:enteredState(target)
    self._attack = {}
    self._attack.target = target

    -- キャラクターは追跡状態に
    self:setCharacterState('goto', self._attack.target.speed * 1.5, self._attack.target)

    -- 視界内の相手を探す
    self.timer:every(
        0.1,
        function ()
            -- 手前の円の範囲にいるコライダーを探す
            local x, y = self.character:forward(64)
            local colliders = self.character.world:queryCircleArea(x + self.character.x, y + self.character.y, 64, { 'player', 'friend' })
            local isFound = false
            for _, collider in pairs(colliders) do
                if collider:getObject() == self._attack.target then
                    -- ターゲットが居た
                    isFound = true
                    local cx, cy = collider:getPosition()
                    local founds = self.character.world:queryLine(cx, cy, self.character.x, self.character.y, { 'All', except = { 'enemy' } })
                    for __, found in pairs(founds) do
                        -- 視界に別のコライダーが邪魔した
                        if found ~= collider then
                            isFound = false
                            break
                        end
                    end
                    break
                end
            end

            -- 見つからなかったらサーチに戻る
            if not isFound then
                self:gotoState('search')
            end
        end
    )
end

-- 描画
function Attack:draw()
    ZombieBehavior.draw(self)
    local x, y = self.character:forward(64)
    love.graphics.circle('line', x + self.character.x, y + self.character.y, 64)
end

return ZombieBehavior
