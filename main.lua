-- Treasures of Azeroth Finder Plugin: Main (Exact Name Matching - Persistent Glow Fix)

---@type color
local color = require("common/color")
---@type vec3
local vec3 = require("common/geometry/vector_3")

-- Attempt to load the treasure list, handle potential errors
local treasure_names_set = require("treasures") -- Assumes treasures.lua is in the script path
if not treasure_names_set then
    core.log_error("Treasures of Azeroth Finder: Could not load treasures.lua!") --
    treasure_names_set = {} -- Use an empty table to prevent errors later
end

local treasure_finder = {}
-- Store references to objects we have successfully set to glow
-- Using the object reference as the key for quick lookups
local tracked_glowing_treasures = {}

-- Define menu elements (Same as before)
function treasure_finder:init_menu()
    local id_prefix = "treasures_of_azeroth_finder_persist_" -- Updated prefix slightly
    self.menu_elements = {
        main_tree = core.menu.tree_node(), --
        enable = core.menu.checkbox(true, id_prefix .. "enable"), --
        search_range = core.menu.slider_float(10.0, 200.0, 80.0, id_prefix .. "search_range"), --
        enable_glow = core.menu.checkbox(true, id_prefix .. "enable_glow"), --
        enable_line = core.menu.checkbox(true, id_prefix .. "enable_line"), --
        enable_circle = core.menu.checkbox(true, id_prefix .. "enable_circle"), --
        treasure_color = core.menu.colorpicker(color.new(255, 215, 0, 220), id_prefix .. "treasure_color"), --
        line_thickness = core.menu.slider_float(1.0, 10.0, 2.0, id_prefix .. "line_thickness"), --
        circle_radius = core.menu.slider_float(0.5, 5.0, 1.2, id_prefix .. "circle_radius"), --
        circle_thickness = core.menu.slider_float(1.0, 30.0, 15.0, id_prefix .. "circle_thickness"), --
        circle_fade = core.menu.slider_float(0.5, 3.0, 1.5, id_prefix .. "circle_fade"), --
        name_font_size = core.menu.slider_int(8, 24, 14, id_prefix .. "name_font_size") --
    }
end

-- Render menu (Same as before)
function treasure_finder:render_menu()
    self.menu_elements.main_tree:render("Treasures Finder (Exact Names)", function() --
        self.menu_elements.enable:render("Enable Finder", "Toggle the treasure finder") --

        if self.menu_elements.enable:get_state() then --
            self.menu_elements.search_range:render("Search Range", "Range to search for treasures (yards)") --
            self.menu_elements.treasure_color:render("Treasure Visual Color", "Color for lines, circles, glows, and names") --

            core.menu.header():render("Visual Toggles", color.white()) --
            self.menu_elements.enable_glow:render("Enable Glow (Persistent)", "Add a glow effect that stays until object disappears") -- Changed tooltip
            self.menu_elements.enable_line:render("Enable Line", "Draw a line from player to treasures") --
            self.menu_elements.enable_circle:render("Enable Circle", "Draw a circle around treasures") --

            core.menu.header():render("Visual Settings", color.white()) --
            if self.menu_elements.enable_line:get_state() then --
                 self.menu_elements.line_thickness:render("Line Thickness", "Thickness of the line") --
            end

            if self.menu_elements.enable_circle:get_state() then --
                self.menu_elements.circle_radius:render("Circle Radius", "Radius of the circle around treasures") --
                self.menu_elements.circle_thickness:render("Circle Thickness", "Thickness of the circle") --
                self.menu_elements.circle_fade:render("Circle Fade", "Fade effect for the circle") --
            end

            if self.menu_elements.enable_glow:get_state() or self.menu_elements.enable_line:get_state() or self.menu_elements.enable_circle:get_state() then --
                 self.menu_elements.name_font_size:render("Name Font Size", "Font size for treasure names") --
            end
        end
    end)
end


