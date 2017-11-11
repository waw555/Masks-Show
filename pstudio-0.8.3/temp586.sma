#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <cstrike>
#include <csx>

//#define DEBUG

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
#define TE_BEAMPOINTS 0//��� ������

//����� �������
#define MODELCHANGE_DELAY 0.5 // �������� ����� ������ ������
#define MODELSET_TASK 100 // ����������� ��� ����� ������ 

new m_spriteTexture
  //����������� �����������
new g_HudSync
new max_players 
enum {//���� ������ ��� ����������
MS_DEATH_LINE,//����� ������
MS_DAMAGE_MSG,//���������� ����
MS_MODEL,//���������� ������ �������
MS_AUTO_MENU,//��������� �������� ����
}
new bool:admin_options[33][30] // �������������� �����
//new bool:is_in_menu[33] // �������� ���� � ������
//new bool:is_in_menu_audio[33] // �������� ���� � ������
//new bool:is_in_menu_audio1[33] // �������� ���� � ������
//new bool:is_in_menu_audio2[33] // �������� ���� � ������
new pcvar_ms	//��������� ���������� �������
new pcvar_help	//������� �� �������

new bool:admin[33];
new bool:girl[33];
new bool:clan[33];
new bool:user[33];
  
new const ADMIN_MODEL_CT_1[] = "ms_admin_ct_2" // ������
new const ADMIN_MODEL_CT_2[] = "cat_ct" // ���
new const ADMIN_MODEL_CT_3[] = "elf_ct" // ����
new const ADMIN_MODEL_CT_4[] = "girl_ct" // ������� �����������
new const ADMIN_MODEL_CT_5[] = "girl_ct1" // ������� ������
new const ADMIN_MODEL_CT_6[] = "marinegirl_ct" // �������


new const ADMIN_MODEL_T_1[] = "ms_admin_t_2" // ������
new const ADMIN_MODEL_T_2[] = "cheburashka_t" // ���������
new const ADMIN_MODEL_T_3[] = "gena_t" // ����
new const ADMIN_MODEL_T_4[] = "girl_ter" // ������� �������
new const ADMIN_MODEL_T_5[] = "girl_ter1" // ��������
new const ADMIN_MODEL_T_6[] = "kiska_t" // ������ ��������������


new const GIRL_MODEL_CT_1[] = "girl_ct" // ������� �����������
new const GIRL_MODEL_CT_2[] = "girl_ct1" // ������� ������
new const GIRL_MODEL_CT_3[] = "marinegirl_ct" // �������
/*new const GIRL_MODEL_CT_4[] = "" // ������ ��������������
new const GIRL_MODEL_CT_5[] = "" // ������ ��������������
new const GIRL_MODEL_CT_6[] = "" // ������ ��������������
new const GIRL_MODEL_CT_7[] = "" // ������ ��������������
new const GIRL_MODEL_CT_8[] = "" // ������ ��������������
new const GIRL_MODEL_CT_9[] = "" // ������ ��������������*/


new const GIRL_MODEL_T_1[] = "girl_ter" // ������� �������
new const GIRL_MODEL_T_2[] = "girl_ter1" // ��������
new const GIRL_MODEL_T_3[] = "kiska_t" // ������� �����
/*new const GIRL_MODEL_T_4[] = "ms_girl_t_2" // ������ ��������������
new const GIRL_MODEL_T_5[] = "ms_girl_t_3" // ������ ��������������*/
/*new const GIRL_MODEL_T_6[] = "" // ������ ��������������
new const GIRL_MODEL_T_7[] = "" // ������ ��������������
new const GIRL_MODEL_T_8[] = "" // ������ ��������������
new const GIRL_MODEL_T_9[] = "" // ������ ��������������*/


new const CLAN_MODEL_CT_1[] = "ms_admin_ct_2" // ������
new const CLAN_MODEL_CT_2[] = "cat_ct" // ���
/*new const CLAN_MODEL_CT_3[] = "ms_clan_ct_1" // ������ ��������������
new const CLAN_MODEL_CT_4[] = "telepuz_ct" // ������ ��������������
new const CLAN_MODEL_CT_5[] = "ms_clan_ct_5" // ������ ��������������
new const CLAN_MODEL_CT_6[] = "ms_girl_ct_7" // ������ ��������������
new const CLAN_MODEL_CT_7[] = "" // ������ ��������������
new const CLAN_MODEL_CT_8[] = "" // ������ ��������������
new const CLAN_MODEL_CT_9[] = "" // ������ ��������������*/


