-- One-shot LoM-VI translation audit. Reads pristine chunks for the exact 46 current
-- localization modules and writes Chinese source data to Saved/Mods as JSONL.
-- It does not alter loaded translation/gameplay values.
local Loader = assert(LOMModLoader, "LOMModLoader is required")
local AUDIT_ID = "current46-20260905-v1"
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

local function cjk(v)
  return type(v) == "string" and v:find("[\228-\233][\128-\191][\128-\191]") ~= nil
end
local function esc(v)
  return '"' .. tostring(v or ""):gsub("\\","\\\\"):gsub('"','\\"')
    :gsub("\b","\\b"):gsub("\f","\\f"):gsub("\n","\\n")
    :gsub("\r","\\r"):gsub("\t","\\t") .. '"'
end
local function key(v)
  if type(v)=="number" and v==math.floor(v) then return string.format("%.0f",v) end
  return tostring(v)
end
local function reportPath()
  local File=import("LuaFunctionLibrary")
  local Paths=import("BlueprintPathsLibrary")
  return File.GetFilePath(Paths.ProjectSavedDir()).."/Mods/lomvi-pristine-current46-"..AUDIT_ID..".jsonl"
end
local function moduleValue(v)
  if type(v)~="table" then return v end
  return type(v.data)=="table" and v.data or v
end
local function execute(chunk)
  local env=setmetatable({}, {__index=_G})
  setfenv(chunk,env)
  local ok,v=pcall(chunk)
  if not ok then return nil,tostring(v) end
  return moduleValue(v),nil
end
local function walk(out,module,v,path,counters,seen)
  if type(v)=="string" then
    if cjk(v) then
      counters.entries=counters.entries+1
      out:write('{"type":"entry","module":',esc(module),',"path":',esc(path),',"source":',esc(v),'}\n')
    end
    return
  end
  if type(v)~="table" or seen[v] then return end
  seen[v]=true
  for k,child in pairs(v) do
    local p=path=="" and key(k) or (path.."."..key(k))
    walk(out,module,child,p,counters,seen)
  end
end
local function scanProto(out,jutil,module,proto,counters,seen,seenLit)
  if seen[proto] then return end
  seen[proto]=true
  local ok,info=pcall(jutil.funcinfo,proto)
  if not ok or type(info)~="table" then return end
  local function scan(v)
    local t=type(v)
    if t=="string" then
      if cjk(v) then
        local id=module.."\0"..v
        if not seenLit[id] then
          seenLit[id]=true; counters.literals=counters.literals+1
          out:write('{"type":"literal","module":',esc(module),',"source":',esc(v),'}\n')
        end
      end
    elseif t=="function" or t=="proto" then
      scanProto(out,jutil,module,v,counters,seen,seenLit)
    elseif t=="table" and not seen[v] then
      seen[v]=true
      pcall(function() for k,child in pairs(v) do scan(k); scan(child) end end)
    end
  end
  for i=-1,-(tonumber(info.gcconsts) or 0),-1 do
    local got,v=pcall(jutil.funck,proto,i); if got then scan(v) end
  end
end

Loader.On("after_main",function()
  if type(Loader.FindOriginalChunk)~="function" then
    print("[LoM-VI audit] FindOriginalChunk unavailable"); return
  end
  local okJit,jutil=pcall(require,"jit.util")
  if not okJit or type(jutil.funck)~="function" then print("[LoM-VI audit] jit.util unavailable"); return end
  local final=reportPath()
  local old=io.open(final,"rb")
  if old then old:close(); print("[LoM-VI audit] report already exists: "..final); return end
  local tmp=final..".tmp"
  local out,err=io.open(tmp,"wb")
  if not out then print("[LoM-VI audit] open failed: "..tostring(err)); return end
  local success,message=xpcall(function()
    local c={modules=0,chunks=0,execute_ok=0,execute_failed=0,entries=0,literals=0}
    local seen=setmetatable({}, {__mode="k"}); local seenLit={}
    for _,module in ipairs(MODULES) do
      c.modules=c.modules+1
      local chunk=Loader.FindOriginalChunk(module)
      local e0,l0=c.entries,c.literals
      local executed=false; local execErr=nil
      if type(chunk)=="function" then
        c.chunks=c.chunks+1
        scanProto(out,jutil,module,chunk,c,seen,seenLit)
        local source,xerr=execute(chunk)
        if xerr==nil then executed=true; c.execute_ok=c.execute_ok+1; walk(out,module,source,"",c,{})
        else execErr=xerr; c.execute_failed=c.execute_failed+1 end
      else execErr="original chunk unavailable"; c.execute_failed=c.execute_failed+1 end
      out:write('{"type":"module-summary","module":',esc(module),
        ',"chunk_found":',type(chunk)=="function" and "true" or "false",
        ',"execute_ok":',executed and "true" or "false",
        ',"execute_error":',execErr and esc(execErr) or "null",
        ',"entries":',tostring(c.entries-e0),',"literals":',tostring(c.literals-l0),'}\n')
      out:flush()
    end
    out:write('{"type":"summary","audit_id":',esc(AUDIT_ID),
      ',"module_count":',tostring(c.modules),',"chunks_found":',tostring(c.chunks),
      ',"execute_ok":',tostring(c.execute_ok),',"execute_failed":',tostring(c.execute_failed),
      ',"cjk_entries":',tostring(c.entries),',"cjk_literals":',tostring(c.literals),'}\n')
    out:flush(); out:close(); out=nil
    local renamed,renameErr=os.rename(tmp,final)
    if not renamed then error("finalize failed: "..tostring(renameErr)) end
    print("[LoM-VI audit] complete modules="..c.modules.." chunks="..c.chunks.." entries="..c.entries.." literals="..c.literals.." path="..final)
  end,debug.traceback)
  if out then out:close() end
  if not success then pcall(os.remove,tmp); print("[LoM-VI audit] failed: "..tostring(message)) end
end,910000,"lomvi.audit.current46-pristine")

return {AuditId=AUDIT_ID,ModuleCount=#MODULES}
