#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2_stocks>
#include <vsh2>


char saxton_songs_str[][] = {
	"saxton_hale/hale_theme1.mp3", /// JMA Saxton Hale Mix
	"saxton_hale/hale_theme2.mp3" /// Men at Work - Land Down Under
};
float saxton_songs_time[] = { 171.0, 221.0 };

char vagineer_songs_str[][] = {
	"saxton_hale/erectin_a_river.mp3",
	"saxton_hale/devil_went_down_to_georgia.mp3",
	"saxton_hale/big_iron.mp3"
};
float vagineer_songs_time[] = { 227.0, 213.0, 236.0 };

char cbs_songs_str[][] = {
	"saxton_hale/numbah_one_snoipah.mp3", /// Mastgrr - Sniper remix Number One TF2
	"saxton_hale/spy_vs_spy.mp3" /// Combustible Edison - Spy vs. Spy
};
float cbs_songs_time[] = { 227.0, 140.0 };

char hhh_songs_str[][] = {
	"saxton_hale/glover_frankenstein_boss.mp3"
};
float hhh_songs_time[] = { 211.0 };

char bunny_songs_str[][] = {
	"saxton_hale/electric_avenue.mp3",
	"saxton_hale/go_daddy_o.mp3"
};
float bunny_songs_time[] = { 221.0, 192.0 };


public Plugin myinfo = {
	name = "VSH2 Extra Boss Themes Addon",
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
	if( !VSH2_HookEx(OnCallDownloads, ExtraBossThemesDownloads) )
		LogError("Error loading OnCallDownloads forwards for Extra Boss Themes Addon.");
	
	if( !VSH2_HookEx(OnMusic, OnExtraMusic) )
		LogError("Error Hooking OnMusic forward for Extra Boss Themes Addon.");
}

public void ExtraBossThemesDownloads()
{
	DownloadSoundList(saxton_songs_str, sizeof(saxton_songs_str));
	DownloadSoundList(vagineer_songs_str, sizeof(vagineer_songs_str));
	DownloadSoundList(cbs_songs_str, sizeof(cbs_songs_str));
	DownloadSoundList(hhh_songs_str, sizeof(hhh_songs_str));
	DownloadSoundList(bunny_songs_str, sizeof(bunny_songs_str));
}

public void OnExtraMusic(char song[PLATFORM_MAX_PATH], float& time, const VSH2Player player)
{
	int bossid = player.GetPropInt("iBossType");
	switch( bossid ) {
		case VSH2Boss_Hale: {
			int index = GetRandomInt(0, sizeof(saxton_songs_str)-1);
			strcopy(song, sizeof(song), saxton_songs_str[index]);
			time = saxton_songs_time[index];
		}
		case VSH2Boss_Vagineer: {
			int index = GetRandomInt(0, sizeof(vagineer_songs_str)-1);
			strcopy(song, sizeof(song), vagineer_songs_str[index]);
			time = vagineer_songs_time[index];
		}
		case VSH2Boss_CBS: {
			if( GetRandomInt(0, 1) )
				return;
			
			int index = GetRandomInt(0, sizeof(cbs_songs_str)-1);
			strcopy(song, sizeof(song), cbs_songs_str[index]);
			time = cbs_songs_time[index];
		}
		case VSH2Boss_HHHjr: {
			if( GetRandomInt(0, 1) )
				return;
			
			int index = GetRandomInt(0, sizeof(hhh_songs_str)-1);
			strcopy(song, sizeof(song), hhh_songs_str[index]);
			time = hhh_songs_time[index];
		}
		case VSH2Boss_Bunny: {
			int index = GetRandomInt(0, sizeof(bunny_songs_str)-1);
			strcopy(song, sizeof(song), bunny_songs_str[index]);
			time = bunny_songs_time[index];
		}
	}
}
