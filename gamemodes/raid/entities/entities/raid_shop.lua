AddCSLuaFile();

ENT.Base = "base_anim";
ENT.Type = "anim";

ENT.PrintName		= "Raid Store";
ENT.Author			= "Linked";
ENT.Contact			= "";
ENT.Purpose			= "";
ENT.Instructions	= "";

ENT.Spawnable			= false;
ENT.AdminSpawnable		= false;

ENT.Interesting 		= true;

function ENT:PostEntityPaste( ply, ent, tab )
	
	GAMEMODE:LogSecurity( ply:SteamID(), "n/a", ply:VisibleRPName(), "Tried to duplicate " .. ent:GetClass() .. "!" );
	ent:Remove();
	
end

function ENT:SetupDataTables()
	
end

function ENT:CanPhysgun()

	return false;

end

function ENT:Initialize()
	
	if( CLIENT ) then return; end
	
	self:SetUseType( SIMPLE_USE );
	
	self:SetModel( "models/props_combine/combine_interface001a.mdl" );
	self:PhysicsInit( SOLID_VPHYSICS );
	
	local phys = self:GetPhysicsObject();
	
	if( phys and phys:IsValid() ) then
		
		phys:EnableMotion( false );
		
	end
	
end

function ENT:Use( ply )

	if( SERVER ) then

		if( GAMEMODE.SquadState == STATE_IDLE ) then

			net.Start( "nOpenStore" );
			net.Send( ply );

		end

	end

end

function ENT:HUDFunc( y )

	draw.SimpleTextOutlined( "Raid Store", "ChatFont", ScrW() / 2, y, Color( 50, 50, 200, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, 255 ) );
	y = y + 15

end
	
if( CLIENT ) then

	function nOpenStore( len )

		local ply = LocalPlayer()

		if( !ply.Money ) then

			ply.Money = 0

		end

		local shopFrame = vgui.Create( "DFrame" );
		shopFrame:SetSize( 550, 400 );
		shopFrame:Center();
		shopFrame:SetTitle( "Raid Store" );
		shopFrame.lblTitle:SetFont( "DebugFixed" );
		shopFrame:MakePopup();
			
		shopFrame.ContentPane = vgui.Create( "DScrollPanel", shopFrame );
		shopFrame.ContentPane:SetPos( 0, 25 );
		shopFrame.ContentPane:SetSize( 550, 365 );
		function shopFrame.ContentPane:Paint() end
			
	--[[local ntext = "You have £" .. LocalPlayer().Money .. ".";
		shopFrame.Cash = vgui.Create( "DLabel", shopFrame.ContentPane );
		shopFrame.Cash:SetText( ntext );
		shopFrame.Cash:SetColor( Color( 200, 200, 0 ) );
		shopFrame.Cash:SetPos( 300, 0 );
		shopFrame.Cash:SetSize( 540, 22 );
		shopFrame.Cash:SetFont( "DebugFixedSmall" );--]]

		for k, v in pairs( GAMEMODE.Shop ) do

			local x = 50

			local y = 35

			if( k == "Weapons" ) then

				x = 25

			elseif( k == "Ammo" ) then

				x = 200

			elseif( k == "Other" ) then

				x = 375

			end

			shopFrame.Type = vgui.Create( "DLabel", shopFrame.ContentPane );
			shopFrame.Type:SetText( k );
			shopFrame.Type:SetColor( Color( 200, 200, 0 ) );
			shopFrame.Type:SetPos( x, 10 );
			shopFrame.Type:SetSize( 540, 22 );
			shopFrame.Type:SetFont( "ChatFont" );

			for a, b in pairs( v ) do

				shopFrame.Button = vgui.Create( "DButton", shopFrame.ContentPane );
				shopFrame.Button:SetFont( "DebugFixedSmall" );
				shopFrame.Button:SetText( b[1] .. " - £" .. b[3] );
				shopFrame.Button:SetPos( x, y );
				shopFrame.Button:SetSize( 150, 25 );
				function shopFrame.Button:DoClick()
							
					net.Start( "nPurchaseItem" );
						net.WriteString( b[2] );
						net.WriteUInt( b[3], 16 );
						net.WriteEntity( ply )
					net.SendToServer();
							
					shopFrame:Remove();
							
				end

				if( ply.Money < b[3] ) then

					shopFrame.Button:SetEnabled( false )

				end

				if( k == "Weapons" ) then

					if( ply:HasWeapon( b[2] ) ) then

						shopFrame.Button:SetEnabled( false )

					end

				end

				if( k == "Ammo" ) then

					shopFrame.Button:SetText( b[1] .. " Ammo - £" .. b[3] );

				end

				y = y + 30;

			end

		end

	end
	net.Receive( "nOpenStore", nOpenStore );

end