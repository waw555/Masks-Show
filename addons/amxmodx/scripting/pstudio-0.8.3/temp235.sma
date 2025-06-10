#include <amxmodx>
#include <amxmisc>

#define PLUGIN "Nextmap Chooser"
#define VERSION "1.0.0/05.06.2025"
#define AUTHOR "AMXX Dev Team"

#define MAX_MAPS 128
#define MAXPLAYERS 33
//Меню
#define MENU_SIZE 1024
#define MENU_KEYS (1<<0 | 1<<1 | 1<<2 | 1<<3 | 1<<4 | 1<<5 | 1<<6 | 1<<7 | 1<<8 | 1<<9)
#define MENU_SLOTS 8 								//	Количество слотов под карты
//Название карты и статус
new MAPS_NAME[MAX_MAPS][MAX_MAPS];					//	Название всех карт
new NOMINATION_MAPS_NAME[MAX_MAPS][MAX_MAPS];		//	Карты для номинированя
new LAST_MAPS_NAME[MAX_MAPS][MAX_MAPS];				//	Последние карты
new NEXT_MAP_NAME[MAX_MAPS]; 						// 	Переменная хранит в себе название следующей карты.
//Файлы
new g_s_MapFile[128]; 								//	Файл с картами
new g_s_LastMapFile[128]; 							//	Файл с последними картами
//Счетчик
new g_i_MapCounter 									//	Счетчик карт
new g_i_LastMapCounter 								//	Счетчик последних карт
new g_i_NominateMapCounter = 0
new g_i_MenuPosition[33] 							//	Счетчик позиции меню игрока
new g_i_VotedPlayers[MAXPLAYERS]; 					//	Переменная хранит в себе, какой игрок учавствовал в голосовании
new g_i_Votes[MAXPLAYERS]; 							// 	Переменная хранит в себе список голосов за каждую карту.
new g_i_Num; 										// 	Колличество игроков
new g_i_Players[MAXPLAYERS - 1]
new g_i_MessageIDSayText; 							// 	Функция цветного чата
//Настройки
new g_i_pcvar_LastMaps 								//	Количество последних карт
new g_i_pcvar_TimeOutNominate 						// 	Квар теймера отложенной номинации
//Включение выключение функций
new bool:g_b_changemap = false; 					// 	Переменная указывает, разрешено ли менять карту
new bool:g_b_changemap_full = false; 				// 	Переменная указывает, разрешено ли менять карту
new bool:g_b_votemap = true; 						// 	Переменная указывает разрешено ли голосовать
//Время игры на карте
new Float: g_f_MapTimer 							//	Счетчик минут

