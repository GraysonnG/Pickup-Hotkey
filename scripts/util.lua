local util = {}

--Creates a blue beam that moves towards the player
function util.create_blue_beam(player, ent)
    return player.surface.create_entity{
        name = "show-laser",
        position = ent.position,
        target = player.character,
        speed=0.5
    }
end

--Adds and entities unit number to the blacklist and creates an icon at the entities position
function util.add_ent_to_blacklist(selected_entity)
    local unit_number = selected_entity.unit_number

    local pos = selected_entity.position
    pos.y = pos.y + 1 + (selected_entity.prototype.selection_box.left_top.y)

    local blacklist_icon = selected_entity.surface.create_entity{
        name = "blacklist-icon",
        position = {pos.x, pos.y}
    }
    global.pickup_player_blacklist[unit_number] = blacklist_icon
end

--Removes and entities unit number from the blacklist removes the icon and places a closing animation icon in its place
function util.remove_ent_from_blacklist(selected_entity)
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

--Creates a floating text entity at the players position
function util.create_floating_text(player, text, index)
    return player.surface.create_entity{
        name = "flying-text",
        position = {x = player.position.x, y = player.position.y + (index-1)},
        text = text,
        color = {r = 130/255, g = 200/255, b = 255/255}
    }
end

--Converts a buttons text to an integer
function util.button_to_uint(button)
   if button.caption and tonumber(button.caption) and tonumber(button.caption) >= 0 and tonumber(button.caption) <= 4294967295 then
       return tonumber(button.caption)
   else
       return false
   end
end

--Converts a textfields text to an integer
function util.textfield_to_uint(textfield)
	if textfield.text and tonumber(textfield.text) and tonumber(textfield.text) >= 0 and tonumber(textfield.text) <= 4294967295 then
		return tonumber(textfield.text)
	else
		return false
	end
end

return util
