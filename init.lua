chimney_mtg = {}

local modname = ":chimney_mtg"

-- =============
-- SELECTION BOX
-- =============

local full_block_box = {
    type = "fixed",
    fixed = {
		{-1/2, -1/2, -1/2, -3/8,  1/2,  1/2},
		{ 3/8, -1/2, -1/2,  1/2,  1/2,  1/2},
		{-3/8, -1/2,  3/8,  3/8,  1/2,  1/2},
		{-3/8, -1/2, -1/2,  3/8,  1/2, -3/8},
	}
}


-- ============
-- REGISTRATION
-- ============

function chimney_mtg.register_chimney(chimney_name, chimney_def)
    local chimney_itemstring = modname .. ":chimney_" .. chimney_name
    local top_itemstring = modname .. ":chimney_top_" .. chimney_name

    local material_node_def = minetest.registered_nodes[chimney_def.material]
    if not material_node_def then
        return
    end

     local groups = {}
    if material_node_def.groups then
        for k, v in pairs(material_node_def.groups) do
            groups[k] = v
        end
    end
    groups["chimney"] = 1
    groups["cracky"] = groups["cracky"] or 3
    groups["oddly_breakable_by_hand"] = 3

    local sounds = material_node_def.sounds or {}
    local description = chimney_def.description or material_node_def.description or ""
    local first_tile = material_node_def.tiles[1]
    local main_texture = first_tile.name or first_tile
    local top_texture = chimney_def.top_texture or "default_sandstone.png"

    -- Chimney
    minetest.register_node(chimney_itemstring, {
        description = (description .. " Chimney"),
        groups = groups,
        drawtype = "mesh",
        mesh = "chimney_mtg_chimney.obj",
        tiles = {main_texture},
        sounds = sounds,
        paramtype = "light",
        paramtype2 = "facedir",
        selection_box = full_block_box,
        collision_box = full_block_box,
    })

    -- Chimney Top
    minetest.register_node(top_itemstring, {
        description = (description .. " Chimney Top"),
        groups = groups,
        drawtype = "mesh",
        mesh = "chimney_mtg_chimney_top.obj",
        tiles = {
            main_texture,
            top_texture
            },
        sounds = sounds,
        paramtype = "light",
        paramtype2 = "facedir",
        selection_box = full_block_box,
        collision_box = full_block_box,
    })

    -- Crafting Recipes
    local raw_chimney = "chimney_mtg:chimney_" .. chimney_name
    local raw_top = "chimney_mtg:chimney_top_" .. chimney_name

    minetest.register_craft({
        output = raw_chimney .. " 4",
        recipe = {
            {chimney_def.material, "", chimney_def.material},
            {chimney_def.material, "", chimney_def.material},
            {chimney_def.material, "", chimney_def.material},
        },
    })

    minetest.register_craft({
        output = raw_top .. " 2",
        recipe = {
            {chimney_def.material, raw_chimney, chimney_def.material},
        },
    })
end


-- =========
-- MATERIALS
-- =========

minetest.register_on_mods_loaded(function()
    local chimney_base_nodes = {
        { material = "default:cobble" }, -- Defaults to sandstone
        { material = "default:stonebrick" },
        { material = "default:brick" },
        -- chimney top nodes
        { material = "default:desert_cobble", top_texture = "default_desert_stone.png" },
        { material = "default:stonebrick", top_texture = "default_stone.png" },
        { material = "default:desert_stonebrick", top_texture = "default_desert_stone.png" },
        { material = "default:sandstonebrick", top_texture = "default_sandstone.png" },
        { material = "default:desert_sandstone_brick", top_texture = "default_desert_sandstone.png" },
    }

    for _, def in ipairs(chimney_base_nodes) do
        if minetest.registered_nodes[def.material] then
            local chimney_name = def.material:match(":(.+)")
            chimney_mtg.register_chimney(chimney_name, def)
        end
    end
end)


-- =========
-- FIRE LOGS
-- =========

-- Fire Logs
minetest.register_node("chimney_mtg:fire_logs", {
    description = "Fire Logs",
    drawtype = "mesh",
    mesh = "chimney_mtg_fire_logs.obj",
    tiles = {
        "chimney_mtg_iron.png",
        "chimney_mtg_fire_logs.png"
    },
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {choppy = 3, oddly_breakable_by_hand = 3},
    sounds = default.node_sound_wood_defaults(),

    selection_box = {
        type = "fixed",
        fixed = {-3/8, -1/2, -1/4, 3/8, 5/16, 5/16}
    },
    collision_box = {
        type = "fixed",
        fixed = {-3/8, -1/2, -1/4, 3/8, 5/16, 5/16}
    },

    -- IGNITE ON PUNCH WITH TORCH
    on_punch = function(pos, node, puncher, pointed_thing)
        if puncher and puncher:get_wielded_item():get_name() == "default:torch" then
            node.name = "chimney_mtg:fire_logs_burning"
            minetest.swap_node(pos, node)
            minetest.sound_play("fire_flint_and_steel", {pos = pos, gain = 0.4, max_hear_distance = 8})
        end
    end,
})