-- Find and draw visuals for treasures (Persistent Glow Logic)
function treasure_finder:on_render()

    -- ** Cleanup Invalidated Glowing Objects **
    -- Periodically check our tracked objects and remove any that are no longer valid.
    local cleanup_needed = false
    for obj_ref, _ in pairs(tracked_glowing_treasures) do
        if not obj_ref:is_valid() then -- Check if the tracked object reference is still valid
            tracked_glowing_treasures[obj_ref] = nil -- Remove invalid reference from tracking
            cleanup_needed = true -- Flag that we modified the table while iterating (optional, but safer)
        end
    end
     -- If we need to clean up potentially nil keys, rebuild the table (simple way)
     -- Note: This might be unnecessary if Lua handles nil keys gracefully during pairs iteration,
     -- but it's safer if object references could somehow become nil without invalidating.
     if cleanup_needed then
         local new_tracking_table = {}
         for obj_ref, v in pairs(tracked_glowing_treasures) do
             if obj_ref and obj_ref:is_valid() then -- Double check validity
                 new_tracking_table[obj_ref] = v
             end
         end
         tracked_glowing_treasures = new_tracking_table
     end
    -- ** End Cleanup **


    if not self.menu_elements.enable:get_state() then --
        return -- Don't process further if the main toggle is off
    end

    local local_player = core.object_manager.get_local_player() --
    if not local_player or not local_player:is_valid() then --
        return
    end

    local player_position = local_player:get_position() --
    if not player_position then
        return
    end

    local search_range = self.menu_elements.search_range:get() --
    local search_range_squared = search_range * search_range

    local should_glow = self.menu_elements.enable_glow:get_state() --
    local should_line = self.menu_elements.enable_line:get_state() --
    local should_circle = self.menu_elements.enable_circle:get_state() --
    local should_draw_name = should_glow or should_line or should_circle

    local treasure_color = self.menu_elements.treasure_color:get() --
    local line_thickness = self.menu_elements.line_thickness:get() --
    local circle_radius = self.menu_elements.circle_radius:get() --
    local circle_thickness = self.menu_elements.circle_thickness:get() --
    local circle_fade = self.menu_elements.circle_fade:get() --
    local name_font_size = self.menu_elements.name_font_size:get() --

    local objects = core.object_manager.get_all_objects() --

    for _, obj in ipairs(objects) do
        if obj:is_valid() then --
            local obj_name = obj:get_name() --
            local obj_position = obj:get_position() --

            if not obj_position then
                goto continue -- Skip if position is nil
            end

            local is_treasure = false
            if obj_name and treasure_names_set[obj_name] then
                 local distance_squared = player_position:squared_dist_to(obj_position)
                 if distance_squared <= search_range_squared then
                     is_treasure = true
                 end
            end

            if is_treasure then
                -- Apply Glow Persistently
                if should_glow then
                    -- Check if we haven't already tracked and glowed this object
                    if not tracked_glowing_treasures[obj] then
                        obj:set_glow(true) -- Apply glow
                        tracked_glowing_treasures[obj] = true -- Track it
                    end
                end

                -- Draw Line (Non-persistent)
                if should_line then
                    core.graphics.line_3d(player_position, obj_position, treasure_color, line_thickness) --
                end

                -- Draw Circle (Non-persistent)
                if should_circle then
                    core.graphics.circle_3d(obj_position, circle_radius, treasure_color, circle_thickness, circle_fade) --
                end

                -- Draw Name (Non-persistent)
                if should_draw_name and obj_name then
                     local text_pos = obj_position:__add(vec3.new(0, 0, 1.0))
                     core.graphics.text_3d(obj_name, text_pos, name_font_size, treasure_color, true) --
                end
            end
            -- No 'else' needed to turn off glow here, persistence is handled by the cleanup loop
        end
        ::continue::
    end
end


-- Register callbacks (Same as before)
function treasure_finder:register()
    core.register_on_render_callback(function() self:on_render() end) --
    core.register_on_render_menu_callback(function() self:render_menu() end) --
end

-- Initialize and register (Same as before)
treasure_finder:init_menu()
treasure_finder:register()

-- Attach menu elements to settings manager (Same as before)
local settings_manager = require("common/modules/settings_manager")
if settings_manager then
    settings_manager:attach(treasure_finder.menu_elements, "treasures_of_azeroth_finder_persist") -- Updated save ID
else
    core.log_warning("Treasures Finder: Settings Manager module not found. Settings will not be saved.") --
end


return treasure_finder