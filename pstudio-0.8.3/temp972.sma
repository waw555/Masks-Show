
  #include <amxmodx>
  #include <fakemeta>
  #include <hamsandwich>
  #include <cstrike>

  #define MENUTIME 30 // how long menus stay up

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

  // Temporary Menu Variables
  //new page[33] = { 1, ...}, target[33][33];
  
  new const ADMIN_MODEL_1[] = "telepuz_ct" // The model we're gonna use for zombies
  #define MODELCHANGE_DELAY 0.5 // �������� ����� ������ ������
  #define MODELSET_TASK 100 // ����������� ��� ����� ������
  
  
  
  new g_has_custom_model[33]//���������� ����� ������ ��� ���
  new g_player_model[33][32]//������� ������ ������
  new Float:g_models_targettime // ����� ������� ������� ��� ���������� ��������� ������
  new Float:g_roundstarttime // ��������� ������� ��������� �����
  

  // A user's assigned model
  
  //new setmodel[33][33];



  //���� � ������� �������
    public Show_Menu_Level(player) {
	if ((cs_get_user_team(player) == CS_TEAM_CT)&&(get_user_flags(player) & ADMIN_LEVEL_F)){
		return Menu_Admin_CT(player)
	}else if ((cs_get_user_team(player) == CS_TEAM_T)&&(get_user_flags(player) & ADMIN_LEVEL_F)){
		return Menu_Admin_T(player)
	}else if ((cs_get_user_team(player) == CS_TEAM_CT)&&(get_user_flags(player) & ADMIN_LEVEL_G)){
		return Menu_Girl_CT(player)
	}else if ((cs_get_user_team(player) == CS_TEAM_T)&&(get_user_flags(player) & ADMIN_LEVEL_G)){
		return Menu_Girl_T(player)
	}else if ((cs_get_user_team(player) == CS_TEAM_CT)&&(get_user_flags(player) & ADMIN_LEVEL_H)){
		return Menu_Clan_CT(player)
	}else if ((cs_get_user_team(player) == CS_TEAM_T)&&(get_user_flags(player) & ADMIN_LEVEL_H)){
		return Menu_Clan_T(player)
	}else if ((cs_get_user_team(player) == CS_TEAM_CT)&&(get_user_flags(player) & ADMIN_USER)){
		return Menu_User_CT(player)
	}else if((cs_get_user_team(player) == CS_TEAM_T)&&(get_user_flags(player) & ADMIN_USER))
		return Menu_User_T(player)
	{
		return PLUGIN_HANDLED
	}
}

  // ------------------------------------------------------------------------------------------
  // --���������� ����--------------------------------------------------------------------------
  // ------------------------------------------------------------------------------------------

