
  #include <amxmodx>
  #include <amxmisc>
  #include <fakemeta>
  #include <hamsandwich>
  #include <cstrike>
  #include <csx>
  
public MultiKill
public MultiKillSound
public BombPlanting
public BombDefusing
public BombPlanted
public BombDefused
public BombFailed
public BombPickUp
public BombDrop
public BombCountVoice
public BombCountDef
public BombReached
public ItalyBonusKill
public EnemyRemaining
public LastMan
public KnifeKill
public KnifeKillSound
public GrenadeKill
public GrenadeSuicide
public HeadShotKill
public HeadShotKillSound
public RoundCounterSound
public RoundCounter
public KillingStreak
public KillingStreakSound
public DoubleKill
public DoubleKillSound
public PlayerName
public FirstBloodSound

new g_streakKills[33][2]
new g_multiKills[33][2]
new g_C4Timer
new g_Defusing
new g_Planter 
new Float:g_LastOmg
new g_LastAnnounce
new g_roundCount
new Float:g_doubleKill
new g_doubleKillId
new g_friend[33]
new g_firstBlood
new g_center1_sync
new g_announce_sync
new g_status_sync
new g_left_sync
new g_bottom_sync
new g_he_sync

new g_MultiKillMsg[7][] =
{
	"�������� �������! %s^n%L %d %L (%d %L)", 
	"�����!!! %s^n%L %d %L (%d %L)", 
	"%s ������ �����!!!^n%L %d %L (%d %L)", 
	"�������!!! %s^n%L %d %L (%d hs)", 
	"%s, ��� �� ��� ������!!!^n%L %d %L (%d %L)", 
	"%s � ������!^n%L %d %L (%d %L)", 
	"%s ����� ������!!!!^n%L %d %L (%d %L)"
}

new g_Sounds[7][] =
{
	"001", 
	"002", 
	"003", 
	"004", 
	"005", 
	"006", 
	"007"
}

new g_Sounds_Girl[7][] =
{
	"021", 
	"022", 
	"023", 
	"024", 
	"025", 
	"023", 
	"021"
}

new g_Sounds_Admin[7][] =
{
	"031", 
	"032", 
	"033", 
	"034", 
	"035", 
	"036", 
	"037"
}

new g_KillingMsg[7][] =
{
	"%s: ������!", 
	"%s: �������!!!", 
	"%s: ������!!!", 
	"%s: �����������!!!", 
	"%s: ������� ����������!!!", 
	"%s: ����� �����������!", 
	"%s: ����� ������!!!"
}

new g_KinfeMsg[4][] =
{
	"KNIFE_MSG_1", 
	"KNIFE_MSG_2", 
	"KNIFE_MSG_3", 
	"KNIFE_MSG_4"
}

new g_LastMessages[4][] =
{
	"LAST_MSG_1", 
	"LAST_MSG_2", 
	"LAST_MSG_3", 
	"LAST_MSG_4"
}

new g_HeMessages[4][] =
{
	"HE_MSG_1", 
	"HE_MSG_2", 
	"HE_MSG_3", 
	"HE_MSG_4"
}

new g_SHeMessages[4][] =
{
	"SHE_MSG_1", 
	"SHE_MSG_2", 
	"SHE_MSG_3", 
	"SHE_MSG_4"
}

new g_HeadShots[7][] =
{
	"HS_MSG_1", 
	"HS_MSG_2", 
	"HS_MSG_3", 
	"HS_MSG_4", 
	"HS_MSG_5", 
	"HS_MSG_6", 
	"HS_MSG_7"
}

new g_teamsNames[4][] =
{
	"TERRORIST", 
	"CT", 
	"TERRORISTS", 
	"CTS"
}

  #define MENUTIME 10 // how long menus stay up

  // Key Defines (for ease of use and readability)
  #define KEY1 (1<<0)
  #define KEY2 (1<<1)
  #define KEY3 (1<<2)
  #define KEY4 (1<<3)
  #define KEY5 (1<<4)
  #define KEY6 (1<<5)
  #define KEY7 (1<<6)
  #define KEY8 (1<<7)
  #define KEY9 (1<<8)
  #define KEY0 (1<<9)
  
  //��� ������
  #define TE_BEAMPOINTS 0
  new m_spriteTexture
  //����������� �����������
  new g_HudSync
  new max_players 
  enum {//���� ������ ��� ����������
  MS_DEATH_LINE,//����� ������
  MS_DAMAGE_MSG,//���������� ����
  MS_MODEL,//���������� ������ �������
  MS_AUTO_MENU,//��������� �������� ����
  MS_AUDIO_CONNECT,//������ ��� ����� � ����
  MS_AUDIO_ALL,//��� ����� ���. ����
  MS_AUDIO_FIRSTBLOOD,//���� ������� ��������
  MS_AUDIO_ADMIN_STEPS,//���� ��������� ������� ������
  MS_AUDIO_GIRL_STEPS,//���� ��������� ������� �������
  MS_AUDIO_USER_STEPS,//���� ��������� ������� ������
  MS_AUDIO_ONE_VS_ONE,//���� 1 �� 1
  MS_AUDIO_ONE_VS_ALL,//���� 1 ������ ����
  MS_AUDIO_ADMIN_KNIFE,//���� ������� � ���� �������
  MS_AUDIO_USER_KNIFE,//���� �������� � ���� �������
  MS_AUDIO_GRENADE,//���� �������� � �������
  MS_AUDIO_GRENADE_SUICIDE,//���� ������������ � �������
  MS_AUDIO_HEADSHOOT_KILLER,//���� ��� ������ � ������
  MS_AUDIO_HEADSHOOT_VICTIM,//���� ��� ������ ������ � ������
  MS_AUDIO_DOUBLE_KILL,//���� �������� ��������
  MS_AUDIO_PREPARE,//���� ������ ������
  MS_AUDIO_MULTI_KILL,//���� ������������� ��������
  MS_AUDIO_PICKED_BOMB,//���� �������� �����
  MS_AUDIO_BOMB_TIMER,//����� ������� �����
  MS_AUDIO_ROUND_END,//����� ����� ������
  }
  new bool:admin_options[33][30] // �������������� �����
  new bool:is_in_menu[33] // �������� ���� � ������
  new pcvar_ms//��������� ���������� �������
  new pcvar_help//������� �� �������

  new bool:admin[33];
  new bool:girl[33];
  new bool:clan[33];
  new bool:user[33];
  
  new const ADMIN_MODEL_CT_1[] = "telepuz_ct" // ������ ��������������
  new const ADMIN_MODEL_CT_2[] = "ms_admin_ct_1" // ������ ��������������
  new const ADMIN_MODEL_CT_3[] = "ms_admin_ct_2" // ������ ��������������
  /*new const ADMIN_MODEL_CT_4[] = "" // ������ ��������������
  new const ADMIN_MODEL_CT_5[] = "" // ������ ��������������
  new const ADMIN_MODEL_CT_6[] = "" // ������ ��������������*/
  new const ADMIN_MODEL_T_1[] = "telepuz_te" // ������ ��������������
  new const ADMIN_MODEL_T_2[] = "ms_admin_t_1" // ������ ��������������
  new const ADMIN_MODEL_T_3[] = "ms_admin_t_2" // ������ ��������������
 /* new const ADMIN_MODEL_T_4[] = "" // ������ ��������������
  new const ADMIN_MODEL_T_5[] = "" // ������ ��������������
  new const ADMIN_MODEL_T_6[] = "" // ������ ��������������*/
  new const GIRL_MODEL_CT_1[] = "ms_girl_ct_1" // ������ ��������������
  new const GIRL_MODEL_CT_2[] = "ms_girl_ct_2" // ������ ��������������
  new const GIRL_MODEL_CT_3[] = "ms_girl_ct_4" // ������ ��������������
  new const GIRL_MODEL_CT_4[] = "ms_girl_ct_5" // ������ ��������������
  /*new const GIRL_MODEL_CT_5[] = "" // ������ ��������������
  new const GIRL_MODEL_CT_6[] = "" // ������ ��������������
  new const GIRL_MODEL_CT_7[] = "" // ������ ��������������
  new const GIRL_MODEL_CT_8[] = "" // ������ ��������������
  new const GIRL_MODEL_CT_9[] = "" // ������ ��������������*/
  new const GIRL_MODEL_T_1[] = "ms_girl_t_1" // ������ ��������������
  new const GIRL_MODEL_T_2[] = "ms_girl_t_2" // ������ ��������������
  new const GIRL_MODEL_T_3[] = "ms_girl_t_3" // ������ ��������������
  new const GIRL_MODEL_T_4[] = "ms_girl_t_4" // ������ ��������������
  /*new const GIRL_MODEL_T_5[] = "" // ������ ��������������
  new const GIRL_MODEL_T_6[] = "" // ������ ��������������
  new const GIRL_MODEL_T_7[] = "" // ������ ��������������
  new const GIRL_MODEL_T_8[] = "" // ������ ��������������
  new const GIRL_MODEL_T_9[] = "" // ������ ��������������*/
  new const CLAN_MODEL_CT_1[] = "ms_clan_ct_1" // ������ ��������������
  new const CLAN_MODEL_CT_2[] = "ms_clan_ct_2" // ������ ��������������
  new const CLAN_MODEL_CT_3[] = "ms_clan_ct_3" // ������ ��������������
  new const CLAN_MODEL_CT_4[] = "ms_clan_ct_4" // ������ ��������������
  /*new const CLAN_MODEL_CT_5[] = "" // ������ ��������������
  new const CLAN_MODEL_CT_6[] = "" // ������ ��������������
  new const CLAN_MODEL_CT_7[] = "" // ������ ��������������
  new const CLAN_MODEL_CT_8[] = "" // ������ ��������������
  new const CLAN_MODEL_CT_9[] = "" // ������ ��������������*/
  new const CLAN_MODEL_T_1[] = "ms_clan_t_1" // ������ ��������������
  new const CLAN_MODEL_T_2[] = "ms_clan_t_2" // ������ ��������������
  new const CLAN_MODEL_T_3[] = "ms_clan_t_3" // ������ ��������������
  new const CLAN_MODEL_T_4[] = "ms_clan_t_4" // ������ ��������������
  /*new const CLAN_MODEL_T_5[] = "" // ������ ��������������
  new const CLAN_MODEL_T_6[] = "" // ������ ��������������
  new const CLAN_MODEL_T_7[] = "" // ������ ��������������
  new const CLAN_MODEL_T_8[] = "" // ������ ��������������
  new const CLAN_MODEL_T_9[] = "" // ������ ��������������*/
  new const USER_MODEL_CT_1[] = "ms_clan_ct_1" // ������ ��������������
  /*new const USER_MODEL_CT_2[] = "" // ������ ��������������
  new const USER_MODEL_CT_3[] = "" // ������ ��������������
  new const USER_MODEL_CT_4[] = "" // ������ ��������������
  new const USER_MODEL_CT_5[] = "" // ������ ��������������
  new const USER_MODEL_CT_6[] = "" // ������ ��������������
  new const USER_MODEL_CT_7[] = "" // ������ ��������������
  new const USER_MODEL_CT_8[] = "" // ������ ��������������
  new const USER_MODEL_CT_9[] = "" // ������ ��������������*/
  new const USER_MODEL_T_1[] = "ms_clan_t_1" // ������ ��������������
  /*new const USER_MODEL_T_2[] = "" // ������ ��������������
  new const USER_MODEL_T_3[] = "" // ������ ��������������
  new const USER_MODEL_T_4[] = "" // ������ ��������������
  new const USER_MODEL_T_5[] = "" // ������ ��������������
  new const USER_MODEL_T_6[] = "" // ������ ��������������
  new const USER_MODEL_T_7[] = "" // ������ ��������������
  new const USER_MODEL_T_8[] = "" // ������ ��������������
  new const USER_MODEL_T_9[] = "" // ������ ��������������*/
  
  
  #define MODELCHANGE_DELAY 0.5 // �������� ����� ������ ������
  #define MODELSET_TASK 100 // ����������� ��� ����� ������ 
  
  new g_has_custom_model[33]//���������� ����� ������ ��� ���
  new g_player_model[33][32]//������� ������ ������
  new Float:g_models_targettime // ����� ������� ������� ��� ���������� ��������� ������
  new Float:g_roundstarttime // ��������� ������� ��������� �����

  //���� � ������� �������
    public Show_Menu_Level(player) {
    	if (is_user_connected(player))
	if ((cs_get_user_team(player) == CS_TEAM_CT)&& admin[player]){
	return Menu_Admin_CT(player);
	}else if ((cs_get_user_team(player) == CS_TEAM_T)&& admin[player]){
	return Menu_Admin_T(player);
	}else if ((cs_get_user_team(player) == CS_TEAM_CT)&& girl[player]){
	return Menu_Girl_CT(player);
	}else if ((cs_get_user_team(player) == CS_TEAM_T)&& girl[player]){
	return Menu_Girl_T(player);
	}else if ((cs_get_user_team(player) == CS_TEAM_CT)&& clan[player]){
	return Menu_Clan_CT(player);
	}else if ((cs_get_user_team(player) == CS_TEAM_T)&& clan[player]){
	return Menu_Clan_T(player);
	}else if ((cs_get_user_team(player) == CS_TEAM_CT)&& user[player]){
	return Menu_User_CT(player);
	}else if((cs_get_user_team(player) == CS_TEAM_T)&& user[player])
	return Menu_User_T(player);
	{
	return PLUGIN_HANDLED;
	}
}

  // ------------------------------------------------------------------------------------------
  // --���������� ����--------------------------------------------------------------------------
  // ------------------------------------------------------------------------------------------

