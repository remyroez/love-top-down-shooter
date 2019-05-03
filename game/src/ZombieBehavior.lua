
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

-- ダメージ時のコールバック
function ZombieBehavior:onDamage(attacker)
    self:gotoState('attack', attacker)
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
            local scale = self.character.scale

            -- キャラクターを探す
            local target = self.character:findCharacter(64 * scale, 64 * scale, { 'player', 'friend' })
            if target == nil then
                target = self.character:findCharacter(128 * scale, 96 * scale, { 'player', 'friend' })
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

    local scale = self.character.scale
    do
        local x, y = self.character:forward(64 * scale)
        love.graphics.circle('line', x + self.character.x, y + self.character.y, 64 * scale)
    end
    do
        local x, y = self.character:forward(128 * scale)
        love.graphics.circle('line', x + self.character.x, y + self.character.y, 96 * scale)
    end
end

-- 検索
local Search = ZombieBehavior:newState 'search'

-- 検索: 周囲を探す
function Search:tweenSearch(rotate)
    local this = self

    self.timer:tween(
        3,
        self.character,
        { rotation = self.character.rotation + rotate },
        'in-out-cubic',
        function ()
            if this == nil then
                self.timer:destroy()
                return
            end
            this:tweenSearch(math.pi / 2 * love.math.random(-1, 1))
        end,
        'search'
    )
end

-- 検索: キャラクターのナビゲート
function Search:navigateCharacter(random)
    local navi

    if random then
        navi = self.character:findRandomNavigation()
    else
        navi = self.character:findNearestNavigation(love.math.random(1, 2) == 1)
    end

    if navi then
        self:gotoState('goto', navi.x, navi.y)
    end
end

-- 検索: ステート開始
function Search:enteredState(rotate)
    rotate = rotate or (math.pi / 2)

    local this = self

    -- キャラクターは立ち状態に
    self:setCharacterState('stand')

    -- 一定間隔で左右を見る
    self:tweenSearch(rotate)

    -- 視界内の相手を探す
    self.timer:every(
        0.1,
        function ()
            if this == nil then
                self.timer:destroy()
                return
            end
            local scale = this.character.scale

            -- キャラクターを探す
            local target = this.character:findCharacter(64 * scale, 64 * scale, { 'player', 'friend' })
            if target == nil then
                target = this.character:findCharacter(128 * scale, 96 * scale, { 'player', 'friend' })
            end

            -- ターゲットを定めたら攻撃へ
            if target then
                this:gotoState('attack', target)
            end
        end
    )

    -- 定期的にナビゲーション先を探す
    self.timer:every(
        5,
        function ()
            if this == nil then
                self.timer:destroy()
                return
            end
            this:navigateCharacter()
        end
    )

    -- 定期的にナビゲーションをリセット
    self.timer:every(
        60,
        function ()
            if this == nil then
                self.timer:destroy()
                return
            end
            this.character:resetNavigation()
        end
    )

    -- 最初に一回ナビゲートする
    if self.first then
        self:navigateCharacter(true)
    end
end

-- 描画
function Search:draw()
    ZombieBehavior.draw(self)

    local scale = self.character.scale
    do
        local x, y = self.character:forward(64 * scale)
        love.graphics.circle('line', x + self.character.x, y + self.character.y, 64 * scale)
    end
    do
        local x, y = self.character:forward(128 * scale)
        love.graphics.circle('line', x + self.character.x, y + self.character.y, 96 * scale)
    end
end

-- 攻撃
local Attack = ZombieBehavior:newState 'attack'