-- Burning Fire Logs
minetest.register_node("chimney_mtg:fire_logs_burning", {
    description = "Burning Fire Logs",
    drawtype = "mesh",
    mesh = "chimney_mtg_fire_logs_burning.obj",
    tiles = {
        "chimney_mtg_iron.png",
        "chimney_mtg_fire_logs.png",
        {
            name = "fire_basic_flame_animated.png",
            animation = {
                type = "vertical_frames",
                aspect_w = 16,
                aspect_h = 16,
                length = 1.0,
            },
        },
    },
    use_texture_alpha = "blend",
    paramtype = "light",
    paramtype2 = "facedir",
    light_source = 12,
    damage_per_second = 2,
    groups = {choppy = 3, oddly_breakable_by_hand = 3, igniter = 2, not_in_creative_inventory = 1},
    drop = "chimney_mtg:fire_logs",
    sounds = default.node_sound_wood_defaults(),

    selection_box = {
        type = "fixed",
        fixed = {-3/8, -1/2, -1/4, 3/8, 5/16, 5/16}
    },
    collision_box = {
        type = "fixed",
        fixed = {-3/8, -1/2, -1/4, 3/8, 5/16, 5/16}
    },

    on_punch = function(pos, node, puncher, pointed_thing)
        if puncher then
            local id = minetest.hash_node_position(pos)
            if chimney_mtg.sound_handles and chimney_mtg.sound_handles[id] then
                minetest.sound_stop(chimney_mtg.sound_handles[id])
                chimney_mtg.sound_handles[id] = nil
            end

            node.name = "chimney_mtg:fire_logs"
            minetest.swap_node(pos, node)
            minetest.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.5, max_hear_distance = 8})
        end
    end,

    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        local id = minetest.hash_node_position(pos)
        if chimney_mtg.sound_handles and chimney_mtg.sound_handles[id] then
            minetest.sound_stop(chimney_mtg.sound_handles[id])
            chimney_mtg.sound_handles[id] = nil
        end
    end,

    -- STICK ROASTING COOKING SYSTEM
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        local wielded_item = itemstack:get_name()

        local cooked = ""
        if wielded_item == "chimney_mtg:marshmallow_raw" then
            cooked = "chimney_mtg:marshmallow_toasted"
        elseif wielded_item == "chimney_mtg:sausage_raw" then
            cooked = "chimney_mtg:sausage_cooked"
        else
            return nil
        end

        if itemstack:get_count() == 1 then
            itemstack:set_name(cooked)
        else
            itemstack:take_item(1)
            local inv = clicker:get_inventory()
            local leftover = inv:add_item("main", cooked)
            if not leftover:is_empty() then
                minetest.add_item(pos, leftover)
            end
        end

        minetest.sound_play("default_cool_lava", {pos = pos, gain = 0.5}, true)
        minetest.add_particlespawner({
            amount = 8,
            time = 0.3,
            minpos = {x = pos.x - 0.1, y = pos.y + 0.4, z = pos.z - 0.1},
            maxpos = {x = pos.x + 0.1, y = pos.y + 0.5, z = pos.z + 0.1},
            minvel = {x = -0.2, y = 1.0, z = -0.2},
            maxvel = {x = 0.2, y = 1.5, z = 0.2},
            minacc = {x = 0, y = 0, z = 0},
            maxacc = {x = 0, y = 0, z = 0},
            minexptime = 0.5,
            maxexptime = 1.0,
            minsize = 1,
            maxsize = 2,
            texture = "chimney_mtg_smoke.png^[opacity:240",
        })

        return itemstack
    end
})


-- ========================================
-- ACTIVE PARTICLE MODIFIERS (SMOKE,AMBERS)
-- ========================================

chimney_mtg.sound_handles = chimney_mtg.sound_handles or {}

