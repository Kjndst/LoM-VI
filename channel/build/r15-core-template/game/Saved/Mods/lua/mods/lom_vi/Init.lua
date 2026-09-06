-- LoM-VI Core 0.2.0.4 runtime entrypoint.
-- Requires the existing LOMModLoader bootstrap or the LoM-VI standalone loader
-- installed by the thin-client migration path.
local Loader = assert(LOMModLoader, "LOMModLoader is required for LoM-VI")
local Factory = require("mods.lom_vi.BootstrapFactory")
local IdData = require("mods.lom_vi.IdOverrides")
local SafeLiterals = require("mods.lom_vi.SafeLiterals")
local UiLiterals = require("mods.lom_vi.UiLiterals")

local function report(message)
    local logger = Log or LaunchLog
    if logger and logger.Info then
        logger.Info("[LoM-VI] " .. tostring(message))
    elseif logger and logger.Error then
        logger.Error("[LoM-VI] " .. tostring(message))
    end
end

return Factory(Loader, IdData, SafeLiterals, UiLiterals, {
    version = "v0.2.0.4",
    dataPriority = 1100000,
    runtimePriority = 1100000,
    generatedPriority = 900000,
    maxScanDepth = 4,
    maxNodesPerRoot = 2048,
    report = report,
})
