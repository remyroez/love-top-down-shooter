
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

-- ゲーム
local Game = Scene:newState 'game'

-- バインドする入力
local bindInputs = {
    up = { 'w', 'up', 'dpup' },
    down = { 's', 'down', 'dpdown' },
    left = { 'a', 'left', 'dpleft' },
    right = { 'd', 'right', 'dpright' },
    fire = { 'mouse1', 'space', 'fdown' },
}

-- 読み込み
function Game:load()
    self.state.input = Input()
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
    self.state.camera:setFollowLerp(0.1)
    self.state.camera:setFollowLead(2)
    self.state.camera:setFollowStyle('TOPDOWN_TIGHT')
    self.state.camera.scale = 1

    -- レベル
    self.state.level = Level('assets/levels/prototype.lua')
    self.state.level:resizeMapCanvas(self.width, self.height, self.state.camera.scale)
    self.state.level:setupCharacters(self.spriteSheet)
    --self.state.level:setupSpawners(self.spriteSheet)

    -- プレイヤー
    self.state.character = self.state.level:getPlayer() or self.state.level:registerEntity(
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
    self.state.character.onDamage = function (character)
        self.state.camera:flash(0.1, { 1, 0, 0, 0.5 })
        self.state.camera:shake(8, 0.2, 60)
    end
end

-- ステート終了
function Game:exitedState(...)
    self.state.input:unbindAll()
    self.state.level:destroy()
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

        -- マウスポインタ描画
        local mx, my = self:getMousePosition()
        lg.line(cx, cy, mx, my)
    end
    self.state.camera:detach()

    -- カメラ描画
    self.state.camera:draw()

    -- ライフ
    do
        love.graphics.setColor(1, 1, 1)
        lg.printf('LIFE: ', 0, self.height - 16, self.width, 'left')
        local color = { lume.color('#ffffff') }
        local rate = self.state.character.life / self.state.character.lifeMax
        if rate <= 0.3 then
            color = { lume.color('rgb(255, 0, 0)') }
        elseif rate <= 0.5 then
            color = { lume.color('rgb(255, 255, 0)') }
        end
        love.graphics.setColor(color)
        lg.printf(self.state.character.life, 32, self.height - 16, self.width, 'left')
    end

    -- 座標（デバッグ）
    love.graphics.setColor(1, 1, 1)
    lg.printf('x: ' .. math.ceil(cx) .. ', y: ' .. math.ceil(cy), 0, self.height - 16, self.width, 'right')
end

-- キー入力
function Game:keypressed(key, scancode, isrepeat)
    if key == 'space' then
    end
end

-- プレイヤー操作
function Game:controlPlayer()
    -- プレイヤーがノンアクティブなら操作しない
    if not self.state.character:isActive() then
        return
    end

    local input = self.state.input

    -- 移動
    local speed = 300
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
    self.state.character:setColliderVelocity(x, y, speed)
    self.state.character:setRotationTo(self:getMousePosition())

    -- 射撃
    if input:pressed('fire') then
        self.state.camera:shake(8, 0.1, 60)

        local cx, cy = self:getPlayerPosition()
        local mx, my = self:getMousePosition()
        local fx, fy = (mx - cx) * 1000 + cx, (my - cy) * 1000 + cy
        local colliders = self.state.level.world:queryLine(cx, cy, fx, fy, { 'All', except = { 'player', 'friend' } })
        for _, collider in ipairs(colliders) do
            local entity = collider:getObject()
            if entity and entity.alive then
                entity:damage(self.state.character:getWeaponDamage(), self.state.character.rotation, self.state.character:getWeaponPower())
                --entity:gotoState 'dying'
                --self.state.level:deregisterEntity(entity)
            end
        end
    end
end

-- プレイヤーのワールド座標を返す
function Game:getPlayerPosition()
    return self.state.character:getPosition()
end

-- マウスのワールド座標を返す
function Game:getMousePosition()
    return self.state.camera:toWorldCoords(lm.getPosition())
end

return Game
