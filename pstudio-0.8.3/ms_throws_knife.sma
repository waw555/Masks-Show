/* AMX Mod X script.
*
*   Throwing Knives (throwing_knives.sma)
*   Copyright (C) 2003-2004  -]ToC[-Bludy / jtp10181
*
*   This program is free software; you can redistribute it and/or
*   modify it under the terms of the GNU General Public License
*   as published by the Free Software Foundation; either version 2
*   of the License, or (at your option) any later version.
*
*   This program is distributed in the hope that it will be useful,
*   but WITHOUT ANY WARRANTY; without even the implied warranty of
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*   GNU General Public License for more details.
*
*   You should have received a copy of the GNU General Public License
*   along with this program; if not, write to the Free Software
*   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*
*   In addition, as a special exception, the author gives permission to
*   link the code of this program with the Half-Life Game Engine ("HL
*   Engine") and Modified Game Libraries ("MODs") developed by Valve,
*   L.L.C ("Valve"). You must obey the GNU General Public License in all
*   respects for all of the code used other than the HL Engine and MODs
*   from Valve. If you modify this file, you may extend this exception
*   to your version of the file, but you are not obligated to do so. If
*   you do not wish to do so, delete this exception statement from your
*   version.
*
****************************************************************************
*
*   Version 1.0.2 - Date: 10/09/2004
*
*   Original by -]ToC[-Bludy
*
*   Upgraded to STEAM and ported to AMXx by: jtp10181 <jtp@jtpage.net>
*   Homepage: http://www.jtpage.net
*
****************************************************************************
*
*   Admin Commands:
*
*     amx_tknives	- Toggles Throwing Knives On and Off
*
*   Client Commands:
*
*     throw_knife		- This is the command for everyone to throw knives
*     say /knifehelp		- Brings up knifehelp menu to help players bind keys
*     say /throwingknives	- Same as /knifehelp
*
*  CVARs: Paste the following into your amxx.cfg to change defaults.
*		must uncomment cvar lines for them to take effect
*
****************************************************************************
*  CVAR CONFIG BEGIN
****************************************************************************

// ******************  Throwing Knives Setup ******************

//Toggles Throwing Knives on and off (default 0) ( 1 or 0 )
//amx_throwknives 1

//The amount of ammo to be given at roundstart (default 5) ( 1 or higher )
//amx_knifeammo 5

//Force at which knives are thrown (default 1200) ( 200 or higher )
//amx_knifetossforce 1200

//Maximum amount of knives allowed at once (default 10) ( amx_knifeammo or higher )
//amx_maxknifeammo 10

//Damage dealt on a knife hit (default 25) ( 1 or higher )
//amx_knifedmg 25

//Toggles knife dropping on death on and off (default 1) ( 1 or 0 )
//amx_dropknives 1

//Toggles autoswitching to knife when bind is pressed (default 1) ( 1 or 0 )
//amx_knifeautoswitch 1

//Toggles logging kill as "throwing_knife" or "knife" (default 0) (1 = throwing_knife, 0 = knife)
//amx_tknifelog 1

****************************************************************************
*  CVAR CONFIG END
****************************************************************************
*
*  Additional info:
*
*	- You must bind a key to throw_knife
*	- You can no longer drop your knives on command, only when you die
*	- Team Attack system dropped, but it will obey the server friendlyfire cvar
*
*  NEW FEATURES:
*
*	- New knife model, more effecient, smaller file size, easier to download
*	- New contact system, knife will stick to whatever they hit
*	- New code which is less CPU intensive, less bugs, server crashing seems to be eliminated.
*
*  DESCRIPTION:
*
*     It was brought to my attention a few days ago that with the update to the 
*     AMX forums the file attached to the bottom of the forum topic had only an 
*     .amx file and no custom model.  This gave me the motivation to create a new 
*     model that was smaller and faster to download, and a brand new knife system 
*     to make the knives more realistic.  It took a few server crashes to get the 
*     code right, but it payed off in the end.  A few of my clan members and I 
*     played throwing knife darts on one of the 
*     players sprays to celebrate.
*             
*     The knives work a lot better than before, and they are a lot of fun to 
*     play with. So get your knives out and go Have Fun
*
*                 ******** Engine Module REQUIRED ********
*                   ******** FUN Module REQUIRED ********
*
*  Changelog:
*
*  v1.0.2 - JTP10181 - 10/09/04
*	- Support for AMXModX 0.20
*
*  v1.0.1 - JTP10181 - 08/11/04
*	- Some tweaks to make it work better on listenservers, changed engclient_cmd to client_cmd
*
*  v1.0 - JTP10181 - 07/05/04
*	- Removed some unneeded return statements
*	- Made it so the knives cannot be used before the round has started (freezetime)
*	- Added some extra checks on variables to be safe
*	- Redid the delay code so it did not use a task
*	- Changed authid arrays to be 34 usable chars for future compatibility
*
*  v0.9.8 - JTP10181 - 06/08/04
*	- Tweaked the help messages a little for the commands
*	- Removed all \ line breaks, not supported anymore.
*	- Somewhere I added the auto-switch feature but forgot to log it.
*
*  v0.9.7 - JTP10181 - 05/19/04
*	- Upgraded MOTD box to STEAM compatibility
*	- Fixed bugs that happened when amx_knifeammo is greater than amx_maxknifeammo
*	- Made checks to keep amx_knifeammo from being set higher than amx_maxknifeammo
*	- Started to reorganize code to make it easier to follow
*	- Changed a lot of PLUGIN_HANDLED to PLUGIN_CONTINUE
*	- Fixed bug with partial pickups not subtracting the correct ammount from the dropped ammo
*	- Hopefully fixed bug that would sometimes kill all the knife entities in the middle of a round
*	- Added logging to server logs for stats software
*	- Fixed bugs with scores being updated wrong
*
*  Below v0.9.6 was maintained by -]ToC[-Bludy
*
**************************************************************************/

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fun>

