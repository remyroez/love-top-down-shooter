
local lume = require 'lume'

-- コライダーモジュール
local Collider = {}

-- 初期化
function Collider:initializeCollider(collider)
    self.x = self.x or 0
    self.y = self.y or 0
    self.collider = collider

    -- コライダー初期設定
    self.collider:setObject(self)
    self:applyPositionToCollider()
end

-- 破棄
function Collider:destroyCollider()
    if self.collider then
        self.collider:destroy()
        self.collider = nil
    end
end

-- コライダー座標の更新
function Collider:setColliderVelocity(x, y, speed)
    if self.collider == nil then
        -- no collider
    elseif (x == 0 and y == 0) or speed == 0 then
        self.collider:setLinearVelocity(0, 0)
    else
        self.collider:setLinearVelocity(lume.vector(lume.angle(self.x, self.y, self.x + x, self.y + y), speed))
    end
end

-- コライダーへ座標を適用
function Collider:applyPositionToCollider()
    if self.collider then
        self.collider:setPosition(self.x, self.y)
    end
end

-- コライダーから座標を適用
function Collider:applyPositionFromCollider()
    if self.collider then
        self.x, self.y = self.collider:getPosition()
    end
end

return Collider
