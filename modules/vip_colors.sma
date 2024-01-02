#include <amxmodx>
#include <engine>
#include <nvault>

#define PLUGIN "Vip Colors"
#define VERSION "1.0"
#define AUTHOR "MrShark45"

native isPlayerVip(id);
native set_user_colors(id, r, g, b);

new g_vault;

public plugin_init(){
	
	register_plugin(PLUGIN,VERSION,AUTHOR);

	register_clcmd("say", "hook_say");

	g_vault = nvault_open("colors");
}

public plugin_end(){
	nvault_close(g_vault);
}

public client_putinserver(id){
	if(isPlayerVip(id))
		load_colors(id);
}

public hook_say(id){
	new args[32], cmd[16], colors[3];

	read_args(args, charsmax(args));
	remove_quotes(args);

	argbreak(args, cmd, charsmax(cmd), args, charsmax(args));

	if(!equali(cmd, "/colors")) return PLUGIN_CONTINUE;

	if(!isPlayerVip(id)){
		client_print_color(id, print_chat, "^4[VIP] ^1Trebuie sa fii ^4VIP ^1pentru a folosi aceasta comanda!");
		return PLUGIN_CONTINUE;
	}
	
	parse_colors(args, colors);

	set_user_colors(id, colors[0], colors[1], colors[2]);

	save_colors(id, args);

	return PLUGIN_CONTINUE;
}

public save_colors(id, szColors[]){
	new key[32];
	get_user_name(id, key, charsmax(key));

	nvault_set(g_vault, key, szColors);
}

public load_colors(id){
	new key[32], szColors[16], iColors[3], timestamp;
	get_user_name(id, key, charsmax(key));

	if(nvault_lookup(g_vault, key, szColors, charsmax(szColors), timestamp)){
		parse_colors(szColors, iColors);
		set_user_colors(id, iColors[0], iColors[1], iColors[2]);
	}
}

stock parse_colors(szColors[], iColors[]){
	new temp[4], pos;
	for(new i;i<3;i++){
		pos = argparse(szColors, pos, temp, charsmax(temp));
		iColors[i] = str_to_num(temp);
	}
}