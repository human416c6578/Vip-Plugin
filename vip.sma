#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <engine>
#include <nvault>
#include <fun>

#define PLUGIN "Vip"	
#define VERSION "1.0"
#define AUTHOR "MrShark45"

#pragma tabsize 0

#define newModels 10

#define KNIFE_NUM 15

#define VIP_KNIFE_NUM 4

#define PREMIUM_KNIFE_NUM 4

#define USP_NUM 8

//List of the old models
new new_v_model[newModels][]={
	"models/llg/weapons/v_usp.mdl",
	"models/llg/weapons/v_deagle.mdl",
	"models/llg/weapons/v_hegrenade.mdl",
	"models/llg/weapons/v_flashbang.mdl",
	"models/llg/weapons/v_smokegrenade.mdl",
	"models/llg/weapons/v_mp5.mdl",
	"models/llg/weapons/v_m4a1.mdl",
	"models/llg/weapons/v_ak47.mdl",
	"models/llg/weapons/v_scout.mdl",
	"models/llg/weapons/v_awp.mdl"
};
//List of the new models to replace the old ones
new old_v_model[newModels][]={
	"models/v_usp.mdl",
	"models/v_deagle.mdl",
	"models/v_hegrenade.mdl",
	"models/v_flashbang.mdl",
	"models/v_smokegrenade.mdl",
	"models/v_mp5.mdl",
	"models/v_m4a1.mdl",
	"models/v_ak47.mdl",
	"models/v_scout.mdl",
	"models/v_awp.mdl"
};
//List of the new knife models
new knifeModels[KNIFE_NUM][128]={
	"models/llg/v_knife.mdl",
	"models/player/adminZP/adminZP3.mdl", //DEF GHOST
	"models/zombieplague/zp3.mdl", //BUT LION
	"models/player/santa_ct/santa_CtT2.mdl", //DEF RAINBOW
	"models/tree22.mdl", // BUT FADE
	"models/zombieplague/v_zclass_painter2.mdl", // BUT XIAO
	"models/zombieplague/rocket2.mdl", // BUT GOJOCAT
	"models/player/adminCT1/adminCt1.mdl", // DEF BLOOD
	"models/p_aug3.mdl", // BUT BLOOD
	"models/zombieplague/v_zclass_sniper3.mdl", // BUT Nezuko
	"models/player/vip1/vip1.mdl", // DEF TOXIC
	"models/zombieplague/v_zclass_sniper4.mdl", // BUT RIAS
	"models/p_m4a3.mdl", // BUT CARBON
	"models/zombieplague/v_zclass_rupture2.mdl", // BUT HyperBeast
	"models/vip/v_hide.mdl"
};
new knifeModelsNames[KNIFE_NUM][128]={
	"Default Knife",
	"Ghost",
	"Lion",
	"Rainbow",
	"Fade",
	"Xiao",
	"Gojo Cat",
	"Blood K5",
	"Blood K4",
	"Nezuko",
	"Toxic",
	"Rias",
	"Carbon",
	"HyperBeast",
	"Hide"
};
//List of the new usp models
new uspModels[USP_NUM][128]={
	"models/v_usp.mdl",
	"models/player/mario/marioT2.mdl", // BLUE
	"models/player/joker/jk2.mdl", // FADE
	"models/player/putin/putinT2.mdl", // BLOOD
	"models/player/ironman/ironmanT.mdl", // SAKURA
	"models/player/naruto/narutoT2.mdl", // CARBON
	"models/player/nazizombie/nazi.mdl", // XIAO
	"models/player/barry/barryT.mdl" // CORTEX
	
};

new uspModelsNames[USP_NUM][128]={
	"Default Usp",
	"Blue Crystal",
	"Fade",
	"Blood Moon",
	"Sakura",
	"Carbon",
	"Xiao",
	"Cyrex"
};

//List of the vip knife models
new vipKnifeModels[VIP_KNIFE_NUM][128]={
	"models/llg/v_vip_tigertooth.mdl",
	"models/llg/v_vip_purple.mdl",
	"models/llg/v_vip_crimson.mdl",
	"models/vip/v_hide.mdl"
};

new vipKnifeModelsNames[VIP_KNIFE_NUM][128]={
	"Tiger Tooth",
	"Purple Haze",
	"Crimson Web",
	"Hide"
};

//List of the vip knife models
new premiumKnifeModels[PREMIUM_KNIFE_NUM][128]={
	"models/llg/v_premium.mdl",
	"models/llg/v_premium_red.mdl",
	"models/llg/v_premium_purple.mdl",
	"models/vip/v_hide.mdl"
};

new premiumKnifeModelsNames[PREMIUM_KNIFE_NUM][128]={
	"Default",
	"Ruby",
	"Purple Vibe",
	"Hide"
};

