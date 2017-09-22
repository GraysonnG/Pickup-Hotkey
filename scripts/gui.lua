--luacheck: ignore 211/.*_
local pickup_defines = require("defines")
local mod_gui = require("mod-gui")
local Util_ = require("scripts.util")

local Gui = {}

function Gui.gen_children_in_parent(disp_parent, gui)

    local disp = disp_parent.add(gui.element_value)

    if gui.style ~= nil then gui.style(disp) end

    for _,child in pairs(gui.children) do
        Gui.gen_children_in_parent(disp, child)
    end

    gui.live_elem = disp
end

function Gui.gen_gui(gui, player)
    local frame_flow = mod_gui.get_frame_flow(player)
    Gui.gen_children_in_parent(frame_flow, gui)
    local edit_gui = frame_flow.add(gui.edit_table.element_value)
    Gui.gen_children_in_parent(edit_gui, gui.edit_table)
    for _,child in pairs(gui.edit_table.children) do
        child.live_elem.style.visible = false;
    end
    gui.live_elem.style.visible = false
end

function Gui.create_simple_gui_element(e, p)
    local new_element = {element_value = e, parent = p, children = {}, sibling = {}, style = nil, on_event = nil}
    if p ~= nil then p.children[e.name] = new_element end
    return new_element
end

function Gui.create_edit_frame(index, edit_table)
    local edit_frame_ = Gui.create_simple_gui_element({
            type = "frame",
            name = "blank-pickup-gui-edit-frame-"..index
        },edit_table)

    local edit_flow = Gui.create_simple_gui_element({
            type = "flow",
            name = "blank-pickup-gui-edit-flow",
            direction = "vertical"
        },edit_frame_)
    local edit_title_ = Gui.create_simple_gui_element({
            type = "label",
            name = "blank-pickup-gui-edit-label",
            caption = {"mod-text.gui-edit-slot-label", index}
        },edit_flow)
    local edit_top_table = Gui.create_simple_gui_element({
            type = "table",
            name = "blank-pickup-gui-edit-top-table",
            colspan = 3
        },edit_flow)

    local edit_bot_table = Gui.create_simple_gui_element({
            type = "table",
            name = "blank-pickup-gui-edit-bottom-table",
            colspan = 5
        },edit_flow)

    local edit_item_selector_ = Gui.create_simple_gui_element({
            type = "choose-elem-button",
            name = "blank-pickup-gui-edit-elem-button-"..index,
            elem_type = "item"
        },edit_top_table)

    local edit_item_textbox_ = Gui.create_simple_gui_element({
            type = "textfield",
            name = "blank-pickup-gui-edit-textfield-"..index
        },edit_top_table)

    local edit_ok_button_ = Gui.create_simple_gui_element({
            type = "button",
            name = "blank-pickup-gui-edit-ok-button",
            caption = {"mod-text.gui-ok"}
        },edit_top_table)

    local edit_minus_1000_button = Gui.create_simple_gui_element({
            type = "button",
            name = "blank-pickup-gui-edit-minus-1k-button",
            caption = "-1000"
        },edit_bot_table)

    local edit_minus_stack_button = Gui.create_simple_gui_element({
            type = "button",
            name = "blank-pickup-gui-edit-minus-stack-button",
            caption = "-100"
        },edit_bot_table)

    local edit_plus_stack_button = Gui.create_simple_gui_element({
            type = "button",
            name = "blank-pickup-gui-edit-plus-stack-button",
            caption = "+100"
        },edit_bot_table)

    local edit_plus_1000_button = Gui.create_simple_gui_element({
            type = "button",
            name = "blank-pickup-gui-edit-plus-1k-button",
            caption = "+1000"
        },edit_bot_table)

    edit_item_selector_.style = pickup_defines.gui.default_styles.default_small_select_elem_button
    edit_item_textbox_.style = pickup_defines.gui.default_styles.default_textfield
    edit_ok_button_.style = pickup_defines.gui.default_styles.default_ok_button
    edit_minus_1000_button.style = pickup_defines.gui.default_styles.default_small_button
    edit_minus_stack_button.style = pickup_defines.gui.default_styles.default_small_button
    edit_plus_stack_button.style = pickup_defines.gui.default_styles.default_small_button
    edit_plus_1000_button.style = pickup_defines.gui.default_styles.default_small_button

    edit_minus_1000_button.value = -1000
    edit_minus_stack_button.value = -100
    edit_plus_1000_button.value = 1000
    edit_plus_stack_button.value = 100

    edit_item_textbox_.button_controls = {}
    edit_item_textbox_.button_controls[edit_minus_1000_button.element_value.name] = edit_minus_1000_button
    edit_item_textbox_.button_controls[edit_minus_stack_button.element_value.name] = edit_minus_stack_button
    edit_item_textbox_.button_controls[edit_plus_stack_button.element_value.name] = edit_plus_stack_button
    edit_item_textbox_.button_controls[edit_plus_1000_button.element_value.name] = edit_plus_1000_button

    edit_item_textbox_.value = 0

    edit_frame_.item_selector = edit_item_selector_
    edit_frame_.item_textfield = edit_item_textbox_
    edit_frame_.ok_button = edit_ok_button_

    return edit_frame_
