-- LoM-VI runtime bootstrap factory.
-- Core 0.2.0.4 restores bounded NativeScan-style runtime coverage while keeping
-- exact-ID translation as the primary authority and English/Chinese as underlay.
--
-- Safety invariants:
--   * no substring/global replacement;
--   * exact literals only, plus tightly anchored contextual UI patterns;
--   * no per-frame polling;
--   * weak registries / idempotent wrappers;
--   * bounded recursive scans;
--   * existing package searcher order is preserved.

return function(Loader, IdData, SafeLiterals, UiLiterals, Options)
    assert(type(Loader) == "table" and type(Loader.AfterLoad) == "function", "LOMModLoader.AfterLoad is required")
    IdData = IdData or {}
    SafeLiterals = SafeLiterals or {}
    UiLiterals = UiLiterals or {}
    Options = Options or {}

    local aggregate = IdData.aggregateOverrides or {}
    local split = IdData.splitOverrides or {}
    local report = type(Options.report) == "function" and Options.report or function() end
    local marker = tostring(Options.version or "lom-vi-test")
    local dataPriority = tonumber(Options.dataPriority) or 1100000
    local runtimePriority = tonumber(Options.runtimePriority) or 1100000
    local generatedPriority = tonumber(Options.generatedPriority) or 900000
    local maxDepth = tonumber(Options.maxScanDepth) or 4
    local maxNodesPerRoot = tonumber(Options.maxNodesPerRoot) or 2048
    local unresolvedSeen = {}

    local unpack_ = unpack or table.unpack
    local function pack(...)
        return { n = select("#", ...), ... }
    end
    local function unpackPack(values)
        return unpack_(values, 1, values.n or #values)
    end

    local function hasCjk(value)
        return type(value) == "string" and value:find("[\228-\233][\128-\191][\128-\191]") ~= nil
    end

    local function getSymbol(value, environment, name)
        if type(value) == "table" then
            if value[name] ~= nil then return value[name] end
            if value.data ~= nil and name == "data" then return value.data end
        end
        if type(environment) == "table" and environment[name] ~= nil then
            return environment[name]
        end
        return nil
    end

    local function lookup(index, tag)
        if tag ~= nil then
            local values = split[tostring(tag)]
            if type(values) ~= "table" then return nil end
            return values[index] or values[tonumber(index)] or values[tostring(index)]
        end
        return aggregate[index] or aggregate[tonumber(index)] or aggregate[tostring(index)]
    end

    local function trim(value)
        if type(value) ~= "string" then return value end
        return (value:gsub("^%s+", ""):gsub("%s+$", ""))
    end

    -- Contextual strings that are assembled at runtime and therefore cannot be
    -- represented as an exact static StringDB row. Patterns are fully anchored.
    local function repairDynamicUiString(value)
        if type(value) ~= "string" then return nil end
        local clean = trim(value)
        if clean:match("^俱乐部%s*%d+%%$")
            or clean:match("^CLB%s*%d+%%$")
            or clean:match("^Câu Lạc Bộ%s*%d+%%$") then
            return "Loading..."
        end
        return nil
    end

    local function reportUnresolved(value, context)
        if not hasCjk(value) then return end
        local key = tostring(context or "") .. "\0" .. value
        if unresolvedSeen[key] then return end
        unresolvedSeen[key] = true
        report("unresolved CJK\t" .. tostring(context or "") .. "\t" .. value:gsub("\n", "\\n"))
    end

    -- Global/source-table repair: only literals proven safe outside a UI-only
    -- context. This is intentionally narrower than repairUiString().
    local function repairString(value, context)
        if type(value) ~= "string" then return value end
        local replacement = SafeLiterals[value]
        if replacement ~= nil then return replacement end
        reportUnresolved(value, context)
        return value
    end

    -- UI boundary repair: exact runtime/UI literals + exact safe literals + the
    -- small anchored dynamic set above. No substring replacement is performed.
    local function repairUiString(value, context)
        if type(value) ~= "string" then return value end
        local dynamic = repairDynamicUiString(value)
        if dynamic ~= nil then return dynamic end
        local replacement = UiLiterals[value]
        if replacement ~= nil then return replacement end
        replacement = SafeLiterals[value]
        if replacement ~= nil then return replacement end
        reportUnresolved(value, context)
        return value
    end

    local function repairValueWith(value, context, depth, seen, stringRepair)
        local kind = type(value)
        if kind == "string" then return stringRepair(value, context) end
        if kind ~= "table" or depth >= maxDepth then return value end
        seen = seen or {}
        if seen[value] then return value end
        seen[value] = true
        for key, child in pairs(value) do
            if type(key) ~= "table" and type(key) ~= "userdata" then
                local repaired = repairValueWith(child, tostring(context or "") .. "." .. tostring(key), depth + 1, seen, stringRepair)
                if repaired ~= child then rawset(value, key, repaired) end
            end
        end
        return value
    end

    local function repairValue(value, context, depth, seen)
        return repairValueWith(value, context, depth or 0, seen or {}, repairString)
    end

    local function repairUiValue(value, context, depth, seen)
        return repairValueWith(value, context, depth or 0, seen or {}, repairUiString)
    end

    local function applyMap(values, symbolName)
        return function(value, environment)
            local module = type(value) == "table" and value or getSymbol(value, environment, symbolName)
            if type(module) ~= "table" then return value end
            local data = type(module.data) == "table" and module.data or module
            for key, replacement in pairs(values) do data[key] = replacement end
            return value
        end
    end

    local applyAggregate = applyMap(aggregate, "StringDB_CN_Data")
    Loader.AfterLoad("Data.Excel.LanguageData.StringDB_CN_Data", applyAggregate, dataPriority, "lom-vi.aggregate-cn")
    Loader.AfterLoad("Data.Excel.LanguageData.StringDB_EN_Data", applyAggregate, dataPriority, "lom-vi.aggregate-en")

    -- Apply selected Vietnamese IDs directly to split StringDB modules as well.
    -- This avoids competing for Loader.Overlays with an existing English patch.
    for tag, values in pairs(split) do
        if type(tag) == "string" and type(values) == "table" then
            local cnName = "Data.Excel.LanguageData.StringDB_CN_Data_" .. tag
            local enName = "Data.Excel.LanguageData.StringDB_EN_Data_" .. tag
            Loader.AfterLoad(cnName, applyMap(values, "StringDB_CN_Data_" .. tag), dataPriority, "lom-vi.split-cn." .. tag)
            Loader.AfterLoad(enName, applyMap(values, "StringDB_EN_Data_" .. tag), dataPriority, "lom-vi.split-en." .. tag)
        end
    end

    Loader.AfterLoad("Framework.Utils.LuaCommon.Managers.TableDataManager", function(value, environment)
        local manager = getSymbol(value, environment, "TableDataManager") or value
        if type(manager) ~= "table" then return value end

        local registry = rawget(_G, "__LOMVI_MANAGER_HOOKS")
        if type(registry) ~= "table" then
            registry = setmetatable({}, { __mode = "k" })
            rawset(_G, "__LOMVI_MANAGER_HOOKS", registry)
        end
        if registry[manager] then return value end
        registry[manager] = true

        local originalGetLangStr = manager.GetLangStr
        local originalGetLangStrSplit = manager.GetLangStrSplit
        local originalGetRow = manager.GetRow
        local originalGetAttr = manager.GetAttr

        if type(originalGetLangStr) == "function" then
            function manager:GetLangStr(index)
                local replacement = lookup(index, nil)
                if replacement ~= nil then return replacement end
                local ok, result = pcall(originalGetLangStr, self, index)
                if ok and result ~= nil then return repairString(result, "GetLangStr:" .. tostring(index)) end
                if type(index) == "string" then return repairString(index, "GetLangStr:key") end
                return nil
            end
        end

        if type(originalGetLangStrSplit) == "function" then
            function manager:GetLangStrSplit(index, tag)
                local replacement = lookup(index, tag)
                if replacement ~= nil then return replacement end
                local ok, result = pcall(originalGetLangStrSplit, self, index, tag)
                if ok and result ~= nil then
                    return repairString(result, "GetLangStrSplit:" .. tostring(tag) .. ":" .. tostring(index))
                end
                if type(index) == "string" then return repairString(index, "GetLangStrSplit:key") end
                return nil
            end
        end

        if type(originalGetRow) == "function" then
            function manager:GetRow(tableName, rowKey, priority)
                local prefix = "LanguageData.StringDB_CN_Data"
                if type(tableName) == "string" then
                    local pos = tableName:find(prefix, 1, true)
                    if pos then
                        local suffix = tableName:sub(pos + #prefix)
                        local tag = suffix:sub(1, 1) == "_" and suffix:sub(2) or nil
                        if tag == "" then tag = nil end
                        local replacement = lookup(rowKey, tag)
                        if replacement ~= nil then return replacement end
                    end
                end
                local result = originalGetRow(self, tableName, rowKey, priority)
                return repairValue(result, tostring(tableName) .. ":" .. tostring(rowKey), 0, {})
            end
        end

        if type(originalGetAttr) == "function" then
            function manager:GetAttr(tableName, attrKey)
                local result = originalGetAttr(self, tableName, attrKey)
                return repairValue(result, tostring(tableName) .. ":" .. tostring(attrKey), 0, {})
            end
        end

        report("LoM-VI localization manager hooks installed")
        return value
    end, runtimePriority, "lom-vi.localization")

    local function wrapGeneratedRows(tableData, source)
        if type(tableData) ~= "table" then return 0 end
        local registry = rawget(_G, "__LOMVI_ROW_HOOKS")
        if type(registry) ~= "table" then
            registry = setmetatable({}, { __mode = "k" })
            rawset(_G, "__LOMVI_ROW_HOOKS", registry)
        end
        if registry[tableData] then return 0 end
        registry[tableData] = true

        local wrapped = 0
        for name, member in pairs(tableData) do
            if type(name) == "string" and type(member) == "function" and name:match("^Get.+Row$") then
                local original = member
                tableData[name] = function(...)
                    local results = pack(original(...))
                    for i = 1, results.n do
                        results[i] = repairValue(results[i], tostring(source) .. "." .. name .. ".return" .. tostring(i), 0, {})
                    end
                    return unpackPack(results)
                end
                wrapped = wrapped + 1
            end
        end
        if wrapped > 0 then report("LoM-VI generated-row hooks=" .. tostring(wrapped) .. " source=" .. tostring(source)) end
        return wrapped
    end

    Loader.AfterLoad("Data.Excel.TableData", function(value, environment)
        local tableData = getSymbol(value, environment, "TableData") or value
        wrapGeneratedRows(tableData, "Data.Excel.TableData")
        return value
    end, runtimePriority, "lom-vi.generated-rows")

    Loader.AfterLoad("Gameplay.LogicSystem.SkillCustomizer.SkillCustomSystem", function(value, environment)
        local system = getSymbol(value, environment, "SkillCustomSystem") or value
        if type(system) ~= "table" then return value end
        local registry = rawget(_G, "__LOMVI_GENERATED_SKILL_HOOKS")
        if type(registry) ~= "table" then
            registry = setmetatable({}, { __mode = "k" })
            rawset(_G, "__LOMVI_GENERATED_SKILL_HOOKS", registry)
        end
        if registry[system] then return value end
        registry[system] = true
        for _, methodName in ipairs({"GenerateSkillDescNoRichText", "GenerateSkillBriefDesc", "GenerateSkillDecoText"}) do
            local original = system[methodName]
            if type(original) == "function" then
                system[methodName] = function(self, ...)
                    local results = pack(original(self, ...))
                    for i = 1, results.n do
                        results[i] = repairValue(results[i], "SkillCustomSystem." .. methodName .. ".return" .. tostring(i), 0, {})
                    end
                    return unpackPack(results)
                end
            end
        end
        report("LoM-VI generated skill hooks installed")
        return value
    end, generatedPriority, "lom-vi.generated-skill")

    ---------------------------------------------------------------------------
    -- NativeScan-style UI boundary instrumentation
    ---------------------------------------------------------------------------

    local instrumentedTables = setmetatable({}, { __mode = "k" })
    local wrappedFunctions = setmetatable({}, { __mode = "k" })
    local widgetRepairBusy = setmetatable({}, { __mode = "k" })

    local setterNames = {
        SetText = true, SetTitle = true, SetDesc = true, SetDescription = true,
        SetContent = true, SetLabel = true, SetCaption = true, SetTip = true,
        SetTooltip = true, SetHint = true, SetNameText = true,
    }
    local getterNames = {
        GetText = true, GetTitle = true, GetDesc = true, GetDescription = true,
        GetContent = true, GetLabel = true, GetCaption = true, GetTip = true,
        GetTooltip = true, GetHint = true, GetNameText = true,
    }
    local lifecycleNames = {
        Refresh = true, OnRefresh = true, OnShow = true, OnOpen = true,
        SetData = true, SetInfo = true, SetValue = true, UpdateView = true,
        UpdateData = true, RefreshView = true, RefreshData = true, OnDataChanged = true,
    }
    local getterSetterPairs = {
        {"GetText", "SetText"}, {"GetTitle", "SetTitle"},
        {"GetDesc", "SetDesc"}, {"GetDescription", "SetDescription"},
        {"GetContent", "SetContent"}, {"GetLabel", "SetLabel"},
        {"GetCaption", "SetCaption"}, {"GetTip", "SetTip"},
        {"GetTooltip", "SetTooltip"}, {"GetHint", "SetHint"},
        {"GetNameText", "SetNameText"},
    }

    local function repairWidget(widget, context)
        local kind = type(widget)
        if kind ~= "table" and kind ~= "userdata" then return 0 end
        if widgetRepairBusy[widget] then return 0 end
        widgetRepairBusy[widget] = true
        local changed = 0

        for _, pair in ipairs(getterSetterPairs) do
            local okGetter, getter = pcall(function() return widget[pair[1]] end)
            local okSetter, setter = pcall(function() return widget[pair[2]] end)
            if okGetter and okSetter and type(getter) == "function" and type(setter) == "function" then
                local okGet, current = pcall(getter, widget)
                if okGet and type(current) == "string" then
                    local repaired = repairUiString(current, tostring(context) .. "." .. pair[1])
                    if repaired ~= current then
                        local okSet = pcall(setter, widget, repaired)
                        if okSet then changed = changed + 1 end
                    end
                end
            end
        end

        -- Some Lua-side views expose text as fields instead of methods.
        if kind == "table" then
            for _, key in ipairs({"Text", "Title", "Desc", "Description", "Content", "Label", "Caption", "Hint"}) do
                local current = rawget(widget, key)
                if type(current) == "string" then
                    local repaired = repairUiString(current, tostring(context) .. "." .. key)
                    if repaired ~= current then
                        rawset(widget, key, repaired)
                        changed = changed + 1
                    end
                end
            end
        end

        widgetRepairBusy[widget] = nil
        return changed
    end

    local instrumentGraph

    local function wrapMethod(owner, name, original, mode, source)
        if wrappedFunctions[original] then return false end
        local wrapper

        if mode == "setter" then
            wrapper = function(...)
                local args = pack(...)
                for i = 2, args.n do
                    args[i] = repairUiValue(args[i], tostring(source) .. "." .. name .. ".arg" .. tostring(i), 0, {})
                end
                local results = pack(original(unpackPack(args)))
                return unpackPack(results)
            end
        elseif mode == "getter" then
            wrapper = function(...)
                local results = pack(original(...))
                for i = 1, results.n do
                    results[i] = repairUiValue(results[i], tostring(source) .. "." .. name .. ".return" .. tostring(i), 0, {})
                end
                return unpackPack(results)
            end
        else -- lifecycle
            wrapper = function(...)
                local args = pack(...)
                for i = 2, args.n do
                    args[i] = repairUiValue(args[i], tostring(source) .. "." .. name .. ".arg" .. tostring(i), 0, {})
                end
                local results = pack(original(unpackPack(args)))
                for i = 1, results.n do
                    results[i] = repairUiValue(results[i], tostring(source) .. "." .. name .. ".return" .. tostring(i), 0, {})
                end
                local self = args[1]
                repairWidget(self, tostring(source) .. "." .. name .. ".widget")
                if type(self) == "table" or type(self) == "userdata" then
                    instrumentGraph(self, tostring(source) .. "." .. name .. ".self", 1, {}, { nodes = 0 })
                end
                return unpackPack(results)
            end
        end

        rawset(owner, name, wrapper)
        wrappedFunctions[wrapper] = true
        return true
    end

    instrumentGraph = function(value, source, depth, seen, budget)
        local kind = type(value)
        if kind ~= "table" and kind ~= "userdata" then return 0 end
        depth = depth or 0
        if depth > maxDepth then return 0 end
        seen = seen or {}
        budget = budget or { nodes = 0 }
        if seen[value] then return 0 end
        seen[value] = true
        budget.nodes = budget.nodes + 1
        if budget.nodes > maxNodesPerRoot then return 0 end

        local changed = 0
        local target = value
        if kind == "userdata" then
            local ok, mt = pcall(getmetatable, value)
            if not ok or type(mt) ~= "table" then return 0 end
            target = mt
        end

        if not instrumentedTables[target] then
            instrumentedTables[target] = true
            for name, member in pairs(target) do
                if type(name) == "string" and type(member) == "function" then
                    if setterNames[name] then
                        if wrapMethod(target, name, member, "setter", source) then changed = changed + 1 end
                    elseif getterNames[name] then
                        if wrapMethod(target, name, member, "getter", source) then changed = changed + 1 end
                    elseif lifecycleNames[name] then
                        if wrapMethod(target, name, member, "lifecycle", source) then changed = changed + 1 end
                    end
                end
            end
        end

        if kind == "table" then
            -- Repair globally safe source-table literals, then walk descendants.
            for key, child in pairs(value) do
                if type(child) == "string" then
                    local repaired = repairString(child, tostring(source) .. "." .. tostring(key))
                    if repaired ~= child then
                        value[key] = repaired
                        changed = changed + 1
                    end
                elseif (type(child) == "table" or type(child) == "userdata") and depth < maxDepth then
                    if child ~= _G and child ~= package and child ~= string and child ~= table
                        and child ~= math and child ~= os and child ~= io and child ~= debug
                        and child ~= coroutine then
                        changed = changed + instrumentGraph(child, tostring(source) .. "." .. tostring(key), depth + 1, seen, budget)
                    end
                end
            end
            local mt = getmetatable(value)
            if type(mt) == "table" and mt ~= _G and depth < maxDepth then
                changed = changed + instrumentGraph(mt, tostring(source) .. ".<metatable>", depth + 1, seen, budget)
            end
        end

        repairWidget(value, tostring(source) .. ".visible")
        return changed
    end

    local function scanLoadedModules()
        local roots = 0
        local changed = 0
        local rootSeen = setmetatable({}, { __mode = "k" })

        if Game and type(Game.loaded) == "table" then
            for name, entry in pairs(Game.loaded) do
                if type(entry) == "table" then
                    for _, root in ipairs({entry.Ret, entry.ENV}) do
                        if (type(root) == "table" or type(root) == "userdata") and root ~= _G and not rootSeen[root] then
                            rootSeen[root] = true
                            roots = roots + 1
                            repairValue(root, "Game.loaded." .. tostring(name), 0, {})
                            changed = changed + instrumentGraph(root, "Game.loaded." .. tostring(name), 0, {}, {nodes = 0})
                        end
                    end
                end
            end
        end

        if package and type(package.loaded) == "table" then
            for name, root in pairs(package.loaded) do
                if (type(root) == "table" or type(root) == "userdata") and root ~= _G and not rootSeen[root] then
                    rootSeen[root] = true
                    roots = roots + 1
                    repairValue(root, "package.loaded." .. tostring(name), 0, {})
                    changed = changed + instrumentGraph(root, "package.loaded." .. tostring(name), 0, {}, {nodes = 0})
                end
            end
        end

        report("LoM-VI NativeScan roots=" .. tostring(roots) .. " changes=" .. tostring(changed))
        return roots, changed
    end

    -- Preserve the existing searcher order (including an English patch searcher)
    -- while observing future Lua modules. We replace each function in-place;
    -- no new higher-priority searcher is inserted here.
    local function instrumentFutureModules()
        local globalState = rawget(_G, "__LOMVI_NATIVE_SCAN_STATE")
        if type(globalState) ~= "table" then
            globalState = { searchers = setmetatable({}, {__mode = "k"}) }
            rawset(_G, "__LOMVI_NATIVE_SCAN_STATE", globalState)
        end

        local function wrapSearcherTable(searchers)
            if type(searchers) ~= "table" or globalState.searchers[searchers] then return 0 end
            globalState.searchers[searchers] = true
            local wrapped = 0
            for index, searcher in ipairs(searchers) do
                if type(searcher) == "function" and not wrappedFunctions[searcher] then
                    local originalSearcher = searcher
                    local wrapper = function(name)
                        local found = pack(originalSearcher(name))
                        if type(found[1]) == "function" then
                            local originalChunk = found[1]
                            found[1] = function(...)
                                local results = pack(originalChunk(...))
                                local env = nil
                                if type(getfenv) == "function" then
                                    local okEnv, gotEnv = pcall(getfenv, originalChunk)
                                    if okEnv then env = gotEnv end
                                end
                                for i = 1, results.n do
                                    local root = results[i]
                                    if type(root) == "table" or type(root) == "userdata" then
                                        repairValue(root, "module." .. tostring(name) .. ".return" .. tostring(i), 0, {})
                                        instrumentGraph(root, "module." .. tostring(name) .. ".return" .. tostring(i), 0, {}, {nodes = 0})
                                    elseif type(root) == "string" then
                                        results[i] = repairString(root, "module." .. tostring(name) .. ".return" .. tostring(i))
                                    end
                                end
                                if type(env) == "table" and env ~= _G then
                                    repairValue(env, "module." .. tostring(name) .. ".env", 0, {})
                                    instrumentGraph(env, "module." .. tostring(name) .. ".env", 0, {}, {nodes = 0})
                                end
                                return unpackPack(results)
                            end
                        end
                        return unpackPack(found)
                    end
                    searchers[index] = wrapper
                    wrappedFunctions[wrapper] = true
                    wrapped = wrapped + 1
                end
            end
            return wrapped
        end

        local wrapped = 0
        if package then
            wrapped = wrapped + wrapSearcherTable(package.loaders)
            if package.searchers ~= package.loaders then
                wrapped = wrapped + wrapSearcherTable(package.searchers)
            end
        end
        report("LoM-VI future-module searchers wrapped=" .. tostring(wrapped))
        return wrapped
    end

    instrumentFutureModules()
    scanLoadedModules()

    return {
        lookup = lookup,
        repairString = repairString,
        repairUiString = repairUiString,
        repairValue = repairValue,
        repairUiValue = repairUiValue,
        repairWidget = repairWidget,
        instrumentGraph = instrumentGraph,
        scanLoadedModules = scanLoadedModules,
        unresolved = unresolvedSeen,
        version = marker,
    }
end
