
  #include <amxmodx>
  #include <amxmisc>
  #include <cstrike>
  #include <csx>

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
  new page[33] = { 1, ...}, target[33][33];
  

  // A user's assigned model
  
  new setmodel[33][33];

  // ------------------------------------------------------------------------------------------
  // --MENU DISPLAYS--------------------------------------------------------------------------
  // ------------------------------------------------------------------------------------------

  // Here are all of our functions for displaying the menus themselves

  // --MENU 1 DISPLAY--------------------------------------------------------------------------
  public menu1Display(id) {
  	new idstr[33];
	num_to_str(id,idstr,32);
	target[id] = idstr;
  	if (cs_get_user_team(id) == CS_TEAM_CT)
		return menu5Display(id)
	{
		return menu4Display(id)
	}
}

  // --MENU 4 DISPLAY--------------------------------------------------------------------------
  public menu4Display(id) {

    // terrorist model list

    new menubody[512];
    format(menubody,511,"\yПоменять модель на:^n^n");
    add(menubody,511,"\w1. Телепузик^n");
    add(menubody,511,"\w2. Скелет^n");
    add(menubody,511,"\w3. Девушка^n");
    add(menubody,511,"\w4. Ковбойка^n");
    add(menubody,511,"\w5. Терминатор^n");
    add(menubody,511,"\w6. Санта^n");
    add(menubody,511,"\w7. Матрица^n");
    /*add(menubody,511,"\w^n9. Далее^n");*/
    add(menubody,511,"\w^n0. Сбросить модель^n");

    show_menu(id,KEY1|KEY2|KEY3|KEY4|KEY5|KEY6|KEY7|KEY8|KEY9|KEY0,menubody,MENUTIME,"menu4");

    return PLUGIN_HANDLED;
  }

  // --MENU 5 DISPLAY--------------------------------------------------------------------------
  public menu5Display(id) {

    // counter-terrorist model list

    new menubody[512];
    format(menubody,511,"\yПоменять модель на:^n^n");
    add(menubody,511,"\w1. Телепузик^n");
    add(menubody,511,"\w2. Скелет^n");
    add(menubody,511,"\w3. Девушка солдат^n");
    add(menubody,511,"\w4. КУСТИК^n");
    add(menubody,511,"\w5. Робокоп^n");
    add(menubody,511,"\w6. Альфа^n");
    add(menubody,511,"\w7. Санта^n");
    add(menubody,511,"\w8. Огнеметчик^n");
    /*add(menubody,511,"\w^n9. Далее^n");*/
    add(menubody,511,"\w^n0. Сбросить модель^n");

    show_menu(id,KEY1|KEY2|KEY3|KEY4|KEY5|KEY6|KEY7|KEY8|KEY9|KEY0,menubody,MENUTIME,"menu5");

    return PLUGIN_HANDLED;
  }
  
  /*  // --MENU 6 DISPLAY--------------------------------------------------------------------------
  public menu6Display(id) {

    // terrorist model list

    new menubody[512];
    format(menubody,511,"\yПоменять модель на:^n^n");
    add(menubody,511,"\w1. Хищник^n");
    add(menubody,511,"\w2. Смерть^n");
    add(menubody,511,"\w^n9. Назад^n");
    add(menubody,511,"\w^n0. Сбросить модель^n");

    show_menu(id,KEY1|KEY2|KEY3|KEY4|KEY5|KEY6|KEY7|KEY8|KEY9|KEY0,menubody,MENUTIME,"menu6");

    return PLUGIN_HANDLED;
  }
*/
  /*// --MENU 7 DISPLAY--------------------------------------------------------------------------
  public menu7Display(id) {

    // counter-terrorist model list

    new menubody[512];
    format(menubody,511,"\yПоменять модель на:^n^n");
    
    add(menubody,511,"\w^n9. Назад^n");
    add(menubody,511,"\w^n0. Сбросить модель^n");

    show_menu(id,KEY1|KEY2|KEY3|KEY4|KEY5|KEY6|KEY7|KEY8|KEY9|KEY0,menubody,MENUTIME,"menu7");

    return PLUGIN_HANDLED;
  }*/

  // ------------------------------------------------------------------------------------------
  // --MENU ACTIONS---------------------------------------------------------------------------
  // ------------------------------------------------------------------------------------------

  // --MENU 4 ACTION---------------------------------------------------------------------------
  public menu4Action(id,key) {

    // 1. Телепуз
    if(key == 0) {
      modelAction(id,target[id],"telepuz_te");
      return 1;
    }

    // 2. Скелет
    if(key == 1) {
      modelAction(id,target[id],"scelet_t");
      return 1;
    }

    // 3. Девушка
    if(key == 2) {
      modelAction(id,target[id],"girl1_t");
      return 1;
    }

    // 4. Девушка ковбойка
    if(key == 3) {
      modelAction(id,target[id],"girl2_t");
      return 1;
    }
    
       // 5. Терминатор
    if(key == 4) {
      modelAction(id,target[id],"t500");
      return 1;
    }
    
       // 6. Хищник
    if(key == 5) {
      modelAction(id,target[id],"santa_te");
      return 1;
    }

       // 6. Хищник
    if(key == 6) {
      modelAction(id,target[id],"human_admin");
      return 1;
    }
    
     /* // 9. Следующая страница
    if(key == 8) {
      menu6Display(id);
      return 1;
    }
    */
    // 0. Reset Models
    if(key == 9) {
      modelAction(id,target[id],".reset");
      return 1;
    }

    return 1;
  }

  // --MENU 5 ACTION---------------------------------------------------------------------------
  public menu5Action(id,key) {

    // 1. Телепуз
    if(key == 0) {
      modelAction(id,target[id],"telepuz_ct");
      return 1;
    }

    // 2. скелет
    if(key == 1) {
      modelAction(id,target[id],"scelet_ct");
      return 1;
    }

    // 3. Девушка солдат
    if(key == 2) {
      modelAction(id,target[id],"girl2_ct");
      return 1;
    }
    
    // 4. Кустик
    if(key == 3) {
      modelAction(id,target[id],"kyctuk1");
      return 1;
    }
    
    // 5. Робокоп
    if(key == 4) {
      modelAction(id,target[id],"robocop");
      return 1;
    }
    
        // 6. Альфа
    if(key == 5) {
      modelAction(id,target[id],"alfa");
      return 1;
    }

        // 7. Санта
    if(key == 6) {
      modelAction(id,target[id],"santa_ct");
      return 1;
    }

        // 7. Санта
    if(key == 7) {
      modelAction(id,target[id],"survivor");
      return 1;
    }
    
    /*// 9. Далее
    if(key == 8) {
      menu7Display(id);
      return 1;
    }*/
    
    // 0. Reset Models
    if(key == 9) {
      modelAction(id,target[id],".reset");
      return 1;
    }

    return 1;
  }
  
  /*  // --MENU 6 ACTION---------------------------------------------------------------------------
  public menu6Action(id,key) {

      // 1. Хищник
    if(key == 0) {
      modelAction(id,target[id],"predator1");
      return 1;
    }
    
          // 2. Хищник
    if(key == 1) {
      modelAction(id,target[id],"death");
      return 1;
    }
  
    // 1. Телепуз
    if(key == 8) {
      menu4Display(id);
      return 1;
    }
    
    // 0. Reset Models
    if(key == 9) {
      modelAction(id,target[id],".reset");
      return 1;
    }

    return 1;
  }
*/
  /*// --MENU 6 ACTION---------------------------------------------------------------------------
  public menu7Action(id,key) {

    // 2. Альфа
    if(key == 0) {
      modelAction(id,target[id],"alfa");
      return 1;
    }
  
    // 1. Назад
    if(key == 8) {
      menu5Display(id);
      return 1;
    }
    
    // 0. Reset Models
    if(key == 9) {
      modelAction(id,target[id],".reset");
      return 1;
    }

    return 1;
  }
*/
  // ------------------------------------------------------------------------------------------
  // --SET MODEL ACTION-----------------------------------------------------------------------
  // ------------------------------------------------------------------------------------------
  public modelAction(id,target[33],model[33]) {

    new username[33], authid[33];
    get_user_name(id,username,32);
    get_user_authid(id,authid,32);

    // if clearing models
    if(equal(model,".reset")) {

      // log the command
      log_amx("Cmd: ^"%s<%d><%s><>^" reset model for %s%s",username,get_user_userid(id),authid,isdigit(target[0]) ? "#" : "",target);

      // show activity
      switch(get_cvar_num("amx_show_activity")) {
        case 1: client_print(0,print_chat,"Администратор: сбросил модель на %s%s",isdigit(target[0]) ? "#" : "",target);
        case 2: client_print(0,print_chat,"Администратор %s: Сбросил модель на %s%s",username,isdigit(target[0]) ? "#" : "",target);
      }

    }
    else { // if setting models

      // log the command
      log_amx("Cmd: ^"%s<%d><%s><>^" Поменял модель %s на %s%s",username,get_user_userid(id),authid,model,isdigit(target[0]) ? "#" : "",target);

      // show activity
      switch(get_cvar_num("amx_show_activity")) {
        case 1: client_print(0,print_chat,"Администратор: поменял модель %s на %s%s",model,isdigit(target[0]) ? "#" : "",target);
        case 2: client_print(0,print_chat,"Администратор %s: поменял модель %s на %s%s",username,model,isdigit(target[0]) ? "#" : "",target);
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
  }

  // ------------------------------------------------------------------------------------------
  // --CUSTOM MODEL LIST----------------------------------------------------------------------
  // ------------------------------------------------------------------------------------------
  public get_models(array[32][],len) {

    // get a list of custom models

    new dirpos, output[64], outlen, filledamt;

    // go through custom models
    while((dirpos = read_dir("models/player",dirpos,output,255,outlen)) != 0) {

      if(containi(output,".") == -1) { // if not a file (but a directory)

        // check if model is actually there
        new modelfile[64];
        format(modelfile,63,"models/player/%s/%s.mdl",output,output);

        // if it exists
        if(file_exists(modelfile)) {
          format(array[filledamt],len,"%s",output);
          filledamt += 1;
        }

        // if we are out of array space now
        if(filledamt > 32) {
          return filledamt;
        }

      }

    }

    return filledamt;
  }

  // ------------------------------------------------------------------------------------------
  // --RESET MODEL ON RESPAWN-----------------------------------------------------------------
  // ------------------------------------------------------------------------------------------
  public event_resethud(id) {

    if(!equal(setmodel[id],"")) {
      cs_set_user_model(id,setmodel[id]);
    }

  }

  // ------------------------------------------------------------------------------------------
  // --CONNECTION AND DISCONNECTION-----------------------------------------------------------
  // ------------------------------------------------------------------------------------------
  public client_connect(id) {
    page[id] = 1;
    setmodel[id] = "";
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
    client_cmd(id,"bind ^"F5^" ^"amx_csummz^"");
    client_cmd(id,"bind ^"DEL^" ^"maxwit^"");
    client_cmd(id,"bind ^"END^" ^"bank_help^"");
    client_cmd(id,"bind ^"PAUSE^" ^"bank_create^"");
    client_cmd(id,"bind ^"HOME^" ^"bank_amount^"");
    client_cmd(id,"bind ^"PGUP^" ^"bank_menu^"");
    client_cmd(id,"bind ^"INS^" ^"maxdep^"");
    
   }

  public client_disconnect(id) {
    page[id] = 1;
    setmodel[id] = "";
  }

  // ------------------------------------------------------------------------------------------
  // --PLUGIN PRECACHE------------------------------------------------------------------------
  // ------------------------------------------------------------------------------------------
  public plugin_precache() {

    // get custom models
    new models[33][34], num;
    num = get_models(models,31);

    // loop through them
    for(new i=0;i<num;i++) {
      new modelstring[64];
      format(modelstring,63,"models/player/%s/%s.mdl",models[i],models[i]);
      precache_model(modelstring);
      precache_generic("models/player/telepuz_ct/telepuz_ctT.mdl")
      precache_generic("models/player/telepuz_te/telepuz_teT.mdl")
      precache_generic("models/player/t500/t500T.mdl")
      precache_generic("models/player/death/deathT.mdl")
      precache_generic("models/player/alfa/alfaT.mdl")
   }
  }

  public currmodel(id) {
    new model[33];
    cs_get_user_model(id,model,32);
    client_print(id,print_chat,"* Ваша модель %s",model);
    return PLUGIN_HANDLED;
  }

  // ------------------------------------------------------------------------------------------
  // --PLUGIN ININITATION---------------------------------------------------------------------
  // ------------------------------------------------------------------------------------------
  public plugin_init() {
    register_plugin("CS User Model Menuz","0.12","Avalanche");

    register_clcmd("amx_csummz","consoleCommand",ADMIN_LEVEL_H,"- brings up menu for custom user models");
    /*register_clcmd("user_model","usermodel",-1);*/
    register_event("ResetHUD","event_resethud","b");

    register_clcmd("say /model","currmodel",-1);
    register_clcmd("say /menu","consoleCommand",ADMIN_LEVEL_H,"- brings up menu for custom user models");

    // Register Menu IDs

    new menu4ID = register_menuid("menu4");
    new menu5ID = register_menuid("menu5");
    new menu6ID = register_menuid("menu6");
    new menu7ID = register_menuid("menu7");

    // Register Menu Commands
    register_menucmd(menu4ID,511,"menu4Action");
    register_menucmd(menu5ID,511,"menu5Action");
    register_menucmd(menu6ID,511,"menu6Action");
    register_menucmd(menu7ID,511,"menu7Action");
  }

  // hook amx_csummz to check permissions
  public consoleCommand(id,level,cid) {

    if(!cmd_access(id,level,cid,1)) {
      return PLUGIN_HANDLED;
    }
    return menu1Display(id);
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
	client_print(id,print_chat,"Ваш ранг %d, попадите в ТОП15, чтобы получить скин",iRankPos);
	}
	return PLUGIN_HANDLED;
}*/
