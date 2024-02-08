local Func={}
function resetCD(Controller,fucker,RigEvent,TryLag,MaxLag,AttackCD)
	local WeaponName = Controller.currentWeaponModel.Name
	local Cooldown = {
		combat = 0.07
	}
	AttackCD = tick() + (fucker and Cooldown[WeaponName:lower()] or fucker or 0.285) + ((TryLag/MaxLag)*0.3)
	RigEvent.FireServer(RigEvent,"weaponChange",WeaponName)
	TryLag += 1
	task.delay((fucker or 0.285) + (TryLag+0.5/MaxLag)*0.3,function()
		TryLag -= 1
	end)
end

function Func:FAt(Controller,fucker,RigEvent,lastFireValid,TryLag,MaxLag,AttackCD,canHits,Data,NormalClick,Settings,NeedAttacking,Char,Client,DisableFastAttack)
	if #canHits > 0 then
		Controller = Data.activeController
		if NormalClick then
			pcall(task.spawn,Controller.attack,Controller)
			continue
		end
		if Controller and Controller.equipped and (not Char.Busy.Value or Client.PlayerGui.Main.Dialogue.Visible) and Char.Stun.Value < 1 and Controller.currentWeaponModel then
			if (NeedAttacking or Settings.DamageAura) then
				if Settings.NewFastAttack and tick() > AttackCD and not DisableFastAttack then
					resetCD(Controller,fucker,RigEvent)
				end
				if tick() - lastFireValid > 0.5 or not Settings.FastAttack then
					Controller.timeToNextAttack = 0
					Controller.hitboxMagnitude = 65
					pcall(task.spawn,Controller.attack,Controller)
					lastFireValid = tick()
					continue
				end
				local AID3 = Controller.anims.basic[3]
				local AID2 = Controller.anims.basic[2]
				local ID = AID3 or AID2
				Animation.AnimationId = ID
				local Playing = Controller.humanoid:LoadAnimation(Animation)
				Playing:Play(0.00075,0.01,0.01)
				RigEvent.FireServer(RigEvent,"hit",canHits,AID3 and 3 or 2,"")
				-- AttackSignal:Fire()
				delay(.5,function()
					Playing:Stop()
				end)
			end
		end
	end
end
return Func
