local util = {}

--Creates a blue beam that moves towards the player
util.create_blue_beam = function(player, ent)
    return player.surface.create_entity{
        name = "show-laser",
        position = ent.position,
        target = player.character,
        speed=0.5
    }
end

--Creates a floating text entity at the players position
util.create_floating_text = function(player, text, index)
    return player.surface.create_entity{
        name = "flying-text",
        position = {x = player.position.x, y = player.position.y + (index-1)},
        text = text,
        color = {r = 130/255, g = 200/255, b = 255/255}
    }
end

--Converts a buttons text to an integer
util.button_to_uint = function(button)
   if button.caption and tonumber(button.caption) and tonumber(button.caption) >= 0 and tonumber(button.caption) <= 4294967295 then
       return tonumber(button.caption)
   else
       return false
   end
end

--Converts a textfields text to an integer
util.textfield_to_uint = function(textfield)
	if textfield.text and tonumber(textfield.text) and tonumber(textfield.text) >= 0 and tonumber(textfield.text) <= 4294967295 then
		return tonumber(textfield.text)
	else
		return false
	end
end

function util.format_number(amount, append_suffix)
  local suffix = ""
  if append_suffix then
    local suffix_list =
      {
        ["T"] = 1000000000000,
        ["B"] = 1000000000,
        ["M"] = 1000000,
        ["k"] = 1000
      }
    for letter, limit in pairs (suffix_list) do
      if math.abs(amount) >= limit then
        amount = math.floor(amount/(limit/10))/10
        suffix = letter
        break
      end
    end
  end
  local formatted = amount
  while true do
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted..suffix
end

function classify(class)
    setmetatable(class, {
        __call = function(class, ...)
            -- Create instance table
            local inst = {}

            -- Set metatable *before* constructor so they can invoke
            -- other functions during construction
            classifyInstance(inst, class)

            -- Invoke constructor
            class.New(inst, ...)

            return inst
        end,
        __newindex = function(index)
            error('Cannot modify class: ' .. index)
        end,
        __metatable = true,
    })
    return class
end

return util
