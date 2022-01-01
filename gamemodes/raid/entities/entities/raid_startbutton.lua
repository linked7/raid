AddCSLuaFile();

ENT.Base = "base_anim";
ENT.Type = "anim";

ENT.PrintName		= "Start Button";
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
	
	self:SetModel( "models/props_combine/breenconsole.mdl" );
	self:PhysicsInit( SOLID_VPHYSICS );
	
	local phys = self:GetPhysicsObject();
	
	if( phys and phys:IsValid() ) then
		
		phys:EnableMotion( false );
		
	end
	
end

function ENT:Think()
	
	if( CLIENT ) then return end
	
end

function ENT:Use( ply )

	if( CLIENT ) then return end

	if( GAMEMODE.SquadState == STATE_IDLE and !self.Starting ) then

		self.Starting = true

		self:EmitSound("buttons/button9.wav", 75, math.random(90, 110));

		timer.Simple(5, function()

			if( self.Starting ) then

				GAMEMODE:StartRaid()

			end
			self.Starting = false

		end )

	elseif( GAMEMODE.SquadState == STATE_IDLE ) then

		self:EmitSound( "ambient/alarms/klaxon1.wav", 60 );

	end
		
end

function ENT:HUDFunc( y )

	draw.SimpleTextOutlined( "Raid Start", "ChatFont", ScrW() / 2, y, Color( 50, 50, 200, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, 255 ) );
	y = y + 15

end