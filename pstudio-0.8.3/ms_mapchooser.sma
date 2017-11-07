#include <amxmodx>
#include <amxmisc>
#include <dhudmessage>

#define PLUGIN "Голосование за смену карты"
#define VERSION "1.0"
#define AUTHOR "WAW555"

#define MAX_PLAYERS 33
#define MAX_MAPNAME_LEN	31
#define LAST_MAPS		128

#define MENU_KEYS (1<<0 | 1<<1 | 1<<2 | 1<<3 | 1<<4 | 1<<5 | 1<<6 | 1<<7 | 1<<8 | 1<<9)
#define MENU_SLOTS 8

new g_last_mapcount //Счетчик последних карт
new g_last_mapname[LAST_MAPS][MAX_MAPNAME_LEN + 1] //Названия последних карт
new pcv_lastmaps //Квар последних карт

new g_configsdir[64] //Дирректория для файла с последними картами

new g_currentMap[MAX_MAPNAME_LEN+1]; //Переменная содержит название текущей карты.

new g_iMenuPage[1024]; // Меню смены карт
new g_iVotedPlayers[256]; //Переменная хранит в себе, какой игрок учавствовал в голосовании
new g_iVotes[256]; // Переменная хранит в себе список голосов за каждую карту.

new g_iPlayers[MAX_PLAYERS - 1]; 
new g_iNum; // Колличество игроков

new Array:g_mapName; // Массив с названиями карт
new g_mapNums; // Количество карт

new g_iMsgidSayText; // Функция цветного чата
new g_iMapChangelevel[32]; // Переменная хранит в себе название следующей карты.
new bool:g_changemap = false; // Переменная указывает, разрешено ли менять карту
new bool:g_changemap_full = false; // Переменная указывает, разрешено ли менять карту
new bool:g_votemap = true; // Переменная указывает разрешено ли голосовать

new g_szLogFile[64]; // Файл логов

new g_iCountRound //Счетчик раундов

