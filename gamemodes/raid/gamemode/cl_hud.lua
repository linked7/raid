function GM:HUDPaint()

	local get = LocalPlayer():GetEyeTraceNoCursor();

	if( get and get.Entity and get.Entity:IsValid() ) then

		playerY = (ScrH() / 2) + 25

		if( get.Entity:IsPlayer() and get.Entity:Alive() ) then

			draw.SimpleTextOutlined( get.Entity:Nick(), "ChatFont", ScrW() / 2, playerY, Color( 200, 200, 0, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, 255 ) );
			playerY = playerY + 15

			draw.SimpleTextOutlined( get.Entity:Health() .. "% Health", "ChatFont", ScrW() / 2, playerY, Color( 200, 50, 50, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, 255 ) );
			playerY = playerY + 15

			if( get.Entity:Armor() and get.Entity:Armor() > 0 ) then

				draw.SimpleTextOutlined( get.Entity:Armor() .. "% Armor", "ChatFont", ScrW() / 2, playerY, Color( 50, 50, 200, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, 255 ) );
				playerY = playerY + 15

			end

		end

		if( get.Entity.Interesting ) then

			get.Entity:HUDFunc( playerY )

		end

	end

	local ply = LocalPlayer();
	local money = 0

	if( ply.Money ) then

		money = ply.Money

	end

	local y = 200

	draw.SimpleTextOutlined( "£" .. money, "ChatFont", ScrW() - 25, ScrH() - y, Color( 200, 200, 0, 200 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, 255 ) );
	y = y + 20

	local sState = "Idle"

	if( self.SquadState and self.SquadState == STATE_ACTIVE and self.ForceRaidEnd ) then

		sState = "Active"
		draw.SimpleTextOutlined( "Raid Time: " .. math.Round( self.ForceRaidEnd - CurTime() ), "ChatFont", ScrW() - 25, ScrH() - y, Color( 200, 200, 0, 200 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, 255 ) );
		y = y + 20

		draw.SimpleTextOutlined( "Raid Threat: " .. math.Round( self.Threat, 2 ), "ChatFont", ScrW() - 25, ScrH() - y, Color( 200, 200, 0, 200 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, 255 ) );
		y = y + 20

	end

	draw.SimpleTextOutlined( "Squad State: " .. sState, "ChatFont", ScrW() - 25, ScrH() - y, Color( 200, 200, 0, 200 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, 255 ) );
	y = y + 20

end