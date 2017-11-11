/* AMX Mod X
*
*	UFPS Map Manager Plugin
*
*	Особенности установки:
*
*	- размещение и структура файлов
*		/addons/amxmodx/configs/umm/mapban.ini
*		/addons/amxmodx/configs/umm/mapconfig.ini
*		/addons/amxmodx/configs/umm/maplast.ini
*		/addons/amxmodx/configs/umm/maprefix.ini
*		/addons/amxmodx/data/lang/umm.txt
*		/addons/amxmodx/plugins/umm.amxx
*
*	- рекомендуется остановить следующие стандартные плагины,
*	  если они не остановлены, плагин их остановит сам, т.к. работа этих плагинов эмулируется:
*		nextmap.amxx
*		timeleft.amxx
*		mapchooser.amxx
*
*	- рекомендуется останавливать другие менеджеры карт, такие как:
*		Deagles' Map Management
*		Galileo
*		Lastround
*
*	- структура файла mapconfig.ini
*		-----------------------------------------------------------------
*		 Mapname			Rating		Min		Max		Week
*							[1-5]		[0-32]	[1-32]	[SuMoTuWeThFrSa]
*		-----------------------------------------------------------------
*		Mapname	- имя карты (de_dust2)
*		Rating	- рейтинг карты (от 1 до 5) частота появления этой карты в списке голосования
*		Min		- минимальное число игроков, при котором карта выставляется на голосование
*		Max		- максимальное число игроков, при котором карта выставляется на голосование
*		Week	- дни недели, по которым должна работать эта карта (SuMoTuWeThFrSa)
*
*	- Если список карт, выставляемый на голосование, по каким либо причинам оказывается пустым -
*	  сработает стандартный механизм смены карты, для этого необходим файл:
*		mapcycle.txt
*
*
*	Команды:
*
*	umm_info				- Информация о плагине
*	umm_votemap				- Досрочное голосование (ADMIN_MAP)
*	amx_banmap <mapname>	- Забанить карту (ADMIN_MAP)
*	amx_unbanmap <mapname>	- Разбанить карту (ADMIN_MAP)
*	say <mapname>			- Номинировать карту в голосование
*	say /rtv			- Проголосовать за досрочную смену карты
*	say /rr					- Проголосовать за рестарт карты (addon UFPS Auto Restart)
*
*	maplist [N] | [-n] [-l] [-b]	- Вывести список карт в консоль:
*			 N - начиная с карты под номером N
*			-n - список номинированных карт
*			-l - список последних сыгранных карт
*			-b - список забаненных карт (ADMIN_MAP)
*
*
*	Эмуляция стандартных команд:
*
*	say ff					- Состояние Friendly Fire: ON|OFF
*	say timeleft			- Остаток времени до окончания текущей карты
*	say thetime				- Текущее время
*	say map			- Текущая карта
*
*
*	Переменные:
*
*	umm_version						(read only)		- Показывает версию плагина
*	umm_restrict_maplist			(default - 1)	- Ограничивает выбор карт списком из mapconfig.ini с ограничением по текущему количеству игроков и дням недели
*	umm_admin_level					(default - b)	- Флаг админов, для которых резервируются слоты на номинацию карт (users.ini)
*	umm_admin_nominate				(default - 0)	- Количество резервных слотов (из umm_users_nominate) для номинации карт администраторами с umm_admin_level
*	umm_admin_voteweight			(default - 1)	- Вес голоса администратора в голосованиях
*	umm_users_nominate				(default - 2)	- Максимальное число карт предложенных игроками
*	umm_timeout_nominate			(default - 0)	- Таймаут на досрочное голосование пользователями в минутах
*	umm_lastmaps					(default - 4)	- Количество последних сыгранных карт, которые не будут предлагаться для голосования
*	umm_votemaps					(default - 4)	- Количество карт для голосования
*	umm_voteratio					(default - 0.6)	- Процент игроков для досрочного голосования
*	umm_lastminute					(default - 0)	- Включает смену карты при включенном тайм лимите на последних секундах (для CSDM, eXtreme Jump и т.д.)
*	umm_screenfade					(default - 1)	- Включает затемнение экрана на время голосования
*	umm_colored_messages			(default - 1)	- Включает вывод цветных сообщений ([g]GREEN_COLOR[/g], [t]TEAM_COLOR[/t])
*	umm_extend_timelimit_max		(default - 40)	- Общий лимит времени на одной карте в минутах
*	umm_extend_timelimit_step		(default - 15)	- Шаг добавочного времени на карту
*	umm_extend_maxrounds_max		(default - 30)	- Общий лимит раундов на одной карте
*	umm_extend_maxrounds_step		(default - 10)	- Шаг добавочных раундов на карту
*
*
*
*	This file is part of UFPS.Team Plugins
*
*
*	Изменения по версиям:
*
*	Ver 3.0.3
*		- Изменен словарь на версию 3.0.3
*		- Небольшая оптимизация
*		- Улучшена мультиязычность плагина
*		- Команда maplist дополнена новыми функциями:
*			- фильтрация списков: номинированных, последних сыгранных, забаненных карт;
*			- при повторном наборе без параметров продолжает вывод списка карт с последней выводившейся;
*		- Добавлены say_team аналоги всех say команд
*		- Консольная команда HL1 listmaps подменяется на maplist
*		- Консольная команда HL1 votemap преобразовывается в say /votemap
*		- Добавлена возможность вывода цветных сообщений и переменная umm_colored_messages для их включения/отключения
*		- Добавлены переменные umm_extend_maxrounds_max и umm_extend_maxrounds_step для возможности продления карты в режиме maxrounds
*		- Переменные amx_extendmap_max и amx_extendmap_step переименованы в umm_extend_timelimit_max и umm_extend_timelimit_step соответственно
*		- Исправлена ошибка размерности g_votemap_idplayer, что вызывало ошибки при 32 игроках на сервере
*		- Аддон UFPS Auto Restart v3.8:
*			- Исправлена ошибка размерности g_arr_voteplayer, что вызывало ошибки при 32 игроках на сервере
*		- Добавлен аддон UFPS MOTD Notification v1.0 для создания say-команд вызова MOTD и вывода в чат нотификаций.
*			- Команды:
*				- umm_add_motd <command> <filename or link> <MOTD title> <access> - Задает команду вывода MOTD, путь к MOTD-файлу, заголовок MOTD, и уровень доступа
*				- umm_add_notification <string> <time> - Задает строку нотификации и период вывода её в чат в секундах
*			- Переменные:
*				- umm_notification		(default - 1)	- Включает/отключает вывод нотификаций в чат
*		- Добавлен аддон UFPS Anti Blocker v1.0, который осуществляет возможность проходимости игроков друг сквозь друга в начале раунда
*			- Переменные:
*				- umm_antiblock			(default - 1)	- Включает/отключает использование плагина
*				- umm_antiblock_time	(default - 5)	- Время в секундах в течении которого игроки могут проходить друг сквозь друга
*
*	Ver 3.0.2
*		- Изменен словарь на версию 3.0.2
*		- Добавлена детализация логов
*		- Добавлен файл префиксов /addons/amxmodx/configs/umm/maprefix.ini для автоматического определения карт в команде say <mapname>
*		- Добавлено оповещение [LAST WIN CT/T] в режиме mp_winlimit > 0
*		- Изменена логика смены карты при mp_winlimit, mp_maxrounds и mp_timelimit > 0
*		- Аддон UFPS Auto Restart v3.7:
*			- Добавлена возможность голосования за рестарт say /rr
*			- Добавлена переменная umm_autorestart_hud для включения/отключения вывода HUD сообщений авторестарта
*			- Добавлена переменная umm_autorestart_voteratio для определения процента игроков при голосовании за рестарт карты
*
*	Ver 3.0.1
*		- Изменен словарь на версию 3.0.1
*		- При невозможности начать голосование карты берутся из mapcofig и только если выборка прошла неудачно из mapcycle.txt
*		- Путь к файлу mapcycle.txt определяется переменной mapcyclefile
*		- Добавлена переменная umm_admin_voteweight, для изменения веса голоса администратора в голосованиях: say /votemap и голосовании смены карты
*
*	Ver 3.0.0
*		- Изменен словарь на версию 3.0.0
*		- Реструктуризация каталогов с настройками, названий плагинов и словарей
*		- Добавлено использование настроек из umm.cfg вместо server.cfg и amxx.cfg
*		- Авто рестарты и конфигурации карт вынесены из плагина как аддоны
*		- amx_show_activity влияет на показ сообщений от имени администраторов
*		- Добавлен перехват и блокировка команды движка HL1: votemap
*		- При действующем таймауте на досрочное голосование команда say /votemap не отображается в чате другим игрокам
*
*	Ver 2.9.2
*		- Изменен словарь на версию 2.9.2
*		- Добавлено отображение времени оставшегося до разрешения досрочного голосования
*
*	Ver 2.9.1
*		- Изменен словарь на версию 2.9.1
*		- Исправлен расчет процента номинаций
*		- Добавлены ограничения на двойной запуск досрочного голосования администраторами и пользователями
*		- Добавлено логирование запуска досрочного голосования администраторами и пользователями
*		- Добавлена переменная umm_timeout_nominate для таймаута на досрочное голосование пользователями в минутах
*
*	Ver 2.9.0
*		- Исправление мелких недочетов с меню выбора карт, выводом списка карт в maplist
*
*	Ver 2.8.9
*		- Изменен словарь на версию 2.8.9
*		- Добавлена переменная umm_notification для включения/отключения уведомлений об используемых пользовательских командах
*		- Добавлена команда для запуска досрочного голосования админом: umm_votemap (ADMIN_MAP)
*		- Исправления ошибка запуска досрочного голосования в режиме umm_lastminute 1
*		- Список карт в maplist теперь выводится по 50 на страницу начиная с указанной для предотвращения у клиента Channel overflowed
*
*	Ver 2.8.8
*		- Добавлено изменение sv_maxspeed на 0 для случаев с umm_lastminute
*		- Добавлено в maplist отображение ограничений по числу играющих при umm_restrict_maplist 1 и убрано для umm_restrict_maplist 0
*		- Исправлено формирование списка maplist при umm_restrict_maplist 0 до полного списка из mapconfig.cfg
*		- Исправлен баг New Menu (неверная обработка неполного списка карт)
*
*	Ver 2.8.7
*		- Изменены названия переменных
*		- Изменен словарь на версию 2.8.7
*		- Добавлена переменная для возможности отключения темного экрана umm_screenfade
*		- Добавлена переменная для возможности смены карты в последние 30 сек раунда umm_lastminute
*		- Добавлена возможность смены карты на последних секундах (для CSDM, eXtreme Jump и т.д.)
*
*	Ver 2.8.6
*		- Изменен словарь на версию 2.8.6
*		- Добавлена команда вывода в консоль списка доступных для голосования карт maplist
*		- Убрана команда say /maplist
*
*	Ver 2.8.5
*		- Исправлен баг New Menu (неверное построение списка)
*
*	Ver 2.8.4
*		- Оптимизировано под New Menu
*
*	Ver 2.8.3
*		- Команда say /maplist реализована в motd
*		- Изменен словарь на версию 2.8.3
*
*	Ver 2.8.2
*		- Перевод плагина на PCVAR, общая оптимизация
*		- Изменен словарь на версию 2.8.2
*
*	Ver 2.8.1
*		- Добавлена возможность ограничения выбора карты списком из mapconfig.ini (umm_restrict_maplist)
*		- Добавлена команда say /maplist
*		- Добавлена команда say ff из заменяемого модуля nextmap
*		- Добавлена команда say currentmap из заменяемого модуля nextmap
*		- Изменен словарь на версию 2.8.1
*
*	Ver 2.8.0
*		- Оптимизация длин переменных, структуры кода, замена старых функций новыми.
*
*	Ver 2.7.9
*		- Исправление мелких недочетов, косметика
*		- Изменен словарь на версию 2.8.0
*
*	Ver 2.7.8
*		- Период вывода сообщений-подсказок увеличен с 5 до 10 минут
*		- Вывод информации об используемой версии словаря
*
*	Ver 2.7.7
*		- Оптимизация и исправление мелких недочетов
*
*	Ver 2.7.4
*		- При номинации карты админом используется amx_show_activity
*		- Меню выбора карты принудительно выводится тем, кто не проголосовал
*		- Исправлен баг в привязке к hostname сервера
*		- umm_autorestart (0 - default)
*
*	Ver 2.7.3
*		- Добавлена переменная umm_admin_nominate
*		- Добавлена переменная umm_admin_level
*		- Изменен словарь на версию 2.7.3
*		- Привязка к hostname сервера
*
*	Ver 2.7.2
*		- Добавлена переменная umm_version
*		- Добавлена команда umm_info
*
*	Ver 2.7.1
*		- Исправлен баг обновляющий отсчет времени при авто рестарте карты
*
*	Ver 2.7
*		- Добавлена возможность авто рестарта карты (через время, после первого раунда)
*		- Добавлена возможность выполнения для каждой карты: общей, префиксной, и именной конфигурации
*		(в стандартном AmxModX 1.8.x выполняется только префиксная и именная конфигурации)
*
*	Ver 2.6
*		- Добавлена возможность выбора карт по дням недели
*
*/

