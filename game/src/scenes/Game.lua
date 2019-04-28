
local lume = require 'lume'
local wf = require 'windfield'

-- エイリアス
local lg = love.graphics
local lk = love.keyboard
local lm = love.mouse

-- クラス
local Scene = require 'Scene'
local Character = require 'Character'

-- ゲーム
local Game = Scene:newState 'game'

-- 読み込み
function Game:load()
    self.state.world = wf.newWorld(0, 0, true)
    self.state.world:addCollisionClass('player')
    self.state.world:addCollisionClass('enemy')

    self.state.character = Character{
        spriteSheet = self.spriteSheet,
        spriteName = 'hitman1_gun.png',
        x = self.width * 0.5,
        y = self.height * 0.5,
        h_align = 'center',
        collider = self.state.world:newCircleCollider(0, 0, 12)
    }
    self.state.character.collider:setCollisionClass('player')
    self.state.box = self.state.world:newRectangleCollider(100, 100, 100, 100)
    self.state.box:setRestitution(0.8)
    self.state.box:setLinearDamping(20)
    self.state.box:setAngularDamping(10)
    self.state.box:setCollisionClass('enemy')
    --self.state.box:setFixedRotation(true)
    self.state.box:setType('static')
    self.state.box2 = self.state.world:newRectangleCollider(300, 100, 100, 100)
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
    self.state.world:update(dt)

    local speed = 100
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
    self.state.character:setRotationTo(love.mouse.getPosition())
    self.state.character:update(dt)
end

-- 描画
function Game:draw()
    self.state.character:draw()
    self.state.character:drawRectangle()
    self.state.world:draw()

    local cx, cy = self.state.character:position()
    local mx, my = lm.getPosition()
    lg.line(cx, cy, mx, my)
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
        local colliders = self.state.world:queryLine(cx, cy, mx, my, { 'All', except = { 'Player' } })
        for _, collider in ipairs(colliders) do
            print(tostring(collider))
            collider:applyLinearImpulse(lume.vector(lume.angle(cx, cy, collider:getPosition()), 3000))
        end
    end
end

return Game
