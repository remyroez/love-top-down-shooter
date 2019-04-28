
local class = require 'middleclass'

-- エンティティ
local Entity = class 'Entity'

-- 初期化
function Entity:initialize()
end

-- 破棄
function Entity:destroy()
end

-- 更新
function Entity:update(dt)
end

-- 描画
function Entity:draw()
end

return Entity
