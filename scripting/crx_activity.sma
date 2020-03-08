#include <amxmodx>
#include <amxmisc>
#include <nvault>

new vault_name[] = "activity";
new player_time[33];

public plugin_init(){
	register_plugin("Player Activity", "1.0", "Relaxing");

	register_concmd("amx_activity", "clcmd_admin_activity", ADMIN_LEVEL_A);
	register_clcmd("say /activity", "clcmd_activity");
}

public plugin_natives(){
	register_native("_get_user_time", "_get_user_time", 1);
}

public client_putinserver(id){
	if (!is_user_bot(id) && !is_user_hltv(id)){
		LoadTime(id);
	}
}

public client_disconnected(id){
	if (!is_user_bot(id) && !is_user_hltv(id)){
		SaveTime(id);
		player_time[id] = 0;
	}
}

public clcmd_admin_activity(id, level, cid){
	if (!cmd_access(id, level, cid, 0))
		return PLUGIN_HANDLED;
		
	new players[32], num, pid, name[32], x;
	get_players(players, num, "ch");
		
	if (players[0]){
		console_print(id, "All Time activity");
		for (new i = 0; i < num; i++){
			pid = players[i]; x++;
			
			get_user_name(pid, name, charsmax(name));
			console_print(id, "%d) %s    %s", x, name, CalculateTime(player_time[pid]));
		}
	} else console_print(id, "No valid players online");
	return PLUGIN_HANDLED;
}

public clcmd_activity(id){
	client_print(id, print_chat, "Current activity: %s", CalculateTime(get_user_time(id)/60));
	client_print(id, print_chat, "All Time activity: %s", CalculateTime(player_time[id]));
	return PLUGIN_HANDLED;
}

stock CalculateTime(Minutes){
	new pReturn[32];
	new hours, minutes = Minutes
	
	while (minutes >= 60){
		hours++;
		minutes -= 60;
	}
	
	if (hours) formatex(pReturn, charsmax(pReturn), "%d hour%s & %d minute%s", hours, hours == 1 ? "" : "s", minutes, minutes == 1 ? "" : "s");
	else formatex(pReturn, charsmax(pReturn), "%d minute%s", minutes, minutes == 1 ? "" : "s");
	hours = minutes = 0;
	return pReturn;
}

stock LoadTime(id){
	new authid[20], vault_data[10], temp;
	new vault = nvault_open(vault_name);
	get_user_authid(id, authid, charsmax(authid));
	
	if (nvault_lookup(vault, authid, vault_data, charsmax(vault_data), temp)){
		nvault_get(vault, authid, vault_data, charsmax(vault_data));
		player_time[id] = str_to_num(vault_data);
	}
	else {
		player_time[id] = 0;
		num_to_str(player_time[id], vault_data, charsmax(vault_data));
		nvault_set(vault, authid, vault_data);
	}
	nvault_close(vault);
}
	
stock SaveTime(id){
	new data, authid[20], vault_data[10];
	new current_time = get_user_time(id)/60;
	new vault = nvault_open(vault_name);
	get_user_authid(id, authid, charsmax(authid));
	nvault_get(vault, authid, vault_data, charsmax(vault_data));
	data = str_to_num(vault_data);
	data += current_time;
	
	num_to_str(data, vault_data, charsmax(vault_data));
	nvault_set(vault, authid, vault_data);
	nvault_close(vault);
}

public _get_user_time(id)
	return is_user_connected(id) ? player_time[id] : 0;
