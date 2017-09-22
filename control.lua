--luacheck: ignore 211/.*_
local blank_pickup_hotkey_defines = require("defines")
local Util = require("util.util")
local Gui = require("util.gui")
local Filter = require("util.filter")

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

local function add_ent_to_blacklist(selected_entity)
    local unit_number = selected_entity.unit_number

    local pos = selected_entity.position
    pos.y = pos.y + 1 + (selected_entity.prototype.selection_box.left_top.y)

    local blacklist_icon = selected_entity.surface.create_entity{
        name = "blacklist-icon",
        position = {pos.x, pos.y}
    }
    global.pickup_player_blacklist[unit_number] = blacklist_icon
end

local function remove_ent_to_blacklist(selected_entity)
    local unit_number = selected_entity.unit_number
    local pos = selected_entity.position
    pos.y = pos.y + 1 + (selected_entity.prototype.selection_box.left_top.y)

    global.pickup_player_blacklist[unit_number].destroy()
    global.pickup_player_blacklist[unit_number] = nil

    selected_entity.surface.create_entity{
        name = "fading-blacklist-icon",
        position = {pos.x, pos.y}
    }
end

--Returns a list of item counts and inventory pointers for each item in the filter
local function get_total_items_in_invs(invs, filter)
    local total = {}
    for i=1, #invs, 1 do
        local inv = invs[i]
        for _,item_in_filter in pairs(filter) do
            local inv_from_count = inv.get_item_count(item_in_filter.name)
            if inv_from_count > 0 then
                total[item_in_filter.name] = total[item_in_filter.name] or {count=0, inventories = {}}
                total[item_in_filter.name].count = total[item_in_filter.name].count + inv_from_count

                table.insert(total[item_in_filter.name].inventories, inv)

                inv.remove{name = item_in_filter.name, count = inv_from_count}
            end
        end
    end
    return total
end

--Handles giving the player the correct amount of items and removes the correct amount of items from the total_items_in_invs
local function give_player_items(filter, player, total_items_in_invs)
    local player_inv = player.get_inventory(defines.inventory.player_main)

    for i = 1, #filter, 1 do
        local item_in_filter = filter[i]
        local amount_in_plr = player_inv.get_item_count(item_in_filter.name)
        local amount_to_give = item_in_filter.count - amount_in_plr
        local total_of_item = total_items_in_invs[item_in_filter.name]

        if amount_to_give < 0 then amount_to_give = 0 end
        if total_of_item ~= nil then

            if total_of_item.count - amount_to_give < 0 then
                amount_to_give = amount_to_give - math.abs(total_of_item.count - amount_to_give)
            end

            if amount_to_give ~= 0 then
                local amount_given = player_inv.insert{name = item_in_filter.name, count = amount_to_give}
                local amount_to_return = amount_to_give - amount_given

                if amount_given > 0 then
                    Util.create_floating_text(player, {"mod-print-text.item-insert", item_in_filter.name, amount_given, player_inv.get_item_count(item_in_filter.name)}, i)
                    for _,inv in pairs(total_of_item.inventories) do
                        Util.create_blue_beam(player, inv.entity_owner)
                    end
                else
                    player.print("Could not complete.")
                end

                total_of_item.count = total_of_item.count - amount_to_give
                total_of_item.count = total_of_item.count + amount_to_return
            end
        end
    end
end

--Refills all the chests and distributes the items evenly across all inventories that contained the item in the first place
local function refill_chests(total_items_in_invs)
    for item_name,total_of_item in pairs(total_items_in_invs) do
        repeat
            local amount_inserted = 0

            for i=#total_of_item.inventories, 1, -1 do
                local inv = total_of_item.inventories[i]
                local amount_to_insert = math.ceil(total_of_item.count / #total_of_item.inventories)

                if total_of_item.count <= 5 or amount_to_insert > total_of_item.count then
                    amount_to_insert = total_of_item.count
                end

                local amount_insert = 0

                if amount_to_insert > 0 then
                    amount_insert = inv.insert{name = item_name, count = amount_to_insert}
                end

                amount_inserted = amount_inserted + amount_insert
                total_of_item.count = total_of_item.count - amount_insert

                if amount_insert ~= amount_to_insert then
                    table.remove(total_of_item.inventories, i)
                end

            end

        until total_of_item.count <= 0 or amount_inserted == 0
    end
end

--Handles the process of picking up items
local function pickup_items(invs, player)
    local player_inv = player.get_inventory(defines.inventory.player_main)
    local filter = global.pickup_player_filter[player.index]

    local total_items_in_invs = get_total_items_in_invs(invs, filter, player_inv)
    give_player_items(filter, player, total_items_in_invs)
    refill_chests(total_items_in_invs)
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

local function set_edit_frame(edit_frame, item_name)
    local stack_size = 100

    if item_name ~= nil then
        stack_size = game.item_prototypes[item_name].stack_size
    end

    edit_frame.item_textfield.value = stack_size

    if stack_size == 0 then stack_size = 100 end

    edit_frame.item_textfield.live_elem.text = item_name ~= nil and stack_size or 0
    edit_frame.item_textfield.value = stack_size or 0

    edit_frame.item_textfield.button_controls["blank-pickup-gui-edit-minus-stack-button"].live_elem.caption = "-"..stack_size
    edit_frame.item_textfield.button_controls["blank-pickup-gui-edit-plus-stack-button"].live_elem.caption = "+"..stack_size
    edit_frame.item_textfield.button_controls["blank-pickup-gui-edit-minus-1k-button"].live_elem.caption = "-"..10 * stack_size
    edit_frame.item_textfield.button_controls["blank-pickup-gui-edit-plus-1k-button"].live_elem.caption = "+"..10 * stack_size

    edit_frame.item_textfield.button_controls["blank-pickup-gui-edit-minus-stack-button"].value = -1 * stack_size
    edit_frame.item_textfield.button_controls["blank-pickup-gui-edit-plus-stack-button"].value = stack_size
    edit_frame.item_textfield.button_controls["blank-pickup-gui-edit-minus-1k-button"].value = -10 * stack_size
    edit_frame.item_textfield.button_controls["blank-pickup-gui-edit-plus-1k-button"].value = 10 * stack_size

    edit_frame.item_selector.live_elem.elem_value = item_name
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

    if selected_entity and selected_entity.unit_number then
        local unit_number = selected_entity.unit_number

        if global.pickup_player_blacklist[unit_number] then
            remove_ent_to_blacklist(selected_entity)
        else
            add_ent_to_blacklist(selected_entity)
        end
    end
end)

