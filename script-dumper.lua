-- if in autoexec
if not game:IsLoaded() then
	game.Loaded:Wait()
end

local root = string.format("dump_%s", game.GameId)
if not isfolder(root) then
	makefolder(root)
end

local services = {
	cloneref(game:GetService("ReplicatedStorage")),
	cloneref(game:GetService("ReplicatedFirst")),
	cloneref(game:GetService("Lighting")),
	cloneref(game:GetService("StarterGui")),
	cloneref(game:GetService("StarterPlayer")),
	cloneref(game:GetService("StarterPack")),
}

local batch = {}
for _, svc in next, services do
	for _, scr in next, svc:QueryDescendants("LuaSourceContainer") do
		table.insert(batch, {
			scr = scr,
			path = string.format("%s/%s", root, scr:GetFullName():gsub("%.", "/")),
		})
	end
end

print(string.format("[!] Collected %d scripts, starting decompilation...", #batch))

local rs = cloneref(game:GetService("RunService"))
rs:Set3dRenderingEnabled(false)

local done, failed, dirs = 0, {}, {}
for _, e in next, batch do
	local ok, src = pcall(decompile, e.scr)
	if not (ok and src and #src > 0) then
		table.insert(failed, e.path)
		continue
	end

	local dir = e.path:match("(.+)/[^/]+$")
	if not dirs[dir] then
		makefolder(dir)
		dirs[dir] = true
	end

	writefile(string.format("%s.lua", e.path), src)
	done += 1
end

if #failed > 0 then
	print(string.format("[!] Failed %d scripts:", #failed))
	for _, p in next, failed do
		print(string.format("\t[-] %s", p))
	end
end

print(string.format("[!] Done: %d dumped, %d failed -> %s", done, #failed, root))

rs:Set3dRenderingEnabled(true)
