
-- Variables that are used on both client and server

SWEP.PrintName		= "Pistol" -- 'Nice' Weapon name (Shown on HUD)
SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/tnb/weapons/c_makarov.mdl"
SWEP.WorldModel		= "models/tnb/weapons/w_makarov.mdl"
SWEP.HoldType		= "pistol"

SWEP.Spawnable		= false
SWEP.AdminOnly		= false

SWEP.Primary.ClipSize		= 8			-- Size of a clip
SWEP.Primary.DefaultClip	= 8		-- Default number of bullets in a clip
SWEP.Primary.Automatic		= false		-- Automatic/Semi Auto
SWEP.Primary.Ammo			= "Pistol"
SWEP.Primary.Damage			= 4
SWEP.Primary.Sound			= "tekka/weapons/weapon_blat.wav"
SWEP.Primary.Delay			= 0.3
SWEP.Primary.NumBullets		= 1
SWEP.Primary.Accuracy		= 0.03

--[[---------------------------------------------------------
	Name: SWEP:Initialize()
	Desc: Called when the weapon is first loaded
-----------------------------------------------------------]]
function SWEP:Initialize()

	self:SetHoldType( self.HoldType )

end
