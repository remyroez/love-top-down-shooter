
local lume = require 'lume'

-- エイリアス
local lg = love.graphics
local lk = love.keyboard
local lm = love.mouse

-- クラス
local Scene = require 'Scene'
local Character = require 'Character'
local Level = require 'Level'
local Camera = require 'Camera'
local Input = require 'Input'
local Timer = require 'Timer'

-- ゲーム
local Game = Scene:newState 'game'

-- バインドする入力
local bindInputs = {
    up = { 'w', 'up', 'dpup' },
    down = { 's', 'down', 'dpdown' },
    left = { 'a', 'left', 'dpleft' },
    right = { 'd', 'right', 'dpright' },
    fire = { 'mouse1', 'fdown' },
    reload = { 'mouse2', 'fright' },
}

-- 読み込み
function Game:load()
    self.state.input = Input()
    self.state.timer = Timer()
end

-- ステート開始
function Game:enteredState(...)
    -- 親
    Scene.enteredState(self, ...)

    -- 入力
    for action, inputs in pairs(bindInputs) do
        for _, input in pairs(inputs) do
            self.state.input:bind(input, action)
        end
    end

    -- カメラ
    self.state.camera = Camera()

    -- レベル
    self.state.level = Level('assets/levels/simple.lua')
    self.state.level:resizeMapCanvas(self.width, self.height, self.state.camera.scale)
    self.state.level:setupCharacters(self.spriteSheet)
    self.state.level:setupWave(1, 0, 10, self.spriteSheet)
    self.state.level:setupNavigation()

    -- プレイヤー
    self.state.player = self.state.level:getPlayer() or self.state.level:registerEntity(
        Character {
            spriteSheet = self.spriteSheet,
            spriteName = 'hitman1_gun.png',
            x = self.width * 0.5,
            y = self.height * 0.5,
            h_align = 'center',
            collider = self.state.level.world:newCircleCollider(0, 0, 12),
            collisionClass = 'player'
        }
    )
    self.state.player.onDamage = function (character, attacker)
        self.state.camera:flash(0.1, { 1, 0, 0, 0.5 })
        self.state.camera:shake(8, 0.2, 60)
    end

    -- カメラ初期設定
    self.state.camera:follow(self:getPlayerPosition())
    self.state.camera:update()
    self.state.camera:setFollowLerp(0.1)
    self.state.camera:setFollowLead(2)
    self.state.camera:setFollowStyle('TOPDOWN_TIGHT')
    self.state.camera:setBounds(self.state.level.left, self.state.level.top, self.state.level.width, self.state.level.height)
    self.state.camera.scale = 1

    -- 弾道
    self.state.bullets = {}

    -- デバッグモード
    self:setDebug(false)
end

-- ステート終了
function Game:exitedState(...)
    self.state.input:unbindAll()
    self.state.level:destroy()
    self.state.timer:destroy()
end

-- 更新
function Game:update(dt)
    -- タイマー
    self.state.timer:update(dt)

    -- プレイヤー操作
    self:controlPlayer()

    -- レベル更新
    self.state.level:update(dt)

    -- カメラ更新
    self.state.camera:update(dt)
    self.state.camera:follow(self:getPlayerPosition())

    -- ウェーブのクリア
    if self.state.level:isClearWave() then
        if self.state.level.wave <= 0 then
            -- 単一ウェーブなら終了
            self.state.level:setupWave()
        else
            -- 次のウェーブへ
            local wave = self.state.level.wave + 1
            self.state.level:setupWave(wave, 0, 5 + wave * 5, self.spriteSheet)
        end
    end
end

