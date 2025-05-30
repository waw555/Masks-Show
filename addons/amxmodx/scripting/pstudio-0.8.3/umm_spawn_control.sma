/* AMX Mod X
*
*	UFPS Spawn Control
*
*	 Этот плагин является аддоном для UFPS Map Manager
*	и осуществляет запуск голосования при превышении количества
*	пользователей на сервере к количеству респаунов на текущей карте.
*
*	Плагин выполнен на основе:	"AuroRTV", "0.1", "K&Bear"
*
*
*	Переменные:
*		umm_control_spawn		(default - 1)	- Включает/отключает использование плагина
*		umm_control_timeout		(default - 3)	- Минимальный интервал в минутах через который сможет быть запущено голосование(0 - отключено)
*		umm_control_redirect	(default - 0)	- Включает/отключает использование редиректов лишних игроков
*		umm_control_server		"server:port"	- Адрес и порт сервера для редиректа игроков
*		umm_control_password					- Пароль сервера для редиректа игроков
*
*	This file is part of UFPS.Team Plugins
*/

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>


#define PLUGIN_NAME			"UFPS Spawn Control"
#define PLUGIN_VERSION		"1.1"
#define PLUGIN_AUTHOR		"UFPS.Team"


#define TASK_CTRL			13827


new g_spawns

new pcv_spawn
new pcv_timeout
new pcv_redirect
new pcv_server
new pcv_password


public plugin_init( )
{
	register_plugin( PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR )

	pcv_spawn		= register_cvar( "umm_control_spawn",		"1" )
	pcv_timeout		= register_cvar( "umm_control_timeout",		"3" )
	pcv_redirect	= register_cvar( "umm_control_redirect",	"0" )
	pcv_server		= register_cvar( "umm_control_server",		""  )
	pcv_password	= register_cvar( "umm_control_password",	""  )
}

public plugin_cfg( )
{
	new ent = 0
	g_spawns = 0
	while(( ent = engfunc( EngFunc_FindEntityByString, ent, "classname", "info_player_deathmatch" ) ) != 0 ) {g_spawns++;}
	ent = 0
	while(( ent = engfunc( EngFunc_FindEntityByString, ent, "classname", "info_player_start" ) ) != 0 ) {g_spawns++;}

	if( g_spawns < get_maxplayers( ) && get_pcvar_num( pcv_timeout ) )
		set_task( float( clamp( get_pcvar_num( pcv_timeout ), 1, 30 ) * 60 ), "task_spawn_control", TASK_CTRL, _, _, "b" )

	
}

public client_authorized( id )
{
	if( get_pcvar_num( pcv_redirect ) )
	{
		if( get_playersnum( 1 ) > g_spawns && !access( id, ADMIN_RESERVATION ) )
		{
			new r_server[32], r_password[32]
			get_pcvar_string( pcv_server, r_server, charsmax( r_server ) )
			get_pcvar_string( pcv_password, r_password, charsmax( r_password ) )

			if( r_server[0] ) client_cmd( id, ";passWord ^"%s^"", r_password )

			client_cmd( id, ";Echo ^"* Redirect to another server.^";discoNNect;Wait;Wait;Wait;coNNect %s", r_server )

			new name[32]
			get_user_name( id, name, charsmax( name ) )

			//log_amx( "UFPS Spawn Conrtol: [REDIRECT PLAYER] | Name %s | Spawns %d", name, g_spawns )
		}
	}
}

public task_spawn_control( )
{
	if( get_pcvar_num( pcv_spawn ) )
	{
		new players = get_playersnum( 1 )

		if( players > g_spawns )
		{
			new mapname[32]
			get_mapname( mapname, charsmax( mapname ) )

			log_amx( "UFPS Spawn Conrtol: [START VOTE] | Map %s | Spawns %d | Players %d", mapname, g_spawns, players )
	
			server_cmd( "umm_extend_maxrounds_max 0" )	// Отключаем продление карты
			server_cmd( "umm_extend_timelimit_max 0" )	// Отключаем продление карты
			server_cmd( "umm_votemap" )
		}
	}
}

public plugin_end( )
	if( task_exists( TASK_CTRL ) ) remove_task( TASK_CTRL )
