-- File: Sylvanas docs/TreasureTrove/ww_ores.lua
-- War Within Ore Names
-- Includes base ore nodes and common names for modified versions.
-- Node names often end in "Deposit", "Vein", or "Seam".

local ww_ore_names = {
    -- Base Ore Nodes (Sources: 2.2, 2.3, 2.5, 2.7, 3.1, 3.2)
    ["Bismuth Deposit"] = true,
    ["Ironclaw Deposit"] = true, 
    ["Aqirite Deposit"] = true,

    -- Simpler names might also be used, or partial names if they are distinct
    ["Bismuth"] = true,         -- If the node is simply named "Bismuth"
    ["Ironclaw Ore"] = true,    -- If the node is named this way
    ["Aqirite"] = true,         -- If the node is simply named "Aqirite"

    -- Common Modified Ore Node Names (Prefix + Base Ore Name + Suffix like "Deposit")
    -- Example pattern: "Crystallized Bismuth Deposit"

    -- Crystallized (Source 2.2, 2.3, 2.7, 3.1) - Drops Crystalline Powder
    ["Crystallized Bismuth Deposit"] = true,
    ["Crystallized Ironclaw Deposit"] = true,
    ["Crystallized Aqirite Deposit"] = true,
    ["Crystallized Bismuth"] = true, -- Simpler variant
    ["Crystallized Ironclaw Ore"] = true,
    ["Crystallized Aqirite"] = true,

    -- Webbed (Source 2.2, 2.3, 2.7, 3.1) - Drops Weavercloth
    ["Webbed Bismuth Deposit"] = true,
    ["Webbed Ironclaw Deposit"] = true,
    ["Webbed Aqirite Deposit"] = true,
    ["Webbed Bismuth"] = true,
    ["Webbed Ironclaw Ore"] = true,
    ["Webbed Aqirite"] = true,

    -- Weeping (Source 2.2, 2.3, 2.7, 3.1) - Drops Writhing Sample
    ["Weeping Bismuth Deposit"] = true,
    ["Weeping Ironclaw Deposit"] = true,
    ["Weeping Aqirite Deposit"] = true,
    ["Weeping Bismuth"] = true,
    ["Weeping Ironclaw Ore"] = true,
    ["Weeping Aqirite"] = true,

    -- EZ-Mine (Source 2.2, 3.1)
    ["EZ-Mine Bismuth Deposit"] = true,
    ["EZ-Mine Ironclaw Deposit"] = true,
    ["EZ-Mine Aqirite Deposit"] = true,
    ["EZ-Mine Bismuth"] = true,
    ["EZ-Mine Ironclaw Ore"] = true,
    ["EZ-Mine Aqirite"] = true,

    -- Camouflaged (Source 2.7, 3.1) - Requires Phial of Truesight
    ["Camouflaged Bismuth Deposit"] = true,
    ["Camouflaged Ironclaw Deposit"] = true,
    ["Camouflaged Aqirite Deposit"] = true,
    ["Camouflaged Bismuth"] = true,
    ["Camouflaged Ironclaw Ore"] = true,
    ["Camouflaged Aqirite"] = true,

    -- Rich Deposits (Source 2.3, 2.7)
    ["Rich Bismuth Deposit"] = true,
    ["Rich Ironclaw Deposit"] = true,
    ["Rich Aqirite Deposit"] = true,
    ["Rich Bismuth"] = true,
    ["Rich Ironclaw Ore"] = true,
    ["Rich Aqirite"] = true,
    
    -- Seams (Source 2.3, 2.7)
    ["Bismuth Seam"] = true,
    ["Ironclaw Seam"] = true,
    ["Aqirite Seam"] = true,
    
    -- Generic names for modified nodes if they don't include the base ore type
    ["Crystallized Deposit"] = true, 
    ["Webbed Deposit"] = true,       
    ["Weeping Deposit"] = true,      
    ["EZ-Mine Deposit"] = true,      
    ["Rich Deposit"] = true,      
    ["Ore Seam"] = true
}
return ww_ore_names