
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
function Game:enteredState(path, ...)
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
    self.state.level = Level(path, self.soundPaths)
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
        -- 画面の演出
        self.state.camera:flash(0.1, { 1, 0, 0, 0.5 })
        self.state.camera:shake(8, 0.2, 60)

        -- ＳＥ
        self.sounds.damage:seek(0)
        self.sounds.damage:play()
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

    -- 音
    self.state.sounds = {}

    -- デバッグモード
    self:setDebug(false)

    -- マウス
    lm.setVisible(false)
    lm.setGrabbed(true)

    -- フェード
    self.state.fade = { 0, 0, 0, 1 }
    self.state.fade2 = { 0, 0, 0, 0 }
    self.state.action = true
    self.state.timer:tween(
        1,
        self.state.fade,
        { [4] = 0 },
        'in-out-cubic',
        function ()
            self.state.action = false
        end
    )
    self.state.youdied = { 1, 0, 0, 0 }
    self.state.gameover = false
    self.state.visiblePressAnyKey = true

    -- ＢＧＭ
    self.musics.ingame:play()
end

-- ステート終了
function Game:exitedState(...)
    self.state.input:unbindAll()
    self.state.level:destroy()
    self.state.timer:destroy()

    -- マウス
    lm.setVisible(true)
    lm.setGrabbed(false)
end

