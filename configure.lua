-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 27/08/2022.
--  All code (c) 2022, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

local useLocal = true --export: Use require() to load local scripts if present. Useful during development.
local logging = true  --export: Enable controller debug output.

modulaSettings = {
    name = "Auto Refiner",
    version = "1.0",
    logging = logging,
    useLocal = useLocal,
    modules = {
        ["samedicorp.modula.modules.industry"] = {},
        ["samedicorp.modula.modules.screen"] = {},
        ["samedicorp.auto-refiner.main"] = {}
    },
    templates = "samedicorp/auto-refiner/templates"
}
