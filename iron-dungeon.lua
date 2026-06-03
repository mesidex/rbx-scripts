local obj = game.Workspace.pikeswo2.LocalControlMgr.Action.BaseAttack
local v2 = require(obj)
local oldPerform = v2.Perform

v2.Perform = function(p_u_4)
  local base = p_u_4.WeaponDef and p_u_4.WeaponDef.BaseAttack
  if base then
    base.Info.CD = 0
    for _, stage in base.StageList do
      stage.Time = 0.01
      stage.ActEndTime = 0.01
      stage.HitTime = 0.01
    end
  end
  return oldPerform(p_u_4)
end

local ResSkillStage = require(game.ReplicatedStorage.Configs.ResSkillStage)

for _, stage in ResSkillStage do
  stage.Time = 0.01
  stage.ActEndTime = 0.01
  stage.HitTime = 0.01
  stage.DamageRange = 1000   -- default seems to be ~11
  stage.RangeOffset = "0, 0, 0"
end

local weaponAttr = game.Players.LocalPlayer:WaitForChild("PlayerEquippedWeapon")
local uuid = weaponAttr:GetAttribute("UUID")
weaponAttr:SetAttribute("UUID", nil)
task.wait(0.1)
weaponAttr:SetAttribute("UUID", uuid)
