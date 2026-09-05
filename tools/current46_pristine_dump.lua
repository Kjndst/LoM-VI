-- LoM-VI one-shot pristine corpus dumper.
-- Reads the original Lua chunks through LOMModLoader and serializes them with
-- string.dump(). It never executes the original chunks and never changes game data.
local Loader = assert(LOMModLoader, "LOMModLoader is required")
local AUDIT_ID = "current46-pristine-bytecode-20260905-v2-immediate"
local PREFIX = "lomvi-current46-dump-"
local MODULES = {
  "Data.Config.Ksbc.KsbcIgnore",
  "Data.Config.StringConst.Language_zhs",
  "Data.Excel.LanguageData.StringDB_CN_Data",
  "Data.Excel.LanguageData.StringDB_CN_Data_achievement",
  "Data.Excel.LanguageData.StringDB_CN_Data_asidetalk",
  "Data.Excel.LanguageData.StringDB_CN_Data_aura",
  "Data.Excel.LanguageData.StringDB_CN_Data_beckland",
  "Data.Excel.LanguageData.StringDB_CN_Data_buffappear",
  "Data.Excel.LanguageData.StringDB_CN_Data_buffdata",
  "Data.Excel.LanguageData.StringDB_CN_Data_debug",
  "Data.Excel.LanguageData.StringDB_CN_Data_gossip",
  "Data.Excel.LanguageData.StringDB_CN_Data_guide",
  "Data.Excel.LanguageData.StringDB_CN_Data_itemgift",
  "Data.Excel.LanguageData.StringDB_CN_Data_itemlife",
  "Data.Excel.LanguageData.StringDB_CN_Data_itemnormal",
  "Data.Excel.LanguageData.StringDB_CN_Data_itemoutlook",
  "Data.Excel.LanguageData.StringDB_CN_Data_itemtask",
  "Data.Excel.LanguageData.StringDB_CN_Data_lettertext",
  "Data.Excel.LanguageData.StringDB_CN_Data_loading",
  "Data.Excel.LanguageData.StringDB_CN_Data_main",
  "Data.Excel.LanguageData.StringDB_CN_Data_maintask",
  "Data.Excel.LanguageData.StringDB_CN_Data_manor",
  "Data.Excel.LanguageData.StringDB_CN_Data_monsterskill",
  "Data.Excel.LanguageData.StringDB_CN_Data_newbietask",
  "Data.Excel.LanguageData.StringDB_CN_Data_newspaper",
  "Data.Excel.LanguageData.StringDB_CN_Data_nocamera",
  "Data.Excel.LanguageData.StringDB_CN_Data_oldtalk",
  "Data.Excel.LanguageData.StringDB_CN_Data_othertalk",
  "Data.Excel.LanguageData.StringDB_CN_Data_sidetask",
  "Data.Excel.LanguageData.StringDB_CN_Data_skill",
  "Data.Excel.LanguageData.StringDB_CN_Data_skill1",
  "Data.Excel.LanguageData.StringDB_CN_Data_skill2",
  "Data.Excel.LanguageData.StringDB_CN_Data_skill3",
  "Data.Excel.LanguageData.StringDB_CN_Data_spellfield",
  "Data.Excel.LanguageData.StringDB_CN_Data_talk",
  "Data.Excel.LanguageData.StringDB_CN_Data_talkother",
  "Data.Excel.LanguageData.StringDB_CN_Data_tingen",
  "Data.Excel.LanguageData.StringDB_CN_Data_tingentalk",
  "Data.Excel.LanguageData.StringDB_CN_Data_traingame",
  "Data.Excel.LanguageData.StringDB_CN_Data_trap",
  "Data.Excel.RoleCreateQandAData",
  "Framework.Utils.LuaCommon.Managers.TableDataManager",
  "Gameplay.Debug.DebugConst",
  "Gameplay.LogicSystem.CreateRole.CreateRoleAnswer_Panel",
  "Launch.I18n.zh",
  "Shared.language_zhs",
}

local function esc(value)
  return '"' .. tostring(value or "")
    :gsub("\\", "\\\\")
    :gsub('"', '\\"')
    :gsub("\b", "\\b")
    :gsub("\f", "\\f")
    :gsub("\n", "\\n")
    :gsub("\r", "\\r")
    :gsub("\t", "\\t") .. '"'
end

local function safeName(module)
  return module:gsub("[^%w_%-]", "_")
end

local function hex4(data)
  if type(data) ~= "string" or #data < 4 then return "" end
  return string.format("%02x%02x%02x%02x", data:byte(1, 4))
end

local function writeFile(path, data)
  local handle, message = io.open(path, "wb")
  if not handle then return false, tostring(message) end
  local ok, writeError = pcall(function()
    handle:write(data)
    handle:flush()
  end)
  handle:close()
  if not ok then return false, tostring(writeError) end
  return true, nil
end

local function dumpChunk(chunk)
  -- LuaJIT supports string.dump(function [, strip]). Keep a compatibility
  -- fallback in case this build exposes only the Lua 5.1 single-argument form.
  local ok, dumped = pcall(string.dump, chunk, true)
  if ok and type(dumped) == "string" and #dumped > 0 then return dumped end
  ok, dumped = pcall(string.dump, chunk)
  if ok and type(dumped) == "string" and #dumped > 0 then return dumped end
  return nil, tostring(dumped)
end

local function rootPath()
  if type(Loader.Root) == "string" and Loader.Root ~= "" then return Loader.Root end
  local File = import("LuaFunctionLibrary")
  local Paths = import("BlueprintPathsLibrary")
  return File.GetFilePath(Paths.ProjectSavedDir()) .. "/Mods/"
end

