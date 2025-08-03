	-- Hellscaped's Minit Xray Module https://p.reconnected.cc/bkMhRFmwc

	local module = {

	    name = "xray",

	    cached = true,

	    timeout = 0

	}

	 

	local neural,c3d

	 

	local targets = {

	    ["minecraft:ancient_debris"] = {150, 75, 0},

	    ["minecraft:deepslate_diamond_ore"] = {63, 195, 235},

	    ["minecraft:deepslate_emerald_ore"] = {0, 255, 0},

	    ["minecraft:deepslate_gold_ore"] = {255, 255, 0},

	--    ["minecraft:deepslate_iron_ore"] = {255, 0, 0},

	--    ["minecraft:deepslate_lapis_ore"] = {0, 0, 255},

	    ["minecraft:deepslate_redstone_ore"] = {255, 0, 0},

	    ["minecraft:diamond_ore"] = {63, 195, 236},

	    ["minecraft:emerald_ore"] = {0, 255, 0},

	    ["minecraft:gold_ore"] = {255, 255, 0},

	--    ["minecraft:iron_ore"] = {255, 0, 0},

	--    ["minecraft:lapis_ore"] = {0, 0, 255},

	    ["minecraft:redstone_ore"] = {255, 0, 0},

	    ["minecraft:nether_gold_ore"] = {255, 255, 0},

	    ["minecraft:nether_quartz_ore"] = {255, 255, 255},

	    ["computercraft:turtle_normal"] = {120, 124, 153},

	    ["minecraft:chest"] = { 158, 132, 66 },

	    ["minecraft:wet_sponge"] = { 140, 158, 66},

	    ["minecraft:sponge"] = { 196, 176, 120 },

	--    ["minecraft:mossy_cobblestone"] = { 140, 158,66},

	    ["minecraft:suspicious_gravel"] = { 196, 176, 120 },

	    ["minecraft:suspicious_sand"] = { 196, 176, 120 }

	}

	 

	function module.setup(ni)

	    neural = ni

	    c3d = neural.canvas3d()

	end

	 

	function module.update(meta)

	    if module.timeout < 3 then

	--        print(module.timeout)

	        module.timeout = module.timeout + 0.1

	        return

	    end

	    module.timeout = 0

	    local blks = neural.scan()

	    if module.cached then

	        c3d.clear()

	        module.cached = false

	    end

	    local obj = c3d.create()

	    for _,v in ipairs(blks) do

	        if targets[v.name] then

	--            if v.name == "minecraft:spawner" then

	--                print(v.y)

	  --          end

	            local highlight = obj.addBox(v.x-0.6,v.y-0.6,v.z-0.6, 1.2, 1.2, 1.2)

	            highlight.setColor(table.unpack(targets[v.name]))

	            highlight.setDepthTested(false)

	            highlight.setAlpha(64)

	            module.cached = true

	        end

	    end

	end

	 

	return module