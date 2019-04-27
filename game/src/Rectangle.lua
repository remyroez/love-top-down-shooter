
-- 矩形モジュール
local Rectangle = {}

-- 横アライメントの割合
local hAligns = {
    left = 0,
    center = 0.5,
    right = 1
}

-- 縦アライメントの割合
local vAligns = {
    top = 0,
    middle = 0.5,
    bottom = 1
}

-- アライメントのオフセットを取得
local function alignOffsets(w, h, h_align, v_align)
    local x, y = 0, 0
    w = w or 0
    h = h or 0

    -- 横アライメントのデフォルトは left
    h_align = h_align or 'left'

    --横アライメントのみ center が指定されていれば、縦アライメントは middle
    if h_align == 'center' and v_align == nil then
        v_align = 'middle'
    end

    -- 縦アライメントのデフォルトは top
    v_align = v_align or 'top'

    -- 横アライメント
    if type(h_align) == 'number' then
        -- 数値ならそのまま渡す
        x = h_align
    else
        x = w * hAligns[h_align]
    end

    -- 縦アライメント
    if type(v_align) == 'number' then
        -- 数値ならそのまま渡す
        y = v_align
    else
        y = h * vAligns[v_align]
    end

    return x, y
end

-- 初期化
function Rectangle:initializeRectangle(x, y, w, h, h_align, v_align)
    self.x = x or self.x or 0
    self.y = y or self.y or 0
    self.width = w or self.width or 0
    self.height = h or self.height or 0

    local pivotX, pivotY = alignOffsets(self.width, self.height, h_align, v_align)
    self.pivotX = h_align and pivotX or self.pivotX
    self.pivotY = (h_align == 'center' or v_align) and pivotY or self.pivotY

    -- プライベート
    self._rectangle = {}
end

-- 矩形の描画
function Rectangle:drawRectangle()
    love.graphics.rectangle('line', self:left(), self:top(), self:right() - self:left(), self:bottom() - self:top())
end

-- 左端の座標
function Rectangle:left()
    return self.x - self.pivotX
end

-- 右端の座標
function Rectangle:right()
    return self:left() + self.width
end

-- 横の中心の座標
function Rectangle:center()
    return self:left() + self.width * 0.5
end

-- 上端の座標
function Rectangle:top()
    return self.y - self.pivotY
end

-- 下端の座標
function Rectangle:bottom()
    return self:top() + self.height
end

-- 縦の中心の座標
function Rectangle:middle()
    return self:top() + self.height * 0.5
end

return Rectangle
