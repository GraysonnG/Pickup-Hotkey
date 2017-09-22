local new_blue_laser = util.table.deepcopy(data.raw["projectile"]["blue-laser"])
new_blue_laser.name = "show-laser"
new_blue_laser.action.action_delivery.target_effects = {
    {
        type = "damage",
        damage = {amount = 0, type = "laser"}
    }
}
new_blue_laser.acceleration = 0.3

data:extend({new_blue_laser})
