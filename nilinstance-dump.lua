for _, inst in ipairs(getnilinstances()) do
    if inst:IsA("LocalScript") or inst:IsA("ModuleScript") then
        local src = decompile(inst)
        if src and #src > 0 then
            writefile(inst.Name .. ".lua", src)
        end
    end
end