new bool:knifeout[33]
new bool:roundfreeze
new Float:tossdelay[33]
new knifeammo[33]
new holdammo[33]

public player_death() {
	new id = read_data(2)
	knife_drop(id)
}

public HandleSay(id) {

	new Speech[192]
	read_args(Speech,192)
	remove_quotes(Speech)
	if(!equal(Speech, "vote",4) && ((containi(Speech, "knife") != -1) || (containi(Speech, "knives") != -1))) {
		if(get_cvar_num("amx_throwknives") == 1){
			client_print(id,print_chat, "Включена возможность бросать нож")
		}
		else {
			client_print(id,print_chat, "Возможность кидать ножи отключена")
		}
	}
}

public knife_drop(id) {
	
	if(!get_cvar_num("amx_dropknives") || knifeammo[id] <= 0 || !get_cvar_num("amx_throwknives")) return

	new Float: Origin[3], Float: Velocity[3]
	entity_get_vector(id, EV_VEC_origin, Origin)

	new knifedrop = create_entity("info_target")
	if(!knifedrop) return

	entity_set_string(knifedrop, EV_SZ_classname, "knife_pickup")
	entity_set_model(knifedrop, "models/ms/w_knifepack.mdl")

	new Float:MinBox[3] = {-1.0, -1.0, -1.0}
	new Float:MaxBox[3] = {1.0, 1.0, 1.0}
	entity_set_vector(knifedrop, EV_VEC_mins, MinBox)
	entity_set_vector(knifedrop, EV_VEC_maxs, MaxBox)

	entity_set_origin(knifedrop, Origin)

	entity_set_int(knifedrop, EV_INT_effects, 32)
	entity_set_int(knifedrop, EV_INT_solid, 1)
	entity_set_int(knifedrop, EV_INT_movetype, 6)
	entity_set_edict(knifedrop, EV_ENT_owner, id)

	VelocityByAim(id, 400 , Velocity)
	entity_set_vector(knifedrop, EV_VEC_velocity ,Velocity)
	holdammo[id] = knifeammo[id]
	knifeammo[id] = 0
}

public check_knife(id) {
	if(!get_cvar_num("amx_throwknives")) return

	new weapon = read_data(2)
	if(weapon == CSW_KNIFE) {
		knifeout[id] = true
		/*if(knifeammo[id] > 1) {
			client_print(id, print_center,"Вы имеете %d нож(а/ей)",knifeammo[id])
		}
		else if(knifeammo[id] == 1) {
			client_print(id, print_center,"Вы имеете %d нож(а/ей).",knifeammo[id])
		}*/
		client_print(id, print_center,"У вас есть %d %s для метания",knifeammo[id], knifeammo[id] == 1 ? "нож(а)" : "ножей")
	}
	else {
		knifeout[id] = false
	}
}

