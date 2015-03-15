#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>

new g_bwEnt[33]

#define PLUG_NAME "HATS"
#define PLUG_AUTH "SgtBane"
#define PLUG_VERS "0.2"
#define PLUG_TAG "HATS"

#define menusize 	220

new HatFile[64]
new MenuPages, TotalHats
new CurrentMenu[33]

#define MAX_HATS 64
new HATMDL[MAX_HATS][41]
new HATNAME[MAX_HATS][41]
new HATTEAM[MAX_HATS][41]
new HATUSER[MAX_HATS][41]

public plugin_init()
{
	register_plugin(PLUG_NAME, PLUG_VERS, PLUG_AUTH)
	register_concmd("amx_givehat", "Give_Hat", ADMIN_RCON, "<nick> <mdl #>")
	register_concmd("amx_removehats", "Remove_Hat", ADMIN_RCON, " - Removes hats from everyone.")
	register_menucmd(register_menuid("\yHat Menu: [Page"),(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9),"MenuCommand")
	/*register_clcmd("say /hats",		"ShowMenu", -1, "Shows Knife menu")*/
	register_clcmd("say /hats","ShowMenu", ADMIN_LEVEL_A, "Shows Knife menu")
}

public ShowMenu(id)
{
	CurrentMenu[id] = 1
	ShowHats(id)
	return PLUGIN_HANDLED
}

public ShowHats(id)
{
	new keys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9)
	
	new szMenuBody[menusize + 1], WpnID
	new nLen = format(szMenuBody, menusize, "\yHat Menu: [Page %i/%i]^n",CurrentMenu[id],MenuPages)
	
	// Get Hat Names And Add Them To The List
	if ((cs_get_user_team(id) == CS_TEAM_CT)&&(equal(HATTEAM == CT)))
		return menu5Display(id)
	{
		return menu4Display(id)
	}
	for (new hatid=0; hatid < 8; hatid++) {
		WpnID = ((CurrentMenu[id] * 8) + hatid - 8)
		if (WpnID < TotalHats) {
			nLen += format(szMenuBody[nLen], menusize-nLen, "^n\w %i. %s",hatid + 1,HATNAME[WpnID])
		}
	}
	
	// Next Page And Previous/Close
	if (CurrentMenu[id] == MenuPages) {
		nLen += format(szMenuBody[nLen], menusize-nLen, "^n^n\d9. Дальше")
	} else {
		nLen += format(szMenuBody[nLen], menusize-nLen, "^n^n\w9. Дальше")
	}
	
	if (CurrentMenu[id] > 1) {
		nLen += format(szMenuBody[nLen], menusize-nLen, "^n\w0. Назад")
	} else {
		nLen += format(szMenuBody[nLen], menusize-nLen, "^n\w0. Закрыть")
	}
	show_menu(id, keys, szMenuBody, -1)
	return PLUGIN_HANDLED
}
public MenuCommand(id, key) 
{
	switch(key)
	{
		case 8:		//9 - [Next Page]
		{
			if (CurrentMenu[id] < MenuPages) CurrentMenu[id]++
			ShowHats(id)
			return PLUGIN_HANDLED
		}
		case 9:		//0 - [Close]
		{
			CurrentMenu[id]--
			if (CurrentMenu[id] > 0) ShowHats(id)
			return PLUGIN_HANDLED
		}
		default:
		{
			new HatID = ((CurrentMenu[id] * 8) + key - 8)
			if (HatID < TotalHats) {
				Set_Hat(id,HatID,id)
			}
		}
	}
	return PLUGIN_HANDLED
}

public plugin_precache()
{
	new cfgDir[32]
	get_configsdir(cfgDir,31)
	formatex(HatFile,63,"%s/hatlist.ini",cfgDir)
	command_load()
	
	for (new i = 1; i < TotalHats; ++i) {
		if (file_exists (HATMDL[i])) {
			precache_model(HATMDL[i])
			server_print("[%s] Precached %s",PLUG_TAG,HATMDL[i])
		} else {
			server_print("[%s] Failed to precache %s",PLUG_TAG,HATMDL[i])
		}
	}
}

