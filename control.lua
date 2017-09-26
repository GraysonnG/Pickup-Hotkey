--luacheck: ignore 211/.*_
local pickup_defines_ = require("defines")
local Util = require("scripts.util")
local Gui = require("scripts.gui")
local Filter = require("scripts.filter")
local Pickup = require("scripts.pickup")
local Events = require("scripts.event-handler")

local pickup_distance
local pickup_chest

--Initializes the main gui for player
local function init_gui(player)
    global.pickup_player_fancy_gui = global.pickup_player_fancy_gui or {}
    global.pickup_player_fancy_gui[player.index] = global.pickup_player_fancy_gui[player.index] or Gui.create_main_menu(player)

    if global.pickup_player_gui and global.pickup_player_gui[player.index] then global.pickup_player_gui[player.index] = nil end
end

--Initializes the filter for player
local function init_filter(player)
    global.pickup_player_filter = global.pickup_player_filter or {}
    global.pickup_player_filter[player.index] = Filter.generate_filter_from_gui(player)
end

--Initializes the blacklist for player
local function init_blacklist()
    global.pickup_player_blacklist = global.pickup_player_blacklist or {}
end

--Handles the process of picking up items
local function pickup_items(invs, player)
    local player_inv = player.get_inventory(defines.inventory.player_main)
    local filter = global.pickup_player_filter[player.index]

    local total_items_in_invs = Pickup.get_total_items_in_invs(invs, filter, player_inv)
    Pickup.give_player_items(filter, player, total_items_in_invs)
    Pickup.refill_chests(total_items_in_invs)
end

--Gets the inventories inside of the pickup_area
local function get_nearby_inventories(surface, pickup_area)
    local entities = surface.find_entities(pickup_area)
    local inventories = {}

    for i=1, #entities, 1 do
        local ent = entities[i]

        if global.pickup_player_blacklist[ent.unit_number] == nil then
            --Filters the entities to those that have output inventories
            if ent.get_output_inventory() ~= nil then
                if ent.type == "assembling-machine" or ent.type == "furnace" then
                    table.insert(inventories, ent.get_output_inventory())
                end
                --If pickup from chest is enabled pick up from chests
                if ent.type == "container" and pickup_chest then
                    table.insert(inventories, ent.get_output_inventory())

                end
            end

            if ent.type == "character-corpse" then
                table.insert(inventories, ent.get_inventory(defines.inventory.item_main))
            end

            if ent.name == "burner-mining-drill" then
                table.insert(inventories, ent.get_inventory(defines.inventory.fuel))
            end
        end
    end

    return inventories
end

--Gets all entities within reach_dist and inserts items into the players inventory
local function main_pickup(player)
    local reach_dist = pickup_distance
    local pickup_area = {
        {player.position.x - reach_dist, player.position.y - reach_dist},
        {player.position.x + reach_dist, player.position.y + reach_dist}
    }

    pickup_items(get_nearby_inventories(player.surface, pickup_area), player)
end

--Event handler for when the player presses the hotkey to pick up items
script.on_event("blank-pickup-hotkey", function(event)
    local player = game.players[event.player_index]

    --Reinitialize pickup_distance and pickup_chest
    pickup_distance = player.mod_settings["blank-pickup-distance"].value
    pickup_chest = player.mod_settings["blank-pickup-chest"].value

    --add a comment
    --Reinitialize gui and filter and initialize pickup_items
    init_gui(player)
    init_filter(player)
    init_blacklist()
    main_pickup(player)
end)

--Event handler for when the player presses the hotkey to open the menu
script.on_event("blank-pickup-menu", function(event)
    local player = game.players[event.player_index]

    init_gui(player)

    local gui = global.pickup_player_fancy_gui[event.player_index]

    gui.live_elem.style.visible = not gui.live_elem.style.visible
end)

--Event handler for blacklisting items
script.on_event("blank-pickup-blacklist", function(event)
    local player = game.players[event.player_index]
    local selected_entity = player.selected

    init_blacklist()

    if selected_entity then
        local unit_number = selected_entity.unit_number

        if global.pickup_player_blacklist[unit_number] then
            Util.remove_ent_from_blacklist(selected_entity)
        else
            Util.add_ent_to_blacklist(selected_entity)
        end
    end
end)


script.on_event(defines.events.on_player_mined_entity, function(event)
    local entity = event.entity

    if entity.unit_number and global.pickup_player_blacklist[entity.unit_number] then
        Util.remove_ent_from_blacklist(entity)
    end
end)

script.on_event(defines.events.on_robot_mined_entity, function(event)
    local entity = event.entity

    if entity.unit_number and global.pickup_player_blacklist[entity.unit_number] then
        Util.remove_ent_from_blacklist(entity)
    end
end)

--Event handler for when the player places an entity
script.on_event(defines.events.on_built_entity, function(event)
    local entity = event.created_entity
    local player = game.players[event.player_index]
    local gui = global.pickup_player_fancy_gui[player.index]

    for i=1,pickup_defines_.gui.filter_count, 1 do
        local filter_item = gui.blacklist_table.children[pickup_defines_.gui.names.gui_main.."-blacklist-table-"..i].item_selector.live_elem.elem_value
        if entity.name == filter_item then
            Util.add_ent_to_blacklist(entity)
        end
    end
end)

--Event handler for when a new player is created
script.on_event(defines.events.on_player_created, function(event)
    local player = game.players[event.player_index]
    init_gui(player)
    init_blacklist()
end)

--Event handler for all on_click events
script.on_event(defines.events.on_gui_click, function(event)
    local elem = event.element
    local player_ = game.players[event.player_index]

    init_gui(player_)

    local gui = global.pickup_player_fancy_gui[event.player_index]

    --Handles Mouse Clicks on the close button
    Events.on_click_gui_close(event, elem, gui)

    --Handles Mouse Clicks on the filter buttons
    Events.on_click_filter_button(event, elem, gui)

    --Handles Mouse Clicks on the edit frame buttons
    Events.on_click_edit_buttons(event, elem, gui)

    --Handles Mouse Clicks on the filter tabs
    Events.on_click_tab_buttons(elem, gui)
end)

--Event handler for when a item selector is changed
script.on_event(defines.events.on_gui_elem_changed, function(event)
    local elem = event.element
    local player_ = game.players[event.player_index]
    local gui = global.pickup_player_fancy_gui[event.player_index]

    Events.on_change_selector_item(elem, gui)
end)