public plugin_init() {
	
	register_plugin(PLUGIN, VERSION, AUTHOR); //Регистрируем плагин
	register_dictionary("votemap.txt"); // Регистрируем словарь
	register_saycmd("votemap", "Cmd_VoteMap", -1, ""); //Комманда вызова меню для смены карты
	register_saycmd("rtv", "Cmd_VoteMap", -1, ""); //Комманда вызова меню для смены карты
	register_saycmd("nominate", "Cmd_VoteMap", -1, ""); //Комманда вызова меню для смены карты
	register_saycmd("rockthevote", "Cmd_VoteMap", -1, ""); //Комманда вызова меню для смены карты
	register_saycmd("nextmap", "Cmd_VoteMap", -1, ""); //Комманда вызова меню для смены карты
	register_saycmd("map", "Cmd_VoteMap", -1, ""); //Комманда вызова меню для смены карты
	register_saycmd("maps", "Cmd_VoteMap", -1, ""); //Комманда вызова меню для смены карты
	register_saycmd("currentmap", "Cmd_VoteMap", -1, ""); //Комманда вызова меню для смены карты
	register_saycmd("nom", "Cmd_VoteMap", -1, ""); //Комманда вызова меню для смены карты
	pcv_lastmaps = register_cvar ( "ms_lastmaps","7" )
	register_concmd("votemapmenu", "ShowMapMenu", ADMIN_CFG)
	
	get_configsdir ( g_configsdir, sizeof ( g_configsdir ) - 1 )
	
	register_logevent("Event_Round_Start", 2, "0=World triggered", "1=Round_Start"); // Событие Начало раунда
	register_event("SendAudio", "Event_Round_End", "a", "2&%!MRAD_terwin", "2&%!MRAD_ctwin", "2&%!MRAD_rounddraw"); //Событие Конец Раунда
	
	register_menucmd(register_menuid("Map Menu"), MENU_KEYS, "Menu_VoteMap"); // Регистрируем меню смены карты

	g_iMsgidSayText = get_user_msgid("SayText"); //Функция цветного чата
	
	new szLogInfo[] = "amx_logdir"; // Записываем в переменную путь к папке с логами
	get_localinfo(szLogInfo, g_szLogFile, charsmax(g_szLogFile)); //Проверяем на наличие файлов
	add(g_szLogFile, charsmax(g_szLogFile), "/votemap");// Добавляем файл в папку votemap
	
	if(!dir_exists(g_szLogFile)) // проверяем если папка votemap не существует, до создаем ее
		mkdir(g_szLogFile); // создаем папку votemap
		
	new szTime[32]; //Массив времени
	get_time("%d-%m-%Y", szTime, charsmax(szTime)); //Получаем время
	format(g_szLogFile, charsmax(g_szLogFile), "%s/%s.log", g_szLogFile, szTime); //Создаем файл с логами и добавляем текущее время в название файла 
	
	g_mapName=ArrayCreate(128); //Создаем массив с картами
	
	new maps_ini_file[64]; //Создаем переменную для путей к файлам со списком карт
	get_configsdir(maps_ini_file, 63); // Получаем дирректорию с настройками
	format(maps_ini_file, 63, "%s/maps.ini", maps_ini_file);// Получаем путь к файлу

	if (!file_exists(maps_ini_file)) //Проверяем наличие файла
		get_cvar_string("mapcyclefile", maps_ini_file, sizeof(maps_ini_file) - 1); // Если файл существует ищем путь к файлу mapcycle.txt
		
	if (!file_exists(maps_ini_file)) //Проверяем на наличие файла
		format(maps_ini_file, 63, "mapcycle.txt") //Если файл найден записываем его в путь
	
	load_settings(maps_ini_file) // Загружаем карты из имеющихся списков
	

}
//Настрока плагина
public plugin_cfg()
{
	get_mapname(g_currentMap, sizeof(g_currentMap)-1) // Получаем название текущей карты
	server_cmd("mp_timelimit 0") //Меняем время карты на 0
	set_task ( 1.0, "cmd_get_lastmaps" ) //Получаем список сыгранных карт
	set_task ( 1.1, "cmd_put_lastmaps" ) //Записываем список сыгранных карт
}
//Отключение игрока
public client_disconnect(id)
{
	if(g_iVotedPlayers[id]) // Если игрок учавствовал в голосовании продолжаем
	{
		get_players(g_iPlayers, g_iNum, "ch") //Получаем количество игроков без HLTV и без ботов
		for(new i = 0 ; i < g_iNum ; i++) // Ищем за что голосовал игрок
		{
			if(g_iVotedPlayers[id] & (1 << g_iPlayers[i])) // Находим все голоса игрока
			{
				g_iVotes[g_iPlayers[i]]-- //Удаляем все голоса данного игрока
			}
		}
		g_iVotedPlayers[id] = 0 // Сбрасываем участие игрока в голосовании на 0
	}
}
//Подключение игрока
public client_authorized(id)
{
	if(g_iVotedPlayers[id]) // Если игрок учавствовал в голосовании продолжаем
	{
		get_players(g_iPlayers, g_iNum, "ch") //Получаем количество игроков без HLTV и без ботов
		for(new i = 0 ; i < g_iNum ; i++) // Ищем за что голосовал игрок
		{
			if(g_iVotedPlayers[id] & (1 << g_iPlayers[i])) // Находим все голоса игрока
			{
				g_iVotes[g_iPlayers[i]]-- //Удаляем все голоса данного игрока
			}
		}
		g_iVotedPlayers[id] = 0 // Сбрасываем участие игрока в голосовании на 0
	}
}	

public Cmd_VoteMap(id)
{	
	new i_PlayersNum = get_playersnum() //Получаем количество игроков
	new i_CountRound = 0

	switch(i_PlayersNum){
		case 0..5:{
			i_CountRound = 5
		}
		case 6..20: {
			i_CountRound = 10
		}
		default: {
			i_CountRound = 15
		}
	}
	new n_round = i_CountRound - g_iCountRound  //Получаем количество оставшихся раундов
	if(g_votemap) // Проверяем Если голосование разрешено
	{
		if(g_iCountRound <= i_CountRound){ //Проверяем количество сигранных раундов
					client_printc(id, "\g%L \d%L \t%d \d%L",id, "VOTEMAP_ATTENTION", id, "VOTEMAP_BEFORE_CHANGINGS_MAPS", n_round, id, "VOTEMAP_ROUNDS");
					client_cmd(id, "spk sound/events/friend_died.wav");
		}else{ //Если голосование разрешено и количество раундов сыграно
			ShowMapMenu(id, g_iMenuPage[id] = 0); // Показываем меню с картами
		}
	}else{ //Если голосование запрещено выводим предупреждение
		client_printc(id, "\g%L \d%L %L \g%s",id, "VOTEMAP_ATTENTION", id, "VOTEMAP_VOTING_IS_COMPLETED", id, "VOTEMAP_NEXT_MAP",  g_iMapChangelevel);
		client_cmd(id, "spk sound/events/friend_died.wav");
	}
}

