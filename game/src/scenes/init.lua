
local folderOfThisFile = (...):gsub("%.init$", "") .. "."

local scenes = {}

local states = {
    "Boot",
    "Splash",
    "Title",
    "Game"
}

for _, name in ipairs(states) do
    scenes[name] = require(folderOfThisFile .. name)
end

return states
