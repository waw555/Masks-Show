/* AMX Mod X
*   CT Bomb Stealer
*
* (c) Copyright 2006 by VEN
*
* This file is provided as is (no warranties)
*
*     DESCRIPTION
*       Plugin allows to CTs collect/drop/plant the dropped bomb.
*       The CT bomb carrier has a VIP model and radar+score mark.
*       Drop/plant and VIP model/marks features can be disabled.
*
*     MODULES
*       fakemeta
*       cstrike
*
*     CVARs
*       cbs_drop (0: OFF, 1: ON, default: 1) - controls drop feature
*       cbs_plant (0: OFF, 1: ON, default: 1) - controls plant feature
*       cbs_model (0: OFF, 1: ON, default: 1) - controls model feature
*       cbs_marks (0: OFF, 1: ON, default: 1) - controls marks feature
*/

#include <amxmodx>
#include <fakemeta>
#include <cstrike>

// plugin's main information
#define PLUGIN_NAME "Бомба для ментов"
#define PLUGIN_VERSION "0.2"
#define PLUGIN_AUTHOR "Для WAW555"

// comment to disable
#define BOMB_MAP_CHECK

// CVAR names and it's default values
new g_drop_cvar[] = "cbs_drop"
new g_drop_def[] = "1"

new g_plant_cvar[] = "cbs_plant"
new g_plant_def[] = "0"

new g_model_cvar[] = "cbs_model"
new g_model_def[] = "0"

new g_marks_cvar[] = "cbs_marks"
new g_marks_def[] = "1"

#define MODELS_NUM 4
new g_class_model[MODELS_NUM][] = {"urban", "gsg9", "sas", "gign"}
new g_vip_model[] = "vip"

new CsInternalModel:g_internal_model[MODELS_NUM] = {CS_CT_URBAN, CS_CT_GSG9, CS_CT_SAS, CS_CT_GIGN}
new CsInternalModel:g_old_model

#define VIP_ATTRIB 4
#define	FL_ONGROUND (1<<9)

new g_game_bomb_pickup[] = "#Game_bomb_pickup"
new g_game_bomb_drop[] = "#Game_bomb_drop"
new g_cant_be_dropped[] = "#Weapon_Cannot_Be_Dropped"
new g_log_dropped[] = "Dropped_The_Bomb"

new g_flags_e[] = "e"
new g_flags_ae[] = "ae"
new g_ct[] = "CT"

new g_classname[] = "classname"
new g_weapon_c4[] = "weapon_c4"

new g_carrier
new g_maxplayers
new g_msgid_text
new g_msgid_attrib

new bool:g_collecting

// initial AMXX version number supported CVAR pointers in get/set_pcvar_* natives
#define CVAR_POINTERS_AMXX_INIT_VER_NUM 170

// determine if get/set_pcvar_* natives can be used
#if defined AMXX_VERSION_NUM && AMXX_VERSION_NUM >= CVAR_POINTERS_AMXX_INIT_VER_NUM
	#define CVAR_POINTERS

	new g_pcvar_drop
	new g_pcvar_plant
	new g_pcvar_model
	new g_pcvar_marks

	#define CVAR_DROP	get_pcvar_num(g_pcvar_drop)
	#define CVAR_PLANT	get_pcvar_num(g_pcvar_plant)
	#define CVAR_MODEL	get_pcvar_num(g_pcvar_model)
	#define CVAR_MARKS	get_pcvar_num(g_pcvar_marks)
#else
	#define CVAR_DROP	get_cvar_num(g_drop_cvar)
	#define CVAR_PLANT	get_cvar_num(g_plant_cvar)
	#define CVAR_MODEL	get_cvar_num(g_model_cvar)
	#define CVAR_MARKS	get_cvar_num(g_marks_cvar)

#endif

public plugin_init() {
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)

#if defined CVAR_POINTERS
	g_pcvar_drop = register_cvar(g_drop_cvar, g_drop_def)
	g_pcvar_plant = register_cvar(g_plant_cvar, g_plant_def)
	g_pcvar_model = register_cvar(g_model_cvar, g_model_def)
	g_pcvar_marks = register_cvar(g_marks_cvar, g_marks_def)
#else
	register_cvar(g_drop_cvar, g_drop_def)
	register_cvar(g_plant_cvar, g_plant_def)
	register_cvar(g_model_cvar, g_model_def)
	register_cvar(g_marks_cvar, g_marks_def)
#endif


#if defined BOMB_MAP_CHECK
	if (!engfunc(EngFunc_FindEntityByString, -1, g_classname, "func_bomb_target"))
		return
#endif

	register_event("HLTV", "event_new_round", "a", "1=0", "2=0")
	register_event("WeapPickup", "event_c4_pickup", "be", "1=6")
	register_event("TextMsg", "event_plant_try", "be", "2=#C4_Plant_At_Bomb_Spot")
	register_event("ScoreAttrib", "event_bomb_attrib", "bc", "2=2")

	register_logevent("logevent_bomb_drop_plant", 3, "2=Dropped_The_Bomb")
	register_logevent("logevent_bomb_drop_plant", 3, "2=Planted_The_Bomb")

	register_forward(FM_Touch, "forward_touch")

	register_clcmd("drop", "clcmd_drop")

	g_maxplayers = get_maxplayers()
	g_msgid_text = get_user_msgid("TextMsg")
	g_msgid_attrib = get_user_msgid("ScoreAttrib")
}

