/*	AMX Mod X
*
*	UFPS Map Config
*	 Этот плагин является аддоном для UFPS Map Manager
*
*	- Для каждой карты плагин пытается выполнить:
*		\addons\amxmodx\configs\umm\maps\default.cfg
*		\addons\amxmodx\configs\umm\maps\default_<prefix>.cfg
*		\addons\amxmodx\configs\umm\maps\<map_name>.cfg
*
*	  Этот механизм позволяет для каждой карты или группы карт сделать свои персональные
*	настройки. Например, многие "мясные" карты удобнее играть при mp_freezetime 0, а для
*	карт с заложниками время раунда стоит увеличивать по сравнению с картами, где
*	используется закладка мины (mp_roundtime с 1.45 до 2.5 минут). Такой механизм в
*	принципе появился в Amx Mod X v1.8.x, но в данном случае default.cfg используется для
*	восстановления всех измененных переменных в исходное значение, чего собственно
*	стандартными средствами Amx Mod X не реализовано.
*
*	This file is part of UFPS.Team Plugins
*/

#include <amxmodx>
#include <amxmisc>

#define PLUGIN_NAME "UFPS Map Config"
#define PLUGIN_VERSION "1.2"
#define PLUGIN_AUTHOR "UFPS.Team"

public plugin_init ( )
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)

	new g_configsdir[64], mapconfig[128]
	get_configsdir ( g_configsdir, sizeof ( g_configsdir ) - 1 )

	format ( mapconfig, sizeof ( mapconfig ) - 1, "%s/umm/maps/default.cfg", g_configsdir )

	if ( file_exists ( mapconfig ) )
		server_cmd ( "exec %s", mapconfig )

	get_mapname ( mapconfig, sizeof ( mapconfig ) - 1 )
	
	if ( containi ( mapconfig, "_" ) )
	{
		new	prefix[64]
	
		copy ( prefix, containi ( mapconfig, "_" ) , mapconfig )
		format ( prefix, sizeof ( prefix ) - 1, "%s/umm/maps/default_%s.cfg", g_configsdir, prefix )
	
		if ( file_exists ( prefix ) )
			server_cmd ( "exec %s", prefix )
	}

	format ( mapconfig, sizeof ( mapconfig ) - 1, "%s/umm/maps/%s.cfg", g_configsdir, mapconfig )
	
	if ( file_exists ( mapconfig ) )
		server_cmd ( "exec %s", mapconfig )
}
