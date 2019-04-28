
local class = require 'middleclass'

local lume = require 'lume'
local wf = require 'windfield'

-- レベル
local Level = class 'Level'

-- 初期化
function Level:initialize()
    -- ワールド
    self.world = wf.newWorld(0, 0, true)
    self.world:addCollisionClass('player')
    self.world:addCollisionClass('enemy')

    -- エンティティ
    self.entities = {}
end

-- 更新
function Level:update(dt)
    self.world:update(dt)
    lume.each(self.entities, 'update', dt)
end

-- 描画
function Level:draw()
    lume.each(self.entities, 'draw')
    self.world:draw(0.5)
end

-- エンティティの追加
function Level:registerEntity(entity)
    table.insert(self.entities, entity)
    return entity
end

-- エンティティの削除
function Level:deregisterEntity(entity)
    entity:destroy()
    lume.remove(self.entities, entity)
end

-- 全エンティティの削除
function Level:clearEntities()
    lume.each(self.entities, 'destroy')
    lume.clear(self.entities)
end

-- 破棄
function Level:destroy()
    self:clearEntities()
    self.world:destroy()
end

return Level