new g_szLogDir[64]; 								// 	Папка с логами
new g_szLogFile[64]; 								// 	Файл логов

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);
	//Регистрируем команды
	register_dictionary("ms_mapchooser.txt"); 										//	Регистрируем словарь
	register_dictionary("ms_global.txt"); 											//	Регистрируем словарь
	g_i_pcvar_LastMaps = register_cvar ( "ms_lastmaps","7" );						//	Регистрируем cvar ms_lastmaps
	g_i_pcvar_TimeOutNominate = register_cvar ( "ms_timeout_nominate","3" );		//	Регистрируем cvar ms_timeout_nominate
	register_saycmd("votemap", "Cmd_Vote_Map", -1, ""); 							//	Комманда вызова меню для смены карты
	register_saycmd("rtv", "Cmd_Vote_Map", -1, ""); 								//	Комманда вызова меню для смены карты
	register_saycmd("nominate", "Cmd_Vote_Map", -1, ""); 							//	Комманда вызова меню для номинации карты
	register_saycmd("rockthevote", "Cmd_Vote_Map", -1, ""); 						//	Комманда вызова меню для смены карты
	register_saycmd("nextmap", "Cmd_Vote_Map", -1, ""); 							//	Комманда для отображения следующей карты
	register_saycmd("map", "Cmd_Vote_Map", -1, ""); 								//	Комманда для отображения текущей карты
	register_saycmd("maps", "Cmd_Vote_Map", -1, ""); 								//	Комманда для отображения всех карты из файла ms_maps.ini
	register_saycmd("currentmap", "Cmd_Vote_Map", -1, ""); 							//	Комманда для отображения текущей карты
	register_saycmd("nom", "Cmd_Vote_Map", -1, ""); 								//	Комманда вызова меню для номинации карты
	
	register_logevent("Event_Round_Start", 2, "0=World triggered", "1=Round_Start"); //	Событие Начало раунда
	register_event("SendAudio", "Event_Round_End", "a", "2&%!MRAD_terwin", "2&%!MRAD_ctwin", "2&%!MRAD_rounddraw");	//	Событие Конец Раунда
	register_event ( "TextMsg","event_restart_game","a", "2=#Game_Commencing","2=#Game_will_restart_in" );
	
	register_menu("Vote Map Menu", MENU_KEYS, "Maps_Menu_Command");					//	Создаем меню
	
	g_i_MessageIDSayText = get_user_msgid("SayText");								//	Функция цветного чата

	
	new szLogInfo[] = "amx_logdir";													//	Записываем в переменную путь к папке с логами
	get_localinfo(szLogInfo, g_szLogDir, charsmax(g_szLogDir));					//	Проверяем на наличие файлов
	add(g_szLogDir, charsmax(g_szLogDir), "/ms_mapchooser");						//	Добавляем файл в папку ms_mapchooser
	
	if(!dir_exists(g_szLogDir))													//	Проверяем если папка ms_mapchooser не существует, до создаем ее
		mkdir(g_szLogDir);															//	Создаем папку ms_mapchooser
	
	new szTime[32];																	//	Массив времени
	get_time("%d-%m-%Y", szTime, charsmax(szTime));									//	Получаем время
	format(g_szLogDir, charsmax(g_szLogDir), "%s/%s.log", g_szLogDir, szTime);	//	Создаем файл с логами и добавляем текущее время в название файла 
	//Создаем путь к файлу с картами
	new s_TempConfigDir[64];														//	Создаем переменную для путей к файлам со списком карт
	get_configsdir(s_TempConfigDir, 63);											//	Получаем дирректорию с настройками
	format(g_s_MapFile, 63, "%s/ms_config/ms_maps.ini", s_TempConfigDir);			//	Получаем путь к файлу с картами
	format(g_s_LastMapFile, 63, "%s/ms_config/ms_lastmaps.ini", s_TempConfigDir);	//	Получаем путь к файлу с последними картами
	Load_Maps();
}

public plugin_cfg()
{
	server_cmd("mp_timelimit 0");													//	Меняем время карты на 0
	
}

public Cmd_Vote_Map(id)
{	
	if(g_b_votemap) // Проверяем Если голосование разрешено
	{
		new s_timer = check_disable_nominate();
		if ( s_timer )
		{
			client_printc(id, "\g%L \d%L \t%d:%d \d%L",id, "MS_ATTENTION", id, "VOTEMAP_BEFORE_CHANGINGS_MAPS", s_timer / 60, s_timer % 60, id, "VOTEMAP_MIN" );
			client_cmd(id, "spk sound/events/friend_died.wav");
		}else{
			Vote_Map_Menu(id, g_i_MenuPosition[id] = 0); // Показываем меню с картами
		}
	}else{
		client_printc(id, "\g%L \d%L %L \g%s",id, "MS_ATTENTION", id, "VOTEMAP_VOTING_IS_COMPLETED", id, "VOTEMAP_NEXT_MAP",  NEXT_MAP_NAME);
		client_cmd(id, "spk sound/events/friend_died.wav");
	}
}

