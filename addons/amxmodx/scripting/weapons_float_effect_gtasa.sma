#pragma semicolon 1

#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <reapi>

new const Float:WEAPON_HEIGHT = 44.0;
new const Float:WEAPON_MINS[3] = { -8.0, -8.0, -8.0 };
new const Float:WEAPON_MAXS[3] = { 8.0, 8.0, 8.0 };

new const BAD_MODEL_ANGLE = (1<<CSW_MP5NAVY) | (1<<CSW_MAC10) | (1<<CSW_XM1014);
new const HORIZONTAL_ANGLE[MAX_WEAPONS + 1] =
{
	0, // WEAPON_NONE
	-61, // WEAPON_P228
	0, // WEAPON_GLOCK
	-68, // WEAPON_SCOUT
	0, // WEAPON_HEGRENADE
	-187, // WEAPON_XM1014
	90, // WEAPON_C4
	90, // WEAPON_MAC10
	-119, // WEAPON_AUG
	0, // WEAPON_SMOKEGRENADE
	-87, // WEAPON_ELITE
	-51, // WEAPON_FIVESEVEN
	-67, // WEAPON_UMP45
	-115, // WEAPON_SG550
	16, // WEAPON_GALIL
	-28, // WEAPON_FAMAS
	-63, // WEAPON_USP
	-107, // WEAPON_GLOCK18
	-107, // WEAPON_AWP
	-172, // WEAPON_MP5N
	-95, // WEAPON_M249
	-123, // WEAPON_M3
	-58, // WEAPON_M4A1
	-132, // WEAPON_TMP
	-107, // WEAPON_G3SG1
	0, // WEAPON_FLASHBANG
	-107, // WEAPON_DEAGLE
	-129, // WEAPON_SG552
	-103, // WEAPON_AK47
	0, // WEAPON_KNIFE
	-124, // WEAPON_P90
};

new const ARMOURY_MAPPER[MAX_WEAPONS + 1] = { CSW_MP5NAVY, CSW_TMP, CSW_P90,
	CSW_MAC10, CSW_AK47, CSW_SG552, CSW_M4A1, CSW_AUG, CSW_SCOUT, CSW_G3SG1, CSW_AWP,
	CSW_M3, CSW_XM1014, CSW_M249, CSW_FLASHBANG, CSW_HEGRENADE, CSW_VEST, CSW_VESTHELM,
	CSW_SMOKEGRENADE, CSW_SHIELDGUN, CSW_FAMAS, CSW_SG550, CSW_GALIL, CSW_UMP45,
	CSW_GLOCK18, CSW_USP, CSW_ELITE, CSW_FIVESEVEN, CSW_P228, CSW_DEAGLE, };

enum
{
	WEAPONSTATE_DEFAULT,
	WEAPONSTATE_CALCULATIONS,
	WEAPONSTATE_FADEIN,
}

public plugin_precache()
{
	register_plugin("Weapons Float Effect (Like in GTA: SA)", "1.0.0", "fl0wer");

	RegisterHam(Ham_Spawn, "armoury_entity", "@CArmoury_Spawn_Post", true);
	RegisterHam(Ham_CS_Restart, "armoury_entity", "@CArmoury_Restart_Post", true);
	RegisterHam(Ham_SetObjectCollisionBox, "armoury_entity", "@CArmoury_SetObjectCollisionBox_Pre", false);
}

public plugin_init()
{
	RegisterHookChain(RG_CWeaponBox_SetModel, "@CWeaponBox_SetModel_Post", true);

	RegisterHam(Ham_Think, "weaponbox", "@CWeaponBox_Think_Pre", false);
	RegisterHam(Ham_Touch, "weaponbox", "@CWeaponBox_Touch_Pre", false);
	RegisterHam(Ham_SetObjectCollisionBox, "weaponbox", "@CWeaponBox_SetObjectCollisionBox_Pre", false);
}

@CWeaponBox_SetModel_Post(id, model[])
{
	if (rg_get_weaponbox_id(id) == WEAPON_NONE)
		return;

	set_entvar(id, var_iuser1, WEAPONSTATE_CALCULATIONS);
	set_entvar(id, var_gravity, 2.0);
	set_entvar(id, var_effects, get_entvar(id, var_effects) | EF_NODRAW);
	set_entvar(id, var_fuser1, Float:get_entvar(id, var_nextthink));
	set_entvar(id, var_nextthink, get_gametime() + 0.3);
}

