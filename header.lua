local plugin = {}

plugin["name"] = "Treasure Trove"
plugin["version"] = "0.1"
plugin["author"] = "HeftyHippo"
plugin["description"] = "Treasure finding utility"
plugin["load"] = true

-- Ensure the script only loads when in-game
local local_player = core.object_manager.get_local_player()
if not local_player then
    plugin["load"] = false
    return plugin
end

return plugin