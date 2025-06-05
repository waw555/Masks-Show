/* ===============================================================================
 * Replace Info Message 2.3 [19.07.2017]
 * Modification by Javekson
 * ============================================================================ */
 
#include <amxmodx>

#pragma semicolon 1

new Trie:g_tReplaceInfoMsg;

public plugin_init() {
	register_plugin("Replace Info Message", "2.3", "maeStro aka 9iky6");
	
	g_tReplaceInfoMsg = TrieCreate();
	Fill_trie();
	
	register_message(get_user_msgid("SayText"), "MessageSayText");
	register_message(get_user_msgid("TextMsg"), "MessageTextMsg");
}

public Fill_trie() {
	TrieSetString(g_tReplaceInfoMsg, "#Game_Commencing",					"Игра началась");
	TrieSetString(g_tReplaceInfoMsg, "#Game_will_restart_in",				"Рестарт игры произойдет через %s секунд");
	TrieSetString(g_tReplaceInfoMsg, "#CTs_Win",							"Контр-Террористы победили");
	TrieSetString(g_tReplaceInfoMsg, "#Terrorists_Win",						"Террористы победили");
	TrieSetString(g_tReplaceInfoMsg, "#Round_Draw",							"Раунд закончился вничью");
	TrieSetString(g_tReplaceInfoMsg, "#Target_Bombed",						"Цель уничтожена");
	TrieSetString(g_tReplaceInfoMsg, "#Target_Saved",						"Цель спасена");
	TrieSetString(g_tReplaceInfoMsg, "#Hostages_Not_Rescued",				"Не удалось спасти заложников");
	TrieSetString(g_tReplaceInfoMsg, "#All_Hostages_Rescued",				"Все заложники спасены");
	TrieSetString(g_tReplaceInfoMsg, "#VIP_Escaped",						"VIP-игрок спасен");
	TrieSetString(g_tReplaceInfoMsg, "#VIP_Assassinated",					"VIP-игрок убит");
	TrieSetString(g_tReplaceInfoMsg, "#C4_Arming_Cancelled",				"Бомба может быть установлена только в зоне установки бомбы");
	TrieSetString(g_tReplaceInfoMsg, "#C4_Plant_Must_Be_On_Ground",			"Для установки бобмы Вы должны находиться на земле");
	TrieSetString(g_tReplaceInfoMsg, "#Defusing_Bomb_With_Defuse_Kit",		"Обезвреживание бомбы с набором сапёра");
	TrieSetString(g_tReplaceInfoMsg, "#Defusing_Bomb_Without_Defuse_Kit",	"Обезвреживание бомбы без набора сапёра");
	TrieSetString(g_tReplaceInfoMsg, "#Weapon_Cannot_Be_Dropped",			"Нельзя выбросить данное оружие");
	TrieSetString(g_tReplaceInfoMsg, "#C4_Plant_At_Bomb_Spot",				"Бомба может быть установлена только в зоне установки бомбы");
	TrieSetString(g_tReplaceInfoMsg, "#Cannot_Carry_Anymore",				"Вы не можете взять больше");
	TrieSetString(g_tReplaceInfoMsg, "#Already_Have_Kevlar",				"У вас уже имеется бронежилет");
	TrieSetString(g_tReplaceInfoMsg, "#Already_Have_Kevlar_Helmet",			"У вас уже имеется бронежилет и шлем");
	TrieSetString(g_tReplaceInfoMsg, "#Switch_To_BurstFire",				"Переключен в режим пулеметного огня");
	TrieSetString(g_tReplaceInfoMsg, "#Switch_To_FullAuto",					"Переключен в автоматический режим");
	TrieSetString(g_tReplaceInfoMsg, "#Switch_To_SemiAuto",					"Переключен в полуавтоматический режим");
	TrieSetString(g_tReplaceInfoMsg, "#Already_Own_Weapon",					"У вас уже имеется данное оружие");
	TrieSetString(g_tReplaceInfoMsg, "#Command_Not_Available",				"Данное действие недоступно в Вашем местонахождении");
	TrieSetString(g_tReplaceInfoMsg, "#Got_bomb",							"Вы подобрали бомбу");
	TrieSetString(g_tReplaceInfoMsg, "#Game_bomb_pickup",					"%s подобрал бомбу");
	TrieSetString(g_tReplaceInfoMsg, "#Game_bomb_drop",						"%s выбросил бомбу");
	TrieSetString(g_tReplaceInfoMsg, "#Bomb_Planted",						"Бомба установлена");
	TrieSetString(g_tReplaceInfoMsg, "#Bomb_Defused",						"Бомба обезврежена");
	TrieSetString(g_tReplaceInfoMsg, "#Cant_buy",							"%s секунд уже истекли.^rПокупка арсенала запрещена");
	TrieSetString(g_tReplaceInfoMsg, "#Name_change_at_respawn",				"Ваше имя будет изменено после следующего возрождения");
	TrieSetString(g_tReplaceInfoMsg, "#Auto_Team_Balance_Next_Round",		"Автоматический баланс команды наступит в следующем раунде");
	TrieSetString(g_tReplaceInfoMsg, "#Hint_press_buy_to_purchase",			"Нажмите клавишу КУПИТЬ, чтобы приобрести товары.");
}

public MessageSayText() {
	new szMsg[21];
	get_msg_arg_string(2, szMsg, charsmax(szMsg));
	if(equal(szMsg, "#Cstrike_Name_Change")) {
		new szNewName[32], szOldName[32], szNewMessage[180];
		get_msg_arg_string(3, szOldName, charsmax(szOldName));
		get_msg_arg_string(4, szNewName, charsmax(szNewName));
		formatex(szNewMessage, charsmax(szNewMessage), "^1Игрок ^3%s ^1изменил имя на ^3%s", szOldName, szNewName);
		set_msg_arg_string(2, szNewMessage);
	}
}

public MessageTextMsg() {
	new szMsg[192], szArg3[32];
	get_msg_arg_string(2, szMsg, charsmax(szMsg));
	if(TrieGetString(g_tReplaceInfoMsg, szMsg, szMsg, charsmax(szMsg))) {
		if(get_msg_args() > 2) {
			get_msg_arg_string(3, szArg3, charsmax(szArg3));
			replace(szMsg, charsmax(szMsg), "%s", szArg3);
		}
		set_msg_arg_string(2, szMsg);
	}
}

public plugin_end() {
	TrieDestroy(g_tReplaceInfoMsg);
}