public client_connect(id)
{
	if(g_bwEnt[id] > 0) engfunc(EngFunc_RemoveEntity,g_bwEnt[id])
	g_bwEnt[id] = 0
}

public client_disconnect(id)
{
	if(g_bwEnt[id] > 0) engfunc(EngFunc_RemoveEntity,g_bwEnt[id])
	g_bwEnt[id] = 0
}

public Give_Hat(id)
{
	new smodelnum[5], name[32]
	read_argv(1,name,31)
	read_argv(2,smodelnum,4)
	
	new player = cmd_target(id,name,2)
	if (!player) {
		client_print(id,print_chat,"Нет такого игрока",PLUG_TAG)
		return PLUGIN_HANDLED
	}
	
	new imodelnum = (str_to_num(smodelnum))
	if (imodelnum > MAX_HATS) return PLUGIN_HANDLED
	
	Set_Hat(player,imodelnum,id)

	return PLUGIN_CONTINUE
}

public Remove_Hat(id)
{
	for (new i = 0; i < get_maxplayers(); ++i) {
		if (is_user_connected(i) && g_bwEnt[i] > 0) {
			engfunc(EngFunc_RemoveEntity,g_bwEnt[i])
			g_bwEnt[i] = 0
		}
	}
	client_print(id,print_chat,"Костюмы отключенны у всех",PLUG_TAG)
	return PLUGIN_CONTINUE
}

public Set_Hat(player,imodelnum,targeter)
{
	new name[32]
	get_user_name(player, name, 31)
	if (imodelnum == 0) {
		if(g_bwEnt[player] > 0) engfunc(EngFunc_RemoveEntity,g_bwEnt[player])
		g_bwEnt[player] = 0
		client_print(targeter, print_chat, "Снял костюм",PLUG_TAG,name)
	} else if (file_exists(HATMDL[imodelnum])) {
		if(g_bwEnt[player] < 1) {
			g_bwEnt[player] = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
			if(g_bwEnt[player] > 0) 
			{
				set_pev(g_bwEnt[player], pev_movetype, MOVETYPE_FOLLOW)
				set_pev(g_bwEnt[player], pev_aiment, player)
				set_pev(g_bwEnt[player], pev_rendermode, kRenderNormal)
				set_pev(g_bwEnt[player], pev_renderamt, 0.0)
				engfunc(EngFunc_SetModel, g_bwEnt[player], HATMDL[imodelnum])
			}
		} else {
			engfunc(EngFunc_SetModel, g_bwEnt[player], HATMDL[imodelnum])
		}
		client_print(targeter, print_chat, "Одел костюм",PLUG_TAG,HATNAME[imodelnum],name)
	}
}

public command_load()
{
	if(file_exists(HatFile)) {
		HATMDL[0] = ""
		HATNAME[0] = "Отключить"
		TotalHats = 1
		new sfLineData[128]
		new file = fopen(HatFile,"rt")
		while(file && !feof(file)) {
			fgets(file,sfLineData,127)
			
			// Skip Comment and Empty Lines
			if (containi(sfLineData,";") > -1) continue
			
			// BREAK IT UP!
			parse(sfLineData, HATMDL[TotalHats],40,HATNAME[TotalHats],40,HATTEAM[TotalHats],40, HATUSER[TotalHats],40)
			
			TotalHats += 1
			if(TotalHats >= MAX_HATS) {
				server_print("Reached hat limit",PLUG_TAG)
				break
			}
		}
		if(file) fclose(file)
	}
	MenuPages = floatround((TotalHats / 8.0), floatround_ceil)
	server_print("[%s] Loaded %i hats, Generated %i pages)",PLUG_TAG,TotalHats,MenuPages)
}