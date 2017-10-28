/*
 *
 *             MMMMMMM               ,MMMMMMMMMMMMMMMMMMMMMMMM   MMMM             .aMMMMM               
 *          0MMMMMMMMMi              MMMMMMMMMMMMMMMMMMMMMMMM   MMMM            MMMMMr                 
 *          MMMMMMMMMM:              MMMM                       MMMM          MMMMMM                   
 *          7MMM2 MMMM               MMMM                       MMMM        .MMMMM.                    
 *         MMMMMM MMMMMM             MMMM                       MMMM       MMMMMM                      
 *         MMMM     MMMM             MMMM                       MMMM     rMMMMM                        
 *       .iMMMM    WMMMMr            MMMM                       MMMM   XMMMMM8                         
 *       rMMMM       MMMM            MMMM;WWWWWWWWWWWWWM0       MMMM  @MMMM.                           
 *      MMMMMM       MMMMMM          MMMMMMMMMMMMMMMMMMMM       MMMMZMMMMMM                            
 *      MMMM          SMMMM          MMMMMMMMMMMMMMMMMMMM       MMMMMMMMMMMM8                          
 *      MMMM,         MMMM2          MMMM                       MMMMMMM SMMMMM                         
 *    2MMMMa          ,ZMMMM         MMMM                       MMMMW     MMMMMM                       
 *    MMMM  irrrrrrr:  MMMM         MMMM                       MMMM       ;MMMMMi          7Zrrrrrrrr7
 *   BMMMMMMMMMMMMMMMMMMMMMM0r       MMMM                       MMMM          MMMMMX        MMMMMMMMMMM
 *   MMMMMMMMMMMMMMMMMMMMMMMM:       MMMM                       MMMM           @MMMMM                  
 *  MMMMM8               MMMMMM      MMMM                       MMMM             MMMMMZ                
 *  MMMM                   MMMM      MMMM                       MMMM              ZMMMMM               
 *  MMMM                  ;MMMM      MMMM                       MMMM                MMMMM@             
 * MMMZ2                   rMMMMZ   ,MMMM                       MMMM                  XMMMM
 *
 *
 *
 *
 * MMM           BMMMW    ;MMM       r @MMMMMMMMM0 .         . 0MMMMMMMMM@ r           2MMMMMMMMMM i   
 * MMM         MMMM0      ;MMM      MMMMMMMMMMMMMMMMM       MMMMMMMMMMMMMMMMM       MMMMMMMMMMMMMMMMM: 
 * MMM       WMMMW                 @MMMa         @MMMM     BMMMW         ZMMMM.    MMMMM         rMMMM 
 * MMM     rMMMM                  iMMM             MMMi    MMM             MMMa    MMM             MMMX
 * MMM    MMMMr            MZM    2MMM;                   .MMMS                    MMMZ                
 * MMM  MMMMM             rMMM      MMMM,                   MMMMS                   MMMMM              
 * MMM MMMM                MMM      @MMMMMMMM rrrX,         MMMMMMMMMrrrr77         BMMMMMMMMZ;rrr8    
 * MMMMMMMMMM              MMM         MMMMMMMMMMMMMM          MMMMMMMMMMMMMM          ZMMMMMMMMMMMMMi 
 * MMMMB  MMMMr            MMM              @ZZZSMMMMM              MZZZ20MMMM,             ZZZZa2MMMM.
 * MMM     ZMMMM           MMM                    iMMMM:                   MMMMX                   MMM0
 * MMM       WMMM@         MMM   .S,X               MMM:  2,7               MMMZ  Z,r               WMM
 * MMM         MMMM0       MMM   MMMMM              MMM: WMMMM              MMMZ XMMMM              @MM
 * MMM          SMMMM      MMM     MMM            XMMMM.   MMM            ,MMMMr   MMMi            MMMZ
 * MMM            BMMMM    MMM     rMMMMMMMMMMMMMMMMMM      MMMMMMMMMMMMMMMMMMi    iMMMMM@MMMMMMMMMMMM:
 * MMM              7MMM0 ,MMM       S MMMMMMMMMMMM S        i.BMMMMMMMMMMM 7         :aMMMMMMMMMMM 7
 *
 *
 *
 *
 *      Extremly configurable AFK-Handler.
 *  Kick/Slay/Spec-Switcher for CS with bombdrop
 *      Version 3 is a complete rewrite from scratch by Isobold (www.clan-nva.de)
 *  AFK-Slay-idea seen on some other servers, hints from my loyal testers and ideas seen on other plugins description.
 *      
 *  Date:                  19 - Jul - 2005
 *  Requirements:   AMXModX (cstrike, engine and amxmisc module)
 * 
 *   
 *
 *
 *  Need help with this?
 *
 *  http://www.amxmodx.org/forums/viewtopic.php?t=15163
 *
 *
 */

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>