public ShowMapMenu(id, iPos)
{
	static i
	static szMenu[1024] // Создаем меню
	new iCurrPos = 0
	static iStart, iEnd; iStart = iPos * MENU_SLOTS
	static iKeys
	new tempMap[32]
	
	get_players(g_iPlayers, g_iNum, "сh");
	
	if(iStart >= g_mapNums)
	{
		iStart = iPos = g_iMenuPage[id] = 0;
	}
	
	static iLen;
	iLen = formatex(szMenu, charsmax(szMenu), "\r%L^n\y%L \r%s^n^n",id, "VOTEMAP_MENU", id, "VOTEMAP_CURRENT", g_currentMap);
	
	iEnd = iStart + MENU_SLOTS;
	iKeys = MENU_KEY_0;
	
	if(iEnd > g_mapNums)
	{
		iEnd = g_mapNums;
	}
	
	for(i = iStart ; i < iEnd ; ++i)
	{
		iKeys |= (1 << iCurrPos);
		ArrayGetString(g_mapName, i, tempMap, charsmax(tempMap));
		if(equal(g_currentMap, tempMap))
		{
			//iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r%d. \y %s \y(%L)^n", ++iCurrPos, tempMap, id, "VOTEMAP_CURRENT");
		} else if (islastmap (tempMap)){
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r%d. \y %s \y(%L)^n", ++iCurrPos, tempMap, id, "VOTEMAP_LAST_MAP");
		}else{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r%d. \w %s \d(\r%d%%\d)^n", ++iCurrPos, tempMap, get_percent(g_iVotes[i], g_iNum));
		}
	}
	
	if(iEnd != g_mapNums)
	{
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r9. \w%L ^n\r0. \w%L", id, "VOTEMAP_MORE",id, iPos ? "VOTEMAP_BACK" : "VOTEMAP_EXIT");
		iKeys |= MENU_KEY_9;
	}
	else
	{
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r0. \w%L",id, iPos ? "VOTEMAP_BACK" : "VOTEMAP_EXIT");
	}
	show_menu(id, iKeys, szMenu, -1, "Map Menu");
	return PLUGIN_HANDLED;
}

public Menu_VoteMap(id, key)
{
	switch(key)
	{
		case 8:
		{
			ShowMapMenu(id, ++g_iMenuPage[id]);
			client_cmd(id, "spk sound/events/tutor_msg.wav");
		}
		case 9:
		{
			if(!g_iMenuPage[id])
				return PLUGIN_HANDLED;
			
			ShowMapMenu(id, --g_iMenuPage[id]);
			client_cmd(id, "spk sound/events/tutor_msg.wav");
		}
		default: {
			new a = g_iMenuPage[id] * MENU_SLOTS + key
			
			new tempMap[32];
			ArrayGetString(g_mapName, a, tempMap, charsmax(tempMap));

			if(equal(g_currentMap, tempMap))
			{
				set_dhudmessage(255, 0, 0, 0.02, 0.15, 0, 6.0, 10.0);
				show_dhudmessage(id, "%L", id, "VOTEMAP_ERROR_CURRENT_MAP");
				ShowMapMenu(id, g_iMenuPage[id]);
				client_cmd(id, "spk sound/events/friend_died.wav");
				
				return PLUGIN_HANDLED;
			}
			
			if (islastmap (tempMap)){
				set_dhudmessage(255, 0, 0, 0.02, 0.15, 0, 6.0, 10.0);
				show_dhudmessage(id, "%L",id, "VOTEMAP_THIS_LAST_MAP");
				ShowMapMenu(id, g_iMenuPage[id]);
				client_cmd(id, "spk sound/events/friend_died.wav");
				
				return PLUGIN_HANDLED;
			}
			
			
			if(g_iVotedPlayers[id] & (1 << a))
			{
				set_dhudmessage(255, 0, 0, 0.02, 0.15, 0, 6.0, 10.0);
				show_dhudmessage(id, "%L", id, "VOTEMAP_ERROR_NOMINATE_MAP");
				ShowMapMenu(id, g_iMenuPage[id]);
				client_cmd(id, "spk sound/events/friend_died.wav");
				
				return PLUGIN_HANDLED;
			}
			
			
			
			if(g_changemap){
				client_printc(id, "\g%L \d%L %L \g%s",id, "VOTEMAP_ATTENTION", id, "VOTEMAP_VOTING_IS_COMPLETED", id, "VOTEMAP_NEXT_MAP",  g_iMapChangelevel);
				client_cmd(id, "spk sound/events/friend_died.wav");
			} else {
			
			g_iVotes[a]++;
			g_iVotedPlayers[id] |= (1 << a);
			
			static szName[1][32];
			get_user_name(id, szName[0], charsmax(szName[]));
			new players[32], pnum
			new percent;
			get_players(players, pnum, "ch")
			new i
			
			switch (pnum){
				case 1:{
					percent = 60;
				}
				case 2..5:{
					percent = 55;
		
				}
				case 6..10:{
					percent = 50;
		
				}
				case 11..15:{
					percent = 45;
		
				}
				case 16..20:{
					percent = 40;
		
				}
				case 21..25:{
					percent = 35;
		
				}
				case 26..30:{
					percent = 30;
		
				}
				case 31..32:{
					percent = 25;
		
				}
				default:{
					percent = 60;
				}
			}
				
				
	
			for (i = 0; i < pnum; i++)
			{
			client_printc(players[i], "\g%L \d%L \t%s \d%L \t%s\d (\g%d%% %L %d%%%\d)",players[i], "VOTEMAP_ATTENTION",players[i], "VOTEMAP_PLAYER", szName[0],players[i], "VOTEMAP_VOTED_CHANGE_MAP", tempMap,get_percent(g_iVotes[a], g_iNum),players[i], "VOTEMAP_OF",percent);
			}
			client_cmd(id, "spk sound/events/tutor_msg.wav");
			log_to_file(g_szLogFile, "Игрок '%s' проголосовал за смену карты на '%s'", szName[0], tempMap);//Добавлена строка 13.07.11
			CheckVotes(a, id);
			
			}
				
		}
	}
	return PLUGIN_HANDLED;
}