new bool:skins[33];
new SyncHud;
new bool:showVips[33];

new vipKey[64][64];
new bool:isVip[33];

new specialKnife[33][4][128];
new specialUsp[33][128];

new g_szFilename[256];

new vipsOnlineText[256];

new knifeId;

new vault;

new lives[33];

#define SCOREATTRIB_NONE    0
#define SCOREATTRIB_DEAD    ( 1 << 0 )
#define SCOREATTRIB_VIP  ( 1 << 2 )

new Array:g_aFileContents;

new g_iToday;

new g_bExpired;

//Main
public plugin_init(){
	
	register_plugin(PLUGIN,VERSION,AUTHOR);

	register_clcmd("say /skinsoff","ToggleSkins");

	register_clcmd("say /vips","ToggleVipShow");

	register_clcmd( "say /vmenu","VipMenu" );

	register_clcmd("say /respawn", "Respawn");

	register_clcmd("amx_reloadvips", "LoadVips");

	register_event("CurWeapon","Changeweapon_Hook","be","1=1");
	RegisterHam(Ham_Spawn,"player","PlayerSpawn",1);

	register_event("HLTV", "NewRound", "a", "1=0", "2=0")  

	//set file name
	get_configsdir(g_szFilename,255);
	format(g_szFilename,255,"%s/vip.ini", g_szFilename);

	SyncHud=CreateHudSyncObj();

	new iEnt = create_entity("info_target");
	entity_set_string(iEnt, EV_SZ_classname, "vip_msg");
	entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 2.0);

	register_think("vip_msg","ForwardThink");

	register_event("ResetHUD", "resetModel", "b");

	vault = nvault_open( "skinsvip" );

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

//Precaching the skins from the list above
public plugin_precache(){
	g_aFileContents = ArrayCreate(128);

	for(new i=0;i<newModels;i++)
		precache_model(new_v_model[i]);
	for(new i=0;i<KNIFE_NUM;i++)
		precache_model(knifeModels[i]);
	for(new i=0;i<USP_NUM;i++)
		precache_model(uspModels[i]);
	for(new i=0;i<VIP_KNIFE_NUM;i++)
		precache_model(vipKnifeModels[i]);
	for(new i=0;i<PREMIUM_KNIFE_NUM;i++)
		precache_model(premiumKnifeModels[i]);

	//precache vip models
	precache_generic("models/player/admin_cte/admin_cte.mdl");
	precache_generic("models/player/admin_te/admin_te.mdl");
	precache_generic("models/player/vipHD/vipHD.mdl");

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
	skins[id]=true;
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
	Load(id);
}
//Event Disconnect Player
public client_disconnected(id){
	isVip[id] = false;
}
//Event Spawn Player
public PlayerSpawn(id){
	if(!(isPlayerVip(id))||!is_user_connected(id))
		return PLUGIN_CONTINUE;
	set_task(0.3,"GiveWeapons",id);

	return PLUGIN_CONTINUE;
}

//Event New Round
public NewRound(){
	for(new i = 0;i<33;i++){
		if(is_user_connected(i) && isPlayerVip(i))
			lives[i] = 2;
	}

}
//Event ResetHUD, to set the player model
public resetModel(id, level, cid){
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	if(is_user_admin(id)){
		if(cs_get_user_team(id) == CS_TEAM_T)
			cs_set_user_model(id, "admin_te");
		else if(cs_get_user_team(id) == CS_TEAM_CT)
			cs_set_user_model(id, "admin_cte");
	}
	if (isPlayerVip(id)){
		if(cs_get_user_team(id) == CS_TEAM_T)
			cs_set_user_model(id, "admin_te");
		if(cs_get_user_team(id) == CS_TEAM_CT)
			cs_set_user_model(id, "vipHD");
	}

	return PLUGIN_HANDLED;
}
//Checking the weapon the player switched to and if he's a vip it'll set a skin on that weapon if it's on the weapons list above
public Changeweapon_Hook(id){
	if(!is_user_alive(id)||!isPlayerVip(id)||!skins[id])
	{
		return PLUGIN_CONTINUE;
	}
	new model[42],i;

	pev(id,pev_viewmodel2,model, charsmax(model));
	for(i=0;i<newModels;i++){
		if(equali(model,old_v_model[i])){
			set_pev(id,pev_viewmodel2,new_v_model[i]);
		}
	}
	if(equali(model,"models/v_usp.mdl") && !equali(specialUsp[id],""))
		set_pev(id,pev_viewmodel2,specialUsp[id]);
	if(equali(model,"models/llg/v_knife.mdl") && !equali(specialKnife[id][0],""))
		set_pev(id,pev_viewmodel2,specialKnife[id][0]);
	if(equali(model,"models/llg/v_butcher.mdl") && !equali(specialKnife[id][1],""))
		set_pev(id,pev_viewmodel2,specialKnife[id][1]);
	if(equali(model,"models/llg/v_vip_tigertooth.mdl") && !equali(specialKnife[id][2],""))
		set_pev(id,pev_viewmodel2,specialKnife[id][2]);
	if(equali(model,"models/llg/v_premium.mdl") && !equali(specialKnife[id][3],""))
		set_pev(id,pev_viewmodel2,specialKnife[id][3]);

	return PLUGIN_HANDLED;
}
//Giving weapons to vips
public GiveWeapons(id){
	fm_give_item(id,"CSW_VESTHELM");
	fm_set_user_health(id,200);
	cs_set_user_armor(id, 100, CS_ARMOR_VESTHELM);
	if(!time_check())
		fm_give_item(id,"weapon_hegrenade");
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
	for(new i=0;i<33;i++){
		if(showVips[i] && is_user_alive(i))
			ShowSyncHudMsg(i, SyncHud, "%s", vipsOnlineText);
	}
	return PLUGIN_HANDLED
}
//Refresh the hud message
public ForwardThink(iEnt){
	vips_online();
	entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 2.0)
}