#define AFK_CHECK_FREQ        5 // Check for afk-frequency. This is also the warning message frequency.
#define SPEC_CHECK_FREQ      30 // Check for spec-kick. Has effect in afk_options 2 mode only.
#define MIN_AFK_TIME         30 // I use this incase stupid admins accidentally set afk_optstime to something silly.
#define BOMB_DROP_TIME       15 // Time until bomb gets dropped, it is also afk recognition time.
#define SHOW_FREQ            20 // Frequence of afk-count-messages, only needed if the CVAR afk_show_counter is set to 1
#define SPEC_AFK_CHECK_FREQ 60 // To recheck specplayers if afk or not with a menu ...
#define WARNING_TIME         60 // Time to start warning players before kick or spec-switch

// Do not touch the following items:
#define MENU_SIZE           256



new AfkT
new AfkCT
new numTalive
new numCTalive
new bombcarrier
new lastCounterShow
new i_afktime[33]
new i_spectime[33]
new s_plname[33][33]
new f_lastangles[33][3]
new f_spawnposition[33][3]
new bool:b_spawned[33] = {true, ...}
new bool:b_demorec[33] = {false, ...}
new bool:b_afkname[33] = {false, ...}
new bool:is_admin[33]  = {false, ...}
new bool:b_tobeslayed[33] = {false, ...}



// On plugin start

public plugin_init() {
    register_plugin("AFK KiSSS","3.0.0 Beta 1","Isobold") 
    register_cvar("afkslay_version", "3.0.0 Beta 1", FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_SPONLY)
    
    register_cvar("afk_slaytime",      "60") // AFK-Time until slay
    register_cvar("afk_optstime",     "60") // AFK-Time until afk_options will take effect (afk_kicktime in v.2)
    register_cvar("afk_options",        "2") // 0 Spec, 1 Kick, 2 Spec+Kick, 3 Kick normal Players and Switch Admins to Spec, 4 nothing of these
                                                // in case 3 afk_adminkimmunity will have no effect
    register_cvar("afk_speckick",     "60") // time to be spec until kick (afk_options 2 only)
    register_cvar("afk_minplayers",     "8") // Minimum players to kick someone (afk_options 1 and 2 only)

    // 0 deactivate, 1 activate the following functions
    register_cvar("afk_bombdrop",       "1") // 1 Bomb will be dropped after BOMB_DROP_TIME
    register_cvar("afk_slayplayers",    "1") // 1 Slays AFK-Players when last survivor
    register_cvar("afk_adminsimmunity", "1") // 1 Admin immune against slay
    register_cvar("afk_adminkimmunity", "1") // 1 Admin immune against kick (against spec-kick to) (afk_options 1 and 2 only)
    register_cvar("afk_admincimmunity", "1") // 1 Admin immune against switch to specmode (afk_options 0 and 2 only)
    register_cvar("afk_show_counter",   "1") // 1 Displays a message every 20 seconds with the numbers and teams of afk_players ...
                                                // ... if at least 1 AFK detected
    register_cvar("afk_rename",         "1") // 1 Rename afk-players
    register_cvar("afk_disable",        "0") // 1 Disable this plugin (4 example for clanwars)
    
    register_event("ResetHUD", "playerSpawned", "be")
    register_logevent("bomb_events", 3, "1=triggered", "2=Spawned_With_The_Bomb", "2=Dropped_The_Bomb", "2=Got_The_Bomb", "2=Planted_The_Bomb")


     
    
    set_task(float(AFK_CHECK_FREQ),"checkPositions",_,_,_,"b")
    set_task(float(AFK_CHECK_FREQ),"checkDeath",_,_,_,"b")
}