public CheckVotes(id, voter)
{
	
	new tempMap[32];
	ArrayGetString(g_mapName, id, tempMap, charsmax(tempMap));
	
	get_players(g_iPlayers, g_iNum, "ch");
	new iPercent = get_percent(g_iVotes[id], g_iNum);
	new percent;
	
	switch (g_iNum){
		case 1:{
			percent = 60;
		}
		case 2..5:{
			percent = 55;

		}
		case 6..10:{
			percent = 50;

		}
		case 11..15:{
			percent = 45;

		}
		case 16..20:{
			percent = 40;

		}
		case 21..25:{
			percent = 35;

		}
		case 26..30:{
			percent = 30;

		}
		case 31..32:{
			percent = 25;

		}
		default:{
			percent = 60;
		}
	}

	
	if (iPercent >= percent)
	{
		g_iMapChangelevel = tempMap;
		g_changemap = true;
		g_votemap = false;
		new szName[32];
		get_user_name(voter, szName, charsmax(szName));
		new players[32], pnum
		get_players(players, pnum, "c")
		new i
	
		for (i = 0; i < pnum; i++)
		{
			client_printc(players[i], "\g%L \d%L \t%s \d%L \g%s",players[i], "VOTEMAP_ATTENTION",players[i], "VOTEMAP_PLAYER", szName, players[i], "VOTEMAP_PLAYER_VOTING_IS_COMPLETED", g_iMapChangelevel);
		}

	}
}

stock get_percent(value, tvalue)
{     
	return floatround(floatmul(float(value) / float(tvalue) , 100.0));
}

stock register_saycmd(saycommand[], function[], flags = -1, info[])
{
	static szTemp[64];
	formatex(szTemp, charsmax(szTemp), "say %s", saycommand);
	register_clcmd(szTemp, function, flags, info);
	formatex(szTemp, charsmax(szTemp), "say_team %s", saycommand);
	register_clcmd(szTemp, function, flags, info);
	formatex(szTemp, charsmax(szTemp), "say /%s", saycommand);
	register_clcmd(szTemp, function, flags, info);
	formatex(szTemp, charsmax(szTemp), "say .%s", saycommand);
	register_clcmd(szTemp, function, flags, info);
	formatex(szTemp, charsmax(szTemp), "say_team /%s", saycommand);
	register_clcmd(szTemp, function, flags, info);
	formatex(szTemp, charsmax(szTemp), "say_team .%s", saycommand);
	register_clcmd(szTemp, function, flags, info);
}

stock client_printc(id, const text[], any:...)
{
	
	new szMsg[191], iPlayers[32], iCount = 1;
	vformat(szMsg, charsmax(szMsg), text, 3);
	
	replace_all(szMsg, charsmax(szMsg), "\g","^x04");
	replace_all(szMsg, charsmax(szMsg), "\d","^x01");
	replace_all(szMsg, charsmax(szMsg), "\t","^x03");
	
	if(id)
		iPlayers[0] = id;
	else
		get_players(iPlayers, iCount, "ch");
	
	for(new i = 0 ; i < iCount ; i++)
	{
		if(!is_user_connected(iPlayers[i]))
			continue;
		
		message_begin(MSG_ONE_UNRELIABLE, g_iMsgidSayText, _, iPlayers[i]);
		write_byte(iPlayers[i]);
		write_string(szMsg);
		message_end();
	}
}