//#define TEST_MODE

#include <amxmodx>
#include <amxmisc>

#define PLUGIN_NAME			"UFPS Map Manager"
#define PLUGIN_VERSION		"3.0.3(z)"
#define PLUGIN_AUTHOR		"UFPS.Team"

#define LOG_ON			1
#define LOG_OFF			0
#define MAX_MAPS		1024
#define MAX_PREFIX		32
#define LEN_PREFIX		16
#define LAST_MAPS		128
#define BAN_MAPS		128
#define LEN_MAPNAME		31
#define MAX_SELECT		8
#define LAST_MINUTE		60
#define VOTE_TIME		25
#define MAPS_PERPAGE	50
#define AUTO_LANG		-76

#define TASK_ID_VOTE_TIMER		8851
#define TASK_ID_LAST_ROUND		8852


new g_menuID
new g_colored
new g_configsdir[64]

new g_timer
new g_round = 1
new g_teamScore[2]
new Float: g_addtime
new Float: g_maptimer

new g_msgSayText
new g_msgScrenFade
new g_hudSyncChannel_3
new g_hudSyncChannel_4
new g_hudSyncChannel_5

new bool:g_nominate_print = false
new bool:g_mapvoteprogress = false

new bool:g_votemap_full = false
new bool:g_votemap_idplayer[33]

new g_maplist_lastidx[33]

new g_prefix_count
new g_prefix_name[MAX_PREFIX][LEN_PREFIX + 1]

new g_rating_idcount
new g_rating_idplayer[32]

new g_last_mapcount
new g_last_mapname[LAST_MAPS][LEN_MAPNAME + 1]

new g_ban_mapcount
new g_ban_mapname[BAN_MAPS][LEN_MAPNAME + 1]

new g_vote_mapcount
new g_vote_mapname[MAX_MAPS][LEN_MAPNAME + 1]

new g_idx_mapcount
new g_idx_mapname[MAX_MAPS * 5]

new g_custom_mapmax
new g_custom_mapcount
new g_custom_reserved
new g_custom_userid[MAX_SELECT]
new g_custom_mapname[MAX_SELECT][LEN_MAPNAME + 1]

new g_select_mapmax
new g_select_mapcount
new g_select_mapname[MAX_SELECT][LEN_MAPNAME + 1]
new g_select_mapvotecheck[MAX_SELECT]

new g_list_mapcount
new g_list_min_players[MAX_MAPS]
new g_list_max_players[MAX_MAPS]
new g_list_mapname[MAX_MAPS][LEN_MAPNAME + 1]

new pcv_lastmaps
new pcv_voteratio
new pcv_lastminute
new pcv_screenfade
new pcv_admin_level
new pcv_timeout_nominate
new pcv_admin_voteweight
new pcv_restrict_maplist
new pcv_colored_messages

new pcv_extend_timelimit_max
new pcv_extend_timelimit_step
new pcv_extend_maxrounds_max
new pcv_extend_maxrounds_step

new pcv_amx_nextmap
new pcv_amx_timeleft
new pcv_amx_show_activity

new pcv_sv_maxspeed
new pcv_mp_chattime
new pcv_mp_winlimit
new pcv_mp_maxrounds
new pcv_mp_timelimit
new pcv_mp_roundtime
new pcv_mp_freezetime
new pcv_mp_c4timer
new pcv_mp_friendlyfire

new g_maxspeed
new g_winlimit
new g_maxrounds
new g_freezetime
new Float:g_timelimit

new bool:g_maxspeedRepare	= false
new bool:g_winlimitRepare	= false
new bool:g_maxroundsRepare	= false
new bool:g_timelimitRepare	= false
new bool:g_freezetimeRepare	= false

public plugin_init()
{
	register_plugin( PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR )
	register_dictionary("umm.txt")

	g_colored = colored_menus()

	g_msgSayText	= get_user_msgid( "SayText" )
	g_msgScrenFade	= get_user_msgid( "ScreenFade" )

	g_hudSyncChannel_3 = CreateHudSyncObj ( )
	g_hudSyncChannel_4 = CreateHudSyncObj ( )
	g_hudSyncChannel_5 = CreateHudSyncObj ( )

	get_configsdir ( g_configsdir, sizeof ( g_configsdir ) - 1 )

	server_cmd ( "exec %s/umm.cfg", g_configsdir )

	register_cvar ( "umm_version", PLUGIN_VERSION, FCVAR_SERVER | FCVAR_SPONLY )

	new pcv_admin_nominate	= register_cvar ( "umm_admin_nominate",			"0" )
	new pcv_users_nominate	= register_cvar ( "umm_users_nominate",			"2" )
	new pcv_votemaps		= register_cvar ( "umm_votemaps",				"4" )

	pcv_lastmaps			= register_cvar ( "umm_lastmaps",				"4" )
	pcv_voteratio			= register_cvar ( "umm_voteratio",				"0.6" )
	pcv_lastminute			= register_cvar ( "umm_lastminute",				"0" )
	pcv_screenfade			= register_cvar ( "umm_screenfade",				"1" )
	pcv_admin_level			= register_cvar ( "umm_admin_level",			"b" )
	pcv_admin_voteweight	= register_cvar ( "umm_admin_voteweight",		"1" )
	pcv_restrict_maplist	= register_cvar ( "umm_restrict_maplist",		"1" )
	pcv_timeout_nominate	= register_cvar ( "umm_timeout_nominate",		"0" )
	pcv_colored_messages	= register_cvar ( "umm_colored_messages",		"1" )

	new	pcv_amx_extendmap_max	= register_cvar ( "amx_extendmap_max",			"40" )
	new	pcv_amx_extendmap_step	= register_cvar ( "amx_extendmap_step",			"15" )

	pcv_extend_timelimit_max	= register_cvar ( "umm_extend_timelimit_max",	"40" )
	pcv_extend_timelimit_step	= register_cvar ( "umm_extend_timelimit_step",	"15" )
	pcv_extend_maxrounds_max	= register_cvar ( "umm_extend_maxrounds_max",	"30" )
	pcv_extend_maxrounds_step	= register_cvar ( "umm_extend_maxrounds_step",	"10" )

	pcv_amx_nextmap			= register_cvar ( "amx_nextmap",				"", 		FCVAR_SERVER | FCVAR_EXTDLL | FCVAR_SPONLY )
	pcv_amx_timeleft		= register_cvar ( "amx_timeleft",				"00:00",	FCVAR_SERVER | FCVAR_EXTDLL | FCVAR_UNLOGGED | FCVAR_SPONLY )

	register_concmd ( "amx_banmap",			"cmd_amx_banmap",	ADMIN_MAP, "<map> - Include map to banlist" )
	register_concmd ( "amx_unbanmap",		"cmd_amx_unbanmap",	ADMIN_MAP, "<map> - Exclude map trom banlist" )
	register_concmd ( "umm_votemap",		"cmd_umm_votemap",	ADMIN_MAP, "- Starting vote for map change" )

	register_clcmd ( "say",					"hook_say_mapname",		0, "<map> - nominate map for voting" )
	register_clcmd ( "say_team",			"hook_say_mapname",		0, "<map> - nominate map for voting" )
	register_clcmd ( "votemap",				"cmd_block_votemap",	0, "- blocked command" )
	register_clcmd ( "maps",			"cmd_maplist",			0, "N - console maplist (default: 50 maps per page)" )
	register_clcmd ( "umm_info",			"cmd_check_version",	ADMIN_MAP, "- check version" )
	register_clcmd ( "say ff", 				"cmd_say_ffstatus", 	0, "- display friendly fire status" )
	register_clcmd ( "say_team ff", 		"cmd_say_ffstatus", 	0, "- display friendly fire status" )
	register_clcmd ( "say rtv",			"cmd_say_votemap",		0, "- vote map change" )
	register_clcmd ( "say /rtv",		"cmd_say_votemap",		0, "- vote map change" )
	register_clcmd ( "say_team rtv",	"cmd_say_votemap",		0, "- vote map change" )
	register_clcmd ( "say_team /rtv",	"cmd_say_votemap",		0, "- vote map change" )
	register_clcmd ( "say timeleft",		"cmd_say_timeleft",		0, "- displays timeleft" )
	register_clcmd ( "say_team timeleft",	"cmd_say_timeleft",		0, "- displays timeleft" )
	register_clcmd ( "say thetime",			"cmd_say_thetime",		0, "- displays current time" )
	register_clcmd ( "say_team thetime",	"cmd_say_thetime",		0, "- displays current time" )
	register_clcmd ( "say map",		"cmd_say_currentmap",	0, "- display current map" )
	register_clcmd ( "say_team map",	"cmd_say_currentmap",	0, "- display current map" )

	register_event ( "30",			"event_map_change",		"a" )
	register_event ( "TeamScore",	"event_team_score",		"a" )
	register_event ( "TextMsg",		"event_restart_game",	"a", "2=#Game_Commencing",	"2=#Game_will_restart_in" )
	register_event ( "SendAudio",	"event_end_round",		"a", "2=%!MRAD_terwin",		"2=%!MRAD_ctwin", "2=%!MRAD_rounddraw" )

	g_select_mapmax		= clamp( get_pcvar_num ( pcv_votemaps ), 1, MAX_SELECT - 1)
	g_custom_mapmax		= ( get_pcvar_num ( pcv_users_nominate ) > g_select_mapmax ) ? g_select_mapmax : get_pcvar_num ( pcv_users_nominate )
	g_custom_reserved	= ( get_pcvar_num ( pcv_admin_nominate ) > g_custom_mapmax ) ? g_custom_mapmax : get_pcvar_num ( pcv_admin_nominate )

	pcv_sv_maxspeed			= get_cvar_pointer ( "sv_maxspeed" )
	pcv_mp_chattime			= get_cvar_pointer ( "mp_chattime" )
	pcv_mp_winlimit			= get_cvar_pointer ( "mp_winlimit" )
	pcv_mp_maxrounds		= get_cvar_pointer ( "mp_maxrounds" )
	pcv_mp_timelimit		= get_cvar_pointer ( "mp_timelimit" )
	pcv_mp_roundtime		= get_cvar_pointer ( "mp_roundtime" )
	pcv_mp_freezetime		= get_cvar_pointer ( "mp_freezetime" )
	pcv_mp_c4timer			= get_cvar_pointer ( "mp_c4timer" )
	pcv_mp_friendlyfire		= get_cvar_pointer ( "mp_friendlyfire" )
	pcv_amx_show_activity	= get_cvar_pointer ( "amx_show_activity" )

	set_pcvar_num ( pcv_mp_chattime, check_cvar_num ( get_pcvar_num ( pcv_mp_chattime ), 3, 30 ) )
	set_pcvar_float ( pcv_amx_extendmap_max, get_pcvar_float ( pcv_amx_extendmap_max ) )
	set_pcvar_float ( pcv_amx_extendmap_step, get_pcvar_float ( pcv_extend_timelimit_step ) )
}

