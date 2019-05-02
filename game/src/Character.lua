
local lume = require 'lume'
local class = require 'middleclass'
local Timer = require 'Timer'

-- キャラクター
local Character = class('Character', require 'Entity')
Character:include(require 'stateful')
Character:include(require 'Rectangle')
Character:include(require 'SpriteRenderer')
Character:include(require 'Transform')
Character:include(require 'Collider')
Character:include(require 'Weapon')

-- 初期化
function Character:initialize(args)
    args = args or {}

    self.timer = Timer()

    self.active = true
    self.alive = true
    self.onDead = args.onDead or function (character) end
    self.onDamage = args.onDamage or function (character, attacker) end

    self.type = args.type or 'object'
    self.speed = args.speed or 100
    self.anglarSpeed = args.anglarSpeed or 90
    self.world = args.world
    self.color = args.color or { lume.color('#ffffff') }
    self.life = args.life or 10
    self.lifeMax = self.life

    self.navigation = args.navigation or {}
    self.visitedNavi = {}

    -- スプライト
    if type(args.sprite) == 'table' then
        self.sprite = args.sprite[love.math.random(#args.sprite)]
    else
        self.sprite = args.sprite or 'zombie'
    end

    -- Weapon 初期化
    self:initializeWeapon(args.weapon)

    -- 初期設定
    self.spriteName = self:getCurrentSpriteName()

    -- SpriteRenderer 初期化
    self:initializeSpriteRenderer(args.spriteSheet)

    -- Rectangle 初期化
    local w, h = self:getSpriteSize(self.spriteName)
    self:initializeRectangle(args.x, args.y, w, h, args.h_align, args.v_align)

    -- Transform 初期化
    self:initializeTransform(self.x, self.y, args.rotation, args.scale)

    -- Collider 初期化
    self:initializeCollider(args.collider)

    -- Collider 初期設定
    self.collider:setMass(args.mass or 10)
    self.collider:setLinearDamping(args.linearDamping or 10)
    self.collider:setAngularDamping(args.angularDamping or 10)
    if args.collisionClass then
        self.collider:setCollisionClass(args.collisionClass)
    end

    -- ビヘイビア
    if args.behavior then
        self.behavior = args.behavior(self)
    end
end

-- 破棄
function Character:destroy()
    self:destroyCollider()
end

-- 更新
function Character:update(dt)
    -- タイマー
    self.timer:update(dt)

    if self.alive then
        -- ビヘイビア
        if self.behavior then
            self.behavior:update(dt)
        end
    end

    -- コライダの座標を適用する
    self:applyPositionFromCollider()
end

-- 描画
function Character:draw()
    -- スプライトの描画
    love.graphics.setColor(self.color)
    self:pushTransform(self:left(), self:top())
    self:drawSprite(self.spriteName, self:getSpriteOffset())
    self:popTransform()

    -- ビヘイビア
    if self.behavior and self.alive then
        self.behavior:draw()
    end
end

-- 動作可能かどうか
function Character:isActive()
    return self.active and self.alive
end

-- スプライトのリセット
function Character:resetSprite(spriteName, h_align, v_align)
    self.spriteName = spriteName
    local w, h = self:getSpriteSize(spriteName)
    self:initializeRectangle(self.x, self.y, w, h, h_align, v_align)
end

-- ポーズ名の取得
function Character:getPoseName()
    local poseName = 'stand'
    if self:hasWeapon() then
        poseName = self:getWeaponName()
    end
    return poseName
end

-- スプライトのオフセットの取得
function Character:getSpriteOffset()
    local x, y = 0, 0
    if self:hasWeapon() then
        x = x + 8
    end
    return x, y
end

-- 現在のスプライト名を返す
function Character:getCurrentSpriteName()
    return self.sprite .. '_' .. self:getPoseName() .. '.png'
end

-- ダメージを与える
function Character:damage(damage, rotation, power, attacker)
    if not self.alive then
        return
    end

    damage = damage or 0
    power = power or 100
    rotation = rotation or (self.rotation + math.pi)

    -- ダメージ
    self.life = self.life - damage

    -- 衝撃
    if power > 0 then
        self.collider:applyLinearImpulse(lume.vector(rotation, power))
    end

    -- ダメージコールバック
    self.onDamage(self)
    if self.behavior and self.alive then
        self.behavior:onDamage(attacker)
    end

    -- ０以下になったら死ぬ
    if self.life <= 0 then
        self:gotoState 'dying'
    else
        self:pushState('wait', power / 10000)
    end
end

-- キャラクターを探す
function Character:findCharacter(range, circle, targetClass)
    range = range or 64
    circle = circle or 64
    targetClass = targetClass or {}

    local target = nil

    local x, y = self:forward(range)
    local colliders = self.world:queryCircleArea(x + self.x, y + self.y, circle, targetClass)
    for _, collider in pairs(colliders) do
        -- 視線の邪魔が無ければターゲットにする
        local isFound = true
        local cx, cy = collider:getPosition()

        local founds = self.world:queryLine(cx, cy, self.x, self.y, { 'All', except = { self.type } })
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

    return target
end

-- ある地点を監視する
function Character:watchPoint(x, y)
    local isFound = true

    local founds = self.world:queryLine(x, y, self.x, self.y, { 'All', except = { self.type } })
    for __, found in pairs(founds) do
        if found:getType() ~= 'dynamic' then
            isFound = false
            break
        end
    end

    return isFound
end

-- キャラクターを監視する
function Character:watchCharacter(target, range, circle, targetClass, sight)
    range = range or 64
    circle = circle or 64
    targetClass = targetClass or {}
    sight = sight == nil and true or sight

    local isFound = false

    -- 視線チェック
    if sight and target and target.collider then
        isFound = true
        local collider = target.collider
        local cx, cy = collider:getPosition()
        local founds = self.world:queryLine(cx, cy, self.x, self.y, { 'All', except = { self.type } })
        for __, found in pairs(founds) do
            -- 視界に別のコライダーが邪魔した
            if found ~= collider and found:getType() ~= 'dynamic' then
                isFound = false
                break
            end
        end
    end

    -- 視界チェック
    if not isFound then
        local x, y = self:forward(range)
        local colliders = self.world:queryCircleArea(x + self.x, y + self.y, circle, targetClass)
        for _, collider in pairs(colliders) do
            if collider:getObject() == target then
                -- ターゲットが居た
                isFound = true
                local cx, cy = collider:getPosition()
                local founds = self.world:queryLine(cx, cy, self.x, self.y, { 'All', except = { self.type } })
                for __, found in pairs(founds) do
                    -- 視界に別のコライダーが邪魔した
                    if found ~= collider and found:getType() ~= 'dynamic' then
                        isFound = false
                        break
                    end
                end
                break
            end
        end
    end

    return isFound
end

-- 一番近いナビゲーションを探す
function Character:findNearestNavigation(reverse, reset)
    reverse = reverse or false
    local navi
    local navis = self:findNavigations(reset)
    if #navis > 0 then
        local sortnavis = lume.sort(
            navis,
            function (a, b)
                if reverse then
                    return (a.dist > b.dist)
                else
                    return (a.dist < b.dist)
                end
            end
        )
        navi = lume.first(sortnavis)
    end
    return navi
end

-- ランダムでナビゲーションを返す
function Character:findRandomNavigation(reset)
    local navi
    local navis = self:findNavigations(reset)
    if #navis > 0 then
        navi = navis[love.math.random(#navis)]
    end
    return navi
end

-- ナビゲーションを探す
function Character:findNavigations(reset)
    local navis = {}

    -- すでに全てのナビゲーションを訪問していたら、記憶をリセット
    if reset or #self.visitedNavi >= #self.navigation then
        self:resetNavigation()
    end

    -- 視線が通るナビゲーションをリストアップ
    for _, navi in ipairs(self.navigation) do
        if not lume.find(self.visitedNavi, navi) then
            local ok = true

            -- 障害物がないかチェック
            local founds = self.world:queryLine(navi.x, navi.y, self.x, self.y, { 'All', except = { self.type } })
            for __, found in pairs(founds) do
                if found:getType() ~= 'dynamic' then
                    ok = false
                    break
                end
            end

            -- 障害物がなかった
            if ok then
                table.insert(navis, { x = navi.x, y = navi.y, dist = lume.distance(self.x, self.y, navi.x, navi.y) })
            end
        end
    end

    return navis
end

-- ナビゲーションの訪問
function Character:visitNavigation(navi)
    table.insert(self.visitedNavi, navi)
end

-- 過去に訪問したナビゲーションのリセット
function Character:resetNavigation()
    self.visitedNavi = {}
end

-- 立つ
local Stand = Character:addState 'stand'

-- 死んだ
local Dead = Character:addState 'dead'

-- 死んだ: ステート開始
function Dead:enteredState(...)
    self.alive = false
    self:destroyCollider()
    if behavior then
        behavior:destroy()
    end
    self.onDead(self)
end

-- 死ぬ
local Dying = Character:addState 'dying'

-- 死ぬ: ステート開始
function Dying:enteredState(...)
    self.alive = false

    -- フェードアウトしつつ１秒後に死亡
    self._dying = {}
    self._dying.tag = self.timer:tween(
        0.5,
        self.color,
        { [4] = 0 },
        'in-out-cubic',
        function ()
            self:gotoState 'dead'
        end
    )
end

-- 死ぬ: ステート終了
function Dying:exitedState(...)
    self.timer:cancel(self._dying.tag)
end

-- 待機
local Wait = Character:addState 'wait'

-- 待機: ステート開始
function Wait:enteredState(delay)
    self.active = false

    self._wait = {}
    self._wait.tag = self.timer:after(
        delay or 1,
        function () self:popState() end
    )
end

-- 待機: ダメージを与える
function Wait:damage(damage, rotation, power)
end

-- 待機: ステート終了
function Wait:exitedState(...)
    self.active = true
    self.timer:cancel(self._wait.tag)
end

-- 待機: 更新
function Wait:update(dt)
    -- タイマー
    self.timer:update(dt)

    -- コライダの座標を適用する
    self:applyPositionFromCollider()
end

-- 見る
local Look = Character:addState 'look'

-- 見る: ステート開始
function Look:enteredState(targetOrTargetX, targetY)
    self._look = {}

    -- 目的地
    self._look.x, self._look.y = 0, 0
    if type(targetOrTargetX) == 'table' then
        self._look.x, self._look.y = targetOrTargetX.x, targetOrTargetX.y
        self._look.target = targetOrTargetX
    else
        self._look.x, self._look.y = targetOrTargetX, targetY
    end
end

-- 見る: 更新
function Look:update(dt)
    -- 目的地更新
    if self._look.target then
        self._look.x, self._look.y = self._look.target.x, self._look.target.y
    end

    -- 目的地を向く
    self:setRotationTo(self._look.x, self._look.y)

    -- 親更新
    Character.update(self, dt)
end

-- 移動
local Goto = Character:addState 'goto'

-- 移動: ステート開始
function Goto:enteredState(speed, targetOrTargetX, targetY)
    self._goto = {}

    -- スピード
    self._goto.speed = speed or self.speed

    -- 目的地
    self._goto.x, self._goto.y = 0, 0
    if type(targetOrTargetX) == 'table' then
        self._goto.x, self._goto.y = targetOrTargetX.x, targetOrTargetX.y
        self._goto.target = targetOrTargetX
    else
        self._goto.x, self._goto.y = targetOrTargetX, targetY
    end
end

-- 移動: 更新
function Goto:update(dt)
    -- 目的地更新
    if self._goto.target then
        self._goto.x, self._goto.y = self._goto.target.x, self._goto.target.y
    end

    -- 目的地を向く
    --self:setRotationTo(self._goto.x, self._goto.y)
    local rotating = false
    do
        local rate = dt
        local rotate = math.rad(self.anglarSpeed)
        local to = lume.angle(self.x, self.y, self._goto.x, self._goto.y) - self.rotation
        if to > math.pi then
            to = to - math.pi * 2
        elseif to < -math.pi then
            to = to + math.pi * 2
        end
        if math.abs(to) > math.pi * 0.1 then
            rotating = true
        end
        if math.abs(to) > math.pi * 0.001 then
            self:rotate((to < 0 and -rotate or rotate) * rate)
        end
    end

    -- 移動
    local x, y = self:forward()
    self:setColliderVelocity(x, y, self._goto.speed * (rotating and 0.5 or 1))

    -- 親更新
    Character.update(self, dt)
end

return Character
