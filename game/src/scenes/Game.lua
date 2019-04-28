
local lume = require 'lume'
local wf = require 'windfield'
local sti = require 'sti'

-- エイリアス
local lg = love.graphics
local lk = love.keyboard
local lm = love.mouse

-- クラス
local Scene = require 'Scene'
local Character = require 'Character'
local Level = require 'Level'
local Camera = require 'Camera'

-- ゲーム
local Game = Scene:newState 'game'

-- 読み込み
function Game:load()
    self.state.camera = Camera()
    self.state.camera:setFollowStyle('NO_DEADZONE')

    self.state.level = Level()

    self.state.map = sti('assets/levels/prototype.lua')
    --self.state.map:addCustomLayer('entity')

    self.state.character = self.state.level:registerEntity(
        Character {
            spriteSheet = self.spriteSheet,
            spriteName = 'hitman1_gun.png',
            x = self.width * 0.5,
            y = self.height * 0.5,
            h_align = 'center',
            collider = self.state.level.world:newCircleCollider(0, 0, 12)
        }
    )
    self.state.character.collider:setCollisionClass('player')

    self.state.entities = {}
    for i = 0, 5 do
        local entity = self.state.level:registerEntity(
            Character {
                spriteSheet = self.spriteSheet,
                spriteName = 'zoimbie1_hold.png',
                x = 300 + i * 50,
                y = self.height * 0.75,
                h_align = 'center',
                collider =self.state.level.world:newCircleCollider(0, 0, 12)
            }
        )
        entity.collider:setMass(10)
        entity.collider:setLinearDamping(10)
        entity.collider:setAngularDamping(10)
        entity.collider:setCollisionClass('enemy')
    end

    self.state.box = self.state.level.world:newRectangleCollider(100, 100, 100, 100)
    self.state.box:setRestitution(0.8)
    self.state.box:setLinearDamping(20)
    self.state.box:setAngularDamping(10)
    self.state.box:setCollisionClass('enemy')
    --self.state.box:setFixedRotation(true)
    self.state.box:setType('static')

    self.state.box2 = self.state.level.world:newRectangleCollider(300, 100, 100, 100)
    self.state.box2:setRestitution(0.8)
    self.state.box2:setLinearDamping(10)
    self.state.box2:setAngularDamping(10)
    self.state.box2:setMass(20)
    self.state.box2:setCollisionClass('enemy')
end

-- ステート開始
function Game:enteredState(...)
    -- 親
    Scene.enteredState(self, ...)
end

-- ステート終了
function Game:exitedState(...)
end

-- 更新
function Game:update(dt)
    -- プレイヤー操作
    local speed = 300
    local x, y = 0, 0
    if lk.isDown('w') or lk.isDown('up') then
        y = -1
    elseif lk.isDown('s') or lk.isDown('down') then
        y = 1
    end
    if lk.isDown('a') or lk.isDown('left') then
        x = -1
    elseif lk.isDown('d') or lk.isDown('right') then
        x = 1
    end
    self.state.character:setColliderVelocity(x, y, speed)
    self.state.character:setRotationTo(self:getMousePosition())

    -- レベル更新
    self.state.level:update(dt)

    -- カメラ更新
    self.state.camera:update(dt)
    self.state.camera:follow(self.state.character:position())

    self.state.map:update(dt)
end

-- 描画
function Game:draw()
    -- カメラ内描画
    self.state.camera:attach()
    do
        self.state.map:draw(-self.state.camera.x, -self.state.camera.y, self.state.camera.scale)

        -- レベル描画
        self.state.level:draw()

        -- マウスポインタ描画
        local cx, cy = self.state.character:position()
        local mx, my = self:getMousePosition()
        lg.line(cx, cy, mx, my)
    end
    self.state.camera:detach()

    -- カメラ描画
    self.state.camera:draw()
end

-- キー入力
function Game:keypressed(key, scancode, isrepeat)
    if key == 'space' then
        self.state.box:applyLinearImpulse(1000, 0)
        --self.state.character.collider:applyLinearImpulse(10, 0)
    end
end

-- マウス入力
function Game:mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        local cx, cy = self.state.character:position()
        local mx, my = (x - cx) * 10000 + cx, (y - cy) * 10000 + cy
        local colliders = self.state.level.world:queryLine(cx, cy, mx, my, { 'All', except = { 'Player' } })
        for _, collider in ipairs(colliders) do
            --print(tostring(collider))
            --collider:applyLinearImpulse(lume.vector(lume.angle(cx, cy, collider:getPosition()), 3000))
            local entity = collider:getObject()
            if entity then
                self.state.level:deregisterEntity(entity)
            end
        end
    end
end

-- マウスのワールド座標を返す
function Game:getMousePosition()
    return self.state.camera:toWorldCoords(lm.getPosition())
end

return Game