public plugin_cfg ( )
{
	check_restrict_plugins()
	set_task ( 1.0, "task_clear_votemap" )
	set_task ( 1.0, "task_time_remaining" )
	set_task ( 1.1, "cmd_get_prefix" )
	set_task ( 1.2, "cmd_get_lastmaps" )
	set_task ( 1.3, "cmd_put_lastmaps" )
	set_task ( 1.4, "cmd_get_banmaps" )
	set_task ( 1.5, "task_mapcycle" )
	set_task ( 15.0, "task_last_round", TASK_ID_LAST_ROUND, _, _, "b" )
	set_cvar_float ( "sv_restart", 1.0 )
}

public cmd_check_version ( id )
{
	console_print ( id, "%s v%s", PLUGIN_NAME, PLUGIN_VERSION )
	console_print ( id, "Dictionary v%L", "xx", "VERSION" )

	return PLUGIN_HANDLED
}

public check_vote_start ( )
{
	if ( g_mapvoteprogress ) return

	if ( !g_votemap_full )
	{
		new winlimit	= get_pcvar_num ( pcv_mp_winlimit )
		new maxrounds	= get_pcvar_num ( pcv_mp_maxrounds )
		new timelimit	= floatround ( get_pcvar_float ( pcv_mp_timelimit ) * 60 )

		if ( winlimit )
		{
			winlimit--

			if ( ( winlimit > g_teamScore[0] ) && ( winlimit > g_teamScore[1] ) ) return

			if ( !g_winlimitRepare )
			{
				g_winlimit = get_pcvar_num ( pcv_mp_winlimit )
				set_pcvar_num ( pcv_mp_winlimit, g_winlimit + 1 )
				g_winlimitRepare = true

				return
			}
		}

		else if ( maxrounds )
		{
			if ( maxrounds >= g_round ) return

			if ( !g_maxroundsRepare )
			{
				g_maxrounds = maxrounds
				g_maxroundsRepare = true
			}

			set_pcvar_num ( pcv_mp_maxrounds, maxrounds + 1 )
		}

		else if ( timelimit && get_pcvar_num ( pcv_lastminute ) )
		{
			new timeleft = get_timeleft()
			new roundtime = get_pcvar_num ( pcv_mp_chattime ) + VOTE_TIME

			if ( timeleft < 1 || timeleft > roundtime ) return
		}

		else return
	}

	g_votemap_full = false
	g_mapvoteprogress = true

	if ( cmd_get_selectmap() )
	{
		new fade[2]
		g_timer = 3
		fade[0] = 2; set_task ( 6.0, "cmd_screen_fade", 0, fade, 2 )
		fade[0] = 1; set_task ( 7.0, "cmd_screen_fade", 0, fade, 2 )

		if ( !get_pcvar_num ( pcv_lastminute ) )
		{
			if ( !g_freezetimeRepare )
			{
				g_freezetime = get_pcvar_num ( pcv_mp_freezetime )
				g_freezetimeRepare = true
			}

			set_pcvar_num ( pcv_mp_freezetime, 20 )
		}

		set_task ( 6.0, "clients_freeze" )
		set_task ( 6.0, "task_timetochoose" )
	}
}

public task_last_round ( )
{
	if ( get_pcvar_float ( pcv_timeout_nominate ) && !g_nominate_print && !check_disable_nominate() )
	{
		g_nominate_print = true
		say_message ( 0, LOG_ON, "%L", AUTO_LANG, "CL_VOTE_MAP_CHANGE_ENABLE" )
	}

	if ( g_mapvoteprogress ) return

	if ( !g_votemap_full )
	{
		new winlimit	= get_pcvar_num ( pcv_mp_winlimit )
		new maxrounds	= get_pcvar_num ( pcv_mp_maxrounds )
		new timelimit	= floatround ( get_pcvar_float ( pcv_mp_timelimit ) * 60 )

		if ( winlimit )
		{
			if ( !g_winlimitRepare ) return
		}

		else if ( maxrounds )
		{
			 if ( maxrounds > g_round ) return
		}

		else if ( timelimit && get_pcvar_num ( pcv_lastminute ) )
		{
			new timeleft	= get_timeleft()
			new roundtime	= get_pcvar_num ( pcv_mp_chattime ) + LAST_MINUTE

			if ( timeleft < 1 || timeleft > roundtime ) return
		}

		else return
	}

	if ( g_winlimitRepare )
	{
		new team[16]

		if ( g_teamScore[0] > g_teamScore[1] )
		{
			copy ( team, sizeof ( team ) - 1, "CT" )
		}

		else if ( g_teamScore[0] < g_teamScore[1] )
		{
			copy ( team, sizeof ( team ) - 1, "T" )
		}

		else
		{
			copy ( team, sizeof ( team ) - 1, "CT/T" )
		}

		say_hudmessage ( 0, 127, 127, 127, 0.02, 0.21, 0, 5.0, 15.04, 0.0, 0.5, 3, "%L %s", AUTO_LANG, "SH_LAST_WIN", team )
	}

	else if ( get_pcvar_num ( pcv_lastminute ) )
	{
		say_hudmessage ( 0, 127, 127, 127, 0.02, 0.21, 0, 5.0, 15.04, 0.0, 0.5, 3, "%L", AUTO_LANG, "SH_LAST_MINUTE" )
	}

	else
	{
		say_hudmessage ( 0, 127, 127, 127, 0.02, 0.21, 0, 5.0, 15.04, 0.0, 0.5, 3, "%L", AUTO_LANG, "SH_LAST_ROUND" )
	}
}

public menu_handle ( id, menu, item )
{
	if ( menu != g_menuID || item < 0 || item > g_select_mapmax )
		return PLUGIN_HANDLED

	new cmd[3], access, callback
	menu_item_getinfo ( menu, item, access, cmd, sizeof ( cmd ) - 1, _, _, callback )
	item = str_to_num ( cmd )

	if ( get_pcvar_float ( pcv_voteratio ) )
	{
		new name[32]
		get_user_name ( id, name, sizeof ( name ) - 1 )

		if ( item == g_select_mapmax )
		{
			say_message ( 0, LOG_ON, "%L", AUTO_LANG, "CL_VOTE_MAP_EXTENDING", name )
		}

		else if ( item < g_select_mapmax )
		{
			say_message ( 0, LOG_ON, "%L", AUTO_LANG, "CL_VOTE_MAP", name, g_select_mapname[item] )
		}
	}

	g_rating_idplayer[g_rating_idcount] = id
	g_rating_idcount++

	if ( get_user_flags ( id ) & ( get_admin_level_flag() | ADMIN_MAP ) )
	{
		g_select_mapvotecheck[item] += get_pcvar_num ( pcv_admin_voteweight )
	}

	else
	{
		g_select_mapvotecheck[item]++
	}

	cmd_print_rating()

	return PLUGIN_HANDLED
}