new const CLAN_MODEL_T_1[] = "ms_admin_t_2" // ������
new const CLAN_MODEL_T_2[] = "gena_t" // ����
/*new const CLAN_MODEL_T_3[] = "ms_clan_t_1" // ������ ��������������
new const CLAN_MODEL_T_4[] = "ms_clan_t_4" // ������ ��������������
new const CLAN_MODEL_T_5[] = "telepuz_te" // ������ ��������������
new const CLAN_MODEL_T_6[] = "ms_girl_t_7" // ������ ��������������
new const CLAN_MODEL_T_7[] = "" // ������ ��������������
new const CLAN_MODEL_T_8[] = "" // ������ ��������������
new const CLAN_MODEL_T_9[] = "" // ������ ��������������*/


/*new const USER_MODEL_CT_1[] = "ms_admin_ct_2" // ������ ��������������
new const USER_MODEL_CT_2[] = "" // ������ ��������������
new const USER_MODEL_CT_3[] = "" // ������ ��������������
new const USER_MODEL_CT_4[] = "" // ������ ��������������
new const USER_MODEL_CT_5[] = "" // ������ ��������������
new const USER_MODEL_CT_6[] = "" // ������ ��������������
new const USER_MODEL_CT_7[] = "" // ������ ��������������
new const USER_MODEL_CT_8[] = "" // ������ ��������������
new const USER_MODEL_CT_9[] = "" // ������ ��������������*/


/*new const USER_MODEL_T_1[] = "ms_admin_t_2" // ������ ��������������
new const USER_MODEL_T_2[] = "" // ������ ��������������
new const USER_MODEL_T_3[] = "" // ������ ��������������
new const USER_MODEL_T_4[] = "" // ������ ��������������
new const USER_MODEL_T_5[] = "" // ������ ��������������
new const USER_MODEL_T_6[] = "" // ������ ��������������
new const USER_MODEL_T_7[] = "" // ������ ��������������
new const USER_MODEL_T_8[] = "" // ������ ��������������
new const USER_MODEL_T_9[] = "" // ������ ��������������*/
  
  

  
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
    add(menubody,1023,"\y1. ������^n");
    add(menubody,1023,"\y2. ���^n");
    add(menubody,1023,"\y3. ����^n");
    add(menubody,1023,"\y4. ������� �� �������^n");
    add(menubody,1023,"\y5. ������^n");
    add(menubody,1023,"\y6. �������^n");
    add(menubody,1023,"\y^n7. ������� ������^n");
    add(menubody,1023,"\y^n8. ������ ����������^n");
    add(menubody,1023,"\r^n^n9. �������� ������^n");

    show_menu(player,KEY1|KEY2|KEY3|KEY4|KEY5|KEY6|KEY7|KEY8|KEY9|KEY0,menubody,MENUTIME,"Menu_Admin_CT");

    return PLUGIN_HANDLED;
}
  
  //���� �������������� ����������
  
public Menu_Admin_T(player) {

  //������ �����������
  
    new menubody[1024];
    format(menubody,1023,"\r������ ��������������:^n^n^n");
    add(menubody,1023,"\y1. ������^n");
    add(menubody,1023,"\y2. ���������^n");
    add(menubody,1023,"\y3. ����^n");
    add(menubody,1023,"\y4. ������� �� ��������^n");
    add(menubody,1023,"\y5. ��������^n");
    add(menubody,1023,"\y6. �������^n");
    add(menubody,1023,"\y^n7. ������� ������^n");
    add(menubody,1023,"\y^n8. ������ ����������^n");
    add(menubody,1023,"\r^n^n9. �������� ������^n");

    show_menu(player,KEY1|KEY2|KEY3|KEY4|KEY5|KEY6|KEY7|KEY8|KEY9|KEY0,menubody,MENUTIME,"Menu_Admin_T");

    return PLUGIN_HANDLED;
}
  
  //���� ������� ����� ����������

public Menu_Girl_CT(player) {

  //������ ����� �����������
  
    new menubody[512];
    format(menubody,511,"\r������� ������:^n^n^n");
    add(menubody,511,"\y1. ������� �� ������^n");
    add(menubody,511,"\y2. ������^n");
    add(menubody,511,"\y3. �������^n");/*
    add(menubody,511,"\y4. ���������^n");*/
    add(menubody,511,"\r^n^n9. �������� ������^n");

    show_menu(player,KEY1|KEY2|KEY3|KEY4|KEY5|KEY6|KEY7|KEY8|KEY9|KEY0,menubody,MENUTIME,"Menu_Girl_CT");

    return PLUGIN_HANDLED;
}
  
  //���� ������� ����������
  