//Создаем меню с картами
public Vote_Map_Menu(id, i_Pos)
{
	if (i_Pos < 0)
		return
	
	client_cmd(id, "spk sound/events/tutor_msg.wav");
	new s_Menu[MENU_SIZE + 1]; //Размер меню
	new i_CurrPos = 0; //Текущая позиция в списке меню
	new i_Start = i_Pos * MENU_SLOTS;
	new i_Keys;
	new i_Len;
	//new s_Color[] = "\w"
	
	get_players(g_i_Players, g_i_Num, "сh");
	
	i_Len = formatex(s_Menu, MENU_SIZE, "\r%L^n\y%s^n^n\w%L^n^n",id,"VOTEMAP_CURRENT", LAST_MAPS_NAME[0], id, "VOTEMAP_MENU")
	
	if(i_Start >= g_i_NominateMapCounter)
	{
		i_Start = i_Pos = g_i_MenuPosition[id] = 0
	}
	
	new i_End = i_Start + MENU_SLOTS
	i_Keys = MENU_KEY_0
	
	if(i_End > g_i_NominateMapCounter)
	{
		i_End = g_i_NominateMapCounter
	}
	
	for(new i_AddMapCount = i_Start; i_AddMapCount < i_End; ++i_AddMapCount)
	{
		
		/*if(g_i_VotedPlayers[id] & (1 << i_AddMapCount))
		{
			s_Color = "\y"
		}else{
			s_Color = "\w"
		}*/
		i_Keys |= (1 << i_CurrPos)
		i_Len += formatex(s_Menu[i_Len], MENU_SIZE - i_Len, "\y%d. \w%s \d(\r%d%%\d)^n", ++i_CurrPos, NOMINATION_MAPS_NAME[i_AddMapCount], get_percent(g_i_Votes[i_AddMapCount], g_i_Num))
	}
	
	if(i_End != g_i_NominateMapCounter)
	{
		i_Len += formatex(s_Menu[i_Len], MENU_SIZE - i_Len, "^n\y9. \w%L ^n\y0. \w%L", id, "MS_MORE",id, i_Pos ? "MS_BACK" : "MS_EXIT");
		i_Keys |= MENU_KEY_9;
	}
	else
	{
		i_Len += formatex(s_Menu[i_Len], MENU_SIZE - i_Len, "^n\y0. \w%L",id, i_Pos ? "MS_BACK" : "MS_EXIT");
	}
	
	i_Len += formatex(s_Menu[i_Len], MENU_SIZE - i_Len, "^n^n\r%L^n", id, "VOTEMAP_LAST_MAPS")
	
	for (new a = 1; a < g_i_LastMapCounter; ++a){
		i_Len += formatex(s_Menu[i_Len], MENU_SIZE - i_Len, "\y%s^n", LAST_MAPS_NAME[a])
	}
	
	show_menu(id, i_Keys, s_Menu, -1, "Vote Map Menu")
}
//Действие с меню
public Maps_Menu_Command(id, key) {
	switch(key)
	{
		case 8:
		{
			Vote_Map_Menu(id, ++g_i_MenuPosition[id]);
			return PLUGIN_HANDLED
		}
		case 9:
		{
			if (!g_i_MenuPosition[id]){
				client_cmd(id, "spk sound/events/tutor_msg.wav")
				return PLUGIN_HANDLED
			}
				
			Vote_Map_Menu(id, --g_i_MenuPosition[id])
		}
		default:
		{
			new i_MapsNum = g_i_MenuPosition[id] * MENU_SLOTS + key
			log_amx ("1. g_i_VotedPlayers[id] = %d, i_MapsNum = %d", g_i_VotedPlayers[id], i_MapsNum )

			if(g_i_VotedPlayers[id] & (1 << i_MapsNum))
			{
				log_amx ("2. g_i_VotedPlayers[id] = %d, i_MapsNum = %d", g_i_VotedPlayers[id], i_MapsNum )

				Vote_Map_Menu(id, g_i_MenuPosition[id]);
				client_cmd(id, "spk sound/events/friend_died.wav");
				return PLUGIN_HANDLED;
			}
			
			if(g_b_changemap){
				client_printc(id, "\g%L \d%L %L \g%s",id, "MS_ATTENTION", id, "VOTEMAP_VOTING_IS_COMPLETED", id, "VOTEMAP_NEXT_MAP",  NEXT_MAP_NAME);
				client_cmd(id, "spk sound/events/friend_died.wav");
			} else {
			client_cmd(id, "spk sound/events/tutor_msg.wav");				
			g_i_Votes[i_MapsNum]++;
			g_i_VotedPlayers[id] |= (1 << i_MapsNum);
			log_amx ("3. g_i_VotedPlayers[id] = %d, i_MapsNum = %d", g_i_VotedPlayers[id], i_MapsNum )

			
			new s_Name[1][32];
			get_user_name(id, s_Name[0], charsmax(s_Name[]));
			new i_Players[32], i_PlayerNum
			new i_Percent;
			get_players(i_Players, i_PlayerNum, "ch")
			new i
			
			switch (i_PlayerNum){
				case 1:{
					i_Percent = 100;
				}
				case 2..5:{
					i_Percent = 55;
		
				}
				case 6..10:{
					i_Percent = 50;
		
				}
				case 11..15:{
					i_Percent = 45;
		
				}
				case 16..20:{
					i_Percent = 40;
		
				}
				case 21..25:{
					i_Percent = 35;
		
				}
				case 26..30:{
					i_Percent = 30;
		
				}
				case 31..32:{
					i_Percent = 25;
		
				}
				default:{
					i_Percent = 100;
				}
			}
				
				
	
			for (i = 0; i < i_PlayerNum; i++)
			{
				client_printc(i_Players[i], "\g%L \t%s \d%L \t%s\d (\g %d%% %L %d%% \d)",i_Players[i], "MS_ATTENTION", s_Name[0],i_Players[i], "VOTEMAP_VOTED_CHANGE_MAP", NOMINATION_MAPS_NAME[i_MapsNum],get_percent(g_i_Votes[i_MapsNum], g_i_Num),i_Players[i], "VOTEMAP_OF",i_Percent);
			}
			client_cmd(id, "spk sound/events/tutor_msg.wav");
			CheckVotes(i_MapsNum, id);
			
			}
		}
	}
	return PLUGIN_HANDLED
}