public check_vote_end ( )
{
	if ( task_exists ( TASK_ID_VOTE_TIMER ) )
	{
		remove_task ( TASK_ID_VOTE_TIMER )
	}

	menu_clients_print ( 0 )

	new idx = 0

	for ( new i = 0; i < g_select_mapcount; ++i )
	{
		if ( g_select_mapvotecheck[idx] < g_select_mapvotecheck[i] )
		{
			idx = i
		}
	}

	if ( g_select_mapvotecheck[g_select_mapmax] > g_select_mapvotecheck[idx] )
	{
		new mapname[32]

		get_mapname ( mapname, sizeof ( mapname ) - 1 )
		g_custom_mapcount = 0
		task_clear_votemap()

		new maxrounds = get_pcvar_num ( pcv_mp_maxrounds )

		if ( maxrounds )
		{
			new steprounds = get_pcvar_num ( pcv_extend_maxrounds_step )

			if ( !g_maxroundsRepare )
			{
				g_maxrounds = get_pcvar_num ( pcv_mp_maxrounds )
				g_maxroundsRepare = true
			}

			set_pcvar_num ( pcv_mp_maxrounds, maxrounds + steprounds - 1 )
			say_message ( 0, LOG_ON, "%L", AUTO_LANG, "CL_MAP_EXTENDED_ROUNDS", mapname, steprounds )
			say_hudmessage ( 0, 220, 160, 0, -1.0, 0.2, 0, 0.0, 2.0, 0.0, 1.0, 3, "%L", AUTO_LANG, "SH_MAP_EXTENDED_ROUNDS", mapname, steprounds )
		}

		else
		{
			new Float: steptime = get_pcvar_float ( pcv_extend_timelimit_step )

			if ( !g_timelimitRepare )
			{
				g_timelimit = get_pcvar_float ( pcv_mp_timelimit )
				g_timelimitRepare = true
			}

			set_pcvar_float ( pcv_mp_timelimit, get_pcvar_float ( pcv_mp_timelimit ) + steptime - g_addtime )
			say_message ( 0, LOG_ON, "%L", AUTO_LANG, "CL_MAP_EXTENDED_TIME", mapname, steptime )
			say_hudmessage ( 0, 220, 160, 0, -1.0, 0.2, 0, 0.0, 2.0, 0.0, 1.0, 3, "%L", AUTO_LANG, "SH_MAP_EXTENDED_TIME", mapname, steptime )
			client_cmd ( 0 ,"spk sound/server_2/repeat")
		}

		set_pcvar_num ( pcv_sv_maxspeed, g_maxspeed )
		g_mapvoteprogress = false
	}

	else
	{
		set_pcvar_string ( pcv_amx_nextmap, g_select_mapname[idx] )
		say_message ( 0, LOG_ON, "%L", AUTO_LANG, "CL_NEXT_MAP", g_select_mapname[idx] )
		say_hudmessage ( 0, 220, 160, 0, -1.0, 0.2, 0, 0.0, 2.0, 0.0, 1.0, 3, "%L", AUTO_LANG, "SH_NEXT_MAP", g_select_mapname[idx] )
		set_task ( 3.0, "event_map_end" )
		client_cmd ( 0 ,"spk sound/server_2/vote_end")
	}

	new fade[2]
	fade[0] = 0; set_task ( 2.0, "cmd_screen_fade", 0, fade, 2 )
	g_addtime = 0.0
	set_pcvar_num ( pcv_mp_freezetime, g_freezetime )
	return PLUGIN_CONTINUE
}

public task_timetochoose ( )
{
	if ( g_timer > 0 )
	{
		say_hudmessage ( 0, 220, 160, 0, -1.0, 0.1, 0, 0.0, 1.03, 0.0, 0.0, 4, "%L", AUTO_LANG, "SH_CHOOSE_THE_NEXT_MAP", g_timer )

		if ( g_timer < 6 )
		{
			new speak[5][] = {  "one", "two", "three", "four", "five" }
			client_cmd ( 0 ,"spk ^"sound/server_2/%s^"", speak[g_timer - 1] )
		}

		g_timer--
		set_task ( 1.0, "task_timetochoose", 0 )
	}

	else
	{
		say_message ( 0, LOG_ON, "%L", AUTO_LANG, "CL_TIME_TO_CHOOSE" )
		say_hudmessage ( 0, 100, 200, 0, -1.0, 0.1, 0, 0.0, 8.0, 1.0, 1.0, 4, "%L", AUTO_LANG, "SH_TIME_TO_CHOOSE" )

		client_cmd ( 0, "spk sound/server_2/vote_start")

		new menu_value[64], menu_num[3]

		formatex ( menu_value, sizeof ( menu_value ) - 1, "\r%L", LANG_PLAYER, "CL_MENU_TITLE" )

		g_menuID = menu_create ( menu_value, "menu_handle" )

		menu_setprop ( g_menuID, MPROP_EXIT, MEXIT_NEVER )
		menu_setprop ( g_menuID, MPROP_NOCOLORS, g_colored )
		menu_setprop ( g_menuID, MPROP_NUMBER_COLOR, "\y" )
		menu_setprop ( g_menuID, MPROP_PERPAGE, 0)

		for ( new i = 0; i < ( MAX_SELECT ); ++i )
		{
			g_select_mapvotecheck[i] = 0
		}

		for ( new i = 0; i < g_select_mapcount; ++i )
		{
			num_to_str ( i, menu_num, sizeof ( menu_num ) - 1 )
			formatex ( menu_value, sizeof ( menu_value ) - 1, "\w%s", g_select_mapname[i] )
			menu_additem ( g_menuID, menu_value, menu_num, 0 )
		}

		if	( isextend() )
		{
			get_mapname ( g_select_mapname[g_select_mapmax], LEN_MAPNAME )
			num_to_str ( g_select_mapmax, menu_num, sizeof ( menu_num ) - 1 )
			formatex ( menu_value, sizeof ( menu_value ) - 1, "\w%s \y[%L]", g_select_mapname[g_select_mapmax], LANG_PLAYER, "CL_MENU_EXTEND" )
			menu_additem ( g_menuID, menu_value, menu_num, 0 )
			g_select_mapvotecheck[g_select_mapmax] = 0
		}

		g_rating_idcount = 0

		log_amx ( "%L", LANG_SERVER, "SV_VOTING_STARTED" )

		g_timer = 9

		set_task ( 0.1, "task_vote_timer", TASK_ID_VOTE_TIMER )
	}

	return PLUGIN_CONTINUE
}

public task_vote_timer ( )
{
	if ( g_timer )
	{
		if ( g_timer > 1 )
			say_hudmessage ( 0, 220, 160, 0, -1.0, 0.15, 0, 6.0, 1.03, 0.0, 0.0, 5, "%L", AUTO_LANG, "SH_SECONDS_BEFORE_VOTING", g_timer )

		else
			say_hudmessage ( 0, 220, 160, 0, -1.0, 0.15, 0, 6.0, 1.0, 0.0, 1.0, 5, "%L", AUTO_LANG, "SH_SECONDS_BEFORE_VOTING", g_timer )

		g_timer--
		set_task ( 1.0, "task_vote_timer", TASK_ID_VOTE_TIMER )
	}

	else
	{
		set_task ( 1.0, "check_vote_end" )
	}

	new fade[2]
	fade[0] = 1; set_task ( 1.0, "cmd_screen_fade", 0, fade, 2 )

	menu_clients_print ( 1 )

	cmd_print_rating()

	return PLUGIN_CONTINUE
}

public cmd_print_rating ( )
{
	if ( !g_rating_idcount )
		return PLUGIN_CONTINUE

	new players[32], num
	get_players ( players, num, "ch" )

	new message[1024], pos

	for ( new i = 0; i < g_select_mapcount; ++i )
	{
		pos += formatex ( message[pos], sizeof ( message ) - 1, "%s %s^n", g_select_mapname[i], format_rating_prefix ( g_select_mapvotecheck[i] ) )
	}

	if	( isextend() )
	{
		pos += formatex ( message[pos], sizeof ( message ) - 1, "%s %s^n", g_select_mapname[g_select_mapmax], format_rating_prefix ( g_select_mapvotecheck[g_select_mapmax] ) )
	}

	for ( new i = 0; i < g_rating_idcount; ++i )
	{
		say_hudmessage ( g_rating_idplayer[i], 255, 255, 255, 0.04, 0.40, 0, 2.0, 2.0, 0.0, 0.0, 3, "%L^n^n%s^n%L", AUTO_LANG, "SH_VOTE_RATING", message, AUTO_LANG, "SH_PLAYERS_VOTED", g_rating_idcount, num )
	}

	return PLUGIN_CONTINUE
}

format_rating_prefix ( num )
{
	new src[32]

	if ( num > 9 )
		formatex ( src, sizeof ( src ) - 1, "%L", LANG_SERVER, "SH_RT2", num )

	else if ( num > 0 )
		formatex ( src, sizeof ( src ) - 1, "%L", LANG_SERVER, "SH_RT1", num )

	else
		formatex ( src, sizeof ( src ) - 1, "%L", LANG_SERVER, "SH_RT0" )

	return src
}

public cmd_get_prefix ( )
{
	new filename[64], string[32], pos, len

	formatex ( filename, sizeof ( filename ) - 1, "%s/umm/maprefix.ini", g_configsdir )

	g_prefix_count = 1
	copy ( g_prefix_name[0], LEN_PREFIX, "" )

	if ( file_exists ( filename ) )
	{
		while ( ( g_prefix_count < MAX_PREFIX ) && read_file ( filename, pos++, string, sizeof ( string ) - 1, len ) )
		{
			if ( ( string[0] != ';' ) && parse ( string, g_prefix_name[g_prefix_count], LEN_PREFIX ) )
			{
				g_prefix_count++
			}
		}
	}

	else
	{
		if ( !write_file ( filename, "; Plugin will create this file automatically" ) )
		{
			log_amx ( "%L", LANG_SERVER, "SV_FILE_WRITE_UNABLE", filename )

			return 0
		}

		log_amx ( "%L", LANG_SERVER, "SV_FILE_CREATE", filename )
	
		return 0
	}

	return 1
}

public cmd_get_lastmaps ( )
{
	new lastmaps = get_pcvar_num ( pcv_lastmaps )

	if (lastmaps > LAST_MAPS)
	{
		lastmaps = LAST_MAPS
	}

	get_mapname ( g_last_mapname[0], LEN_MAPNAME )

	new filename[64], string[32], pos, len

	formatex ( filename, sizeof ( filename ) - 1, "%s/umm/maplast.ini", g_configsdir )

	g_last_mapcount = 1

	if ( file_exists ( filename ) )
	{
		while ( ( g_last_mapcount < lastmaps ) && read_file ( filename, pos++, string, sizeof ( string ) - 1, len ) )
		{
			if ( ( string[0] != ';' ) && parse ( string, g_last_mapname[g_last_mapcount], LEN_MAPNAME ) && is_map_valid ( g_last_mapname[g_last_mapcount] ) )
			{
				g_last_mapcount++
			}
		}
	}

	else
	{
		log_amx ( "%L", LANG_SERVER, "SV_FILE_CREATE", filename )
	
		return 0
	}

	return 1
}

