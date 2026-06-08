local rs = cloneref(game:GetService("RunService"))

local frozen = function()
	wait(9e9)
end

for _, v in next, getscripts() do
	if v:IsA("BaseScript") then
		v.Disabled = true
	end
end

for _, thread in next, getactorthreads() do
	task.cancel(thread)
end

for _, actor in next, getactors() do
	for _, v in next, actor:GetDescendants() do
		if v:IsA("BaseScript") then
			v.Disabled = true
		end
	end
end

hookmetamethod(
	game,
	"__newindex",
	newcclosure(function(self, key, value)
		if not checkcaller() and key == "Parent" and typeof(self) == "Instance" and self:IsA("BaseScript") then
			self.Disabled = true
		end
		return hookmetamethod(game, "__newindex", function() end)(self, key, value)
	end)
)

rs.DescendantAdded:Connect(function(v)
	if v:IsA("BaseScript") then
		v.Disabled = true
	end
	-- Catch actors added after sweep
	if v:IsA("Actor") then
		for _, s in next, v:GetDescendants() do
			if s:IsA("BaseScript") then
				s.Disabled = true
			end
		end
	end
end)

local oldSpawn = hookfunction(
	task.spawn,
	newcclosure(function(fn, ...)
		if checkcaller() then
			return oldSpawn(fn, ...)
		end
		task.cancel(oldSpawn(frozen))
	end)
)

local oldDefer = hookfunction(
	task.defer,
	newcclosure(function(fn, ...)
		if checkcaller() then
			return oldDefer(fn, ...)
		end
		task.cancel(oldDefer(frozen))
	end)
)

local oldDelay = hookfunction(
	task.delay,
	newcclosure(function(dt, fn, ...)
		if checkcaller() then
			return oldDelay(dt, fn, ...)
		end
		task.cancel(oldDelay(9e9, frozen))
	end)
)

local oldResume = hookfunction(
	coroutine.resume,
	newcclosure(function(co, ...)
		if not checkcaller() then
			return false, "blocked"
		end
		return oldResume(co, ...)
	end)
)

hookfunction(
	require,
	newcclosure(function(...)
		if not checkcaller() then
			wait(9e9)
		end
	end)
)
