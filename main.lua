-- File: Sylvanas docs/TreasureTrove/main.lua
-- Treasures of Azeroth Finder Plugin: Main (Improved Glow Logic)

---@type color
local color = require("common/color")
---@type vec3
local vec3 = require("common/geometry/vector_3")
local plugin_helper = require("common/utility/plugin_helper")
-- Load treasures.lua
local treasure_names_set = require("treasures")
if not treasure_names_set then
    core.log_error("Treasures Finder Error: Could not load treasures.lua or it's not returning a table!") -- 
    treasure_names_set = {}
end

local role = core.get_user_role_flags()
if role == false then
core.log_error("role: " .. tostring(role)) else
core.log_warning("role: " .. tostring(role)) end

-- Load War Within herb names
local ww_herb_names_set = require("ww_herbs")
if not ww_herb_names_set then
    core.log_error("Treasures Finder Error: Could not load ww_herbs.lua or it's not returning a table!") -- 
    ww_herb_names_set = {}
end

-- Load War Within ore names
local ww_ore_names_set = require("ww_ores")
if not ww_ore_names_set then
    core.log_error("Treasures Finder Error: Could not load ww_ores.lua or it's not returning a table!") -- 
    ww_ore_names_set = {}
end

local treasure_finder = {}
local tracked_glowing_objects = {} -- Stores obj_ref -> true for objects that *should* be glowing

local world_up = vec3.new(0, 0, 1)
local world_right = vec3.new(1, 0, 0)

treasure_finder.update_counter = 0 
-- treasure_finder.process_every_n_updates = 3 -- Set by menu

function treasure_finder:init_menu()
    local id_prefix = "treasures_resources_finder_v2.4_" -- Incremented prefix
    self.menu_elements = {
        main_tree = core.menu.tree_node(),
        enable = core.menu.checkbox(true, id_prefix .. "enable"),
        search_range = core.menu.slider_float(10.0, 200.0, 80.0, id_prefix .. "search_range"),
        process_frequency = core.menu.slider_int(1, 10, 3, id_prefix .. "process_frequency"),
        
        visual_toggles_node = core.menu.tree_node(),

        enable_treasures = core.menu.checkbox(true, id_prefix .. "enable_treasures"),
        treasure_color = core.menu.colorpicker(color.new(255, 215, 0, 220), id_prefix .. "treasure_color"), -- 

        enable_herbs = core.menu.checkbox(true, id_prefix .. "enable_herbs"),
        enable_ores = core.menu.checkbox(true, id_prefix .. "enable_ores"),

        enable_glow = core.menu.checkbox(true, id_prefix .. "enable_glow"),
        enable_arrow = core.menu.checkbox(true, id_prefix .. "enable_arrow"),
        enable_multi_arrow_gatherables = core.menu.checkbox(true, id_prefix .. "enable_multi_arrow_gatherables"),
        enable_single_arrow_treasure = core.menu.checkbox(true, id_prefix .. "enable_single_arrow_treasure"),
        enable_circle = core.menu.checkbox(true, id_prefix .. "enable_circle"),

        visual_settings_node = core.menu.tree_node(),
        arrow_offset_distance = core.menu.slider_float(0.5, 5.0, 1.5, id_prefix .. "arrow_offset_distance"),
        arrow_size_length = core.menu.slider_float(0.2, 2.0, 0.6, id_prefix .. "arrow_size_length"),
        arrow_size_width = core.menu.slider_float(0.1, 1.5, 0.4, id_prefix .. "arrow_size_width"),
        circle_radius = core.menu.slider_float(0.5, 5.0, 1.2, id_prefix .. "circle_radius"),
        circle_thickness = core.menu.slider_float(1.0, 30.0, 15.0, id_prefix .. "circle_thickness"),
        circle_fade = core.menu.slider_float(0.5, 3.0, 1.5, id_prefix .. "circle_fade"),
        name_font_size = core.menu.slider_int(8, 34, 18, id_prefix .. "name_font_size")
    }
    if self.menu_elements.process_frequency then
        treasure_finder.process_every_n_updates = self.menu_elements.process_frequency:get()
    else
        treasure_finder.process_every_n_updates = 3 -- Fallback default
    end
