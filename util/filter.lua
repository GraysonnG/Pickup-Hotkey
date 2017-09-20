local Filter = {}

function Filter.generate_filter_from_gui(player)
    local filter = {}
    local gui = global.pickup_player_fancy_gui[player.index]
    local filter_table = gui.filter_table

    for _,child in pairs(filter_table.children) do
        local selector = child.item_selector.live_elem.elem_value
        local amount = child.item_button.value
        local filt = {name = selector or "undefined", count = amount or -1}
        if filt.name ~= "undefined" and filt.count > 0 then
            table.insert(filter,filt)
        end
    end

    return filter;
end

return Filter
