
local lume = require 'lume'

-- コライダーモジュール
local Collider = {}

-- 初期化
function Collider:initializeCollider(collider)
    self.x = self.x or 0
    self.y = self.y or 0

    self.collider = collider
    self.collider:setObject(self)
    self:applyPositionToCollider()
end

-- コライダー座標の更新
function Collider:setColliderVelocity(x, y, speed)
    if x == 0 and y == 0 then
        self.collider:setLinearVelocity(0, 0)
    else
        self.collider:setLinearVelocity(lume.vector(lume.angle(self.x, self.y, self.x + x, self.y + y), speed))
    end
end

-- コライダー座標の更新
function Collider:applyPositionToCollider()
    self.collider:setPosition(self.x, self.y)
end

-- コライダー座標の更新
function Collider:applyPositionFromCollider()
    self.x, self.y = self.collider:getPosition()
end

return Collider
