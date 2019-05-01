
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

    -- 視界内の相手を探す
    self.timer:every(
        0.1,
        function ()
            -- キャラクターを探す
            local target = self.character:findCharacter(64, 64, { 'player', 'friend' })
            if target == nil then
                target = self.character:findCharacter(128, 96, { 'player', 'friend' })
            end

            -- ターゲットを定めたら攻撃へ
            if target then
                self:gotoState('attack', target)
            end
        end
    )
end

-- 描画
function Wait:draw()
    ZombieBehavior.draw(self)
    do
        local x, y = self.character:forward(64)
        love.graphics.circle('line', x + self.character.x, y + self.character.y, 64)
    end
    do
        local x, y = self.character:forward(128)
        love.graphics.circle('line', x + self.character.x, y + self.character.y, 96)
    end
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
            -- キャラクターを探す
            local target = self.character:findCharacter(64, 64, { 'player', 'friend' })
            if target == nil then
                target = self.character:findCharacter(128, 96, { 'player', 'friend' })
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
    do
        local x, y = self.character:forward(64)
        love.graphics.circle('line', x + self.character.x, y + self.character.y, 64)
    end
    do
        local x, y = self.character:forward(128)
        love.graphics.circle('line', x + self.character.x, y + self.character.y, 96)
    end
end

-- 攻撃
local Attack = ZombieBehavior:newState 'attack'

-- 攻撃: ステート開始
function Attack:enteredState(target)
    self._attack = {}
    self._attack.target = target
    self._attack.wait = false

    -- キャラクターは追跡状態に
    self:setCharacterState('goto', self.character.speed * 1.5, self._attack.target)

    -- 視界内の相手を探す
    self.timer:every(
        0.1,
        function ()
            -- 手前の円の範囲にいるコライダーを探す
            local isFound =
                self.character:watchCharacter(self._attack.target, 64, 64, { 'player', 'friend' })
                or self.character:watchCharacter(self._attack.target, 128, 96, { 'player', 'friend' })

            -- 見つからなかったらサーチに戻る
            if not isFound then
                self:gotoState('search')
            elseif not self._attack.wait and self.character:watchCharacter(self._attack.target, 32, 32, { 'player', 'friend' }) then
                self._attack.target:damage(
                    self.character:getWeaponDamage(),
                    self.character.rotation,
                    self.character:getWeaponPower()
                )
                self._attack.wait = true
                self.timer:after(self.character:getWeaponDelay(), function () self._attack.wait = false end)
            end
        end
    )
end

-- 描画
function Attack:draw()
    ZombieBehavior.draw(self)
    if not self._attack.wait then
        local x, y = self.character:forward(32)
        love.graphics.circle('line', x + self.character.x, y + self.character.y, 32)
    end
    do
        local x, y = self.character:forward(64)
        love.graphics.circle('line', x + self.character.x, y + self.character.y, 64)
    end
    do
        local x, y = self.character:forward(128)
        love.graphics.circle('line', x + self.character.x, y + self.character.y, 96)
    end
end

return ZombieBehavior