minetest.register_abm({
    label = "Burning Fire Logs Effects",
    nodenames = {"chimney_mtg:fire_logs_burning"},
    interval = 1.0,
    chance = 1,
    action = function(pos, node, active_object_count, active_object_count_wider)
        local id = minetest.hash_node_position(pos)
        if not chimney_mtg.sound_handles[id] then
            chimney_mtg.sound_handles[id] = minetest.sound_play("chimney_mtg_fire_logs_burning", {
                pos = pos,
                gain = 0.4,
                max_hear_distance = 12,
                loop = true
            })
        end

        minetest.add_particlespawner({
            amount = 2,
            time = 1.0,
            minpos = {x = pos.x - 0.02, y = pos.y + 0.15, z = pos.z - 0.02},
            maxpos = {x = pos.x + 0.02, y = pos.y + 0.25, z = pos.z + 0.02},
            minvel = {x = -0.02, y = 0.5, z = -0.02},
            maxvel = {x = 0.02,  y = 0.8, z = 0.02},
            minacc = {x = 0, y = 0.02, z = 0},
            maxacc = {x = 0, y = 0.05, z = 0},
            minexptime = 8.0,
            maxexptime = 10.0,
            minsize = 2.0,
            maxsize = 4.0,
            collisiondetection = true,
            collision_removal = false,
            object_collision = false,
            texture = "default_item_smoke.png^[opacity:120",
            glow = 2,
        })

        minetest.add_particlespawner({
            amount = 5,
            time = 1.0,
            minpos = {x = pos.x - 0.15, y = pos.y + 0.05, z = pos.z - 0.15},
            maxpos = {x = pos.x + 0.15, y = pos.y + 0.15, z = pos.z + 0.15},
            minvel = {x = -0.1, y = 0.3, z = -0.1},
            maxvel = {x = 0.1,  y = 0.7, z = 0.1},
            minacc = {x = -0.02, y = 0.05, z = -0.02},
            maxacc = {x = 0.02,  y = 0.15, z = 0.02},
            minexptime = 1.2,
            maxexptime = 2.2,
            minsize = 0.1,
            maxsize = 0.3,
            collisiondetection = false,
            collision_removal = false,
            object_collision = false,
            texture = "default_furnace_fire_fg.png",
            glow = 14,
        })
    end,
})


-- =====
-- TOOLS
-- =====

minetest.register_tool("chimney_mtg:whittled_stick", {
	description = "Whittled Roasting Stick",
	inventory_image = "chimney_mtg_whittled_stick.png",
})

minetest.register_craft({
	output = "chimney_mtg:whittled_stick",
	recipe = {
		{"", "", "default:stick"},
		{"", "default:stick", ""},
		{"default:stick", "", ""},
	}
})


-- =====
-- FOODS
-- =====

minetest.register_craftitem("chimney_mtg:marshmallow_raw", {
	description = "Raw Marshmallow",
	inventory_image = "chimney_mtg_marshmallow_raw.png",
})

minetest.register_craftitem("chimney_mtg:sausage_raw", {
	description = "Raw Sausage",
	inventory_image = "chimney_mtg_sausage_raw.png",

	on_use = function(itemstack, user, pointed_thing)
		if not user then return nil end

		user:set_hp(math.min(20, user:get_hp() + 2))

		itemstack:set_name("chimney_mtg:whittled_stick")
		return itemstack
	end,
})


minetest.register_craftitem("chimney_mtg:marshmallow_toasted", {
	description = "Toasted Marshmallow",
	inventory_image = "chimney_mtg_marshmallow_toasted.png",
	groups = {not_in_creative_inventory = 1},

	on_use = function(itemstack, user, pointed_thing)
		if not user then return nil end

		user:set_hp(math.min(20, user:get_hp() + 2))

		minetest.sound_play("chimney_mtg_mmm", {object = user, gain = 0.8}, true)

		itemstack:set_name("chimney_mtg:whittled_stick")
		return itemstack
	end,
})

minetest.register_craftitem("chimney_mtg:sausage_cooked", {
	description = "Cooked Sausage",
	inventory_image = "chimney_mtg_sausage_cooked.png",
	groups = {not_in_creative_inventory = 1},

	on_use = function(itemstack, user, pointed_thing)
		if not user then return nil end

		user:set_hp(math.min(20, user:get_hp() + 5))

		minetest.sound_play("chimney_mtg_mmm", {object = user, gain = 0.8}, true)

		itemstack:set_name("chimney_mtg:whittled_stick")
		return itemstack
	end,
})


minetest.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
	local itemstack = player:get_wielded_item()
	if itemstack:get_name() ~= "chimney_mtg:whittled_stick" then
		return
	end

	local listname = inventory_info.listname or inventory_info.from_list or inventory_info.to_list
	if listname ~= "main" then return end

	local index = inventory_info.index or inventory_info.from_index or inventory_info.to_index
	if not index then return end

	local clicked_stack = inventory:get_stack("main", index)
	local clicked_item = clicked_stack:get_name()

	local food_stick_version = ""
	if clicked_item == "chimney_mtg:marshmallow_raw" then
		food_stick_version = "chimney_mtg:marshmallow_raw"
	elseif clicked_item == "chimney_mtg:sausage_raw" then
		food_stick_version = "chimney_mtg:sausage_raw"
	end

	if food_stick_version ~= "" then
		clicked_stack:take_item(1)
		inventory:set_stack("main", index, clicked_stack)

		itemstack:set_name(food_stick_version)
		player:set_wielded_item(itemstack)

		minetest.sound_play("default_place_node", {object = player, gain = 0.5}, true)
	end
end)

