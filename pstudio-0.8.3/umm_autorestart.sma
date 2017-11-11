/*	AMX Mod X
*
*	UFPS Auto Restart
*	 Ётот плагин €вл€етс€ аддоном дл€ UFPS Map Manager
*
*	ѕеременные поместить в server.cfg:
*		umm_autorestart <0|1|2>			(default: 0)	- –ежимы авторестартов: OFF, TIME, ONE ROUND
*															TIME:		авторестарт по истечении заданного интервала времени от 10 до 90 секунд
*															ONE ROUND:	авторестарт после окончани€ 1-го раунда
*		umm_autorestart_hud				(default: 1)	- ¬ключение вывода HUD сообщений
*		umm_autorestart_time <10-90>	(default: 20)	- ¬рем€ в секундах дл€ авторестарта (только дл€ режима TIME)
*		umm_autorestart_limit			(default: 3)	-  оличество рестартов
*		umm_autorestart_protect <0|1>	(default: 1)	- «ащита игроков от повреждений на врем€ рестарта (только дл€ режима TIME)
*		umm_autorestart_voteratio		(default - 0)	- ѕроцент игроков дл€ голосовани€ за рестарт карты
*
*	This file is part of UFPS.Team Plugins
*/

#include <amxmodx>
#include <fun>

#define PLUGIN_NAME		"UFPS Auto Restart"
#define PLUGIN_VERSION	"3.8"
#define PLUGIN_AUTHOR	"UFPS.Team"

#define HUD_RESTART		220, 160, 0, -1.0, 0.8, 0, 0.0, 1.03, 0.0, 0.0, 5
#define HUD_LAST		100, 200, 0, -1.0, 0.8, 0, 0.0, 3.0, 0.0, 2.0, 5

#define TASK_ID_ARR_COUNTDOWN	8854

new message[128]

new g_arr_limit
new g_arr_round
new g_arr_HudSync
new g_arr_countdown

new bool:g_arr_voteplayer[33] = { false, ... }

new pcv_admin_level
new pcv_admin_voteweight

new pcv_autorestart
new pcv_autorestart_hud
new pcv_autorestart_time
new pcv_autorestart_limit
new pcv_autorestart_protect
new pcv_autorestart_voteratio

public plugin_init()
{
	register_plugin ( PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR )
	register_dictionary ( "umm.txt" )

	register_event ( "ResetHUD", "event_reset_hud", "be" )
	register_event ( "TextMsg", "event_start_game", "a", "2=#Game_Commencing" )
	register_logevent ( "event_start_round", 2,	 "0=World triggered",	"1=Round_Start" )

	register_clcmd ( "say /rr",			"cmd_say_rr",	0, "- vote restart" )
	register_clcmd ( "say_team /rr",	"cmd_say_rr",	0, "- vote restart" )

	pcv_autorestart				= register_cvar ( "umm_autorestart",			"0" )
	pcv_autorestart_hud			= register_cvar ( "umm_autorestart_hud",		"1" )
	pcv_autorestart_time		= register_cvar ( "umm_autorestart_time",		"20" )
	pcv_autorestart_limit		= register_cvar ( "umm_autorestart_limit",		"3" )
	pcv_autorestart_protect		= register_cvar ( "umm_autorestart_protect",	"1" )
	pcv_autorestart_voteratio	= register_cvar ( "umm_autorestart_voteratio",	"0" )

	g_arr_HudSync			= CreateHudSyncObj()

	pcv_admin_level			= get_cvar_pointer ( "umm_admin_level" )
	pcv_admin_voteweight	= get_cvar_pointer ( "umm_admin_voteweight" )
}

public task_arr_countdown ( )
{
	if ( g_arr_countdown )
	{
		format ( message, sizeof ( message ) - 1, "%L", LANG_PLAYER, "SH_AUTO_RESTART_ROUND" , g_arr_countdown )

		if ( g_arr_countdown < g_arr_limit )
			set_cvar_float ( "sv_restart", 1.0 )

		else if ( get_pcvar_num ( pcv_autorestart ) == 1 && get_pcvar_num ( pcv_autorestart_protect ) )
		{
			cmd_arr_protect()
			format ( message, sizeof ( message ) - 1, "%s%L", message, LANG_PLAYER, "SH_AUTO_PROTECT_PLAYERS" )
		}

		set_hudmessage ( HUD_RESTART )
		show_hudmsg ( 0 )

		g_arr_countdown--

		set_task ( 1.0, "task_arr_countdown", TASK_ID_ARR_COUNTDOWN )
	}

	else
	{
		format ( message, sizeof ( message ) - 1, "%L", LANG_PLAYER, "SH_AUTO_GL_HF" )

		set_hudmessage ( HUD_LAST )

		set_task ( 1.0, "task_arr_countlast" )
	}
}

public task_arr_countlast ( )
{
	if ( task_exists ( TASK_ID_ARR_COUNTDOWN ) )
		remove_task ( TASK_ID_ARR_COUNTDOWN )

	show_hudmsg ( 0 )
	cmd_clear_vote ( )
}

public cmd_arr_protect ( )
{
	new players[32], num
	
	get_players ( players, num, "h" )
	
	for ( new i=0; i<num;i ++ )
		if ( !is_user_hltv ( players[i] ) && is_user_alive ( players[i] ) && !get_user_godmode ( players[i] ) )
			set_user_godmode ( players[i], 1 )
}

