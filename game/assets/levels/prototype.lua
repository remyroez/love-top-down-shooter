return {
  version = "1.2",
  luaversion = "5.1",
  tiledversion = "1.2.3",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 18,
  height = 17,
  tilewidth = 64,
  tileheight = 64,
  nextlayerid = 5,
  nextobjectid = 16,
  properties = {},
  tilesets = {
    {
      name = "tilesheet",
      firstgid = 1,
      filename = "../../../art/tilesheet.tsx",
      tilewidth = 64,
      tileheight = 64,
      spacing = 0,
      margin = 0,
      columns = 27,
      image = "../tilesheet.png",
      imagewidth = 1728,
      imageheight = 1280,
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 64,
        height = 64
      },
      properties = {},
      terrains = {
        {
          name = "grass",
          tile = 0,
          properties = {}
        },
        {
          name = "white-line",
          tile = 39,
          properties = {}
        },
        {
          name = "yellow-line",
          tile = 32,
          properties = {}
        },
        {
          name = "soil",
          tile = 4,
          properties = {}
        }
      },
      tilecount = 540,
      tiles = {
        {
          id = 0,
          terrain = { 0, 0, 0, 0 },
          probability = 0.25
        },
        {
          id = 1,
          terrain = { 0, 0, 0, 0 },
          probability = 0.25
        },
        {
          id = 2,
          terrain = { 0, 0, 0, 0 },
          probability = 0.25
        },
        {
          id = 3,
          terrain = { 0, 0, 0, 0 },
          probability = 0.25
        },
        {
          id = 4,
          terrain = { 3, 3, 3, 3 },
          probability = 0.5
        },
        {
          id = 5,
          terrain = { 3, 3, 3, 3 },
          probability = 0.5
        },
        {
          id = 6,
          probability = 0.5
        },
        {
          id = 7,
          probability = 0.5
        },
        {
          id = 27,
          terrain = { -1, 2, -1, 2 }
        },
        {
          id = 28,
          terrain = { 2, -1, 2, -1 }
        },
        {
          id = 29,
          terrain = { -1, -1, 2, 2 }
        },
        {
          id = 30,
          terrain = { 2, 2, 2, -1 }
        },
        {
          id = 31,
          terrain = { 2, 2, -1, 2 }
        },
        {
          id = 32,
          terrain = { -1, -1, -1, 2 }
        },
        {
          id = 33,
          terrain = { -1, -1, 2, -1 }
        },
        {
          id = 34,
          terrain = { -1, 1, -1, 1 }
        },
        {
          id = 35,
          terrain = { 1, -1, 1, -1 }
        },
        {
          id = 36,
          terrain = { -1, -1, 1, 1 }
        },
        {
          id = 37,
          terrain = { 1, 1, 1, -1 }
        },
        {
          id = 38,
          terrain = { 1, 1, -1, 1 }
        },
        {
          id = 39,
          terrain = { -1, -1, -1, 1 }
        },
        {
          id = 40,
          terrain = { -1, -1, 1, -1 }
        },
        {
          id = 56,
          terrain = { 2, 2, -1, -1 }
        },
        {
          id = 57,
          terrain = { 2, -1, 2, 2 }
        },
        {
          id = 58,
          terrain = { -1, 2, 2, 2 }
        },
        {
          id = 59,
          terrain = { -1, 2, -1, -1 }
        },
        {
          id = 60,
          terrain = { 2, -1, -1, -1 }
        },
        {
          id = 63,
          terrain = { 1, 1, -1, -1 }
        },
        {
          id = 64,
          terrain = { 1, -1, 1, 1 }
        },
        {
          id = 65,
          terrain = { -1, 1, 1, 1 }
        },
        {
          id = 66,
          terrain = { -1, 1, -1, -1 }
        },
        {
          id = 67,
          terrain = { 1, -1, -1, -1 }
        },
        {
          id = 85,
          terrain = { 2, 2, 2, 2 }
        },
        {
          id = 92,
          terrain = { 1, 1, 1, 1 }
        },
        {
          id = 128,
          objectGroup = {
            type = "objectgroup",
            name = "",
            visible = true,
            opacity = 1,
            offsetx = 0,
            offsety = 0,
            draworder = "index",
            properties = {},
            objects = {
              {
                id = 1,
                name = "",
                type = "",
                shape = "rectangle",
                x = 5,
                y = 5,
                width = 54,
                height = 54,
                rotation = 0,
                visible = true,
                properties = {}
              }
            }
          }
        },
        {
          id = 180,
          objectGroup = {
            type = "objectgroup",
            name = "",
            visible = true,
            opacity = 1,
            offsetx = 0,
            offsety = 0,
            draworder = "index",
            properties = {},
            objects = {
              {
                id = 1,
                name = "",
                type = "",
                shape = "ellipse",
                x = 32,
                y = 32,
                width = 64,
                height = 64,
                rotation = 0,
                visible = true,
                properties = {}
              }
            }
          }
        },
        {
          id = 181,
          objectGroup = {
            type = "objectgroup",
            name = "",
            visible = true,
            opacity = 1,
            offsetx = 0,
            offsety = 0,
            draworder = "index",
            properties = {},
            objects = {
              {
                id = 1,
                name = "",
                type = "",
                shape = "ellipse",
                x = -32,
                y = 32,
                width = 64,
                height = 64,
                rotation = 0,
                visible = true,
                properties = {}
              }
            }
          }
        }
      }
    }
  },
  layers = {
    {
      type = "tilelayer",
      id = 1,
      name = "ground",
      x = 0,
      y = 0,
      width = 18,
      height = 17,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      chunks = {
        {
          x = 0, y = -16, width = 16, height = 16,
          data = {
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            40, 37, 37, 41, 40, 37, 41, 40, 37, 41, 40, 37, 41, 0, 0, 0
          }
        },
        {
          x = -16, y = 0, width = 16, height = 16,
          data = {
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 40,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 35,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 35,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 35,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 67,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
          }
        },
        {
          x = 0, y = 0, width = 16, height = 16,
          data = {
            35, 93, 93, 36, 35, 93, 36, 35, 93, 36, 35, 93, 36, 0, 0, 0,
            67, 64, 64, 40, 66, 38, 68, 35, 93, 36, 67, 39, 65, 41, 0, 0,
            37, 37, 37, 66, 93, 65, 37, 66, 93, 65, 41, 67, 64, 68, 0, 0,
            95, 95, 93, 38, 39, 38, 64, 64, 64, 39, 36, 33, 30, 34, 0, 0,
            92, 90, 93, 36, 35, 36, 33, 30, 34, 35, 36, 28, 86, 29, 0, 0,
            93, 93, 93, 36, 67, 68, 28, 86, 29, 35, 36, 28, 86, 29, 0, 0,
            64, 39, 93, 36, 0, 0, 60, 57, 61, 35, 36, 60, 32, 58, 34, 0,
            0, 35, 93, 36, 0, 40, 41, 0, 0, 67, 68, 0, 28, 86, 29, 0,
            0, 35, 93, 36, 0, 67, 68, 33, 30, 34, 0, 33, 59, 31, 61, 0,
            0, 67, 64, 68, 0, 0, 0, 28, 86, 29, 0, 28, 86, 29, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 60, 57, 61, 0, 60, 57, 61, 0, 0,
            4, 3, 3, 2, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 1, 3, 1, 3, 3, 1, 3, 0, 0, 6, 6, 5, 5, 5, 6,
            4, 1, 1, 3, 3, 1, 2, 1, 0, 0, 5, 5, 5, 5, 6, 5,
            0, 0, 1, 4, 2, 4, 1, 0, 0, 0, 0, 5, 5, 5, 6, 6,
            0, 0, 0, 0, 4, 2, 0, 0, 0, 0, 0, 5, 5, 6, 5, 5
          }
        },
        {
          x = 16, y = 0, width = 16, height = 16,
          data = {
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
          }
        }
      }
    },
    {
      type = "tilelayer",
      id = 4,
      name = "interior",
      x = 0,
      y = 0,
      width = 18,
      height = 17,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      chunks = {}
    },
    {
      type = "objectgroup",
      id = 2,
      name = "object",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      draworder = "topdown",
      properties = {},
      objects = {
        {
          id = 15,
          name = "",
          type = "",
          shape = "rectangle",
          x = 420,
          y = 366,
          width = 64,
          height = 64,
          rotation = 0,
          gid = 129,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
