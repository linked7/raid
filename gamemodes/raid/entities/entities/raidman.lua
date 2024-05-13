AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true
ENT.PlayerModel		= "models/player/group01/male_07.mdl";

function ENT:SetupDataTables()
	self:NetworkVar( "Entity", 0, "ActiveWeapon" )
end

ENT.RebelModels = {
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
}

ENT.MedicModels = {
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

function ENT:Initialize()
	if( SERVER ) then
		local models = self.RebelModels

		if( self.Medic ) then
			print("I'm a medic!") 
			models = self.MedicModels
		end

		local model = table.Random( models )

		if( not util.IsValidModel( model ) ) then
			print( "ERROR! INVALID MODEL: " .. model)
			model = "models/player/Group03/male_07.mdl"
		end

		self:SetModel( model ) 

	end 
	self.LoseTargetDist	= 1200 -- these are largely obsolute for the size of the arenas, but will be kept for furture compatibility
	self.SearchRadius 	= 1800

	self.NextFire = CurTime()
	self.NextSound = CurTime()+1
	self.NextFootstep = CurTime()
	self.NextCrouch = CurTime()

	self.Healing = false
	self.Foot = false

	self.Idle = IDLETYPE_IDLE
	if string.find(self:GetModel(), "female") then
		self:SwapGender()
	end

end

IDLETYPE_IDLE = 	1
IDLETYPE_INTERUPT = 2
IDLETYPE_ACTIVE = 	3

function ENT:SwapGender() -- swap all the voiceline's genders if the npc is using a female model
	for key, value in pairs(self.Vo) do
		for i, sound in ipairs(value) do
			self.Vo[key][i] = string.gsub(sound, "male01", "female01")
		end
	end
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
		
		if( self:Health() < self:GetMaxHealth() / 1.5 and math.random( self:Health(), self:GetMaxHealth() ) < self:GetMaxHealth() / 1.5 ) then 
			self:RunToRandomLocation() -- depending on how injured they are, run in panic
		end
		if( (self.Medic and math.random(1,100) > 1 ) or true ) then
			self:HealAlly()
		end
		if self:HaveEnemy() then
			
			self:StartActivity(ACT_HL2MP_WALK_PISTOL)
			self:SetPoseParameter("aim_pitch",0)
			self.loco:SetDesiredSpeed(50)
			self.NextFire = CurTime()+1

			local behaviours = { -- this functions as a switch statement substitue in lua
				function() self:ChargeEnemy() end,
				function() self:GoAwayFromEnemy() end,
				function() self:GoRandomWhileShooting() end,
			}
			table.Random(behaviours)() -- choose a random behaviour

		else

			self:StartActivity(ACT_HL2MP_WALK)
			self:SetPoseParameter("aim_pitch", 40)
			self.loco:SetDesiredSpeed(50)
			self:MoveToPos(self:GetPos() + Vector(math.Rand(-1, 1), math.Rand(-1, 1), 0) * 100)
			self:StartActivity(ACT_HL2MP_IDLE)

			if self.Idle == IDLETYPE_INTERUPT then
				self.Idle = IDLETYPE_ACTIVE 
				coroutine.yield()
				break
			end

		end
		
		coroutine.wait(2)
	end
end

function ENT:RunToRandomLocation() -- injured behaviour (run in panic), does not attack during this
	self:EmitSound(table.Random(self.Vo.Panic), 75, math.random(95,105), 1, CHAN_VOICE)
	self:StartActivity(ACT_HL2MP_RUN_PANICKED)
	self.loco:SetDesiredSpeed(200)
	self:MoveToPos(self:GetPos() + Vector(math.Rand(-1, 1), math.Rand(-1, 1), 0) * 600)
	coroutine.yield()
	return "ok"
end

function ENT:HealAlly()

	local patient
	for k, v in pairs( ents.FindInSphere(self:GetPos(), 2000) ) do
		if( v != self and v:GetClass() == self:GetClass() and v:Health() < v:GetMaxHealth() ) then -- find a nearby ally that is injured
			patient = v
			break
		end
	end

	print("finding patient")
	if( patient and patient:IsValid() ) then
		local path = Path("Follow")
		path:SetMinLookAheadDistance(0)
		path:SetGoalTolerance(20)
		print("found patient")
		path:Compute(self, patient:GetPos()) -- Fix the path computation by passing the patient's position as the goal
		path:SetGoalTolerance(20)
		local timeout = CurTime() + math.random(5,8)

		while path:IsValid() and timeout > CurTime() do


			self:StartActivity(ACT_HL2MP_RUN_PANICKED)
			self.loco:SetDesiredSpeed(100)
			print("starting to heal ally")

			if path:GetAge() > 0.1 then
				print("Going to heal ally")
				local vec = (patient:GetPos() - self:GetPos()):GetNormalized() * 100
				path:Update(self)
				self.loco:FaceTowards(patient:GetPos())
				local newPos = self:GetPos() + vec
				local tr = util.TraceLine({
					start = self:GetPos(),
					endpos = newPos,
					filter = self
				})
				path:Compute(self, newPos)
				if tr.Hit and tr.HitPos:Distance(self:GetPos()) < 128 then
					newPos = tr.HitPos + tr.HitNormal * 128
					self:EmitSound(table.Random(self.Vo.HealAlly), 75, math.random(95,105), 1, CHAN_VOICE)
					self:PlaySequenceAndWait(ACT_GMOD_GESTURE_ITEM_GIVE)
					patient:SetHealth(patient:GetMaxHealth())
					coroutine.yield()
					break
				end
			end
			
	
			if (self.loco:IsStuck()) then
				self:HandleStuck()
				return "stuck"
			end
			--coroutine.wait(2)

		end

	end

	coroutine.yield()

end

function ENT:GoRandomWhileShooting() -- go to a random location while shooting at the enemy
	self:EmitSound(table.Random(self.Vo.BehaviourFar), 75, math.random(95,105), 1, CHAN_VOICE)
	local path = Path("Follow")
	path:SetMinLookAheadDistance(0)
	path:SetGoalTolerance(20)
	path:Compute(self, self:GetPos() + Vector(math.Rand(-1, 1), math.Rand(-1, 1), 0) * 600)
    
	if not path:IsValid() then return "failed" end
	local timeout = CurTime() + math.random(5,8)

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
					self:StartActivity(self:GetAimAnim())
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

	end

	coroutine.yield()

	return "ok"
end

function ENT:GoAwayFromEnemy() -- go far away from the enemy while shooting at them
	self:EmitSound(table.Random(self.Vo.BehaviourFar), 75, math.random(95,105), 1, CHAN_VOICE)
	local path = Path("Follow")
	path:SetMinLookAheadDistance(0)
	path:SetGoalTolerance(20)
	path:Compute(self, self:GetEnemy():GetPos())
    
	if not path:IsValid() then return "failed" end
	local timeout = CurTime() + math.random(5,8)

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
					self:StartActivity(self:GetAimAnim())
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

function ENT:ChargeEnemy() -- charge to the enemy while shooting them. they will stand still and shoot the enemy while close to them
	self:EmitSound(table.Random(self.Vo.BehaviourCharge), 75, math.random(95,105), 1, CHAN_VOICE)
	local path = Path("Follow")
	path:SetMinLookAheadDistance(0)
	path:SetGoalTolerance(20)
	path:Compute(self, self:GetEnemy():GetPos())
	
	if not path:IsValid() then return "failed" end

	local timeout = CurTime() + math.random(6,12)

	while path:IsValid() and self:HaveEnemy() do
		if path:GetAge() > 0.1 then
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
					self:StartActivity(self:GetAimAnim())
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

function ENT:GetAimAnim()

	local wep = self:GetActiveLuaWeapon()
	if ( !IsValid( wep ) ) then return end

	local act = wep:GetActivity()

	local translations = {
		["pistol"] = ACT_HL2MP_WALK_REVOLVER,
		["smg"] = ACT_HL2MP_WALK_SMG1,
		["ar2"] = ACT_HL2MP_WALK_AR2,
		["shotgun"] = ACT_HL2MP_WALK_SHOTGUN,
		["crossbow"] = ACT_HL2MP_WALK_CROSSBOW,
		["rpg"] = ACT_HL2MP_WALK_RPG,
		["grenade"] = ACT_HL2MP_WALK_GRENADE,
	}

	local anim = translations[wep:GetHoldType()] or ACT_HL2MP_WALK_REVOLVER
	return anim

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
				self:EmitSound(table.Random(self.Vo.EnemySpotted), 75, math.random(95,105), 1, CHAN_VOICE)
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
	self.NextFire = CurTime()+0.4
	self:EmitSound(table.Random(self.Vo.Pain), 75, math.random(95,105), 1, CHAN_VOICE)
end

function ENT:OnKilled(dmginfo)
	self:EmitSound(table.Random(self.Vo.Die), 75, math.random(95,105), 1, CHAN_VOICE)
	local rag = self:BecomeRagdoll(dmginfo)
	hook.Call("OnNPCKilled", GAMEMODE, self, dmginfo:GetAttacker(), dmginfo:GetInflictor())
	SafeRemoveEntityDelayed(self, 0.01)
end

function ENT:Reload()
	local wep = self:GetActiveLuaWeapon()
	if wep.Reloading then return end
	self:RestartGesture(ACT_HL2MP_GESTURE_RELOAD_REVOLVER)
	wep.Reloading = true
	self:EmitSound(table.Random(self.Vo.Reload), 75, math.random(95,105), 1, CHAN_VOICE)
	timer.Simple(2.5, function()
		if self:IsValid() and wep:IsValid() then
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
		return -- Do not fire if the trace hits a friendly entity
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

	if( self.Idle == IDLETYPE_IDLE and self:HaveEnemy() ) then
		self.Idle = IDLETYPE_INTERUPT
	end

	if self.NextSound < CurTime() and !self.Enemy then
		self.NextSound = CurTime()+math.random(4,5)
		self:EmitSound(table.Random(self.Vo.Idle), 75, math.random(95,105), 1, CHAN_VOICE)
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

--[[function ENT:Touch(ent) -- this function doesn't work with nextbots, this was an attempt to prevent the NPC from getting stuck on objects
	print("TOUCHED")
	if( ent:GetClass() == "func_breakable" or ent:GetClass() == "prop_physics" ) then
		ent:TakeDamage( 1000, self )
	end
end--]]

ENT.Vo = {}
ENT.Vo.EnemySpotted = {"vo/npc/male01/overthere01.wav", "vo/npc/male01/overthere02.wav", "vo/npc/male01/watchout.wav", "vo/npc/male01/ohno.wav", "vo/npc/male01/headsup01.wav", "vo/npc/male01/headsup02.wav", "vo/npc/male01/heretheycome01.wav"}
ENT.Vo.Reload = {"vo/npc/male01/coverwhilereload01.wav", "vo/npc/male01/coverwhilereload02.wav"}
ENT.Vo.Die = {"vo/npc/male01/no01.wav", "vo/npc/male01/no02.wav"}
ENT.Vo.Pain = {
	"vo/npc/male01/hitingut02.wav",
	"vo/npc/male01/hitingut02.wav",
	"vo/npc/male01/hitingut02.wav",
	"vo/npc/male01/hitingut01.wav",
	"vo/npc/male01/myarm02.wav",
	"vo/npc/male01/myarm01.wav",
	"vo/npc/male01/myleg01.wav",
	"vo/npc/male01/myleg02.wav",
	"vo/npc/male01/pain01.wav",
	"vo/npc/male01/pain02.wav",
	"vo/npc/male01/pain03.wav",
	"vo/npc/male01/pain04.wav",
	"vo/npc/male01/pain05.wav",
	"vo/npc/male01/pain06.wav",
	"vo/npc/male01/pain07.wav",
	"vo/npc/male01/pain08.wav",
	"vo/npc/male01/pain09.wav",
}
ENT.Vo.Footstep = {}
ENT.Vo.Panic = { "vo/npc/male01/help01.wav", "vo/npc/male01/runforyourlife021.wav", "vo/npc/male01/runforyourlife02.wav", "vo/npc/male01/runforyourlife03.wav" }
ENT.Vo.BehaviourFar = { "vo/npc/male01/holddownspot01.wav", "vo/npc/male01/illstayhere01.wav", "vo/npc/male01/holddownspot02.wav"}
ENT.Vo.BehaviourCharge = { "vo/npc/male01/letsgo01.wav", "vo/npc/male01/letsgo02.wav", "vo/npc/male01/leadtheway01.wav", "vo/npc/male01/leadtheway02.wav"}
ENT.Vo.HealAlly = { "vo/npc/male01/health01.wav", "vo/npc/male01/health02.wav", "vo/npc/male01/health03.wav", "vo/npc/male01/health04.wav", "vo/npc/male01/health05.wav" }
ENT.Vo.Idle = {
	"vo/npc/male01/question01.wav",
	"vo/npc/male01/question02.wav",
	"vo/npc/male01/question03.wav",
	"vo/npc/male01/question04.wav",
	"vo/npc/male01/question05.wav",
	"vo/npc/male01/question06.wav",
	"vo/npc/male01/question07.wav",
	"vo/npc/male01/question08.wav",
	"vo/npc/male01/question09.wav",
	"vo/npc/male01/question10.wav",
	"vo/npc/male01/question11.wav",
	"vo/npc/male01/question12.wav",
	"vo/npc/male01/question13.wav",
	"vo/npc/male01/question14.wav",
	"vo/npc/male01/question15.wav",
	"vo/npc/male01/question16.wav",
	"vo/npc/male01/question17.wav",
	"vo/npc/male01/question18.wav",
	"vo/npc/male01/question19.wav",
	"vo/npc/male01/question20.wav",
	"vo/npc/male01/question21.wav",
	"vo/npc/male01/question22.wav",
	"vo/npc/male01/question23.wav",
	"vo/npc/male01/question24.wav",
	"vo/npc/male01/question25.wav",
	"vo/npc/male01/question26.wav",
	"vo/npc/male01/question27.wav",
	"vo/npc/male01/question28.wav",
	"vo/npc/male01/question29.wav",
	"vo/npc/male01/question30.wav",
	"vo/npc/male01/question31.wav"
}


list.Set("NPC", "raidman", {
	Name = "Raid Enemy",
	Class = "raidman",
	Category = "Raid"
})