//Проверяем количество голосов на установленное количество
public CheckVotes(id, voter)
{
	
	get_players(g_i_Players, g_i_Num, "ch")
	new i_Percents = get_percent(g_i_Votes[id], g_i_Num);
	new i_Percent
	
	switch (g_i_Num){
		case 1:{
			i_Percent = 100;
		}
		case 2..5:{
			i_Percent = 55;

		}
		case 6..10:{
			i_Percent = 50;

		}
		case 11..15:{
			i_Percent = 45;

		}
		case 16..20:{
			i_Percent = 40;

		}
		case 21..25:{
			i_Percent = 35;

		}
		case 26..30:{
			i_Percent = 30;

		}
		case 31..32:{
			i_Percent = 25;

		}
		default:{
			i_Percent = 100;
		}
	}

	
	if (i_Percents >= i_Percent)
	{
		NEXT_MAP_NAME = NOMINATION_MAPS_NAME[id]
		g_b_changemap = true;
		g_b_votemap = false;
		new s_Name[32];
		get_user_name(voter, s_Name, charsmax(s_Name));
		new i_Players[32], i_PlayersNum
		get_players(i_Players, i_PlayersNum, "ch")
		new i
	
		for (i = 0; i < i_PlayersNum; i++)
		{
			client_printc(i_Players[i], "\g%L \t%s \d%L \g%s",i_Players[i], "MS_ATTENTION", s_Name, i_Players[i], "VOTEMAP_PLAYER_VOTING_IS_COMPLETED", NEXT_MAP_NAME);
		}

	}
}

