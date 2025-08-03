-- iikk_a's Ore Tracer Module https://github.com/iikk-a/Plethora-Ore-Tracers

local module = {
    name = "xray",
    cached = true,
    timeout = 0
}

local neural, c3d

local ores = {
    ["minecraft:coal_ore"] = {0, 0, 0},
    ["minecraft:iron_ore"] = {255, 150, 50},
    ["minecraft:redstone_ore"] = {255, 0, 0},
    ["minecraft:gold_ore"] = {255, 255, 0},
    ["minecraft:lapis_ore"] = {0, 50, 255},
    ["minecraft:diamond_ore"] = {0, 255, 255},
    ["minecraft:emerald_ore"] = {0, 255, 0},
    ["ic2:resource"] = {0, 90, 0},
    ["appliedenergistics2:quartz_ore"] = {227, 252, 250},
    ["thermalfoundation:ore_fluid"] = {120, 23, 37}
}

function module.setup(ni)
    neural = ni
    c3d = neural.canvas3d()
end

function module.update(meta)
    if module.timeout < 3 then
        module.timeout = module.timeout + 0.1
        return
    end

    module.timeout = 0
    local blocks = neural.scan()

    if module.cached then
        c3d.clear()
        module.cached = false
    end

    local obj = c3d.create()

    for _, v in ipairs(blocks) do
        local color = ores[v.name]
        if color then
            local highlight = obj.addLine({0, -1, 0}, {v.x, v.y, v.z}, 3.0)
            highlight.setColor(table.unpack(color))
            highlight.setDepthTested(false)
            highlight.setAlpha(255)
            module.cached = true
        end
    end
end

return module