public cmd_put_lastmaps ( )
{
	new filename[64]
	formatex ( filename, sizeof ( filename ) - 1, "%s/umm/maplast.ini", g_configsdir )

	if ( !delete_file ( filename ) )
	{
		log_amx ( "%L", LANG_SERVER, "SV_FILE_DELETE_UNABLE", filename )
	}

	if ( !write_file ( filename, "; Generated by Map Manager Plugin. Do not modify!" ) )
	{
		log_amx ( "%L", LANG_SERVER, "SV_FILE_WRITE_UNABLE", filename )
	
		return 0
	}

	else
	{
		for ( new i = 0; i < g_last_mapcount; ++i )
			write_file ( filename, g_last_mapname[i] )
	}

	return 1
}

public cmd_amx_banmap ( id, level, cid )
{
	if ( !cmd_access ( id, level, cid, 2 ) )
		return PLUGIN_HANDLED

	new string[256], map[32]

	read_args ( string, sizeof ( string ) - 1 )
	parse ( string, map, sizeof ( map ) - 1 )
	remove_sign ( map )

	if ( !is_map_valid ( map ) )
	{
		console_print ( id, "%L", id, "CL_MAP_NOT_FOUND", map )
	
		return PLUGIN_HANDLED
	}

	if ( isbanned ( map ) )
	{
		console_print ( id, "%L", id, "CL_MAP_BANNED_ALREADY", map )

		return PLUGIN_HANDLED
	}

	if ( !( g_ban_mapcount < BAN_MAPS ) )
	{
		console_print ( id, "%L", id, "CL_BANLIST_FULL", map )
		log_amx ( "%L", LANG_SERVER, "CL_BANLIST_FULL", map )

		return PLUGIN_HANDLED
	}

	formatex ( g_ban_mapname[g_ban_mapcount], LEN_MAPNAME, "%s", map )
	g_ban_mapcount++

	if ( cmd_put_banmaps() )
	{
		console_print ( id, "%L", id, "CL_MAP_BANNED", map )
		log_amx ( "%L", LANG_SERVER, "CL_MAP_BANNED", map )
	}

	else
	{
		console_print ( id, "%L", id, "CL_BANLIST_PROBLEM" )
	}

	return PLUGIN_HANDLED
}

public cmd_amx_unbanmap ( id, level, cid )
{
	if ( !cmd_access ( id, level, cid, 2 ) )
		return PLUGIN_HANDLED

	new string[256], map[32]

	read_args ( string, sizeof ( string ) - 1 )
	parse ( string, map, sizeof ( map ) - 1 )
	remove_sign ( map )

	if ( !isbanned ( map ) )
	{
		console_print ( id, "%L", id, "CL_BANLIST_MAP_NOT_FOUND", map )

		return PLUGIN_HANDLED
	}

	for ( new i = 0; i < g_ban_mapcount; ++i )
	{
		if ( equali ( g_ban_mapname[i], map ) )
		{
			for ( new j = i + 1; j < g_ban_mapcount; ++j )
			{
				g_ban_mapname[j-1] = g_ban_mapname[j]
			}

			g_ban_mapcount--
		}
	}

	if ( cmd_put_banmaps() )
	{
		console_print ( id, "%L", id, "CL_BANLIST_MAP_REMOVED", map )
		log_amx ( "%L", LANG_SERVER, "CL_BANLIST_MAP_REMOVED", map )
	}

	else
	{
		console_print ( id, "%L", id, "CL_BANLIST_PROBLEM" )
	}

	return PLUGIN_HANDLED
}

public cmd_get_banmaps ( )
{
	new filename[64], string[32], pos, len
	formatex ( filename, sizeof ( filename ) - 1, "%s/umm/mapban.ini", g_configsdir )

	if ( file_exists ( filename ) )
	{
		while ( ( g_ban_mapcount < ( BAN_MAPS ) ) && read_file ( filename, pos++, string, sizeof ( string ) - 1, len ) )
		{
			if ( ( string[0] != ';' ) && parse ( string, g_ban_mapname[g_ban_mapcount], LEN_MAPNAME ) && is_map_valid ( g_ban_mapname[g_ban_mapcount] ) )
			{
				g_ban_mapcount++
			}
		}
	}

	else
	{
		log_amx ( "%L", LANG_SERVER, "SV_FILE_NOT_FOUND", filename )

		return 0
	}

	return 1
}

public cmd_put_banmaps ( )
{
	new filename[64]
	formatex ( filename, sizeof ( filename ) - 1, "%s/umm/mapban.ini", g_configsdir )

	if ( !delete_file ( filename ) )
	{
		log_amx ( "%L", LANG_SERVER, "SV_FILE_DELETE_UNABLE", filename )

		return 0
	}

	if ( !write_file ( filename, "; Plugin will create this file automatically" ) )
	{
		log_amx ( "%L", LANG_SERVER, "SV_FILE_WRITE_UNABLE", filename )

		return 0
	}

	else
	{
		for ( new i = 0; i < g_ban_mapcount; ++i )
		{
			write_file ( filename, g_ban_mapname[i] )
		}
	}

	return 1
}

public cmd_get_selectmap ( )
{
	g_select_mapcount = 0

	while ( ( g_select_mapcount < g_custom_mapcount ) && ( g_select_mapcount < g_select_mapmax ) )
	{
		copy ( g_select_mapname[g_select_mapcount], LEN_MAPNAME, g_custom_mapname[g_select_mapcount] )
		g_select_mapcount++
	}

	cmd_get_votemaps()

	new idx

	while ( g_select_mapcount < g_select_mapmax )
	{
		if ( isfreeidx() )
		{
			idx = random_num ( 0, g_idx_mapcount - 1 )

			if ( g_idx_mapname[idx] != g_vote_mapcount && !isselect ( g_vote_mapname[g_idx_mapname[idx]] ) )
			{
				copy ( g_select_mapname[g_select_mapcount], LEN_MAPNAME, g_vote_mapname[g_idx_mapname[idx]] )
				g_select_mapcount++
			}

			else
			{
				g_idx_mapname[idx] = g_vote_mapcount
			}
		}

		else
		{
			return g_select_mapcount
		}
	}

	return g_select_mapcount
}

public cmd_get_votemaps ( )
{
	new weeks[7][3] = {
		"Su",
		"Mo",
		"Tu",
		"We",
		"Th",
		"Fr",
		"Sa"
	}

	new date_week[3], idx
	get_time ( "%w", date_week, sizeof ( date_week ) - 1 )
	idx = str_to_num ( date_week )

	new filename[64]
	formatex ( filename, sizeof ( filename ) - 1, "%s/umm/mapconfig.ini", g_configsdir )

	if ( file_exists ( filename ) )
	{
		new string[128], pos, len
		new players = get_playersnum ( 1 ), maprate, week[16]
		new vote_maprate[5], vote_mapmin[5], vote_mapmax[5]

		g_vote_mapcount = g_list_mapcount = g_idx_mapcount = 0

		while ( ( g_vote_mapcount < ( MAX_MAPS ) ) && read_file ( filename, pos++, string, sizeof ( string ) - 1, len ) )
		{
			if	(	string[0] != ';' &&
					parse
						(
							string,
							g_vote_mapname[g_vote_mapcount], LEN_MAPNAME,
							vote_maprate, sizeof ( vote_maprate ) - 1,
							vote_mapmin, sizeof ( vote_mapmin ) - 1,
							vote_mapmax, sizeof ( vote_mapmax ) - 1,
							week, sizeof ( week ) - 1
						)
				)
			{
				maprate = str_to_num(vote_maprate)

				if	( is_map_valid ( g_vote_mapname[g_vote_mapcount] ) && ( !get_pcvar_num ( pcv_restrict_maplist ) || ( get_pcvar_num ( pcv_restrict_maplist ) && containi ( week, weeks[idx] ) != -1 ) ) )
				{
					g_list_mapname[g_list_mapcount] = g_vote_mapname[g_vote_mapcount]
					g_list_min_players[g_list_mapcount] = str_to_num ( vote_mapmin )
					g_list_max_players[g_list_mapcount] = str_to_num ( vote_mapmax )
					g_list_mapcount++
				}

				if	(
						is_map_valid ( g_vote_mapname[g_vote_mapcount] ) &&
						!islastmap ( g_vote_mapname[g_vote_mapcount] ) &&
						!isbanned ( g_vote_mapname[g_vote_mapcount] ) &&
						( iscustom ( g_vote_mapname[g_vote_mapcount] ) == -1 ) &&
						( containi ( week, weeks[idx] ) != -1 ) &&
						( maprate > 0 ) && ( maprate < 6 ) &&
						( players + 1 ) > str_to_num ( vote_mapmin ) &&
						( players - 1 ) < str_to_num ( vote_mapmax )
					)
				{
					for ( new i = 0; i < maprate; ++i )
					{
						g_idx_mapname[g_idx_mapcount] = g_vote_mapcount
						g_idx_mapcount++
					}
					g_vote_mapcount++
				}
			}
		}
	}

	else
	{
		log_amx ( "%L", LANG_SERVER, "SV_FILE_NOT_FOUND", filename )

		return 0
	}

	return 1
}

public cmd_screen_fade ( fade[] )
{
	if ( !get_pcvar_num ( pcv_screenfade ) )
		return PLUGIN_CONTINUE

	new time, hold, flags

	switch (fade[0])
	{
		case 1:
		{
			time = 1
			hold = 1
			flags = 4
		}
	
		case 2:
		{
			time = 4096
			hold = 1024
			flags = 1
		}
	
		default:
		{
			time = 4096
			hold = 1024
			flags = 2
		}
	}

	message_begin ( MSG_ALL, g_msgScrenFade, {0,0,0}, 0 )
	write_short	( time )
	write_short	( hold )
	write_short	( flags )
	write_byte	( 0 )
	write_byte	( 0 )
	write_byte	( 0 )
	write_byte	( 255 )
	message_end()

	return PLUGIN_CONTINUE
}

public task_mapcycle ( )
{
	new nextmap[32]

	if ( cmd_get_selectmap() )
		copy ( nextmap, sizeof ( nextmap ) - 1, g_select_mapname[0] )

	else
	{
		new filename[32], pos
		new string[32], map[32], num[8]

		get_localinfo ( "lastmapcycle", string, sizeof ( string ) - 1 )

		parse ( string, map, sizeof ( map ) - 1, num, sizeof ( num ) - 1 )

		pos = str_to_num ( num )

		get_cvar_string ( "mapcyclefile", filename, sizeof ( filename ) - 1 )

		if ( !equal ( filename, map ) ) pos = 0

		pos = cmd_read_mapcycle ( filename, nextmap, pos, sizeof ( nextmap ) - 1 )

		formatex ( map, sizeof ( map ) - 1, "%s %d", filename, pos )

		set_localinfo ( "lastmapcycle", map )
	}

	set_pcvar_string ( pcv_amx_nextmap, nextmap )
}

