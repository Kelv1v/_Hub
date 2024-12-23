





--[[ THANKS REDZ HUB FOR THAT SHIT ]]






local environment, replicatedstorage, players, net, client, modulepath, characterfolder, enemyfolder do
	environment = (getgenv or getrenv or getfenv)()
	replicatedstorage = game:GetService("ReplicatedStorage")
	players = game:GetService("Players")
	client = players.LocalPlayer
	modulepath = replicatedstorage:WaitForChild("Modules")
	net = modulepath:WaitForChild("Net")
	characterfolder = workspace:WaitForChild("Characters")
	enemyfolder = workspace:WaitForChild("Enemies")
end

local Module = {}
Module.AttackCooldown = tick()
local CachedChars = {}

function Module.IsAlive(Char: Model?): boolean
	if not Char then
		return nil
	end

	if CachedChars[Char] then
		return CachedChars[Char].Health > 0
	end

	local Hum = Char:FindFirstChildOfClass("Humanoid")
	CachedChars[Char] = Hum
	return Hum and Hum.Health > 0
end

local Settings = {
	ClickDelay = 0.01,
	AutoClick = true
}

Module.FastAttack = (function()
	if environment._trash_attack then
		return environment._trash_attack
	end

	local module = {
		NextAttack = 0,
		Distance = 55,
		attackMobs = true,
		attackPlayers = true
	}

	local RegisterAttack = net:WaitForChild("RE/RegisterAttack")
	local RegisterHit = net:WaitForChild("RE/RegisterHit")

	function module:AttackEnemy(EnemyHead,Table) 
		if EnemyHead and client:DistanceFromCharacter(EnemyHead.Position) < self.Distance then
			if not self.FirstAttack then
				RegisterAttack:FireServer(Settings.ClickDelay or 0.125)
				self.FirstAttack = true
			end
			RegisterHit:FireServer(EnemyHead, (Table) and Table or {})
		end
	end

	function module:AttackNearest()
		local args = {
			[1] = nil,
			[2] = {}
		}
		for _, Enemy in enemyfolder:GetChildren() do
			if not args[1] and Enemy:FindFirstChild("HumanoidRootPart",true) and client:DistanceFromCharacter(Enemy.HumanoidRootPart.Position) < self.Distance then
				args[1] = Enemy:FindFirstChild("UpperTorso")
			else
				if Enemy:FindFirstChild("HumanoidRootPart",true) and client:DistanceFromCharacter(Enemy.HumanoidRootPart.Position) < self.Distance then
					table.insert(args[2],{
						[1] = Enemy,
						[2] = Enemy:FindFirstChild("UpperTorso")
					})
				end
			end
		end
		self:AttackEnemy(unpack(args))

		for _, Enemy in characterfolder:GetChildren() do
			if Enemy ~= client.Character then
				self:AttackEnemy(Enemy:FindFirstChild("UpperTorso"))
			end
		end

		if not self.FirstAttack then
			task.wait(0.5)
		end
	end

	function module:BladeHits()
		self:AttackNearest()
		self.FirstAttack = false
	end

	task.spawn(function()
		while task.wait(Settings.ClickDelay or 0.125) do
			if (tick() - Module.AttackCooldown) < 0.3 then continue end
			if not Settings.AutoClick then continue end
			if not Module.IsAlive(client.Character) then continue end
			if not Usefastattack then continue end
			if not client.Character:FindFirstChildOfClass("Tool") then continue end
			Module.AttackCooldown = tick()
			module:BladeHits()
		end
	end)

	environment._trash_attack = module
	return module
end)()
