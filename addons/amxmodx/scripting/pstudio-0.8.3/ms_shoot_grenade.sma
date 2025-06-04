
#include <amxmodx>

#include <fakemeta>
#include <engine>
#include <hamsandwich>

#include <cstrike>


new const Plugin[] = "Shoot Grenades"
new const Author[] = "joaquimandrade"
new const Version[] = "1.0"

enum _:Grenade
{
	Flashbang,
	He,
	Smoke,
	C4
}

new Cvars[Grenade]

new CvarsNames[Grenade][] =
{
	"flash",
	"he",
	"smoke",
	"c4"
}

// Arkshine
const m_flC4Blow = 100

new MaxPlayers

public plugin_init()
{
	register_plugin(Plugin,Version,Author)
	RegisterHam(Ham_TraceAttack,"worldspawn","globalTraceAttack")
	
	register_cvar("shootGrenades_version",Version,FCVAR_SERVER|FCVAR_SPONLY)
}

public plugin_cfg()
{
	new cvarName[15]
	
	for(new i=0;i<Grenade;i++)
	{
		formatex(cvarName,charsmax(cvarName),"shoot_%s",CvarsNames[i])
		Cvars[i] = register_cvar(cvarName,"1")
	}		
	
	MaxPlayers = get_maxplayers()	
}

public globalTraceAttack(this,attackerID,Float:damage,Float:direction[3],tracehandle,damagebits)
{
	if(1 <= attackerID <= MaxPlayers)
	{
		static Float:origin[3]
		pev(attackerID,pev_origin,origin)
		
		static Float:end[3]
		get_tr2(tracehandle,TR_vecEndPos,end)
		
		new trace = create_tr2()
		
		new grenade = -1
		
		while((grenade = find_ent_by_class(grenade,"grenade")))
		{
			engfunc(EngFunc_TraceModel,origin,end,HULL_POINT,grenade,trace)
			
			if(get_tr2(trace,TR_pHit) == grenade)
			{
				new id = fm_cs_get_grenade_type_myid(grenade)
				
				if(id == C4)
				{
					new cvarValue = get_pcvar_num(Cvars[C4])
						
					if((cvarValue == 2) || (cvarValue && (cs_get_user_team(attackerID) == CS_TEAM_CT)))
					{
						set_pdata_float(grenade,m_flC4Blow,0.0)
					}
				}
				else
				{
					if(get_pcvar_num(Cvars[id]))
					{
						if(id == Smoke)
							set_pev(grenade,pev_flags,pev(grenade,pev_flags) | FL_ONGROUND)
						
						// Connor
						set_pev(grenade,pev_dmgtime,0.0)
						dllfunc(DLLFunc_Think,grenade)
					}
				}
			}
		}
		
		free_tr2(trace)
	}
}

// VEN
fm_cs_get_grenade_type_myid(index) 
{
	if(get_pdata_int(index, 96) & (1<<8))
	{
		return 3
	}	
	
	return get_pdata_int(index, 114) & 3
}