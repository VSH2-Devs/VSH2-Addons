#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <tf2_stocks>
#include <vsh2>


public Plugin myinfo = {
	name        = "VSH2 Infinite Ammo Uber addon",
	author      = "Nergal/Assyrian",
	description = "",
	version     = "1.3",
	url         = "https://github.com/VSH2-Devs/VSH2-Addons"
};


public void OnLibraryAdded(const char[] name) {
	if( StrEqual(name, "VSH2") ) {
		LoadVSH2Hooks();
	}
}

public void LoadVSH2Hooks() {
	if( !VSH2_HookEx(OnUberLoop, OnInfAmmoUberLoop) )
		LogError("Error loading OnUberLoop forwards for Infinite Ammo Uber Addon.");
}

public void OnInfAmmoUberLoop(const VSH2Player medic, const VSH2Player ubertarget)
{
	if( !ubertarget ) {
		return;
	}
	
	for( int i; i<2; i++ ) {
		int ent_wep = GetPlayerWeaponSlot(ubertarget.index, i);
		if( ent_wep <= 0 || !IsValidEntity(ent_wep) ) {
			continue;
		}
		
		int wepindex = ubertarget.GetWeaponSlotIndex(i);
		if( wepindex <= 0 ) {
			continue;
		}
		
		int maxAmmo = ubertarget.GetAmmoTable(i);
		if( maxAmmo > 0 ) {
			SetWeaponAmmo(ent_wep, maxAmmo);
		}
		
		/// Exclude certain weapons in terms of clipsize...
		if( wepindex==730 || wepindex==1079 || wepindex==305 || wepindex==45 ) {
			continue;
		}
		
		int maxClip = ubertarget.GetClipTable(i);
		if( maxClip > 0 ) {
			SetWeaponClip(ent_wep, maxClip);
		}
	}
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