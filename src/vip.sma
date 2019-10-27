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

#define newModels 8
//List of the old models
new new_v_model[newModels][]={
	"models/vip/v_deagle2.mdl",
	"models/vip/v_hegrenade.mdl",
	"models/vip/v_flashbang.mdl",
	"models/vip/v_smokegrenade.mdl",
	"models/vip/v_m4a12.mdl",
	"models/vip/v_ak472.mdl",
	"models/vip/v_scout.mdl",
	"models/vip/v_awp2.mdl"
};
//List of the new models to replace the old ones
new old_v_model[newModels][]={
	"models/v_deagle.mdl",
	"models/v_hegrenade.mdl",
	"models/v_flashbang.mdl",
	"models/v_smokegrenade.mdl",
	"models/v_m4a1.mdl",
	"models/v_ak47.mdl",
	"models/v_scout.mdl",
	"models/v_awp.mdl"
};
//List of the new knife models
new knifeModels[10][128]={
	"models/v_knife.mdl",
	"models/vip/v_knife.mdl",
	"models/vip/v_knife2.mdl",
	"models/vip/v_butcher.mdl",
	"models/vip/v_butcher4.mdl",
	"models/vip/redbutt.mdl",
	"models/vip/v_butcher5.mdl",
	"models/vip/v_shark.mdl",
	"models/vip/v_butcher6.mdl",
	"models/vip/v_hide.mdl"
	
};
//List of the new usp models
new uspModels[6][128]={
	"models/v_usp.mdl",
	"models/vip/v_usp.mdl",
	"models/vip/v_usp1.mdl",
	"models/vip/v_usp2.mdl",
	"models/vip/v_usp31.mdl",
	"models/vip/v_usp4.mdl"
	
};

new bool:skins[33];
new SyncHud;
new bool:showVips[33];

new vipKey[512][64];
new bool:isVip[33];

new specialKnife[33][2][128];
new specialUsp[33][128];

new fileName[256];

new vipsOnlineText[256];

new knifeId;

new vault;

new lives[33];

#define SCOREATTRIB_NONE    0
#define SCOREATTRIB_DEAD    ( 1 << 0 )
#define SCOREATTRIB_VIP  ( 1 << 2 )