public cmd_read_mapcycle ( filename[], nextmap[], pos, len )
{
	new line, maps, txtlen
	new buffer[32], first[32]

	if ( file_exists ( filename ) )
	{
		while ( read_file ( filename, line++, buffer, sizeof ( buffer ) - 1, txtlen ) )
		{
			if ( !isalnum ( buffer[0] ) || !is_map_valid ( buffer ) )
			{
				continue
			}

			if ( !maps )
			{
				copy ( first, sizeof ( first ) - 1, buffer )
			}

			if ( ++maps > pos )
			{
				copy ( nextmap, len, buffer )
				pos = maps

				return pos
			}
		}
	}

	if ( !maps )
	{
		log_amx ( "%L", LANG_SERVER, "SV_FILE_MAPCYCLE_NOT_FOUND", filename )
		get_mapname ( first, sizeof ( first ) - 1 )
	}

	copy ( nextmap, len, first )
	pos = 1

	return pos
}

public cmd_say_thetime ( id )
{
	new shours[16], smins[16], ssec[16], sday[16], smon[16], syear[16], mmon[128]
	
	get_time("%H", shours, 15)
	get_time("%M", smins, 15)
	get_time("%S", ssec, 15)
	get_time("%d", sday, 15)
	get_time("%m", smon, 15)
	get_time("%Y", syear, 15)
	
	new dmins = str_to_num(smins)
	new dhours = str_to_num(shours)
	new dsec = str_to_num(ssec)
	new dday = str_to_num(sday)
	new dmon = str_to_num(smon)
	new dyear = str_to_num(syear)
	
	if(dmon==1){
		mmon = "ЯНВАРЯ"
	}else if(dmon==2){
		mmon = "ФЕВРАЛЯ"
	}else if(dmon==3){
		mmon = "МАРТА"
	}else if(dmon==4){
		mmon = "АПРЕЛЯ"
	}else if(dmon==5){
		mmon = "МАЯ"
	}else if(dmon==6){
		mmon = "ИЮНЯ"
	}else if(dmon==7){
		mmon = "ИЮЛЯ"
	}else if(dmon==8){
		mmon = "АВГУСТА"
	}else if(dmon==9){
		mmon = "СЕНТЯБРЯ"
	}else if(dmon==10){
		mmon = "ОКТЯБРЯ"
	}else if(dmon==11){
		mmon = "НОЯБРЯ"
	}else{
		mmon = "ДЕКАБРЯ"
	}
	
	client_print(0, print_chat, "%L:   %d:%d:%d   %L  %d  %s  %d", LANG_PLAYER, "CL_THE_TIME", dhours, dmins, dsec, LANG_PLAYER, "CL_TODAY", dday, mmon, dyear )
	
	return PLUGIN_CONTINUE
}

public cmd_say_timeleft ( id )
{
	if ( get_pcvar_float ( pcv_mp_timelimit ) )
	{
		if ( g_mapvoteprogress || g_votemap_full )
		{
			say_message ( id, LOG_OFF, "%L %L", id, "CL_TIME_LEFT", id, "SH_LAST_ROUND" )
		}

		else
		{
			new timeleft = get_timeleft()
			say_message ( id, LOG_OFF, "%L %02d:%02d", id, "CL_TIME_LEFT", ( timeleft / 60 ), ( timeleft % 60 ) )
		}
	}

	else
	{
		say_message ( id, LOG_OFF, "%L", id, "CL_NO_TIME_LIMIT" )
	}

	return PLUGIN_CONTINUE
}

public task_time_remaining ( )
{
	set_task ( 1.0, "task_time_remaining" )

	if ( get_pcvar_float ( pcv_mp_timelimit ) )
	{
		new timeleft = get_timeleft()

		if ( !g_mapvoteprogress )
		{
			if ( g_votemap_full )
			{
				if ( ( get_pcvar_num ( pcv_lastminute ) ) || ( timeleft < ( get_pcvar_num ( pcv_mp_chattime ) + VOTE_TIME ) ) )
				{
					check_vote_start()
				}

				timeleft = 0
			}

			else
			{
				if ( get_pcvar_num ( pcv_lastminute ) && ( timeleft < ( get_pcvar_num ( pcv_mp_chattime ) + VOTE_TIME ) ) )
				{
					check_vote_start()
				}
			}

			if ( timeleft && ( timeleft < 3 ) )
			{
				if ( !g_timelimitRepare )
				{
					g_timelimit = get_pcvar_float ( pcv_mp_timelimit )
					g_timelimitRepare = true
				}

				new Float: timelimit = get_pcvar_float ( pcv_mp_timelimit )
				g_addtime = ( get_pcvar_float ( pcv_mp_roundtime ) * 60 + get_pcvar_num ( pcv_mp_freezetime ) + get_pcvar_num ( pcv_mp_c4timer ) + get_pcvar_num ( pcv_mp_chattime ) + VOTE_TIME + LAST_MINUTE ) / 60

				set_pcvar_float ( pcv_mp_timelimit, timelimit + g_addtime )

				g_votemap_full = true
			}
		}

		else
		{
			timeleft = 0
		}

		new string[12]
		formatex ( string, sizeof ( string ) - 1, "%02d:%02d", timeleft / 60, timeleft % 60 )
		set_pcvar_string ( pcv_amx_timeleft, string )
	}
}

public cmd_say_ffstatus ( id )
{
	say_message ( id, LOG_OFF, "%L %L", id, "CL_FRIENDLY_FIRE", id, get_pcvar_num ( pcv_mp_friendlyfire ) ? "CL_ON" : "CL_OFF" )
}

public cmd_say_currentmap ( id )
{
	new mapname[LEN_MAPNAME]
	get_mapname ( mapname, sizeof ( mapname ) - 1 )
	say_message ( id, LOG_OFF, "%L %s", id, "CL_PLAYED_MAP", mapname )
}

public task_clear_votemap ( )
{
	for ( new i = 0; i < 33; ++i )
	{
		g_votemap_idplayer[i] = false
	}
}

public cmd_maplist ( id )
{
	new filter, start
	new arg[8], args_num = read_argc()

	for ( new i = 1; i < args_num; ++i )
	{
		read_argv ( i, arg, sizeof ( arg ) - 1 )

		if ( equali ( arg, "-n") )
		{
			filter |= 1
		}

		else if ( equali ( arg, "-l") )
		{
			filter |= 2
		}

		else if ( equali ( arg, "-b") )
		{
			filter |= 4
		}

		else if ( !start )
		{
			start = str_to_num ( arg )
		}
	}

	if ( filter )
	{
		console_print ( id, "%L:", id, "CL_MAPLIST" )

		if 	( filter & 1 )
		{
			print_maplist_nominated ( id )
		}

		if 	( filter & 2 )
		{
			print_maplist_lastmaps ( id )
		}

		if 	( filter & 4 )
		{
			if ( get_user_flags ( id ) & ADMIN_MAP )
			{
				print_maplist_banned ( id )
			}
		}
	}

	else
	{
		print_maplist_main ( id, start )
	}

	console_print ( id, "^n]" )

	return PLUGIN_HANDLED
}

print_maplist_nominated ( id )
{
	console_print ( id, "^n%s^t%L:", "#", id, "CL_NOMINATED" )

	for ( new i = 0; i < g_custom_mapcount; ++i )
	{
		console_print ( id, "%d^t%-33.32s", i + 1, g_custom_mapname[i] )
	}
}

print_maplist_lastmaps ( id )
{
	console_print ( id, "^n%s^t%L:", "#", id, "CL_LAST_PLAYED" )

	for ( new i = 0; i < g_last_mapcount; ++i )
	{
		console_print ( id, "%d^t%-33.32s", i + 1, g_last_mapname[i] )
	}
}

print_maplist_banned ( id )
{
	console_print ( id, "^n%s^t%L:", "#", id, "CL_BANNED" )

	for ( new i = 0; i < g_ban_mapcount; ++i )
	{
		console_print ( id, "%d^t%-33.32s", i + 1, g_ban_mapname[i] )
	}
}

print_maplist_main ( id, start )
{
	if ( !start )
	{
		start = check_cvar_num ( start, g_maplist_lastidx[id], g_list_mapcount )
	}

	new end = check_cvar_num ( start + MAPS_PERPAGE, 0, g_list_mapcount )
	start = check_cvar_num ( start, 1, end ) - 1

	console_print ( id, "%L (%d-%d |%d):", id, "CL_MAPLIST", start + 1, end, g_list_mapcount )
	console_print ( id, "%L", id, "CL_MAPLIST_HELP" )
	console_print ( id, "^n%s^t%L^t^t^t%L", "#", id, "CL_MAP", id, "CL_STATUS" )

	new status[64], nominate[64], last[64], banned[64], minmax[64], pos = start + 1

	formatex ( nominate, sizeof ( nominate ) - 1, "%L", id, "CL_NOMINATED" )
	formatex ( last, sizeof ( last ) - 1, "%L", id, "CL_LAST_PLAYED" )
	formatex ( banned, sizeof ( banned ) - 1, "%L", id, "CL_BANNED" )

	for ( new i = start; ( ( i < g_list_mapcount ) && ( pos <= end ) ); ++i )
	{
		if ( iscustom ( g_list_mapname[i] ) != -1 )
		{
			copy ( status, sizeof ( status ) - 1, nominate )
		}

		else if ( islastmap ( g_list_mapname[i] ) )
		{
			copy ( status, sizeof ( status ) - 1, last )
		}

		else if ( isbanned ( g_list_mapname[i] ) )
		{
			if ( get_user_flags ( id ) & ADMIN_MAP )
			{
				copy ( status, sizeof ( status ) - 1, banned )
			}

			else continue
		}

		else
		{
			copy ( status, sizeof ( status ) - 1, "" )
		}

		if ( get_pcvar_num ( pcv_restrict_maplist ) )
		{
			formatex ( minmax, sizeof ( minmax ) - 1, "%s (%i-%i)", g_list_mapname[i], g_list_min_players[i], g_list_max_players[i] )
		}

		else
		{
			formatex ( minmax, sizeof ( minmax ) - 1, "%s", g_list_mapname[i] )
		}

		console_print ( id, "%d^t%s^t^t%s", pos++, minmax, status )
	}

	if ( end < g_list_mapcount )
	{
		g_maplist_lastidx[id] = end
	}

	else
	{
		g_maplist_lastidx[id] = 0
	}
}

