
-- エイリアス
local lg = love.graphics

-- トランスフォームモジュール
local Transform = {}

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

-- アライメントのピボットを取得
local function alignPivots(h_align, v_align)
    local x, y = 0, 0

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
        x = hAligns[h_align]
    end

    -- 縦アライメント
    if type(v_align) == 'number' then
        -- 数値ならそのまま渡す
        y = v_align
    else
        y = vAligns[v_align]
    end

    return x, y
end

-- 初期化
function Transform:initializeTransform(x, y, rotation, scale, pivotX, pivotY)
    self.x = x or self.x or 0
    self.y = y or self.y or 0
    self.rotation = rotation or self.rotation or 0
    self.scale = scale or self.scale or 1
    self:setPivot(pivotX, pivotY)

    -- プライベート
    self._transform = {}
end

-- ピボット
function Transform:setPivot(pivotX, pivotY)
    self.pivotX = pivotX or self.pivotX or 0
    self.pivotY = pivotY or self.pivotY or 0
end

-- 回転
function Transform:rotate(rotation)
    rotation = rotation or 0
    self.rotation = self.rotation + rotation
    while self.rotation > (math.pi * 2) do
        self.rotation = self.rotation - (math.pi * 2)
    end
end

-- トランスフォームを積む
function Transform:pushTransform(x, y)
    x = x or self.x
    y = y or self.y

    lg.push()
    lg.translate(math.ceil(x), math.ceil(y))
    lg.translate(self.pivotX, self.pivotY)
    lg.rotate(self.rotation)
    lg.scale(self.scale)
    lg.translate(-self.pivotX, -self.pivotY)
end

-- トランスフォームを除く
function Transform:popTransform()
    lg.pop()
end

return Transform