//Загружаем список карт из файла
Load_Maps()
{
	
	//Получаем список недавних карт
	
	new i_LastMaps = get_pcvar_num (g_i_pcvar_LastMaps)

	if (i_LastMaps  > MAX_MAPS)
	{
		i_LastMaps  = MAX_MAPS
	}
	
	
	get_mapname(LAST_MAPS_NAME[0], charsmax(LAST_MAPS_NAME[]))
	
	new s_TextData[32], i_Pos, s_Len
	
	g_i_LastMapCounter = 1
	
	if (file_exists(g_s_LastMapFile))
	{
		while ( ( g_i_LastMapCounter < i_LastMaps ) && read_file (g_s_LastMapFile, i_Pos++, s_TextData, sizeof ( s_TextData ) - 1, s_Len ) )
		{
			if ( ( s_TextData[0] != ';') && parse ( s_TextData, LAST_MAPS_NAME[g_i_LastMapCounter], charsmax(LAST_MAPS_NAME[])) && is_map_valid ( LAST_MAPS_NAME[g_i_LastMapCounter] ) )
			{
				g_i_LastMapCounter++
			}
		}
	} else {
		log_amx ( "Файл %s не найден. Плагин создаст файл автоматически.", g_s_LastMapFile)
	}
	
	new b_FileOpen = fopen(g_s_MapFile, "r") // Открываем файл с картами
	
	if (!b_FileOpen)
	{
		return 0;
	}
	
	new s_LineData[128];
	
	while (!feof(b_FileOpen))
	{
		fgets(b_FileOpen, s_LineData, charsmax(s_LineData));
		
		if (s_LineData[0] == ';' || strlen(s_LineData) < 1 || (s_LineData[0] == '/' && s_LineData[1] == '/'))
		{
			continue;
		}
		parse(s_LineData, MAPS_NAME[g_i_MapCounter], 127)
		
		if (Valid_Map(MAPS_NAME[g_i_MapCounter])){
			if (!b_CheckLastMapName(MAPS_NAME[g_i_MapCounter]) && !equali(LAST_MAPS_NAME[0], MAPS_NAME[g_i_MapCounter])){
				NOMINATION_MAPS_NAME[g_i_NominateMapCounter] = MAPS_NAME[g_i_MapCounter]
				g_i_NominateMapCounter++
			}
		}
		g_i_MapCounter++
	}

	fclose(b_FileOpen);
	
	if ( !delete_file ( g_s_LastMapFile) )
	{
		log_amx ( "Невозможно удалить файл %s", g_s_LastMapFile )
	}

	if ( !write_file ( g_s_LastMapFile, "; Данный файл создается и изменяется автоматически, не изменяйте его!" ) )
	{
		log_amx ("Невозможна запись в файл %s", g_s_LastMapFile )
	
		return 0
	}

	else
	{
		for ( new i = 0; i < g_i_LastMapCounter; ++i ){
			write_file ( g_s_LastMapFile, LAST_MAPS_NAME[i] )
		}
	}

	return 1;
}
//Проверяем карту на валидность
stock bool:Valid_Map(s_MapName[])
{
	if ( is_map_valid(s_MapName) )
	{
		return true;
	}
	// If the is_map_valid check failed, check the end of the string
	new s_Len = strlen(s_MapName) - 4;
	
	// The mapname was too short to possibly house the .bsp extension
	if (s_Len < 0)
	{
		return false;
	}
	if ( equali(s_MapName[s_Len], ".bsp") )
	{
		// If the ending was .bsp, then cut it off.
		// the string is byref'ed, so this copies back to the loaded text.
		s_MapName[s_Len] = '^0';
		
		// recheck
		if ( is_map_valid(s_MapName) )
		{
			return true;
		}
	}
	
	return false;
}
//Проверяем карту на наличие в списке недавних карт
bool:b_CheckLastMapName (s_MapName[] )
{
	for ( new i = 0; i < g_i_LastMapCounter; ++i )
	{
		if ( equali (s_MapName, LAST_MAPS_NAME[i] ) )
		{
			return true
		}
	}

	return false
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
		
		message_begin(MSG_ONE_UNRELIABLE, g_i_MessageIDSayText, _, iPlayers[i]);
		write_byte(iPlayers[i]);
		write_string(szMsg);
		message_end();
	}
}
//Получаем процент голосов
stock get_percent(value, tvalue)
{     
	return floatround(floatmul(float(value) / float(tvalue) , 100.0));
}

