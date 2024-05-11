AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true
ENT.PlayerModel		= "models/player/group01/male_07.mdl";

function ENT:SetupDataTables()
	self:NetworkVar( "Entity", 0, "ActiveWeapon" )
end

function ENT:Initialize()
	local modelsRebel = {
		"models/player/Group03/male_01.mdl",
		"models/player/Group03/male_02.mdl",
		"models/player/Group03/male_03.mdl",
		"models/player/Group03/male_04.mdl",
		"models/player/Group03/male_05.mdl",
		"models/player/Group03/male_06.mdl",
		"models/player/Group03/male_07.mdl",
		"models/player/Group03/male_08.mdl",
		"models/player/Group03/male_09.mdl",
		"models/player/Group03/female_01.mdl",
		"models/player/Group03/female_02.mdl",
		"models/player/Group03/female_03.mdl",
		"models/player/Group03/female_04.mdl",
		"models/player/Group03/female_05.mdl",
		"models/player/Group03/female_06.mdl",
		"models/player/Group03m/male_01.mdl",
		"models/player/Group03m/male_02.mdl",
		"models/player/Group03m/male_03.mdl",
		"models/player/Group03m/male_04.mdl",
		"models/player/Group03m/male_05.mdl",
		"models/player/Group03m/male_06.mdl",
		"models/player/Group03m/male_07.mdl",
		"models/player/Group03m/male_08.mdl",
		"models/player/Group03m/male_09.mdl",
		"models/player/Group03m/female_01.mdl",
		"models/player/Group03m/female_02.mdl",
		"models/player/Group03m/female_03.mdl",
		"models/player/Group03m/female_04.mdl",
		"models/player/Group03m/female_05.mdl",
		"models/player/Group03m/female_06.mdl"
	}

	if( SERVER ) then
		local model = table.Random( modelsRebel )

		if( not util.IsValidModel( model ) ) then
			print( "INVALID MODEL: " .. model)
			model = "models/player/Group03/male_07.mdl"
		end
		self:SetModel( model ) 

	end 
	self.LoseTargetDist	= 1200
	self.SearchRadius 	= 1800

	self.NextFire = CurTime()
	self.NextSound = CurTime()+1
	self.NextFootstep = CurTime()
	self.NextCrouch = CurTime()

	self.Healing = false
	self.Foot = false
	
end


function ENT:Give(wepname)
    if CLIENT then return end
    if self:GetActiveLuaWeapon():IsValid() then self:GetActiveLuaWeapon():Remove() end

	local wep = ents.Create(wepname)
	
	if IsValid(wep) then
		wep:SetPos(self:GetPos())
		wep:SetOwner(self)
		wep:Spawn()
		wep:Activate()
		return self:SetupWeapon(wep)
	end
end

function ENT:GetActiveLuaWeapon()
	return self.m_ActualWeapon or NULL
end

function ENT:SetupWeapon(wep)
	if !IsValid(wep) then return end

	self:SetActiveWeapon(wep)

	self.m_ActualWeapon = wep

	local actwep = self:GetActiveLuaWeapon()
	
	wep:SetVelocity(vector_origin)
	wep:RemoveSolidFlags(FSOLID_TRIGGER)
	wep:SetOwner(self)
	wep:RemoveEffects(EF_ITEM_BLINK)
	wep:PhysicsDestroy()
	
	wep:SetParent(self)
	wep:SetMoveType(MOVETYPE_NONE)
	wep:AddEffects(EF_BONEMERGE)
	wep:AddSolidFlags(FSOLID_NOT_SOLID)
	wep:SetLocalPos(vector_origin)
	wep:SetLocalAngles(angle_zero)
	wep:SetTransmitWithParent(true)
	wep.CurAmmo = wep.Primary.ClipSize
	wep.MaxClip = wep.Primary.ClipSize
	print(" WEAPON SET UP")
	wep.Reloading = false
	return actwep
end

----------------------------------------------------
-- ENT:Get/SetEnemy()
-- Simple functions used in keeping our enemy saved
----------------------------------------------------
function ENT:SetEnemy(ent)
	self.Enemy = ent
end
function ENT:GetEnemy()
	return self.Enemy
end

function ENT:BodyUpdate()
	self:BodyMoveXY()
end