-- 更新
function Game:update(dt)
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

    -- タイマー
    self.state.timer:update(dt)
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

        -- サウンド描画
        if self.debug then
            for _, sound in ipairs(self.state.sounds) do
                lg.setColor(sound.color)
                lg.circle(unpack(sound.circle))
            end
        end
    end
    self.state.camera:detach()

    -- カメラ描画
    self.state.camera:draw()

    -- フェード2
    if self.state.fade2[4] > 0 then
        lg.setColor(unpack(self.state.fade2))
        lg.rectangle('fill', 0, 0, self.width, self.height)
    end

    -- 照準の描画
    local mx, my = lm.getPosition()
    lg.setColor(1, 1, 1)
    lg.draw(self.crosshair, mx - self.crosshair:getWidth() * 0.5, my - self.crosshair:getHeight() * 0.5)

    -- ライフ
    do
        love.graphics.setColor(1, 1, 1)
        lg.printf(
            'LIFE',
            self.font16,
            8,
            self.height - self.font32:getHeight() - self.font16:getHeight(),
            self.width,
            'left'
        )
        local color = { lume.color('#ffffff') }
        local rate = self.state.player.life / self.state.player.lifeMax
        if rate <= 0.3 then
            color = { lume.color('rgb(255, 0, 0)') }
        elseif rate <= 0.5 then
            color = { lume.color('rgb(255, 255, 0)') }
        end
        love.graphics.setColor(color)
        lg.printf(
            self.state.player.life,
            self.font32,
            8,
            self.height - self.font32:getHeight(),
            self.width,
            'left'
        )
    end

    -- 残弾数
    do
        love.graphics.setColor(1, 1, 1)
        lg.printf(
            'AMMO',
            self.font16,
            -8,
            self.height - self.font32:getHeight() - self.font16:getHeight(),
            self.width,
            'right'
        )
        lg.printf(
            '' .. (self.state.player:isReloadingWeapon() and 'RELOADING...' or tostring(self.state.player:getWeaponAmmo())),
            self.font32,
            -8,
            self.height - self.font32:getHeight(),
            self.width,
            'right'
        )
    end

    -- 座標（デバッグ）
    if self.debug then
        love.graphics.setColor(1, 1, 1)
        lg.printf('x: ' .. math.ceil(cx) .. ', y: ' .. math.ceil(cy), 0, self.height * 0.5 - 16, self.width, 'right')
    end

    -- ウェーブ
    if self.state.level.wave > 0 then
        love.graphics.setColor(1, 1, 1)
        lg.printf('WAVE', self.font16, 8, 8, self.width, 'left')
        lg.printf(
            self.state.level.wave,
            self.font32,
            8,
            8 + self.font16:getHeight(),
            self.width,
            'left'
        )
    end

    -- 残り時間
    if self.state.level:hasWaveTime() then
        love.graphics.setColor(1, 1, 1)
        lg.printf(math.floor(self.state.level:getWaveTime()), self.font32, 0, 0, self.width, 'center')
    end

    -- 敵
    if self.state.level:getMaxSpawn() > 0 then
        love.graphics.setColor(1, 1, 1)
        lg.printf('ENEMIES', self.font16, -8, 8, self.width, 'right')
        lg.printf(
            self.state.level:getMaxSpawn() - (self.state.level:getNumSpawned() - #self.state.level:getEnemies()),
            self.font32,
            -8,
            8 + self.font16:getHeight(),
            self.width,
            'right'
        )
    end

    -- 死亡
    if self.state.youdied[4] > 0 then
        -- 死亡表示，操作
        lg.setColor(unpack(self.state.youdied))
        lg.printf('YOU DIED', self.font64, 0, (self.height - self.font64:getHeight()) * 0.5, self.width, 'center')

        -- キー入力表示
        if self.state.visiblePressAnyKey and not self.state.action then
            lg.printf('PRESS ANY KEY', self.font32, 0, self.height - self.font32:getHeight(), self.width, 'center')
        end
    end

    -- ゲームオーバー操作
    if self:isPlayable() and self:isGameOver() then
        -- ゲームオーバー演出開始
        self.musics.ingame:stop()
        self.sounds.gameover:seek(0)
        self.sounds.gameover:play()
        self.state.gameover = true
        self.state.action = true
        self.state.timer:tween(
            1,
            self.state.youdied,
            { [4] = 1 },
            'in-out-cubic',
            function ()
                self.state.timer:every(
                    0.5,
                    function ()
                        self.state.visiblePressAnyKey = not self.state.visiblePressAnyKey
                    end
                )
                self.state.action = false
            end
        )
        self.state.timer:tween(
            1,
            self.state.fade2,
            { [4] = 0.5 },
            'in-out-cubic'
        )
    end

    -- フェード
    if self.state.fade[4] > 0 then
        lg.setColor(unpack(self.state.fade))
        lg.rectangle('fill', 0, 0, self.width, self.height)
    end
end

-- キー入力
function Game:keypressed(key, scancode, isrepeat)
    if not self.state.action and self.state.gameover then
        -- ゲームオーバーからレベル選択へ
        self.state.action = true
        self.state.timer:tween(
            1,
            self.state.fade,
            { [4] = 1 },
            'in-out-cubic',
            function ()
                -- クリアウェーブの更新
                if self.state.level.wave > 0 then
                    local clearWave = self.state.level.wave - 1
                    if self.clearWave[self.selectedLevel] == nil then
                        self.clearWave[self.selectedLevel] = clearWave
                    elseif clearWave > self.clearWave[self.selectedLevel] then
                        self.clearWave[self.selectedLevel] = clearWave
                    end
                end
                self:gotoState 'select'
            end
        )

        -- ＳＥ
        self.sounds.back:seek(0)
        self.sounds.back:play()
    end
end

-- マウス入力
function Game:mousepressed(x, y, button, istouch, presses)
    if not self.state.action and self.state.gameover then
        self:keypressed('space')
    end
end

-- デバッグモード設定
function Game:setDebug(enable)
    self.debug = enable
    self.state.level:setDebug(enable)
end

-- ゲームオーバー判定
function Game:isGameOver()
    local gameover = true
    if #self.state.level:getPlayers() > 0 then
        gameover = false
    elseif #self.state.level:getFriends() > 0 then
        gameover = false
    end
    return gameover
end

-- プレイ可能かどうか
function Game:isPlayable()
    return not self.state.gameover and not self.state.action
end

-- プレイヤー操作
function Game:controlPlayer()
    local player = self.state.player

    -- プレイヤーがノンアクティブなら操作しない
    if not self:isPlayable() or not player:isActive() then
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

            -- ＳＥ
            self.sounds.fire:seek(0)
            self.sounds.fire:play()

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
            do
                local fx, fy = cx + rx, cy + ry
                local colliders = self.state.level.world:queryLine(cx, cy, fx, fy, { 'All', except = { 'player', 'friend' } })
                local nearestDist = player:getWeaponRange() * 2
                local nearest
                for _, collider in ipairs(colliders) do
                    local entity = collider:getObject()
                    if entity and entity.alive then
                        local dist = lume.distance(cx, cy, entity.x, entity.y)
                        if dist < nearestDist and player:watchPoint(entity.x, entity.y, {'enemy', 'friend'}) then
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
            end

            -- 音エフェクト
            if self.debug then
                local sound = { circle = { 'line', cx, cy, player:getWeaponSound() }, color = { 1.0, 1.0, 0, 0.5 }}
                table.insert(self.state.sounds, sound)
                self.state.timer:tween(
                    0.1,
                    sound.color,
                    { [4] = 0 },
                    'in-out-cubic',
                    function ()
                        lume.remove(self.state.sounds, sound)
                    end
                )
            end

            -- 音を出す
            do
                local colliders = self.state.level.world:queryCircleArea(cx, cy, player:getWeaponSound(), { 'All', except = { 'player', 'friend' } })
                for _, collider in ipairs(colliders) do
                    local entity = collider:getObject()
                    if entity and entity.alive then
                        entity:hear(player)
                    end
                end
            end
        elseif player:canReloadWeapon() then
            -- リロード
            player:reloadWeapon(1, function (p) p:resetSprite() end)
            player:resetSprite()

            -- ＳＥ
            self.sounds.reload:seek(0)
            self.sounds.reload:play()
        end
    elseif input:pressed('reload') and player:canReloadWeapon() then
        -- リロード
        player:reloadWeapon(1, function (p) p:resetSprite() end)
        player:resetSprite()

        -- ＳＥ
        self.sounds.reload:seek(0)
        self.sounds.reload:play()
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
