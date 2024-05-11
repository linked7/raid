
-- Variables that are used on both client and server

SWEP.PrintName		= "Pistol" -- 'Nice' Weapon name (Shown on HUD)
SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/tnb/weapons/c_mp5.mdl"
SWEP.WorldModel		= "models/tnb/weapons/w_mp5.mdl"
SWEP.HoldType		= "smg"

SWEP.Spawnable		= false
SWEP.AdminOnly		= false

SWEP.Primary.ClipSize		= 30			-- Size of a clip
SWEP.Primary.DefaultClip	= 30		-- Default number of bullets in a clip
SWEP.Primary.Automatic		= false		-- Automatic/Semi Auto
SWEP.Primary.Ammo			= "SMG1"
SWEP.Primary.Damage			= 5
SWEP.Primary.Sound			= "tekka/weapons/weapon_m4.wav"
SWEP.Primary.Delay			= 0.075
SWEP.Primary.NumBullets		= 1
SWEP.Primary.Accuracy		= 0.1

--[[---------------------------------------------------------
	Name: SWEP:Initialize()
	Desc: Called when the weapon is first loaded
-----------------------------------------------------------]]
function SWEP:Initialize()

	self:SetHoldType( self.HoldType )

end