public cmd_say_rr ( id )
{
	if 	(	!get_pcvar_float ( pcv_autorestart_voteratio ) ||
			task_exists ( TASK_ID_ARR_COUNTDOWN ) ||
			( get_pcvar_num ( pcv_autorestart ) == 1 && g_arr_round < 2 ) ||
			( get_pcvar_num ( pcv_autorestart ) == 2 && g_arr_round < 3 )
		)
	{
		client_print ( id, print_chat, "%L", id, "CL_VOTE_RR_DISABLE" )
		return PLUGIN_HANDLED
	}

	if ( g_arr_voteplayer[id] )
	{
		client_print ( id, print_chat, "%L", id, "CL_VOTE_RR_ALREADY" )
	}

	else
	{
		new  name[32]
		get_user_name ( id, name, sizeof ( name ) - 1 )
		client_print ( 0, print_chat, "%L", LANG_PLAYER, "CL_VOTE_RR", name )
		log_amx ( "%L", LANG_SERVER, "CL_VOTE_RR", name )
		g_arr_voteplayer[id] = true
	}

	new players[32], num, voted
	get_players ( players, num, "ch" )

	for ( new i = 0; i < num; ++i )
	{
		if ( g_arr_voteplayer[players[i]] )
		{
			if ( get_user_flags ( players[i] ) & get_admin_level_flag() )
				voted += get_pcvar_num ( pcv_admin_voteweight )

			else
				voted++
		}
	}

	if ( floatround (get_pcvar_float ( pcv_autorestart_voteratio ) * 100 ) > ( voted * 100 / num ) )
	{
		client_print ( 0, print_chat, "%L", LANG_PLAYER, "CL_VOTE_RR_PLAYERS", voted, floatround ( get_pcvar_float ( pcv_autorestart_voteratio ) * num + 0.49 ) )
		log_amx ( "%L", LANG_SERVER, "CL_VOTE_RR_PLAYERS", voted, floatround ( get_pcvar_float ( pcv_autorestart_voteratio ) * num + 0.49 ) )

		return PLUGIN_CONTINUE
	}

	client_print ( 0, print_chat, "%L", LANG_PLAYER, "CL_VOTE_RR_ALL" )
	log_amx ( "%L", LANG_SERVER, "CL_VOTE_RR_ALL" )

	g_arr_limit		= check_pcvar ( get_pcvar_num ( pcv_autorestart_limit ), 1, 3 ) + 1
	g_arr_countdown = g_arr_limit - 1

	set_task ( 1.0, "task_arr_countdown", TASK_ID_ARR_COUNTDOWN )

	return PLUGIN_CONTINUE
}

public event_start_round ( )
{
	g_arr_round++

	switch ( get_pcvar_num ( pcv_autorestart ) )
	{
		case 1:
		{
			if ( g_arr_round == 1 )
			{
				if ( task_exists ( TASK_ID_ARR_COUNTDOWN ) )
					return PLUGIN_CONTINUE

				g_arr_countdown	= check_pcvar ( get_pcvar_num ( pcv_autorestart_time ), 10, 90 )
				g_arr_limit		= check_pcvar ( get_pcvar_num ( pcv_autorestart_limit ), 1, g_arr_countdown ) + 1

				set_task ( 1.0, "task_arr_countdown", TASK_ID_ARR_COUNTDOWN )
			}
		}

		case 2:
		{
			if ( g_arr_round == 2 )
			{
				if ( task_exists ( TASK_ID_ARR_COUNTDOWN ) )
					return PLUGIN_CONTINUE

				g_arr_limit		= check_pcvar ( get_pcvar_num ( pcv_autorestart_limit ), 1, 3 ) + 1
				g_arr_countdown = g_arr_limit - 1

				set_task ( 1.0, "task_arr_countdown", TASK_ID_ARR_COUNTDOWN )
			}
		}
	}

	return PLUGIN_CONTINUE
}

public event_reset_hud ( id )
{
	if ( task_exists ( TASK_ID_ARR_COUNTDOWN ) )
		show_hudmsg ( id )

	return PLUGIN_CONTINUE
}

public event_start_game ( )
{
	g_arr_round = 0

	return PLUGIN_CONTINUE
}

public get_admin_level_flag ( )
{
	new flags[24]

	get_pcvar_string ( pcv_admin_level, flags, sizeof ( flags ) - 1 )

	if ( !strlen ( flags ) )
		copy ( flags, sizeof ( flags ) - 1, "b" )

	return ( read_flags ( flags ) )
}

cmd_clear_vote ( )
{
	for ( new i = 0; i < 33; ++i )
		g_arr_voteplayer[i] = false
}

show_hudmsg ( id )
{
	if ( get_pcvar_num ( pcv_autorestart_hud ) )
		ShowSyncHudMsg ( id, g_arr_HudSync, "%s", message )
}

check_pcvar ( var, min, max )
{
	new value = var

	if ( value < min )
		value = min

	else if ( value > max )
		value = max

	return 	value
}

public client_disconnect ( id )
{
	g_arr_voteplayer[id] = false

	return PLUGIN_CONTINUE
}

public plugin_end ( )
{
	if ( task_exists ( TASK_ID_ARR_COUNTDOWN ) )
		remove_task ( TASK_ID_ARR_COUNTDOWN )
}
