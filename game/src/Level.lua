
local class = require 'middleclass'

local lume = require 'lume'
local wf = require 'windfield'
local sti = require 'sti'

-- クラス
local Character = require 'Character'

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
    -- キャラクター
    self.characters = {}

    -- ワールド
    self.world = wf.newWorld(0, 0, true)

    -- コリジョンクラスの追加
    for name, klass in pairs(collisionClasses) do
        self.world:addCollisionClass(name, klass)
        self.characters[name] = {}
    end

    -- マップ
    self.map = sti(map, { 'windfield' })
    self.map:windfield_init(self.world)

    -- エンティティ
    self.entities = {}
end

-- キャラクターのセットアップ
function Level:setupCharacters(spriteSheet)
    self:clearEntities()

    local layer = self.map.layers['character']
    layer.visible = false

    for _, object in ipairs(layer.objects) do
        local spriteName
        if object.type == 'player' then
            spriteName = object.properties.spriteName or 'hitman1_gun.png'
        else
            spriteName = object.properties.spriteName or 'zombie1_hold.png'
        end

        local entity = self:registerEntity(
            Character {
                spriteSheet = spriteSheet,
                spriteName = spriteName,
                x = object.x,
                y = object.y,
                rotation = math.rad(object.rotation or 0),
                scale = object.properties.scale or 1,
                h_align = 'center',
                collider = self.world:newCircleCollider(0, 0, 12 * (object.properties.scale or 1)),
                collisionClass = object.type
            }
        )
        if self.characters[object.type] then
            table.insert(self.characters[object.type], entity)
        else
            print('invalid object type [' .. object.type .. ']')
        end
    end
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

    for type, list in pairs(self.characters) do
        lume.remove(list, entity)
    end
end

-- 全エンティティの削除
function Level:clearEntities()
    lume.each(self.entities, 'destroy')
    lume.clear(self.entities)

    for type, list in pairs(self.characters) do
        lume.clear(list)
    end
end

-- キャラクターリストの取得
function Level:getCharacters(category)
    return self.characters[category]
end

-- プレイヤーリストの取得
function Level:getPlayers()
    return self:getCharacters('player')
end

-- エネミーリストの取得
function Level:getEnemies()
    return self:getCharacters('enemy')
end

-- 建物リストの取得
function Level:getBuildings()
    return self:getCharacters('building')
end

-- オブジェクトリストの取得
function Level:getObjects()
    return self:getCharacters('object')
end

-- プレイヤーの取得
function Level:getPlayer()
    return lume.first(self:getPlayers())
end

return Level