public plugin_precache()
{
	precache_sound("events/friend_died.wav");
	precache_sound("events/tutor_msg.wav");
}


stock bool:ValidMap(mapname[])
{
	if ( is_map_valid(mapname) )
	{
		return true;
	}
	// If the is_map_valid check failed, check the end of the string
	new len = strlen(mapname) - 4;
	
	// The mapname was too short to possibly house the .bsp extension
	if (len < 0)
	{
		return false;
	}
	if ( equali(mapname[len], ".bsp") )
	{
		// If the ending was .bsp, then cut it off.
		// the string is byref'ed, so this copies back to the loaded text.
		mapname[len] = '^0';
		
		// recheck
		if ( is_map_valid(mapname) )
		{
			return true;
		}
	}
	
	return false;
}

load_settings(filename[])
{
	new fp = fopen(filename, "r");
	
	if (!fp)
	{
		return 0;
	}
		

	new text[256];
	new tempMap[32];
	
	while (!feof(fp))
	{
		fgets(fp, text, charsmax(text));
		
		if (text[0] == ';')
		{
			continue;
		}
		if (parse(text, tempMap, charsmax(tempMap)) < 1)
		{
			continue;
		}
		if (!ValidMap(tempMap))
		{
			continue;
		}
		
		ArrayPushString(g_mapName, tempMap);
		g_mapNums++;
	}

	fclose(fp);

	return 1;
}

public Event_Round_Start() {
	
	g_iCountRound++;

	if (g_changemap && g_changemap_full)
	{
		g_changemap_full = false;
		server_cmd("changelevel %s", g_iMapChangelevel)
	}
        return PLUGIN_CONTINUE;
}

public Event_Round_End(){
	
	if (g_changemap)
	{
		set_task(10.0, "change_level_message");
	}
	
}

public change_level_message (){
	
	g_changemap_full = true;
	
	new players[32], pnum
	get_players(players, pnum, "c")
	new i
	
	for (i = 0; i < pnum; i++)
	{
		set_dhudmessage(255, 0, 0, -1.0, 0.17, 0, 6.0, 1800.0);
		show_dhudmessage(players[i], "%L", players[i], "VOTEMAP_LAST_ROUND");
		
		set_dhudmessage(0, 255, 0, -1.0, 0.14, 0, 6.0, 1800.0);
		show_dhudmessage(players[i], "%L %s", players[i], "VOTEMAP_NEXT_MAP", g_iMapChangelevel);
	}
}

public cmd_get_lastmaps ( )
{
	new lastmaps = get_pcvar_num ( pcv_lastmaps )

	if (lastmaps > LAST_MAPS)
	{
		lastmaps = LAST_MAPS
	}

	get_mapname ( g_last_mapname[0], MAX_MAPNAME_LEN)

	new filename[128], string[32], pos, len

	formatex ( filename, sizeof ( filename ) - 1, "%s/ms_config/ms_maplast.ini", g_configsdir )

	g_last_mapcount = 1

	if ( file_exists ( filename ) )
	{
		while ( ( g_last_mapcount < lastmaps ) && read_file ( filename, pos++, string, sizeof ( string ) - 1, len ) )
		{
			if ( ( string[0] != ';' ) && parse ( string, g_last_mapname[g_last_mapcount], MAX_MAPNAME_LEN ) && is_map_valid ( g_last_mapname[g_last_mapcount] ) )
			{
				g_last_mapcount++
			}
		}
	}

	else
	{
		log_to_file(g_szLogFile, "Файл %s не найден. Плагин создаст файл автоматически.", filename )
	
		return 0
	}

	return 1
}

public cmd_put_lastmaps ( )
{
	new filename[128]
	formatex ( filename, sizeof ( filename ) - 1, "%s/ms_config/ms_maplast.ini", g_configsdir )

	if ( !delete_file ( filename ) )
	{
		log_to_file(g_szLogFile, "Невозможно удалить файл %s", filename )
	}

	if ( !write_file ( filename, "; Данный файл создается и изменяется автоматически, не изменяйте его!" ) )
	{
		log_to_file(g_szLogFile, "Невозможна запись в файл %s", filename )
	
		return 0
	}

	else
	{
		for ( new i = 0; i < g_last_mapcount; ++i )
			write_file ( filename, g_last_mapname[i] )
	}

	return 1
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