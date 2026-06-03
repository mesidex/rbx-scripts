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

local dirs_cache = {}

local rs = game:GetService("RunService")
rs:Pause()
rs:Set3dRenderingEnabled(false)

print("[!] Starting to dump")
for _, svc in services do
  for _, scr in svc:QueryDescendants("LocalScript, ModuleScript") do
    local ok, src = pcall(decompile, scr)
    if not (ok and src and #src > 0) then continue end

    local fpath = root .. "/" .. scr:GetFullName():gsub("%.", "/")
    local dir = fpath:match("(.+)/[^/]+$")
    if not dirs_cache[dir] then
      makefolder(dir)
      dirs_cache[dir] = true
    end

    local prefix = "-- " .. fpath .. "\n"
    writefile(fpath .. ".lua", prefix .. src)
  end
end
print("[!] Dump done -> " .. root)

rs:Run()
rs:Set3dRenderingEnabled(true)