public cmd_say_votemap ( id )
{
	if ( !get_pcvar_float ( pcv_voteratio ) )
	{
		say_message ( id, LOG_OFF, "%L", id, "CL_VOTE_MAP_CHANGE_DISABLE" )

		return PLUGIN_HANDLED
	}

	if ( get_pcvar_float ( pcv_timeout_nominate ) )
	{
		new timer = check_disable_nominate()

		if ( timer )
		{
			say_message ( id, LOG_OFF, "%L", id, "CL_VOTE_MAP_CHANGE_TIMEOUT", timer / 60, timer % 60 )

			return PLUGIN_HANDLED
		}
	}

	if ( g_mapvoteprogress || g_votemap_full )
	{
		say_message ( id, LOG_OFF, "%L", id, "CL_VOTING_PROGRESS" )
	
		return PLUGIN_HANDLED
	}

	if ( g_votemap_idplayer[id] )
	{
		say_message ( id, LOG_OFF, "%L", id, "CL_VOTE_MAP_ALREADY" )
	}

	else
	{
		new  name[32]

		g_votemap_idplayer[id] = true
		get_user_name ( id, name, sizeof ( name ) - 1 )
		say_message ( 0, LOG_ON, "%L", AUTO_LANG, "CL_VOTE_MAP_CHANGE", name )
	}

	new players[32], num, voted
	get_players ( players, num, "ch" )

	for ( new i = 0; i < num; ++i )
	{
		if ( g_votemap_idplayer[players[i]] )
		{
			if ( get_user_flags ( players[i] ) & get_admin_level_flag() )
				voted += get_pcvar_num ( pcv_admin_voteweight )

			else
				voted++
		}
	}

	if ( num && ( floatround (get_pcvar_float ( pcv_voteratio ) * 100.0 ) > ( voted * 100 / num ) ) )
	{
		say_message ( 0, LOG_ON, "%L", AUTO_LANG, "CL_VOTE_MAP_PLAYERS", voted, floatround ( get_pcvar_float ( pcv_voteratio ) * num + 0.49 ) )

		return PLUGIN_CONTINUE
	}

	g_votemap_full = true
	say_message ( 0, LOG_ON, "%L", AUTO_LANG, "CL_VOTE_MAP_CHANGE_ALL" )

	return PLUGIN_CONTINUE
}

public cmd_umm_votemap ( id, level, cid )
{
	if ( !cmd_access ( id, level, cid, 1 ) )
		return PLUGIN_HANDLED

	if ( g_mapvoteprogress || g_votemap_full )
	{
		say_message ( id, LOG_OFF, "%L", id, "CL_VOTING_PROGRESS" )

		return PLUGIN_HANDLED
	}

	if ( get_pcvar_num ( pcv_amx_show_activity ) )
	{
		new name[32]
		get_user_name ( id, name, sizeof ( name ) - 1 )
		say_message ( 0, LOG_OFF, "%L", AUTO_LANG, "CL_VOTE_MAP_ADMIN", ( get_pcvar_num ( pcv_amx_show_activity ) == 2 ) ? name : "" )
		log_amx ( "%L", LANG_SERVER, "CL_VOTE_MAP_ADMIN", name )
	}

	g_votemap_full = true

	return PLUGIN_HANDLED
}

public hook_say_mapname ( id )
{
	if ( !g_custom_mapmax )
		return PLUGIN_CONTINUE

	new string[256], mapname[32], prefixmap[32]

	read_args ( string, sizeof ( string ) - 1 )
	parse ( string, mapname, sizeof ( mapname ) - 1 )
	remove_sign ( mapname )

	for ( new i = 0; i < g_prefix_count; ++i )
	{
		formatex ( prefixmap, sizeof ( prefixmap ) - 1, "%s%s", g_prefix_name[i], mapname )

		if ( is_map_valid ( prefixmap ) )
		{
			if ( !get_pcvar_num ( pcv_restrict_maplist ) || islistmap ( prefixmap ) != -1 )
			{
				check_nomination ( id, prefixmap )
			}

			return PLUGIN_CONTINUE
		}
	}

	return PLUGIN_CONTINUE
}

public check_nomination ( id, map[] )
{
	if ( g_mapvoteprogress || g_votemap_full )
	{
		say_message ( id, LOG_OFF, "%L", id, "CL_VOTING_PROGRESS" )
	
		return PLUGIN_HANDLED
	}

	if ( islastmap ( map ) )
	{
		say_message ( id, LOG_OFF, "%L", id, "CL_MAP_NOMINATE_LAST" )

		return PLUGIN_HANDLED
	}

	if ( isbanned ( map ) )
	{
		say_message ( id, LOG_OFF, "%L", id, "CL_MAP_NOMINATE_BANNED" )

		return PLUGIN_HANDLED
	}

	if ( get_pcvar_num ( pcv_restrict_maplist ) )
	{
		new players[32], num
		get_players ( players, num, "ch" )

		new listmap_idx = islistmap ( map )

		if ( listmap_idx != -1 && ( num < g_list_min_players[listmap_idx] || num > g_list_max_players[listmap_idx] ) )
		{
			say_message ( id, LOG_OFF, "%L", id, "CL_MAP_NOMINATE_REQUIRES", g_list_min_players[listmap_idx], g_list_max_players[listmap_idx] )

			return PLUGIN_HANDLED
		}
	}

	new name[32]
	new custom_idx = iscustom ( map )

	if ( custom_idx != -1 )
	{
		if ( g_custom_userid[custom_idx] == id )
		{
			formatex ( name, sizeof ( name ) - 1, "%L", id, "CL_YOU" )
		}

		else
		{
			get_user_name ( g_custom_userid[custom_idx], name, sizeof ( name ) - 1 )
		}

		say_message ( id, LOG_OFF, "%L", id, "CL_MAP_NOMINATE_ALREADY", name, map )

		return PLUGIN_HANDLED
	}

	get_user_name ( id, name, sizeof ( name ) - 1 )
	custom_idx = iscustomidx ( id )

	if ( custom_idx != -1 )
	{
		say_message ( 0, LOG_ON, "%L", AUTO_LANG, "CL_MAP_NOMINATE_SWITCH", name, g_custom_mapname[custom_idx], map )
		formatex ( g_custom_mapname[custom_idx], LEN_MAPNAME, map )
	}

	else if ( g_custom_mapcount < ( g_custom_mapmax - g_custom_reserved + iscustomacc() ) )
	{
		say_message ( 0, LOG_ON, "%L", AUTO_LANG, "CL_MAP_NOMINATE", name, map )
		formatex ( g_custom_mapname[g_custom_mapcount], LEN_MAPNAME, map )
		g_custom_userid[g_custom_mapcount] = id
		g_custom_mapcount++
	}

	else if ( ( get_user_flags ( id ) & get_admin_level_flag() ) && ( g_custom_mapcount < g_custom_mapmax ) )
	{
		if ( get_pcvar_num ( pcv_amx_show_activity ) )
		{
			say_message ( 0, LOG_OFF, "%L", AUTO_LANG, "CL_MAP_NOMINATE_ADMIN", ( get_pcvar_num ( pcv_amx_show_activity ) == 2 ) ? name : "", map )
			log_amx ( "%L", LANG_SERVER, "CL_MAP_NOMINATE_ADMIN", name, map )
		}

		else
		{
			say_message ( 0, LOG_ON, "%L", AUTO_LANG, "CL_MAP_NOMINATE", name, map )
		}

		formatex ( g_custom_mapname[g_custom_mapcount], LEN_MAPNAME, map )
		g_custom_userid[g_custom_mapcount] = id
		g_custom_mapcount++
	}

	else
	{
		say_message ( id, LOG_OFF, "%L", id, "CL_MAP_NOMINATE_MAX", g_custom_mapmax )
	}

	return PLUGIN_HANDLED
}

public check_restrict_plugins ( )
{
	cmd_pause_plugin ( "nextmap.amxx" )
	cmd_pause_plugin ( "timeleft.amxx" )
	cmd_pause_plugin ( "mapchooser.amxx" )
}

cmd_pause_plugin ( arg[32] )
{
	new len = strlen ( arg )

	if ( len && ( ( cmd_find_plugin ( arg, len ) ) != -1 ) && pause ( "dc", arg ) )
	{
		log_amx ( "%L", LANG_SERVER, "SV_PLUGIN_STOP", arg )
	}
}

cmd_find_plugin ( arg[32], &len )
{
	new name[32], title[32], status[2]
	new pluginsnum = get_pluginsnum()

	for ( new i = 0; i < pluginsnum; ++i )
	{
		get_plugin ( i, name, sizeof ( name ) - 1, title, sizeof ( title ) - 1, status, 0, status, 0, status, 1 )
	
		if	( equali ( name, arg, len ) &&	(
												status[0] == 'r' ||	/*running*/
												status[0] == 'p' ||	/*paused*/
												status[0] == 's' ||	/*stopped*/
												status[0] == 'd' 	/*debug*/
											)
			)
		{
			len = copy ( arg, sizeof ( arg ) - 1, name )
	
			return i
		}
	}
	
	return -1
}

public menu_clients_print ( on )
{
	new players[32], num
	get_players ( players, num, "ch" )

	for ( new i = 0; i < num; ++i )
	{
		if ( !israting ( players[i] ) && is_user_connected ( players[i] ) )
		{
			if ( on )
			{
				menu_display ( players[i], g_menuID )
			}

			else
			{
				menu_cancel ( players[i] )
				client_cmd ( players[i], "slot1" )
			}
		}
	}
}

public event_team_score ( )
{
	new team[2]

	read_data ( 1, team, 1 )
	g_teamScore[( team[0]=='C' ) ? 0 : 1] = read_data ( 2 )

	if ( !get_pcvar_num ( pcv_lastminute ) )
	{
		check_vote_start()
	}

	return PLUGIN_CONTINUE
}

public event_end_round ( )
{
	g_round++

	if ( !get_pcvar_num ( pcv_lastminute ) )
	{
		check_vote_start()
	}

	return PLUGIN_CONTINUE
}

public event_restart_game ( )
{
	g_round = 1
	g_maptimer = get_gametime()
	g_nominate_print = false

	return PLUGIN_CONTINUE
}

