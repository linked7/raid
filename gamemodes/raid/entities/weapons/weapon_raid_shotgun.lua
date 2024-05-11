
-- Variables that are used on both client and server

SWEP.PrintName		= "Shotgun" -- 'Nice' Weapon name (Shown on HUD)
SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/tnb/weapons/c_sawnoff.mdl"
SWEP.WorldModel		= "models/tnb/weapons/w_sawnoff.mdl"
SWEP.HoldType		= "shotgun"

SWEP.Spawnable		= false
SWEP.AdminOnly		= false

SWEP.Primary.ClipSize		= 2			-- Size of a clip
SWEP.Primary.DefaultClip	= 2		-- Default number of bullets in a clip
SWEP.Primary.Automatic		= false		-- Automatic/Semi Auto
SWEP.Primary.Ammo			= "Shotgun"
SWEP.Primary.Damage			= 4
SWEP.Primary.Sound			= "Weapon_Shotgun.Single"
SWEP.Primary.Delay			= 0.7
SWEP.Primary.NumBullets		= 6
SWEP.Primary.Accuracy		= 0.1

--[[---------------------------------------------------------
	Name: SWEP:Initialize()
	Desc: Called when the weapon is first loaded
-----------------------------------------------------------]]
function SWEP:Initialize()

	self:SetHoldType( self.HoldType )

end