end

function Gui.create_filter_item(index, p, edit_table)
    local selector_table = Gui.create_simple_gui_element({
            type = "table",
            name = "blank-pickup-gui-filter-selector-table-"..index,
            colspan = 2
        }, p)

    local item_selector_ = Gui.create_simple_gui_element({
            type = "choose-elem-button",
            name = "blank-pickup-gui-filter-choose-elem-button-"..index,
            elem_type = "item"
        }, selector_table)

    local item_count_ = Gui.create_simple_gui_element({
            type = "button",
            name = "blank-pickup-gui-filter-choose-amount-button-"..index,
            caption = "0";

        }, selector_table)

    local edit_frame_ = Gui.create_edit_frame(index, edit_table)

    selector_table.item_selector = item_selector_
    selector_table.item_button = item_count_

    item_selector_.sibling = item_count_
    item_count_.sibling = item_selector_
    edit_frame_.sibling = selector_table

    item_count_.value = 0

    p.children[selector_table.element_value.name] = selector_table

    return selector_table
end

function Gui.create_main_menu(player)
    local gui = Gui.create_simple_gui_element({
            type = "frame",
            name = "blank-pickup-gui-frame"
        },
        nil)

    local edit_gui_table = Gui.create_simple_gui_element({
            type = "table",
            name = "blank-pickup-gui-edit-table",
            colspan = 3
        }, nil)

    local vert_flow_ = Gui.create_simple_gui_element({
            type = "flow",
            name = "blank-pickup-gui-vert-flow",
            direction = "vertical"
        },
        gui)

    local frame_label_ = Gui.create_simple_gui_element({
            type = "label",
            name = "blank-pickup-gui-frame-label",
            caption = {"mod-text.gui-main-menu-label"}
        },
        vert_flow_)

    local filter_table_ = Gui.create_simple_gui_element({
            type = "table",
            name = "blank-pickup-gui-filter-table",
            colspan = 2,
        },
        vert_flow_)

    local filter_close_ = Gui.create_simple_gui_element({
            type = "button",
            name = "blank-pickup-gui-close-button",
            caption = {"mod-text.gui-close"}
        },vert_flow_)

    for i = 1, pickup_defines.gui.filter_count, 1 do
        local filter_item_ = Gui.create_filter_item(i, filter_table_, edit_gui_table)
        filter_item_.item_button.style = pickup_defines.gui.default_styles.default_button
    end
    filter_close_.style = pickup_defines.gui.default_styles.default_small_button

    gui.filter_table = filter_table_
    gui.edit_table = edit_gui_table

    Gui.gen_gui(gui, player)

    return gui
end

function Gui.set_edit_frame(edit_frame, item_name)
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

return Gui