end

function treasure_finder:render_menu()
    if not self.menu_elements or not self.menu_elements.main_tree then 
        return 
    end

    self.menu_elements.main_tree:render("Treasure & Resource Finder", function()
        if not self.menu_elements.enable or not self.menu_elements.search_range or not self.menu_elements.process_frequency then return end
        self.menu_elements.enable:render("Enable Finder", "Toggle all finding features")
        if self.menu_elements.enable:get_state() then
            self.menu_elements.search_range:render("Search Range", "Range to search (yards)")
            
            if self.menu_elements.process_frequency:render("Scan Frequency (1=Max, 10=Min)", "Process objects every Nth update cycle. Higher value = less CPU.") then
                 treasure_finder.process_every_n_updates = self.menu_elements.process_frequency:get() 
            end

            if not self.menu_elements.enable_treasures or not self.menu_elements.enable_herbs or not self.menu_elements.enable_ores then return end
            core.menu.header():render("Trackable Types", color.white(255))
            self.menu_elements.enable_treasures:render("Enable Treasure Tracking", "Track objects from treasures.lua")
            if self.menu_elements.enable_treasures:get_state() and self.menu_elements.treasure_color then
                 self.menu_elements.treasure_color:render("   Treasure Visual Color", "Color for treasure visuals")
            end
            self.menu_elements.enable_herbs:render("Enable War Within Herb Tracking (Green)", "Track War Within herbs")
            self.menu_elements.enable_ores:render("Enable War Within Ore Tracking (Blue)", "Track War Within ores")
            
            if not self.menu_elements.enable_glow or not self.menu_elements.enable_circle or not self.menu_elements.enable_arrow then return end
            core.menu.header():render("Common Visual Toggles", color.white(255))
            self.menu_elements.enable_glow:render("Enable Glow (Persistent)", "Add a glow effect")
            self.menu_elements.enable_circle:render("Enable Circle", "Draw a circle around enabled trackables")
            
            core.menu.header():render("Arrow Settings", color.white(255))
            self.menu_elements.enable_arrow:render("Enable Arrows (Master Toggle)", "Master toggle for all arrow indicators")
            if self.menu_elements.enable_arrow:get_state() then
                if not self.menu_elements.enable_multi_arrow_gatherables or not self.menu_elements.enable_single_arrow_treasure then return end
                self.menu_elements.enable_multi_arrow_gatherables:render("  Multiple Arrows for Herbs/Ores", "Show individual arrows for each nearby herb/ore")
                self.menu_elements.enable_single_arrow_treasure:render("  Single Arrow for Closest Treasure", "Show one arrow for the closest treasure")
            end
            
            if not self.menu_elements.visual_settings_node then return end
            self.menu_elements.visual_settings_node:render("Detailed Visual Settings", function()
                if not self.menu_elements.arrow_offset_distance or not self.menu_elements.arrow_size_length or not self.menu_elements.arrow_size_width or
                   not self.menu_elements.circle_radius or not self.menu_elements.circle_thickness or not self.menu_elements.circle_fade or
                   not self.menu_elements.name_font_size then return end

                if self.menu_elements.enable_arrow:get_state() then
                    self.menu_elements.arrow_offset_distance:render("Arrow Offset Distance", "How far arrows appear from the player")
                    self.menu_elements.arrow_size_length:render("Arrow Length", "Length of indicator arrows")
                    self.menu_elements.arrow_size_width:render("Arrow Width", "Width of indicator arrow bases")
                end
                if self.menu_elements.enable_circle:get_state() then
                    self.menu_elements.circle_radius:render("Circle Radius", "Radius of the circle around trackables")
                    self.menu_elements.circle_thickness:render("Circle Thickness", "Thickness of the circle")
                    self.menu_elements.circle_fade:render("Circle Fade", "Fade effect for the circle")
                end
                if self.menu_elements.enable_glow:get_state() or self.menu_elements.enable_arrow:get_state() or self.menu_elements.enable_circle:get_state() then
                    self.menu_elements.name_font_size:render("Name Font Size", "Font size for trackable names")
                end
            end)
        end
    end)
