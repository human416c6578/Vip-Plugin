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

native isPlayerVip(id);

#define KNIFE_NUM 15

#define VIP_KNIFE_NUM 4

#define USP_NUM 8

//List of the new knife models
new knifeModels[KNIFE_NUM][128]={
	"models/llg/v_knife.mdl",
	"models/llg/v_def_ghost.mdl", //DEF GHOST
	"models/llg/v_but_lion.mdl", //BUT LION
	"models/llg/v_def_rainbow.mdl", //DEF RAINBOW
	"models/llg/v_but_fade.mdl", // BUT FADE
	"models/llg/v_but_xiao.mdl", // BUT XIAO
	"models/llg/v_but_gojo.mdl", // BUT GOJOCAT
	"models/llg/v_def_blood.mdl", // DEF BLOOD
	"models/llg/v_but_blood.mdl", // BUT BLOOD
	"models/llg/v_but_nezuko.mdl", // BUT Nezuko
	"models/llg/v_def_toxic.mdl", // DEF TOXIC
	"models/llg/v_but_rias.mdl", // BUT RIAS
	"models/llg/v_but_carbon.mdl", // BUT CARBON
	"models/llg/v_but_hyperbeast.mdl", // BUT HyperBeast
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
	"models/llg/v_usp_blue.mdl", // BLUE
	"models/llg/v_usp_fade.mdl", // FADE
	"models/llg/v_usp_blood.mdl", // BLOOD
	"models/llg/v_usp_sakura.mdl", // SAKURA
	"models/llg/v_usp_carbon.mdl", // CARBON
	"models/llg/v_usp_xiao.mdl", // XIAO
	"models/llg/v_usp_cortex.mdl" // CORTEX
	
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


new specialKnife[33][2][128];
new specialUsp[33][128];

new knifeId;

new vault;

//Main
public plugin_init(){
	
	register_plugin(PLUGIN,VERSION,AUTHOR);

	register_clcmd( "say /vmenu","VipMenu" );

	register_event("CurWeapon","Changeweapon_Hook","be","1=1");

	register_event("ResetHUD", "resetModel", "b");

	vault = nvault_open( "skinsvip" );
}


//Precaching the skins from the list above
public plugin_precache(){
	for(new i=0;i<KNIFE_NUM;i++)
		precache_model(knifeModels[i]);
	for(new i=0;i<USP_NUM;i++)
		precache_model(uspModels[i]);

	//precache vip models
	precache_generic("models/player/admin_cte/admin_cte.mdl");
	precache_generic("models/player/admin_te/admin_te.mdl");
	precache_generic("models/player/vipHD/vipHD.mdl");

}

public client_putinserver(id){
    Load(id);
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
	if(!is_user_alive(id)||!isPlayerVip(id))
	{
        return PLUGIN_CONTINUE;
    }

    new model[42];

    pev(id,pev_viewmodel2,model, charsmax(model));

    if(equali(model, "models/v_usp.mdl") && !equali(specialUsp[id], ""))
        set_pev(id,pev_viewmodel2,specialUsp[id]);
	if(equali(model,"models/llg/v_knife.mdl") && !equali(specialKnife[id][0],""))
		set_pev(id,pev_viewmodel2,specialKnife[id][0]);
	if(equali(model,"models/llg/v_butcher.mdl") && !equali(specialKnife[id][1],""))
		set_pev(id,pev_viewmodel2,specialKnife[id][1]);

	return PLUGIN_HANDLED;
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
	nvault_set( vault , key , specialUsp[id]);

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
	nvault_get( vault , key , specialUsp[id], 127 );

	return PLUGIN_CONTINUE;
}
