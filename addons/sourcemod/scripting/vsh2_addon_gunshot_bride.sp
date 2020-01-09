#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2_stocks>
#include <vsh2>


bool g_bPlayAirShotSong;

public Plugin myinfo = {
	name = "VSH2 Airshot Gunshot Bride addon",
	author = "Nergal/Assyrian",
	description = "",
	version = "1.0",
	url = "sus"
};


public void OnLibraryAdded(const char[] name) {
	if( StrEqual(name, "VSH2") ) {
		LoadVSH2Hooks();
	}
}

public void LoadVSH2Hooks()
{
	if( !VSH2_HookEx(OnVariablesReset, AirshotRoundReset) )
		LogError("Error Hooking OnVariablesReset forward for Airshot Gunshot Bride addon.");
		
	if( !VSH2_HookEx(OnBossAirShotProj, AirshotOnBossAirShotProj) )
		LogError("Error Hooking OnBossAirShotProj forward for Airshot Gunshot Bride addon.");
}

public void AirshotDownloads()
{
	PrepareSound("airshot.wav");
}

public void AirshotRoundReset(const VSH2Player player)
{
	g_bPlayAirShotSong = true;
}

public Action AirshotOnBossAirShotProj(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if( victim.index==attacker )
		return Plugin_Continue;
	
	char inflictor_name[32];
	if( IsValidEntity(inflictor) )
		GetEntityClassname(inflictor, inflictor_name, sizeof(inflictor_name));
	
	//char wepname[64];
	//if( IsValidEntity(weapon) )
	//	GetEdictClassname(weapon, wepname, sizeof(wepname));
	
	if( StrEqual(inflictor_name, "tf_projectile_rocket") || StrEqual(inflictor_name, "tf_projectile_pipe") ) {
		VSH2Player pro = VSH2Player(attacker);
		if( g_bPlayAirShotSong ) {
			EmitSoundToAll("airshot.wav");
			g_bPlayAirShotSong = false;
			CreateTimer(80.0, TimerResetAirshot, _, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	return Plugin_Continue;
}

public Action TimerResetAirshot(Handle timer)
{
	g_bPlayAirShotSong = true;
	return Plugin_Continue;
}

stock void SetPawnTimer(Function func, float thinktime = 0.1, any param1 = -999, any param2 = -999)
{
	DataPack thinkpack = new DataPack();
	thinkpack.WriteFunction(func);
	thinkpack.WriteCell(param1);
	thinkpack.WriteCell(param2);
	CreateTimer(thinktime, DoThink, thinkpack, TIMER_DATA_HNDL_CLOSE);
}
public Action DoThink(Handle hTimer, DataPack hndl)
{
	hndl.Reset();
	
	Function pFunc = hndl.ReadFunction();
	Call_StartFunction( null, pFunc );
	
	any param1 = hndl.ReadCell();
	if( param1 != -999 )
		Call_PushCell(param1);
	
	any param2 = hndl.ReadCell();
	if( param2 != -999 )
		Call_PushCell(param2);
	
	Call_Finish();
	return Plugin_Continue;
}
