
-- グローバルに影響があるライブラリ
require 'autobatch'
require 'sbss'
require 'scenes'

-- シーンクラス
local Scene = require 'Scene'

-- シーン
local scene

-- ステートの描画フラグ
local printStates = true

-- 読み込み
function love.load()
    -- シーンの作成とロード
    scene = Scene()
    scene:gotoState 'boot'
end

-- 更新
function love.update(dt)
    -- シーンの更新
    scene:update(dt)
end

-- 描画
function love.draw()
    -- 画面のリセット
    love.graphics.reset()

    -- シーンの描画
    scene:draw()

    -- ステートの描画
    if printStates then
        love.graphics.setColor(1, 1, 1)
        scene:printStates()
    end
end

-- キー入力
function love.keypressed(key, scancode, isrepeat)
    if key == 'escape' then
        -- 終了
        love.event.quit()
    elseif key == 'f5' then
        -- リスタート
        love.event.quit('restart')
    elseif key == 'f12' then
        -- ステートの描画
        printStates = not printStates
    else
        -- シーンに処理を渡す
        scene:keypressed(key, scancode, isrepeat)
    end
end

-- マウス入力
function love.mousepressed(...)
    -- シーンに処理を渡す
    scene:mousepressed(...)
end
