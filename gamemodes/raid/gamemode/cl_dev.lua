ESpawns = {}

function GetEnemySpawn( ply, cmd, args )

	local spot = {}
	spot[1] = args[1] -- size
	spot[2] = ply:GetEyeTrace().HitPos;

	table.insert( ESpawns, spot )

	for k, v in pairs( ESpawns ) do

		if( !args[2] ) then

			MsgN( "{\"" .. v[1] .. "\", Vector( " .. tostring( math.ceil( v[2].x ) ) .. ", " .. tostring( math.ceil( v[2].y ) ) .. ", " .. tostring( math.ceil( v[2].z ) ) .. " ) }," );

		else

			MsgN( "Vector( " .. tostring( math.ceil( v[2].x ) ) .. ", " .. tostring( math.ceil( v[2].y ) ) .. ", " .. tostring( math.ceil( v[2].z ) ) .. " )," );

		end

	end

	--PrintTable( GAMEMODE.ESpawns )

end
concommand.Add( "dev_getenemyspawn", GetEnemySpawn );

function GetSpot( ply, cmd, args )

	local v = ply:GetEyeTrace().HitPos;

	MsgN( "Vector( " .. tostring( math.ceil( v.x ) ) .. ", " .. tostring( math.ceil( v.y ) ) .. ", " .. tostring( math.ceil( v.z ) ) .. " )," );

end
concommand.Add( "dev_getspot", GetSpot );