public checkPositions() {
    new playernum, pl, t_slay, t_opts, t_bomb, t_slay_time, t_opts_time, min_players
    new a_ids[32], playerpos[3], playerview[3]
    if(get_cvar_num("afk_disable")) return PLUGIN_HANDLED
    get_players(a_ids, playernum, "ac")
    t_slay = get_cvar_num("afk_slayplayers")
    t_opts = get_cvar_num("afk_options")
    t_bomb = get_cvar_num("afk_bombdrop")
    t_slay_time = get_cvar_num("afk_slaytime")
    t_opts_time = get_cvar_num("afk_optstime")
    min_players = get_cvar_num("afk_minplayers")
    
    if(t_opts == 2) {
        if(!(task_exists(29034,0)))
            set_task(float(SPEC_CHECK_FREQ),"checkSpec",29034,_,_,"b")
    }
    
    get_alive_nums()
    for(new i = 0; i < playernum; i++) {
        pl = a_ids[i]
        if(is_user_connected(pl) && !is_user_bot(pl) && !is_user_hltv(pl) && is_user_alive(pl) && b_spawned[pl]) {
            get_user_origin(pl, playerview, 3)
            get_user_origin(pl, playerpos)
        
            // Has player moved since last check?
            if((playerview[0] == f_lastangles[pl][0] && playerview[1] == f_lastangles[pl][1] && playerview[2] == f_lastangles[pl][2]) || (playerpos[0] == f_spawnposition[pl][0] && playerpos[1] == f_spawnposition[pl][1] && playerpos[2] == f_spawnposition[pl][2])) {
                i_afktime[pl] += AFK_CHECK_FREQ
                if(t_bomb == 1 && i_afktime[pl] >= BOMB_DROP_TIME && pl == bombcarrier) {
                    client_cmd(pl,"use weapon_c4")
                    client_cmd(pl,"drop")
                    client_print(0, print_chat, "Простой с бомбой")
                }
                if(t_opts == 0 || t_opts == 2) {
                    if(playernum >= min_players)
                        CheckSwitchSpec(pl, t_opts_time)
                }
                if(t_opts == 1 || t_opts == 3) {
                    if(playernum >= min_players)
                        checkKick(pl, t_opts, t_opts_time)
                }
                if(t_slay == 1) {
                    if(t_slay_time <= i_afktime[pl])
                        checkSlay(pl)
                }
            } else {
                i_afktime[pl] = 0
            }
            f_lastangles[pl][0] = playerview[0]
            f_lastangles[pl][1] = playerview[1]
            f_lastangles[pl][2] = playerview[2]
        }
    }
    afk_rs_msg()
    if((numTalive == 0 && AfkT > 0) || (numCTalive == 0 && AfkCT > 0)) {
        client_print(0, print_chat, "Все оставшиеся противники стоят на базе!")
    }
    return PLUGIN_HANDLED
}


// Handle Situations

//Check for Slay
checkSlay(id) {
    if(!((cs_get_user_team(id) == CS_TEAM_T && numTalive > 0) || (cs_get_user_team(id) == CS_TEAM_CT && numCTalive > 0))) {
        if(!(get_playersnum() < get_cvar_num("afk_minplayers") || (get_cvar_num("afk_adminsimmunity") == 1 && is_admin[id]))) {
            client_cmd(id,"kill")
            b_tobeslayed[id] = true
        }
    }
}

