
local class = require 'middleclass'

local lume = require 'lume'
local wf = require 'windfield'
local sti = require 'sti'

-- クラス
local Character = require 'Character'
local ZombieBehavior = require 'ZombieBehavior'
local Timer = require 'Timer'

-- レベル
local Level = class 'Level'

-- コリジョンクラス
local collisionClasses = {
    player = {},
    enemy = {},
    friend = {},
    building = {},
    object = {},
}

-- スプライトバリエーション
local spriteVariation = {
    hitman = { 'hitman1', 'hitman2' },
    zombie = { 'zombie1', 'zombie2' },
    man = { 'manBlue', 'manBrown', 'manRed' },
    man_old = { 'manOld' },
    woman = { 'womanGreen' },
    woman_old = { 'womanOld' },
    robot = { 'robot1', 'robot2' },
    soldier = { 'soldier1', 'soldier2' },
    survivor = { 'survivor1', 'survivor2' },
}

-- 武器
local weaponData = {
    gun = {
        name = 'gun',
        damage = 4,
        power = 5000,
        ammo = 8,
        sound = 20,
    },
    machine = {
        name = 'machine',
        damage = 1,
        power = 2500,
        ammo = 8,
        sound = 10,
    },
    silencer = {
        name = 'silencer',
        damage = 3,
        power = 1000,
        ammo = 8,
        sound = 5,
    },
    hand = {
        name = 'hold',
        damage = 1,
        power = 1000,
        ammo = -1,
        sound = 1,
    },
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

    -- タイマー
    self.timer = Timer()
end

-- キャラクターのセットアップ
function Level:setupCharacters(spriteSheet)
    self:clearEntities()

    -- character レイヤー
    local layer = self.map.layers['character']
    layer.visible = false

    -- 遅延設定用のテーブル
    local rotateToPlayer = {}
    local lazySettingStates = {
        followPlayer = {},
        lookAtPlayer = {}
    }

    -- オブジェクトからキャラクター生成
    for _, object in ipairs(layer.objects) do
        -- キャラクターのスポーン
        local entity = self:spawnCharacter(object, spriteSheet)

        -- プレイヤーに向かせるため保持
        if object.properties.rotate == 'player' and object.type ~= 'player' then
            table.insert(rotateToPlayer, entity)
        end

        -- ステートを後から設定するため保持
        for name, list in pairs(lazySettingStates) do
            if object.properties.state == name and object.type ~= 'player' then
                table.insert(list, entity)
            end
        end
    end

    -- プレイヤー関連の設定
    local player = self:getPlayer()
    if player then
        for _, entity in ipairs(rotateToPlayer) do
            entity:setRotationTo(player:getPosition())
        end
        for _, entity in ipairs(lazySettingStates.followPlayer) do
            entity:gotoState('goto', entity.speed, player)
        end
        for _, entity in ipairs(lazySettingStates.lookAtPlayer) do
            entity:gotoState('look', player)
        end
    end
end

-- スポナーのセットアップ
function Level:setupSpawners(spriteSheet)
    self.timer:destroy()

    -- spawner レイヤー
    local layer = self.map.layers['spawner']
    layer.visible = false

    -- オブジェクトからスポナー生成
    for _, object in ipairs(layer.objects) do
        self.timer:every(
            object.properties.delay or 1,
            function ()
                -- キャラクターのスポーン
                local entity = self:spawnCharacter(object, spriteSheet)

                -- プレイヤー関連の設定
                local player = self:getPlayer()
                if player and object.type ~= 'player' then
                    if object.properties.rotate == 'player' then
                        entity:setRotationTo(player:getPosition())
                    end
                    if object.properties.state == 'followPlayer' then
                        entity:gotoState('goto', entity.speed, player)
                    elseif object.properties.state == 'lookAtPlayer' then
                        entity:gotoState('look', player)
                    end
                end
            end
        )
    end
end

-- キャラクターのスポーン
function Level:spawnCharacter(object, spriteSheet)
    -- デフォルト
    local defaultSprite = (object.type == 'player') and spriteVariation.hitman or spriteVariation.zombie
    local defaultWeapon = (object.type == 'player') and weaponData.gun or weaponData.hand

    -- スプライト名
    local sprite = spriteVariation[object.properties.sprite] or defaultSprite

    -- 武器
    local weapon = weaponData[object.properties.weapon] or defaultWeapon

    -- 回転
    local rotation = object.rotation or 0
    if object.properties.rotate == 'random' then
        rotation = love.math.random(360)
    elseif object.properties.rotate == 'player' then
        rotation = love.math.random(360)
    end

    -- ステート
    local state
    if object.properties.state == 'followPlayer' then
    end

    -- ビヘイビア
    local behavior
    if object.properties.behavior == 'zombie' then
        behavior = ZombieBehavior
    end

    -- キャラクターエンティティの登録
    local entity = self:registerEntity(
        Character {
            type = object.type,
            spriteSheet = spriteSheet,
            sprite = sprite,
            weapon = weapon,
            x = object.x,
            y = object.y,
            rotation = math.rad(rotation),
            scale = object.properties.scale or 1,
            speed = object.properties.speed,
            h_align = 'center',
            collider = self.world:newCircleCollider(0, 0, 12 * (object.properties.scale or 1)),
            collisionClass = object.type,
            behavior = behavior,
            world = self.world,
            life = object.properties.life,
            onDead = function (character) self:deregisterEntity(character) end
        }
    )

    -- キャラクターテーブルに登録
    if self.characters[object.type] then
        table.insert(self.characters[object.type], entity)
    else
        print('invalid object type [' .. object.type .. ']')
    end

    return entity
end

-- 破棄
function Level:destroy()
    self.timer:destroy()
    self:clearEntities()
    self.world:destroy()
end

-- 更新
function Level:update(dt)
    self.timer:update(dt)
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