public Menu_Girl_T(player) {

  //������ �����������
  
    new menubody[512];
    format(menubody,511,"\r������� ������:^n^n^n");
    add(menubody,511,"\y1. ������� �� ��������^n");
    add(menubody,511,"\y2. ��������^n");
    add(menubody,511,"\y3. �������^n");
  /*add(menubody,511,"\y4. ������ �������^n");
    add(menubody,511,"\y5. �������^n");*/
    add(menubody,511,"\r^n^n9. �������� ������^n");

    show_menu(player,KEY1|KEY2|KEY3|KEY4|KEY5|KEY6|KEY7|KEY8|KEY9|KEY0,menubody,MENUTIME,"Menu_Girl_T");

    return PLUGIN_HANDLED;
}
  //���� ��������� ���������� ����� ����������

public Menu_Clan_CT(player) {

  //������ ����� �����������
  
    new menubody[512];
    format(menubody,511,"\r������ ����������:^n^n^n");
    add(menubody,511,"\y1. ������^n");
    add(menubody,511,"\y2. ���^n");
    /*add(menubody,511,"\y3. ����������^n");
    add(menubody,511,"\y4. �������^n");
    add(menubody,511,"\y5. �������^n");
    add(menubody,511,"\y6. ������� �� ��������^n");*/
    add(menubody,511,"\r^n^n9. �������� ������^n");

    show_menu(player,KEY1|KEY2|KEY3|KEY4|KEY5|KEY6|KEY7|KEY8|KEY9|KEY0,menubody,MENUTIME,"Menu_Clan_CT");

    return PLUGIN_HANDLED;
}
  
  //���� ��������� ���������� ����������
  
public Menu_Clan_T(player) {

  //������ �����������
  
    new menubody[512];
    format(menubody,511,"\r������ ����������:^n^n^n");
    add(menubody,511,"\y1. ������^n");
    add(menubody,511,"\y2. ����^n");
    /*add(menubody,511,"\y3. ������ � ��������^n");
    add(menubody,511,"\y4. ������� �������^n");
    add(menubody,511,"\y5. �������^n");
    add(menubody,511,"\y6. ������� �� ��������^n");*/
    add(menubody,511,"\r^n^n9. �������� ������^n");

    show_menu(player,KEY1|KEY2|KEY3|KEY4|KEY5|KEY6|KEY7|KEY8|KEY9|KEY0,menubody,MENUTIME,"Menu_Clan_T");

    return PLUGIN_HANDLED;
}
  
  //���� ������ ����� ����������

public Menu_User_CT(player) {

  //������ ����� �����������
  
    new menubody[512];
    format(menubody,511,"\r������ ������:^n^n^n");
    /*add(menubody,511,"\y1. ������^n");*/
    add(menubody,511,"\r^n^n9. �������� ������^n");

    show_menu(player,KEY1|KEY2|KEY3|KEY4|KEY5|KEY6|KEY7|KEY8|KEY9|KEY0,menubody,MENUTIME,"Menu_User_CT");

    return PLUGIN_HANDLED;
}
  
  //���� ������ ����������
  
public Menu_User_T(player) {

  //������ �����������
  
    new menubody[512];
    format(menubody,511,"\r������ ������:^n^n^n");
    /*add(menubody,511,"\y1. ������^n");*/
    add(menubody,511,"\r^n^n9. �������� ������^n");

    show_menu(player,KEY1|KEY2|KEY3|KEY4|KEY5|KEY6|KEY7|KEY8|KEY9|KEY0,menubody,MENUTIME,"Menu_User_T");

    return PLUGIN_HANDLED;
}

