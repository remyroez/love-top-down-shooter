
local lume = require 'lume'
local class = require 'middleclass'

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

    self.type = args.type or 'object'
    self.speed = args.speed or 100

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
    -- ビヘイビア
    if self.behavior then
        self.behavior:update(dt)
    end

    -- コライダの座標を適用する
    self:applyPositionFromCollider()
end

-- 描画
function Character:draw()
    self:pushTransform(self:left(), self:top())
    self:drawSprite(self.spriteName, self:getSpriteOffset())
    self:popTransform()
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
    self._goto.speed = speed

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
    self:setRotationTo(self._goto.x, self._goto.y)

    -- 移動
    local x, y = self:forward()
    self:setColliderVelocity(x, y, self._goto.speed)

    -- 親更新
    Character.update(self, dt)
end

return Character
