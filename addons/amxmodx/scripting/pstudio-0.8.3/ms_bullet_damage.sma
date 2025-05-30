#include <amxmodx>
#include <amxmisc>
#include <cstrike>

new g_HudSync

public plugin_init()
{
	register_plugin("Bullet Damage", "1.2", "f117bomb|Er0p4uk|STR@TEG")
	register_event("Damage", "damage_message", "b", "2!0", "3=0", "4!0")
	register_cvar("bullet_damage", "1")
	g_HudSync = CreateHudSyncObj()
}

public damage_message(id)
{
	if (!get_cvar_float("bullet_damage"))
	return PLUGIN_HANDLED

	new attacker = get_user_attacker(id)
	if (is_user_connected(attacker))
	{
		if (get_cvar_num("bullet_damage")==1)
		{
			new damage = read_data(2)
			set_hudmessage(200, 200, 200, -1.0, 0.55, 2, 0.1, 4.0, 0.02, 0.02, -1)
			ShowSyncHudMsg(attacker, g_HudSync, "%i^n", damage)
		}

		if (get_cvar_num("bullet_damage")>1)
		{
			if (is_user_admin(id))
			{
				new damage = read_data(2)
				set_hudmessage(0, 255, 0, -1.0, 0.55, 2, 0.1, 4.0, 0.02, 0.02, -1)
				ShowSyncHudMsg(attacker, g_HudSync, "%i^n", damage)
			}

			if (cs_get_user_team(id)==CS_TEAM_T)
			{
				new damage = read_data(2)
				set_hudmessage(255, 0, 0, -1.0, 0.55, 2, 0.1, 4.0, 0.02, 0.02, -1)
				ShowSyncHudMsg(attacker, g_HudSync, "%i^n", damage)
			}

			if (cs_get_user_team(id)==CS_TEAM_CT)
			{
				new damage = read_data(2)
				set_hudmessage(0, 0, 255, -1.0, 0.55, 2, 0.1, 4.0, 0.02, 0.02, -1)
				ShowSyncHudMsg(attacker, g_HudSync, "%i^n", damage)
			}
		}
	}
	return PLUGIN_CONTINUE
}
