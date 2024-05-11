function GM:Think()

	if( self.SquadState == STATE_ACTIVE and self.ForceRaidEnd < CurTime() and self.ForceRaidEnd != 0 and not self.Ending ) then
		self.Ending = true
		self:EndRaid()

	end

end