//Menu to choose the menu you want
public VipMenu(id){
	if(!isPlayerVip(id)){
		client_print(id,print_chat, "Acest meniu este doar pentru VIP!");
		return PLUGIN_CONTINUE;
	}
	new menu = menu_create( "\yChoose The Menu You Want!:", "menu_handler1" );

	menu_additem( menu, "\wKnife Skins", "", 0 );
	menu_additem( menu, "\wUsp Skins", "", 0 );

	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, menu, 0 );

	return PLUGIN_CONTINUE;
}
//menu handler for the vip menu /vmenu
public menu_handler1( id, menu, item ){
	switch( item )
	{
		case 0:
		{
			SkinMenu(id);
		}
		case 1:
		{
			UspMenu(id);
		}
	}
	menu_destroy( menu );
	return PLUGIN_HANDLED;
}

//Menu to choose a custom knife skin
public SkinMenu(id){
	if(!isPlayerVip(id)){
		client_print(id,print_chat, "Acest meniu este doar pentru VIP!");
		return PLUGIN_CONTINUE;
	}
	new menu = menu_create( "\yChoose Knife To Set Skin To!:", "menu_handler" );

	menu_additem( menu, "\wDefault Knife", "", 0 );
	menu_additem( menu, "\wGravity Knife", "", 0 );
	menu_additem( menu, "\wVip Knife", "", 0 );
	menu_additem( menu, "\wPremium Knife", "", 0 );

	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, menu, 0 );

	return PLUGIN_CONTINUE;
}
//Handler for the knife skin menu
public menu_handler( id, menu, item ){
	switch( item )
	{
		case 0:
		{
			SelectSkinMenu(id);
			knifeId = 0;
		}
		case 1:
		{
			SelectSkinMenu(id);
			knifeId = 1;
		}
		case 2:
		{
			VipKnifeSkinMenu(id);
		}
		case 3:
		{
			PremiumKnifeSkinMenu(id);
		}
	}
	menu_destroy( menu );
	return PLUGIN_HANDLED;
}
//Menu to choose a custom knife skin
public UspMenu(id){
	if(!isPlayerVip(id)){
		client_print(id,print_chat, "Acest meniu este doar pentru VIP!");
		return PLUGIN_CONTINUE;
	}
	new menu = menu_create( "\yChoose Knife To Set Skin To!:", "menu_handler4" );
	new txt[128];

	for(new i=0;i<USP_NUM;i++){
		format(txt,charsmax(txt),"\w%s", uspModelsNames[i]);
		menu_additem(menu, txt, "");
	}

	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, menu, 0 );

	return PLUGIN_CONTINUE;
}
//Handler for the knife skin menu
public menu_handler4( id, menu, item ){
	if ( item == MENU_EXIT ){
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}

	specialUsp[id] = uspModels[item];
	Save(id);

	menu_destroy( menu );
	return PLUGIN_HANDLED;
}
//Second Menu
public SelectSkinMenu(id){

	new menu = menu_create( "\yChoose Skin!:", "menu2_handler" );
	new txt[128];

	for(new i=0;i<KNIFE_NUM;i++){
		format(txt,charsmax(txt),"\w%s", knifeModelsNames[i]);
		menu_additem(menu, txt, "");
	}

	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, menu, 0 );
}
//Second Handler for the second menu
public menu2_handler( id, menu, item){
	if ( item == MENU_EXIT ){
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}

	if(knifeId == 1 && item == 0){
		specialKnife[id][knifeId] = "models/llg/v_butcher.mdl";
		Save(id);
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	specialKnife[id][knifeId] = knifeModels[item];
	Save(id);
	menu_destroy( menu );
	return PLUGIN_HANDLED;
}

public VipKnifeSkinMenu(id){

	new menu = menu_create( "\yChoose Skin!:", "vip_handler" );
	new txt[128];

	for(new i=0;i<VIP_KNIFE_NUM;i++){
		format(txt,charsmax(txt),"\w%s", vipKnifeModelsNames[i]);
		menu_additem(menu, txt, "");
	}

	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, menu, 0 );
}
//Second Handler for the second menu
public vip_handler( id, menu, item){
	if ( item == MENU_EXIT ){
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}

	specialKnife[id][2] = vipKnifeModels[item];
	Save(id);
	menu_destroy( menu );

	return PLUGIN_HANDLED;
}

