function GM:Think()

	if( self.SquadState == STATE_ACTIVE and self.ForceRaidEnd < CurTime() and self.ForceRaidEnd != 0 ) then

		self:EndRaid()

	end

end