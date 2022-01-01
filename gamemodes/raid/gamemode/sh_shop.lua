GM.Shop = {
	["Weapons"] = {
		{ "Pistol", "weapon_pistol", 10 },
		{ "SMG", "weapon_smg1", 25 },
		{ "Shotgun", "weapon_shotgun", 40 },
		{ ".357", "weapon_357", 40 },
		{ "Medkit", "weapon_medkit", 75 },
		{ "Crossbow", "weapon_crossbow", 75 },
		{ "AR2", "weapon_ar2", 100 },
		{ "RPG", "weapon_rpg", 100 },
		{ "Grenade", "weapon_frag", 10, true },
		{ "Bugbait", "weapon_bugbait", 10, true },
	},
	["Ammo"] = {
		{ "Pistol", "item_ammo_pistol", 5 },
		{ "SMG", "item_ammo_smg1", 10 },
		{ "Shotgun", "item_box_buckshot", 30 },
		{ ".357", "item_ammo_357", 10 },
		{ "Crossbow", "item_ammo_crossbow", 30 },
		{ "AR2", "item_ammo_ar2", 20 },
		{ "AR2 Alt", "item_ammo_ar2_altfire", 20 },
		{ "SMG Alt", "item_ammo_smg1_grenade", 20 },
		{ "RPG", "item_rpg_round", 20 },
	},
	["Other"] = {
		{ "Armour", "item_battery", 20 },
		{ "Health", "item_healthkit", 15 },
		{ "Minor Health", "item_healthvial", 5 },
		{ "Dynamic", "item_dynamic_resupply", 50 },
	},
};

GM.Weapons = {
	{ "weapon_crowbar", 0.5 }, -- base player threat
	{ "weapon_pistol", 0.25 },
	{ "weapon_smg1", 0.25 },
	{ "weapon_shotgun", 0.25 },
	{ "weapon_357", 0.25 },
	{ "weapon_medkit", 0.25 },
	{ "weapon_crossbow", 0.25 },
	{ "weapon_ar2", 0.25 },
	{ "weapon_rpg", 0.25 },
	{ "weapon_frag", 0.25 },
	{ "weapon_bugbait", 0 }, -- maybe bugbait should be an investment to lower threat
};