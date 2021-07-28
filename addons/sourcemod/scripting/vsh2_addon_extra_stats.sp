#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <tf2_stocks>
#include <vsh2>


public Plugin myinfo = {
	name        = "VSH2 Extra Round End Stats addon",
	author      = "Nergal/Assyrian",
	description = "",
	version     = "1.0",
	url         = "https://github.com/VSH2-Devs/VSH2-Addons"
};


public void OnLibraryAdded(const char[] name) {
	if( StrEqual(name, "VSH2") ) {
		LoadVSH2Hooks();
	}
}

public void LoadVSH2Hooks() {
	if( !VSH2_HookEx(OnShowStats, OnExtraStats) )
		LogError("Error loading OnShowStats forwards for Extra End Stats Addon.");
	
	if( !VSH2_HookEx(OnBossTakeDamage_OnStabbed, OnExtraStatsBackStab) )
		LogError("Error loading OnBossTakeDamage_OnStabbed forwards for Extra End Stats Addon.");
		
	if( !VSH2_HookEx(OnBossTakeDamage_OnSniped, OnExtraStatsSniped) )
		LogError("Error loading OnBossTakeDamage_OnSniped forwards for Extra End Stats Addon.");
		
	if( !VSH2_HookEx(OnUberDeployed, OnExtraStatsDoUber) )
		LogError("Error loading OnUberDeployed forwards for Extra End Stats Addon.");
		
	if( !VSH2_HookEx(OnVariablesReset, OnExtraStatsReset) )
		LogError("Error loading OnVariablesReset forwards for Extra End Stats Addon.");
		
	if( !VSH2_HookEx(OnBossMedicCall, OnExtraStatsRage) )
		LogError("Error loading OnBossMedicCall forwards for Extra End Stats Addon.");
}


/**
 * Boss HP (Remaining / Total)
 * Top Total boss Rages and Special abilities activation count
 * Top Total Headshots
 * Top Total Backstabs
 * Top Total Ubercharges
 * Who made a final blow (if boss was killed by someone)
 */

public void OnExtraStatsReset(const VSH2Player player) {
	player.SetPropInt("iHeadShots", 0);
	player.SetPropInt("iBackstabs", 0);
	player.SetPropInt("iUbers",     0);
	player.SetPropInt("iRages",     0);
}

public void OnExtraStatsRage(const VSH2Player player) {
	player.SetPropInt("iRages", player.GetPropInt("iRages") + 1);
}

public Action OnExtraStats(const VSH2Player top[3])
{
	VSH2Player top_players[5], top_headshots, top_stabs, top_ubers, top_rager;
	VSH2Player(0).SetPropInt("iDamage", 0);
	for( int i=MaxClients; i; --i ) {
		if( !IsValidClient(i) || GetClientTeam(i) <= VSH2Team_Spectator ) {
			continue;
		}
		
		VSH2Player player = VSH2Player(i);
		if( player.bIsBoss ) {
			if( player.GetPropInt("iRages") >= top_rager.GetPropInt("iRages") ) {
				top_rager = player;
			}
			continue;
		} else if( player.GetPropInt("iDamage")==0 ) {
			continue;
		}
		
		if( player.GetPropInt("iDamage") >= top_players[0].GetPropInt("iDamage") ) {
			top_players[4] = top_players[3];
			top_players[3] = top_players[2];
			top_players[2] = top_players[1];
			top_players[1] = top_players[0];
			top_players[0] = player;
		} else if( player.GetPropInt("iDamage") >= top_players[1].GetPropInt("iDamage") ) {
			top_players[4] = top_players[3];
			top_players[3] = top_players[2];
			top_players[2] = top_players[1];
			top_players[1] = player;
		} else if( player.GetPropInt("iDamage") >= top_players[2].GetPropInt("iDamage") ) {
			top_players[4] = top_players[3];
			top_players[3] = top_players[2];
			top_players[2] = player;
		} else if( player.GetPropInt("iDamage") >= top_players[3].GetPropInt("iDamage") ) {
			top_players[4] = top_players[3];
			top_players[3] = player;
		} else if( player.GetPropInt("iDamage") >= top_players[4].GetPropInt("iDamage") ) {
			top_players[4] = player;
		}
		
		if( player.GetPropInt("iHeadShots") > top_headshots.GetPropInt("iHeadShots") ) {
			top_headshots = player;
		}
		if( player.GetPropInt("iBackstabs") > top_stabs.GetPropInt("iBackstabs") ) {
			top_stabs = player;
		}
		if( player.GetPropInt("iUbers") > top_ubers.GetPropInt("iUbers") ) {
			top_ubers = player;
		}
	}
	
	char names[5][64], headshotter[64], backstabber[64], uberer[64], rager[64];
	int damages[5], irages;
	for( int i; i<5; i++ ) {
		if( top_players[i].index && top_players[i].GetPropInt("iDamage") > 0 ) {
			GetClientName(top_players[i].index, names[i], sizeof(names[]));
			damages[i] = top_players[i].GetPropInt("iDamage");
		} else {
			names[i] = "nil";
		}
	}
	if( top_headshots.index ) {
		GetClientName(top_headshots.index, headshotter, sizeof(headshotter));
	} else {
		headshotter = "nil";
	}
	if( top_stabs.index ) {
		GetClientName(top_stabs.index, backstabber, sizeof(backstabber));
	} else {
		backstabber = "nil";
	}
	if( top_ubers.index ) {
		GetClientName(top_ubers.index, uberer, sizeof(uberer));
	} else {
		uberer = "nil";
	}
	if( top_rager.index ) {
		GetClientName(top_rager.index, rager, sizeof(rager));
		irages = top_rager.GetPropInt("iRages");
	} else {
		rager = "nil";
	}
	
	SetHudTextParams(-1.0, 0.30, 10.0, 255, 255, 255, 255);
	char damage_list[512];
	Format(damage_list, sizeof(damage_list), "Top Rages: %i - %s\nTop Damage :\n1)%i - %s\n2)%i - %s\n3)%i - %s\n4)%i - %s\n5)%i - %s", irages, rager, damages[0], names[0], damages[1], names[1], damages[2], names[2], damages[3], names[3], damages[4], names[4]);
	
	char topper_list[512];
	Format(topper_list, sizeof(topper_list), "Top Headshots %i - %s\nTop Backstabs %i - %s\nTop Ubers %i - %s", top_headshots.GetPropInt("iHeadShots"), headshotter, top_stabs.GetPropInt("iBackstabs"), backstabber, top_ubers.GetPropInt("iUbers"), uberer);
	
	for( int i=MaxClients; i; --i ) {
		if( !IsValidClient(i) || (GetClientButtons(i) & IN_SCORE) ) {
			continue;
		}
		ShowHudText(i, -1, "%s", damage_list);
	}
	
	SetHudTextParams(-1.0, 0.40, 10.0, 255, 255, 255, 255);
	for( int i=MaxClients; i; --i ) {
		if( !IsValidClient(i) || (GetClientButtons(i) & IN_SCORE) ) {
			continue;
		}
		VSH2Player player = VSH2Player(i);
		ShowHudText(i, -1, "%s\n\nDamage Dealt: %i", topper_list, player.GetPropInt("iDamage"));
	}
	return Plugin_Handled;
}