----------------------------------------------------
-- ENT:RunBehaviour()
-- This is where the meat of our AI is
----------------------------------------------------
function ENT:RunBehaviour()
	local wep = self:GetActiveLuaWeapon()
	while true do
		
		if( self:Health() < self:GetMaxHealth() / 2 and math.random( self:Health(), self:GetMaxHealth() ) < self:GetMaxHealth() / 2 ) then 
			self:RunToRandomLocation()
		end
		if self:HaveEnemy() then
			
			self:StartActivity(ACT_HL2MP_WALK_PISTOL)
			self:SetPoseParameter("aim_pitch",0)
			self.loco:SetDesiredSpeed(50)
			self.NextFire = CurTime()+1


			local behaviours = { 
				function() self:ChargeEnemy() end,
				function() self:GoAwayFromEnemy() end,
				function() self:GoRandomWhileShooting() end,
			}
			table.Random(behaviours)()
			
		else
			self:StartActivity(ACT_HL2MP_WALK)
			self:SetPoseParameter("aim_pitch", 40)
			self.loco:SetDesiredSpeed(50)
			self:MoveToPos(self:GetPos() + Vector(math.Rand(-1, 1), math.Rand(-1, 1), 0) * 100)
			self:StartActivity(ACT_HL2MP_IDLE)
			
			while not self:FindEnemy() do 
				print("found enemy DURING WALK")
				coroutine.yield()
				break
			end
		end
		
		coroutine.wait(2)
	end
end	

function ENT:RunToRandomLocation()
	self:StartActivity(ACT_HL2MP_RUN_PANICKED)
	self.loco:SetDesiredSpeed(200)
	self:MoveToPos(self:GetPos() + Vector(math.Rand(-1, 1), math.Rand(-1, 1), 0) * 600)
	coroutine.yield()
	return "ok"
end

function ENT:GoRandomWhileShooting()
	local path = Path("Follow")
	path:SetMinLookAheadDistance(0)
	path:SetGoalTolerance(20)
	path:Compute(self, self:GetPos() + Vector(math.Rand(-1, 1), math.Rand(-1, 1), 0) * 600)
    
	if not path:IsValid() then return "failed" end
	local timeout = CurTime() + math.random(2,3)

	while path:IsValid() and self:HaveEnemy() and timeout > CurTime() do
		if path:GetAge() > 0.1 then
			local vec = vec or self:GetPos()
			path:Compute(self, self:GetPos() + self:GetPos() + Vector(math.Rand(-1, 1), math.Rand(-1, 1), 0) * 600)
			self:WeaponPrimaryAttack()
			self.loco:FaceTowards(self:GetEnemy():GetPos())
			if self.NextCrouch < CurTime() then
				self.NextCrouch = CurTime() + 1
				if math.random(1,10) == 2 then 
					self:StartActivity(ACT_HL2MP_WALK_CROUCH_REVOLVER)
					self.loco:SetDesiredSpeed(38)
				else
					self:StartActivity(ACT_HL2MP_WALK_REVOLVER)
					self.loco:SetDesiredSpeed(85)
				end
			end
        end
		path:Update(self)
		self.loco:FaceTowards(self:GetEnemy():GetPos())

		if (self.loco:IsStuck()) then
			self:HandleStuck()
			return "stuck"
		end

		coroutine.yield()
	end

	return "ok"
end

function ENT:GoAwayFromEnemy()
	print("running")
	local path = Path("Follow")
	path:SetMinLookAheadDistance(0)
	path:SetGoalTolerance(20)
	path:Compute(self, self:GetEnemy():GetPos())
    
	if not path:IsValid() then return "failed" end
	local timeout = CurTime() + math.random(4,6)

	while path:IsValid() and self:HaveEnemy() and timeout > CurTime() do
		if path:GetAge() > 0.1 then
			local vec = vec or self:GetPos()
			local vec = (self:GetPos() - self:GetEnemy():GetPos()):Angle():Forward() * 50
			path:Compute(self, self:GetPos() + vec)
			self:WeaponPrimaryAttack()
			self.loco:FaceTowards(self:GetEnemy():GetPos())
			if self.NextCrouch < CurTime() then
				self.NextCrouch = CurTime() + 5
				if math.random(1,4) == 2 then 
					self:StartActivity(ACT_HL2MP_WALK_CROUCH_REVOLVER)
					self.loco:SetDesiredSpeed(38)
				else
					self:StartActivity(ACT_HL2MP_WALK_REVOLVER)
					self.loco:SetDesiredSpeed(90)
				end
			end
        end
		path:Update(self)
		self.loco:FaceTowards(self:GetEnemy():GetPos())

		if (self.loco:IsStuck()) then
			self:HandleStuck()
			return "stuck"
		end

		coroutine.yield()
	end

	return "ok"
