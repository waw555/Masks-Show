#include <amxmodx>
#include <amxmisc>

#define PLUGIN "Voteban"
#define VERSION "1.0"
#define AUTHOR "WAW555"

//#define MAX_PLAYERS 33

#define MENU_KEYS (1<<0 | 1<<1 | 1<<2 | 1<<3 | 1<<4 | 1<<5 | 1<<6 | 1<<7 | 1<<8 | 1<<9)
#define MENU_SLOTS 8

new g_iMenuPage[MAX_PLAYERS];
new g_iVotedPlayers[MAX_PLAYERS];
new g_iVotes[MAX_PLAYERS];

new g_iPlayers[MAX_PLAYERS - 1];
new g_iNum;

new g_iMsgidSayText;

enum {
	CVAR_PERCENT = 0,
	CVAR_BANTYPE,
	CVAR_BANTIME
};
new g_szCvarName[][] = {
	"voteban_percent",
	"voteban_type",
	"voteban_time"
};
new g_szCvarValue[][] = {
	"30",
	"1",
	"60"
};
new g_iPcvar[3];
new g_szLogFile[64];

public plugin_init() {
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_dictionary("voteban.txt")
	register_dictionary("common.txt")
	register_saycmd("voteban", "Cmd_VoteBan", -1, "");
	register_saycmd("/voteban", "Cmd_VoteBan", -1, "");
	register_saycmd("мщеуифт", "Cmd_VoteBan", -1, "");
	register_saycmd("бан", "Cmd_VoteBan", -1, "");
	register_saycmd("вотебан", "Cmd_VoteBan", -1, "");
	
	register_menucmd(register_menuid("Ban Menu"), MENU_KEYS, "Menu_VoteBan");
	
	for(new i = 0 ; i < 3 ; i++)
	{
		g_iPcvar[i] = register_cvar(g_szCvarName[i], g_szCvarValue[i]);
	}
	g_iMsgidSayText = get_user_msgid("SayText");
	
	new szLogInfo[] = "amx_logdir";
	get_localinfo(szLogInfo, g_szLogFile, charsmax(g_szLogFile));
	add(g_szLogFile, charsmax(g_szLogFile), "/voteban");
	
	if(!dir_exists(g_szLogFile))
		mkdir(g_szLogFile);
		
	new szTime[32];
	get_time("%d-%m-%Y", szTime, charsmax(szTime));
	format(g_szLogFile, charsmax(g_szLogFile), "%s/%s.log", g_szLogFile, szTime);
}

public client_disconnected(id)
{
	if(g_iVotedPlayers[id])
	{
		get_players(g_iPlayers, g_iNum, "h");
		
		for(new i = 0 ; i < g_iNum ; i++)
		{
			if(g_iVotedPlayers[id] & (1 << g_iPlayers[i]))
			{
				g_iVotes[g_iPlayers[i]]--;
			}
		}
		g_iVotedPlayers[id] = 0;
	}
}

public Cmd_VoteBan(id)
{
	get_players(g_iPlayers, g_iNum, "h");
	
	if(g_iNum < 3)
	{
		client_printc(id, "\g> \d%L", id, "CMD_DISABLE");
		return PLUGIN_HANDLED;
	}
		
	ShowBanMenu(id, g_iMenuPage[id] = 0);
	return PLUGIN_CONTINUE;
}

public ShowBanMenu(id, iPos)
{
	static i, iPlayer, szName[32];
	static szMenu[1024], iCurrPos; iCurrPos = 0;
	static iStart, iEnd; iStart = iPos * MENU_SLOTS;
	static iKeys;
	
	get_players(g_iPlayers, g_iNum, "h");
	
	if(iStart >= g_iNum)
	{
		iStart = iPos = g_iMenuPage[id] = 0;
	}
	
	static iLen;
	iLen = formatex(szMenu, charsmax(szMenu), "\r%L \y%L:^n^n",id, "BAN", id, "MENU");
	
	iEnd = iStart + MENU_SLOTS;
	iKeys = MENU_KEY_0;
	
	if(iEnd > g_iNum)
	{
		iEnd = g_iNum;
	}
	
	for(i = iStart ; i < iEnd ; i++)
	{
		iPlayer = g_iPlayers[i];
		get_user_name(iPlayer, szName, charsmax(szName));
		
		iKeys |= (1 << iCurrPos++);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r%d\w.%s \d(\r%d%%\d)^n", iCurrPos, szName, get_percent(g_iVotes[iPlayer], g_iNum));
	}
	
	if(iEnd != g_iNum)
	{
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r9\w.%L ^n\r0\w.%L", id, "MORE",id, iPos ? "BACK" : "EXIT");
		iKeys |= MENU_KEY_9;
	}
	else
	{
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r0\w.%L",id, iPos ? "BACK" : "EXIT");
	}
	show_menu(id, iKeys, szMenu, -1, "Ban Menu");
	return PLUGIN_HANDLED;
}

