
local lume = require 'lume'
local Timer = require 'Timer'

-- 武器モジュール
local Weapon = {}

-- 初期化
function Weapon:initializeWeapon(properties)
    self._weapon = {}
    self._weapon.timer = Timer()

    self:resetWeapon(properties)
end

-- 破棄
function Weapon:destroyWeapon()
    self._weapon.timer:destroy()
    self._weapon.properties = {}
end

-- 武器の再設定
function Weapon:resetWeapon(properties)
    self._weapon.timer:destroy()
    self._weapon.properties = properties or {}
    self._weapon.hasWeapon = properties and true or false
    self._weapon.ammo = self._weapon.properties.ammo or 0
end

-- 更新
function Weapon:updateWeapon(dt)
    self._weapon.timer:update(dt)
end

-- 武器を持っているかどうか
function Weapon:hasWeapon()
    return self._weapon.hasWeapon
end

-- 武器の名前
function Weapon:getWeaponName()
    return self._weapon.properties.name or 'none'
end

-- 武器のダメージ
function Weapon:getWeaponDamage()
    return self._weapon.properties.damage or 0
end

-- 武器のパワー
function Weapon:getWeaponPower()
    return self._weapon.properties.power or 0
end

-- 武器の音
function Weapon:getWeaponSound()
    return self._weapon.properties.sound or 0
end

-- 武器の残り弾数
function Weapon:getWeaponAmmo()
    return self._weapon.ammo or 0
end

-- 武器の最大弾数
function Weapon:getWeaponMaxAmmo()
    return self._weapon.properties.ammo or 0
end

-- 武器のディレイ
function Weapon:getWeaponDelay()
    return self._weapon.properties.delay or 1
end

-- 武器の射程
function Weapon:getWeaponRange()
    return self._weapon.properties.range or 0
end

-- 武器の残り弾数があるかどうか
function Weapon:hasWeaponAmmo()
    return self:getWeaponAmmo() > 0
end

-- 武器のリロードができるかどうか
function Weapon:canReloadWeapon()
    return (self:getWeaponAmmo() < self:getWeaponMaxAmmo()) and (self:getWeaponMaxAmmo() > 0)
end

-- 武器の発射
function Weapon:fireWeapon()
    self._weapon.ammo = self._weapon.ammo - 1
end

-- 武器のリロード
function Weapon:reloadWeapon(delay, action)
    self._weapon.timer:after(
        delay or 1,
        function ()
            self._weapon.ammo = self:getWeaponMaxAmmo()
            self._weapon.timer:cancel('reload')
            if type(action) == 'function' then
                action(self)
            end
        end,
        'reload'
    )
end

-- 武器のリロード中かどうか
function Weapon:isReloadingWeapon()
    return self._weapon.timer.timers.reload ~= nil
end

return Weapon