-- 攻撃: ステート開始
function Attack:enteredState(target)
    self.target = target

    self._attack = {}
    self._attack.targetX, self._attack.targetY = self.target:getPosition()
    self._attack.wait = false
    self._attack.lastX, self._attack.lastY = self.character.x, self.character.y
    self._attack.nomove = 0

    -- キャラクターは追跡状態に
    self:setCharacterState('goto', self.character.speed * 1.5, self.target)

    -- ナビゲーションのリセット
    self.character:resetNavigation()

    -- 視界内の相手を探す
    self.timer:every(
        0.1,
        function ()
            local scale = self.character.scale

            -- 手前の円の範囲にいるコライダーを探す
            local isFound =
                self.character:watchCharacter(self.target, 64 * scale, 64 * scale, { 'player', 'friend' })
                or self.character:watchCharacter(self.target, 128 * scale, 96 * scale, { 'player', 'friend' })

            -- ターゲット座標の更新
            if isFound then
                self._attack.targetX, self._attack.targetY = self.target:getPosition()
            end

            -- 見つからなかったらサーチに戻る
            if not isFound then
                self:gotoState('goto', self._attack.targetX, self._attack.targetY)
            elseif not self._attack.wait and self.character:watchCharacter(self.target, 16 * scale, 16 * scale, { 'player', 'friend' }, false) then
                -- 手元に居たら攻撃
                self.target:damage(
                    self.character:getWeaponDamage(),
                    self.character.rotation,
                    self.character:getWeaponPower(),
                    self.character
                )
                self._attack.wait = true
                self.timer:after(self.character:getWeaponDelay(), function () self._attack.wait = false end)
                self._attack.nomove = 0
            else
                -- 移動していなかったらカウントアップ
                if math.abs(self.character.x - self._attack.lastX) < 4 and math.abs(self.character.y - self._attack.lastY) < 4 then
                    self._attack.nomove = self._attack.nomove + love.timer.getDelta() / 0.1
                else
                    self._attack.nomove = 0
                end

                -- 一定時間移動しなかったら検索へ
                if self._attack.nomove > 3 then
                    self:gotoState('search')
                end
            end

            -- 現在のキャラの座標を記憶
            self._attack.lastX, self._attack.lastY = self.character.x, self.character.y
        end
    )
end

-- 描画
function Attack:draw()
    ZombieBehavior.draw(self)

    local scale = self.character.scale
    if not self._attack.wait then
        local x, y = self.character:forward(16 * scale)
        love.graphics.circle('line', x + self.character.x, y + self.character.y, 16 * scale)
    end
    do
        local x, y = self.character:forward(64 * scale)
        love.graphics.circle('line', x + self.character.x, y + self.character.y, 64 * scale)
    end
    do
        local x, y = self.character:forward(128 * scale)
        love.graphics.circle('line', x + self.character.x, y + self.character.y, 96 * scale)
    end
end

-- 移動
local Goto = ZombieBehavior:newState 'goto'

-- 移動: ステート開始
function Goto:enteredState(x, y)
    self._goto = {}
    self._goto.x, self._goto.y = x or 0, y or 0
    self._goto.lastX, self._goto.lastY = self.character.x, self.character.y
    self._goto.nomove = 0

    -- キャラクターは追跡状態に
    self:setCharacterState('goto', self.character.speed, x, y)

    -- 視界内の相手を探す
    self.timer:every(
        0.1,
        function ()
            local scale = self.character.scale

            -- キャラクターを探す
            local target = self.character:findCharacter(64 * scale, 64 * scale, { 'player', 'friend' })
            if target == nil then
                target = self.character:findCharacter(128 * scale, 96 * scale, { 'player', 'friend' })
            end

            -- ターゲットを定めたら攻撃へ
            if target then
                self:gotoState('attack', target)
            end

            -- 終了判定
            if lume.distance(self.character.x, self.character.y, self._goto.x, self._goto.y) < 10 * scale then
                -- 到着したら捜索へ
                self:gotoState('search')
            elseif not self.character:watchPoint(self._goto.x, self._goto.y) then
                -- 地点が見えなかったら捜索へ
                self:gotoState('search')
            end

            -- 移動していなかったらカウントアップ
            if math.abs(self.character.x - self._goto.lastX) < 4 and math.abs(self.character.y - self._goto.lastY) < 4 then
                self._goto.nomove = self._goto.nomove + love.timer.getDelta() / 0.1
            else
                self._goto.nomove = 0
            end

            -- 一定時間移動しなかったら検索へ
            if self._goto.nomove > 3 then
                self:gotoState('search')
            end

            -- 現在のキャラの座標を記憶
            self._goto.lastX, self._goto.lastY = self.character.x, self.character.y
        end
    )
end

-- 移動: 描画
function Goto:draw()
    ZombieBehavior.draw(self)

    local scale = self.character.scale
    do
        local x, y = self.character:forward(64 * scale)
        love.graphics.circle('line', x + self.character.x, y + self.character.y, 64 * scale)
    end
    do
        local x, y = self.character:forward(128 * scale)
        love.graphics.circle('line', x + self.character.x, y + self.character.y, 96 * scale)
    end
end

return ZombieBehavior
