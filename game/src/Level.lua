
local class = require 'middleclass'

local lume = require 'lume'
local wf = require 'windfield'
local sti = require 'sti'

-- レベル
local Level = class 'Level'

-- コリジョンクラス
local collisionClasses = {
    player = {},
    enemy = {},
    building = {},
    object = {},
}

-- 初期化
function Level:initialize(map)
    -- ワールド
    self.world = wf.newWorld(0, 0, true)

    -- コリジョンクラスの追加
    for name, klass in pairs(collisionClasses) do
        self.world:addCollisionClass(name, klass)
    end

    -- マップ
    self.map = sti(map, { 'windfield' })
    self.map:windfield_init(self.world)

    -- エンティティ
    self.entities = {}
end

-- 破棄
function Level:destroy()
    self:clearEntities()
    self.world:destroy()
end

-- 更新
function Level:update(dt)
    self.world:update(dt)
    lume.each(self.entities, 'update', dt)
end

-- 描画
function Level:draw(x, y, scale)
    -- マップの描画
    self.map:draw(x, y, scale)

    -- エンティティの描画
    lume.each(self.entities, 'draw')

    -- ワールドのデバッグ描画
    self.world:draw(0.5)
end

-- マップキャンバスのリサイズ
function Level:resizeMapCanvas(w, h, scale)
    local width, height = love.graphics.getDimensions()
    w = w or width or 0
    h = h or height or 0
    self.map:resize(w / scale, h / scale)
    self.map.canvas:setFilter("linear", "linear")
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

return Level
