-- LoM-VI standalone loader 0.2.0.4.
-- Used only when migrating the historical LoM-VI sparse/native bridge.
-- English Patch LOMModLoader installations keep their existing bootstrap byte-for-byte.

local File = import("LuaFunctionLibrary")
local Paths = import("BlueprintPathsLibrary")
local root = File.GetFilePath(Paths.ProjectSavedDir()) .. "/Mods/"

local Loader = {
    Version = "0.2.0.4",
    Root = root,
    Hooks = {},
    Applied = {},
}
_G.LOMModLoader = Loader

local function report(message)
    local logger = Log or LaunchLog
    if logger and logger.Error then
        logger.Error("[LoM-VI loader] " .. tostring(message))
    end
end

local function info(message)
    local logger = Log or LaunchLog
    if logger and logger.Info then
        logger.Info("[LoM-VI loader] " .. tostring(message))
    end
end

local function read_chunk(relative, chunk_name)
    local path = root .. relative
    if type(loadfile) == "function" then
        local chunk = loadfile(path)
        if chunk then return chunk, path end
    end
    local source = File.LoadFile(path)
    if source == nil or source == "" then return nil, "missing " .. path end
    local chunk, message = load(source, "@" .. (chunk_name or path))
    if not chunk then return nil, message end
    return chunk, path
end

local function module_relative(name)
    if type(name) ~= "string" or name:find("[^%w_%.]") or name:find("..", 1, true) then return nil end
    if name:sub(1, 12) ~= "mods.lom_vi." and name ~= "mods.lom_vi.Init" then return nil end
    return "lua/" .. name:gsub("%.", "/") .. ".lua"
end

local registration_order = 0
local function sort_hooks(hooks)
    table.sort(hooks, function(a, b)
        if a.Priority == b.Priority then return a.Order < b.Order end
        return a.Priority < b.Priority
    end)
end

function Loader.Apply(name, value, environment)
    local hooks = Loader.Hooks[name]
    if not hooks then return value end
    for _, hook in ipairs(hooks) do
        local ok, replacement = xpcall(function()
            return hook.Callback(value, environment, name)
        end, function(message)
            report("post-load hook " .. tostring(hook.Id) .. " failed: " .. tostring(message))
            return message
        end)
        if ok and replacement ~= nil then value = replacement end
    end
    Loader.Applied[name] = (Loader.Applied[name] or 0) + 1
    return value
end

function Loader.Reapply(name)
    local game_loaded = Game and Game.loaded and Game.loaded[name]
    if game_loaded then
        local value = game_loaded.Ret ~= nil and game_loaded.Ret or game_loaded.ENV
        local replacement = Loader.Apply(name, value, game_loaded.ENV)
        if game_loaded.Ret ~= nil then game_loaded.Ret = replacement end
        if package.loaded[name] ~= nil then package.loaded[name] = replacement end
        return true
    elseif package.loaded[name] ~= nil then
        package.loaded[name] = Loader.Apply(name, package.loaded[name], _G)
        return true
    end
    return false
end

function Loader.AfterLoad(name, callback, priority, id)
    assert(type(name) == "string" and type(callback) == "function")
    registration_order = registration_order + 1
    local hooks = Loader.Hooks[name] or {}
    Loader.Hooks[name] = hooks
    hooks[#hooks + 1] = {
        Callback = callback,
        Priority = tonumber(priority) or 0,
        Id = id or (name .. "#" .. registration_order),
        Order = registration_order,
    }
    sort_hooks(hooks)
    Loader.Reapply(name)
end

local searchers = package.loaders or package.searchers
assert(type(searchers) == "table", "Lua package searchers are unavailable")
local original_searchers = {}
for index, searcher in ipairs(searchers) do original_searchers[index] = searcher end

local function find_original_chunk(name)
    for _, searcher in ipairs(original_searchers) do
        local chunk = searcher(name)
        if type(chunk) == "function" then return chunk end
    end
    return nil
end
Loader.FindOriginalChunk = find_original_chunk

local function lomvi_searcher(name)
    local relative = module_relative(name)
    if relative then
        local chunk, message = read_chunk(relative, name)
        if not chunk then
            report("external module " .. tostring(name) .. " failed: " .. tostring(message))
            return "\n\t" .. tostring(message)
        end
        return function(...)
            setfenv(chunk, getfenv(1))
            return chunk(...)
        end
    end

    if Loader.Hooks[name] then
        local chunk = find_original_chunk(name)
        if chunk then
            return function(...)
                local environment = getfenv(1)
                setfenv(chunk, environment)
                return Loader.Apply(name, chunk(...), environment)
            end
        end
    end
    return "\n\tno LoM-VI mapping for " .. tostring(name)
end

table.insert(searchers, 1, lomvi_searcher)
Loader.Searcher = lomvi_searcher

local manifest_chunk, manifest_error = read_chunk("manifest.lua", "LoM-VI manifest")
if not manifest_chunk then error("LoM-VI manifest failed: " .. tostring(manifest_error)) end
setfenv(manifest_chunk, _G)
local ok, manifest = xpcall(manifest_chunk, debug.traceback)
if not ok or type(manifest) ~= "table" then
    error("LoM-VI manifest invalid: " .. tostring(manifest))
end
Loader.Manifest = manifest

for _, name in ipairs(manifest.Load or {}) do
    local loaded, message = xpcall(function() return require(name) end, debug.traceback)
    if not loaded then report("entry module " .. tostring(name) .. " failed: " .. tostring(message)) end
end

info("standalone loader active")
return Loader
