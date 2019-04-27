
local class = require 'middleclass'

-- キャラクター
local Character = class('Character', require 'Entity')
Character:include(require 'Rectangle')
Character:include(require 'SpriteRenderer')

-- 初期化
function Character:initialize(args)
    args = args or {}

    self.spriteName = args.spriteName

    -- SpriteRenderer 初期化
    self:initializeSpriteRenderer(args.spriteSheet)

    -- Rectangle 初期化
    local w, h = self:getSpriteSize(args.spriteName)
    self:initializeRectangle(args.x, args.y, w, h, args.h_align, args.v_align)
end

-- 更新
function Character:update(dt)
end

-- 描画
function Character:draw()
    self:drawSprite(self.spriteName, self:left(), self:top())
end

-- スプライトのリセット
function Character:resetSprite(spriteName, h_align, v_align)
    self.spriteName = spriteName
    local w, h = self:getSpriteSize(spriteName)
    self:initializeRectangle(self.x, self.y, w, h, h_align, v_align)
end

return Character
