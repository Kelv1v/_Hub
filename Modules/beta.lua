new = {}
function FastAttackConnectorFunction()
	Players = game.Players
	Client = Players.LocalPlayer
	local Char = Client.Character
	local Root = Char.HumanoidRootPart
	wait()
	do -- Module Requiring
		Combat =  getupvalue(require(Client.PlayerScripts.CombatFramework),2)
		RL = require(game:GetService("ReplicatedStorage").CombatFramework.RigLib)
		PC = require(Client.PlayerScripts.CombatFramework.Particle)
		DMG = require(Client.PlayerScripts.CombatFramework.Particle.Damage)
		RigC = getupvalue(require(Client.PlayerScripts.CombatFramework.RigController),2)
	end
	do
		canHits = {}
		RunService = game:GetService("RunService")
	end
	ReturnFunctions={}
	local Data = Combat
	local Blank = function() end
	local RigEvent = game:GetService("ReplicatedStorage").RigControllerEvent
	local Animation = Instance.new("Animation")
	local RecentlyFired = 0
	local AttackCD = 0
	local Controller
	local lastFireValid = 0
	local MaxLag = 350
	fucker = 0.07
	TryLag = 0
	
	--------	Setup	--------
	function ReturnFunctions:AttackAnimation(k)
		NoAttackAnimation = k or false
	end
	function ReturnFunctions:FastAttack1(k)
		FastAttack = k or false
	end
	function ReturnFunctions:DamageAura1(k)
		DamageAura = k or nil
	end
	function ReturnFunctions:InstantAttack(k)
		NewFastAttack = k or false
	end
	function ReturnFunctions:DisableAttack(k)
		DisableFastAttack = k or nil
	end
	function ReturnFunctions:Attack(k)
		NeedAttacking = k or false
	end
	
	
	local resetCD = function()
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
	
	if not shared.orl then shared.orl = RL.wrapAttackAnimationAsync end
	if not shared.cpc then shared.cpc = PC.play end
	if not shared.dnew then shared.dnew = DMG.new end
	if not shared.attack then shared.attack = RigC.attack end
	RL.wrapAttackAnimationAsync = function(a,b,c,d,func)
		if not NoAttackAnimation and not NeedAttacking then
			PC.play = shared.cpc
			return shared.orl(a,b,c,65,func)
		end
		--local Radius = (DamageAura and Settings.DamageAuraRadius) or 65
		if canHits and #canHits > 0 then
			PC.play = function() end
			a:Play(0.00075,0.01,0.01)
			func(canHits)
			wait(a.length * 0.5)
			a:Stop()
		end
	end
	spawn(function()
	while RunService.Stepped:Wait() do
		if #canHits > 0 then
			Controller = Data.activeController
			if NormalClick then
				pcall(task.spawn,Controller.attack,Controller)
				continue
			end
			if Controller and Controller.equipped and (not Char.Busy.Value or Client.PlayerGui.Main.Dialogue.Visible) and Char.Stun.Value < 1 and Controller.currentWeaponModel then
				if (NeedAttacking or DamageAura) then
					if NewFastAttack and tick() > AttackCD and not DisableFastAttack then
						resetCD()
					end
					if tick() - lastFireValid > 0.5 or not FastAttack then
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
		end)
	return ReturnFunctions
end

return FastAttackConnectorFunction()
