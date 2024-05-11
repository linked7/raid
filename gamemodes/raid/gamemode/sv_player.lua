function GM:PlayerLoadout( ply )

	ply:Give( "weapon_crowbar" )

end

local function SpawnUpdateClient( ply )

	local mdls = {
		"models/player/urban.mdl",
		"models/player/swat.mdl",
		"models/player/riot.mdl",
		"models/player/gasmask.mdl",
	};

	ply:SetModel( table.Random( mdls ) )

	ply:SetTeam( 1 )
	ply:SetNoCollideWithTeammates( true )

	net.Start( "nUpdateRaidStart" );
		net.WriteUInt( GAMEMODE.ForceRaidEnd, 16 );
		net.WriteUInt( GAMEMODE.SquadState, 4 )
	net.Send( ply );

	GAMEMODE:GiveMoney( ply, 0 ) -- to ensure they get money on initial spawn

end
hook.Add( "PlayerSpawn", "Spawn_Client_Update", SpawnUpdateClient )

function GM:GiveMoney( ply, amt )

	if( !ply.Money ) then
		ply.Money = 0
	end

	ply.Money = ply.Money + amt

	net.Start( "nUpdateMoney" );
		net.WriteUInt( ply.Money, 32 );
	net.Send( ply )

end

function nPurchaseItem()

	local item = net.ReadString();
	local price = net.ReadUInt( 16 );
	local ply = net.ReadEntity()

	if( ply.Money >= price ) then

		GAMEMODE:GiveMoney( ply, -price )

		ply:Give( item )

	end

end
net.Receive( "nPurchaseItem", nPurchaseItem );

function GM:OnNPCKilled( npc, attacker, inf )

	if( attacker and attacker:IsPlayer() and npc.Reward ) then

		self:GiveMoney( attacker, npc.Reward )

	end

	if( table.HasValue( self.ActiveEnemies, npc ) ) then

		table.RemoveByValue( self.ActiveEnemies, npc )

		if( table.IsEmpty( self.ActiveEnemies ) ) then

			attacker:EmitSound( "buttons/button1.wav", 90 )

			timer.Simple( 3, function() self:EndRaid() end )

		end

	end

end

function GM:DoPlayerDeath( ply, attacker, inf )

	if( attacker:IsPlayer() and attacker:IsValid() and attacker != ply ) then

		attacker.Money = attacker.Money * 0.6

		net.Start( "nUpdateMoney" );
			net.WriteUInt( ply.Money, 32 );
		net.Send( attacker )

		if( self.SquadState == STATE_IDLE ) then

			attacker:EmitSound( "ambient/alarms/klaxon1.wav" );
			attacker:Kill()

		end

	end

	ply.Money = ply.Money * 0.5

	net.Start( "nUpdateMoney" );
		net.WriteUInt( ply.Money, 32 );
	net.Send( ply )

end

GM.BannedWeaponPickups = {
	--"weapon_crowbar",
	"weapon_stunstick",
	"weapon_pistol",
	"weapon_smg1",
	"weapon_ar2",
	"weapon_shotgun",
	"weapon_crossbow",
	"weapon_357",
	"weapon_rpg",
	"weapon_annabelle",
};
function GM:PlayerCanPickupWeapon( ply, wep )

	if( table.HasValue( self.BannedWeaponPickups, wep:GetClass() ) and self.SquadState == STATE_ACTIVE ) then

		return false;

	end

	return true;

end

function GM:PlayerShouldTakeDamage(ply, attacker)
	if ((attacker:GetClass() == "prop_physics" and attacker:GetModel() ~= "models/props_c17/trappropeller_blade.mdl") or attacker:GetClass() == "prop_ragdoll" or attacker:GetClass() == "prop_combine_ball" ) then return false; end

	return true;
end

function GM:EntityTakeDamage(ent, dmg)

	if (ent:IsPlayer() and dmg:GetAttacker() and dmg:GetAttacker():IsValid() and dmg:GetAttacker():IsPlayer() ) then

		dmg:ScaleDamage( 0.25 )

		if( self.SquadState == STATE_IDLE ) then

			dmg:GetAttacker():TakeDamage( dmg:GetDamage() )

			dmg:ScaleDamage( 0 )

		end

	end

	if (ent:IsPlayer() and dmg:GetAttacker() and dmg:GetAttacker().CustomDamageScale ) then

		dmg:ScaleDamage( dmg:GetAttacker().CustomDamageScale )

	end

end