//���� �������������� ����� ����������

  public Menu_Admin_CT(player) {

  //������ ����� �����������
  
    new menubody[1024];
    format(menubody,1023,"\r������ ��������������:^n^n^n");
    add(menubody,1023,"\y1. ���������^n");
    add(menubody,1023,"\y2. �������� Evil^n");
    add(menubody,1023,"\y3. ������^n");
    add(menubody,1023,"\y^n6. ������� ������^n");
    add(menubody,1023,"\y^n7. ������ ����������^n");
    add(menubody,1023,"\y^n8. ������ �������^n");
    add(menubody,1023,"\r^n^n9. �������� ������^n");

    show_menu(player,KEY1|KEY2|KEY3|KEY4|KEY5|KEY6|KEY7|KEY8|KEY9|KEY0,menubody,MENUTIME,"Menu_Admin_CT");

    return PLUGIN_HANDLED;
  }
  
  //���� �������������� ����������
  
    public Menu_Admin_T(player) {

  //������ �����������
  
    new menubody[1024];
    format(menubody,1023,"\r������ ��������������:^n^n^n");
    add(menubody,1023,"\y1. ���������^n");
    add(menubody,1023,"\y2. ���������^n");
    add(menubody,1023,"\y3. ������^n");
    add(menubody,1023,"\y^n6. ������� ������^n");
    add(menubody,1023,"\y^n7. ������ ����������^n");
    add(menubody,1023,"\y^n8. ������ �������^n");
    add(menubody,1023,"\r^n^n9. �������� ������^n");

    show_menu(player,KEY1|KEY2|KEY3|KEY4|KEY5|KEY6|KEY7|KEY8|KEY9|KEY0,menubody,MENUTIME,"Menu_Admin_T");

    return PLUGIN_HANDLED;
  }
  
  //���� ������� ����� ����������

  public Menu_Girl_CT(player) {

  //������ ����� �����������
  
    new menubody[512];
    format(menubody,511,"\r������� ������:^n^n^n");
    add(menubody,511,"\y1. ������� �� �������^n");
    add(menubody,511,"\y2. ������� � ������� �����^n");
    add(menubody,511,"\y3. ������� �� ��������^n");
    add(menubody,511,"\y4. ���������^n");
    add(menubody,511,"\r^n^n9. �������� ������^n");

    show_menu(player,KEY1|KEY2|KEY3|KEY4|KEY5|KEY6|KEY7|KEY8|KEY9|KEY0,menubody,MENUTIME,"Menu_Girl_CT");

    return PLUGIN_HANDLED;
  }
  
  //���� ������� ����������
  
    public Menu_Girl_T(player) {

  //������ �����������
  
    new menubody[512];
    format(menubody,511,"\r������� ������:^n^n^n");
    add(menubody,511,"\y1. ������� ��������^n");
    add(menubody,511,"\y2. ������ �������^n");
    add(menubody,511,"\y3. �������^n");
    add(menubody,511,"\y4. ���������^n");
    add(menubody,511,"\r^n^n9. �������� ������^n");

    show_menu(player,KEY1|KEY2|KEY3|KEY4|KEY5|KEY6|KEY7|KEY8|KEY9|KEY0,menubody,MENUTIME,"Menu_Girl_T");

    return PLUGIN_HANDLED;
  }
  //���� ��������� ���������� ����� ����������

  public Menu_Clan_CT(player) {

  //������ ����� �����������
  
    new menubody[512];
    format(menubody,511,"\r������ ����������:^n^n^n");
    add(menubody,511,"\y1. ����������^n");
    add(menubody,511,"\y2. ���������^n");
    add(menubody,511,"\y3. ������� �������^n");
    add(menubody,511,"\y4. ������^n");
    add(menubody,511,"\r^n^n9. �������� ������^n");

    show_menu(player,KEY1|KEY2|KEY3|KEY4|KEY5|KEY6|KEY7|KEY8|KEY9|KEY0,menubody,MENUTIME,"Menu_Clan_CT");

    return PLUGIN_HANDLED;
  }
  
  //���� ��������� ���������� ����������
  
    public Menu_Clan_T(player) {

  //������ �����������
  
    new menubody[512];
    format(menubody,511,"\r������ ����������:^n^n^n");
    add(menubody,511,"\y1. ������� �������^n");
    add(menubody,511,"\y2. ���������^n");
    add(menubody,511,"\y3. ������� ����^n");
    add(menubody,511,"\y4. ������� �������^n");
    add(menubody,511,"\r^n^n9. �������� ������^n");

    show_menu(player,KEY1|KEY2|KEY3|KEY4|KEY5|KEY6|KEY7|KEY8|KEY9|KEY0,menubody,MENUTIME,"Menu_Clan_T");

    return PLUGIN_HANDLED;
  }
  
  //���� ������ ����� ����������

  public Menu_User_CT(player) {

  //������ ����� �����������
  
    new menubody[512];
    format(menubody,511,"\r������ ������:^n^n^n");
    add(menubody,511,"\y1. ����������^n");
    add(menubody,511,"\r^n^n9. �������� ������^n");

    show_menu(player,KEY1|KEY2|KEY3|KEY4|KEY5|KEY6|KEY7|KEY8|KEY9|KEY0,menubody,MENUTIME,"Menu_User_CT");

    return PLUGIN_HANDLED;
  }
  
  //���� ������ ����������
  
    public Menu_User_T(player) {

  //������ �����������
  
    new menubody[512];
    format(menubody,511,"\r������ ������:^n^n^n");
    add(menubody,511,"\y1. ������� �������^n");
    add(menubody,511,"\r^n^n9. �������� ������^n");

    show_menu(player,KEY1|KEY2|KEY3|KEY4|KEY5|KEY6|KEY7|KEY8|KEY9|KEY0,menubody,MENUTIME,"Menu_User_T");

    return PLUGIN_HANDLED;
  }
  

public Audio_Settings(id){
	new audio_menu[1024]
	new onoff[2][]={{"\r����\w"},{"\y���\w"}} // \r=red \y=yellow \w white
	format(audio_menu, 1023, "\y���� �������� �����\w^n ^n1. �������������� ��� ����� %s^n2. ������ ��� ����� � ���� %s^n3. ���� �������� ������� ������ %s^n4. ���� �������� ��������������� %s^n5. ���� �������� �������� %s^n6. ���� �������� ������� %s^n7. ���� ����� 1 �� 1 %s^n8. �����^n9. �����^n0. ��������� � �����",
	onoff[admin_options[id][MS_AUDIO_ALL]],
	onoff[admin_options[id][MS_AUDIO_CONNECT]],
	onoff[admin_options[id][MS_AUDIO_FIRSTBLOOD]],
	onoff[admin_options[id][MS_AUDIO_ADMIN_STEPS]],
	onoff[admin_options[id][MS_AUDIO_GIRL_STEPS]],
	onoff[admin_options[id][MS_AUDIO_USER_STEPS]],
	onoff[admin_options[id][MS_AUDIO_ONE_VS_ONE]])
	show_menu(id,KEY1|KEY2|KEY3|KEY4|KEY5|KEY6|KEY7|KEY8|KEY9|KEY0,audio_menu,MENUTIME,"Audio_Settings")
	
	return PLUGIN_HANDLED
}

public Audio_Settings1(id){
	new audio_menu1[1024]
	new onoff[2][]={{"\r����\w"},{"\y���\w"}} // \r=red \y=yellow \w white
	format(audio_menu1, 1023, "\y���� �������� �����\w^n ^n1. ���� ���� ������ ����� %s^n2. ���� �������� � ���� ������� %s^n3. ���� �������� � ���� ������� %s^n4. ���� �������� � ������� %s^n5. ���� ������������ � ������� %s^n6. ���� ������ � ������ %s^n7. ���� ��� ������� � ������ %s^n8. �����^n9. �����^n0. ��������� � �����",
	onoff[admin_options[id][MS_AUDIO_ONE_VS_ALL]],
	onoff[admin_options[id][MS_AUDIO_ADMIN_KNIFE]],
	onoff[admin_options[id][MS_AUDIO_USER_KNIFE]],
	onoff[admin_options[id][MS_AUDIO_GRENADE]],
	onoff[admin_options[id][MS_AUDIO_GRENADE_SUICIDE]],
	onoff[admin_options[id][MS_AUDIO_HEADSHOOT_KILLER]],
	onoff[admin_options[id][MS_AUDIO_HEADSHOOT_VICTIM]])
	show_menu(id,KEY1|KEY2|KEY3|KEY4|KEY5|KEY6|KEY7|KEY8|KEY9|KEY0,audio_menu1,MENUTIME,"Audio_Settings1")
	
	return PLUGIN_HANDLED
}

public Audio_Settings2(id){
	new audio_menu2[1024]
	new onoff[2][]={{"\r����\w"},{"\y���\w"}} // \r=red \y=yellow \w white
	format(audio_menu2, 1023, "\y���� �������� �����\w^n ^n1. ���� �������� �������� %s^n2. ���� ������ ������ %s^n3. ���� �������������� �������� %s^n4. ���� �������� ����� %s^n5. ������ ����� %s^n6. ���� � ����� ������ %s^n9. �����^n0. ��������� � �����",
	onoff[admin_options[id][MS_AUDIO_DOUBLE_KILL]],
	onoff[admin_options[id][MS_AUDIO_PREPARE]],
	onoff[admin_options[id][MS_AUDIO_MULTI_KILL]],
	onoff[admin_options[id][MS_AUDIO_PICKED_BOMB]],
	onoff[admin_options[id][MS_AUDIO_BOMB_TIMER]],
	onoff[admin_options[id][MS_AUDIO_ROUND_END]])
	show_menu(id,KEY1|KEY2|KEY3|KEY4|KEY5|KEY6|KEY7|KEY8|KEY9|KEY0,audio_menu2,MENUTIME,"Audio_Settings2")
	
	return PLUGIN_HANDLED
}