--Event handler for all on_click events
script.on_event(defines.events.on_gui_click, function(event)
    local elem = event.element
    local player_ = game.players[event.player_index]

    init_gui(player_)

    local gui = global.pickup_player_fancy_gui[event.player_index]

    if event.button == defines.mouse_button_type.left and elem.name == "blank-pickup-gui-close-button" then
        gui.live_elem.style.visible = false
    end

    --Handles Mouse Clicks for the filter buttons
    for i=1, blank_pickup_hotkey_defines.gui.filter_count, 1 do
        local filter_item = gui.filter_table.children["blank-pickup-gui-filter-selector-table-"..i]
        for cname,child in pairs(filter_item.children) do
            if elem.type == "button" and cname == elem.name then
                --Left click : Opens the filters' edit menu
                if event.button == defines.mouse_button_type.left then
                    local edit_frame = gui.edit_table.children["blank-pickup-gui-edit-frame-"..i]
                    edit_frame.item_textfield.live_elem.text = child.parent.item_button.value
                    edit_frame.item_selector.live_elem.elem_value = child.parent.item_selector.live_elem.elem_value
                    edit_frame.live_elem.style.visible = not edit_frame.live_elem.style.visible
                    child.live_elem.caption = "..."
                    child.sibling.live_elem.enabled = false
                    child.live_elem.enabled = false
                --Right click : Clears the filter and resets the filters' edit frame
                elseif event.button == defines.mouse_button_type.right then
                    local edit_frame = gui.edit_table.children["blank-pickup-gui-edit-frame-"..i]
                    child.live_elem.caption = "0"
                    child.value = 0
                    set_edit_frame(edit_frame, nil)
                    child.sibling.live_elem.elem_value = nil
                end
            end
        end
    end

    --Handles Mouse Clicks for the edit frame buttons
    for cname,child in pairs(gui.edit_table.children) do
            if elem.type == "button" and event.button == defines.mouse_button_type.left then
                if elem.name == "blank-pickup-gui-edit-ok-button" and elem.parent.parent.parent.name == cname then
                    local selected_item = child.item_selector.live_elem.elem_value
                    local selected_textfield = child.item_textfield.live_elem

                    local text_int = child.sibling.item_button.value
                    if Util.textfield_to_uint(selected_textfield) then
                        text_int = Util.textfield_to_uint(selected_textfield)
                        child.item_textfield.value = text_int
                        child.sibling.item_button.value = text_int
                    end

                    child.sibling.item_selector.live_elem.elem_value = selected_item
                    child.sibling.item_button.live_elem.caption = text_int

                    child.live_elem.style.visible = false
                    child.sibling.item_selector.live_elem.enabled = true
                    child.sibling.item_button.live_elem.enabled = true
                else
                    for bname,butgui in pairs(child.item_textfield.button_controls) do
                        if bname == elem.name and elem.parent.parent.parent.name == cname then
                            child.item_textfield.value = child.item_textfield.value + butgui.value
                            if child.item_textfield.value < 0 then child.item_textfield.value = 0 end
                            child.item_textfield.live_elem.text = child.item_textfield.value
                        end
                    end
                end
            end
    end
end)

--Event handler for when a item selector is changed
script.on_event(defines.events.on_gui_elem_changed, function(event)
    local elem = event.element
    local player_ = game.players[event.player_index]
    local gui = global.pickup_player_fancy_gui[event.player_index]

    for i=1, blank_pickup_hotkey_defines.gui.filter_count, 1 do
        local filter_item = gui.filter_table.children["blank-pickup-gui-filter-selector-table-"..i]
        for cname,child in pairs(filter_item.children) do
            if elem.elem_value ~= nil then
                if elem.type == "choose-elem-button" and cname == elem.name then
                    child.sibling.live_elem.caption = "..."
                    child.live_elem.enabled = false
                    child.sibling.live_elem.enabled = false
                    local edit_frame = gui.edit_table.children["blank-pickup-gui-edit-frame-"..i]
                    set_edit_frame(edit_frame, elem.elem_value)
                    edit_frame.live_elem.style.visible = true
                end
            else
                if elem.type == "choose-elem-button" and cname == elem.name then
                    local edit_frame = gui.edit_table.children["blank-pickup-gui-edit-frame-"..i]
                    child.sibling.value = 0
                    child.sibling.live_elem.caption = child.sibling.value
                    set_edit_frame(edit_frame, elem.elem_value)

                end
            end
        end
        if elem.name == "blank-pickup-gui-edit-elem-button-"..i then
            local edit_frame = gui.edit_table.children["blank-pickup-gui-edit-frame-"..i]
            set_edit_frame(edit_frame, elem.elem_value)
        end
    end
end)
