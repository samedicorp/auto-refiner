-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 27/08/2022.
--  All code (c) 2022, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

-- If setting up manually, add the following handler to any connected screens:
-- local failure = modula:call("onScreenReply", output)
-- if failure then
--     error(failure)
-- end

local Module = {}

function Module:register(parameters)
    modula:registerForEvents(self, "onStart", "onStop", "onCheckMachines", "onCommand")
    self.logMachines = parameters.logMachines or false
end

-- ---------------------------------------------------------------------
-- Event handlers
-- ---------------------------------------------------------------------

function Module:onStart()
    debugf("Auto Refiner started.")

    self:attachToScreen()
    local industry = modula:getService("industry")
    self.industry = industry

    self.recipes = {
        2240749601, -- Pure Aluminium
        2112763718, -- Pure Calcium
        159858782,  -- Pure Carbon
        -- 2031444137, -- Pure Cobalt
        1466453887, -- Pure Copper
        2147954574, -- Pure Chromium
        -- 3323724376, -- Pure Flourine
        -- 3837955371, -- Pure Gold
        -- 1010524904, -- Pure Hydrogen
        198782496, -- Pure Iron
        -- 3810111622, -- Pure Lithium
        -- 2421303625, -- Pure Manganese
        -- 3012303017, -- Pure Nickel
        -- 1126600143, -- Pure Niobium
        -- 947806142,  -- Pure Oxygen
        -- 3211418846, -- Pure Scandium
        2589986891, -- Pure Silicon
        -- 1807690770, -- Pure Silver
        3603734543, -- Pure Sodium
        -- 3822811562, -- Pure Sulfur
        -- 752542080,  -- Pure Titanium
        -- 2007627267, -- Pure Vanadium
    }

    modula:addTimer("onCheckMachines", 1.0)

    self:attachToScreen()

    if self.logMachines then
        industry:reportMachines()
    end

    self:restartMachines()
end

function Module:onStop()
    debugf("Auto Refiner stopped.")
end

function Module:onContainerChanged(container)
    self.screen:send({ name = container:name(), value = container.percentage })
end

function Module:onScreenReply(reply)
end

function Module:onCheckMachines()
    self:restartMachines()
end

function Module:restartMachines()
    local industry = self.industry
    if industry then
        industry:withMachines(function(machine)
            if machine:label():find("Refiner") then
                self:restartMachine(machine)
            end
        end)
    end
end

function Module:restartMachine(machine)
    if machine:isStopped() or machine:isMissingIngredients() or machine:isMissingSchematics() or machine:isPending() then
        local index = (1 + (machine.index or 0) % #self.recipes)
        machine.index = index
        local recipe = self.recipes[index]

        if not machine:isStopped() then
            machine:stop()
        end

        if machine:setRecipe(recipe) == 0 then
            machine:start()
            machine.target = recipe
        end
    elseif machine:isRunning() then
        if machine.actual ~= machine.target then
            debugf("Switched to '%s' for %s.", system.getItem(recipe).locDisplayName, machine:name())
            machine.actual = machine.target
        end
    end
end

function Module:onCommand(command, parameters)
    if command == "list" then
        local industry = modula:getService("industry")
        if industry then
            local machines = industry:getMachines()
            for i, machine in ipairs(machines) do
                debugf("%s, -- %s", machine.mainProduct.id, machine.mainProduct.name)
            end
        else
            debugf("No industry service found.")
        end
    end
end

-- ---------------------------------------------------------------------
-- Internal
-- ---------------------------------------------------------------------

function Module:attachToScreen()
    -- TODO: send initial container data as part of render script
    local service = modula:getService("screen")
    if service then
        local screen = service:registerScreen(self, false, self.renderScript)
        if screen then
            self.screen = screen
        end
    end
end

Module.renderScript = [[

containers = containers or {}

if payload then
    local name = payload.name
    if name then
        containers[name] = payload
    end
    reply = { name = name, result = "ok" }
end

local screen = toolkit.Screen.new()
local layer = screen:addLayer()
local chart = layer:addChart(layer.rect:inset(10), containers, "Play")

layer:render()
screen:scheduleRefresh()
]]

return Module