public Action OnExtraStatsBackStab(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VSH2Player stabber = VSH2Player(attacker);
	stabber.SetPropInt("iBackstabs", stabber.GetPropInt("iBackstabs") + 1);
	return Plugin_Continue;
}

public Action OnExtraStatsSniped(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VSH2Player sniper = VSH2Player(attacker);
	if( damagecustom==TF_CUSTOM_HEADSHOT ) {
		sniper.SetPropInt("iHeadShots", sniper.GetPropInt("iHeadShots") + 1);
	}
	return Plugin_Continue;
}

public void OnExtraStatsDoUber(const VSH2Player medic, const VSH2Player target) {
	medic.SetPropInt("iUbers", medic.GetPropInt("iUbers") + 1);
}



stock bool IsValidClient(const int client, bool nobots=false)
{ 
	if( client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)) )
		return false;
	return IsClientInGame(client); 
}
stock int SetWeaponAmmo(const int weapon, const int ammo)
{
	int owner = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");
	if( owner <= 0 ) {
		return 0;
	}
	if( IsValidEntity(weapon) ) {
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		SetEntData(owner, iAmmoTable+iOffset, ammo, 4, true);
	}
	return 0;
}
stock int GetWeaponAmmo(int weapon)
{
	int owner = GetOwner(weapon);
	if( owner <= 0 ) {
		return 0;
	}
	if( IsValidEntity(weapon) ) {
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		return GetEntData(owner, iAmmoTable+iOffset, 4);
	}
	return 0;
}
stock int GetWeaponClip(const int weapon)
{
	if( IsValidEntity(weapon) ) {
		int AmmoClipTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		return GetEntData(weapon, AmmoClipTable);
	}
	return 0;
}
stock int SetWeaponClip(const int weapon, const int ammo)
{
	if( IsValidEntity(weapon) ) {
		int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		SetEntData(weapon, iAmmoTable, ammo, 4, true);
	}
	return 0;
}
stock int GetOwner(const int ent)
{
	if( IsValidEdict(ent) && IsValidEntity(ent) ) {
		return GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	}
	return -1;
}
stock int GetSlotFromWeapon(const int iClient, const int iWeapon)
{
	for( int i=0; i<5; i++ ) {
		if( iWeapon == GetPlayerWeaponSlot(iClient, i) ) {
			return i;
		}
	}
	return -1;
}

stock void SetAmmo(const int client, const int slot, const int ammo)
{
	int weapon = GetPlayerWeaponSlot(client, slot);
	if( IsValidEntity(weapon) ) {
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		SetEntData(client, iAmmoTable+iOffset, ammo, 4, true);
	}
}