public kill_all_entity(classname[]) {
	new iEnt = find_ent_by_class(-1, classname)
	new tEnt
	while(iEnt > 0) {
		tEnt = iEnt
		iEnt = find_ent_by_class(iEnt, classname)
		remove_entity(tEnt)
	}
}

public new_spawn(id) {

	if(knifeammo[id] < get_cvar_num("amx_knifeammo")) knifeammo[id] = get_cvar_num("amx_knifeammo")
	if(knifeammo[id] > get_cvar_num("amx_maxknifeammo")) knifeammo[id] = get_cvar_num("amx_maxknifeammo")
	tossdelay[id] = 0.0
}

public client_connect(id) {

	knifeammo[id] = get_cvar_num("amx_knifeammo")
	holdammo[id] = 0
	tossdelay[id] = 0.0
	knifeout[id] = false
	client_cmd(id, "bind mouse3 throw_knife")
}

public client_authorized(id){
	client_cmd(id, "bind mouse3 knife")
}

public client_disconnected(id) {

	knifeammo[id] = 0
	holdammo[id] = 0
	tossdelay[id] = 0.0
	knifeout[id] = false
}

public round_start() {
	roundfreeze = false
}
public round_end() {
	roundfreeze = true
	kill_all_entity("throwing_knife")
	kill_all_entity("knife_pickup")
}