//Second Menu
public PremiumKnifeSkinMenu(id){

	new menu = menu_create( "\yChoose Skin!:", "premium_handler" );
	new txt[128];

	for(new i=0;i<PREMIUM_KNIFE_NUM;i++){
		format(txt,charsmax(txt),"\w%s", premiumKnifeModelsNames[i]);
		menu_additem(menu, txt, "");
	}

	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, menu, 0 );
}
//Second Handler for the second menu
public premium_handler( id, menu, item){
	if ( item == MENU_EXIT ){
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}

	specialKnife[id][3] = premiumKnifeModels[item];
	Save(id);
	menu_destroy( menu );
	return PLUGIN_HANDLED;
}

public Respawn(id){
	if(!isPlayerVip(id)){
		client_print(id,print_chat, "Aceasta comanda este doar pentru VIP!");
		return PLUGIN_HANDLED;
	}
	if(is_user_alive(id)){
		client_print(id,print_chat, "Trebuie sa fii mort pentru a folosi aceasta comanda!");
		return PLUGIN_HANDLED;
	}
	if(checkCTAlive() < 2){
		client_print(id,print_chat, "Este doar un CT in viata, nu poti folosi aceasta comanda!");
		return PLUGIN_HANDLED;
	}
	if(cs_get_user_team(id) != CS_TEAM_CT){
		client_print(id,print_chat, "Trebuie sa fii CT pentru a folosi aceasta comanda!");
		return PLUGIN_HANDLED;
	}
	if(lives[id]>0){
		ExecuteHamB(Ham_CS_RoundRespawn, id);
		lives[id]--;
	}
	else{
		client_print(id,print_chat, "Nu ai destule vieti!");
	}
	
	return PLUGIN_HANDLED;
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


//Toggle some booleans
public ToggleSkins(id){
	skins[id]=!skins[id];
}

public ToggleVipShow(id){
	showVips[id]=!showVips[id];
}

public bool:isPlayerVip(id){
	if(time_check()) return true;

	return isVip[id];
}
//save the skins and sounds for the vips
public Save(id){
	new name[30];
	new key[30];


	get_user_name( id , name , charsmax( name ) );

	formatex(key, charsmax(key), "%s", name);
	nvault_set( vault , key , specialKnife[id][0]);
	formatex(key, charsmax(key), "%s+1", name);
	nvault_set( vault , key , specialKnife[id][1]);
	formatex(key, charsmax(key), "%s+2", name);
	nvault_set( vault , key , specialKnife[id][2]);
	formatex(key, charsmax(key), "%s+3", name);
	nvault_set( vault , key , specialUsp[id]);
	formatex(key, charsmax(key), "%s+4", name);
	nvault_set( vault , key , specialKnife[id][3]);
	
}
//loads the skins and sounds for the vips
public Load(id){
	if(!isPlayerVip(id))
		return PLUGIN_CONTINUE;

	new name[30];
	new key[30];

	get_user_name( id , name , charsmax( name ) );

	formatex(key, charsmax(key), "%s", name);
	nvault_get( vault , key , specialKnife[id][0], 127 );  
	formatex(key, charsmax(key), "%s+1", name);
	nvault_get( vault , key , specialKnife[id][1], 127 );
	formatex(key, charsmax(key), "%s+2", name);
	nvault_get( vault , key , specialKnife[id][2], 127 );
	formatex(key, charsmax(key), "%s+3", name);
	nvault_get( vault , key , specialUsp[id], 127 );
	formatex(key, charsmax(key), "%s+4", name);
	nvault_get( vault , key , specialKnife[id][3], 127 );

	return PLUGIN_CONTINUE;
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

public checkCTAlive(){
	new playersAlive;
	for(new i;i<=33;i++)
		if(is_user_alive(i) && cs_get_user_team(i) == CS_TEAM_CT)
			playersAlive++;
	return playersAlive;
}