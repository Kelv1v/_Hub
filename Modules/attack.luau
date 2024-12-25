local Environment, ReplicatedStorage, Players, NetworkModule, Client, ModulePath, CharacterFolder, EnemyFolder do
	Environment = (getgenv or getrenv or getfenv)()
	ReplicatedStorage = game:GetService("ReplicatedStorage")
	Players = game:GetService("Players")
	Client = Players.LocalPlayer
	ModulePath = ReplicatedStorage:WaitForChild("Modules")
	NetworkModule = ModulePath:WaitForChild("Net")
	CharacterFolder = workspace:WaitForChild("Characters")
	EnemyFolder = workspace:WaitForChild("Enemies")
end

local EventHandlers = {}
local CombatModule = {}
CombatModule.AttackCooldown = tick()
local CachedCharacters = {}

local CombatUtil = require(ModulePath.CombatUtil)
local Network = require(NetworkModule)
EventHandlers.AttackEvent = Network:RemoteEvent("RegisterAttack")
EventHandlers.HitEvent = Network:RemoteEvent("RegisterHit")

function CombatModule.IsCharacterAlive(Character: Model?): boolean
	if not Character then
		return nil
	end

	if CachedCharacters[Character] then
		return CachedCharacters[Character].Health > 0
	end

	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	CachedCharacters[Character] = Humanoid
	return Humanoid and Humanoid.Health > 0
end

local Settings = {
	ClickDelay = 0.01,
	AutoClick = true
}

CombatModule.FastAttack = (function()
	if Environment._fast_attack then
		return Environment._fast_attack
	end

	local FastAttackModule = {
		NextAttack = 0,
		AttackRange = 55,
		AttackMobs = true,
		AttackPlayers = true
	}

	function FastAttackModule:AttackTarget(TargetPart, AdditionalData)
		if TargetPart and Client:DistanceFromCharacter(TargetPart.Position) < self.AttackRange then
			if not self.InitialAttack then
				EventHandlers.AttackEvent:FireServer(Settings.ClickDelay or 0.125)
				self.InitialAttack = true
			end
			EventHandlers.HitEvent:FireServer(TargetPart, AdditionalData or {})
		end
	end

	function FastAttackModule:AttackNearbyEntities()
		local attackArgs = {
			[1] = nil,
			[2] = {}
		}

		for _, Enemy in EnemyFolder:GetChildren() do
			local HumanoidRootPart = Enemy:FindFirstChild("HumanoidRootPart", true)
			if not attackArgs[1] and HumanoidRootPart and Client:DistanceFromCharacter(HumanoidRootPart.Position) < self.AttackRange then
				attackArgs[1] = Enemy:FindFirstChild("UpperTorso")
			else
				if HumanoidRootPart and Client:DistanceFromCharacter(HumanoidRootPart.Position) < self.AttackRange then
					table.insert(attackArgs[2], {
						[1] = Enemy,
						[2] = Enemy:FindFirstChild("UpperTorso")
					})
				end
			end
		end

		self:AttackTarget(unpack(attackArgs))

		for _, Character in CharacterFolder:GetChildren() do
			if Character ~= Client.Character then
				self:AttackTarget(Character:FindFirstChild("UpperTorso"))
			end
		end

		if not self.InitialAttack then
			task.wait(0.5)
		end
	end

	function FastAttackModule:ExecuteBladeHits()
		self:AttackNearbyEntities()
		self.InitialAttack = false
	end

	task.spawn(function()
		while task.wait(Settings.ClickDelay or 0.125) do
			if (tick() - CombatModule.AttackCooldown) < 0.3 then continue end
			if not Settings.AutoClick then continue end
			if not CombatModule.IsCharacterAlive(Client.Character) then continue end
			if not Usefastattack then continue end
			if not Client.Character:FindFirstChildOfClass("Tool") then continue end
			--if not CombatUtil:CanAttack(Client.Character, "Melee") then end

			CombatModule.AttackCooldown = tick()
			FastAttackModule:ExecuteBladeHits()
		end
	end)

	Environment._fast_attack = FastAttackModule
	return FastAttackModule
end)()
