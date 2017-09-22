local Util = require("scripts.util")
local Pickup = {}

--Returns a list of item counts and inventory pointers for each item in the filter
function Pickup.get_total_items_in_invs(invs, filter)
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
function Pickup.give_player_items(filter, player, total_items_in_invs)
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
function Pickup.refill_chests(total_items_in_invs)
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

return Pickup
