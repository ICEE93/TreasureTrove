-- File: Sylvanas docs/TreasureTrove/ww_herbs.lua
-- War Within Herb Names
-- Includes base herbs and common names for modified versions.
-- You might need to add more specific prefixed/suffixed names if they differ in-game.

local ww_herb_names = {
    -- Base Herbs (Sources: 1.1, 1.2, 1.3, 1.4, 1.7, 3.2)
    ["Mycobloom"] = true,
    ["Blessing Blossom"] = true,
    ["Arathor's Spear"] = true,
    ["Luredrop"] = true,
    ["Orbinid"] = true,
    ["Null Lotus"] = true, -- (Source 2.2, 3.2)

    -- Common Modified Herb Names (Prefix + Base Herb Name)
    -- It's assumed the game names nodes like "Lush Mycobloom", "Irradiated Blessing Blossom", etc.
    -- If the game uses a different pattern (e.g., "Mycobloom (Lush)"), you'll need to adjust.

    -- Lush (Source 1.1)
    ["Lush Mycobloom"] = true,
    ["Lush Blessing Blossom"] = true,
    ["Lush Arathor's Spear"] = true,
    ["Lush Luredrop"] = true,
    ["Lush Orbinid"] = true,
    ["Lush Null Lotus"] = true,

    -- Irradiated (Source 1.1, 1.4, 1.8) - Drops Leyline Residue
    ["Irradiated Mycobloom"] = true,
    ["Irradiated Blessing Blossom"] = true,
    ["Irradiated Arathor's Spear"] = true,
    ["Irradiated Luredrop"] = true,
    ["Irradiated Orbinid"] = true,
    ["Irradiated Null Lotus"] = true,

    -- Crystallized (Source 1.1, 1.4, 1.8) - Drops Crystalline Powder
    ["Crystallized Mycobloom"] = true,
    ["Crystallized Blessing Blossom"] = true,
    ["Crystallized Arathor's Spear"] = true,
    ["Crystallized Luredrop"] = true,
    ["Crystallized Orbinid"] = true,
    ["Crystallized Null Lotus"] = true,

    -- Sporefused (Source 1.1, 1.4, 1.8) - Drops Viridescent Spores
    ["Sporefused Mycobloom"] = true,
    ["Sporefused Blessing Blossom"] = true,
    ["Sporefused Arathor's Spear"] = true,
    ["Sporefused Luredrop"] = true,
    ["Sporefused Orbinid"] = true,
    ["Sporefused Null Lotus"] = true,

    -- Altered (Source 1.1, 1.3, 1.4) - Drops Writhing Sample
    ["Altered Mycobloom"] = true,
    ["Altered Blessing Blossom"] = true,
    ["Altered Arathor's Spear"] = true,
    ["Altered Luredrop"] = true,
    ["Altered Orbinid"] = true,
    ["Altered Null Lotus"] = true,

    -- Camouflaged (Source 1.1, 1.2, 1.4) - Requires Phial of Truesight
    -- Only add these if you expect them to be visible when the script runs.
    ["Camouflaged Mycobloom"] = true,
    ["Camouflaged Blessing Blossom"] = true,
    ["Camouflaged Arathor's Spear"] = true,
    ["Camouflaged Luredrop"] = true,
    ["Camouflaged Orbinid"] = true,
    ["Camouflaged Null Lotus"] = true,

    -- Individual Herbalism Treasures if they are distinct nodes and not in general treasures.lua
    -- ["Ancient Flower"] = true, -- Already in treasures.lua, decide if it's a node or treasure.
    -- ["Web-Entangled Lotus"] = true, -- Also in treasures.lua
}
return ww_herb_names