-- 描画
function Game:draw()
    local cx, cy = self:getPlayerPosition()

    -- カメラ内描画
    self.state.camera:attach()
    do
        -- レベル描画
        self.state.level:draw(
            self.state.camera.w / 2 - self.state.camera.x,
            self.state.camera.h / 2 - self.state.camera.y,
            self.state.camera.scale)

        -- 弾道描画
        for _, bullet in ipairs(self.state.bullets) do
            lg.setColor(bullet.color)
            lg.line(unpack(bullet.line))
        end
    end
    self.state.camera:detach()

    -- カメラ描画
    self.state.camera:draw()

    -- ライフ
    do
        love.graphics.setColor(1, 1, 1)
        lg.printf('LIFE: ', 0, self.height - 16, self.width, 'left')
        local color = { lume.color('#ffffff') }
        local rate = self.state.player.life / self.state.player.lifeMax
        if rate <= 0.3 then
            color = { lume.color('rgb(255, 0, 0)') }
        elseif rate <= 0.5 then
            color = { lume.color('rgb(255, 255, 0)') }
        end
        love.graphics.setColor(color)
        lg.printf(self.state.player.life, 32, self.height - 16, self.width, 'left')
    end

    -- 残弾数
    love.graphics.setColor(1, 1, 1)
    lg.printf(
        'AMMO: ' .. (self.state.player:isReloadingWeapon() and 'RELOADING...' or tostring(self.state.player:getWeaponAmmo())) .. '/' .. self.state.player:getWeaponMaxAmmo(),
        0,
        self.height - 16,
        self.width,
        'right'
    )

    -- 座標（デバッグ）
    if self.debug then
        love.graphics.setColor(1, 1, 1)
        lg.printf('x: ' .. math.ceil(cx) .. ', y: ' .. math.ceil(cy), 0, self.height * 0.5 - 16, self.width, 'right')
    end

    -- ウェーブ
    if self.state.level.wave > 0 then
        love.graphics.setColor(1, 1, 1)
        lg.printf('WAVE: ' .. self.state.level.wave, 0, 0, self.width, 'left')
    end

    -- 残り時間
    if self.state.level:hasWaveTime() then
        love.graphics.setColor(1, 1, 1)
        lg.printf(math.floor(self.state.level:getWaveTime()), 0, 0, self.width, 'center')
    end

    -- 敵
    if self.state.level:getMaxSpawn() > 0 then
        love.graphics.setColor(1, 1, 1)
        lg.printf('KILL: ' .. (self.state.level:getNumSpawned() - #self.state.level:getEnemies()) .. '/' .. self.state.level:getMaxSpawn(), 0, 0, self.width, 'right')
    end
end

-- デバッグモード設定
function Game:setDebug(enable)
    self.debug = enable
    self.state.level:setDebug(enable)
end

-- プレイヤー操作
function Game:controlPlayer()
    local player = self.state.player

    -- プレイヤーがノンアクティブなら操作しない
    if not player:isActive() then
        return
    end

    local input = self.state.input

    -- 移動
    local x, y = 0, 0
    if input:down('up') then
        y = -1
    elseif input:down('down') then
        y = 1
    end
    if input:down('left') then
        x = -1
    elseif input:down('right') then
        x = 1
    end
    player:setColliderVelocity(x, y, player.speed)
    player:setRotationTo(self:getMousePosition())

    -- 射撃
    if player:isReloadingWeapon() then
        -- リロード中
    elseif input:down('fire', player:getWeaponDelay()) then
        if player:hasWeaponAmmo() then
            local cx, cy = self:getPlayerPosition()
            local mx, my = self:getMousePosition()
            local rx, ry = lume.vector(lume.angle(cx, cy, mx, my), player:getWeaponRange())
            --[[
            local gx, gy = cx, cy
            do
                local x, y = player:forward(32)
                gx = gx + x
                gy = gy + y
            end
            do
                local x, y = lume.vector(player.rotation + math.pi * 0.5, 10 * player.scale)
                gx = gx + x
                gy = gy + y
            end
            --]]

            -- 射撃実行
            player:fireWeapon()

            -- 画面のシェイク
            self.state.camera:shake(8, 0.1, 60)

            -- 弾道
            local bullet = { line = { cx, cy, cx + rx, cy + ry }, color = { 1.0, 0, 0, 0.5 }}
            table.insert(self.state.bullets, bullet)

            -- 一番近いヒット地点を探す
            do
                local hits = {}
                self.state.level.world:rayCast(
                    cx, cy, cx + rx, cy + ry,
                    function (fixture, x, y, xn, yn, fraction)
                        table.insert(hits, { x = x, y = y })
                        return 1
                    end
                )
                local nearestDist = player:getWeaponRange()
                local nearest
                for _, hit in ipairs(hits) do
                    local dist = lume.distance(cx, cy, hit.x, hit.y)
                    if dist < nearestDist then
                        nearestDist = dist
                        nearest = hit
                    end
                end
                if nearest then
                    bullet.line[3] = nearest.x
                    bullet.line[4] = nearest.y
                end
            end

            self.state.timer:tween(
                0.1,
                bullet.color,
                { [4] = 0 },
                'in-out-cubic',
                function ()
                    lume.remove(self.state.bullets, bullet)
                end
            )

            -- 斜線の敵を探す
            local fx, fy = cx + rx, cy + ry
            local colliders = self.state.level.world:queryLine(cx, cy, fx, fy, { 'All', except = { 'player', 'friend' } })
            local nearestDist = player:getWeaponRange()
            local nearest
            for _, collider in ipairs(colliders) do
                local entity = collider:getObject()
                if entity and entity.alive then
                    local dist = lume.distance(cx, cy, entity.x, entity.y)
                    if dist < nearestDist then
                        nearestDist = dist
                        nearest = entity
                    end
                end
            end
            if nearest then
                nearest:damage(
                    player:getWeaponDamage(),
                    player.rotation,
                    player:getWeaponPower(),
                    player
                )
            end
        elseif player:canReloadWeapon() then
            -- リロード
            player:reloadWeapon(1, function (p) p:resetSprite() end)
            player:resetSprite()
        end
    elseif input:pressed('reload') and player:canReloadWeapon() then
        -- リロード
        player:reloadWeapon(1, function (p) p:resetSprite() end)
        player:resetSprite()
    end
end

-- プレイヤーのワールド座標を返す
function Game:getPlayerPosition()
    return self.state.player:getPosition()
end

-- マウスのワールド座標を返す
function Game:getMousePosition()
    return self.state.camera:toWorldCoords(lm.getPosition())
end

return Game