local function runDump()
  if type(Loader.FindOriginalChunk) ~= "function" then
    print("[LoM-VI corpus dump] FindOriginalChunk unavailable")
    return
  end
  if type(string) ~= "table" or type(string.dump) ~= "function" then
    print("[LoM-VI corpus dump] string.dump unavailable")
    return
  end

  local root = rootPath()
  local manifestPath = root .. PREFIX .. "manifest.jsonl"
  local completePath = root .. PREFIX .. "complete.json"
  local loadedPath = root .. PREFIX .. "loaded.json"
  local failurePath = root .. PREFIX .. "failure.json"

  local loaded = '{"audit_id":' .. esc(AUDIT_ID)
    .. ',"stage":"module_loaded","loader_version":' .. esc(Loader.Version or "unknown") .. '}\n'
  local loadedOk, loadedError = writeFile(loadedPath, loaded)
  if not loadedOk then
    print("[LoM-VI corpus dump] loaded marker failed: " .. tostring(loadedError))
    return
  end
  pcall(os.remove, failurePath)

  local existing = io.open(completePath, "rb")
  if existing then
    existing:close()
    print("[LoM-VI corpus dump] already complete: " .. completePath)
    return
  end

  local manifest, openError = io.open(manifestPath .. ".tmp", "wb")
  if not manifest then
    print("[LoM-VI corpus dump] cannot open manifest: " .. tostring(openError))
    return
  end

  local counters = {modules = #MODULES, chunks = 0, dump_ok = 0, dump_failed = 0, bytes = 0}
  local success, message = xpcall(function()
    manifest:write('{"type":"header","audit_id":', esc(AUDIT_ID),
      ',"module_count":', tostring(#MODULES),
      ',"loader_version":', esc(Loader.Version or "unknown"), '}\n')

    for index, module in ipairs(MODULES) do
      local chunk = Loader.FindOriginalChunk(module)
      local fileName = string.format("%s%02d-%s.luac", PREFIX, index, safeName(module))
      local found = type(chunk) == "function"
      local dumped, dumpError = nil, nil
      local wrote, writeError = false, nil

      if found then
        counters.chunks = counters.chunks + 1
        dumped, dumpError = dumpChunk(chunk)
        if dumped then
          wrote, writeError = writeFile(root .. fileName, dumped)
          if wrote then
            counters.dump_ok = counters.dump_ok + 1
            counters.bytes = counters.bytes + #dumped
          else
            counters.dump_failed = counters.dump_failed + 1
          end
        else
          counters.dump_failed = counters.dump_failed + 1
        end
      else
        counters.dump_failed = counters.dump_failed + 1
        dumpError = "original chunk unavailable"
      end

      manifest:write('{"type":"module","index":', tostring(index),
        ',"module":', esc(module),
        ',"chunk_found":', found and "true" or "false",
        ',"dump_ok":', wrote and "true" or "false",
        ',"file":', wrote and esc(fileName) or "null",
        ',"bytes":', dumped and tostring(#dumped) or "0",
        ',"header_hex":', dumped and esc(hex4(dumped)) or "null",
        ',"error":', esc(writeError or dumpError or ""), '}\n')
      manifest:flush()
    end

    manifest:write('{"type":"summary","audit_id":', esc(AUDIT_ID),
      ',"module_count":', tostring(counters.modules),
      ',"chunks_found":', tostring(counters.chunks),
      ',"dump_ok":', tostring(counters.dump_ok),
      ',"dump_failed":', tostring(counters.dump_failed),
      ',"bytes":', tostring(counters.bytes), '}\n')
    manifest:flush()
    manifest:close()
    manifest = nil

    local renamed, renameError = os.rename(manifestPath .. ".tmp", manifestPath)
    if not renamed then error("manifest finalize failed: " .. tostring(renameError)) end

    local complete = '{"audit_id":' .. esc(AUDIT_ID)
      .. ',"module_count":' .. tostring(counters.modules)
      .. ',"chunks_found":' .. tostring(counters.chunks)
      .. ',"dump_ok":' .. tostring(counters.dump_ok)
      .. ',"dump_failed":' .. tostring(counters.dump_failed)
      .. ',"bytes":' .. tostring(counters.bytes) .. '}\n'
    local completeOk, completeError = writeFile(completePath, complete)
    if not completeOk then error("complete marker failed: " .. tostring(completeError)) end

    print("[LoM-VI corpus dump] complete modules=" .. tostring(counters.modules)
      .. " chunks=" .. tostring(counters.chunks)
      .. " dumped=" .. tostring(counters.dump_ok)
      .. " failed=" .. tostring(counters.dump_failed)
      .. " bytes=" .. tostring(counters.bytes))
  end, debug.traceback)

  if manifest then manifest:close() end
  if not success then
    pcall(os.remove, manifestPath .. ".tmp")
    local failure = '{"audit_id":' .. esc(AUDIT_ID)
      .. ',"stage":"dump","error":' .. esc(message) .. '}\n'
    pcall(writeFile, failurePath, failure)
    print("[LoM-VI corpus dump] failed: " .. tostring(message))
  end
end

-- Run immediately when bootstrap requires this audit module.
-- This avoids depending on the game's after_main lifecycle while still never
-- executing any of the 46 original module chunks.
local ok, message = xpcall(runDump, debug.traceback)
if not ok then
  local root = rootPath()
  local failure = '{"audit_id":' .. esc(AUDIT_ID)
    .. ',"stage":"module_top_level","error":' .. esc(message) .. '}\n'
  pcall(writeFile, root .. PREFIX .. "failure.json", failure)
  print("[LoM-VI corpus dump] top-level failure: " .. tostring(message))
end

return {AuditId = AUDIT_ID, ModuleCount = #MODULES}