/*================================================================================
 �������� ���� ��������
=================================================================================*/
public show_esp_menu(id){
	//is_in_menu[id] = true
	new menu[1024];
	//new keys=MENU_KEY_0|MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9;
	new onoff[2][]={{"\r����\w"},{"\y���\w"}} // \r=red \y=yellow \w white
	new text[2][]={{"(����������� �����)"},{"�������� ���������^n /menu\w"}} // \r=red \y=yellow \w white
	new text_index=get_pcvar_num(pcvar_help)
	if (text_index!=1) text_index=0
	format(menu, 1023, "\y���� ��������\w^n^n %s ^n^n1. ��� ������ %s^n2. ���������� ����������� %s^n3. ���������� ������ ������� %s^n4. ���������� ���� ��� ������ %s^n8. ��������� � �����",
	text[text_index],
	onoff[admin_options[id][MS_DEATH_LINE]],
	onoff[admin_options[id][MS_DAMAGE_MSG]],
	onoff[admin_options[id][MS_MODEL]],
	onoff[admin_options[id][MS_AUTO_MENU]])
	show_menu(id,KEY1|KEY2|KEY3|KEY4|KEY5|KEY6|KEY7|KEY8|KEY9|KEY0,menu,MENUTIME,"show_esp_menu");
	
	return PLUGIN_HANDLED;
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

    // 4. ������ 4
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
    }

       // ������ 7 //������� ������
    if(key == 6) {
      Menu_Girl_CT(player);
      return 1;
    }
    
      // ������ 8 //������ ����������
    if(key == 7) {
      Menu_Clan_CT(player);
      return 1;
    }
    
      //������ 9 //������ �������
    if(key == 7) {
      Menu_User_CT(player);
      return 1;
    }
    
    
     //������ 0 //�������� ������
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

    // 4. ������ 4
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
    }

       //������ 7 //������� ������
    if(key == 6) {
      Menu_Girl_T(player);
      return 1;
    }
    
      //������ 8 //������ ����������
    if(key == 7) {
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

   /* // 4. ������ 4
    if(key == 3) {
      copy( g_player_model[player], charsmax( g_player_model[] ), GIRL_MODEL_CT_4 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }
    
      // 5. ������ 5
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
    
    /*// 4. ������ 4
    if(key == 3) {
      copy( g_player_model[player], charsmax( g_player_model[] ), GIRL_MODEL_T_4 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }
    
      // 5. ������ 5
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

    /*// 3. ������ 3
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
    
       // 5. ������ 5
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

    /*// 3. ������ 3
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
    
       // 5. ������ 5
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
  	
   /*// 1. ������ 1
    if(key == 0) {
      copy( g_player_model[player], charsmax( g_player_model[] ), USER_MODEL_CT_1 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }

    // 2. ������ 2
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

   /* // 1. ������ 1
    if(key == 0) {
      copy( g_player_model[player], charsmax( g_player_model[] ), USER_MODEL_T_1 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }

    // 2. ������ 2
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
  


/*================================================================================
 �������� ����
=================================================================================*/
public menu_esp(id,key){
	
	if (key==7){ // exit
		save2vault(id);
		//return PLUGIN_HANDLED;
		return 1;
	}

	if (key==0){ // exit
		if (admin_options[id][MS_DEATH_LINE]){
		admin_options[id][MS_DEATH_LINE]=false;
		}else{
		admin_options[id][MS_DEATH_LINE]=true;
	}
		
		show_esp_menu(id);
		return 1;
		//return PLUGIN_HANDLED;
	}
	
	if (key==1){ // exit
		if (admin_options[id][MS_DAMAGE_MSG]){
		admin_options[id][MS_DAMAGE_MSG]=false;
		}else{
		admin_options[id][MS_DAMAGE_MSG]=true;
	}
		
		show_esp_menu(id);
		return 1;
		//return PLUGIN_HANDLED;
	}
	
	if (key==2){ // exit
		if (admin_options[id][MS_MODEL]){
		admin_options[id][MS_MODEL]=false;
		client_cmd(id,"cl_minmodels 1");
		}else{
		admin_options[id][MS_MODEL]=true;
		client_cmd(id,"cl_minmodels 0");
	}
		
		show_esp_menu(id);
		return 1;
		//return PLUGIN_HANDLED;
	}
	
	if (key==3){ // exit
		if (admin_options[id][MS_AUTO_MENU]){
		admin_options[id][MS_AUTO_MENU]=false;
		}else{
		admin_options[id][MS_AUTO_MENU]=true;
	}
		show_esp_menu(id);
		return 1;
		//return PLUGIN_HANDLED;
	}
	
	/*if (key==4){ // exit
		if (admin_options[id][MS_DEFAULT_LANGUAGE]){
		admin_options[id][MS_DEFAULT_LANGUAGE]=false;
		client_print(id, print_chat, "��� �� ������� �����");
		}else{
		admin_options[id][MS_DEFAULT_LANGUAGE]=true;
		client_print(id, print_chat, "��� �� ���������� �����");
	}
		show_esp_menu(id);
		return 1;
		//return PLUGIN_HANDLED;
	}*/
	
	/*if (key==5){ // exit
		if (admin_options[id][MS_AUTO_MODEL_MENU]){
		admin_options[id][MS_AUTO_MODEL_MENU]=false;
		}else{
		admin_options[id][MS_AUTO_MODEL_MENU]=true;
		admin_options[id][MS_AUTO_MENU]=false;
	}
		show_esp_menu(id);
		return 1;
		//return PLUGIN_HANDLED;
	}
	

	// toggle esp options
	if (admin_options[id][key]){
		admin_options[id][key]=false
		}else{
		admin_options[id][key]=true
	}*/
	
	/*if (key==5){ // exit
		//is_in_menu[id] = false
		Audio_Settings(id);
		return 1;
	}*/
	
	return 1;
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

public client_disconnected(id) {
	save2vault(id);
}

public client_authorized(id) {
	client_cmd(id, "voice_inputfromfile 0");
	return PLUGIN_CONTINUE;
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
	
	
	for (new i=0;i<30;i++){
		admin_options[id][i]=true
	}
	load_vault_data(id);
	if(admin_options[id][MS_AUTO_MENU]){
	set_task(1.0,"cmd_esp_menu", id)
	}
	if(admin_options[id][MS_MODEL]){
	client_cmd(id,"cl_minmodels 0");
	}else{
	client_cmd(id,"cl_minmodels 1");
	}
	client_cmd(id, "voice_inputfromfile 0");
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
register_clcmd("say /model","currmodel",-1);
register_clcmd("say /menu","",-1);
    
register_forward( FM_SetClientKeyValue, "fw_SetClientKeyValue" );
register_forward( FM_ClientUserInfoChanged, "fw_ClientUserInfoChanged" );
register_event( "HLTV", "event_round_start", "a", "1=0", "2=0" );
RegisterHam( Ham_Spawn, "player", "fw_PlayerSpawn", 1 );

    // ������������ ID ����
new menu1ID = register_menuid("Menu_Admin_CT");
new menu2ID = register_menuid("Menu_Admin_T");
new menu3ID = register_menuid("Menu_Girl_CT");
new menu4ID = register_menuid("Menu_Girl_T");
new menu5ID = register_menuid("Menu_Clan_CT");
new menu6ID = register_menuid("Menu_Clan_T");
new menu7ID = register_menuid("Menu_User_CT");
new menu8ID = register_menuid("Menu_User_T");
new menu9ID = register_menuid("show_esp_menu");

    // ������������ ������� ����
register_menucmd(menu1ID,1023,"Menu_Admin_CT_Action");
register_menucmd(menu2ID,1023,"Menu_Admin_T_Action");
register_menucmd(menu3ID,511,"Menu_Girl_CT_Action");
register_menucmd(menu4ID,511,"Menu_Girl_T_Action");
register_menucmd(menu5ID,511,"Menu_Clan_CT_Action");
register_menucmd(menu6ID,511,"Menu_Clan_T_Action");
register_menucmd(menu7ID,511,"Menu_User_CT_Action");
register_menucmd(menu8ID,511,"Menu_User_T_Action");
register_menucmd(menu9ID,1023,"menu_esp");
    //�������
set_task( 30.0, "Reklama", _,_,_,_, 1);
    

    
register_cvar("ms_on_off","1")//��������� ���������� �������
register_cvar("ms_help","1")//���������� ������� ��� ���
register_clcmd("say /menu","cmd_esp_menu",-1);
register_clcmd("say menu","cmd_esp_menu",-1);
register_clcmd("menu","cmd_esp_menu",-1);
    //��� ������
register_cvar("amx_deathbeams_enabled","1")//�������� ��������� ����� ������ �����
register_cvar("amx_deathbeams_randcolor","0")//���� ������
register_event("DeathMsg","death","a")//������� ������ ������
    //����������� �����������
register_event("Damage", "damage_message", "b", "2!0", "3=0", "4!0")
g_HudSync = CreateHudSyncObj()

max_players=get_maxplayers()

return PLUGIN_CONTINUE
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
	if(iRankPos == 1 || iRankPos == 2 || iRankPos == 3 || iRankPos == 4 || iRankPos == 5 || iRankPos == 6 || iRankPos == 7 || iRankPos == 8 || iRankPos == 9 || iRankPos == 10) {
	return Show_Menu_Level(player);
	}else if ((get_user_flags(player) & ADMIN_LEVEL_F) || (get_user_flags(player) & ADMIN_LEVEL_G) || (get_user_flags(player) & ADMIN_LEVEL_H) || (get_user_flags(player) & ADMIN_USER)) {
	return Show_Menu_Level(player);
	}else{
	client_print(player,print_chat,"��� ���� %d, �������� � ���10, ����� �������� ����",iRankPos);
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
	client_cmd(player,"cl_minmodels 0");
	}else{
	client_cmd(player,"cl_minmodels 1");
	}
	client_cmd(player, "voice_inputfromfile 0");
	
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

	if (get_xvar_num("amx_deathbeams_enabled") == 1)
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
		
		load_vault_data(id)
}

/*================================================================================
 ��������� �������� ����
=================================================================================*/
public cmd_esp_menu(id){
	if (get_pcvar_num(pcvar_ms)==1){
		show_esp_menu(id)
	}
}