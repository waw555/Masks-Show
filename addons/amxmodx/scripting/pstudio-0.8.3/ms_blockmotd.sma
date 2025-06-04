#include <amxmodx> 
#include <amxmisc> 


#define PLUGIN "Block MOTD" 
#define VERSION "1.0" 
#define AUTHOR "Sn!ff3r" 


new cvar, bool:saw[33] 


public plugin_init()  
{ 
    register_plugin(PLUGIN, VERSION, AUTHOR) 
     
    register_message(get_user_msgid("MOTD"), "message_MOTD") 
     
    cvar = register_cvar("amx_disable_motd", "1") 
} 


public client_connect(id) 
{ 
    saw[id] = false 
} 


public message_MOTD(const MsgId, const MsgDest, const MsgEntity) 
{ 
    if(!saw[MsgEntity] && get_pcvar_num(cvar)) 
    { 
        if(get_msg_arg_int(1) == 1) 
        { 
            saw[MsgEntity] = true 
            return PLUGIN_HANDLED 
        }         
    } 
    return PLUGIN_CONTINUE 
}