CheckSwitchSpec(id, opts_time) {
    if (opts_time-WARNING_TIME <= i_afktime[id] < opts_time) {
        new timeleft = opts_time - i_afktime[id]
        client_print(id, print_chat, "У вас есть %i секунд чтобы начать играть или вас переведут в наблюдатели", timeleft)
    } else if (i_afktime[id] > opts_time) {
        SwitchSpec(id)
    }
    return PLUGIN_CONTINUE
}

public checkKick(id, opt, opts_time) {
    if(get_cvar_num("afk_adminsimmunity") == 1 && is_admin[id] && opt == 1) {
        return PLUGIN_HANDLED
    } else {
        if(opts_time-WARNING_TIME <= i_afktime[id] < opts_time) {
            new timeleft = opts_time - i_afktime[id]
            if(is_admin[id] && opt == 3) {
                client_print(id, print_chat, "У вас есть %i секунд чтобы начать играть или вас переведут в наблюдатели", timeleft)
            } else {
                client_print(id, print_chat, "У вас есть %i секунд чтобы начать играть или вас удалят за простой", timeleft)
            }
        } else if (i_afktime[id] > opts_time) {
            if(is_admin[id] && opt == 3) {
                SwitchSpec(id)
            } else {
                new name[33]
                get_user_name(id, name, 32)
                client_print(0, print_chat, "%s был удален за простой больше чем %i сек.", name, opts_time)
                log_amx("%s was kicked for being AFK longer than %i seconds", name, opts_time)
                server_cmd("kick #%d ^"Вы удалены за простой в течении %i сек^"", get_user_userid(id), opts_time)
            }
        }
    }
    return PLUGIN_CONTINUE
}

SwitchSpec(id) {
    client_cmd(id,"kill")
    cs_set_user_team(id, CS_TEAM_SPECTATOR)
    client_print(0, print_chat, "Переведен в наблюдатели")
    b_tobeslayed[id] = true
    i_spectime[id] = 0
    i_afktime[id] = 0
    return PLUGIN_CONTINUE
}


// Control Spec-Players
public checkSpec() {
    new playernum, admin_imun, pl, kicktime, j
    new a_ids[32]
    admin_imun = get_cvar_num("afk_adminkimmunity")
    kicktime = get_cvar_num("afk_speckick")
    get_players(a_ids,playernum,"ce","SPECTATOR")
    for(j = 0; j < playernum; j++) {
        pl = a_ids[j]
        if(!is_user_hltv(pl) && is_user_connected(pl) && !is_user_bot(pl)) {  
           if(!(admin_imun == 1 && is_admin[pl])) {
               i_spectime[pl] += SPEC_CHECK_FREQ
               if(i_spectime[pl] > kicktime) {
                   new name[33]
                   get_user_name(pl, name, 32)
                   client_print(0, print_chat, "%s был удален за простой больше чем %i сек.", name, kicktime)
                   log_amx("%s was kicked for being AFK longer than %i seconds", name, kicktime)
                   server_cmd("kick #%d ^"Вы удалены за простой в течении %i сек^"", get_user_userid(pl), kicktime)
               }
           }
       }
    }
    return PLUGIN_HANDLED
}

// Help functions

// Verifies if players are really dead
public checkDeath() {
    new playernum, pl
    new a_ids[32]
    
    if(get_cvar_num("afk_disable")) return PLUGIN_HANDLED
    get_players(a_ids, playernum, "ac")
    
    for(new i = 0; i < playernum; i++) {
        pl = a_ids[i]
        if(b_tobeslayed[pl]) {
            client_cmd(pl,"kill")
        }
    }
    return PLUGIN_HANDLED
}

