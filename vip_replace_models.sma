#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <engine>
#include <nvault>
#include <fun>

#define PLUGIN "Vip Replace Models"
#define VERSION "1.0"
#define AUTHOR "MrShark45"

#pragma tabsize 0

#define newModels 9

native isPlayerVip(id);

//List of the old models
new new_v_model[newModels][]={
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

//Main
public plugin_init(){
	
	register_plugin(PLUGIN,VERSION,AUTHOR);

	register_event("CurWeapon","Changeweapon_Hook","be","1=1");

}


//Precaching the skins from the list above
public plugin_precache(){
	for(new i=0;i<newModels;i++)
		precache_model(new_v_model[i]);
}

//Checking the weapon the player switched to and if he's a vip it'll set a skin on that weapon if it's on the weapons list above
public Changeweapon_Hook(id){
	if(!is_user_alive(id)||!isPlayerVip(id))
	{
		return PLUGIN_CONTINUE;
	}
	new model[42];

	pev(id,pev_viewmodel2,model, charsmax(model));
	for(new i=0;i<newModels;i++){
		if(equali(model,old_v_model[i])){
			set_pev(id,pev_viewmodel2,new_v_model[i]);
		}
	}

	return PLUGIN_HANDLED;
}
