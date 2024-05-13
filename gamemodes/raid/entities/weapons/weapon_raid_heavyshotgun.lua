
-- Variables that are used on both client and server

SWEP.PrintName		= "Heavy Shotgun" -- 'Nice' Weapon name (Shown on HUD)
SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/tnb/weapons/c_mossberg.mdl"
SWEP.WorldModel		= "models/tnb/weapons/w_mossberg.mdl"
SWEP.HoldType		= "shotgun"

SWEP.Spawnable		= false
SWEP.AdminOnly		= false

SWEP.Primary.ClipSize		= 4			-- Size of a clip
SWEP.Primary.DefaultClip	= 4		-- Default number of bullets in a clip
SWEP.Primary.Automatic		= false		-- Automatic/Semi Auto
SWEP.Primary.Ammo			= "Shotgun"
SWEP.Primary.Damage			= 5
SWEP.Primary.Sound			= "tekka/weapons/weapon_mossberg.wav"
SWEP.Primary.Delay			= 1
SWEP.Primary.NumBullets		= 6
SWEP.Primary.Accuracy		= 0.15

--[[---------------------------------------------------------
	Name: SWEP:Initialize()
	Desc: Called when the weapon is first loaded
-----------------------------------------------------------]]
function SWEP:Initialize()

	self:SetHoldType( self.HoldType )

end