/*================================================================================
 �������� ���� ��������
=================================================================================*/
public show_esp_menu(id){
	is_in_menu[id]=true
	new menu[501]
	new keys=MENU_KEY_0|MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9
	new onoff[2][]={{"\r����\w"},{"\y���\w"}} // \r=red \y=yellow \w white
	new text[2][]={{"(����������� ����� ��� ���������)"},{"����� �������� ���������^n �������� � ���� \r /menu\w"}} // \r=red \y=yellow \w white
	new text_index=get_pcvar_num(pcvar_help)
	if (text_index!=1) text_index=0
	format(menu, 500, "\y���� ��������\w^n ^n %s ^n ^n1. ��� ������ %s^n2. ���������� ����������� %s^n3. ���������� ������ ������� %s^n4. ���������� ���� ��� ������ %s^n^n9. ��������� ������^n0. ��������� � �����",
	text[text_index],
	onoff[admin_options[id][MS_DEATH_LINE]],
	onoff[admin_options[id][MS_DAMAGE_MSG]],
	onoff[admin_options[id][MS_MODEL]],
	onoff[admin_options[id][MS_AUTO_MENU]])
	show_menu(id,keys,menu)
	
	return PLUGIN_HANDLED
}

  // ------------------------------------------------------------------------------------------
  // --�������� ����---------------------------------------------------------------------------
  // ------------------------------------------------------------------------------------------

  // --���� �������������� ����� ����������---------------------------------------------------------------------------
  public Menu_Admin_CT_Action(player,key) {

    // 1. ������ 1
    if(key == 0) {
      copy( g_player_model[player], charsmax( g_player_model[] ), ADMIN_MODEL_CT_1 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }

    // 2. ������ 2
    if(key == 1) {
      copy( g_player_model[player], charsmax( g_player_model[] ), ADMIN_MODEL_CT_2 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }

    // 3. ������ 3
    if(key == 2) {
      copy( g_player_model[player], charsmax( g_player_model[] ), ADMIN_MODEL_CT_3 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }

    /*// 4. ������ 4
    if(key == 3) {
      copy( g_player_model[player], charsmax( g_player_model[] ), ADMIN_MODEL_CT_4 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }
    
       // 5. ������ 5
    if(key == 4) {
      copy( g_player_model[player], charsmax( g_player_model[] ), ADMIN_MODEL_CT_5 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }
    
       // 6. ������ 6
    if(key == 5) {
      copy( g_player_model[player], charsmax( g_player_model[] ), ADMIN_MODEL_CT_6 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }*/

       // ������ 6 //������� ������
    if(key == 5) {
      Menu_Girl_CT(player);
      return 1;
    }
    
      // ������ 7 //������ ����������
    if(key == 6) {
      Menu_Clan_CT(player);
      return 1;
    }
    
      //������ 8 //������ �������
    if(key == 7) {
      Menu_User_CT(player);
      return 1;
    }
    
     //������ 9 //�������� ������
    if(key == 8) {
	fm_reset_user_model(player);
	return 1;
    }

    return 1;
  }
  
    // --���� �������������� ����������---------------------------------------------------------------------------
  public Menu_Admin_T_Action(player,key) {

    // 1. ������ 1
    if(key == 0) {
      copy( g_player_model[player], charsmax( g_player_model[] ), ADMIN_MODEL_T_1 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }

    // 2. ������ 2
    if(key == 1) {
      copy( g_player_model[player], charsmax( g_player_model[] ), ADMIN_MODEL_T_2 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }

    // 3. ������ 3
    if(key == 2) {
      copy( g_player_model[player], charsmax( g_player_model[] ), ADMIN_MODEL_T_3 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }

    /*// 4. ������ 4
    if(key == 3) {
      copy( g_player_model[player], charsmax( g_player_model[] ), ADMIN_MODEL_T_4 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }
    
       // 5. ������ 5
    if(key == 4) {
      copy( g_player_model[player], charsmax( g_player_model[] ), ADMIN_MODEL_T_5 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }
    
       // 6. ������ 6
    if(key == 5) {
      copy( g_player_model[player], charsmax( g_player_model[] ), ADMIN_MODEL_T_6 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }*/

       //������ 6 //������� ������
    if(key == 5) {
      Menu_Girl_T(player);
      return 1;
    }
    
      //������ 7 //������ ����������
    if(key == 6) {
      Menu_Clan_T(player);
      return 1;
    }
    
      //������ 8 //������ �������
    if(key == 7) {
      Menu_User_T(player);
      return 1;
    }
   
      // ������ 9 //�������� ������
    if(key == 8) {
	fm_reset_user_model(player);
	return 1;
    }

    return 1;
  }
  
    // --���� ������� ����� ����������---------------------------------------------------------------------------
  public Menu_Girl_CT_Action(player,key) {

    // 1. ������ 1
    if(key == 0) {
      copy( g_player_model[player], charsmax( g_player_model[] ), GIRL_MODEL_CT_1 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }

    // 2. ������ 2
    if(key == 1) {
      copy( g_player_model[player], charsmax( g_player_model[] ), GIRL_MODEL_CT_2 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }

    // 3. ������ 3
    if(key == 2) {
      copy( g_player_model[player], charsmax( g_player_model[] ), GIRL_MODEL_CT_3 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }

    // 4. ������ 4
    if(key == 3) {
      copy( g_player_model[player], charsmax( g_player_model[] ), GIRL_MODEL_CT_4 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }
    
    /*  // 5. ������ 5
    if(key == 4) {
      copy( g_player_model[player], charsmax( g_player_model[] ), GIRL_MODEL_CT_5 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }
    
       // 6. ������ 6
    if(key == 5) {
      copy( g_player_model[player], charsmax( g_player_model[] ), GIRL_MODEL_CT_6 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }
    
      // 7. ������ 7
    if(key == 6) {
      copy( g_player_model[player], charsmax( g_player_model[] ), GIRL_MODEL_CT_7 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }
    
      // 8. ������ 8
    if(key == 7) {
      copy( g_player_model[player], charsmax( g_player_model[] ), GIRL_MODEL_CT_8 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }*/
    
      // 9. ������ 9
    if(key == 8) {
	fm_reset_user_model(player);
	return 1;
    }

    return 1;
  }

  
      // --���� ������� ����������---------------------------------------------------------------------------
  public Menu_Girl_T_Action(player,key) {

    // 1. ������ 1
    if(key == 0) {
      copy( g_player_model[player], charsmax( g_player_model[] ), GIRL_MODEL_T_1 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }

    // 2. ������ 2
    if(key == 1) {
      copy( g_player_model[player], charsmax( g_player_model[] ), GIRL_MODEL_T_2 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }

    // 3. ������ 3
    if(key == 2) {
      copy( g_player_model[player], charsmax( g_player_model[] ), GIRL_MODEL_T_3 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }
    
    // 4. ������ 4
    if(key == 3) {
      copy( g_player_model[player], charsmax( g_player_model[] ), GIRL_MODEL_T_4 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }
    
    /*  // 5. ������ 5
    if(key == 4) {
      copy( g_player_model[player], charsmax( g_player_model[] ), GIRL_MODEL_T_5 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }
    
       // 6. ������ 6
    if(key == 5) {
      copy( g_player_model[player], charsmax( g_player_model[] ), GIRL_MODEL_T_6 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }
    
      // 7. ������ 7
    if(key == 6) {
      copy( g_player_model[player], charsmax( g_player_model[] ), GIRL_MODEL_T_7 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }
    
      // 8. ������ 8
    if(key == 7) {
      copy( g_player_model[player], charsmax( g_player_model[] ), GIRL_MODEL_T_8 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }*/
    
      // 9. ������ 9
    if(key == 8) {
	fm_reset_user_model(player);
	return 1;
    }

    return 1;
  }
  
     // --���� ���������� ����� ����������---------------------------------------------------------------------------
  public Menu_Clan_CT_Action(player,key) {

    // 1. ������ 1
    if(key == 0) {
      copy( g_player_model[player], charsmax( g_player_model[] ), CLAN_MODEL_CT_1 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }

    // 2. ������ 2
    if(key == 1) {
      copy( g_player_model[player], charsmax( g_player_model[] ), CLAN_MODEL_CT_2 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }

    // 3. ������ 3
    if(key == 2) {
      copy( g_player_model[player], charsmax( g_player_model[] ), CLAN_MODEL_CT_3 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }

    // 4. ������ 4
    if(key == 3) {
      copy( g_player_model[player], charsmax( g_player_model[] ), CLAN_MODEL_CT_4 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }
    
    /*   // 5. ������ 5
    if(key == 4) {
      copy( g_player_model[player], charsmax( g_player_model[] ), CLAN_MODEL_CT_5 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }
    
       // 6. ������ 6
    if(key == 5) {
      copy( g_player_model[player], charsmax( g_player_model[] ), CLAN_MODEL_CT_6 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }
    
      // 7. ������ 7
    if(key == 6) {
      copy( g_player_model[player], charsmax( g_player_model[] ), CLAN_MODEL_CT_7 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }
    
      // 8. ������ 8
    if(key == 7) {
      copy( g_player_model[player], charsmax( g_player_model[] ), CLAN_MODEL_CT_8 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }*/
    
      // 9. ������ 9
    if(key == 8) {
	fm_reset_user_model(player);
	return 1;
    }

    return 1;
  }
  
       // --���� ���������� ����������---------------------------------------------------------------------------
  public Menu_Clan_T_Action(player,key) {

    // 1. ������ 1
    if(key == 0) {
      copy( g_player_model[player], charsmax( g_player_model[] ), CLAN_MODEL_T_1 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }

    // 2. ������ 2
    if(key == 1) {
      copy( g_player_model[player], charsmax( g_player_model[] ), CLAN_MODEL_T_2 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }

    // 3. ������ 3
    if(key == 2) {
      copy( g_player_model[player], charsmax( g_player_model[] ), CLAN_MODEL_T_3 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }

    // 4. ������ 4
    if(key == 3) {
      copy( g_player_model[player], charsmax( g_player_model[] ), CLAN_MODEL_T_4 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }
    
    /*   // 5. ������ 5
    if(key == 4) {
      copy( g_player_model[player], charsmax( g_player_model[] ), CLAN_MODEL_T_5 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }
    
       // 6. ������ 6
    if(key == 5) {
      copy( g_player_model[player], charsmax( g_player_model[] ), CLAN_MODEL_T_6 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }
    
      // 7. ������ 7
    if(key == 6) {
      copy( g_player_model[player], charsmax( g_player_model[] ), CLAN_MODEL_T_7 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }
    
      // 8. ������ 8
    if(key == 7) {
      copy( g_player_model[player], charsmax( g_player_model[] ), CLAN_MODEL_T_8 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }*/
    
      // 9. ������ 9
    if(key == 8) {
	fm_reset_user_model(player);
	return 1;
    }

    return 1;
  }
  
       // --���� ������ ����� ����������---------------------------------------------------------------------------
  public Menu_User_CT_Action(player,key) {
  	
   // 1. ������ 1
    if(key == 0) {
      copy( g_player_model[player], charsmax( g_player_model[] ), USER_MODEL_CT_1 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }

    /*// 2. ������ 2
    if(key == 1) {
      copy( g_player_model[player], charsmax( g_player_model[] ), USER_MODEL_CT_2 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }

    // 3. ������ 3
    if(key == 2) {
      copy( g_player_model[player], charsmax( g_player_model[] ), USER_MODEL_CT_3 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }

    // 4. ������ 4
    if(key == 3) {
      copy( g_player_model[player], charsmax( g_player_model[] ), USER_MODEL_CT_4 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }
    
       // 5. ������ 5
    if(key == 4) {
      copy( g_player_model[player], charsmax( g_player_model[] ), USER_MODEL_CT_5 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }
    
       // 6. ������ 6
    if(key == 5) {
      copy( g_player_model[player], charsmax( g_player_model[] ), USER_MODEL_CT_6 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }
    
      // 7. ������ 7
    if(key == 6) {
      copy( g_player_model[player], charsmax( g_player_model[] ), USER_MODEL_CT_7 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }
    
      // 8. ������ 8
    if(key == 7) {
      copy( g_player_model[player], charsmax( g_player_model[] ), USER_MODEL_CT_8 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }*/
    
      // 9. ������ 9
    if(key == 8) {
	fm_reset_user_model(player);
	return 1;
    }

    return 1;
  }
  
  
         // --���� ������ ����������---------------------------------------------------------------------------
  public Menu_User_T_Action(player,key) {

    // 1. ������ 1
    if(key == 0) {
      copy( g_player_model[player], charsmax( g_player_model[] ), USER_MODEL_T_1 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }

    /*// 2. ������ 2
    if(key == 1) {
      copy( g_player_model[player], charsmax( g_player_model[] ), USER_MODEL_T_2 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }

    // 3. ������ 3
    if(key == 2) {
      copy( g_player_model[player], charsmax( g_player_model[] ), USER_MODEL_T_3 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }

    // 4. ������ 4
    if(key == 3) {
      copy( g_player_model[player], charsmax( g_player_model[] ), USER_MODEL_T_4 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }
    
       // 5. ������ 5
    if(key == 4) {
      copy( g_player_model[player], charsmax( g_player_model[] ), USER_MODEL_T_5 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }
    
       // 6. ������ 6
    if(key == 5) {
      copy( g_player_model[player], charsmax( g_player_model[] ), USER_MODEL_T_6 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }
    
      // 7. ������ 7
    if(key == 6) {
      copy( g_player_model[player], charsmax( g_player_model[] ), USER_MODEL_T_7 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }
    
      // 8. ������ 8
    if(key == 7) {
      copy( g_player_model[player], charsmax( g_player_model[] ), USER_MODEL_T_8 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }*/
    
      // 9. ������ 9
    if(key == 8) {
	fm_reset_user_model(player);
	return 1;
    }
    
    return 1;
  }
  
public Audio_Settings_Action(id,key){
	if (key==0){ // exit
		if (admin_options[id][MS_AUDIO_ALL]){
		admin_options[id][MS_AUDIO_ALL]=false
		admin_options[id][MS_AUDIO_CONNECT]=false
		admin_options[id][MS_AUDIO_FIRSTBLOOD]=false
		admin_options[id][MS_AUDIO_ADMIN_STEPS]=false
		admin_options[id][MS_AUDIO_GIRL_STEPS]=false
		admin_options[id][MS_AUDIO_USER_STEPS]=false
		admin_options[id][MS_AUDIO_ONE_VS_ONE]=false
		admin_options[id][MS_AUDIO_ONE_VS_ALL]=false
		admin_options[id][MS_AUDIO_ADMIN_KNIFE]=false
		admin_options[id][MS_AUDIO_USER_KNIFE]=false
		admin_options[id][MS_AUDIO_GRENADE]=false
		admin_options[id][MS_AUDIO_GRENADE_SUICIDE]=false
		admin_options[id][MS_AUDIO_HEADSHOOT_KILLER]=false
		admin_options[id][MS_AUDIO_HEADSHOOT_VICTIM]=false
		admin_options[id][MS_AUDIO_DOUBLE_KILL]=false
		admin_options[id][MS_AUDIO_PREPARE]=false
		admin_options[id][MS_AUDIO_MULTI_KILL]=false
		admin_options[id][MS_AUDIO_PICKED_BOMB]=false
		admin_options[id][MS_AUDIO_BOMB_TIMER]=false
		admin_options[id][MS_AUDIO_ROUND_END]=false
		}else{
		admin_options[id][MS_AUDIO_ALL]=true
		admin_options[id][MS_AUDIO_CONNECT]=true
		admin_options[id][MS_AUDIO_FIRSTBLOOD]=true
		admin_options[id][MS_AUDIO_ADMIN_STEPS]=true
		admin_options[id][MS_AUDIO_GIRL_STEPS]=true
		admin_options[id][MS_AUDIO_USER_STEPS]=true
		admin_options[id][MS_AUDIO_ONE_VS_ONE]=true
		admin_options[id][MS_AUDIO_ONE_VS_ALL]=true
		admin_options[id][MS_AUDIO_ADMIN_KNIFE]=true
		admin_options[id][MS_AUDIO_USER_KNIFE]=true
		admin_options[id][MS_AUDIO_GRENADE]=true
		admin_options[id][MS_AUDIO_GRENADE_SUICIDE]=true
		admin_options[id][MS_AUDIO_HEADSHOOT_KILLER]=true
		admin_options[id][MS_AUDIO_HEADSHOOT_VICTIM]=true
		admin_options[id][MS_AUDIO_DOUBLE_KILL]=true
		admin_options[id][MS_AUDIO_PREPARE]=true
		admin_options[id][MS_AUDIO_MULTI_KILL]=true
		admin_options[id][MS_AUDIO_PICKED_BOMB]=true
		admin_options[id][MS_AUDIO_BOMB_TIMER]=true
		admin_options[id][MS_AUDIO_ROUND_END]=true
	}
		Audio_Settings(id)
		return PLUGIN_HANDLED
	}
	if (key==1){ // exit
		if (admin_options[id][MS_AUDIO_CONNECT]){
		admin_options[id][MS_AUDIO_CONNECT]=false
		}else{
		admin_options[id][MS_AUDIO_CONNECT]=true
		admin_options[id][MS_AUDIO_ALL]=true
		}
		Audio_Settings(id)
		return PLUGIN_HANDLED
	}
	if (key==2){ // exit
		if (admin_options[id][MS_AUDIO_FIRSTBLOOD]){
		admin_options[id][MS_AUDIO_FIRSTBLOOD]=false
		}else{
		admin_options[id][MS_AUDIO_FIRSTBLOOD]=true
		admin_options[id][MS_AUDIO_ALL]=true
		}
		Audio_Settings(id)
		return PLUGIN_HANDLED
	}
	if (key==3){ // exit
		if (admin_options[id][MS_AUDIO_ADMIN_STEPS]){
		admin_options[id][MS_AUDIO_ADMIN_STEPS]=false
		}else{
		admin_options[id][MS_AUDIO_ADMIN_STEPS]=true
		admin_options[id][MS_AUDIO_ALL]=true
	}
		Audio_Settings(id)
		return PLUGIN_HANDLED
	}
	if (key==4){ // exit
		if (admin_options[id][MS_AUDIO_GIRL_STEPS]){
		admin_options[id][MS_AUDIO_GIRL_STEPS]=false
		}else{
		admin_options[id][MS_AUDIO_GIRL_STEPS]=true
		admin_options[id][MS_AUDIO_ALL]=true
		}
		Audio_Settings(id)
		return PLUGIN_HANDLED
	}
	if (key==5){ // exit
		if (admin_options[id][MS_AUDIO_USER_STEPS]){
		admin_options[id][MS_AUDIO_USER_STEPS]=false
		}else{
		admin_options[id][MS_AUDIO_USER_STEPS]=true
		admin_options[id][MS_AUDIO_ALL]=true
		}
		Audio_Settings(id)
		return PLUGIN_HANDLED
	}
	if (key==6){ // exit
		if (admin_options[id][MS_AUDIO_ONE_VS_ONE]){
		admin_options[id][MS_AUDIO_ONE_VS_ONE]=false
		}else{
		admin_options[id][MS_AUDIO_ONE_VS_ONE]=true
		admin_options[id][MS_AUDIO_ALL]=true
		}
		Audio_Settings(id)
		return PLUGIN_HANDLED
	}
	if (key==7){ // exit
		Audio_Settings1(id)
		return PLUGIN_HANDLED
	}
	
	if (key==8){ // exit
		is_in_menu[id]=true
		show_esp_menu(id)
		return PLUGIN_HANDLED
	}
	
	if (key==9){ // exit
		save2vault(id)
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public Audio_Settings_Action1(id,key){
	if (key==0){ // exit
		if (admin_options[id][MS_AUDIO_ONE_VS_ALL]){
		admin_options[id][MS_AUDIO_ONE_VS_ALL]=false
		}else{
		admin_options[id][MS_AUDIO_ALL]=true
		admin_options[id][MS_AUDIO_ONE_VS_ALL]=true
		}
		Audio_Settings1(id)
		return PLUGIN_HANDLED
	}
	if (key==1){ // exit
		if (admin_options[id][MS_AUDIO_ADMIN_KNIFE]){
		admin_options[id][MS_AUDIO_ADMIN_KNIFE]=false
		}else{
		admin_options[id][MS_AUDIO_ADMIN_KNIFE]=true
		admin_options[id][MS_AUDIO_ALL]=true
		}
		Audio_Settings1(id)
		return PLUGIN_HANDLED
	}
	if (key==2){ // exit
		if (admin_options[id][MS_AUDIO_USER_KNIFE]){
		admin_options[id][MS_AUDIO_USER_KNIFE]=false
		}else{
		admin_options[id][MS_AUDIO_USER_KNIFE]=true
		admin_options[id][MS_AUDIO_ALL]=true
		}
		Audio_Settings1(id)
		return PLUGIN_HANDLED
	}
	if (key==3){ // exit
		if (admin_options[id][MS_AUDIO_GRENADE]){
		admin_options[id][MS_AUDIO_GRENADE]=false
		}else{
		admin_options[id][MS_AUDIO_GRENADE]=true
		admin_options[id][MS_AUDIO_ALL]=true
		}
		Audio_Settings1(id)
		return PLUGIN_HANDLED
	}
	if (key==4){ // exit
		if (admin_options[id][MS_AUDIO_GRENADE_SUICIDE]){
		admin_options[id][MS_AUDIO_GRENADE_SUICIDE]=false
		}else{
		admin_options[id][MS_AUDIO_GRENADE_SUICIDE]=true
		admin_options[id][MS_AUDIO_ALL]=true
		}
		Audio_Settings1(id)
		return PLUGIN_HANDLED
	}
	if (key==5){ // exit
		if (admin_options[id][MS_AUDIO_HEADSHOOT_KILLER]){
		admin_options[id][MS_AUDIO_HEADSHOOT_KILLER]=false
		}else{
		admin_options[id][MS_AUDIO_HEADSHOOT_KILLER]=true
		admin_options[id][MS_AUDIO_ALL]=true
		}
		Audio_Settings1(id)
		return PLUGIN_HANDLED
	}
	if (key==6){ // exit
		if (admin_options[id][MS_AUDIO_HEADSHOOT_VICTIM]){
		admin_options[id][MS_AUDIO_HEADSHOOT_VICTIM]=false
		}else{
		admin_options[id][MS_AUDIO_HEADSHOOT_VICTIM]=true
		admin_options[id][MS_AUDIO_ALL]=true
		}
		Audio_Settings1(id)
		return PLUGIN_HANDLED
	}
	if (key==7){ // exit
		Audio_Settings2(id)
		return PLUGIN_HANDLED
	}
	
	if (key==8){ // exit
		Audio_Settings(id)
		return PLUGIN_HANDLED
	}
	
	if (key==9){ // exit
		save2vault(id)
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public Audio_Settings_Action2(id,key){
	if (key==0){ // exit
		if (admin_options[id][MS_AUDIO_DOUBLE_KILL]){
		admin_options[id][MS_AUDIO_DOUBLE_KILL]=false
		}else{
		admin_options[id][MS_AUDIO_ALL]=true
		admin_options[id][MS_AUDIO_DOUBLE_KILL]=true
		}
		Audio_Settings2(id)
		return PLUGIN_HANDLED
	}
	if (key==1){ // exit
		if (admin_options[id][MS_AUDIO_PREPARE]){
		admin_options[id][MS_AUDIO_PREPARE]=false
		}else{
		admin_options[id][MS_AUDIO_PREPARE]=true
		admin_options[id][MS_AUDIO_ALL]=true
		}
		Audio_Settings2(id)
		return PLUGIN_HANDLED
	}
	if (key==2){ // exit
		if (admin_options[id][MS_AUDIO_MULTI_KILL]){
		admin_options[id][MS_AUDIO_MULTI_KILL]=false
		}else{
		admin_options[id][MS_AUDIO_MULTI_KILL]=true
		admin_options[id][MS_AUDIO_ALL]=true
		}
		Audio_Settings2(id)
		return PLUGIN_HANDLED
	}
	if (key==3){ // exit
		if (admin_options[id][MS_AUDIO_PICKED_BOMB]){
		admin_options[id][MS_AUDIO_PICKED_BOMB]=false
		}else{
		admin_options[id][MS_AUDIO_PICKED_BOMB]=true
		admin_options[id][MS_AUDIO_ALL]=true
	}
		Audio_Settings2(id)
		return PLUGIN_HANDLED
	}
	if (key==4){ // exit
		if (admin_options[id][MS_AUDIO_BOMB_TIMER]){
		admin_options[id][MS_AUDIO_BOMB_TIMER]=false
		}else{
		admin_options[id][MS_AUDIO_BOMB_TIMER]=true
		admin_options[id][MS_AUDIO_ALL]=true
		}
		Audio_Settings2(id)
		return PLUGIN_HANDLED
	}
	if (key==5){ // exit
		if (admin_options[id][MS_AUDIO_ROUND_END]){
		admin_options[id][MS_AUDIO_ROUND_END]=false
		}else{
		admin_options[id][MS_AUDIO_ROUND_END]=true
		admin_options[id][MS_AUDIO_ALL]=true
		}
		Audio_Settings2(id)
		return PLUGIN_HANDLED
	}
	/*if (key==6){ // exit
		if (admin_options[id][MS_AUDIO_HEADSHOOT_VICTIM]){
		admin_options[id][MS_AUDIO_HEADSHOOT_VICTIM]=false
		}else{
		admin_options[id][MS_AUDIO_HEADSHOOT_VICTIM]=true
		admin_options[id][MS_AUDIO_ALL]=true
		}
		Audio_Settings2(id)
		return PLUGIN_HANDLED
	}
	if (key==7){ // exit
		Audio_Settings2(id)
		return PLUGIN_HANDLED
	}*/
	
	if (key==8){ // exit
		Audio_Settings1(id)
		return PLUGIN_HANDLED
	}
	
	if (key==9){ // exit
		save2vault(id)
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}
  


/*================================================================================
 �������� ����
=================================================================================*/
public menu_esp(id,key){

	if (key==9){ // exit
		save2vault(id)
		is_in_menu[id]=false
		return PLUGIN_HANDLED
	}
	
	if (key==8){ // exit
		is_in_menu[id]=false
		Audio_Settings(id)
	}
	
	if (key==0){ // exit
		if (admin_options[id][MS_DEATH_LINE]){
		admin_options[id][MS_DEATH_LINE]=false
		}else{
		admin_options[id][MS_DEATH_LINE]=true
	}
		show_esp_menu(id)
		return PLUGIN_HANDLED
	}
	
	if (key==1){ // exit
		if (admin_options[id][MS_DAMAGE_MSG]){
		admin_options[id][MS_DAMAGE_MSG]=false
		}else{
		admin_options[id][MS_DAMAGE_MSG]=true
	}
		show_esp_menu(id)
		return PLUGIN_HANDLED
	}
	
	if (key==2){ // exit
		if (admin_options[id][MS_MODEL]){
		admin_options[id][MS_MODEL]=false
		}else{
		admin_options[id][MS_MODEL]=true
	}
		show_esp_menu(id)
		return PLUGIN_HANDLED
	}
	
	if (key==3){ // exit
		if (admin_options[id][MS_AUTO_MENU]){
		admin_options[id][MS_AUTO_MENU]=false
		}else{
		admin_options[id][MS_AUTO_MENU]=true
	}
		show_esp_menu(id)
		return PLUGIN_HANDLED
	}
	

	/*// toggle esp options
	if (admin_options[id][key]){
		admin_options[id][key]=false
		}else{
		admin_options[id][key]=true
	}*/
	return PLUGIN_HANDLED
}
  // ------------------------------------------------------------------------------------------
  // --CUSTOM MODEL LIST----------------------------------------------------------------------
  // ------------------------------------------------------------------------------------------
  public get_models(array[50][],len) {

    // get a list of custom models

    new dirpos, output[128], outlen, filledamt;

    // go through custom models
    while((dirpos = read_dir("models/player",dirpos,output,255,outlen)) != 0) {

      if(containi(output,".") == -1) { // if not a file (but a directory)

        // check if model is actually there
        new modelfile[256];
        format(modelfile,255,"models/player/%s/%s.mdl",output,output);

        // if it exists
        if(file_exists(modelfile)) {
          format(array[filledamt],len,"%s",output);
          filledamt += 1;
        }

        // if we are out of array space now
        if(filledamt > 50) {
          return filledamt;
        }

      }

    }

    return filledamt;
  }

/*================================================================================
 ����������� ������
=================================================================================*/
  public client_connect(id) {
  	client_cmd(id, "mp3 play sound/ms/start_%d", random_num(1,2));
	client_cmd(id,"bind ^"mouse3^" ^"throw_knife;ppfire^"");
	client_cmd(id,"bind F6 ^"say buy_parachute^"");
	client_cmd(id,"bind F8 ^"setinfo translit 1^"");
	client_cmd(id,"bind F9 ^"setinfo translit 0^"");
	client_cmd(id,"bind F10 ^"quit^"");
	client_cmd(id,"bind P pcview");
	client_cmd(id,"cl_updaterate 100");
	client_cmd(id,"cl_cmdrate 100");
	client_cmd(id,"rate 20000");
	client_cmd(id,"bind ^"F7^" ^"piss^"");
	client_cmd(id,"bind ^"F5^" ^"ms_model^"");
	client_cmd(id,"bind ^"DEL^" ^"maxwit^"");
	client_cmd(id,"bind ^"END^" ^"bank_help^"");
	client_cmd(id,"bind ^"PAUSE^" ^"bank_create^"");
	client_cmd(id,"bind ^"HOME^" ^"bank_amount^"");
	client_cmd(id,"bind ^"PGUP^" ^"bank_menu^"");
	client_cmd(id,"bind ^"INS^" ^"maxdep^"");
  
	return 1;
   }

  public client_disconnect(id) {
  g_has_custom_model[id] = false
  save2vault(id)

  }
  
  public client_putinserver(id){
	//������� ����� ��������������
	if (get_user_flags(id) & ADMIN_LEVEL_F){
		admin[id]=true
		}else{
		admin[id]=false
	}
	//������ ����� ��� �������
	if (get_user_flags(id) & ADMIN_LEVEL_G){
		girl[id]=true
		}else{
		girl[id]=false
	}
	//������ ����� ��� ����������
	if (get_user_flags(id) & ADMIN_LEVEL_H){
		clan[id]=true
		}else{
		clan[id]=false
	}
	//������ ����� ��� ������� �������������
	if (get_user_flags(id) & ADMIN_USER){
		user[id]=true
		}else{
		user[id]=false
	}
	
	
	for (new i=0;i<10;i++){
		admin_options[id][i]=true
	}
	load_vault_data(id);
	if(admin_options[id][MS_AUDIO_CONNECT] && admin_options[id][MS_AUDIO_ALL]){
	set_task(1.0,"Connect_Sound", id)
	}
	if(admin_options[id][MS_AUTO_MENU]){
	set_task(1.0,"cmd_esp_menu", id)
	}
	g_multiKills[id] = {0, 0}
	g_streakKills[id] = {0, 0}
}


  // ------------------------------------------------------------------------------------------
  // --PLUGIN PRECACHE------------------------------------------------------------------------
  // ------------------------------------------------------------------------------------------
  public plugin_precache() {

    // get custom models
    new models[50][65], num;
    num = get_models(models,64);

    // loop through them
    for(new i=0;i<num;i++) {
      new modelstring[256];
      format(modelstring,255,"models/player/%s/%s.mdl",models[i],models[i]);
      precache_model(modelstring);
      precache_generic("models/player/ms_clan_ct_1/ms_clan_ct_1T.mdl");
      precache_generic("models/player/ms_clan_ct_2/ms_clan_ct_2T.mdl");
      precache_generic("models/player/ms_clan_t_1/ms_clan_t_1T.mdl");
      precache_generic("models/player/ms_clan_t_2/ms_clan_t_2T.mdl");
      precache_generic("models/player/telepuz_ct/telepuz_ctT.mdl");
      precache_generic("models/player/telepuz_te/telepuz_teT.mdl");
      precache_generic("models/player/ms_admin_ct_1/ms_admin_ct_1T.mdl");
      precache_generic("models/player/ms_girl_ct_5/ms_girl_ct_5T.mdl");
      precache_generic("models/player/ms_clan_ct_4/ms_clan_ct_4T.mdl");
      
      
      //���� ��� ����� �� ������
      precache_sound("ms/start_1.mp3");
      precache_sound("ms/start_2.mp3");
      precache_sound("waw555/eight.wav");
      precache_sound("waw555/five.wav");
      precache_sound("waw555/four.wav");
      precache_sound("waw555/seven.wav");
      precache_sound("waw555/six.wav");
      precache_sound("waw555/ten.wav");
      precache_sound("waw555/thirty.wav");
      precache_sound("waw555/three.wav");
      precache_sound("waw555/twenty.wav");
      precache_sound("waw555/two.wav");
      precache_sound("waw555/nine.wav");
      precache_sound("waw555/one.wav");
      precache_sound("waw555/dropbomb.wav");
      precache_sound("waw555/firstblood001.wav");
      precache_sound("waw555/grenade.wav");
      precache_sound("waw555/021.wav");
      precache_sound("waw555/022.wav");
      precache_sound("waw555/023.wav");
      precache_sound("waw555/024.wav");
      precache_sound("waw555/025.wav");
      precache_sound("waw555/090.wav");
      precache_sound("waw555/080.wav");
      precache_sound("waw555/001.wav");
      precache_sound("waw555/002.wav");
      precache_sound("waw555/003.wav");
      precache_sound("waw555/004.wav");
      precache_sound("waw555/005.wav");
      precache_sound("waw555/006.wav");
      precache_sound("waw555/007.wav");
      precache_sound("waw555/031.wav");
      precache_sound("waw555/032.wav");
      precache_sound("waw555/033.wav");
      precache_sound("waw555/034.wav");
      precache_sound("waw555/035.wav");
      precache_sound("waw555/036.wav");
      precache_sound("waw555/037.wav");
      precache_sound("waw555/maytheforce001.wav");
      precache_sound("waw555/oneandonly001.mp3");
      precache_sound("waw555/humiliation001.wav");
      precache_sound("waw555/humiliation002.wav");
      precache_sound("waw555/girl.wav");
      precache_sound("waw555/2011.wav");
      precache_sound("waw555/2020.wav");
      precache_sound("waw555/2021.wav");
      precache_sound("waw555/2022.wav");
      precache_sound("waw555/2023.wav");
      precache_sound("waw555/tebe23.wav");
      precache_sound("waw555/tebe28.wav");
      precache_sound("waw555/tebe40.wav");
      precache_sound("waw555/tebe41.wav");
      precache_sound("waw555/tebe42.wav");
      precache_sound("waw555/tebe43.wav");
      precache_sound("waw555/teamkiller.wav");
      precache_sound("waw555/stoimwaw555.wav");
      precache_sound("waw555/mat/sob4ak.wav");
      precache_sound("waw555/ms_CheatOff.wav");
      precache_sound("waw555/ms_CheatOn.wav");
      precache_sound("waw555/matwarning3.wav");
      precache_sound("waw555/matwarning2.wav");
      precache_sound("waw555/holywaw555.wav");
      precache_sound("waw555/5001.wav");
      precache_sound("waw555/2012.wav");
      precache_sound("waw555/9002.wav");
      precache_sound("waw555/2013.wav");
      precache_sound("waw555/9004.wav");
      precache_sound("waw555/9005.wav");
      precache_sound("waw555/2003.wav");
      precache_sound("waw555/2004.wav");
      precache_sound("waw555/2005.wav");
      precache_sound("waw555/2006.wav");
      precache_sound("waw555/2007.wav");
      precache_sound("waw555/2008.wav");
      precache_sound("waw555/2009.wav");
      precache_sound("waw555/2010.wav");
      precache_sound("waw555/o4akovo.wav");
      
      //�������� ����� ��� ���� ������
      m_spriteTexture = precache_model("sprites/laserbeam.spr");
   }
  }

  public currmodel(player) {
    new model[65];
    cs_get_user_model(player,model,64);
    client_print(player,print_chat,"* ���� ������ %s",model);
    return PLUGIN_HANDLED;
  }

  // ------------------------------------------------------------------------------------------
  // --PLUGIN ININITATION---------------------------------------------------------------------
  // ------------------------------------------------------------------------------------------
  public plugin_init() {

    register_plugin("���� �������","0.1","WAW555");

    register_event("TextMsg", "Change_Team", "a", "1=1", "2&Game_join_te", "2&Game_join_ct");
    register_clcmd("ms_model","usermodel",-1,"���� �������");
    //register_event("ResetHUD","event_resethud","b");
    register_clcmd("say /model","currmodel",-1);
    
    register_forward( FM_SetClientKeyValue, "fw_SetClientKeyValue" );
    register_forward( FM_ClientUserInfoChanged, "fw_ClientUserInfoChanged" );
    register_event( "HLTV", "event_round_start", "a", "1=0", "2=0" );
    RegisterHam( Ham_Spawn, "player", "fw_PlayerSpawn", 1 );
    register_dictionary("miscstats.txt")
    register_event("TextMsg", "eRestart", "a", "2&#Game_C", "2&#Game_w")
    register_event("SendAudio", "eEndRound", "a", "2&%!MRAD_terwin", "2&%!MRAD_ctwin", "2&%!MRAD_rounddraw")
    register_event("RoundTime", "eNewRound", "bc")
    register_event("StatusValue", "setTeam", "be", "1=1")
    register_event("StatusValue", "showStatus", "be", "1=2", "2!0")
    register_event("StatusValue", "hideStatus", "be", "1=1", "2=0")
    
    new mapname[32];
    get_mapname(mapname, 31)

    if (equali(mapname, "de_", 3) || equali(mapname, "csde_", 5))
    {
	register_event("StatusIcon", "eGotBomb", "be", "1=1", "1=2", "2=c4")
	register_event("TextMsg", "eBombPickUp", "bc", "2&#Got_bomb")
	register_event("TextMsg", "eBombDrop", "bc", "2&#Game_bomb_d")
	}
	else if (equali(mapname, "cs_italy"))
	{
	register_event("23", "chickenKill", "a", "1=108", /*"12=106", */ "15=4")
	register_event("23", "radioKill", "a", "1=108", /*"12=294", */ "15=2")
	}else if (equali(mapname, "zm_", 3)){
	pause ( "ac", "ms_model.amxx" );
	}

    g_center1_sync = CreateHudSyncObj()
    g_announce_sync = CreateHudSyncObj()
    g_status_sync = CreateHudSyncObj()
    g_left_sync = CreateHudSyncObj()
    g_bottom_sync = CreateHudSyncObj()
    g_he_sync = CreateHudSyncObj()

   

    // ������������ ID ����
    new menu1ID = register_menuid("Menu_Admin_CT");
    new menu2ID = register_menuid("Menu_Admin_T");
    new menu3ID = register_menuid("Menu_Girl_CT");
    new menu4ID = register_menuid("Menu_Girl_T");
    new menu5ID = register_menuid("Menu_Clan_CT");
    new menu6ID = register_menuid("Menu_Clan_T");
    new menu7ID = register_menuid("Menu_User_CT");
    new menu8ID = register_menuid("Menu_User_T");
    new menu9ID = register_menuid("Audio_Settings");
    new menu10ID = register_menuid("Audio_Settings1");
    new menu11ID = register_menuid("Audio_Settings2");


    // ������������ ������� ����
    register_menucmd(menu1ID,1023,"Menu_Admin_CT_Action");
    register_menucmd(menu2ID,1023,"Menu_Admin_T_Action");
    register_menucmd(menu3ID,511,"Menu_Girl_CT_Action");
    register_menucmd(menu4ID,511,"Menu_Girl_T_Action");
    register_menucmd(menu5ID,511,"Menu_Clan_CT_Action");
    register_menucmd(menu6ID,511,"Menu_Clan_T_Action");
    register_menucmd(menu7ID,511,"Menu_User_CT_Action");
    register_menucmd(menu8ID,511,"Menu_User_T_Action");
    register_menucmd(menu9ID,1023,"Audio_Settings_Action");
    register_menucmd(menu10ID,1023,"Audio_Settings_Action1");
    register_menucmd(menu11ID,1023,"Audio_Settings_Action2");
    //�������
    set_task( 30.0, "Reklama", _,_,_,_, 1);
    

    
    pcvar_ms=register_cvar("ms","1")//��������� ���������� �������
    pcvar_help=register_cvar("ms_help","1")//���������� ������� ��� ���
    register_clcmd("say /menu","cmd_esp_menu",-1);
    //��� ������
    register_cvar("amx_deathbeams_enabled","1")//�������� ��������� ����� ������ �����
    register_cvar("amx_deathbeams_randcolor","0")//���� ������
    register_event("DeathMsg","death","a")//������� ������ ������
    //����������� �����������
    register_event("Damage", "damage_message", "b", "2!0", "3=0", "4!0")
    g_HudSync = CreateHudSyncObj()
    register_clcmd("settings","cmd_esp_menu",-1,"�������� ���� ��������")
    //����
    new keys=MENU_KEY_0|MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9//������
    register_menucmd(register_menuid("���� ��������"),keys,"menu_esp")
    max_players=get_maxplayers()
  }
  // ------------------------------------------------------------------------------------------
  // --Set stats---------------------------------------------------------------------
  // ------------------------------------------------------------------------------------------
  public usermodel(player) {
	new izStats[8], izBody[8];
	new iRankPos;
	new stim[16]
	get_user_authid(player, stim, sizeof stim -1)

	if(equal(stim, "VALVE_ID_LAN")
	|| equal(stim, "VALVE_ID_PENDING")
	|| equal(stim, "STEAM_666:88:666")
	|| equal(stim, "STEAM_ID_PENDING")
	|| equal(stim, "STEAM_ID_LAN") ){
	fm_reset_user_model(player);
	return PLUGIN_HANDLED;
	}else{
	iRankPos = get_user_stats(player, izStats, izBody);
	if(iRankPos == 1 || iRankPos == 2 || iRankPos == 3 || iRankPos == 4 || iRankPos == 5 || iRankPos == 6 || iRankPos == 7 || iRankPos == 8 || iRankPos == 9 || iRankPos == 10 || iRankPos == 11 || iRankPos == 12 || iRankPos == 13 || iRankPos == 14 || iRankPos == 15) {
	return Show_Menu_Level(player);
	}else if ((get_user_flags(player) & ADMIN_LEVEL_F) || (get_user_flags(player) & ADMIN_LEVEL_G) || (get_user_flags(player) & ADMIN_LEVEL_H)) {
	return Show_Menu_Level(player);
	}else{
	client_print(player,print_chat,"��� ���� %d, �������� � ���15, ����� �������� ����",iRankPos);
	}
	}
	return PLUGIN_HANDLED;
}

/*================================================================================
 [������ ������]
=================================================================================*/

public event_round_start()
{
    g_roundstarttime = get_gametime()
    
}

/*================================================================================
 [����������� ������]
=================================================================================*/

public fw_PlayerSpawn( player ){
	if(admin_options[player][MS_MODEL]){
	client_cmd(player,"cl_minmodels 0;alias cl_minmodels");
	}else{
	client_cmd(player,"cl_minmodels 1;alias cl_minmodels");
	}
    // ������� �������������� ������ ���� ��������
	remove_task( player + MODELSET_TASK )
	// ������� ��������� �� ������
			

    // Check whether the player is a zombie
    // ��������� ����� �� ����� �������� ������
    //if ( g_zombie[id] )
	if ( g_has_custom_model[player] ){   
        // �������� ������� ������
		new currentmodel[32]
		fm_get_user_model( player, currentmodel, charsmax( currentmodel ) )
			// ������� ��������� �� ������
		if ( !equal( currentmodel, g_player_model[player] ) ){
            // �������������� �������� � ������ ������ ���� ������� ������
            // ��������� ������ SVC_BAD ������� ��������� ����� ���������
		if ( get_gametime() - g_roundstarttime < 5.0 ){
		set_task( 5.0 * MODELCHANGE_DELAY, "fm_user_model_update", player + MODELSET_TASK )
		}else{
		fm_user_model_update( player + MODELSET_TASK )
		}
		}
				// ���� �������� ������ ��� �� ���������� ������
				}else{ 
				fm_reset_user_model( player )
				}
	}


/*================================================================================
 [�������������� ���������]
=================================================================================*/

public fw_SetClientKeyValue( player, const infobuffer[], const key[] )
{   
    // ��������� ����� ������
    if ( g_has_custom_model[player] && equal( key, "model" ) )
        return FMRES_SUPERCEDE;
    
    return FMRES_IGNORED;
}

public fw_ClientUserInfoChanged( player )
{
    // ���� ����� �� ����� �������� ������
    if ( !g_has_custom_model[player] )
        return FMRES_IGNORED;
    
    // Get current model
    static currentmodel[32]
    fm_get_user_model( player, currentmodel, charsmax( currentmodel ) )
    
    // ��������� ������ ������ ���� ��� �� �������� �� ������������� ��������
    if ( !equal( currentmodel, g_player_model[player] ) && !task_exists( player + MODELSET_TASK ) )
        fm_set_user_model( player + MODELSET_TASK )
    
    return FMRES_IGNORED;
}

/*================================================================================
 [������]
=================================================================================*/

public fm_user_model_update( taskid )
{
    static Float:current_time
    current_time = get_gametime()
    
    // ����� �� �������� ��������� ������
    if ( current_time - g_models_targettime >= MODELCHANGE_DELAY )
    {
        fm_set_user_model( taskid )
        g_models_targettime = current_time
    }
    else
    {
        set_task( (g_models_targettime + MODELCHANGE_DELAY) - current_time, "fm_set_user_model", taskid )
        g_models_targettime = g_models_targettime + MODELCHANGE_DELAY
    }
}

public fm_set_user_model( player )
{
    // Get actual player id
    player -= MODELSET_TASK
    
    // Set new model
    engfunc( EngFunc_SetClientKeyValue, player, engfunc( EngFunc_GetInfoKeyBuffer, player ), "model", g_player_model[player] )
    
    // Remember this player has a custom model
    g_has_custom_model[player] = true
}

/*================================================================================
 [Stocks]
=================================================================================*/

stock fm_get_user_model( player, model[], len )
{
    // Retrieve current model
    engfunc( EngFunc_InfoKeyValue, engfunc( EngFunc_GetInfoKeyBuffer, player ), "model", model, len )
}

stock fm_reset_user_model( player )
{
    client_print(player, print_chat, "����������� ����������� ������");
    // Player doesn't have a custom model any longer
    g_has_custom_model[player] = false
    
    dllfunc( DLLFunc_ClientUserInfoChanged, player, engfunc( EngFunc_GetInfoKeyBuffer, player ) )
}

public Change_Team() //��������� ������ �� ����� ��������
{
		new s_Name[32], player //��� ������ � ID ������
		read_data(3, s_Name, charsmax(s_Name)) //��������� ������ ������
		player = get_user_index(s_Name) // �������� ID ������
		fm_reset_user_model(player);//���������� ������ ������
		set_task( 5.0, "usermodel", player );//��������� ���� ��� ����� ������
}

public Reklama()//������� ������� � �������
{
	client_print(0, print_chat, "����� ���������� �� ������� ������ @@@����� - ���@@@");
}



public Connect_Sound(id)//������ ��� ����� ������ �� ������
{
	client_cmd(id, "mp3 play sound/ms/start_%d", random_num(1,2));
}

/*================================================================================
 ����������� �����������
=================================================================================*/
public damage_message(player){
	for (new i=1;i<=max_players;i++){
		new attacker = get_user_attacker(player)
	
		if (is_user_connected(attacker) && admin_options[attacker][MS_DAMAGE_MSG])
		{
			new damage = read_data(2)
			set_hudmessage(200, 200, 200, -1.0, 0.55, 2, 0.1, 4.0, 0.02, 0.02, -1)
			ShowSyncHudMsg(attacker, g_HudSync, "%i^n", damage)
		}
	     }
}

/*================================================================================
 ��� ������
=================================================================================*/
public death(){
	
	for (new id=1;id<=max_players;id++){
	
	
	new player_num = 0                          // A Player incrementer.
	new maxpl = get_maxplayers()+1              // Max players.
	new killer_id = read_data(1)                // Killer's player ID.
	new victim_id = read_data(2)                // Victim's player ID.
	new killer_team = get_user_team(killer_id)  // The team the killer's on.

	if (get_cvar_num("amx_deathbeams_enabled") == 1)
	{
		if (!is_user_alive(victim_id) && admin_options[victim_id][MS_DEATH_LINE]){
		if (killer_id!=victim_id && killer_id)
		{
			new k_origin[3]
			new v_origin[3]
			get_user_origin(killer_id,k_origin)
			get_user_origin(victim_id,v_origin)
			
			for(player_num = 1;player_num < maxpl; player_num++)
			{
				if(is_user_alive(player_num)==0 && get_user_time(player_num)!= 0 && admin_options[player_num][MS_DEATH_LINE])
				{
					message_begin(MSG_ONE, SVC_TEMPENTITY,{0,0,0},player_num)
					write_byte( TE_BEAMPOINTS )
					write_coord(k_origin[0])
					write_coord(k_origin[1])
					write_coord(k_origin[2])
					write_coord(v_origin[0])
					write_coord(v_origin[1])
					write_coord(v_origin[2])
					write_short( m_spriteTexture )
					write_byte( 1 )   // framestart
					write_byte( 1 )   // framerate
					write_byte( 100 ) // life in 0.1's
					write_byte( 25 )  // width
					write_byte( 0 )   // noise

					// Set the color of the beam.
					if (get_cvar_num("amx_deathbeams_randcolor") == 1)
					{
						write_byte( random_num(50,255) ) // red
						write_byte( random_num(50,255) )   // green
						write_byte( random_num(50,255) )   // blue
					}
					else
					{
						if (killer_team == 1)
						{ // Terrorist
							write_byte( 255 ) // red
							write_byte( 0 )   // green
							write_byte( 0 )   // blue
						}
						else
						{ // Counter-terrorist
							write_byte( 0 )   // red
							write_byte( 0 )   // green
							write_byte( 255 )   // blue
					      	}
					}
					write_byte( 100 ) // brightness
					write_byte( 0 )   // speed
					message_end()
				}
			}
		}
	}
}
}
}


/*================================================================================
 �������� ��������
=================================================================================*/
public load_vault_data(id){
	new data[31]
	new authid[35]
	get_user_authid (id,authid,34)
	new key[41]
	format(key,40,"MS_%s",authid)
	get_vaultdata(key,data,30)
	if (strlen(data)>0){
		for (new s=0;s<30;s++){
			if (data[s]=='1'){
				admin_options[id][s]=true
			}else{
				admin_options[id][s]=false
			}
		}
	}
}

/*================================================================================
 ���������� ��������
=================================================================================*/
public save2vault(id){
		new authid[35]
		get_user_authid (id,authid,34) 
		new tmp[31]
	
		for (new s=0;s<30;s++){
		
			if (admin_options[id][s]){
				tmp[s]='1';
			}else{
				tmp[s]='0';
			}
		}
		tmp[30]=0

		//server_print("STEAMID: %s OPTIONS: %s",authid,tmp);
		new key[41]
		format(key,40,"MS_%s",authid) 
		
		set_vaultdata(key,tmp)
	}

/*================================================================================
 ��������� �������� ����
=================================================================================*/
public cmd_esp_menu(id){
	if (get_pcvar_num(pcvar_ms)==1){
		show_esp_menu(id)
	}
}

public plugin_cfg()
{
	new g_addStast[] = "amx_statscfg add ^"%s^" %s"
	
	server_cmd(g_addStast, "ST_MULTI_KILL", "MultiKill")
	server_cmd(g_addStast, "ST_MULTI_KILL_SOUND", "MultiKillSound")
	server_cmd(g_addStast, "ST_BOMB_PLANTING", "BombPlanting")
	server_cmd(g_addStast, "ST_BOMB_DEFUSING", "BombDefusing")
	server_cmd(g_addStast, "ST_BOMB_PLANTED", "BombPlanted")
	server_cmd(g_addStast, "ST_BOMB_DEF_SUCC", "BombDefused")
	server_cmd(g_addStast, "ST_BOMB_DEF_FAIL", "BombFailed")
	server_cmd(g_addStast, "ST_BOMB_PICKUP", "BombPickUp")
	server_cmd(g_addStast, "ST_BOMB_DROP", "BombDrop")
	server_cmd(g_addStast, "ST_BOMB_CD_VOICE", "BombCountVoice")
	server_cmd(g_addStast, "ST_BOMB_CD_DEF", "BombCountDef")
	server_cmd(g_addStast, "ST_BOMB_SITE", "BombReached")
	server_cmd(g_addStast, "ST_ITALY_BONUS", "ItalyBonusKill")
	server_cmd(g_addStast, "ST_LAST_MAN", "LastMan")
	server_cmd(g_addStast, "ST_KNIFE_KILL", "KnifeKill")
	server_cmd(g_addStast, "ST_KNIFE_KILL_SOUND", "KnifeKillSound")
	server_cmd(g_addStast, "ST_HE_KILL", "GrenadeKill")
	server_cmd(g_addStast, "ST_HE_SUICIDE", "GrenadeSuicide")
	server_cmd(g_addStast, "ST_HS_KILL", "HeadShotKill")
	server_cmd(g_addStast, "ST_HS_KILL_SOUND", "HeadShotKillSound")
	server_cmd(g_addStast, "ST_ROUND_CNT", "RoundCounter")
	server_cmd(g_addStast, "ST_ROUND_CNT_SOUND", "RoundCounterSound")
	server_cmd(g_addStast, "ST_KILL_STR", "KillingStreak")
	server_cmd(g_addStast, "ST_KILL_STR_SOUND", "KillingStreakSound")
	server_cmd(g_addStast, "ST_ENEMY_REM", "EnemyRemaining")
	server_cmd(g_addStast, "ST_DOUBLE_KILL", "DoubleKill")
	server_cmd(g_addStast, "ST_DOUBLE_KILL_SOUND", "DoubleKillSound")
	server_cmd(g_addStast, "ST_PLAYER_NAME", "PlayerName")
	server_cmd(g_addStast, "ST_FIRST_BLOOD_SOUND", "FirstBloodSound")
}

public client_death(killer, victim, wpnindex, hitplace, TK)
{
	if (wpnindex == CSW_C4)
		return

	new headshot = (hitplace == HIT_HEAD) ? 1 : 0
	new selfkill = (killer == victim) ? 1 : 0

	if (g_firstBlood)
	{
		g_firstBlood = 0
		if (FirstBloodSound){
			new players[32], pnum
			get_players(players, pnum, "c")
			new i
	
			for (i = 0; i < pnum; i++)
			{
			if (is_user_connecting(players[i]) && admin_options[players[i]][MS_AUDIO_ALL] && admin_options[players[i]][MS_AUDIO_FIRSTBLOOD])
			continue
		
			client_cmd(players[i], "spk sound/waw555/firstblood001")
			}
		}
	}

	if ((KillingStreak || KillingStreakSound) && !TK)
	{
		g_streakKills[victim][1]++
		g_streakKills[victim][0] = 0

		if (!selfkill)
		{
			g_streakKills[killer][0]++
			g_streakKills[killer][1] = 0
			
			new a = g_streakKills[killer][0] - 3

			if ((a > -1) && !(a % 2))
			{
				new name[32]
				get_user_name(killer, name, 31)
				
				if ((a >>= 1) > 6)
					a = 6
				
				if (KillingStreak)
				{
					set_hudmessage(0, 100, 255, 0.05, 0.50, 2, 0.02, 6.0, 0.01, 0.1, -1)
					ShowSyncHudMsg(0, g_left_sync, g_KillingMsg[a], name)
				}
				
				if (KillingStreakSound)
				{
					if (get_user_flags(killer) & ADMIN_LEVEL_B){
						
						new players[32], pnum
						get_players(players, pnum, "c")
						new i
	
						for (i = 0; i < pnum; i++)
						{
						if (is_user_connecting(players[i]) && admin_options[players[i]][MS_AUDIO_ALL] && admin_options[players[i]][MS_AUDIO_ADMIN_STEPS])
						continue
		
						client_cmd(players[i], "spk sound/waw555/%s",g_Sounds_Admin[a])
						}
					}else if (get_user_flags(killer) & ADMIN_LEVEL_C){
												
						new players[32], pnum
						get_players(players, pnum, "c")
						new i
	
						for (i = 0; i < pnum; i++)
						{
						if (is_user_connecting(players[i]) && admin_options[players[i]][MS_AUDIO_ALL] && admin_options[players[i]][MS_AUDIO_GIRL_STEPS])
						continue
		
						client_cmd(players[i], "spk sound/waw555/%s",g_Sounds_Girl[a])
						}
					}else{
						
						new players[32], pnum
						get_players(players, pnum, "c")
						new i
	
						for (i = 0; i < pnum; i++)
						{
						if (is_user_connecting(players[i]) && admin_options[players[i]][MS_AUDIO_ALL] && admin_options[players[i]][MS_AUDIO_USER_STEPS])
						continue
		
						client_cmd(players[i], "spk sound/waw555/%s",g_Sounds[a])
						}
					}
				}
			}
		}
	}

	if (MultiKill || MultiKillSound)
	{
		if (!selfkill && !TK && killer)
		{
			g_multiKills[killer][0]++ 
			g_multiKills[killer][1] += headshot
			
			new param[2]
			
			param[0] = killer
			param[1] = g_multiKills[killer][0]
			set_task(4.0 + float(param[1]), "checkKills", 0, param, 2)
		}
	}

	if (EnemyRemaining && is_user_connected(victim))
	{
		new ppl[32], pplnum = 0, maxplayers = get_maxplayers()
		new epplnum = 0
		new CsTeams:team = cs_get_user_team(victim)
		new CsTeams:other_team
		new CsTeams:enemy_team = (team == CS_TEAM_T) ? CS_TEAM_CT : CS_TEAM_T
		
		if (team == CS_TEAM_T || team == CS_TEAM_CT)
		{
			for (new i=1; i<=maxplayers; i++)
			{
				if (!is_user_connected(i))
				{
					continue
				}
				if (i == victim)
				{
					continue
				}
				other_team = cs_get_user_team(i)
				if (other_team == team && is_user_alive(i))
				{
					epplnum++
				} else if (other_team == enemy_team) {
					ppl[pplnum++] = i
				}
			}
			
			if (pplnum && epplnum)
			{
				new message[128], team_name[32]

				set_hudmessage(255, 255, 255, 0.02, 0.85, 2, 0.05, 0.1, 0.02, 3.0, -1)
				
				/* This is a pretty stupid thing to translate, but whatever */
				new _teamname[32]
				if (team == CS_TEAM_T)
				{
					format(_teamname, 31, "TERRORIST%s", (epplnum == 1) ? "" : "S")
				} else if (team == CS_TEAM_CT) {
					format(_teamname, 31, "CT%s", (epplnum == 1) ? "" : "S")
				}

				for (new a = 0; a < pplnum; ++a)
				{
					format(team_name, 31, "%L", ppl[a], _teamname)
					format(message, 127, "%L", ppl[a], "REMAINING", epplnum, team_name)
					ShowSyncHudMsg(ppl[a], g_bottom_sync, "%s", message)
				}
			}
		}
	}

	if (LastMan)
	{
		new cts[32], ts[32], ctsnum, tsnum
		new maxplayers = get_maxplayers()
		new CsTeams:team
		
		for (new i=1; i<=maxplayers; i++)
		{
			if (!is_user_connected(i) || !is_user_alive(i))
			{
				continue
			}
			team = cs_get_user_team(i)
			if (team == CS_TEAM_T)
			{
				ts[tsnum++] = i
			} else if (team == CS_TEAM_CT) {
				cts[ctsnum++] = i
			}
		}
		
		if (ctsnum == 1 && tsnum == 1)
		{
			new ctname[32], tname[32]
			
			get_user_name(cts[0], ctname, 31)
			get_user_name(ts[0], tname, 31)
			
			set_hudmessage(0, 255, 255, -1.0, 0.35, 0, 6.0, 6.0, 0.5, 0.15, -1)
			ShowSyncHudMsg(0, g_center1_sync, "%s vs. %s", ctname, tname)
			
			new players[32], pnum
			get_players(players, pnum, "c")
			new i
	
			for (i = 0; i < pnum; i++)
			{
			if (is_user_connecting(players[i]) && admin_options[players[i]][MS_AUDIO_ALL] && admin_options[players[i]][MS_AUDIO_ONE_VS_ONE])
			continue
		
			client_cmd(players[i], "spk sound/waw555/maytheforce001")
			}
		}
		else if (!g_LastAnnounce)
		{
			new oposite = 0, _team = 0
			
			if (ctsnum == 1 && tsnum > 1)
			{
				g_LastAnnounce = cts[0]
				oposite = tsnum
				_team = 0
			}
			else if (tsnum == 1 && ctsnum > 1)
			{
				g_LastAnnounce = ts[0]
				oposite = ctsnum
				_team = 1
			}

			if (g_LastAnnounce)
			{
				new name[32]
				
				get_user_name(g_LastAnnounce, name, 31)
				
				set_hudmessage(0, 255, 255, -1.0, 0.38, 0, 6.0, 6.0, 0.5, 0.15, -1)
				ShowSyncHudMsg(0, g_center1_sync, "%s (%d HP) vs. %d %s%s: %L", name, get_user_health(g_LastAnnounce), oposite, g_teamsNames[_team], (oposite == 1) ? "" : "S", LANG_PLAYER, g_LastMessages[random_num(0, 3)])
				
				if (!is_user_connecting(g_LastAnnounce))
				{
					if (is_user_connecting(g_LastAnnounce) && admin_options[g_LastAnnounce][MS_AUDIO_ALL] && admin_options[g_LastAnnounce][MS_AUDIO_ONE_VS_ALL])
					client_cmd(g_LastAnnounce, "mp3 play sound/waw555/oneandonly001")
				}
			}
		}
	}

	if (wpnindex == CSW_KNIFE && (KnifeKill || KnifeKillSound))
	{
		if (KnifeKill)
		{
			new killer_name[32], victim_name[32]
			
			get_user_name(killer, killer_name, 31)
			get_user_name(victim, victim_name, 31)
			
			set_hudmessage(255, 100, 100, -1.0, 0.25, 1, 6.0, 6.0, 0.5, 0.15, -1)
			ShowSyncHudMsg(0, g_he_sync, "%L", LANG_PLAYER, g_KinfeMsg[random_num(0, 3)], killer_name, victim_name)
		}
		
		if (KnifeKillSound){
			if (get_user_flags(killer) & ADMIN_LEVEL_F){
				new players[32], pnum
				get_players(players, pnum, "c")
				new i
	
				for (i = 0; i < pnum; i++)
				{
				if (is_user_connecting(players[i]) && admin_options[players[i]][MS_AUDIO_ALL] && admin_options[players[i]][MS_AUDIO_ADMIN_KNIFE])
				continue
		
				client_cmd(players[i], "spk sound/waw555/humiliation001.wav")
				}
				}else{
				new players[32], pnum
				get_players(players, pnum, "c")
				new i
	
				for (i = 0; i < pnum; i++)
				{
				if (is_user_connecting(players[i]) && admin_options[players[i]][MS_AUDIO_ALL] && admin_options[players[i]][MS_AUDIO_USER_KNIFE])
				continue
		
				client_cmd(players[i], "spk sound/waw555/humiliation002.wav")
				}
			}
		}
	}

	if (wpnindex == CSW_HEGRENADE && (GrenadeKill || GrenadeSuicide))
	{
		new killer_name[32], victim_name[32]
		
		get_user_name(killer, killer_name, 31)
		get_user_name(victim, victim_name, 31)
		
		set_hudmessage(255, 100, 100, -1.0, 0.25, 1, 6.0, 6.0, 0.5, 0.15, -1)
		
		if (!selfkill)
		{
			if (GrenadeKill){
				ShowSyncHudMsg(0, g_he_sync, "%L", LANG_PLAYER, g_HeMessages[random_num(0, 3)], killer_name, victim_name)
				new players[32], pnum
				get_players(players, pnum, "c")
				new i
	
				for (i = 0; i < pnum; i++)
				{
				if (is_user_connecting(players[i]) && admin_options[players[i]][MS_AUDIO_ALL] && admin_options[players[i]][MS_AUDIO_GRENADE])
				continue
		
				client_cmd(players[i], "spk sound/waw555/grenade")
				}
			}
		}
		else if (GrenadeSuicide)
			{
				ShowSyncHudMsg(0, g_he_sync, "%L", LANG_PLAYER, g_SHeMessages[random_num(0, 3)], victim_name)
				new players[32], pnum
				get_players(players, pnum, "c")
				new i
	
				for (i = 0; i < pnum; i++)
				{
				if (is_user_connecting(players[i]) && admin_options[players[i]][MS_AUDIO_ALL] && admin_options[players[i]][MS_AUDIO_GRENADE_SUICIDE])
				continue
		
				client_cmd(players[i], "spk sound/waw555/grenade")
				}
			}
	}

	if (headshot && (HeadShotKill || HeadShotKillSound))
	{
		if (HeadShotKill && wpnindex)
		{
			new killer_name[32], victim_name[32], weapon_name[32], message[256], players[32], pnum
			
			xmod_get_wpnname(wpnindex, weapon_name, 31)
			get_user_name(killer, killer_name, 31)
			get_user_name(victim, victim_name, 31)
			get_players(players, pnum, "c")
			
			for (new i = 0; i < pnum; i++)
			{
				format(message, sizeof(message)-1, "%L", players[i], g_HeadShots[random_num(0, 6)])
				
				replace(message, sizeof(message)-1, "$vn", victim_name)
				replace(message, sizeof(message)-1, "$wn", weapon_name)
				replace(message, sizeof(message)-1, "$kn", killer_name)
				
				set_hudmessage(100, 100, 255, -1.0, 0.30, 0, 6.0, 6.0, 0.5, 0.15, -1)
				ShowSyncHudMsg(players[i], g_announce_sync, "%s", message)
			}
		}
		
		if (HeadShotKillSound)
		{
			if (is_user_connecting(killer) && admin_options[killer][MS_AUDIO_ALL] && admin_options[killer][MS_AUDIO_HEADSHOOT_KILLER])
			client_cmd(killer, "spk sound/waw555/headshot001")
			if (is_user_connecting(killer) && admin_options[victim][MS_AUDIO_ALL] && admin_options[victim][MS_AUDIO_HEADSHOOT_VICTIM])
			client_cmd(victim, "spk sound/waw555/headshot002")
		}
	}

	if ((DoubleKill || DoubleKillSound) && !selfkill)
	{
		new Float:nowtime = get_gametime()
		
		if (g_doubleKill == nowtime && g_doubleKillId == killer)
		{
			if (DoubleKill)
			{
				new name[32]
				
				get_user_name(killer, name, 31)
				
				set_hudmessage(255, 0, 255, -1.0, 0.35, 0, 6.0, 6.0, 0.5, 0.15, -1)
				ShowSyncHudMsg(0, g_center1_sync, "%L", LANG_PLAYER, "DOUBLE_KILL", name)
			}
			
			if (DoubleKillSound)
			{
				new players[32], pnum
				get_players(players, pnum, "c")
				new i
	
				for (i = 0; i < pnum; i++)
				{
				if (is_user_connecting(players[i]) && admin_options[players[i]][MS_AUDIO_ALL] && admin_options[players[i]][MS_AUDIO_DOUBLE_KILL])
				continue
		
				client_cmd(players[i], "spk sound/waw555/080")
				}
			}
		}
		
		g_doubleKill = nowtime
		g_doubleKillId = killer
	}
}

public hideStatus(id)
{
	if (PlayerName)
	{
		ClearSyncHud(id, g_status_sync)
	}
}

public setTeam(id)
	g_friend[id] = read_data(2)

public showStatus(id)
{
	if(!is_user_bot(id) && is_user_connected(id) && PlayerName) 
	{
		new name[32], pid = read_data(2)
	
		get_user_name(pid, name, 31)
		new color1 = 0, color2 = 0
	
		if (get_user_team(pid) == 1)
			color1 = 255
		else
			color2 = 255
		
		if (g_friend[id] == 1)	// friend
		{
			new clip, ammo, wpnid = get_user_weapon(pid, clip, ammo)
			new wpnname[32]
		
			if (wpnid)
				xmod_get_wpnname(wpnid, wpnname, 31)
		
			set_hudmessage(color1, 50, color2, -1.0, 0.60, 1, 0.01, 3.0, 0.01, 0.01, -1)
			ShowSyncHudMsg(id, g_status_sync, "%s -- %d HP / %d AP / %s", name, get_user_health(pid), get_user_armor(pid), wpnname)
		} else {
			set_hudmessage(color1, 50, color2, -1.0, 0.60, 1, 0.01, 3.0, 0.01, 0.01, -1)
			ShowSyncHudMsg(id, g_status_sync, "%s", name)
		}
	}
}

public eNewRound()
{
	if (read_data(1) == floatround(get_cvar_float("mp_roundtime") * 60.0,floatround_floor))
	{
		g_firstBlood = 1
		g_C4Timer = 0
		++g_roundCount
		
		new htime[6]
		
		get_time("%H",htime,5)
		
		if (RoundCounter)
		{
			set_hudmessage(200, 0, 0, -1.0, 0.30, 0, 6.0, 6.0, 0.5, 0.15, -1)
			ShowSyncHudMsg(0, g_announce_sync, "%L", LANG_PLAYER, "PREPARE_FIGHT", g_roundCount)
		}
		
		if (RoundCounterSound)
		{
			new players[32], pnum
			get_players(players, pnum, "c")
			new i
	
			for (i = 0; i < pnum; i++)
			{
			if (is_user_connecting(players[i]) && admin_options[players[i]][MS_AUDIO_ALL] && admin_options[players[i]][MS_AUDIO_PREPARE])
			continue
		
			client_cmd(players[i], "spk sound/waw555/prepare")
			}
		}
		
		if (KillingStreak)
		{
			new appl[32], ppl, i
			get_players(appl, ppl, "ac")
			
			for (new a = 0; a < ppl; ++a)
			{
				i = appl[a]
				
				if (g_streakKills[i][0] >= 2)
					client_print(i, print_chat, "* %L", i, "KILLED_ROW", g_streakKills[i][0])
				else if (g_streakKills[i][1] >= 2)
					client_print(i, print_chat, "* %L", i, "DIED_ROUNDS", g_streakKills[i][1])
			}
		}
	}
}

public eRestart()
{
	eEndRound()
	g_roundCount = 0
	g_firstBlood = 1
}

public eEndRound()
{
	g_C4Timer = -2
	g_LastOmg = 0.0
	remove_task(8038)
	g_LastAnnounce = 0
	new players[32], pnum
	get_players(players, pnum, "c")
	new i
	for (i = 0; i < pnum; i++)
	{
	if (is_user_connecting(players[i]) && admin_options[players[i]][MS_AUDIO_ALL] && admin_options[players[i]][MS_AUDIO_ROUND_END])
	continue	
	client_cmd(players[i], "spk sound/waw555/round_end%d.wav", random_num(1,3))
	}
}

public checkKills(param[])
{
	new id = param[0]
	new a = param[1]
	
	if (a == g_multiKills[id][0])
	{
		a -= 3
		
		if (a > -1)
		{
			if (a > 6)
			{
				a = 6
			}
			
			if (MultiKill)
			{
				new name[32]
				
				get_user_name(id, name, 31)
				set_hudmessage(255, 0, 100, 0.05, 0.50, 2, 0.02, 6.0, 0.01, 0.1, -1)
				
				ShowSyncHudMsg(0, g_left_sync, g_MultiKillMsg[a], name, LANG_PLAYER, "WITH", g_multiKills[id][0], LANG_PLAYER, "KILLS", g_multiKills[id][1], LANG_PLAYER, "HS")
			}
			
			if (MultiKillSound)
			{
				new players[32], pnum
				new sound[24]
				format(sound, 23, "sound/waw555/%s", g_Sounds[a])
				get_players(players, pnum, "c")
				new i
	
				for (i = 0; i < pnum; i++)
				{
				if (is_user_connecting(players[i]) && admin_options[players[i]][MS_AUDIO_ALL] && admin_options[players[i]][MS_AUDIO_MULTI_KILL])
				continue
		
				client_cmd(players[i], "spk sound/waw555/%s", sound)
				}
			}
		}
		g_multiKills[id] = {0, 0}
	}
}

public chickenKill()
{
	if (ItalyBonusKill)
		announceEvent(0, "KILLED_CHICKEN")
}

public radioKill()
{
	if (ItalyBonusKill)
		announceEvent(0, "BLEW_RADIO")
}

announceEvent(id, message[])
{
	new name[32]
	
	get_user_name(id, name, 31)
	set_hudmessage(255, 100, 50, -1.0, 0.30, 0, 6.0, 6.0, 0.5, 0.15, -1)
	ShowSyncHudMsg(0, g_announce_sync, "%L", LANG_PLAYER, message, name)
}

public eBombPickUp(id)
{
	if (BombPickUp){
		announceEvent(id, "PICKED_BOMB")
		new players[32], pnum
		get_players(players, pnum, "c")
		new i
	
		for (i = 0; i < pnum; i++)
		{
		if (is_user_connecting(players[i]) && admin_options[players[i]][MS_AUDIO_ALL] && admin_options[players[i]][MS_AUDIO_PICKED_BOMB])
		continue
		
		client_cmd(players[i], "spk sound/waw555/090")
		}
	}
}

public eBombDrop()
{
	if (BombDrop)
		announceEvent(g_Planter, "DROPPED_BOMB")
}

public eGotBomb(id)
{
	g_Planter = id
	
	if (BombReached && read_data(1) == 2 && g_LastOmg < get_gametime())
	{
		g_LastOmg = get_gametime() + 15.0
		announceEvent(g_Planter, "REACHED_TARGET")
	}
}

public bombTimer()
{
	if (--g_C4Timer > 0)
	{
		if (BombCountVoice)
		{
			if (g_C4Timer == 30 || g_C4Timer == 20)
			{
				new temp[64]
				
				num_to_word(g_C4Timer, temp, 63)
				format(temp, 63, "waw555/%s", temp)
				new players[32], pnum
				get_players(players, pnum, "c")
				new i
		
				for (i = 0; i < pnum; i++)
				{
				if (is_user_connecting(players[i]) && admin_options[players[i]][MS_AUDIO_ALL] && admin_options[players[i]][MS_AUDIO_BOMB_TIMER])
				continue
				client_cmd(players[i], "spk sound/waw555/%s",temp)
				}
			}
			else if (g_C4Timer < 11)
			{
				new temp[64]
				
				num_to_word(g_C4Timer, temp, 63)
				format(temp, 63, "waw555/%s", temp)
				new players[32], pnum
				get_players(players, pnum, "c")
				new i
		
				for (i = 0; i < pnum; i++)
				{
				if (is_user_connecting(players[i]) && admin_options[players[i]][MS_AUDIO_ALL] && admin_options[players[i]][MS_AUDIO_BOMB_TIMER])
				continue
				client_cmd(players[i], "spk sound/waw555/%s",temp)
				}
			}
		}
		if (BombCountDef && g_Defusing)
			client_print(g_Defusing, print_center, "%d", g_C4Timer)
	}
	else
		remove_task(8038)
}

public bomb_planted(planter)
{
	g_Defusing = 0
	
	if (BombPlanted)
		announceEvent(planter, "SET_UP_BOMB")
	
	g_C4Timer = get_cvar_num("mp_c4timer")
	set_task(1.0, "bombTimer", 8038, "", 0, "b")
}

public bomb_planting(planter)
{
	if (BombPlanting)
		announceEvent(planter, "PLANT_BOMB")
}

public bomb_defusing(defuser)
{
	if (BombDefusing)
		announceEvent(defuser, "DEFUSING_BOMB")
	
	g_Defusing = defuser
}

public bomb_defused(defuser)
{
	if (BombDefused)
		announceEvent(defuser, "DEFUSED_BOMB")
}

public bomb_explode(planter, defuser)
{
	if (BombFailed && defuser)
		announceEvent(defuser, "FAILED_DEFU")
}
