--luacheck: ignore 211/.*_
local pickup_defines = require("defines")
local Gui = require("scripts.gui")
local Util = require("scripts.util")
local Events = {}

function Events.on_change_selector_item(elem, gui)
    for i=1, pickup_defines.gui.filter_count, 1 do
        local filter_item = gui.filter_table.children["blank-pickup-gui-filter-selector-table-"..i]
        for cname,child in pairs(filter_item.children) do
            if elem.elem_value ~= nil then
                if elem.type == "choose-elem-button" and cname == elem.name then
                    child.sibling.live_elem.caption = "..."
                    child.live_elem.enabled = false
                    child.sibling.live_elem.enabled = false
                    local edit_frame = gui.edit_table.children["blank-pickup-gui-edit-frame-"..i]
                    Gui.set_edit_frame(edit_frame, elem.elem_value)
                    edit_frame.live_elem.style.visible = true
                end
            else
                if elem.type == "choose-elem-button" and cname == elem.name then
                    local edit_frame = gui.edit_table.children["blank-pickup-gui-edit-frame-"..i]
                    child.sibling.value = 0
                    child.sibling.live_elem.caption = child.sibling.value
                    Gui.set_edit_frame(edit_frame, elem.elem_value)

                end
            end
        end
        if elem.name == "blank-pickup-gui-edit-elem-button-"..i then
            local edit_frame = gui.edit_table.children["blank-pickup-gui-edit-frame-"..i]
            Gui.set_edit_frame(edit_frame, elem.elem_value)
        end
    end
end

function Events.on_click_filter_button(event, elem, gui)
    for i=1, pickup_defines.gui.filter_count, 1 do
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
                    Gui.set_edit_frame(edit_frame, nil)
                    child.sibling.live_elem.elem_value = nil
                end
            end
        end
    end
end

function Events.on_click_edit_buttons(event, elem, gui)
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
end

function Events.on_click_gui_close(event, elem, gui)
    if event.button == defines.mouse_button_type.left and elem.name == "blank-pickup-gui-close-button" then
        gui.live_elem.style.visible = false
    end
end

function Events.on_click_tab_buttons(elem, gui)
    for _,child in pairs(gui.tab_table.children) do
        if child.live_elem.name == elem.name then
            --for _,player in pairs(game.players) do player.print(elem.name..":"..child.live_elem.name) end
            --child.live_elem.style.visible = not child.live_elem.style.visible
            --child.sibling.live_elem.style.visible = not child.live_elem.style.visible

            Events.on_click_item_tab_button(elem, gui, child)
            Events.on_click_entity_tab_button(elem, gui, child)
        end
    end
end

function Events.on_click_item_tab_button(elem, gui, button)
    if elem.name == pickup_defines.gui.names.gui_main.."-tab-1" then
        gui.blacklist_table.live_elem.style.visible = false
        gui.filter_table.live_elem.style.visible = true
        button.live_elem.style.visible = false
        button.sibling.live_elem.style.visible = true
        gui.label.live_elem.caption = {"mod-text.gui-main-menu-label"}
    end
end

function Events.on_click_entity_tab_button(elem, gui, button)
    if elem.name == pickup_defines.gui.names.gui_main.."-tab-2" then
        gui.filter_table.live_elem.style.visible = false
        gui.blacklist_table.live_elem.style.visible = true
        button.live_elem.style.visible = false
        button.sibling.live_elem.style.visible = true
        gui.label.live_elem.caption = {"mod-text.gui-blacklist-label"}
        --for _,player in pairs(game.players) do player.print("activate blacklist") end
    end
end

return Events
