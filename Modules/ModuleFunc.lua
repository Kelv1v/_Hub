local Func={}
function Func:resetCD(Controller,fucker,RigEvent,TryLag,MaxLag,AttackCD)
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
return Func
