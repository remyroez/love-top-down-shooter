
local lume = require 'lume'
local class = require 'middleclass'

-- キャラクター
local Character = class('Character', require 'Entity')
Character:include(require 'Rectangle')
Character:include(require 'SpriteRenderer')
Character:include(require 'Transform')
Character:include(require 'Collider')
Character:include(require 'Weapon')

-- 初期化
function Character:initialize(args)
    args = args or {}

    self.type = args.type or 'object'

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
end

-- 破棄
function Character:destroy()
    self:destroyCollider()
end

-- 更新
function Character:update(dt)
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

return Character
