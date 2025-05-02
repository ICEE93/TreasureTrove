-- Treasures of Azeroth Finder Plugin: Main (Indicator Arrow Around Player - Final Comments)

-- Import required libraries/modules provided by the Sylvanas environment
---@type color
local color = require("common/color")
---@type vec3
local vec3 = require("common/geometry/vector_3")

-- Load the user-defined list of exact treasure names from treasures.lua
-- It's crucial that treasures.lua exists and returns a table keyed by treasure names.
-- Load treasures.lua (Same as before)
local treasure_names_set = require("treasures")
if not treasure_names_set then
    core.log_error("Treasures of Azeroth Finder: Could not load treasures.lua!") --
    treasure_names_set = {}
end

-- Main table for the plugin's functions and data
local treasure_finder = {}
-- Table to track objects that have had their glow enabled persistently.
-- Uses the object reference itself as the key.
local tracked_glowing_treasures = {}

-- Define constant world vectors used for calculations (assuming Z-axis is up)
local world_up = vec3.new(0, 0, 1)
local world_right = vec3.new(1, 0, 0) -- Used as fallback for cross product if direction is vertical

-- Initializes all menu elements (checkboxes, sliders, etc.) for the plugin's settings.
-- Called once when the script loads.
function treasure_finder:init_menu()
    -- Use a unique prefix for element IDs to avoid conflicts with other plugins or script updates
    local id_prefix = "treasures_of_azeroth_finder_final_"
    self.menu_elements = {
        -- The main collapsible node in the Sylvanas menu for this plugin
        main_tree = core.menu.tree_node(),
        -- Master enable switch for the entire plugin
        enable = core.menu.checkbox(true, id_prefix .. "enable"),
        -- Slider to control the maximum distance to scan for treasures
        search_range = core.menu.slider_float(10.0, 200.0, 80.0, id_prefix .. "search_range"),

        -- Toggles for different visual indicators
        enable_glow = core.menu.checkbox(true, id_prefix .. "enable_glow"),       -- Toggle for persistent glow effect
        enable_arrow = core.menu.checkbox(true, id_prefix .. "enable_arrow"),     -- Toggle for the directional arrow indicator near the player
        enable_circle = core.menu.checkbox(true, id_prefix .. "enable_circle"),   -- Toggle for drawing a circle around treasures

        -- Color picker for all visual elements (glow color isn't directly affected, uses game default)
        treasure_color = core.menu.colorpicker(color.new(255, 215, 0, 220), id_prefix .. "treasure_color"),

        -- Collapsible node specifically for detailed visual settings
        visual_settings_node = core.menu.tree_node(),

        -- Settings for the arrow indicator
        arrow_offset_distance = core.menu.slider_float(0.5, 5.0, 1.5, id_prefix .. "arrow_offset_distance"), -- Controls arrow distance from player
        arrow_size_length = core.menu.slider_float(0.2, 2.0, 0.6, id_prefix .. "arrow_size_length"), -- Controls arrow indicator length
        arrow_size_width = core.menu.slider_float(0.1, 1.5, 0.4, id_prefix .. "arrow_size_width"), -- Controls arrow indicator width/base

        -- Settings for the circle indicator
        circle_radius = core.menu.slider_float(0.5, 5.0, 1.2, id_prefix .. "circle_radius"),         -- Controls circle radius around treasure
        circle_thickness = core.menu.slider_float(1.0, 30.0, 15.0, id_prefix .. "circle_thickness"), -- Controls circle line thickness
        circle_fade = core.menu.slider_float(0.5, 3.0, 1.5, id_prefix .. "circle_fade"),             -- Controls circle fade effect (if supported by circle_3d)

        -- Setting for the font size of the treasure name text
        name_font_size = core.menu.slider_int(8, 24, 14, id_prefix .. "name_font_size")
    }
end

-- Renders the plugin's menu structure within the Sylvanas main menu.
-- Called every frame the menu is open.
function treasure_finder:render_menu()
    -- Render the main collapsible node for this plugin
    self.menu_elements.main_tree:render("Treasures Finder (Exact Names)", function()
        -- Render the master enable checkbox
        self.menu_elements.enable:render("Enable Finder", "Toggle the treasure finder")

        -- Only render the rest of the options if the plugin is enabled
        if self.menu_elements.enable:get_state() then
            -- Render general settings
            self.menu_elements.search_range:render("Search Range", "Range to search for treasures (yards)")
            self.menu_elements.treasure_color:render("Treasure Visual Color", "Color for arrows, circles, and names")

            -- Header for the visual toggles section
            core.menu.header():render("Visual Toggles", color.white())
            self.menu_elements.enable_glow:render("Enable Glow (Persistent)", "Add a glow effect that stays until object disappears")
            self.menu_elements.enable_arrow:render("Enable Arrow Indicator", "Draw an arrow near player pointing to closest treasure")
            self.menu_elements.enable_circle:render("Enable Circle", "Draw a circle around treasures")

            -- Render the collapsible node for detailed visual settings
            self.menu_elements.visual_settings_node:render("Visual Settings", function()
                -- Conditionally render arrow settings
                if self.menu_elements.enable_arrow:get_state() then
                    self.menu_elements.arrow_offset_distance:render("Arrow Offset Distance", "How far the arrow appears from the player")
                    self.menu_elements.arrow_size_length:render("Arrow Length", "Length of the indicator arrow")
                    self.menu_elements.arrow_size_width:render("Arrow Width", "Width of the indicator arrow base")
                end

                -- Conditionally render circle settings
                if self.menu_elements.enable_circle:get_state() then
                    self.menu_elements.circle_radius:render("Circle Radius", "Radius of the circle around treasures")
                    self.menu_elements.circle_thickness:render("Circle Thickness", "Thickness of the circle")
                    self.menu_elements.circle_fade:render("Circle Fade", "Fade effect for the circle")
                end

                -- Conditionally render name font size setting (if any visual is enabled)
                if self.menu_elements.enable_glow:get_state() or self.menu_elements.enable_arrow:get_state() or self.menu_elements.enable_circle:get_state() then
                    self.menu_elements.name_font_size:render("Name Font Size", "Font size for treasure names")
                end
            end) -- End of visual_settings_node render callback
        end -- End of if plugin enabled
    end) -- End of main_tree render callback
end


-- Main logic function, called every frame by the Sylvanas core.
-- Handles finding treasures and drawing the selected visuals.
function treasure_finder:on_render()

    -- Section: Cleanup Invalid Glowing Objects
    -- Iterate through objects previously marked as glowing
    for obj_ref, _ in pairs(tracked_glowing_treasures) do
        -- If the object reference is no longer valid (object despawned/looted)
        if not obj_ref:is_valid() then
            -- Remove it from the tracking table
            tracked_glowing_treasures[obj_ref] = nil
        end
    end
    -- Basic cleanup for potential nil keys left after invalidation
    -- (This might be overly cautious but ensures table integrity)
     if next(tracked_glowing_treasures) then
         local new_tracking_table = {}
         for obj_ref, v in pairs(tracked_glowing_treasures) do
             if obj_ref then new_tracking_table[obj_ref] = v end
         end
         tracked_glowing_treasures = new_tracking_table
     end
    -- End Cleanup Section


    -- Exit early if the plugin is disabled via the menu
    if not self.menu_elements.enable:get_state() then
        return
    end

    -- Get the local player object
    local local_player = core.object_manager.get_local_player()
    -- Exit if player object is invalid (e.g., zoning, not logged in)
    if not local_player or not local_player:is_valid() then
        return
    end

    -- Get the player's current position
    local player_position = local_player:get_position()
    -- Exit if player position is unavailable
    if not player_position then
        return
    end

    -- Get current settings from the menu elements
    local search_range = self.menu_elements.search_range:get()
    local search_range_squared = search_range * search_range -- Use squared distance for cheaper checks

    -- Check which visual toggles are enabled
    local should_glow = self.menu_elements.enable_glow:get_state()
    local should_arrow = self.menu_elements.enable_arrow:get_state()
    local should_circle = self.menu_elements.enable_circle:get_state()
    -- Determine if names should be drawn (if any visual is active)
    local should_draw_name = should_glow or should_arrow or should_circle

    -- Get visual appearance settings
    local treasure_color = self.menu_elements.treasure_color:get()
    local arrow_offset = self.menu_elements.arrow_offset_distance:get()
    local arrow_length = self.menu_elements.arrow_size_length:get()
    local arrow_width = self.menu_elements.arrow_size_width:get()
    local circle_radius = self.menu_elements.circle_radius:get()
    local circle_thickness = self.menu_elements.circle_thickness:get()
    local circle_fade = self.menu_elements.circle_fade:get()
    local name_font_size = self.menu_elements.name_font_size:get()

    -- Get all game objects currently loaded in the vicinity
    local objects = core.object_manager.get_all_objects()
    -- Pre-calculate the small vertical offset vector for names
    local name_z_offset_vector = vec3.new(0, 0, 1.0)

    -- Variables to track the closest treasure for the arrow indicator
    local closest_treasure_obj = nil
    local min_distance_sq = search_range_squared + 1 -- Initialize higher than max range

    -- **** Main Object Processing Loop ****
    for _, obj in ipairs(objects) do
        -- Ensure the object reference is currently valid
        if obj:is_valid() then
            -- Get object properties
            local obj_name = obj:get_name()
            local obj_position = obj:get_position()

            -- Skip if the object's position is invalid/unavailable
            if not obj_position then
                goto continue -- Jump to the end of this loop iteration
            end

            local is_treasure = false
            local current_distance_sq = -1 -- Initialize distance marker

            -- Check if the object's name is in our predefined treasure list
            if obj_name and treasure_names_set[obj_name] then
                 -- Calculate squared distance for efficiency
                 current_distance_sq = player_position:squared_dist_to(obj_position)
                 -- Check if within range and not too close (avoids issues with player self)
                 if current_distance_sq <= search_range_squared and current_distance_sq > 0.01 then
                     is_treasure = true
                 end
            end

            -- If this object is a valid treasure within range
            if is_treasure then
                -- Handle Persistent Glow: Apply once and track
                if should_glow then
                    if not tracked_glowing_treasures[obj] then -- Check if not already tracked
                        obj:set_glow(true) -- Turn glow on
                        tracked_glowing_treasures[obj] = true -- Add to tracking table
                    end
                end

                -- Draw Circle (if enabled)
                if should_circle then
                    core.graphics.circle_3d(obj_position, circle_radius, treasure_color, circle_thickness, circle_fade)
                end

                -- Draw Name (if any visual is enabled)
                if should_draw_name and obj_name then
                     -- Calculate position slightly above the object using vector addition
                     local text_pos = obj_position + name_z_offset_vector
                     core.graphics.text_3d(obj_name, text_pos, name_font_size, treasure_color, true)
                end

                -- Update Closest Treasure: Check if this treasure is closer than the current closest
                if current_distance_sq < min_distance_sq then
                    min_distance_sq = current_distance_sq
                    closest_treasure_obj = obj -- Update the reference to the closest object
                end
            end -- End if is_treasure
        end -- End if obj:is_valid()
        ::continue:: -- Target label for the goto skip
    end -- **** End of Main Object Processing Loop ****


    -- **** Draw Indicator Arrow Section ****
    -- Only draw if the arrow toggle is enabled AND we found at least one treasure
    if should_arrow and closest_treasure_obj then
        -- Get the position of the closest treasure found
        -- Re-get position in case the object moved slightly between loop and here
        local target_pos = closest_treasure_obj:get_position()

        -- Ensure the closest object still has a valid position
        if target_pos then
            -- Calculate the normalized direction vector from player to target
            local direction = (target_pos - player_position):normalize()

            -- Calculate the base point of the arrow indicator, offset from the player
            local arrow_base = player_position + (direction * arrow_offset)
            -- Calculate the tip point of the arrow indicator
            local tip = arrow_base + (direction * arrow_length)

            -- Calculate a vector perpendicular to the direction vector for the arrow wings
            local perp_vec = direction:cross(world_up)
            -- If the direction is vertical, cross product with 'up' yields zero; use 'right' instead
            if perp_vec:dot(perp_vec) < 0.001 then -- Use dot product check
                perp_vec = direction:cross(world_right)
            end
            perp_vec = perp_vec:normalize() -- Ensure the perpendicular vector is unit length

            -- Calculate the points for the base of the arrow head (wings)
            local wing1 = arrow_base + (perp_vec * arrow_width * 0.5) -- Offset by half width
            local wing2 = arrow_base - (perp_vec * arrow_width * 0.5) -- Offset by half width

            -- Draw the filled triangle representing the arrow indicator
            core.graphics.triangle_3d_filled(tip, wing1, wing2, treasure_color)
        end -- End if target_pos valid
    end -- **** End of Arrow Drawing Section ****

end -- End of on_render function


-- Registers the plugin's functions with the Sylvanas core callbacks.
-- Called once when the script loads.
function treasure_finder:register()
    -- Register the on_render function to be called every frame for drawing/logic
    core.register_on_render_callback(function() self:on_render() end)
    -- Register the render_menu function to be called when the Sylvanas menu is open
    core.register_on_render_menu_callback(function() self:render_menu() end)
end

-- Script Initialization Section
treasure_finder:init_menu() -- Create the menu elements
treasure_finder:register()  -- Register the core callbacks

-- Attempt to integrate with the Settings Manager common module to save/load menu settings
local settings_manager = require("common/modules/settings_manager")
if settings_manager then
    -- Attach the menu elements table to the settings manager with a unique key
    settings_manager:attach(treasure_finder.menu_elements, "treasures_of_azeroth_finder_indicator")
else
    -- Log a warning if the settings manager module isn't found
    core.log_warning("Treasures Finder: Settings Manager module not found. Settings will not be saved.")
end

-- Return the main plugin table (standard practice for Lua modules)
return treasure_finder