public vexd_pfntouch(pToucher, pTouched) {

	if ( !is_valid_ent(pToucher) ) return
	if (!get_cvar_num("amx_throwknives")) return

	new Classname[32]
	entity_get_string(pToucher, EV_SZ_classname, Classname, 31)
	new owner = entity_get_edict(pToucher, EV_ENT_owner)
	new Float:kOrigin[3]
	entity_get_vector(pToucher, EV_VEC_origin, kOrigin)

	if(equal(Classname,"knife_pickup")) {
		if ( !is_valid_ent(pTouched) ) return
		
		check_cvars()
		new Class2[32]     
		entity_get_string(pTouched, EV_SZ_classname, Class2, 31)
		if(!equal(Class2,"player") || knifeammo[pTouched] >= get_cvar_num("amx_maxknifeammo")) return

		if((knifeammo[pTouched] + holdammo[owner]) > get_cvar_num("amx_maxknifeammo")) {
			holdammo[owner] -= get_cvar_num("amx_maxknifeammo") - knifeammo[pTouched]
			knifeammo[pTouched] = get_cvar_num("amx_maxknifeammo")
			emit_sound(pToucher, CHAN_ITEM, "weapons/knife_deploy1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
		else {
			knifeammo[pTouched] += holdammo[owner]
			emit_sound(pToucher, CHAN_ITEM, "weapons/knife_deploy1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			remove_entity(pToucher)
		}
		client_print(pTouched, print_center,"Вы имеете %i нож(а/ей)",knifeammo[pTouched])
	}

	else if(equal(Classname,"throwing_knife")) {
		check_cvars()
		if(is_user_alive(pTouched)) {
			new movetype = entity_get_int(pToucher, EV_INT_movetype)
			if(movetype == 0 && knifeammo[pTouched] < get_cvar_num("amx_maxknifeammo")) {
				if(knifeammo[pTouched] < get_cvar_num("amx_maxknifeammo")) knifeammo[pTouched] += 1
				client_print(pTouched,print_center,"Вы имеете %i нож(а/ей)",knifeammo[pTouched])
				emit_sound(pToucher, CHAN_ITEM, "weapons/knife_deploy1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
				remove_entity(pToucher)
			}
			else if (movetype != 0) {
				if(owner == pTouched) return

				remove_entity(pToucher)

				if(get_cvar_num("mp_friendlyfire") == 1 && get_user_team(pTouched) == get_user_team(owner)) return

				new pTdead[33]
				entity_set_float(pTouched, EV_FL_dmg_take, get_cvar_num("amx_knifedmg") * 1.0)

				if((get_user_health(pTouched) - get_cvar_num("amx_knifedmg")) <= 0) {
					pTdead[pTouched] = 1
				}
				else {
					set_user_health(pTouched, get_user_health(pTouched) - get_cvar_num("amx_knifedmg"))
				}

				if(get_user_team(pTouched) == get_user_team(owner)) {
					new name[33]
					get_user_name(owner,name,32)
					client_print(0,print_chat,"%s Аттаковал товарища",name)
				}

				emit_sound(pTouched, CHAN_ITEM, "weapons/knife_hit4.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)

				if(pTdead[pTouched]) {
					if(get_user_team(pTouched) == get_user_team(owner)) {
						set_user_frags(owner, get_user_frags(owner) - 1)
						client_print(owner,print_center,"Вы убили товарища")
					}
					else {
						set_user_frags(owner, get_user_frags(owner) + 1)
					}

					new gmsgScoreInfo = get_user_msgid("ScoreInfo")
					new gmsgDeathMsg = get_user_msgid("DeathMsg")

					//Kill the victim and block the messages
					set_msg_block(gmsgDeathMsg,BLOCK_ONCE)
					set_msg_block(gmsgScoreInfo,BLOCK_ONCE)
					user_kill(pTouched,1)

					//Update killers scorboard with new info
					message_begin(MSG_ALL,gmsgScoreInfo)
					write_byte(owner)
					write_short(get_user_frags(owner))
					write_short(get_user_deaths(owner))
					write_short(0)
					write_short(get_user_team(owner))
					message_end()

					//Update victims scoreboard with correct info
					message_begin(MSG_ALL,gmsgScoreInfo)
					write_byte(pTouched)
					write_short(get_user_frags(pTouched))
					write_short(get_user_deaths(pTouched))
					write_short(0)
					write_short(get_user_team(pTouched))
					message_end()

					//Replaced HUD death message
					message_begin(MSG_ALL,gmsgDeathMsg,{0,0,0},0)
					write_byte(owner)
					write_byte(pTouched)
					write_byte(0)
					write_string("knife")
					message_end()

					new tknifelog[16]
					if (get_cvar_num("amx_tknifelog")) tknifelog = "throwing_knife"
					else tknifelog = "knife"

					new namea[32], authida[35], teama[32]
					new namev[32], authidv[35], teamv[32]
					get_user_name(owner,namea,31)
					get_user_authid(owner,authida,34)
					get_user_team(owner,teama,31)
					get_user_name(pTouched,namev,31)
					get_user_authid(pTouched,authidv,34)
					get_user_team(pTouched,teamv,31)

					log_message("^"%s<%d><%s><%s>^" убийств ^"%s<%d><%s><%s>^" с ^"%s^"",
					namea,get_user_userid(owner),authida,teama,namev,get_user_userid(pTouched),authidv,teamv,tknifelog)
				}
			}
		}
		else {
			entity_set_int(pToucher, EV_INT_movetype, 0)
			emit_sound(pToucher, CHAN_ITEM, "weapons/knife_hitwall1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
	}
}

public command_knife(id) {

	if(!is_user_alive(id) || !get_cvar_num("amx_throwknives") || roundfreeze) return PLUGIN_HANDLED

	if(get_cvar_num("amx_knifeautoswitch")) {
		knifeout[id] = true
		//engclient_cmd(id,"weapon_knife")
		client_cmd(id,"weapon_knife")
	}

	if(!knifeammo[id]) client_print(id,print_center,"У Вас нет ножей",knifeammo[id])
	if(!knifeout[id] || !knifeammo[id]) return PLUGIN_HANDLED

	if(tossdelay[id] > get_gametime() - 0.5) return PLUGIN_HANDLED
	else tossdelay[id] = get_gametime()

	knifeammo[id]--

	if (knifeammo[id] == 1) {
		client_print(id,print_center,"Вы имеете %i нож(а/ей)",knifeammo[id])
	}
	else {
		client_print(id,print_center,"Вы имеете %i нож(а/ей)",knifeammo[id])
	}

	new Float: Origin[3], Float: Velocity[3], Float: vAngle[3], Ent

	entity_get_vector(id, EV_VEC_origin , Origin)
	entity_get_vector(id, EV_VEC_v_angle, vAngle)

	Ent = create_entity("info_target")

	if (!Ent) return PLUGIN_HANDLED

	entity_set_string(Ent, EV_SZ_classname, "throwing_knife")
	entity_set_model(Ent, "models/ms/w_throwingknife.mdl")

	new Float:MinBox[3] = {-1.0, -7.0, -1.0}
	new Float:MaxBox[3] = {1.0, 7.0, 1.0}
	entity_set_vector(Ent, EV_VEC_mins, MinBox)
	entity_set_vector(Ent, EV_VEC_maxs, MaxBox)

	vAngle[0] -= 90

	entity_set_origin(Ent, Origin)
	entity_set_vector(Ent, EV_VEC_angles, vAngle)

	entity_set_int(Ent, EV_INT_effects, 2)
	entity_set_int(Ent, EV_INT_solid, 1)
	entity_set_int(Ent, EV_INT_movetype, 6)
	entity_set_edict(Ent, EV_ENT_owner, id)

	VelocityByAim(id, get_cvar_num("amx_knifetossforce") , Velocity)
	entity_set_vector(Ent, EV_VEC_velocity ,Velocity)
	
	return PLUGIN_HANDLED
}

public admin_tknife(id,level,cid){
	
	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED

	new authid[35],name[32]
	get_user_authid(id,authid,34)
	get_user_name(id,name,31)

	if(get_cvar_num("amx_throwknives") == 0){
		set_cvar_num("amx_throwknives",1)
		client_print(0,print_chat,"Администратор включил возможность бросать ножи")
		console_print(id,"Вы можете бросать ножи")
		log_amx("Администратор: ^"%s<%d><%s><>^" включил возможность бросать ножи",name,get_user_userid(id),authid)
	}
	else {
		set_cvar_num("amx_throwknives",0)
		client_print(0,print_chat,"Администратор отключил возможность бросать ножи")
		console_print(id,"Вы не можете бросать ножи")
		log_amx("Администратор: ^"%s<%d><%s><>^" отключил возможность бросать ножи",name,get_user_userid(id),authid)
	}
	return PLUGIN_HANDLED
}

/************************************************************
* CORE PLUGIN FUNCTIONS
************************************************************/

public plugin_init()
{
	register_plugin("Метание ножей","1.0","WAW555")

	register_event("ResetHUD","new_spawn","b")
	register_event("CurWeapon","check_knife","b","1=1")
	register_event("DeathMsg", "player_death", "a")
	register_logevent("round_start", 2, "1=Round_Start") 
	register_logevent("round_end", 2, "1=Round_End")
	
	register_clcmd("throw_knife","command_knife",0,"- throws a knife if the plugin is enabled")
	register_concmd("amx_tknives","admin_tknife",ADMIN_LEVEL_C,"- toggles throwing knives on/off")

	register_cvar("amx_throwknives","1",FCVAR_SERVER)
	register_cvar("amx_knifeammo","5")
	register_cvar("amx_knifetossforce","1200")
	register_cvar("amx_maxknifeammo","5")
	register_cvar("amx_knifedmg","25")
	register_cvar("amx_dropknives","0")
	register_cvar("amx_knifeautoswitch","1")
	register_cvar("amx_tknifelog","0")

	check_cvars()
}

public plugin_precache()
{
	precache_sound("weapons/knife_hitwall1.wav")
	precache_sound("weapons/knife_hit4.wav")
	precache_sound("weapons/knife_deploy1.wav")
	precache_model("models/ms/w_knifepack.mdl")
	precache_model("models/ms/w_throwingknife.mdl")
}

public check_cvars() {
	if (get_cvar_num("amx_knifeammo") > get_cvar_num("amx_maxknifeammo")) {
		server_print("[AMXX] amx_knifeammo can not be greater than amx_maxknifeammo, adjusting amx_maxknifeammo")
		set_cvar_num("amx_maxknifeammo",get_cvar_num("amx_knifeammo"))
	}
	if (get_cvar_num("amx_knifedmg") < 1 ) {
		server_print("[AMXX] amx_knifedmg can not be set lower than 1, setting cvar to 1 now.")
		set_cvar_num("amx_knifedmg",0)
	}
	if (get_cvar_num("amx_knifetossforce") < 200 ) {
		server_print("[AMXX] amx_knifetossforce can not be set lower than 200, setting cvar to 200 now.")
		set_cvar_num("amx_knifetossforce",200)
	}
}