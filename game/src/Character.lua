
local class = require 'middleclass'

-- キャラクター
local Character = class('Character', require 'Entity')
Character:include(require 'Rectangle')
Character:include(require 'SpriteRenderer')
Character:include(require 'Transform')
Character:include(require 'Collider')

-- 初期化
function Character:initialize(args)
    args = args or {}

    self.spriteName = args.spriteName

    -- SpriteRenderer 初期化
    self:initializeSpriteRenderer(args.spriteSheet)

    -- Rectangle 初期化
    local w, h = self:getSpriteSize(args.spriteName)
    self:initializeRectangle(args.x, args.y, w, h, args.h_align, args.v_align)

    -- Transform 初期化
    self:initializeTransform(self.x, self.y)

    -- Collider 初期化
    self:initializeCollider(args.collider)
end

-- 更新
function Character:update(dt)
    -- 回転テスト
    --self:rotate(math.pi * 0.5 * dt)

    -- スケールテスト
    --[[
    self.scale = self.scale + dt
    if self.scale > 3 then
        self.scale = 0
    end
    --]]
    self:applyPositionFromCollider()
end

-- 描画
function Character:draw()
    self:pushTransform(self:left(), self:top())
    self:drawSprite(self.spriteName)
    self:popTransform()
end

-- スプライトのリセット
function Character:resetSprite(spriteName, h_align, v_align)
    self.spriteName = spriteName
    local w, h = self:getSpriteSize(spriteName)
    self:initializeRectangle(self.x, self.y, w, h, h_align, v_align)
end

return Character