end

function ENT:ChargeEnemy()
	local path = Path("Follow")
	path:SetMinLookAheadDistance(0)
	path:SetGoalTolerance(20)
	path:Compute(self, self:GetEnemy():GetPos())
	
	if not path:IsValid() then return "failed" end

	local timeout = CurTime() + math.random(6,12)

	while path:IsValid() and self:HaveEnemy() do
		if path:GetAge() > 0.1 then
			local vec = vec or self:GetPos()
			local vec = (self:GetEnemy():GetPos() - self:GetPos()):GetNormalized() * 100
			
			self:WeaponPrimaryAttack()
			self.loco:FaceTowards(self:GetEnemy():GetPos())
			local newPos = self:GetPos() + vec
			local tr = util.TraceLine({
				start = self:GetPos(),
				endpos = newPos,
				filter = self
			})
			if tr.Hit then
				newPos = tr.HitPos + tr.HitNormal * 128
			end
			path:Compute(self, newPos)
			if self.NextCrouch < CurTime() then
				self.NextCrouch = CurTime() + 1
				if math.random(1,8) == 2 then 
					self:StartActivity(ACT_HL2MP_WALK_CROUCH_REVOLVER)
					self.loco:SetDesiredSpeed(70)
				else
					self:StartActivity(ACT_HL2MP_WALK_REVOLVER)
					self.loco:SetDesiredSpeed(100)
				end
			end
		end
		path:Update(self)
		self.loco:FaceTowards(self:GetEnemy():GetPos())

		if (self.loco:IsStuck()) then
			self:HandleStuck()
			return "stuck"
		end

		coroutine.yield()
	end

	return "ok"
end

----------------------------------------------------
-- ENT:HaveEnemy()
-- Returns true if we have an enemy
----------------------------------------------------
function ENT:HaveEnemy()
	-- If our current enemy is valid
	if ( self:GetEnemy() and IsValid(self:GetEnemy()) ) then
		-- If the enemy is too far
		if ( self:GetRangeTo(self:GetEnemy():GetPos()) > self.LoseTargetDist ) then
			-- If the enemy is lost then call FindEnemy() to look for a new one
			-- FindEnemy() will return true if an enemy is found, making this function return true
			return self:FindEnemy()
		-- If the enemy is dead( we have to check if its a player before we use Alive() )
		elseif ( self:GetEnemy():IsPlayer() and !self:GetEnemy():Alive() ) then
			return self:FindEnemy()		-- Return false if the search finds nothing
		end
		if( self:GetEnemy():GetClass() == self:GetClass() ) then 
			return self:FindEnemy()
		end
		-- The enemy is neither too far nor too dead so we can return true
		return true
	else
		-- The enemy isn't valid so lets look for a new one
		return self:FindEnemy()
	end
end

----------------------------------------------------
-- ENT:FindEnemy()
-- Returns true and sets our enemy if we find one
----------------------------------------------------
function ENT:FindEnemy()
	-- Search around us for entities
	-- This can be done any way you want eg. ents.FindInCone() to replicate eyesighti
	local angle = 0.707 -- costign angle. if this is 0.707 the NPC should have a 90deg field of view
	local _ents = ents.FindInCone( self:GetPos(), self:GetForward(), self.SearchRadius, angle )

	-- Here we loop through every entity the above search finds and see if it's the one we want
	for k,v in ipairs( _ents ) do
		if ( v:IsPlayer() ) then
			-- We found one so lets set it as our enemy and return true
			if self:Visible(v) then
				self:SetEnemy(v)
				return true
			end
			--self:PlaySequenceAndWait("ACT_SIGNAL_HALT")
		end
	end
	-- We found nothing so we will set our enemy as nil (nothing) and return false
	self:SetEnemy(nil)
	return false
end

