#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2_stocks>
#include <vsh2>
#include <morecolors>


enum /** difficulty flags */ {
	DIFF_FLAG_25PC_LESS_HP    = 1,
	DIFF_FLAG_HALF_HP         = 2,
	DIFF_FLAG_NO_RAGE         = 4,
	DIFF_FLAG_DEGEN_HEALTH    = 8,
	DIFF_FLAG_NO_WGHDWN       = 16,
};


public Plugin myinfo = {
	name = "VSH2 Difficulty Settings addon",
	author = "Nergal/Assyrian",
	description = "",
	version = "1.0",
	url = "sus"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_vsh2_difficulty", SetDifficulty);
	RegConsoleCmd("sm_ff2_difficulty", SetDifficulty);
	RegConsoleCmd("sm_boss_difficulty", SetDifficulty);
	RegConsoleCmd("sm_setdifficulty", SetDifficulty);
	RegConsoleCmd("sm_difficulty", SetDifficulty);
}


public void OnLibraryAdded(const char[] name) {
	if( StrEqual(name, "VSH2") ) {
		LoadVSH2Hooks();
	}
}

public void LoadVSH2Hooks()
{
	//if( !VSH2_HookEx(OnBossCalcHealth, DiffOnModHealth) )
	//	LogError("Error Hooking OnBossCalcHealth forward for VSH2 Difficulty Settings addon.");
	
	if( !VSH2_HookEx(OnRoundStart, DiffOnRoundStart) )
		LogError("Error Hooking OnRoundStart forward for VSH2 Difficulty Settings addon.");
		
	if( !VSH2_HookEx(OnBossThinkPost, DiffOnBossThinkPost) )
		LogError("Error Hooking OnBossThinkPost forward for VSH2 Difficulty Settings addon.");
		
	if( !VSH2_HookEx(OnHelpMenu, DiffOnHelpMenu) )
		LogError("Error Hooking OnHelpMenu forward for VSH2 Difficulty Settings addon.");
	if( !VSH2_HookEx(OnHelpMenuSelect, DiffOnHelpMenuSelect) )
		LogError("Error Hooking OnHelpMenuSelect forward for VSH2 Difficulty Settings addon.");
}

public Action SetDifficulty(int client, int args)
{
	if( client <= 0 ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} You can only use this command ingame.");
		return Plugin_Handled;
	}
	
	VSH2Player player = VSH2Player(client);
	Menu difficulty = new Menu(MenuHandler_DoDifficulties);
	difficulty.SetTitle("Choose your VSH2 Boss Difficulty Settings:");
	int curr_difficulty = player.GetPropInt("iDifficulty");
	char
		tostr[10],
		settingstr[100]
	;
	
	IntToString(DIFF_FLAG_25PC_LESS_HP, tostr, sizeof(tostr));
	Format(settingstr, sizeof(settingstr), "25% Less Boss Health %s", curr_difficulty & DIFF_FLAG_25PC_LESS_HP ? "(Enabled)" : "(Disabled)");
	difficulty.AddItem(tostr, settingstr);
	
	IntToString(DIFF_FLAG_HALF_HP, tostr, sizeof(tostr));
	Format(settingstr, sizeof(settingstr), "Halved Boss Health %s", curr_difficulty & DIFF_FLAG_HALF_HP ? "(Enabled)" : "(Disabled)");
	difficulty.AddItem(tostr, settingstr);
	
	IntToString(DIFF_FLAG_NO_RAGE, tostr, sizeof(tostr));
	Format(settingstr, sizeof(settingstr), "No Rage Generation %s", curr_difficulty & DIFF_FLAG_NO_RAGE ? "(Enabled)" : "(Disabled)");
	difficulty.AddItem(tostr, settingstr);
	
	IntToString(DIFF_FLAG_DEGEN_HEALTH, tostr, sizeof(tostr));
	Format(settingstr, sizeof(settingstr), "Health Degeneration %s", curr_difficulty & DIFF_FLAG_DEGEN_HEALTH ? "(Enabled)" : "(Disabled)");
	difficulty.AddItem(tostr, settingstr);
	
	IntToString(DIFF_FLAG_NO_WGHDWN, tostr, sizeof(tostr));
	Format(settingstr, sizeof(settingstr), "No Weighdown %s", curr_difficulty & DIFF_FLAG_NO_WGHDWN ? "(Enabled)" : "(Disabled)");
	difficulty.AddItem(tostr, settingstr);
	
	difficulty.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public int MenuHandler_DoDifficulties(Menu menu, MenuAction action, int client, int pick)
{
	char info[32]; menu.GetItem(pick, info, sizeof(info));
	if( action == MenuAction_Select ) {
		int difficulty_flag = StringToInt(info);
		VSH2Player player = VSH2Player(client);
		int curr_difficulty = player.GetPropInt("iDifficulty");
		player.SetPropInt("iDifficulty", curr_difficulty ^ difficulty_flag);
		SetDifficulty(client, -1);
	} else if( action == MenuAction_End )
		delete menu;
}

