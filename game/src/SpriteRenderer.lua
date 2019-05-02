
-- スプライトレンダラーモジュール
local SpriteRenderer = {}

-- 初期化
function SpriteRenderer:initializeSpriteRenderer(spriteSheet)
    -- プライベート
    self._spriteRenderer = {}

    -- スプライトシート
    self._spriteRenderer.spriteSheet = spriteSheet
end

-- スプライトの取得
function SpriteRenderer:getSpriteQuad(name)
    return self._spriteRenderer.spriteSheet.quad[name]
end

-- スプライトのサイズの取得
function SpriteRenderer:getSpriteSize(name)
    local quad = self:getSpriteQuad(name)
    if quad == nil then return 0, 0 end
    local _, __, w, h = quad:getViewport()
    return w, h
end

-- スプライトの描画
function SpriteRenderer:drawSprite(name, x, y)
    x = x or 0
    y = y or 0
    self._spriteRenderer.spriteSheet:draw(name, math.ceil(x), math.ceil(y))
end

-- スプライトバッチへ追加
function SpriteRenderer:addSpriteToBatch(spriteBatch, name, x, y)
    spriteBatch:add(self:getSpriteQuad(name), math.ceil(x), math.ceil(y))
end

return SpriteRenderer
