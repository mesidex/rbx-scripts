local containers = {
    game.ReplicatedStorage,
    game.ReplicatedFirst,
    game.StarterGui,
    game.StarterPlayer,
    game.StarterPack,
    game.Lighting,
}

local dump_path = "dump_" .. game.GameId
makefolder(dump_path)

local made = {}

for _, container in containers do
  for _, obj in container:GetDescendants() do
    if obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
      local ok, source = pcall(decompile, obj)
      if ok and source and #source > 0 then
        local parts = dump_path .. "/" .. obj:GetFullName():gsub("%.", "/")
        local dir = parts:match("(.+)/[^/]+$")
        if not made[dir] then
          local current = ""
          for part in dir:gmatch("[^/]+") do
            current = current == "" and part or (current .. "/" .. part)
            if not made[current] then
              makefolder(current)
              made[current] = true
            end
          end
        end
        writefile(parts .. ".lua", source)
      end
    end
  end
end