end

treasure_finder.trackables_for_render = {} 
treasure_finder.closest_treasure = {obj = nil, dist_sq = -1, position = nil} 

function treasure_finder:on_update()
    if not self.menu_elements or not self.menu_elements.enable or not self.menu_elements.process_frequency then 
        return 
    end

    if not self.menu_elements.enable:get_state() then
        if #self.trackables_for_render > 0 then 
            self.trackables_for_render = {}
        end
        self.closest_treasure = {obj = nil, dist_sq = -1, position = nil}
        -- Turn off all glows if script is disabled
        for obj_ref, _ in pairs(tracked_glowing_objects) do
            if obj_ref and obj_ref:is_valid() then
                obj_ref:set_glow(false)
            end
        end
        tracked_glowing_objects = {}
        return
    end

    self.update_counter = self.update_counter + 1
    
    local process_frequency_val = self.menu_elements.process_frequency:get()
    if self.update_counter < process_frequency_val then
        return 
    end
    self.update_counter = 0 

    local local_player = core.object_manager.get_local_player()
    if not local_player or not local_player:is_valid() then
        self.trackables_for_render = {}
        self.closest_treasure = {obj = nil, dist_sq = -1, position = nil}
        return
    end

    local player_position = local_player:get_position()
    if not player_position then
        self.trackables_for_render = {}
        self.closest_treasure = {obj = nil, dist_sq = -1, position = nil}
        return
    end
    
    if not self.menu_elements.search_range or 
       not self.menu_elements.enable_treasures or 
       not self.menu_elements.enable_herbs or 
       not self.menu_elements.enable_ores or 
       not self.menu_elements.enable_glow then
        return
    end

    local search_range = self.menu_elements.search_range:get()
    local search_range_squared = search_range * search_range

    local current_trackables = {}
    local temp_closest_treasure_dist_sq = search_range_squared + 1 
    local temp_closest_treasure_obj = nil
    local temp_closest_treasure_position = nil

    local objects = core.object_manager.get_all_objects()
    
    local should_track_treasures = self.menu_elements.enable_treasures:get_state()
    local should_track_herbs = self.menu_elements.enable_herbs:get_state()
    local should_track_ores = self.menu_elements.enable_ores:get_state()
    local should_glow_globally_enabled = self.menu_elements.enable_glow:get_state()
    
    local new_tracked_glows_this_scan = {} -- Temp table for glows identified in this scan

    for _, obj in ipairs(objects) do
        if obj:is_valid() then
            local obj_name = obj:get_name()
            local obj_position = obj:get_position()

            if obj_name and obj_position then
                local dist_sq = player_position:squared_dist_to(obj_position)

                if dist_sq <= search_range_squared and dist_sq > 0.01 then 
                    local object_type = nil
                    if should_track_treasures and treasure_names_set[obj_name] then
                        object_type = "treasure"
                    elseif should_track_herbs and ww_herb_names_set[obj_name] then
                        object_type = "herb"
                    elseif should_track_ores and ww_ore_names_set[obj_name] then
                        object_type = "ore"
                    end

                    if object_type and (obj:can_be_looted() or obj:can_be_used()) then
                        table.insert(current_trackables, {
                            obj_ref = obj, 
                            type = object_type, 
                            name = obj_name, 
                            position = obj_position
                        })

                        if object_type == "treasure" then
                            if dist_sq < temp_closest_treasure_dist_sq then
                                temp_closest_treasure_dist_sq = dist_sq
                                temp_closest_treasure_obj = obj
                                temp_closest_treasure_position = obj_position
                            end
                        end
                        
                        if should_glow_globally_enabled then
                            if not obj:is_glow() then -- Only set glow if not already glowing (minor optimization) 
                                obj:set_glow(true) -- 
                            end
                            new_tracked_glows_this_scan[obj] = true 
                        end
                    end
                end
            end
        end
    end
    self.trackables_for_render = current_trackables
    self.closest_treasure = {obj = temp_closest_treasure_obj, dist_sq = temp_closest_treasure_dist_sq, position = temp_closest_treasure_position}

    -- Manage glows: Turn off glows for objects no longer in our new_tracked_glows_this_scan but were previously glowing
    if should_glow_globally_enabled then
        for obj_ref, _ in pairs(tracked_glowing_objects) do
            if not new_tracked_glows_this_scan[obj_ref] then
                if obj_ref and obj_ref:is_valid() then
                    obj_ref:set_glow(false)
                end
            end
        end
        tracked_glowing_objects = new_tracked_glows_this_scan
    elseif next(tracked_glowing_objects) then -- If glow was just disabled globally
        for obj_ref, _ in pairs(tracked_glowing_objects) do
            if obj_ref and obj_ref:is_valid() then
                obj_ref:set_glow(false)
            end
        end
        tracked_glowing_objects = {}
    end
