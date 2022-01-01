GM.Name = "Raid";
GM.Author = "Linked";
GM.Email = "N/A";
GM.Website = "N/A";

DeriveGamemode( "base" );

-- init system below made by jane i believe

local cfiles = file.Find( GM.FolderName .. "/gamemode/*.lua", "LUA", "namedesc" );

table.RemoveByValue( cfiles, "sh_setup.lua" );
table.RemoveByValue( cfiles, "init.lua" );
table.RemoveByValue( cfiles, "cl_init.lua" );

for k, v in pairs( cfiles ) do
	
	if( string.find( v, "sh_" ) ) then
	
		include( GM.FolderName .. "/gamemode/" .. v );
		
		if( SERVER ) then
		
			AddCSLuaFile( GM.FolderName .. "/gamemode/" .. v );
			
		end
		
		Msg( "loading " .. v .. "\n" );
		
	elseif( string.find( v, "cl_" ) ) then
	
		if( CLIENT ) then
	
			include( GM.FolderName .. "/gamemode/" .. v );
			
			Msg( "loading " .. v .. "\n" );
			
		else
		
			AddCSLuaFile( GM.FolderName .. "/gamemode/" .. v );
			
		end
		
	elseif( string.find( v, "sv_" ) and SERVER ) then
	
		include( GM.FolderName .. "/gamemode/" .. v );
		
		Msg( "loading " .. v .. "\n" );
		
	elseif( !string.find( v, "sv_" ) and !string.find( v, "cl_" ) and !string.find( v, "sh_" ) ) then
	
		-- this doesn't have a prefix. load it as if it were shared
		
		include( GM.FolderName .. "/gamemode/" .. v );
		AddCSLuaFile( GM.FolderName .. "/gamemode/" .. v );
		
		Msg( "loading " .. v .. "\n" );
		
	end
	
end