public forward_touch(ent, id) {
	if (!id || id > g_maxplayers || ent <= g_maxplayers || g_collecting || cs_get_user_team(id) != CS_TEAM_CT || !(pev(ent, pev_flags) & FL_ONGROUND))
		return FMRES_IGNORED

	new c4 = engfunc(EngFunc_FindEntityByString, -1, g_classname, g_weapon_c4)
	if (!c4 || pev(c4, pev_owner) != ent)
		return FMRES_IGNORED

	g_collecting = true
	g_old_model = CS_DONTCHANGE
	new CsInternalModel:new_model = CS_DONTCHANGE

	if (CVAR_MODEL) {
		new model[8]
		cs_get_user_model(id, model, 7)
		for (new i = 0; i < MODELS_NUM; ++i) {
			if (equali(model, g_class_model[i])) {
				g_old_model = g_internal_model[i]
				break
			}
		}

		if (g_old_model == CS_DONTCHANGE)
			g_old_model = g_internal_model[random_num(0, MODELS_NUM - 1)]

		new_model = CS_CT_VIP
	}

	new name[32]
	get_user_name(id, name, 31)
	msg_ct_bomb_text(name)

	cs_set_user_team(id, CS_TEAM_T)
	dllfunc(DLLFunc_Touch, ent, id)
	cs_set_user_team(id, CS_TEAM_CT, new_model)
	g_carrier = id

	if (!CVAR_PLANT)
		cs_set_user_plant(id, 0)

	if (CVAR_MARKS)
		msg_set_vip_attrib(id)

	return FMRES_SUPERCEDE
}


public event_c4_pickup(id) {
	g_collecting = false
}

public clcmd_drop(id) {
	if (!is_user_alive(id) || !user_has_weapon(id, CSW_C4) || cs_get_user_team(id) != CS_TEAM_CT || CVAR_DROP)
		return PLUGIN_CONTINUE

	new clip, ammo, arg[11]
	new weapon = get_user_weapon(id, clip, ammo)
	read_argv(1, arg, 10)
	if ((!arg[0] && weapon == CSW_C4) || equal(arg, g_weapon_c4)) {
		message_begin(MSG_ONE, g_msgid_text, _, id)
		write_byte(print_center)
		write_string(g_cant_be_dropped)
		message_end()

		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}

public event_plant_try(id) {
	if (cs_get_user_team(id) == CS_TEAM_CT && !cs_get_user_plant(id)) {
		message_begin(MSG_ONE, g_msgid_text, _, id)
		write_byte(print_center)
		write_string("")
		message_end()
	}
}

public event_bomb_attrib() {
	new id = read_data(1)
	if (!is_user_connected(id) || cs_get_user_team(id) != CS_TEAM_CT || !CVAR_MARKS)
		return

	msg_set_vip_attrib(id)
}

public logevent_bomb_drop_plant() {
	new carrier = g_carrier
	g_carrier = 0
	new logarg[80], name[32]
	read_logargv(0, logarg, 79)
	parse_loguser(logarg, name, 31)
	new id = get_user_index(name)
	new bool:connected = bool:is_user_connected(id)
	if ((!connected && id != carrier) || (connected && cs_get_user_team(id) != CS_TEAM_CT))
		return

	read_logargv(2, logarg, 17)
	if (equal(logarg, g_log_dropped))
		msg_ct_bomb_text(name, false)

	if (!connected)
		return

	new model[8]
	cs_get_user_model(id, model, 7)
	if (equali(model, g_vip_model))
		cs_set_user_team(id, CS_TEAM_CT, g_old_model)

	if (is_user_alive(id) && CVAR_MARKS)
		msg_set_vip_attrib(id, false)
}

public event_new_round() {
	g_carrier = 0
	new player[32], num
	get_players(player, num, g_flags_e, g_ct)
	if (!num)
		return

	new id, model[8]
	for (new i = 0; i < num; ++i) {
		id = player[i]
		cs_get_user_model(id, model, 7)
		if (equali(model, g_vip_model)) {
			cs_set_user_team(id, CS_TEAM_CT, g_old_model)
			break
		}
	}
}

msg_ct_bomb_text(name[], bool:got = true) {
	new player[32], num
	get_players(player, num, g_flags_ae, g_ct)
	if (!num)
		return

	new game_bomb[20]
	copy(game_bomb, 19, got ? g_game_bomb_pickup : g_game_bomb_drop)
	for (new i = 0; i < num; ++i) {
		message_begin(MSG_ONE, g_msgid_text, _, player[i])
		write_byte(print_center)
		write_string(game_bomb)
		write_string(name)
		message_end()
	}
}

msg_set_vip_attrib(id, bool:attrib = true) {
	message_begin(MSG_ALL, g_msgid_attrib)
	write_byte(id)
	write_byte(attrib ? VIP_ATTRIB : 0)
	message_end()
}