public void DiffOnModHealth(const VSH2Player player, int& max_health, const int boss_count, const int red_players)
{
	int diff_flags = player.GetPropInt("iDifficulty");
	switch( diff_flags & (DIFF_FLAG_25PC_LESS_HP|DIFF_FLAG_HALF_HP) ) {
		case DIFF_FLAG_25PC_LESS_HP|DIFF_FLAG_HALF_HP:
			max_health = RoundFloat( max_health * 0.25 );
		case DIFF_FLAG_25PC_LESS_HP:
			max_health = RoundFloat( max_health * 0.75 );
		case DIFF_FLAG_HALF_HP:
			max_health = RoundFloat( max_health * 0.5 );
	}
}

public void DiffOnRoundStart(const VSH2Player[] bosses, const int boss_count, const VSH2Player[] red_players, const int red_count)
{
	for( int i; i<boss_count; i++ ) {
		int diff_flags = bosses[i].GetPropInt("iDifficulty");
		switch( diff_flags & (DIFF_FLAG_25PC_LESS_HP|DIFF_FLAG_HALF_HP) ) {
			case DIFF_FLAG_25PC_LESS_HP|DIFF_FLAG_HALF_HP:
				bosses[i].SetPropInt("iMaxHealth", RoundFloat(bosses[i].GetPropInt("iMaxHealth") * 0.25));
			case DIFF_FLAG_25PC_LESS_HP:
				bosses[i].SetPropInt("iMaxHealth", RoundFloat(bosses[i].GetPropInt("iMaxHealth") * 0.75));
			case DIFF_FLAG_HALF_HP:
				bosses[i].SetPropInt("iMaxHealth", bosses[i].GetPropInt("iMaxHealth") / 2);
		}
	}
}

public void DiffOnBossThinkPost(VSH2Player player)
{
	int client = player.index;
	if( !IsPlayerAlive(client) )
		return;
	
	int diff_flags = player.GetPropInt("iDifficulty");
	if( diff_flags & DIFF_FLAG_NO_RAGE )
		player.SetPropFloat("flRAGE", 0.0);
	
	if( diff_flags & DIFF_FLAG_DEGEN_HEALTH ) {
		if( player.iHealth > 300 )
			player.iHealth -= 1;
	}
	
	if( diff_flags & DIFF_FLAG_NO_WGHDWN )
		player.SetPropFloat("flWeighDown", 0.0);
}

public void DiffOnHelpMenu(const VSH2Player player, Menu menu)
{
	menu.AddItem("vsh2_difficulty", "Set Boss Difficulty Settings (/vsh2_difficulty)");
}

public void DiffOnHelpMenuSelect(const VSH2Player player, Menu menu, int selection)
{
	char info1[64]; menu.GetItem(selection, info1, sizeof(info1));
	if( StrEqual(info1, "vsh2_difficulty") ) {
		SetDifficulty(player.index, -1);
	}
}
