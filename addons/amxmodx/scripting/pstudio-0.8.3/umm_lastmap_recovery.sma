/* AMX Mod X
*
*	UFPS Lastmap Recovery
*
*	 Этот плагин является аддоном для UFPS Map Manager
*	и позволяет сменить карту на сервере на последнюю игравшуюся
*	во время остановки сервера в результате сбоя или ручной остановки
*
*	This file is part of UFPS.Team Plugins
*/

#include <amxmodx>
#include <amxmisc>

#define PLUGIN_NAME			"UFPS Lastmap Recovery"
#define PLUGIN_VERSION		"1.0"
#define PLUGIN_AUTHOR		"UFPS.Team"

public plugin_init ( )
{
	register_plugin ( PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR )
	new pcv_first_start	= register_cvar ( "umm_first_start", "1", FCVAR_SERVER | FCVAR_EXTDLL | FCVAR_UNLOGGED | FCVAR_SPONLY )
	
	if ( get_pcvar_num ( pcv_first_start ) )
	{
		set_pcvar_num ( pcv_first_start, 0 )

		if ( !change_to_lastmap() )
			pause ( "ad", PLUGIN_NAME )
	}

	else
		pause ( "ad", PLUGIN_NAME )
}

public change_to_lastmap ( )
{
	new configsdir[128], filename[128]

	get_configsdir ( configsdir, sizeof ( configsdir ) - 1 )
	format ( filename, sizeof ( filename ) - 1, "%s/umm/maplast.ini", configsdir )

	new last_mapname[32], string[32], pos, len

	if ( file_exists ( filename ) )
	{
		while ( read_file ( filename, pos++, string, sizeof ( string ) - 1, len ) )
		{
			if ( ( string[0] != ';' ) && parse ( string, last_mapname, sizeof ( last_mapname ) - 1 ) && is_map_valid ( last_mapname ) )
			{
				set_task ( 1.0, "task_delayed_mapchange", 0, last_mapname, sizeof ( last_mapname ) )

				log_amx ( "Detected first start. Recovery map to last ^"%s^"", last_mapname )

				return true
			}
		}
	}

	else
		log_amx ( "File ^"%s^" not found.", filename )

	return false
}

public task_delayed_mapchange ( param[] )
{
	server_cmd ( "changelevel %s", param )

	return PLUGIN_CONTINUE
}