function ENT:OnInjured(info)
	if( info:GetAttacker():IsPlayer() ) then
		self.Enemy = info:GetAttacker()
	end
	--self:FindEnemy()
	self.NextFire = CurTime()+0.1
	self:EmitSound("placenta/pain/prole5.wav")
end

function ENT:OnKilled(dmginfo)
	self:EmitSound("placenta/pain/prole" .. math.random(2,4) .. ".wav")
	local rag = self:BecomeRagdoll(dmginfo)
	hook.Call("OnNPCKilled", GAMEMODE, self, dmginfo:GetAttacker(), dmginfo:GetInflictor())
	SafeRemoveEntityDelayed(self, 0.05)
end

function ENT:Reload()
	local wep = self:GetActiveLuaWeapon()
	if wep.Reloading then return end
	self:RestartGesture(ACT_HL2MP_GESTURE_RELOAD_REVOLVER)
	wep.Reloading = true
	timer.Simple(2.5, function()
		if self:IsValid() and wep:IsValid() then
			print("finished reloading")
			wep.CurAmmo = wep.MaxClip
			wep.Reloading = false
		end
	end)

	return
end

function ENT:WeaponPrimaryAttack()
	if self.NextFire > CurTime() then return end
	if not self:HaveEnemy() then return end
	if self.Healing then return end

	local wep = self:GetActiveLuaWeapon()

	if wep.CurAmmo <= 0 then
		self:Reload()
		return
	end
	if false and self:Health()<=30 then
		self:Heal()
	end

	local trace = {}
	trace.start = wep:GetPos()+Vector(0,0,50)
	trace.endpos = wep:GetPos()+Vector(0,0,50) + self:GetEnemy():GetPos()-wep:GetPos()
	trace.filter = self -- Exclude self from the trace
	local tr = util.TraceLine(trace)
	if( IsValid(tr.Entity) and tr.Entity:GetClass() == self:GetClass() ) then
		print("HOLDING FIRE")
		return -- Do not fire if the trace hits a friendly player
	end

	self:SetPoseParameter("aim_pitch",0)

	ProtectedCall(function() 
        self.NextFire = CurTime() + wep.Primary.Delay + math.random( -wep.Primary.Delay / 10, wep.Primary.Delay / 10);
		local snd = wep.Primary.Sound;
		if type(snd) == "table" then
			snd = table.Random( snd );
		end
        self:EmitSound(snd, 75, 100, 5 )
        self:RestartGesture(ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL)
        local bullet = {}
        bullet.Num		= wep.Primary.NumBullets
        bullet.Src		= wep:GetPos()+Vector(0,0,50)
        bullet.Dir		= self:GetEnemy():GetPos()-wep:GetPos()
        bullet.Spread	= Vector(wep.Primary.Accuracy * 300, wep.Primary.Accuracy * 300, 0)
        bullet.Tracer	= 1
        bullet.Force	= wep.Primary.Damage
        bullet.Damage	= wep.Primary.Damage
        bullet.AmmoType = "pistol"

        wep:FireBullets(bullet)
		wep.CurAmmo = wep.CurAmmo - 1
		wep:MuzzleFlash()
    end)
end

function ENT:Think()
	if CLIENT then return end
	local wep = self:GetActiveLuaWeapon()
	
	if wep.CurAmmo <= 0 then
		self:Reload()
		return
	end

	if self.NextSound < CurTime() then
		self.NextSound = CurTime()+math.random(9,18)
		self:EmitSound("placenta/speech/prisoner" .. math.random(1,4) .. ".wav")
	end

	local speed = (self.loco:GetVelocity().x + self.loco:GetVelocity().y)%1

	if self.NextFootstep < CurTime() and speed>0.6 then
		if self.Foot then
			self:EmitSound("NPC_Citizen.FootstepLeft")
		else
			self:EmitSound("NPC_Citizen.FootstepRight")
		end
		self.NextFootstep = CurTime()+0.6
		self.Foot = !self.Foot
	end
end

function ENT:Touch(ent)
	print("TOUCHED")
	if( ent:GetClass() == "func_breakable" or ent:GetClass() == "prop_physics" ) then
		ent:TakeDamage( 1000, self )
	end
end

list.Set("NPC", "raidman", {
	Name = "Raid Enemy",
	Class = "raidman",
	Category = "Raid"
})