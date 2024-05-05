STATE_IDLE = 0
STATE_ACTIVE = 1

GM.SquadState = STATE_IDLE
GM.ActiveEnemies = {};
GM.ActiveRaiders = {};
GM.ForceRaidEnd = 0

util.AddNetworkString( "nUpdateFateCount" );
util.AddNetworkString( "nUpdateRaidStart" );
util.AddNetworkString( "nUpdateMoney" );
util.AddNetworkString( "nOpenStore" );
util.AddNetworkString( "nPurchaseItem" );

function GM:StartRaid()

	self.SquadState = STATE_ACTIVE

	local enemyType = table.Random( self.EnemyTypes )
	local enemyType = table.Copy( self.EnemyTypes["Custom"] )

	local location = table.Random( self.Arenas )

	local dangerLevel = self:GetDanger()

	self:PopulateLocation( location, dangerLevel, enemyType )

	self:RaidPlayers( location )

	self.ForceRaidEnd = CurTime() + math.random( 60, 120 );

	net.Start( "nUpdateRaidStart" );
		net.WriteUInt( self.ForceRaidEnd, 16 );
		net.WriteUInt( self.SquadState, 4 )
		net.WriteFloat( dangerLevel )
	net.Broadcast();

end

function GM:GetDanger()

	local danger = 0.1

	for a, ply in pairs( player.GetAll() ) do

		if( ply:Alive() ) then

			for k, v in pairs( self.Weapons ) do

				if( ply:HasWeapon( v[1] ) ) then

					danger = danger + v[2]

				end

				danger = danger + ( ply:Armor() / 100 )

			end

		end

	end

	print("DANGER IS: " .. danger)

	return danger

end

function GM:EndRaid()

	RunConsoleCommand( "gmod_admin_cleanup" )

	self.ActiveEnemies = {};

	timer.Simple( 0.05 , function()
		self:InitPostEntity()
		for k, v in pairs( player.GetAll() ) do

			v:SetPos( table.Random( self.Spawns ) )

			if( v:Alive() ) then

				self:GiveMoney( v, 10 )

			end

			self.SquadState = STATE_IDLE
			self.ForceRaidEnd = 0

			v:EmitSound("ambient/machines/teleport1.wav", 60)

			net.Start( "nUpdateRaidStart" );
				net.WriteUInt( self.ForceRaidEnd, 16 );
				net.WriteUInt( self.SquadState, 4 )
			net.Broadcast();

		end

	end)

end

function GM:RaidPlayers( location )

	arena_tabl = self.ArenaSpawns[location]

	for k, v in pairs( player.GetAll() ) do

		v:EmitSound("ambient/machines/teleport1.wav", 60)

		v:SetPos( table.Random( arena_tabl ) )

		table.insert( self.ActiveRaiders, v )

	end

end

function GM:PopulateLocation( location, dangerLevel, enemyType )

	local unusedSpawns = table.Copy( self.EnemySpawns[location] )

	local bust = 0
	local debt = 0

	local weightedEnemies = {};

	for k, v in pairs( enemyType ) do

		for i = 1, v["Weight"] do

			table.insert( weightedEnemies, v )

		end

	end

	local anySpawned = false
	local upgradeNPCs = false

	while( ( dangerLevel > 0 and bust < 6 ) or anySpawned == false ) do

		if( #unusedSpawns <= 0 ) then

			print( "PopulateLocation ran out of spawn points!")
			upgradeNPCs = true

		end

		local v = table.Random( weightedEnemies )

		local anything = false

		if( v and v["Price"] <= dangerLevel and dangerLevel - v["Price"] >= 0 ) then

			if( upgradeNPCs == true ) then

				local npc = table.Random( self.ActiveEnemies )

				npc:SetMaxHealth( npc:GetMaxHealth() * 2 )
				npc:SetHealth( npc:Health() * 2 )

				npc:SetColor( Color( 200, 50, 200, 255) )
				npc:SetRenderMode( RENDERMODE_TRANSCOLOR )

				npc.Reward = npc.Reward * 2

				dangerLevel = dangerLevel - 0.5
				bust = bust + 1

				print( "Upgrading NPC " .. npc:GetClass() )

			else

				anything = true
				anySpawned = true

				local spawn = table.Random( unusedSpawns )
				--print( "spawning " .. tostring( spawn[2] ) )

				table.RemoveByValue( unusedSpawns, spawn )

				local npc = ents.Create( v["NPC"] );
				npc:SetPos( spawn[2] );
				npc:SetAngles( Angle( 0, math.random(0,359), 0 ) );
				npc:SetHealth( v["Health"] or 50 )
				npc:SetMaxHealth( v["Health"] or 50 )
				npc:Spawn();
				npc:Activate();

				if( v["Weapon"] ) then
					npc:Give( v["Weapon"] )
				end

				if( v["Rebel"] and v["Rebel"] == true ) then

					npc:SetModel( table.Random( self.RebelModels ) );

				end

				npc.Reward = v["Reward"]

				table.insert( self.ActiveEnemies, npc )

				dangerLevel = math.Round( dangerLevel - v["Price"], 1 )

				if( v["Weapon"] ) then

					npc:Give( v["Weapon"] )

				end

				if( v["DamageScale"] ) then

					npc.CustomDamageScale = v["DamageScale"]

				end

				if( v["CustomModel"] ) then

					npc:SetModel( v["CustomModel"] )

				end

				if( v["HealthScale"] ) then

					npc:SetMaxHealth( npc:GetMaxHealth() * v["HealthScale"] )
					npc:SetHealth( npc:Health() * v["HealthScale"] )

				end

			end

		else

			table.RemoveByValue( weightedEnemies, v )

		end

		print("bust: " .. bust )

		if( anything == false ) then --protection from having too little danger to spawn anything

			bust = bust + 1

		end

	end

end
