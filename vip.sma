#include <amxmodx>
#include <amxmisc>
#include <engine>

#define PLUGIN "Vip"
#define VERSION "1.0"
#define AUTHOR "MrShark45"

#pragma tabsize 0

new SyncHud;
new bool:showVips[33];

new vipKey[256][64];
new bool:isVip[33];

new g_szFilename[256];

new vipsOnlineText[256];

#define SCOREATTRIB_NONE    0
#define SCOREATTRIB_DEAD    ( 1 << 0 )
#define SCOREATTRIB_VIP  ( 1 << 2 )

new Array:g_aFileContents;

new g_iToday;

new g_bExpired;

//Main
public plugin_init(){
	
	register_plugin(PLUGIN,VERSION,AUTHOR);

	register_clcmd("say /vips","ToggleVipShow");

	register_clcmd("amx_reloadvips", "LoadVips");

	//set file name
	get_configsdir(g_szFilename,255);
	format(g_szFilename,255,"%s/vip.ini", g_szFilename);

	SyncHud=CreateHudSyncObj();

	new iEnt = create_entity("info_target");
	entity_set_string(iEnt, EV_SZ_classname, "vip_msg");
	entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 2.0);

	register_think("vip_msg","ForwardThink");

	register_message( get_user_msgid( "ScoreAttrib" ), "MessageScoreAttrib" );
}

public plugin_cfg(){
	g_bExpired = false;

	//Calling the method to load the vips from file
	LoadVips();
}

public plugin_end(){
	ArrayDestroy(g_aFileContents)
}

public plugin_precache(){
	g_aFileContents = ArrayCreate(128);

}

public plugin_natives(){
	register_library("vip");

	register_native("isPlayerVip", "isPlayerVip_native")
}

public bool:isPlayerVip_native(numParams){
	new id = get_param(1);

	return isPlayerVip(id);
}

//Event Connect Player
public client_putinserver(id){
	showVips[id]=false;
	if(is_user_bot(id))
		return;

	new Name[32], Steamid[32];

	get_user_authid(id, Steamid, 31);
	get_user_name(id, Name, 31);

	for(new i = 0; i<sizeof(vipKey);i++){
		if(equal(Steamid,vipKey[i])){
			isVip[id] = true;
			break;
		}
		if(equal(Name,vipKey[i])){
			isVip[id] = true;
			break;
		}

	}
}
//Event Disconnect Player
public client_disconnected(id){
	isVip[id] = false;
}

//Show vip status in scoreboard
public MessageScoreAttrib( iMsgID, iDest, iReceiver ) {
    new iPlayer = get_msg_arg_int( 1 );
    if( is_user_connected(iPlayer) && isPlayerVip(iPlayer)) {
        set_msg_arg_int( 2, ARG_BYTE, is_user_alive( iPlayer ) ? SCOREATTRIB_VIP : SCOREATTRIB_DEAD );
    }
}

//Set the hud message
public SetVipsMessage(){
	new Name[32];
	formatex(vipsOnlineText,127,"Online VIPs : ");
	for(new i = 0 ;i<33;i++){
		if(isVip[i]){
			get_user_name(i, Name, 31);
			formatex(vipsOnlineText,127,"%s^n%s",vipsOnlineText,Name);
		}
	}
}
//Show the hud message
public vips_online(){
	SetVipsMessage();
	set_hudmessage(	0, 134, 139, 0.1, 0.1, _, _, 4.0, _, _, 4);
	for(new i;i<33;i++){
		if(showVips[i])
			ShowSyncHudMsg(i, SyncHud, "%s", vipsOnlineText);
	}
	return PLUGIN_HANDLED
}
//Refresh the hud message
public ForwardThink(iEnt){
	vips_online();
	entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 2.0)
}

//Load vips from the file
public LoadVips(){
	g_iToday = get_systime();
	new readdata[128], txtlen;
	new parsedkey[64], expirationDate[64];
	
	new line = 0
	new vipNum = 0;
	while(read_file(g_szFilename,line++,readdata,127,txtlen))
	{
		ArrayPushString(g_aFileContents, readdata);

		if (readdata[0] == ';' || readdata[0] == '/' || !readdata[0])
		{
			continue;
		}

		parse(readdata, parsedkey, 63, expirationDate, 63);
		if(is_date_expired(expirationDate, line-1))
			continue;

		vipKey[vipNum] = parsedkey;
		vipNum++;
	}

	if(g_bExpired)
		ReWriteFile();

	return PLUGIN_HANDLED;
}

public ReWriteFile(){
	new iFilePointer = fopen(g_szFilename, "w")
	new line[128];
	for(new i; i < ArraySize(g_aFileContents); i++)
	{
		ArrayGetString(g_aFileContents, i, line, sizeof(line));
		fprintf(iFilePointer, "%s^n", line)
	}

	fclose(iFilePointer)
}

bool:is_date_expired(const szDate[], const iLine)
{
	if(!szDate[0] || szDate[0] == ';')
	{
		return false
	}

	if(parse_time(szDate, "[%d.%m.%Y]") < g_iToday)
	{
		new szOldLine[128]
		new szNewLine[128];
		ArrayGetString(g_aFileContents, iLine, szOldLine, 127);
		formatex(szNewLine, charsmax(szNewLine), ";%s # EXPIRED", szOldLine);
		ArraySetString(g_aFileContents, iLine, szNewLine)

		g_bExpired = true;

		return true;
	}

	return false;
}




public bool:isPlayerVip(id){
	if(time_check()) return true;

	return isVip[id];
}


public bool:time_check(){
	new data[3];
	get_time("%H", data, 2);
	if(str_to_num(data)<20 && str_to_num(data)>10){
		return false;
	}
	else{
		return true;
	}
}

public ToggleVipShow(id){
    showVips[id] = !showVips[id];
}