end

function treasure_finder:on_render()
    if not self.menu_elements or not self.menu_elements.enable or 
       not self.menu_elements.enable_arrow or 
       not self.menu_elements.enable_multi_arrow_gatherables or 
       not self.menu_elements.enable_single_arrow_treasure or
       not self.menu_elements.enable_circle or 
       not self.menu_elements.name_font_size or
       not self.menu_elements.treasure_color or
       not self.menu_elements.arrow_offset_distance or 
       not self.menu_elements.arrow_size_length or
       not self.menu_elements.arrow_size_width or
       not self.menu_elements.circle_radius or
       not self.menu_elements.circle_thickness or
       not self.menu_elements.circle_fade
       then
        return 
    end

    -- Glow cleanup for objects that become invalid/unlootable between on_update scans
    -- or if glow setting is toggled off globally.
    local should_glow_globally_enabled_render = self.menu_elements.enable_glow:get_state()
    if not should_glow_globally_enabled_render and next(tracked_glowing_objects) then
         for obj_ref, _ in pairs(tracked_glowing_objects) do
            if obj_ref and obj_ref:is_valid() then
                obj_ref:set_glow(false)
            end
        end
        tracked_glowing_objects = {}
    elseif should_glow_globally_enabled_render then
        local still_glowing_this_frame = {}
        for obj_ref, _ in pairs(tracked_glowing_objects) do
            if obj_ref and obj_ref:is_valid() and (obj_ref:can_be_looted() or obj_ref:can_be_used()) then
                -- Further check if it's still a type we want to glow based on current menu settings
                local obj_name_render = obj_ref:get_name()
                local type_should_glow = false
                if self.menu_elements.enable_treasures:get_state() and treasure_names_set[obj_name_render] then type_should_glow = true end
                if not type_should_glow and self.menu_elements.enable_herbs:get_state() and ww_herb_names_set[obj_name_render] then type_should_glow = true end
                if not type_should_glow and self.menu_elements.enable_ores:get_state() and ww_ore_names_set[obj_name_render] then type_should_glow = true end

                if type_should_glow then
                    still_glowing_this_frame[obj_ref] = true
                else
                    obj_ref:set_glow(false)
                end
            else
                 if obj_ref and obj_ref:is_valid() then obj_ref:set_glow(false) end
            end
        end
        tracked_glowing_objects = still_glowing_this_frame
    end


    if not self.menu_elements.enable:get_state() then
        return
    end

    local local_player = core.object_manager.get_local_player()
    if not local_player or not local_player:is_valid() then
        return
    end
    local player_position = local_player:get_position()
    if not player_position then return end

    local master_arrow_enabled = self.menu_elements.enable_arrow:get_state()
    local multi_arrow_gatherables = master_arrow_enabled and self.menu_elements.enable_multi_arrow_gatherables:get_state()
    local single_arrow_treasure = master_arrow_enabled and self.menu_elements.enable_single_arrow_treasure:get_state()
    
    local should_circle = self.menu_elements.enable_circle:get_state() 
    local name_font_size = self.menu_elements.name_font_size:get()
    local name_z_offset_vector = vec3.new(0, 0, 4.0) 
    
    local default_treasure_color = self.menu_elements.treasure_color:get()
    local herb_color = color.green(220)
    local ore_color = color.blue(220)

    local arrow_offset_dist = self.menu_elements.arrow_offset_distance:get()
    local arrow_len = self.menu_elements.arrow_size_length:get()
    local arrow_wid = self.menu_elements.arrow_size_width:get()

    for _, trackable in ipairs(self.trackables_for_render) do
        if trackable.obj_ref and trackable.obj_ref:is_valid() then
            local current_visual_color
            local is_gatherable = false

            if trackable.type == "treasure" then
                current_visual_color = default_treasure_color
            elseif trackable.type == "herb" then
                current_visual_color = herb_color
                is_gatherable = true
            elseif trackable.type == "ore" then
                current_visual_color = ore_color
                is_gatherable = true
            else
                goto continue_render_loop 
            end

            if should_circle then
                core.graphics.circle_3d(trackable.position, self.menu_elements.circle_radius:get(), current_visual_color, self.menu_elements.circle_thickness:get(), self.menu_elements.circle_fade:get())
            end

            if trackable.name then
                 local text_pos = trackable.position + name_z_offset_vector
                 core.graphics.text_3d(trackable.name, text_pos, name_font_size, current_visual_color, true)
            end

            if is_gatherable and multi_arrow_gatherables then
                local direction = (trackable.position - player_position):normalize()
                local arrow_base = player_position + (direction * arrow_offset_dist)
                local tip = arrow_base + (direction * arrow_len)
                local perp_vec = direction:cross(world_up)
                if perp_vec:dot(perp_vec) < 0.001 then perp_vec = direction:cross(world_right) end
                perp_vec = perp_vec:normalize()
                local wing1 = arrow_base + (perp_vec * arrow_wid * 0.5)
                local wing2 = arrow_base - (perp_vec * arrow_wid * 0.5)
                core.graphics.triangle_3d_filled(tip, wing1, wing2, current_visual_color)
            end
        end
        ::continue_render_loop::
    end

    if single_arrow_treasure and self.closest_treasure.obj and self.closest_treasure.obj:is_valid() and self.closest_treasure.position then
        local closest_treasure_pos = self.closest_treasure.position 
        local arrow_color = default_treasure_color
        
        local direction = (closest_treasure_pos - player_position):normalize()
        local arrow_base = player_position + (direction * arrow_offset_dist)
        local tip = arrow_base + (direction * arrow_len)
        local perp_vec = direction:cross(world_up)
        if perp_vec:dot(perp_vec) < 0.001 then perp_vec = direction:cross(world_right) end
        perp_vec = perp_vec:normalize()
        local wing1 = arrow_base + (perp_vec * arrow_wid * 0.5)
        local wing2 = arrow_base - (perp_vec * arrow_wid * 0.5)
        core.graphics.triangle_3d_filled(tip, wing1, wing2, arrow_color)
    end
end

function treasure_finder:register()
    core.register_on_update_callback(function() self:on_update() end)
    core.register_on_render_callback(function() self:on_render() end)
    core.register_on_render_menu_callback(function() self:render_menu() end)
end

treasure_finder:init_menu() 
treasure_finder:register()  

local settings_manager = require("common/modules/settings_manager")
if settings_manager then
    settings_manager:attach(treasure_finder.menu_elements, "treasures_resources_finder_v2.4") 
else
    core.log_warning("Treasures Finder: Settings Manager module not found. Settings will not be saved.") -- 
end

return treasure_finder