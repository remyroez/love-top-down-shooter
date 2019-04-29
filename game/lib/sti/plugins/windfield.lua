--- windfield plugin for STI
-- @module windfield
-- @author remyroez
-- @copyright 2019
-- @license MIT/X11

local love  = _G.love
local utils = require((...):gsub('plugins.windfield', 'utils'))
local lg    = require((...):gsub('plugins.windfield', 'graphics'))
local wf = rawget(_G, "windfield") or require((...):gsub('sti.plugins.windfield', "windfield"))

return {
	windfield_LICENSE     = "MIT/X11",
	windfield_URL         = "https://github.com/adnzzzzZ/windfield",
	windfield_VERSION     = "1.0",
	windfield_DESCRIPTION = "windfield hooks for STI.",

	--- Initialize windfield physics world.
	-- @param world The windfield world to add objects to.
	windfield_init = function(map, world)
		assert(love.physics, "To use the windfield plugin, please enable the love.physics module.")

		local collision = {
		}

		local function addObjectToWorld(objshape, vertices, userdata, object)
			local collider

			if objshape == "polyline" then
				if #vertices == 4 then
					collider = world:newLineCollider(unpack(vertices))
				else
					collider = world:newChainCollider(vertices, false)
				end
			else
				collider = world:newPolygonCollider(vertices)
			end

			if userdata.properties.dynamic == true then
				collider:setType('dynamic')
			else
				collider:setType('kinematic')
			end

			collider:setFriction(userdata.properties.friction       or 0.2)
			collider:setRestitution(userdata.properties.restitution or 0.0)
			collider:setSensor(userdata.properties.sensor           or false)
			collider:setCollisionClass(userdata.properties.class    or 'object')


			local x = (object.dx or object.x) + map.offsetx
			local y = (object.dy or object.y) + map.offsety
			--collider:setPosition(x, y)

			local obj = {
				object   = object,
				collider = collider,
				userdata = userdata,
			}

			table.insert(collision, obj)
		end

		local function getPolygonVertices(object)
			local vertices = {}
			for _, vertex in ipairs(object.polygon) do
				table.insert(vertices, vertex.x)
				table.insert(vertices, vertex.y)
			end

			return vertices
		end

		local function calculateObjectPosition(object, tile)
			local o = {
				shape   = object.shape,
				x       = (object.dx or object.x) + map.offsetx,
				y       = (object.dy or object.y) + map.offsety,
				w       = object.width,
				h       = object.height,
				polygon = object.polygon or object.polyline or object.ellipse or object.rectangle,
				r       = object.rotation or 0
			}

			local userdata = {
				object     = o,
				properties = object.properties
			}

			if o.shape == "rectangle" then
				local cos = math.cos(math.rad(o.r))
				local sin = math.sin(math.rad(o.r))
				local oy  = 0

				if object.gid then
					local tileset = map.tilesets[map.tiles[object.gid].tileset]
					local lid     = object.gid - tileset.firstgid
					local t       = {}

					-- This fixes a height issue
					 o.y = o.y + map.tiles[object.gid].offset.y
					 oy  = o.h

					for _, tt in ipairs(tileset.tiles) do
						if tt.id == lid then
							t = tt
							break
						end
					end

					if t.objectGroup then
						for _, obj in ipairs(t.objectGroup.objects) do
							local tileobj = {
								shape      = obj.shape,
								x          = obj.x + o.x - o.w / 2,
								y          = obj.y + o.y - o.h / 2,
								width      = obj.width,
								height     = obj.height,
								polygon    = obj.polygon,
								polyline   = obj.polyline,
								ellipse    = obj.ellipse,
								rectangle  = obj.rectangle,
								properties = obj.properties,
								rotation   = obj.rotation-- + o.r
							}
							-- Every object in the tile
							calculateObjectPosition(tileobj, object)
						end

						return
					else
						o.w = map.tiles[object.gid].width
						o.h = map.tiles[object.gid].height
					end
				end

				o.polygon = {
					{ x=o.x+0,   y=o.y+0   },
					{ x=o.x+o.w, y=o.y+0   },
					{ x=o.x+o.w, y=o.y+o.h },
					{ x=o.x+0,   y=o.y+o.h }
				}

				for _, vertex in ipairs(o.polygon) do
					vertex.x, vertex.y = utils.rotate_vertex(map, vertex, o.x, o.y, cos, sin, oy)
				end

				local vertices = getPolygonVertices(o)
				addObjectToWorld(o.shape, vertices, userdata, tile or object)
			elseif o.shape == "ellipse" then
				if not o.polygon then
					o.polygon = utils.convert_ellipse_to_polygon(o.x, o.y, o.w, o.h)
				end
				local vertices  = getPolygonVertices(o)
				local triangles = love.math.triangulate(vertices)

				for _, triangle in ipairs(triangles) do
					addObjectToWorld(o.shape, triangle, userdata, tile or object)
				end
			elseif o.shape == "polygon" then
				-- Recalculate collision polygons inside tiles
				if tile then
					local cos = math.cos(math.rad(o.r))
					local sin = math.sin(math.rad(o.r))
					for _, vertex in ipairs(o.polygon) do
						vertex.x = vertex.x + o.x
						vertex.y = vertex.y + o.y
						vertex.x, vertex.y = utils.rotate_vertex(map, vertex, o.x, o.y, cos, sin)
					end
				end

				local vertices  = getPolygonVertices(o)
				local triangles = love.math.triangulate(vertices)

				for _, triangle in ipairs(triangles) do
					addObjectToWorld(o.shape, triangle, userdata, tile or object)
				end
			elseif o.shape == "polyline" then
				local vertices = getPolygonVertices(o)
				addObjectToWorld(o.shape, vertices, userdata, tile or object)
			end
		end

		for _, tile in pairs(map.tiles) do
			if map.tileInstances[tile.gid] then
				for _, instance in ipairs(map.tileInstances[tile.gid]) do
					-- Every object in every instance of a tile
					if tile.objectGroup then
						for _, object in ipairs(tile.objectGroup.objects) do
							if object.properties.collidable == true then
								object.dx = instance.x + object.x
								object.dy = instance.y + object.y
								calculateObjectPosition(object, instance)
							end
						end
					end

					-- Every instance of a tile
					if tile.properties.collidable == true then
						local object = {
							shape      = "rectangle",
							x          = instance.x,
							y          = instance.y,
							width      = map.tilewidth,
							height     = map.tileheight,
							properties = tile.properties
						}

						calculateObjectPosition(object, instance)
					end
				end
			end
		end

		for _, layer in ipairs(map.layers) do
			-- Entire layer
			if layer.properties.collidable == true then
				if layer.type == "tilelayer" then
					for gid, tiles in pairs(map.tileInstances) do
						local tile = map.tiles[gid]
						local tileset = map.tilesets[tile.tileset]

						for _, instance in ipairs(tiles) do
							if instance.layer == layer then
								local object = {
									shape      = "rectangle",
									x          = instance.x,
									y          = instance.y,
									width      = tileset.tilewidth,
									height     = tileset.tileheight,
									properties = tile.properties
								}

								calculateObjectPosition(object, instance)
							end
						end
					end
				elseif layer.type == "objectgroup" then
					if object.properties.collidable == true then
						calculateObjectPosition(object)
					end
				elseif layer.type == "imagelayer" then
					local object = {
						shape      = "rectangle",
						x          = layer.x or 0,
						y          = layer.y or 0,
						width      = layer.width,
						height     = layer.height,
						properties = layer.properties
					}

					calculateObjectPosition(object)
				end
			else
				-- Individual objects
				if layer.type == "objectgroup" then
					for _, object in ipairs(layer.objects) do
						if object.properties.collidable == true then
							calculateObjectPosition(object)
						end
					end
				end
			end
		end

		map.windfield_collision = collision
	end,

	--- Remove windfield fixtures and shapes from world.
	-- @param index The index or name of the layer being removed
	windfield_removeLayer = function(map, index)
		local layer = assert(map.layers[index], "Layer not found: " .. index)
		local collision = map.windfield_collision

		-- Remove collision objects
		for i = #collision, 1, -1 do
			local obj = collision[i]

			if obj.object.layer == layer then
				obj.collider:destroy()
				table.remove(collision, i)
			end
		end
	end,

	--- Draw windfield physics world.
	-- @param tx Translate on X
	-- @param ty Translate on Y
	-- @param sx Scale on X
	-- @param sy Scale on Y
	windfield_draw = function(map, tx, ty, sx, sy)
	end
}

--- Custom Properties in Tiled are used to tell this plugin what to do.
-- @table Properties
-- @field collidable set to true, can be used on any Layer, Tile, or Object
-- @field sensor set to true, can be used on any Tile or Object that is also collidable
-- @field dynamic set to true, can be used on any Tile or Object
-- @field friction can be used to define the friction of any Object
-- @field restitution can be used to define the restitution of any Object
-- @field categories can be used to set the filter Category of any Object
-- @field mask can be used to set the filter Mask of any Object
-- @field group can be used to set the filter Group of any Object
