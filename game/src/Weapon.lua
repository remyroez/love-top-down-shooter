
local lume = require 'lume'

-- 武器モジュール
local Weapon = {}

-- 初期化
function Weapon:initializeWeapon(properties)
    self._weapon = {}

    self:resetWeapon(properties)
end

-- 破棄
function Weapon:destroyWeapon()
    self._weapon.properties = {}
end

-- 武器の再設定
function Weapon:resetWeapon(properties)
    self._weapon.properties = properties or {}
    self._weapon.properties.hasWeapon = properties and true or false
end

-- 武器を持っているかどうか
function Weapon:hasWeapon()
    return self._weapon.properties.hasWeapon
end

-- 武器の名前
function Weapon:getWeaponName()
    return self._weapon.properties.name or 'none'
end

-- 武器のダメージ
function Weapon:getWeaponDamage()
    return self._weapon.properties.damage or 0
end

return Weapon
