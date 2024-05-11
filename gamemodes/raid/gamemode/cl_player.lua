STATE_IDLE = 0
STATE_ACTIVE = 1

LocalPlayer().Money = 0

function nUpdateRaidStart( len )

	GAMEMODE.ForceRaidEnd = net.ReadUInt( 16 );
	GAMEMODE.SquadState = net.ReadUInt( 4 )
	GAMEMODE.Threat = net.ReadFloat()

end
net.Receive( "nUpdateRaidStart", nUpdateRaidStart );

function nUpdateMoney( len )

	local amount = net.ReadUInt( 32 )

	LocalPlayer().Money = amount

end
net.Receive( "nUpdateMoney", nUpdateMoney );