public Menu_VoteBan(id, key)
{
	switch(key)
	{
		case 8:
		{
			ShowBanMenu(id, ++g_iMenuPage[id]);
			client_cmd(id, "spk sound/events/tutor_msg.wav");
		}
		case 9:
		{
			if(!g_iMenuPage[id])
				return PLUGIN_HANDLED;
			
			ShowBanMenu(id, --g_iMenuPage[id]);
			client_cmd(id, "spk sound/events/tutor_msg.wav");
		}
		default: {
			static iPlayer;
			iPlayer = g_iPlayers[g_iMenuPage[id] * MENU_SLOTS + key];
			
			if(!is_user_connected(iPlayer))
			{
				ShowBanMenu(id, g_iMenuPage[id]);
				client_cmd(id, "spk sound/events/friend_died.wav");
				
				return PLUGIN_HANDLED;
				
			}
			if(iPlayer == id)
			{
				client_print(id, print_center, "%L", id, "YOU_ERROR");
				ShowBanMenu(id, g_iMenuPage[id]);
				client_cmd(id, "spk sound/events/friend_died.wav");
				
				return PLUGIN_HANDLED;
			}
			if(g_iVotedPlayers[id] & (1 << iPlayer))
			{
				client_print(id, print_center, "%L", id, "ERROR_NOMINATE");
				ShowBanMenu(id, g_iMenuPage[id]);
				client_cmd(id, "spk sound/events/friend_died.wav");
				
				return PLUGIN_HANDLED;
			}
			if(get_user_flags(iPlayer) & ADMIN_IMMUNITY)
			{
				client_print(id, print_center, "%L", id, "ERROR_PLAYER_BAN");
				ShowBanMenu(id, g_iMenuPage[id]);
				client_cmd(id, "spk sound/events/friend_died.wav");
				
				return PLUGIN_HANDLED;
			}
			g_iVotes[iPlayer]++;
			g_iVotedPlayers[id] |= (1 << iPlayer);
			
			static szName[2][32];
			get_user_name(id, szName[0], charsmax(szName[]));
			get_user_name(iPlayer, szName[1], charsmax(szName[]));
			new percent = 30;
			new players[32], pnum
			get_players(players, pnum, "c")
			new i
	
			for (i = 0; i < pnum; i++)
			{
			client_printc(players[i], "\g>>> \d%L \t%s \d%L \t%s\d! (\g%d%% %L %d%%%\d)",players[i], "PLAYER", szName[0],players[i], "VOTEBAN", szName[1],get_percent(g_iVotes[iPlayer], g_iNum),players[i], "OF",percent);
			}
			client_cmd(id, "spk sound/events/tutor_msg.wav");
			
			CheckVotes(iPlayer, id);
		}
	}
	return PLUGIN_HANDLED;
}

public CheckVotes(id, voter)
{
	
	get_players(g_iPlayers, g_iNum, "h");
	new iPercent = get_percent(g_iVotes[id], g_iNum);
	
	if (iPercent >= get_pcvar_num(g_iPcvar[CVAR_PERCENT]))
	{
		new stim[35]
		get_user_authid(id, stim, charsmax(stim))
		new szIp[32]
		get_user_ip(id, szIp, charsmax(szIp), 1)
		
				
		if (equal(stim, "VALVE_ID_LAN")
		|| equal(stim, "VALVE_ID_PENDING")
		|| equal(stim, "STEAM_666:88:666")
		|| equal(stim, "STEAM_ID_PENDING")
		|| equal(stim, "STEAM_ID_LAN") ){
			server_cmd( "amx_ban %s %i ^"Забанен игроками сервера^"", szIp, get_pcvar_num(g_iPcvar[CVAR_BANTIME]))
			g_iVotes[id] = 0;
			
		} else {
			server_cmd("amx_ban %s %i ^"Забанен игроками сервера^"", stim, get_pcvar_num(g_iPcvar[CVAR_BANTIME]))
			g_iVotes[id] = 0;
		}
		
		
		
		new szName[2][32];
		get_user_name(id, szName[0], charsmax(szName[]));
		get_user_name(id, szName[1], charsmax(szName[]));
		new players[32], pnum
		get_players(players, pnum, "c")
		new i
	
		for (i = 0; i < pnum; i++)
		{
			client_printc(players[i], "\g> \d%L \t%s \d%L \g%d\d %L",players[i], "PLAYER", szName[0],id, "BANNED", get_pcvar_num(g_iPcvar[CVAR_BANTIME]), players[i], "BANNED_2");
		}
		log_to_file(g_szLogFile, "Player '%s' voted for banning '%s'", szName[1], szName[0]);
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