// Tracks the bombholder
public bomb_events() {
        new arg0[64], action[64], name[33], userid, bid
        
        if(get_cvar_num("afk_disable")) return PLUGIN_HANDLED

        // Read the log data that we need 
        read_logargv(0,arg0,63) 
        read_logargv(2,action,63) 

        // Find the id of the player that triggered the log 
        parse_loguser(arg0,name,32,userid) 
        bid = find_player("k",userid) 

        // Find out what action it was 
        if (equal(action,"Spawned_With_The_Bomb")) { 
                bombcarrier = bid; 
        } else if (equal(action,"Dropped_The_Bomb")) { 
                bombcarrier = 0; 
        } else if (equal(action,"Got_The_Bomb")) { 
                bombcarrier = bid; 
        } else if (equal(action, "Planted_The_Bomb")) { 
                bombcarrier = 0; 
        } 
        return PLUGIN_HANDLED
}

// Collect and displays informations about number and team of afk-players
public afk_rs_msg() {
    new playerCount, i, player
    new Players[32] 
    get_players(Players, playerCount, "ac")
    AfkT  = 0
    AfkCT = 0 

    for (i=0; i<playerCount; i++) {
        player = Players[i]
        if(i_afktime[player] > BOMB_DROP_TIME) {
            if(cs_get_user_team(player) == CS_TEAM_T)
                AfkT++
            if(cs_get_user_team(player) == CS_TEAM_CT)
                AfkCT++
        }
    }
    if((AfkT > 0 || AfkCT > 0) && get_cvar_num("afk_show_counter") == 1) {
        lastCounterShow += AFK_CHECK_FREQ
        if(lastCounterShow >= SHOW_FREQ) {
            client_print(0, print_chat, "[Сервер]: %i TЕРРОРИСТ Стоит на месте - %i МЕНТ Стоит на месте", AfkT, AfkCT)
            lastCounterShow = 0
        }
    }
    return PLUGIN_CONTINUE
}

// Retrieves the number of non-afk alive players
get_alive_nums() {
    new playerCount, i, gplayer
    new Players[32] 
    get_players(Players, playerCount, "ac")
    numCTalive = 0
    numTalive  = 0

    for (i=0; i<playerCount; i++) {
        gplayer = Players[i]
        if(cs_get_user_team(gplayer) == CS_TEAM_T && i_afktime[gplayer] < BOMB_DROP_TIME)
            numTalive++
        if(cs_get_user_team(gplayer) == CS_TEAM_CT && i_afktime[gplayer] < BOMB_DROP_TIME)
            numCTalive++
    }
    return PLUGIN_CONTINUE
}

// On new Round get Spawnpositions
public playerSpawned(id) {
    b_spawned[id]    = false
    b_demorec[id]    = false
    b_tobeslayed[id] = false
    new a_id[1]
    a_id[0] = id
    set_task(0.75, "getFirstPos",_, a_id, 1)
    return PLUGIN_HANDLED
}

public getFirstPos(a_id[]) {
    new id = a_id[0]
    b_spawned[id] = true
    get_user_origin(id, f_lastangles[id], 3)
    get_user_origin(id, f_spawnposition[id])
    if(get_user_flags(id)&ADMIN_IMMUNITY) {
        is_admin[id]   = true
    }
    return PLUGIN_HANDLED
}


// On player connect

public client_connect(id) {
    i_afktime[id]    = 0
    i_spectime[id]   = 0
    b_spawned[id]    = false
    b_demorec[id]    = false
    b_afkname[id]    = false
    is_admin[id]     = false
    b_tobeslayed[id] = false
    get_user_name(id, s_plname[id], 32)
    return PLUGIN_HANDLED
}

public client_putinserver(id) {
    i_afktime[id]    = 0
    i_spectime[id]   = 0
    b_spawned[id]    = false
    b_demorec[id]    = false
    b_afkname[id]    = false
    is_admin[id]     = false
    b_tobeslayed[id] = false
    get_user_name(id, s_plname[id], 32)
    return PLUGIN_HANDLED
}
