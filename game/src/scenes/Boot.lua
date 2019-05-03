
local Scene = require 'Scene'

-- エイリアス
local lg = love.graphics
local la = love.audio

-- ブート
local Boot = Scene:newState 'boot'

-- 次のステートへ
function Boot:nextState(...)
    self:gotoState 'splash'
end

-- 読み込み
function Boot:load()
    -- 画面のサイズ
    local width, height = lg.getDimensions()
    self.width = width
    self.height = height

    -- スプライトシートの読み込み
    self.spriteSheet = sbss:new('assets/spritesheet.xml')

    -- 照準
    self.crosshair = lg.newImage('assets/crosshair038.png')

    -- 音楽
    local musics = {
        ingame = 'assets/Space Cadet.ogg',
        outgame = 'assets/Sad Descent.ogg',
    }
    self.musics = {}
    for name, path in pairs(musics) do
        self.musics[name] = love.audio.newSource(path, 'static')
        self.musics[name]:setLooping(true)
        self.musics[name]:setVolume(0.5)
    end

    -- ＳＥ
    local sounds = {
        gameover = 'assets/Serious ident.ogg',
    }
    self.sounds = {}
    for name, path in pairs(sounds) do
        self.sounds[name] = love.audio.newSource(path, 'static')
    end

    -- フォント
    local font = 'assets/Kenney Thick.ttf'
    self.font16 = love.graphics.newFont(font, 16)
    self.font32 = love.graphics.newFont(font, 32)
    self.font64 = love.graphics.newFont(font, 64)

    -- その他
    self.selectedLevel = 1
    self.clearWave = { 1 }
end

-- 更新
function Boot:update()
    self:nextState()
end

return Boot
