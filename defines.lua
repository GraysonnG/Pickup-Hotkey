local blank_pickup_hotkey_defines = {}
blank_pickup_hotkey_defines.MOD_NAME = "__pickup-hotkey__"

blank_pickup_hotkey_defines.gui = {}
blank_pickup_hotkey_defines.gui.filter_count = 16
blank_pickup_hotkey_defines.gui.default_button_height = 35
blank_pickup_hotkey_defines.gui.small_button_width = 40
blank_pickup_hotkey_defines.gui.small_button_height = 25

blank_pickup_hotkey_defines.gui.default_styles = {}
blank_pickup_hotkey_defines.gui.default_styles.default_ok_button = function(live_elem)
    live_elem.style.minimal_height = blank_pickup_hotkey_defines.gui.small_button_height
    live_elem.style.maximal_height = blank_pickup_hotkey_defines.gui.small_button_height
    live_elem.style.minimal_width = blank_pickup_hotkey_defines.gui.small_button_width
    live_elem.style.maximal_width = blank_pickup_hotkey_defines.gui.small_button_width
    live_elem.style.font = "default-small-bold"
    live_elem.style.top_padding = 1
end

blank_pickup_hotkey_defines.gui.default_styles.default_button = function(live_elem)
    live_elem.style.maximal_height = blank_pickup_hotkey_defines.gui.default_button_height
    live_elem.style.minimal_height = blank_pickup_hotkey_defines.gui.default_button_height
    live_elem.style.font = "default-small-bold"
end

blank_pickup_hotkey_defines.gui.default_styles.default_small_button = function(live_elem)
    live_elem.style.minimal_height = blank_pickup_hotkey_defines.gui.small_button_height
    live_elem.style.maximal_height = blank_pickup_hotkey_defines.gui.small_button_height
    live_elem.style.font = "default-small-bold"
    live_elem.style.top_padding = 1
end

blank_pickup_hotkey_defines.gui.default_styles.default_textfield = function(live_elem)
    live_elem.style.minimal_height = blank_pickup_hotkey_defines.gui.small_button_height
    live_elem.style.maximal_height = blank_pickup_hotkey_defines.gui.small_button_height
end

blank_pickup_hotkey_defines.gui.default_styles.default_small_select_elem_button = function(live_elem)
    live_elem.style.minimal_height = blank_pickup_hotkey_defines.gui.small_button_height
    live_elem.style.maximal_height = blank_pickup_hotkey_defines.gui.small_button_height
    live_elem.style.minimal_width = blank_pickup_hotkey_defines.gui.small_button_height
    live_elem.style.maximal_width = blank_pickup_hotkey_defines.gui.small_button_height
end

blank_pickup_hotkey_defines.gui.names = {}

blank_pickup_hotkey_defines.gui.names.gui_main = "blank-pickup-gui"
blank_pickup_hotkey_defines.gui.names.gui_edit = "blank-pickup-gui-edit"

return blank_pickup_hotkey_defines
