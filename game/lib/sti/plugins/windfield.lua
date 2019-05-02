--- windfield plugin for STI
-- @module windfield
-- @author remyroez
-- @copyright 2019
-- @license MIT/X11

local love  = _G.love
local utils = require((...):gsub('plugins.windfield', 'utils'))
local lg    = require((...):gsub('plugins.windfield', 'graphics'))
local wf = rawget(_G, "windfield") or require((...):gsub('sti.plugins.windfield', "windfield"))

local function UUID()
    local fn = function(x)
        local r = love.math.random(16) - 1
        r = (x == "x") and (r + 1) or (r % 4) + 9
        return ("0123456789abcdef"):sub(r, r)
    end
    return (("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"):gsub("[xy]", fn))
end

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

		local function addObjectToWorld(objshape, vertices, userdata, object, baseObj)
			local collider

			local objprop = object and object.properties or {}
			local baseobjprop = baseObj and baseObj.properties or {}

			if objshape == "polyline" then
				if #vertices == 4 then
					collider = world:newLineCollider(unpack(vertices))
				else
					collider = world:newChainCollider(vertices, false)
				end
			else
				collider = world:newPolygonCollider(vertices)
			end

			if userdata.properties.dynamic == true --[[or objprop.dynamic == true]] then
				collider:setType('dynamic')
			else
				collider:setType('kinematic')
			end

			collider:setFriction(userdata.properties.friction or objprop.friction or baseobjprop.friction or 0.2)
			collider:setRestitution(userdata.properties.restitution or objprop.restitution or baseobjprop.restitution or 0.0)
			collider:setLinearDamping(userdata.properties.linearDamping or objprop.linearDamping or baseobjprop.linearDamping or 0.0)
			collider:setAngularDamping(userdata.properties.angularDamping or objprop.angularDamping or baseobjprop.angularDamping or 0.0)
			--collider:setSensor(userdata.properties.sensor           or false)
			--collider:setMass(userdata.properties.mass or objprop.mass or baseobjprop.mass or collider:getMass())
			collider:setCollisionClass(userdata.properties.class or objprop.class or baseobjprop.class or 'object')

			local obj = {
				object   = object,
				baseObj  = baseObj,
				collider = collider,
				userdata = userdata,
			}

			collider:setObject(obj)

			table.insert(collision, obj)

			return obj
		end

		local function getPolygonVertices(object)
			local vertices = {}
			for _, vertex in ipairs(object.polygon) do
				table.insert(vertices, vertex.x)
				table.insert(vertices, vertex.y)
			end

			return vertices
		end

		local function calculateObjectPosition(object, tile, baseTile, parent)
			local o = {
				shape   = object.shape,
				x       = (object.dx or object.x) + map.offsetx,
				y       = (object.dy or object.y) + map.offsety,
				w       = object.width,
				h       = object.height,
				polygon = object.polygon or object.polyline or object.ellipse or object.rectangle,
				r       = object.drotation or object.rotation or 0,
				oy      = object.oy or 0,
				t       = object.tile,
				sub     = object.sub
			}

			local addedObj

			local userdata = {
				object     = o,
				properties = object.properties
			}
			local oy = 0

			if o.shape == "rectangle" then
				oy  = 0

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
						local first
						for _, obj in ipairs(t.objectGroup.objects) do
							local tileobj = {
								shape      = obj.shape,
								x          = obj.x,
								y          = obj.y,
								dx         = obj.x + object.x,
								dy         = obj.y + object.y,
								width      = obj.width,
								height     = obj.height,
								polygon    = obj.polygon,
								polyline   = obj.polyline,
								ellipse    = obj.ellipse,
								rectangle  = obj.rectangle,
								properties = obj.properties,
								rotation   = obj.rotation,
								drotation  = obj.rotation + o.r,
								original = obj,
								oy = o.h,
								tile = tile,
								sub = true,
							}
							-- Every object in the tile
							if first == nil then
								addedObj = calculateObjectPosition(tileobj, object, tile)
								first = addedObj
							else
								calculateObjectPosition(tileobj, object, tile, first)
							end
						end

						return addedObj
					else
						oy = 0
						o.w = map.tiles[object.gid].width
						o.h = map.tiles[object.gid].height
					end
				end

				-- local coords
				local baseX = 0
				local baseY = 0
				local baseR = 0
				local o_x = o.x
				local o_y = o.y
				local o_r = o.r
				local ofs = 0
				if o.sub and not o.t and tile then
					baseX, baseY, baseR = object.x, object.y, object.rotation
					o_x, o_y, o_r = tile.x, tile.y, tile.rotation
					oy = tile.height
					ofs = -tile.height
				end

				local polygon = {
					{ x=baseX+0,   y=baseY+0   },
					{ x=baseX+o.w, y=baseY+0   },
					{ x=baseX+o.w, y=baseY+o.h },
					{ x=baseX+0,   y=baseY+o.h }
				}

				-- local rotate
				if baseR ~= 0 then
					local bcos = math.cos(math.rad(baseR))
					local bsin = math.sin(math.rad(baseR))
					for _, vertex in ipairs(polygon) do
						vertex.x, vertex.y = utils.rotate_vertex(map, vertex, 0, 0, bcos, bsin)
					end
				end

				if parent then
					parent.collider:addShape(UUID(), 'PolygonShape', unpack(polygon))
					return
				end

				local cos = math.cos(math.rad(o_r))
				local sin = math.sin(math.rad(o_r))
				for _, vertex in ipairs(polygon) do
					vertex.y = vertex.y + ofs
					vertex.x, vertex.y = utils.rotate_vertex(map, vertex, 0, 0, cos, sin, oy)
					vertex.x = vertex.x + o_x
					vertex.y = vertex.y + o_y - ofs
				end

				local vertices = getPolygonVertices({ polygon = polygon })
				addedObj = addObjectToWorld(o.shape, vertices, userdata, tile or object, baseTile)
			elseif o.shape == "ellipse" then
				local cos = math.cos(math.rad(o.r))
				local sin = math.sin(math.rad(o.r))
				-- local coords
				local baseX = 0
				local baseY = 0
				local baseR = 0
				local o_x = o.x
				local o_y = o.y
				local o_r = o.r
				local ofs = 0
				if o.sub and not o.t and tile then
					baseX, baseY, baseR = object.x, object.y, object.rotation
					o_x, o_y, o_r = tile.x, tile.y, tile.rotation
					oy = tile.height
					ofs = -tile.height
				end
				if not o.polygon then
					o.polygon = utils.convert_ellipse_to_polygon(baseX, baseY, o.w, o.h, 32)
					for _, vertex in ipairs(o.polygon) do
						vertex.y = vertex.y + ofs
						vertex.x, vertex.y = utils.rotate_vertex(map, vertex, 0, 0, cos, sin, oy)
						vertex.x = vertex.x + o_x
						vertex.y = vertex.y + o_y - ofs
					end
				end
				local vertices  = getPolygonVertices(o)
				local triangles = love.math.triangulate(vertices)

				addedObj = addObjectToWorld(o.shape, triangles[1], userdata, tile or object, baseTile)
				for i, triangle in ipairs(triangles) do
					if i > 1 then
						addedObj.collider:addShape(tostring(i), 'PolygonShape', unpack(triangle))
					end
				end
			elseif o.shape == "polygon" then
				local polygon = {}
				for _, vertex in ipairs(o.polygon) do
					table.insert(polygon, { x = vertex.x, y = vertex.y } )
				end

				-- Recalculate collision polygons inside tiles
				if tile then
					-- local coords
					local o_x = o.x
					local o_y = o.y
					local o_r = o.r
					local ofs = 0
					if o.sub and not o.t and tile then
						local baseX, baseY, baseR = object.x, object.y, object.rotation
						o_x, o_y, o_r = tile.x, tile.y, tile.rotation
						oy = tile.height
						ofs = -tile.height
						local bcos = math.cos(math.rad(baseR))
						local bsin = math.sin(math.rad(baseR))
						for _, vertex in ipairs(polygon) do
							vertex.x, vertex.y = utils.rotate_vertex(map, vertex, 0, 0, bcos, bsin)
							vertex.x = vertex.x + baseX
							vertex.y = vertex.y + baseY
						end
					end
					local cos = math.cos(math.rad(o_r))
					local sin = math.sin(math.rad(o_r))
					for _, vertex in ipairs(polygon) do
						vertex.y = vertex.y + ofs
						vertex.x, vertex.y = utils.rotate_vertex(map, vertex, 0, 0, cos, sin, oy)
						vertex.x = vertex.x + o_x
						vertex.y = vertex.y + o_y - ofs
					end
				end

				local vertices  = getPolygonVertices({ polygon = polygon })
				local triangles = love.math.triangulate(vertices)

				addedObj = addObjectToWorld(o.shape, triangles[1], userdata, tile or object, baseTile)
				for i, triangle in ipairs(triangles) do
					if i > 1 then
						addedObj.collider:addShape(tostring(i), 'PolygonShape', unpack(triangle))
					end
				end
			elseif o.shape == "polyline" then
				local vertices = getPolygonVertices(o)
				addedObj = addObjectToWorld(o.shape, vertices, userdata, tile or object, baseTile)
			end

			return addedObj
		end

		for _, layer in ipairs(map.layers) do
			-- Entire layer
			local layer_collidable = layer.properties.collidable == true
			if layer.type == "tilelayer" then
				for gid, tiles in pairs(map.tileInstances) do
					local tile = map.tiles[gid]
					local tileset = map.tilesets[tile.tileset]

					for _, instance in ipairs(tiles) do
						if instance.layer == layer then
							if layer_collidable or (tile.properties.collidable == true) then
								local object = {
									shape      = "rectangle",
									x          = instance.x,
									y          = instance.y,
									width      = tileset.tilewidth,
									height     = tileset.tileheight,
									properties = tile.properties,
									gid = gid
								}

								calculateObjectPosition(object, instance)
							end
						end
					end
				end
			elseif layer.type == "objectgroup" then
				for _, object in ipairs(layer.objects) do
					if layer_collidable or (object.properties.collidable == true) then
						calculateObjectPosition(object)
					end
				end
			elseif layer.type == "imagelayer" then
				if layer_collidable then
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

	windfield_update = function(map, dt)
		--[[
		local updateLayers = {}
		for _, collision in ipairs(map.windfield_collision) do
			if collision.object.layer and collision.object.layer.type == 'objectgroup' and collision.object.gid then
				local x, y = collision.collider:getPosition()
				if x ~= collision.object.x or y ~= collision.object.y then
					print(collision.object.x, collision.object.y, x, y)
					--collision.object.x, collision.object.y = x, y
					local found = false
					for _, layer in ipairs(updateLayers) do
						if collision.object.layer == layer then
							found = true
							break
						end
					end
					if not found then
						table.insert(updateLayers, collision.object.layer)
					end
				end
			end
		end
		for _, layer in ipairs(updateLayers) do
			map:setObjectSpriteBatches(layer)
		end
		--]]
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