public event_map_change ( )
{
	new string[32]
	new Float:chattime = get_pcvar_float ( pcv_mp_chattime )

	if ( chattime < 3.0 )
	{
		chattime = 3.0
		set_pcvar_float ( pcv_mp_chattime, chattime )
	}

	new len = get_pcvar_string ( pcv_amx_nextmap, string, sizeof ( string ) - 1 ) + 1

	set_task ( chattime - 1.0, "task_delayed_mapchange", 0, string, len )

	return PLUGIN_CONTINUE
}


public check_disable_nominate ( )
{
	new timer = floatround ( get_gametime() - g_maptimer )

	if ( floatround ( get_pcvar_float ( pcv_timeout_nominate ) * 60.0 ) > timer )
		return floatround ( get_pcvar_float ( pcv_timeout_nominate ) * 60.0 ) - timer

	return 0
}

public task_delayed_mapchange ( param[] )
{
	server_cmd ( "changelevel %s", param )

	return PLUGIN_CONTINUE
}

public event_map_end ( )
{
	if ( !g_timelimitRepare )
	{
		g_timelimit = get_pcvar_float ( pcv_mp_timelimit )
		g_timelimitRepare = true
	}

	set_pcvar_float ( pcv_mp_timelimit, 0.01 )

	return PLUGIN_CONTINUE
}

say_hudmessage ( id, red=200, green=100, blue=0, Float:x=-1.0, Float:y=0.35, effects=0, Float:fxtime=6.0, Float:holdtime=12.0, Float:fadeintime=0.1, Float:fadeouttime=0.2, channel=4, msg[], any:... )
{
	new arg_num = numargs()
	new arg_langid[16], arg_langcount

	for ( new i = 12; i < arg_num; i++ )
		if ( getarg ( i ) == AUTO_LANG )
			arg_langid[arg_langcount++] = i

	new players[32], num
	get_players ( players, num )

	if ( id )
	{
		players[0] = id
		num = 1
	}

	else
		get_players ( players, num )

	set_hudmessage ( red, green, blue, x, y, effects, fxtime, holdtime, fadeintime, fadeouttime, channel )

	new message[192]

	for ( new i = 0; i < num; i++ )
	{
		if ( !is_user_connected ( players[i] ) ) continue

		for ( new j = 0; j < arg_langcount; j++ )
			setarg ( arg_langid[j], 0, players[i] )

		vformat ( message, sizeof ( message ) - 1, msg, 14 )
		format_color (message, sizeof ( message ) - 1, 0 )

		switch ( channel )
		{
			case 3:
				ShowSyncHudMsg ( players[i], g_hudSyncChannel_3, message )
	
			case 4:
				ShowSyncHudMsg ( players[i], g_hudSyncChannel_4, message )
	
			case 5:
				ShowSyncHudMsg ( players[i], g_hudSyncChannel_5, message )

			default:
				ShowSyncHudMsg ( players[i], g_hudSyncChannel_3, message )
		}
	}

	for ( new i = 0; i < arg_langcount; i++ )
		setarg ( arg_langid[i], 0, AUTO_LANG )

	return 1
}

say_message ( id, log, msg[], any:... )
{
	new arg_num = numargs()
	new arg_langid[16], arg_langcount

	for ( new i = 3; i < arg_num; i++ )
		if ( getarg ( i ) == AUTO_LANG )
			arg_langid[arg_langcount++] = i

	new players[32], num

	if ( id )
	{
		players[0] = id
		num = 1
	}

	else
		get_players ( players, num )

	new message[192], string[192]

	new colored_messages = get_pcvar_num ( pcv_colored_messages )

	for ( new i = 0; i < num; i++ )
	{
		if ( !is_user_connected ( players[i] ) ) continue

		for ( new j = 0; j < arg_langcount; j++ )
			setarg ( arg_langid[j], 0, players[i] )

		vformat ( string, sizeof ( string ) - 1, msg, 4 )
		format_color (string, sizeof ( string ) - 1, colored_messages )
		formatex ( message, sizeof ( message ) - 1, "^x01%s", string )

		message_begin ( MSG_ONE, g_msgSayText, _, players[i] )
		write_byte ( players[i] )
		write_string ( message )
		message_end ( )
	}

	for ( new i = 0; i < arg_langcount; i++ )
		setarg ( arg_langid[i], 0, LANG_SERVER )

	vformat ( string, sizeof ( string ) - 1, msg, 4 )
	format_color ( string, sizeof ( string ) - 1, 0 )

	if ( log )
		log_amx ( string )

	else if ( !id )
		server_print ( string )

	for ( new i = 0; i < arg_langcount; i++ )
		setarg ( arg_langid[i], 0, AUTO_LANG )

	return 1
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

public clients_freeze ( )
{
	if ( !g_maxspeedRepare )
	{
		g_maxspeed = get_pcvar_num ( pcv_sv_maxspeed )
		g_maxspeedRepare = true
	}

	set_pcvar_num ( pcv_sv_maxspeed, 0 )
}

public get_admin_level_flag()
{
	new flags[24]

	get_pcvar_string ( pcv_admin_level, flags, sizeof ( flags ) - 1 )

	return ( read_flags ( flags ) )
}

bool:isextend()
{
	new winlimit	= get_pcvar_num ( pcv_mp_winlimit )
	new maxrounds	= get_pcvar_num ( pcv_mp_maxrounds )

	if	( !winlimit )
	{
		if ( maxrounds )
		{
			if ( maxrounds < get_pcvar_num ( pcv_extend_maxrounds_max ) )
			{
				return true
			}
		}

		else if ( ( get_pcvar_float ( pcv_mp_timelimit ) - g_addtime ) < get_pcvar_float ( pcv_extend_timelimit_max ) )
		{
			return true
		}
	}

	return false
}

bool:islastmap ( map[] )
{
	for ( new i = 0; i < g_last_mapcount; ++i )
	{
		if ( equali ( map, g_last_mapname[i] ) )
		{
			return true
		}
	}

	return false
}

public islistmap ( map[] )
{
	for ( new i = 0; i < g_list_mapcount; ++i )
	{
		if ( equali ( map, g_list_mapname[i] ) )
		{
			return i
		}
	}

	return -1
}

bool:isbanned ( map[] )
{
	for ( new i = 0; i < g_ban_mapcount; ++i )
	{
		if ( equali ( map, g_ban_mapname[i] ) )
		{
			return true
		}
	}

	return false
}

bool:isselect ( map[] )
{
	for ( new i = 0; i < g_select_mapcount; ++i )
	{
		if ( equali ( map, g_select_mapname[i] ) )
		{
			return true
		}
	}

	return false
}

bool:isfreeidx()
{
	for ( new i = 0; i < g_idx_mapcount; ++i )
	{
		if ( g_idx_mapname[i] != g_vote_mapcount )
		{
			return true
		}
	}

	return false
}

public iscustomidx ( id )
{
	for ( new i = 0; i < g_custom_mapcount; ++i )
	{
		if ( id == g_custom_userid[i] )
		{
			return i
		}
	}

	return -1
}

public iscustom ( map[] )
{
	for ( new i = 0; i < g_custom_mapcount; ++i )
	{
		if ( equali ( map, g_custom_mapname[i] ) )
		{
			return i
		}
	}

	return -1
}

public iscustomacc()
{
	new access_slot = 0
	new access_level = get_admin_level_flag()

	for ( new i = 0; i < g_custom_mapcount; ++i )
	{
		if ( get_user_flags ( g_custom_userid[i] ) & access_level )
		{
			access_slot++
		}
	}

	return access_slot
}

bool:israting ( id )
{
	for ( new i = 0; i < g_rating_idcount; ++i )
	{
		if ( g_rating_idplayer[i] == id )
		{
			return true
		}
	}

	return false
}

public cmd_block_votemap ( id )
{
	client_cmd ( id, "say /rtv" )

	return PLUGIN_HANDLED
}

public remove_sign ( map[] )
{
	remove_quotes ( map )
	strtolower( map )

	while ( replace ( map, LEN_MAPNAME, "/", "" ) ) {}
	while ( replace ( map, LEN_MAPNAME, "\", "" ) ) {}
	while ( replace ( map, LEN_MAPNAME, ":", "" ) ) {}
	while ( replace ( map, LEN_MAPNAME, "*", "" ) ) {}
	while ( replace ( map, LEN_MAPNAME, "?", "" ) ) {}
	while ( replace ( map, LEN_MAPNAME, ">", "" ) ) {}
	while ( replace ( map, LEN_MAPNAME, "<", "" ) ) {}
	while ( replace ( map, LEN_MAPNAME, "|", "" ) ) {}
	while ( replace ( map, LEN_MAPNAME, ".", "" ) ) {}
}

check_cvar_num ( var, min, max )
{
	new value = var

	if ( value < min )
		value = min

	else if ( value > max )
		value = max

	return 	value
}

public client_connect ( id )
{
	g_votemap_idplayer[id] = false
	g_maplist_lastidx[id] = 0

	return PLUGIN_CONTINUE
}

public client_disconnect ( id )
{
	g_votemap_idplayer[id] = false
	g_maplist_lastidx[id] = 0

	return PLUGIN_CONTINUE
}

public plugin_end ( )
{
	if ( task_exists ( TASK_ID_VOTE_TIMER ) )
		remove_task ( TASK_ID_VOTE_TIMER )

	if ( task_exists ( TASK_ID_LAST_ROUND ) )
		remove_task ( TASK_ID_LAST_ROUND )

	if ( g_timelimitRepare )
		set_pcvar_float ( pcv_mp_timelimit, g_timelimit )

	if ( g_freezetimeRepare )
		set_pcvar_num ( pcv_mp_freezetime, g_freezetime )

	if ( g_winlimitRepare )
		set_pcvar_num ( pcv_mp_winlimit, g_winlimit )

	if ( g_maxroundsRepare )
		set_pcvar_num ( pcv_mp_maxrounds, g_maxrounds )

	if ( g_maxspeedRepare )
		set_pcvar_num ( pcv_sv_maxspeed, g_maxspeed )
}

public plugin_precache()
{
	precache_sound("server_2/vote_start.wav");
	precache_sound("server_2/vote_end.wav");
	precache_sound("server_2/repeat.wav");
	precache_sound("server_2/prevote.wav");
	precache_sound("server_2/eight.wav");
	precache_sound("server_2/five.wav");
	precache_sound("server_2/four.wav");
	precache_sound("server_2/seven.wav");
	precache_sound("server_2/six.wav");
	precache_sound("server_2/ten.wav");
	precache_sound("server_2/three.wav");
	precache_sound("server_2/two.wav");
	precache_sound("server_2/nine.wav");
	precache_sound("server_2/one.wav");
}