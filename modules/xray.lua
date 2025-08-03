-- xray script from https://plethora.madefor.cc/examples/ore-scanner.html

-- ==== Configuration ====
local scanInterval = 0.2
local renderInterval = 0.05
local scannerRange = 8
local scannerWidth = scannerRange * 2 + 1

local size = 0.5
local cellSize = 16
local offsetX, offsetY = 75, 75

local module = {
    name = "xray",
}

local orePriority = {
    ["minecraft:diamond_ore"] = 10,
    ["minecraft:deepslate_diamond_ore"] = 10,
    ["minecraft:emerald_ore"] = 10,
    ["minecraft:deepslate_emerald_ore"] = 10,
    ["minecraft:ancient_debris"] = 9,
    ["minecraft:gold_ore"] = 8,
    ["minecraft:deepslate_gold_ore"] = 8,
    ["minecraft:nether_gold_ore"] = 8,
    ["minecraft:redstone_ore"] = 5,
    ["minecraft:deepslate_redstone_ore"] = 5,
    ["minecraft:lapis_ore"] = 5,
    ["minecraft:deepslate_lapis_ore"] = 5,
    ["minecraft:iron_ore"] = 2,
    ["minecraft:deepslate_iron_ore"] = 2,
    ["minecraft:copper_ore"] = 2,
    ["minecraft:deepslate_copper_ore"] = 2,
    ["minecraft:coal_ore"] = 1,
    ["minecraft:deepslate_coal_ore"] = 1,
    ["minecraft:nether_quartz_ore"] = 1
}

local oreColors = {
    ["minecraft:coal_ore"] = {150, 150, 150},
    ["minecraft:deepslate_coal_ore"] = {100, 100, 100},
    ["minecraft:iron_ore"] = {255, 150, 50},
    ["minecraft:deepslate_iron_ore"] = {200, 120, 40},
    ["minecraft:copper_ore"] = {255, 120, 0},
    ["minecraft:deepslate_copper_ore"] = {200, 100, 0},
    ["minecraft:gold_ore"] = {255, 255, 0},
    ["minecraft:deepslate_gold_ore"] = {200, 200, 0},
    ["minecraft:nether_gold_ore"] = {255, 220, 0},
    ["minecraft:diamond_ore"] = {0, 255, 255},
    ["minecraft:deepslate_diamond_ore"] = {0, 200, 200},
    ["minecraft:redstone_ore"] = {255, 0, 0},
    ["minecraft:deepslate_redstone_ore"] = {200, 0, 0},
    ["minecraft:lapis_ore"] = {0, 50, 255},
    ["minecraft:deepslate_lapis_ore"] = {0, 30, 200},
    ["minecraft:emerald_ore"] = {0, 255, 0},
    ["minecraft:deepslate_emerald_ore"] = {0, 200, 0},
    ["minecraft:nether_quartz_ore"] = {255, 255, 255},
    ["minecraft:ancient_debris"] = {128, 0, 64}
}

-- ==== Peripheral Setup ====
local ni = peripheral.find("neuralInterface")
if not ni then error("Neural interface not found.", 0) end
if not ni.hasModule("plethora:scanner") then error("Block scanner module required.", 0) end
if not ni.hasModule("plethora:glasses") then error("Overlay glasses module required.", 0) end

local canvas = ni.canvas()
canvas.clear()

-- ==== Minimap Grid Setup ====
local blocks, texts = {}, {}
for x = -scannerRange, scannerRange do
    blocks[x], texts[x] = {}, {}
    for z = -scannerRange, scannerRange do
        blocks[x][z] = {block = nil, y = nil}
        texts[x][z] = canvas.addText({0, 0}, " ", 0xFFFFFFFF, size)
    end
end

canvas.addText({ offsetX, offsetY }, "^", 0xFFFFFFFF, size * 2)

local radius = scannerRange * cellSize * size + cellSize / 2
canvas.addCircle({offsetX, offsetY}, radius, 0xFFFFFF)

-- ==== Scan Function ====
local function scan()
    while true do
        local scanned = ni.scan()
        for x = -scannerRange, scannerRange do
            for z = -scannerRange, scannerRange do
                local bestBlock, bestY, bestScore = nil, nil, -1

                for y = -scannerRange, scannerRange do
                    local i = scannerWidth ^ 2 * (x + scannerRange) +
                              scannerWidth * (y + scannerRange) +
                              (z + scannerRange) + 1
                    local blk = scanned[i]
                    if blk then
                        local score = orePriority[blk.name]
                        if score and score > bestScore then
                            bestBlock, bestY, bestScore = blk.name, y, score
                        end
                    end
                end

                blocks[x][z].block = bestBlock
                blocks[x][z].y = bestY
            end
        end
        sleep(scanInterval)
    end
end

-- ==== Render Function ====
local function render()
    while true do
        local meta = ni.getMetaOwner and ni.getMetaOwner()
        local yaw = meta and meta.yaw or 180
        local angle = math.rad(-yaw % 360)

        for x = -scannerRange, scannerRange do
            for z = -scannerRange, scannerRange do
                local block = blocks[x][z]
                local text = texts[x][z]

                if block.block then
                    local px = math.cos(angle) * -x - math.sin(angle) * -z
                    local py = math.sin(angle) * -x + math.cos(angle) * -z

                    local sx = math.floor(px * size * cellSize)
                    local sy = math.floor(py * size * cellSize)

                    text.setPosition(offsetX + sx, offsetY + sy)
                    text.setText(tostring(block.y))
                    text.setColor(table.unpack(oreColors[block.block] or {255, 255, 255}))
                else
                    text.setText(" ")
                end
            end
        end

        sleep(renderInterval)
    end
end

-- ==== Run Everything ====
parallel.waitForAll(scan, render)
