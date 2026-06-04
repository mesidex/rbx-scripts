-- if in autoexec
if not game:IsLoaded() then game.Loaded:Wait() end

local root = "dump_" .. game.GameId
if not isfolder(root) then makefolder(root) end

local services = {
  game:GetService("ReplicatedStorage"),
  game:GetService("ReplicatedFirst"),
  game:GetService("Lighting"),
  game:GetService("StarterGui"),
  game:GetService("StarterPlayer"),
  game:GetService("StarterPack"),
}

-- collect all scripts then dump
local batch = {}
for _, svc in services do
  for _, scr in svc:QueryDescendants("LocalScript, ModuleScript") do
    local fpath = root .. "/" .. scr:GetFullName():gsub("%.", "/")
    table.insert(batch, { script = scr, path = fpath })
  end
end
print(("[!] Collected %d scripts, starting decompilation..."):format(#batch))

local rs = game:GetService("RunService")
rs:Pause()
rs:Set3dRenderingEnabled(false)

local done = 0
local failed = {}
local dirs_cache = {}

-- dump
for _, entry in batch do
  local ok, src = pcall(decompile, entry.script)
  if not (ok and src and #src > 0) then
    table.insert(failed, entry.path)
    continue
  end

  local dir = entry.path:match("(.+)/[^/]+$")
  if not dirs_cache[dir] then
    makefolder(dir)
    dirs_cache[dir] = true
  end

  writefile(entry.path .. ".lua",  src)
  done += 1
end

if #failed > 0 then
  print(("[!] Failed %d scripts:"):format(#failed))
  for _, path in failed do
    print("\t[-] " .. path)
  end
end

print(("[!] Done: %d dumped, %d failed -> %s"):format(done, #failed, root))

rs:Run()
rs:Set3dRenderingEnabled(true)
