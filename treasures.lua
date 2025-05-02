-- Add exact treasure object names gathered from Wowhead, addons, or in-game observation.
-- This list is not exhaustive and can be expanded as needed.
local treasures = {

    -- == Generic / Common Chest Names (Used across many zones/expansions) ==
    ["Treasure Chest"] = true,
    ["Solid Chest"] = true,
    ["Large Solid Chest"] = true,
    ["Reinforced Chest"] = true,
    ["Large Iron Bound Chest"] = true,
    ["Iron Bound Chest"] = true,
    ["Adamantite Bound Chest"] = true, -- TBC/WotLK common
    ["Fel Iron Chest"] = true,         -- TBC common
    ["Obsidium Bound Chest"] = true,   -- Cataclysm common
    ["Elementium Bound Chest"] = true,-- Cataclysm common
    ["Ghost Iron Chest"] = true,       -- MoP common
    ["Ancient Pandaren Cache"] = true,-- MoP common
    ["Hozen Treasure Cache"] = true,  -- MoP specific type
    ["Glimmering Treasure Chest"] = true,
    ["Forgotten Treasure"] = true,
    ["Adventurer's Satchel"] = true,
    ["Adventurer's Pack"] = true,
    ["Hidden Stash"] = true,
    ["Discarded Pack"] = true,
    ["Waterlogged Chest"] = true,
    ["Mossy Chest"] = true,
    ["Buried Treasure"] = true,
    ["Weathered Chest"] = true,
    ["Locked Chest"] = true,          -- May require lockpicking/key
    ["Silken Treasure Chest"] = true, -- MoP specific type

    -- == Dragonflight ==
    ["Expedition Scout's Pack"] = true,
    ["Disturbed Dirt"] = true,        -- Requires shovel + renown
    ["Climbing Chest"] = true,        -- Found during climbing WQs
    ["Golden Dragon Goblet"] = true,  -- Toy container
    ["Magic-Bound Chest"] = true,     -- Requires high renown
    ["Lost Supplies"] = true,         -- Found during climbing WQs
    ["Dreamseed Cache"] = true,       -- Emerald Dream event reward

    -- == Shadowlands ==
    ["Forgotten Mementos"] = true,
    ["Halis' Lunch Pail"] = true,
    ["Kyrian Keepsake"] = true,
    ["Necro Tome"] = true,
    ["Chest of Eyes"] = true,
    ["Misplaced Supplies"] = true,
    ["Abandoned Stockpile"] = true,
    ["Faerie Trove"] = true,
    ["Harmonic Chest"] = true,
    ["Lost Satchel"] = true,
    ["Glutharn's Stash"] = true,
    ["Taskmaster's Trove"] = true,
    ["Vrytha's Dredglaive"] = true,
    ["Wayfarer's Abandoned Spoils"] = true,
    ["Glittering Nest Material"] = true,
    ["Lost Memento"] = true,
    ["Infested Vestige"] = true,
    ["Forgotten Feather"] = true,
    ["Dislodged Nest"] = true,
    ["Anima Laden Egg"] = true,
    ["Helsworn Chest"] = true,
    ["Displaced Relic"] = true,
    ["Jeweled Heart"] = true,
    ["Offering Box"] = true,
    ["Silver Strongbox"] = true,      -- Generic SL?
    ["Gift of the Night Court"] = true,

    -- == Battle for Azeroth ==
    ["War Supply Chest"] = true,      -- Warfronts / Incursions?
    ["Abyssal Treasure"] = true,      -- Nazjatar
    ["Glimmering Chest"] = true,      -- Nazjatar?
    ["Mechagon Chest"] = true,        -- Mechagon

    -- == Legion ==
    ["Ancient Mana Chunk"] = true,    -- Suramar currency/item
    ["Gleaming Footlocker"] = true,   -- Generic Legion?
    ["Treasure Chest (Legion)"] = true, -- Placeholder for specific Legion chests

    -- == Warlords of Draenor ==
    ["Garrison Cache"] = true,        -- Garrison mission reward table item
    ["Smuggled Sack of Goods"] = true,-- Common WoD treasure
    ["Treasures of Draenor"] = true,  -- Generic category - needs specific names
    ["Glowing Mushroom"] = true,      -- Spires of Arak interactable?
    ["Apexis Crystal Cluster"] = true,-- Tanaan Jungle

    -- == Mists of Pandaria ==
    ["Cache of Pilfered Goods"] = true,
    ["Stolen Sprite Treasure"] = true,
    ["Virmen Treasure Cache"] = true,
    ["Gift of the Celestials"] = true,
    ["Lost Adventurer's Belongings"] = true,
    ["Ancient Guo-Lai Cache"] = true, -- Vale (Pre-destruction)
    ["Treasures of the Vale"] = true, -- Post-destruction

    -- == Cataclysm ==
    ["Shipwreck Debris"] = true,      -- Vashj'ir
    ["Deepsea Treasure Chest"] = true,-- Vashj'ir
    ["Tol'vir Hieroglyphic Jar"] = true, -- Uldum archaeology node? Or treasure?

    -- == Wrath of the Lich King ==
    ["Forgotten Chest"] = true, -- Placeholder - need specific names
    ["Scourge War Chest"] = true,
    ["Nerubian Relic"] = true,

    -- == The Burning Crusade ==
    ["Glowcap"] = true,               -- Zangarmarsh interactable?
    ["Unidentified Fungal Growth"] = true, -- Zangarmarsh?

    -- == Classic ==
    ["Battered Chest"] = true,        -- Very common, low level
    ["Buccaneer's Strongbox"] = true, -- Stranglethorn Vale?
    ["Large Mithril Bound Chest"] = true, -- Higher level zones
    ["Thorium Bound Chest"] = true,   -- Higher level zones

    -- == The War Within ==
    ["Earthen Iron Powder"] = true, -- Alchemy Prof Treasure
    ["Metal Dornogal Frame"] = true,-- Blacksmithing Prof Treasure
    ["Reinforced Beaker"] = true,   -- Alchemy Prof Treasure
    ["Engraved Stirring Rod"] = true,-- Alchemy Prof Treasure
    ["Silver Dornogal Rod"] = true, -- Jewelcrafting Prof Treasure
    ["Dornogal Seam Ripper"] = true,-- Tailoring Prof Treasure
    ["Ancient Flower"] = true,      -- Herbalism Prof Treasure
    ["Heavy Spider Crusher"] = true,-- Mining Prof Treasure
    ["Nerubian Mining Cart"] = true,-- Mining Prof Treasure
    ["Bountiful Heavy Trunk"] = true, -- Delve reward
    ["Bountiful Coffer"] = true,      -- Delve reward (needs key)
    ["Hidden Trove"] = true,          -- Delve reward (needs key)
    ["Disturbed Earth"] = true,         -- Disturbed Earth treasure mounds

    -- Add many, many more specific names here...
}

return treasures