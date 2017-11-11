/* AMX Mod X
*
*	UFPS MOTD Notification
*
*	 Этот плагин является аддоном для UFPS Map Manager
*	и позволяет создавать нотификации и say-команды для вызова заданных MOTD окон
*
*	Плагин выполнен на основе плагина:	"Custom MOTD Commands", "1.0", "Zenith77"
*
*
*	Команды:
*		umm_add_motd <command> <filename or link> <MOTD title> <access>	- Задает команду вывода MOTD, путь к MOTD-файлу, заголовок MOTD, и уровень доступа
*		umm_add_notification <string> <time>	- Задает строку нотификации и период вывода её в чат в секундах
*
*	Переменные:
*		umm_notification		(default - 1)	- Включает/отключает вывод нотификаций в чат
*
*	This file is part of UFPS.Team Plugins
*/

#include <amxmodx>
#include <amxmisc>

#define PLUGIN	"UFPS MOTD Notification"
#define VERSION	"1.0"
#define AUTHOR	"UFPS.Team"

#define AUTO_LANG		-76
#define MAX_MOTDS 		 32
#define MAX_NTF			 64

#define MAX_COMMAND		 32
#define MAX_SOURCE		 128
#define MAX_TITLE		 64
#define MAX_ACCESS 		 26
#define MAX_STRING		 256


new g_msgSayText
new g_configsdir[64]

new pcv_notification
new pcv_colored_messages

new g_motd
new g_motd_command[MAX_MOTDS][MAX_COMMAND + 1]
new g_motd_source[MAX_MOTDS][MAX_SOURCE + 1]
new g_motd_title[MAX_MOTDS][MAX_TITLE + 1]
new g_motd_access[MAX_MOTDS]

new g_notification
new g_notification_string[MAX_NTF][MAX_STRING + 1]

public plugin_init()
{
	register_plugin ( PLUGIN, VERSION, AUTHOR )

	register_concmd ( "umm_add_notification", "cmd_add_notification", ADMIN_CFG, "<string> <time> - Create notification" )
	register_concmd ( "umm_add_motd", "cmd_add_motd", ADMIN_CHAT, "<command> <filename or http://link> <MOTD title> <access> - Create say /command for MOTD" )

	g_msgSayText			= get_user_msgid ( "SayText" )
	pcv_notification		= register_cvar ( "umm_notification", "1" )
	pcv_colored_messages	= get_cvar_pointer ( "umm_colored_messages" )

	get_configsdir ( g_configsdir, sizeof ( g_configsdir ) - 1 )
}

public cmd_add_motd ( id, level, cid )
{
	if ( !cmd_access ( id, level, cid, 5 ) )
		return PLUGIN_HANDLED

	new string[MAX_STRING + 1], command[MAX_COMMAND + 1], source[MAX_SOURCE + 1], title[MAX_TITLE + 1], access[MAX_ACCESS + 1]

	read_args ( string, sizeof ( string ) - 1 )

	if	( ( g_motd < MAX_MOTDS ) && parse ( string, command, MAX_COMMAND, source, MAX_SOURCE, title, MAX_TITLE, access, MAX_ACCESS ) && strlen ( command ) && strlen ( source ) )
	{
		copy ( g_motd_command[g_motd], MAX_COMMAND, command )

		if ( containi ( source, "http://" ) != -1 )
		{
			copy ( g_motd_source[g_motd], MAX_SOURCE, source )
		}

		else
		{
			formatex ( g_motd_source[g_motd], MAX_SOURCE, "%s/umm/motds/%s", g_configsdir, source )
		}

		g_motd_access[g_motd] = read_flags ( access )
		copy ( g_motd_title[g_motd], MAX_TITLE, strlen ( title ) ? title : command )

		formatex ( string, MAX_STRING, "say %s", command )
		register_clcmd ( string, "hook_say" )

		g_motd++
	}

	return PLUGIN_HANDLED
}

public hook_say ( id )
{
	new arg[MAX_COMMAND + 1]
	read_argv ( 1, arg, MAX_COMMAND )

	for ( new i = 0; i < g_motd; ++i )
	{
		if ( equal ( arg, g_motd_command[i] ) )
		{
			if ( g_motd_access[i] == 0 || ( get_user_flags ( id ) & g_motd_access[i] ) )
			{
				show_motd ( id, g_motd_source[i], g_motd_title[i] )
			}

			else
			{
				client_print ( id, print_chat, "You have no access to that command." )
			}

			break
		}
	}

	return PLUGIN_CONTINUE
}

public cmd_add_notification ( id, level, cid )
{
	if ( !cmd_access ( id, level, cid, 2 ) )
		return PLUGIN_HANDLED

	new string[MAX_STRING + 1], message[MAX_STRING + 1], timer[8]

	read_args ( string, sizeof ( string ) - 1 )

	if ( ( g_notification < MAX_NTF ) && parse ( string, message, MAX_STRING, timer, sizeof ( timer ) - 1 ) && strlen ( message ) && strlen ( timer ) )
	{
		new param[2]

		copy ( g_notification_string[g_notification], MAX_STRING, message )

		if ( str_to_float ( timer ) > 0.0 )
		{
			param[0] = g_notification
			set_task ( str_to_float ( timer ), "loop_messages", 0, param, 2, "b" )
			g_notification++
		}
	}

	return PLUGIN_HANDLED
}

public loop_messages ( param[] )
{
	if ( get_pcvar_num ( pcv_notification ) )
		say_message ( g_notification_string[param[0]] )
}

say_message ( msg[] )
{
	new players[32], num
	get_players ( players, num )

	new message[192]

	format ( message, sizeof ( message ) - 1, "%s", msg )
	format_color (message, sizeof ( message ) - 1, get_pcvar_num ( pcv_colored_messages ) )
	format ( message, sizeof ( message ) - 1, "^x01%s", message )

	for ( new i = 0; i < num; i++ )
	{
		if ( !is_user_connected ( players[i] ) ) continue

		message_begin ( MSG_ONE, g_msgSayText, _, players[i] )
		write_byte ( players[i] )
		write_string ( message )
		message_end ( )
	}
}

format_color ( string[], len, colored_messages )
{
	if ( colored_messages )
	{
		replace_all ( string, len, "[t]", "^x03" )
		replace_all ( string, len, "[g]", "^x04" )
		replace_all ( string, len, "[/t]", "^x01" )
		replace_all ( string, len, "[/g]", "^x01" )
	}

	else
	{
		replace_all ( string, len, "[t]", "" )
		replace_all ( string, len, "[g]", "" )
		replace_all ( string, len, "[/t]", "" )
		replace_all ( string, len, "[/g]", "" )
	}
}
