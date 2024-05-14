local files = file.Find( GM.FolderName .. "/gamemode/maps/" .. game.GetMap() .. ".lua", "LUA", "namedesc" );

if( #files > 0 ) then

	for _, v in pairs( files ) do

		include( "maps/" .. v );
		AddCSLuaFile( "maps/" .. v );

	end

	MsgC( Color( 200, 200, 200, 255 ), "Serverside map lua file for " .. game.GetMap() .. " loaded.\n" );

else

	MsgC( Color( 200, 200, 200, 255 ), "Warning: No serverside map lua file for " .. game.GetMap() .. ".\n" );

end

function GM:InitPostEntity()
	if( self.MapEnts ) then
		for _, v in pairs( self.MapEnts ) do

			local ent = ents.Create( v[3] );
			ent:SetPos( v[1] );
			ent:SetAngles( v[2] );

			ent:Spawn();
			ent:Activate();
			if( ent and ent:IsValid() and ent:GetPhysicsObject() and ent:GetPhysicsObject():IsValid() ) then
				ent:GetPhysicsObject():EnableMotion( false );
				ent.Static = true;
			end

		end
		
	end
end
