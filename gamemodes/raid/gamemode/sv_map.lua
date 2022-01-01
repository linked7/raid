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
	
	local ent = ents.FindByClass( "func_dustmotes" );
	
	for k, v in pairs( ent ) do
		
		v:Remove();
		
	end
	
	if( self.OtherEnts ) then
		
		for _, v in pairs( self.OtherEnts ) do
			
			local purpose = ents.Create( v[3] );
			purpose:SetPos( v[1] );
			purpose:SetAngles( v[2] );
			
			purpose:Spawn();
			purpose:Activate();
			purpose:GetPhysicsObject():EnableMotion( false );
			purpose.Static = true;
			
		end
		
	end

end