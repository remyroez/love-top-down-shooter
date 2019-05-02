
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
    'frame',
    'player',
    'enemy',
    'friend',
    'building',
    'object',
    frame = {},
    player = {},
    enemy = { ignores = { 'frame' } },
    friend = { ignores = { 'frame' } },
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
        delay = 0.5,
        range = 500,
    },
    machine = {
        name = 'machine',
        damage = 1,
        power = 3000,
        ammo = 30,
        sound = 10,
        delay = 0.1,
        range = 500,
    },
    silencer = {
        name = 'silencer',
        damage = 3,
        power = 2000,
        ammo = 8,
        sound = 5,
        delay = 0.5,
        range = 300,
    },
    hand = {
        name = 'hold',
        damage = 1,
        power = 5000,
        ammo = -1,
        sound = 1,
        delay = 1,
        range = 16,
    },
}

-- 初期化
function Level:initialize(map)
    -- キャラクター
    self.characters = {}

    -- ワールド
    self.world = wf.newWorld(0, 0, true)

    -- コリジョンクラスの追加
    for index, name in ipairs(collisionClasses) do
        local klass = collisionClasses[name]
        self.world:addCollisionClass(name, klass)
        self.characters[name] = {}
    end

    -- マップ
    self.map = sti(map, { 'windfield' })
    self.map:windfield_init(self.world)

    -- マップ情報の取得
    self.left = 0
    self.right = 0
    self.top = 0
    self.bottom = 0
    local customIndex = nil
    for index, layer in ipairs(self.map.layers) do
        if layer == self.map.layers['character'] then
            customIndex = index
        end
        if layer.type == 'tilelayer' then
            -- チャンクから上下左右の端を取得
            if layer.chunks then
                for __, chunk in ipairs(layer.chunks) do
                    if chunk.x < self.left then
                        self.left = chunk.x
                    end
                    if chunk.y < self.top then
                        self.top = chunk.y
                    end
                    if chunk.x + chunk.width > self.right then
                        self.right = chunk.x + chunk.width
                    end
                    if chunk.y + chunk.height > self.bottom then
                        self.bottom = chunk.y + chunk.height
                    end
                end
            end
        end
    end
    self.left = self.left * self.map.tilewidth
    self.right = self.right * self.map.tilewidth
    self.top = self.top * self.map.tileheight
    self.bottom = self.bottom * self.map.tileheight
    self.width = self.right - self.left
    self.height = self.bottom - self.top

    self.frames = {}
    do
        local rects = {
            { self.left - 8, self.top - 8, 8, self.height + 16, dir = 'left' },
            { self.left - 8, self.top - 8, self.width + 16, 8, dir = 'up' },
            { self.right, self.top - 8, 8, self.height + 16, dir = 'right' },
            { self.left - 8, self.bottom, self.width + 16, 8, dir = 'down' },
        }
        for _, rect in ipairs(rects) do
            local r = rect
            local frame = self.world:newRectangleCollider(unpack(rect))
            frame:setCollisionClass('frame')
            frame:setType('static')
            frame:setPreSolve(
                function(collider_1, collider_2, contact)
                    if collider_1.collision_class ~= 'frame' and collider_2.collision_class == 'frame' then
                        local x1, y1 = collider_1:getPosition()
                        local x2, y2 = collider_2:getPosition()
                        print(x1, y1, x2, y2)
                        if r.dir == 'left' then
                            if x1 > x2 then contact:setEnabled(false) end
                        elseif r.dir == 'up' then
                            if y1 > y2 then contact:setEnabled(false) end
                        elseif r.dir == 'right' then
                            if x1 < x2 then contact:setEnabled(false) end
                        elseif r.dir == 'down' then
                            if y1 < y2 then contact:setEnabled(false) end
                        end
                    end
                end
            )
            table.insert(self.frames, frame)
        end
    end

    -- カスタムレイヤー
    if customIndex then
        local level = self
        local layer = self.map:addCustomLayer('entity', customIndex)
        function layer:update(dt)
            lume.each(level.entities, 'update', dt)
        end
        function layer:draw()
            lume.each(level.entities, 'draw')
        end
    end

    for _, collision in ipairs(self.map.windfield_collision) do
        if collision.object.layer and collision.object.layer.type == 'tilelayer' then
            collision.collider:setCollisionClass('building')
        elseif collision.baseObj and collision.baseObj.layer and collision.baseObj.layer.type == 'tilelayer' then
            collision.collider:setCollisionClass('building')
        end
    end

    -- エンティティ
    self.entities = {}

    -- タイマー
    self.timer = Timer()

    -- ウェーブ情報
    self.wave = 0
    self.time = 0
    self.spawner = {
        current = 0,
        max = 0,
    }

    -- ナビ
    self.navigation = {}
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
    -- spawner レイヤー
    local layer = self.map.layers['spawner']
    layer.visible = false

    -- オブジェクトからスポナー生成
    for _, object in ipairs(layer.objects) do
        -- 現在のウェーブ以下なら、スポナー設置
        local wave = object.properties.wave or 0
        if wave <= self.wave then
            self.timer:every(
                object.properties.delay or 1,
                function ()
                    -- スポーン数が限度に達していたらキャンセル
                    if self.spawner.current >= self.spawner.max then
                        return
                    end

                    -- キャラクターのスポーン
                    local entity = self:spawnCharacter(object, spriteSheet)
                    self.spawner.current = self.spawner.current + 1

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
end

-- ウェーブのセットアップ
function Level:setupWave(wave, time, max, spriteSheet)
    self.wave = wave or 0
    self.time = time or 0

    -- スポナー情報のクリア
    self.spawner = {
        current = 0,
        max = max or 0,
    }

    -- タイマーのリセット
    self.timer:destroy()

    -- スポナーセットアップ
    if self.spawner.max > 0 then
        self:setupSpawners(spriteSheet)
    end

    -- 制限時間
    if self.time > 0 then
        self.timer:after(
            self.time,
            function ()
                self.timer:destroy()
            end,
            'wave'
        )
    end
end

-- ウェーブのタイム
function Level:getWaveTime()
    return self.time - (self.timer.timers['wave'] and self.timer:getTime('wave') or self.time)
end

-- ウェーブの制限時間があるかどうか
function Level:hasWaveTime()
    return self.time > 0
end

-- ウェーブをクリアしたかどうか
function Level:isClearWave()
    local clear = false

    if self:hasWaveTime() and self:getWaveTime() == 0 then
        clear = true
    elseif self:isAllSpawned() and #self:getEnemies() == 0 then
        clear = true
    end

    return clear
end

-- ウェーブのセットアップ
function Level:setupNavigation()
    lume.clear(self.navigation)

    -- navi レイヤー
    local layer = self.map.layers['navi']
    if not layer then
        return
    end

    layer.visible = false

    -- オブジェクトからナビゲーション生成
    for _, object in ipairs(layer.objects) do
        table.insert(self.navigation, { x = object.x, y = object.y })
    end
end

-- キャラクターのスポーン
function Level:spawnCharacter(object, spriteSheet)
    -- デフォルトスプライト
    local defaultSprite = (object.type == 'player') and spriteVariation.hitman or spriteVariation.zombie

    -- デフォルト武器
    local defaultWeapon
    if object.type == 'player' then
        defaultWeapon = weaponData.gun
    elseif object.type == 'enemy' then
        defaultWeapon = weaponData.hand
    end

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
            x = object.x + love.math.randomNormal(),
            y = object.y + love.math.randomNormal(),
            rotation = math.rad(rotation),
            scale = object.properties.scale or 1,
            speed = object.properties.speed,
            h_align = 'center',
            collider = self.world:newCircleCollider(0, 0, 12 * (object.properties.scale or 1)),
            collisionClass = object.type,
            behavior = behavior,
            world = self.world,
            navigation = self.navigation,
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
    self.map:update(dt)
    self.map:windfield_update(dt)
end

-- 描画
function Level:draw(x, y, scale)
    -- マップの描画
    self.map:draw(x, y, scale)

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

-- スポーン済みの数
function Level:getNumSpawned()
    return self.spawner.current
end

-- スポーン最大数
function Level:getMaxSpawn()
    return self.spawner.max
end

-- 全てスポーン済みかどうか
function Level:isAllSpawned()
    return self:getNumSpawned() >= self:getMaxSpawn()
end

return Level
