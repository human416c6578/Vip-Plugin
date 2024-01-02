#include <amxmodx>
#include <cstrike>
#include <fakemeta_util>
#include <hamsandwich>


#define PLUGIN "Vip Lives"
#define VERSION "1.0"
#define AUTHOR "MrShark45"

#pragma tabsize 0

native isPlayerVip(id);

new lives[33];

//Main
public plugin_init(){
	
	register_plugin(PLUGIN,VERSION,AUTHOR);

	register_clcmd("say /respawn", "Respawn");

	register_event("HLTV", "NewRound", "a", "1=0", "2=0")

	RegisterHam(Ham_Spawn,"player","PlayerSpawn",1);
}


//Event New Round
public NewRound(){
	for(new i = 0;i<33;i++){
		if(is_user_connected(i) && isPlayerVip(i))
			lives[i] = 2;
	}

}

public PlayerSpawn(id){
    if(!isPlayerVip(id) || !is_user_connected(id)) return PLUGIN_CONTINUE;

    set_task(0.3, "GiveWeapons", id);

    return PLUGIN_CONTINUE;
}

//Giving weapons to vips
public GiveWeapons(id){
	if(!is_user_connected(id))
		return PLUGIN_HANDLED;
	
	fm_give_item(id,"CSW_VESTHELM");
	fm_set_user_health(id, 150);
	cs_set_user_armor(id, 100, CS_ARMOR_VESTHELM);
	if(!time_check())
		fm_give_item(id,"weapon_hegrenade");
	
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
	if(checkCTAlive() < 3){
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
