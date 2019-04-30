
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

-- ゲーム
local Game = Scene:newState 'game'

-- 読み込み
function Game:load()
end

-- ステート開始
function Game:enteredState(...)
    -- 親
    Scene.enteredState(self, ...)

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
end

-- ステート終了
function Game:exitedState(...)
    self.state.level:destroy()
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

    lg.printf('x: ' .. math.ceil(cx) .. ', y: ' .. math.ceil(cy), 0, self.height - 16, self.width, 'left')
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
    x, y = self.state.camera:toWorldCoords(x, y)
    if button == 1 then
        local cx, cy = self:getPlayerPosition()
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

-- プレイヤーのワールド座標を返す
function Game:getPlayerPosition()
    return self.state.character:getPosition()
end

-- マウスのワールド座標を返す
function Game:getMousePosition()
    return self.state.camera:toWorldCoords(lm.getPosition())
end

return Game