//���� �������������� ����� ����������

  public Menu_Admin_CT(player) {

  //������ ����� �����������
  
    new menubody[512];
    format(menubody,511,"\r������ ��������������:^n^n^n");
    add(menubody,511,"\y1. ���������^n");
    add(menubody,511,"\y^n7. ������� ������^n");
    add(menubody,511,"\y^n8. ������ ����������^n");
    add(menubody,511,"\y^n9. ������ �������^n");
    add(menubody,511,"\r^n^n0. �������� ������^n");

    show_menu(player,KEY1|KEY2|KEY3|KEY4|KEY5|KEY6|KEY7|KEY8|KEY9|KEY0,menubody,MENUTIME,"Menu_Admin_CT");

    return PLUGIN_HANDLED;
  }
  
  //���� �������������� ����������
  
    public Menu_Admin_T(player) {

  //������ �����������
  
    new menubody[512];
    format(menubody,511,"\r������ ��������������:^n^n^n");
    add(menubody,511,"\y^n1. ���������^n");
    add(menubody,511,"\y^n7. ������� ������^n");
    add(menubody,511,"\y^n8. ������ ����������^n");
    add(menubody,511,"\y^n9. ������ �������^n");
    add(menubody,511,"\r^n^n0. �������� ������^n");

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
    add(menubody,511,"\r^n^n0. �������� ������^n");

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
    add(menubody,511,"\r^n^n0. �������� ������^n");

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
    add(menubody,511,"\r^n^n0. �������� ������^n");

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
    add(menubody,511,"\r^n^n0. �������� ������^n");

    show_menu(player,KEY1|KEY2|KEY3|KEY4|KEY5|KEY6|KEY7|KEY8|KEY9|KEY0,menubody,MENUTIME,"Menu_Clan_T");

    return PLUGIN_HANDLED;
  }
  
  //���� ������ ����� ����������

  public Menu_User_CT(player) {

  //������ ����� �����������
  
    new menubody[512];
    format(menubody,511,"\r������ ������:^n^n^n");
    /*add(menubody,511,"\y1. ���������^n");*/
    add(menubody,511,"\r^n^n0. �������� ������^n");

    show_menu(player,KEY1|KEY2|KEY3|KEY4|KEY5|KEY6|KEY7|KEY8|KEY9|KEY0,menubody,MENUTIME,"Menu_User_CT");

    return PLUGIN_HANDLED;
  }
  
  //���� ������ ����������
  
    public Menu_User_T(player) {

  //������ �����������
  
    new menubody[512];
    format(menubody,511,"\r������ ������:^n^n^n");
    /*add(menubody,511,"\y1. ���������^n");*/
    add(menubody,511,"\r^n^n0. �������� ������^n");

    show_menu(player,KEY1|KEY2|KEY3|KEY4|KEY5|KEY6|KEY7|KEY8|KEY9|KEY0,menubody,MENUTIME,"Menu_User_T");

    return PLUGIN_HANDLED;
  }

  // ------------------------------------------------------------------------------------------
  // --�������� ����---------------------------------------------------------------------------
  // ------------------------------------------------------------------------------------------

  // --���� �������������� ����� ����������---------------------------------------------------------------------------
  public Menu_Admin_CT_Action(player,key) {

    // 1. ������ 1
    if(key == 0) {
      copy( g_player_model[player], charsmax( g_player_model[] ), ADMIN_MODEL_1 );
      g_has_custom_model[player] = true;
      fw_PlayerSpawn( player );
      return 1;
    }

   /* // 2. ������ 2
    if(key == 1) {
      modelAction(id,target[id],"scelet_ct");
      return 1;
    }

    // 3. ������ 3
    if(key == 2) {
      modelAction(id,target[id],"");
      return 1;
    }

    // 4. ������ 4
    if(key == 3) {
      modelAction(id,target[id],"");
      return 1;
    }
    
       // 5. ������ 5
    if(key == 4) {
      modelAction(id,target[id],"");
      return 1;
    }
    
       // 6. ������ 6
    if(key == 5) {
      modelAction(id,target[id],"");
      return 1;
    }*/

    /*   // 7. ������ 7 //������� ������
    if(key == 6) {
      Menu_Girl_CT(player);
      return 1;
    }
    
      // 8. ������ 8 //������ ����������
    if(key == 7) {
      Menu_Clan_CT(player);
      return 1;
    }
    
      // 9. ������ 9 //������ �������
    if(key == 8) {
      Menu_User_CT(player);
      return 1;
    }*/
    
      // 0. ������ 0 //�������� ������
    if(key == 9) {
      fm_reset_user_model(player);
      return 1;
    }

    return 1;
  }
  
  /*  // --���� �������������� ����������---------------------------------------------------------------------------
  public Menu_Admin_T_Action(id,key) {

    // 1. ������ 1
    if(key == 0) {
      modelAction(id,target[id],"telepuz_te");
      return 1;
    }

    // 2. ������ 2
    if(key == 1) {
      modelAction(id,target[id],"");
      return 1;
    }

    // 3. ������ 3
    if(key == 2) {
      modelAction(id,target[id],"");
      return 1;
    }

    // 4. ������ 4
    if(key == 3) {
      modelAction(id,target[id],"");
      return 1;
    }
    
       // 5. ������ 5
    if(key == 4) {
      modelAction(id,target[id],"");
      return 1;
    }
    
       // 6. ������ 6
    if(key == 5) {
      modelAction(id,target[id],"");
      return 1;
    }

       // 7. ������ 7 //������� ������
    if(key == 6) {
      Menu_Girl_T(id);
      return 1;
    }
    
      // 8. ������ 8 //������ ����������
    if(key == 7) {
      Menu_Clan_T(id);
      return 1;
    }
    
      // 9. ������ 9 //������ �������
    if(key == 8) {
      Menu_User_T(id);
      return 1;
    }
    
      // 0. ������ 0 //�������� ������
    if(key == 9) {
      modelAction(id, target[id],".reset");
      return 1;
    }

    return 1;
  }
  
    // --���� ������� ����� ����������---------------------------------------------------------------------------
  public Menu_Girl_CT_Action(id,key) {

    // 1. ������ 1
    if(key == 0) {
      modelAction(id,target[id],"ms_girl_ct_1");
      return 1;
    }

    // 2. ������ 2
    if(key == 1) {
      modelAction(id,target[id],"ms_girl_ct_2");
      return 1;
    }

    // 3. ������ 3
    if(key == 2) {
      modelAction(id,target[id],"ms_girl_ct_4");
      return 1;
    }

    // 4. ������ 4
    if(key == 3) {
      modelAction(id,target[id],"");
      return 1;
    }
    
       // 5. ������ 5
    if(key == 4) {
      modelAction(id,target[id],"");
      return 1;
    }
    
       // 6. ������ 6
    if(key == 5) {
      modelAction(id,target[id],"");
      return 1;
    }
    
      // 7. ������ 7
    if(key == 6) {
      modelAction(id,target[id],"");
      return 1;
    }
    
      // 8. ������ 8
    if(key == 7) {
      modelAction(id,target[id],"");
      return 1;
    }
    
      // 9. ������ 9
    if(key == 8) {
      modelAction(id,target[id],"");
      return 1;
    }
    
      // 0. ������ 0 //�������� ������
    if(key == 9) {
      modelAction(id, target[id],".reset");
      return 1;
    }

    return 1;
  }

  
      // --���� ������� ����������---------------------------------------------------------------------------
  public Menu_Girl_T_Action(id,key) {

    // 1. ������ 1
    if(key == 0) {
      modelAction(id,target[id],"ms_girl_t_1");
      return 1;
    }

    // 2. ������ 2
    if(key == 1) {
      modelAction(id,target[id],"ms_girl_t_2");
      return 1;
    }

    // 3. ������ 3
    if(key == 2) {
      modelAction(id,target[id],"ms_girl_t_3");
      return 1;
    }

    // 4. ������ 4
    if(key == 3) {
      modelAction(id,target[id],"");
      return 1;
    }
    
       // 5. ������ 5
    if(key == 4) {
      modelAction(id,target[id],"");
      return 1;
    }
    
       // 6. ������ 6
    if(key == 5) {
      modelAction(id,target[id],"");
      return 1;
    }
    
      // 7. ������ 7
    if(key == 6) {
      modelAction(id,target[id],"");
      return 1;
    }
    
      // 8. ������ 8
    if(key == 7) {
      modelAction(id,target[id],"");
      return 1;
    }
    
      // 9. ������ 9
    if(key == 8) {
      modelAction(id,target[id],"");
      return 1;
    }
    
      // 0. ������ 0 //�������� ������
    if(key == 9) {
      modelAction(id, target[id],".reset");
      return 1;
    }

    return 1;
  }
  
     // --���� ���������� ����� ����������---------------------------------------------------------------------------
  public Menu_Clan_CT_Action(id,key) {

    // 1. ������ 1
    if(key == 0) {
      modelAction(id,target[id],"ms_clan_ct_1");
      return 1;
    }

    // 2. ������ 2
    if(key == 1) {
      modelAction(id,target[id],"ms_clan_ct_2");
      return 1;
    }

    // 3. ������ 3
    if(key == 2) {
      modelAction(id,target[id],"ms_clan_ct_3");
      return 1;
    }

    // 4. ������ 4
    if(key == 3) {
      modelAction(id,target[id],"");
      return 1;
    }
    
       // 5. ������ 5
    if(key == 4) {
      modelAction(id,target[id],"");
      return 1;
    }
    
       // 6. ������ 6
    if(key == 5) {
      modelAction(id,target[id],"");
      return 1;
    }
    
      // 7. ������ 7
    if(key == 6) {
      modelAction(id,target[id],"");
      return 1;
    }
    
      // 8. ������ 8
    if(key == 7) {
      modelAction(id,target[id],"");
      return 1;
    }
    
      // 9. ������ 9
    if(key == 8) {
      modelAction(id,target[id],"");
      return 1;
    }
    
      // 0. ������ 0 //�������� ������
    if(key == 9) {
      modelAction(id, target[id],".reset");
      return 1;
    }

    return 1;
  }
  
       // --���� ���������� ����������---------------------------------------------------------------------------
  public Menu_Clan_T_Action(id,key) {

    // 1. ������ 1
    if(key == 0) {
      modelAction(id,target[id],"ms_clan_t_1");
      return 1;
    }

    // 2. ������ 2
    if(key == 1) {
      modelAction(id,target[id],"ms_clan_t_2");
      return 1;
    }

    // 3. ������ 3
    if(key == 2) {
      modelAction(id,target[id],"ms_clan_t_3");
      return 1;
    }

    // 4. ������ 4
    if(key == 3) {
      modelAction(id,target[id],"");
      return 1;
    }
    
       // 5. ������ 5
    if(key == 4) {
      modelAction(id,target[id],"");
      return 1;
    }
    
       // 6. ������ 6
    if(key == 5) {
      modelAction(id,target[id],"");
      return 1;
    }
    
      // 7. ������ 7
    if(key == 6) {
      modelAction(id,target[id],"");
      return 1;
    }
    
      // 8. ������ 8
    if(key == 7) {
      modelAction(id,target[id],"");
      return 1;
    }
    
      // 9. ������ 9
    if(key == 8) {
      modelAction(id,target[id],"");
      return 1;
    }
    
      // 0. ������ 0 //�������� ������
    if(key == 9) {
      modelAction(id, target[id],".reset");
      return 1;
    }

    return 1;
  }
  
       // --���� ������ ����� ����������---------------------------------------------------------------------------
  public Menu_User_CT_Action(id,key) {

   // 1. ������ 1
    if(key == 0) {
      modelAction(id,target[id],"");
      return 1;
    }

    // 2. ������ 2
    if(key == 1) {
      modelAction(id,target[id],"");
      return 1;
    }

    // 3. ������ 3
    if(key == 2) {
      modelAction(id,target[id],"");
      return 1;
    }

    // 4. ������ 4
    if(key == 3) {
      modelAction(id,target[id],"");
      return 1;
    }
    
       // 5. ������ 5
    if(key == 4) {
      modelAction(id,target[id],"");
      return 1;
    }
    
       // 6. ������ 6
    if(key == 5) {
      modelAction(id,target[id],"");
      return 1;
    }
    
      // 7. ������ 7
    if(key == 6) {
      modelAction(id,target[id],"");
      return 1;
    }
    
      // 8. ������ 8
    if(key == 7) {
      modelAction(id,target[id],"");
      return 1;
    }
    
      // 9. ������ 9
    if(key == 8) {
      modelAction(id,target[id],"");
      return 1;
    }
    
      // 0. ������ 0 //�������� ������
    if(key == 9) {
      modelAction(id, target[id],".reset");
      return 1;
    }

    return 1;
  }
  
  
         // --���� ������ ����������---------------------------------------------------------------------------
  public Menu_User_T_Action(id,key) {

    // 1. ������ 1
    if(key == 0) {
      modelAction(id,target[id],"");
      return 1;
    }

    // 2. ������ 2
    if(key == 1) {
      modelAction(id,target[id],"");
      return 1;
    }

    // 3. ������ 3
    if(key == 2) {
      modelAction(id,target[id],"");
      return 1;
    }

    // 4. ������ 4
    if(key == 3) {
      modelAction(id,target[id],"");
      return 1;
    }
    
       // 5. ������ 5
    if(key == 4) {
      modelAction(id,target[id],"");
      return 1;
    }
    
       // 6. ������ 6
    if(key == 5) {
      modelAction(id,target[id],"");
      return 1;
    }
    
      // 7. ������ 7
    if(key == 6) {
      modelAction(id,target[id],"");
      return 1;
    }
    
      // 8. ������ 8
    if(key == 7) {
      modelAction(id,target[id],"");
      return 1;
    }
    
      // 9. ������ 9
    if(key == 8) {
      modelAction(id,target[id],"");
      return 1;
    }
    
      // 0. ������ 0 //�������� ������
    if(key == 9) {
      modelAction(id, target[id],".reset");
      return 1;
    }

    return 1;
  }*/

  // ------------------------------------------------------------------------------------------
  // --��������� ������-----------------------------------------------------------------------
  // ------------------------------------------------------------------------------------------  
 /* public modelAction(id,target[33],model[33]) {

    new username[33], authid[33];
    get_user_name(id,username,32);
    get_user_authid(id,authid,32);

    // if clearing models
    if(equal(model,".reset")) {

      // log the command
      log_amx("Cmd: ^"%s<%d><%s><>^" reset model for %s%s",username,get_user_userid(id),authid,isdigit(target[0]) ? "#" : "",target);

      // show activity
      switch(get_cvar_num("amx_show_activity")) {
        case 1: client_print(0,print_chat,"�������������: ������� ������ �� %s%s",isdigit(target[0]) ? "#" : "",target);
        case 2: client_print(0,print_chat,"������������� %s: ������� ������ �� %s%s",username,isdigit(target[0]) ? "#" : "",target);
      }

    }
    else { // if setting models

      // log the command
      log_amx("Cmd: ^"%s<%d><%s><>^" ������� ������ %s �� %s%s",username,get_user_userid(id),authid,model,isdigit(target[0]) ? "#" : "",target);

      // show activity
      switch(get_cvar_num("amx_show_activity")) {
        case 1: client_print(0,print_chat,"�������������: ������� ������ %s �� %s%s",model,isdigit(target[0]) ? "#" : "",target);
        case 2: client_print(0,print_chat,"������������� %s: ������� ������ %s �� %s%s",username,model,isdigit(target[0]) ? "#" : "",target);
      }

    }

    new flags[2], team[33];

    if(equal(target,"@T")) { // All Terrorists
      flags = "e"; // team
      team = "TERRORIST";
    }
    else if(equal(target,"@CT")) { // All Counter-Terrorists
      flags = "e"; // team
      team = "CT";
    }
    else if(isdigit(target[0])) { // Specific Player or Yourself
      flags = "f"; // name
      get_user_name(str_to_num(target),team,32);
    }

    // Otherwise this leaves us with nothing, which is All Players

    // get targets
    new players[32], num;
    get_players(players,num,flags,team);

    // loop through
    for(new i=0;i<num;i++) {
      new player = players[i]; // our player

      if(equal(model,".reset")) { // if reset
        cs_reset_user_model(player);
        setmodel[player] = "";
      }
      else {
        cs_set_user_model(player,model);
        setmodel[player] = model;
      }
    }

    return 1;
  }*/
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

  // ------------------------------------------------------------------------------------------
  // --RESET MODEL ON RESPAWN-----------------------------------------------------------------
  // ------------------------------------------------------------------------------------------
  /*public event_resethud(id) {

    if(!equal(setmodel[id],"")) {
      cs_set_user_model(id,setmodel[id]);
    }

  }*/

  // ------------------------------------------------------------------------------------------
  // --CONNECTION AND DISCONNECTION-----------------------------------------------------------
  // ------------------------------------------------------------------------------------------
  public client_connect(id) {
   /* page[id] = 1;
    setmodel[id] = "";*/
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
    
   }

  public client_disconnect(player) {
    /*page[id] = 1;
    setmodel[id] = "";*/

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
      precache_generic("models/player/ms_clan_ct_1/ms_clan_ct_1T.mdl")
      precache_generic("models/player/ms_clan_ct_2/ms_clan_ct_2T.mdl")
      precache_generic("models/player/ms_clan_t_1/ms_clan_t_1T.mdl")
      precache_generic("models/player/ms_clan_t_2/ms_clan_t_2T.mdl")
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

    register_clcmd("ms_model","Show_Menu_Level",-1,"���� �������");
    //register_event("ResetHUD","event_resethud","b");
    register_clcmd("say /model","currmodel",-1);
    
    register_forward( FM_SetClientKeyValue, "fw_SetClientKeyValue" );
    register_forward( FM_ClientUserInfoChanged, "fw_ClientUserInfoChanged" );
    register_event( "HLTV", "event_round_start", "a", "1=0", "2=0" )
    RegisterHam( Ham_Spawn, "player", "fw_PlayerSpawn", 1 )
   

    // ������������ ID ����
    new menu1ID = register_menuid("Menu_Admin_CT");
    new menu2ID = register_menuid("Menu_Admin_T");
    new menu3ID = register_menuid("Menu_Girl_CT");
    new menu4ID = register_menuid("Menu_Girl_T");
    new menu5ID = register_menuid("Menu_Clan_CT");
    new menu6ID = register_menuid("Menu_Clan_T");
    new menu7ID = register_menuid("Menu_User_CT");
    new menu8ID = register_menuid("Menu_User_T");


    // ������������ ������� ����
    register_menucmd(menu1ID,511,"Menu_Admin_CT_Action");
    register_menucmd(menu2ID,511,"Menu_Admin_T_Action");
    register_menucmd(menu3ID,511,"Menu_Girl_CT_Action");
    register_menucmd(menu4ID,511,"Menu_Girl_T_Action");
    register_menucmd(menu5ID,511,"Menu_Clan_CT_Action");
    register_menucmd(menu6ID,511,"Menu_Clan_T_Action");
    register_menucmd(menu7ID,511,"Menu_User_CT_Action");
    register_menucmd(menu8ID,511,"Menu_User_T_Action");
  }
  // ------------------------------------------------------------------------------------------
  // --Set stats---------------------------------------------------------------------
  // ------------------------------------------------------------------------------------------
  /*public usermodel(id) {
	new izStats[8], izBody[8];
	new iRankPos;
	iRankPos = get_user_stats(id, izStats, izBody);
	if(iRankPos == 1 || iRankPos == 2 || iRankPos == 3 || iRankPos == 4 || iRankPos == 5 || iRankPos == 6 || iRankPos == 7 || iRankPos == 8 || iRankPos == 9 || iRankPos == 10 || iRankPos == 11 || iRankPos == 12 || iRankPos == 13 || iRankPos == 14 || iRankPos == 15) {
	return menu1Display(id);
	}else if (get_user_flags(id) & ADMIN_LEVEL_H) {
	return menu1Display(id);
	}else{
	client_print(id,print_chat,"��� ���� %d, �������� � ���15, ����� �������� ����",iRankPos);
	}
	return PLUGIN_HANDLED;
}*/

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
    // ������� �������������� ������ ���� ��������
    remove_task( player + MODELSET_TASK )
    
    
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
    client_print(player,print_chat,"* ���� ������ %s",model);
}

stock fm_reset_user_model( player )
{
    // Player doesn't have a custom model any longer
    g_has_custom_model[player] = false
    
    dllfunc( DLLFunc_ClientUserInfoChanged, player, engfunc( EngFunc_GetInfoKeyBuffer, player ) )
}