@CWeaponBox_Think_Pre(id)
{
	switch (get_entvar(id, var_iuser1))
	{
		case WEAPONSTATE_CALCULATIONS:
		{
			set_entvar(id, var_nextthink, get_gametime() + 0.1);

			if (~get_entvar(id, var_flags) & FL_ONGROUND)
				return HAM_SUPERCEDE;

			new weaponId = any:rg_get_weaponbox_id(id);
			new Float:vecOrigin[3];
			new Float:vecAngles[3];

			get_entvar(id, var_origin, vecOrigin);
			get_entvar(id, var_angles, vecAngles);

			vecOrigin[2] += WEAPON_HEIGHT;

			vecAngles[0] = float(HORIZONTAL_ANGLE[weaponId]);
			vecAngles[1] += 90.0;
			vecAngles[2] = 90.0;

			// Flip Models with Wrong Angle
			if ((1<<weaponId) & BAD_MODEL_ANGLE)
				vecAngles[1] += 180.0;

			set_entvar(id, var_iuser1, WEAPONSTATE_FADEIN);
			set_entvar(id, var_effects, get_entvar(id, var_effects) & ~EF_NODRAW);
			set_entvar(id, var_rendermode, kRenderTransTexture);

			SetFloatEffect(id, vecOrigin, vecAngles);
			return HAM_SUPERCEDE;
		}
		case WEAPONSTATE_FADEIN: // Fade in
		{
			new Float:renderamt = Float:get_entvar(id, var_renderamt);

			if (renderamt >= 255.0)
			{
				set_entvar(id, var_iuser1, WEAPONSTATE_DEFAULT);
				set_entvar(id, var_nextthink, get_entvar(id, var_fuser1));
			}
			else
			{
				set_entvar(id, var_renderamt, floatmin(renderamt + 64.0, 255.0));
				set_entvar(id, var_nextthink, get_gametime() + 0.1);
			}

			return HAM_SUPERCEDE;
		}
	}

	// Allow to call Think to destroy items
	return HAM_IGNORED;
}

@CWeaponBox_Touch_Pre(id, other)
{
	if (get_entvar(id, var_iuser1) != WEAPONSTATE_DEFAULT)
		return;

	// Allow weapon boxes to pick up
	set_entvar(id, var_flags, get_entvar(id, var_flags) | FL_ONGROUND);
}

@CWeaponBox_SetObjectCollisionBox_Pre(id)
{
	SetObjectCollisionBox(id);
	return HAM_SUPERCEDE;
}

@CArmoury_Spawn_Post(id)
{
	new weaponId = ARMOURY_MAPPER[get_member(id, m_Armoury_iItem)];
	new Float:vecOrigin[3];
	new Float:vecAngles[3];

	engfunc(EngFunc_DropToFloor, id);

	get_entvar(id, var_origin, vecOrigin);
	get_entvar(id, var_angles, vecAngles);

	vecOrigin[2] += WEAPON_HEIGHT;

	if ((1<<weaponId) & ((1<<CSW_VEST) | (1<<CSW_VESTHELM)))
		vecAngles[0] = -90.0;
	else
	{
		vecAngles[0] = float(HORIZONTAL_ANGLE[weaponId]);

		// Flip Models with Wrong Angle
		if ((1<<weaponId) & BAD_MODEL_ANGLE)
			vecAngles[1] += 180.0;
	}

	vecAngles[1] += 90.0;
	vecAngles[2] = 90.0;

	SetFloatEffect(id, vecOrigin, vecAngles);
}

@CArmoury_Restart_Post(id)
{
	if (get_entvar(id, var_effects) & EF_NODRAW)
		return;

	new Float:vecOrigin[3];
	get_entvar(id, var_origin, vecOrigin);

	vecOrigin[2] += WEAPON_HEIGHT;

	engfunc(EngFunc_SetOrigin, id, vecOrigin);
}

@CArmoury_SetObjectCollisionBox_Pre(id)
{
	SetObjectCollisionBox(id);
	return HAM_SUPERCEDE;
}

SetObjectCollisionBox(id)
{
	new Float:vecOrigin[3];
	new Float:vecAbsMin[3];
	new Float:vecAbsMax[3];

	get_entvar(id, var_origin, vecOrigin);

	for (new i = 0; i < 3; i++)
	{
		vecAbsMin[i] = vecOrigin[i] + WEAPON_MINS[i];
		vecAbsMax[i] = vecOrigin[i] + WEAPON_MAXS[i];
	}

	set_entvar(id, var_absmin, vecAbsMin);
	set_entvar(id, var_absmax, vecAbsMax);
}

SetFloatEffect(id, Float:vecOrigin[3], Float:vecAngles[3])
{
	set_entvar(id, var_angles, vecAngles);
	set_entvar(id, var_avelocity, Float:{ 0.0, -90.0, 0.0 });

	// Allow rotation by physics calls
	set_entvar(id, var_gravity, 0.000000001);
	set_entvar(id, var_velocity, Float:{ 0.0, 0.0, 0.000000001 });

	engfunc(EngFunc_SetOrigin, id, vecOrigin);
}