//Main
public plugin_init(){
	
	register_plugin(PLUGIN,VERSION,AUTHOR);

	register_clcmd("say /skinsoff","ToggleSkins");

	register_clcmd("say /vips","ToggleVipShow");

	register_clcmd("say /vip", "ShowMotd");

	register_clcmd( "say /vmenu","VipMenu" );

	register_clcmd("say /respawn", "Respawn");

	register_clcmd("amx_reload_vips", "LoadVips");

	register_event("CurWeapon","Changeweapon_Hook","be","1=1");
	RegisterHam(Ham_Spawn,"player","PlayerSpawn",1);

	register_event("HLTV", "NewRound", "a", "1=0", "2=0")  

	//set file name
	get_configsdir(fileName,255);
	format(fileName,255,"%s/vip.ini",fileName);

	//Calling the method to load the vips from file
	LoadVips();

	SyncHud=CreateHudSyncObj();

	new iEnt = create_entity("info_target");
	entity_set_string(iEnt, EV_SZ_classname, "vip_msg");
	entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 2.0);

	register_think("vip_msg","ForwardThink");

	register_event("ResetHUD", "resetModel", "b");

	vault = nvault_open( "SpecialKnife13" );

	register_message( get_user_msgid( "ScoreAttrib" ), "MessageScoreAttrib" );
}
//Precaching the skins from the list above
public plugin_precache(){
	for(new i=0;i<newModels;i++)
		precache_model(new_v_model[i]);
	for(new i=0;i<10;i++)
		precache_model(knifeModels[i]);
	for(new i=0;i<6;i++)
		precache_model(uspModels[i]);

	//precache vip models
	precache_model("models/player/admin_ct/admin_ct.mdl");
	precache_model("models/player/admin_te/admin_te.mdl");
	precache_model("models/player/vip1/vip1.mdl");

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
	if (isPlayerVip(id)){
		cs_set_user_model(id, "vip1");
	}
	else{
		if(is_user_admin(id)){
			if(cs_get_user_team(id) == CS_TEAM_T)
				cs_set_user_model(id, "admin_t");
			else if(cs_get_user_team(id) == CS_TEAM_CT)
				cs_set_user_model(id, "admin_ct");
		}
	}
	

	return PLUGIN_CONTINUE;
}
//Checking the weapon the player switched to and if he's a vip it'll set a skin on that weapon if it's on the weapons list above
public Changeweapon_Hook(id){
	if(!is_user_alive(id)||!(isPlayerVip(id))||!skins[id])
	{
		return PLUGIN_CONTINUE;
	}
	new model[32],i;

	pev(id,pev_viewmodel2,model,31);
	for(i=0;i<newModels;i++){
		if(equali(model,old_v_model[i])){
			set_pev(id,pev_viewmodel2,new_v_model[i]);
		}
	}
	if(equali(model,"models/v_usp.mdl") && !equali(specialUsp[id],""))
		set_pev(id,pev_viewmodel2,specialUsp[id]);
	if(equali(model,"models/v_knife.mdl") && !equali(specialKnife[id][0],""))
		set_pev(id,pev_viewmodel2,specialKnife[id][0]);
	if(equali(model,"models/knife-mod/v_butcher.mdl") && !equali(specialKnife[id][1],""))
		set_pev(id,pev_viewmodel2,specialKnife[id][1]);
	return PLUGIN_HANDLED;
}
//Giving weapons to vips
public GiveWeapons(id){
	fm_give_item(id,"CSW_VESTHELM");
	fm_set_user_health(id,150);
	cs_set_user_armor(id, 100, CS_ARMOR_VESTHELM);
	fm_give_item(id,"weapon_hegrenade");
	fm_give_item(id,"weapon_smokegrenade");
	fm_give_item(id,"weapon_flashbang");
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
//Load vips from the file
public LoadVips(){
	new readdata[128], txtlen;
	new parsedkey[64], junk[64];
	
	new line = 0
	while(read_file(fileName,line++,readdata,127,txtlen))
	{
		if (readdata[0] == ';' || readdata[0] == '/' || !readdata[0])
		{
			continue;
		}

		parse(readdata,parsedkey, 63, junk, 63);
		vipKey[line] = parsedkey;
	}

	return PLUGIN_CONTINUE;
}
//Menu to choose the menu you want
public VipMenu(id){
	if(!isPlayerVip(id)){
		client_print(id,print_chat, "Acest meniu este doar pentru VIP!");
		return PLUGIN_CONTINUE;
	}
	new menu = menu_create( "\rChoose The Menu You Want!:", "menu_handler1" );

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
	new menu = menu_create( "\rChoose Knife To Set Skin To!:", "menu_handler" );

	menu_additem( menu, "\wDefault Knife", "", 0 );
	menu_additem( menu, "\wGravity Knife", "", 0 );

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
	new menu = menu_create( "\rChoose Knife To Set Skin To!:", "menu_handler4" );

	menu_additem( menu, "\wDefault Usp", "", 0 );
	menu_additem( menu, "\wBlue Crystal", "", 0 );
	menu_additem( menu, "\wFade", "", 0 );
	menu_additem( menu, "\wNeo-Noir", "", 0 );
	menu_additem( menu, "\wBlue Flame", "", 0 );
	menu_additem( menu, "\wBlood Moon", "", 0 );

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

	new menu = menu_create( "\rChoose Skin!:", "menu2_handler" );

	menu_additem( menu, "\wDefault", "", 0 );
	menu_additem( menu, "\wRainbow", "", 0 );
	menu_additem( menu, "\wAcid", "", 0 );
	menu_additem( menu, "\wGhost", "", 0 );
	menu_additem( menu, "\wFade", "", 0 );
	menu_additem( menu, "\wRedButt", "", 0 );
	menu_additem( menu, "\wMonster", "", 0 );
	menu_additem( menu, "\wShark", "", 0 );
	menu_additem( menu, "\wRedbutt2", "", 0 );
	menu_additem( menu, "\wHide", "", 0 );

	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, menu, 0 );
}
//Second Handler for the second menu
public menu2_handler( id, menu, item){
	if(knifeId == 1 && item == 0){
		specialKnife[id][knifeId] = "models/knife-mod/v_butcher.mdl";
		Save(id);
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	specialKnife[id][knifeId] = knifeModels[item];
	Save(id);
	menu_destroy( menu );
	return PLUGIN_HANDLED;
}

//Show Motd
public ShowMotd(id){
	show_motd(id,"addons/vip.html","Beneficii VIP");
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
	if(lives[id]>0){
		ExecuteHamB(Ham_CS_RoundRespawn, id);
		lives[id]--;
	}
	else{
		client_print(id,print_chat, "Nu ai destule vieti!");
	}
	
	return PLUGIN_HANDLED;
}

//Toggle some booleans
public ToggleSkins(id){
	skins[id]=!skins[id];
}

public ToggleVipShow(id){
	showVips[id]=!showVips[id];
}

public isPlayerVip(id){
	return isVip[id];
}
//save the skins and sounds for the vips
public Save(id){
	new name[30];
	new key1[30];
	new key2[30];
	new key4[30];


	get_user_name( id , name , charsmax( name ) );

	formatex(key1, charsmax(key1), "%s", name);
	formatex(key2, charsmax(key2), "%s+1", name);
	formatex(key4, charsmax(key2), "%s+3", name);
	
	nvault_set( vault , key1 , specialKnife[id][0]);
	nvault_set( vault , key2 , specialKnife[id][1]);
	nvault_set( vault , key4 , specialUsp[id]);
}
//loads the skins and sounds for the vips
public Load(id){
	if(!isPlayerVip(id))
		return PLUGIN_CONTINUE;

	new name[30];
	new key1[30];
	new key2[30];
	new key4[30];

	get_user_name( id , name , charsmax( name ) );

	formatex(key1, charsmax(key1), "%s", name);
	formatex(key2, charsmax(key2), "%s+1", name);
	formatex(key4, charsmax(key2), "%s+3", name);

	nvault_get( vault , key1 , specialKnife[id][0] , 127 );  
	nvault_get( vault , key2 , specialKnife[id][1] , 127 );
	nvault_get( vault , key4 , specialUsp[id] , 127 );

	return PLUGIN_CONTINUE;
}