//Отключение игрока, сброс голосов
public client_disconnected(id)
{
	if(g_i_VotedPlayers[id])// Если игрок учавствовал в голосовании продолжаем
	{
		get_players(g_i_Players, g_i_Num, "ch"); //Получаем количество игроков без HLTV
		
		for(new i = 0 ; i < g_i_Num ; i++) // Ищем за что голосовал игрок
		{
			if(g_i_VotedPlayers[id] & (1 << g_i_Players[i])) // Находим все голоса игрока
			{
				g_i_Votes[g_i_Players[i]]--; //Удаляем все голоса данного игрока
			}
		}
		g_i_VotedPlayers[id] = 0; // Сбрасываем участие игрока в голосовании на 0
	}
}

//Подключение игрока

public client_authorized(id)
{
	if(g_i_VotedPlayers[id])// Если игрок учавствовал в голосовании продолжаем
	{
		get_players(g_i_Players, g_i_Num, "ch"); //Получаем количество игроков без HLTV
		
		for(new i = 0 ; i < g_i_Num ; i++) // Ищем за что голосовал игрок
		{
			if(g_i_VotedPlayers[id] & (1 << g_i_Players[i])) // Находим все голоса игрока
			{
				g_i_Votes[g_i_Players[i]]--; //Удаляем все голоса данного игрока
			}
		}
		g_i_VotedPlayers[id] = 0; // Сбрасываем участие игрока в голосовании на 0
	}
}

public Event_Round_Start() {

	if (g_b_changemap && g_b_changemap_full)
	{
		g_b_changemap_full = false;
		server_cmd("changelevel %s", NEXT_MAP_NAME)
	}
        return PLUGIN_CONTINUE;
}

public Event_Round_End(){
	
	if (g_b_changemap)
	{
		set_task(10.0, "change_level_message");
	}
	
}

public change_level_message (){
	
	g_b_changemap_full = true;
	
	new i_Players[32], i_PlayersNum
	get_players(i_Players, i_PlayersNum, "ch")
	new i
	
	for (i = 0; i < i_PlayersNum; i++)
	{
		set_dhudmessage(255, 0, 0, -1.0, 0.01, 0, 6.0, 1800.0);
		show_dhudmessage(i_Players[i], "%L", i_Players[i], "VOTEMAP_LAST_ROUND");
		
		set_dhudmessage(0, 255, 0, -1.0, 0.04, 0, 6.0, 1800.0);
		show_dhudmessage(i_Players[i], "%L %s", i_Players[i], "VOTEMAP_NEXT_MAP", NEXT_MAP_NAME);
	}
}

public check_disable_nominate ( )
{
	new s_timer = floatround ( get_gametime() - g_f_MapTimer )

	if ( floatround ( get_pcvar_float ( g_i_pcvar_TimeOutNominate ) * 60.0 ) > s_timer )
		return floatround ( get_pcvar_float ( g_i_pcvar_TimeOutNominate ) * 60.0 ) - s_timer

	return 0
}

public event_restart_game ( )
{
	g_f_MapTimer = get_gametime()
	return PLUGIN_CONTINUE
}

public plugin_precache()
{
	precache_sound("events/friend_died.wav");
	precache_sound("events/tutor_msg.wav");
}