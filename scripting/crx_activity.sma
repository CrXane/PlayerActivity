#include <amxmodx>
#include <amxmisc>
#include <nvault>

new vault_name[] = "activity";

enum _:PlayerData{
	steamid[32],
	total_playtime[16],
	iTotal_playtime,
	timestamp,
	bool:is_player,
}

new Player[33][PlayerData];

public plugin_init(){
	register_plugin("Player Activity", "1.1", "Relaxing");

	register_concmd("amx_activity", "clcmd_admin_activity", ADMIN_LEVEL_A, " - shows current players' activity, [steamid] for single search");
	register_clcmd("say /activity", "clcmd_activity");
}

public plugin_natives(){
	register_native("_get_user_time", "_get_user_time", 1);
	register_native("_get_user_time_timestamp", "_get_user_time_timestamp", 1);
}

public client_putinserver(id){
	Player[id][is_player] = bool: (!is_user_bot(id) && !is_user_hltv(id));
	
	if (Player[id][is_player]){
		get_user_authid(id, Player[id][steamid], charsmax(Player[][steamid]));
		LoadTime(id);
	}
}

public client_disconnected(id){
	if (Player[id][is_player]){
		SaveTime(id);
	}
}

public clcmd_admin_activity(id, level, cid){
	if (!cmd_access(id, level, cid, 0))
		return PLUGIN_HANDLED;
		
	new args[32];
	read_args(args, charsmax(args));
	remove_quotes(args); trim(args);
	
	if (strlen(args)){
		new vault = nvault_open(vault_name);
		new vault_data[10], _time[24], temp;
		
		if (nvault_lookup(vault, args, vault_data, charsmax(vault_data), temp)){
			format_time(_time, charsmax(_time), "%m/%d/%Y %H:%M:%S", temp);
			console_print(id, "%s    %s", args, CalculateTime(str_to_num(vault_data)));
			console_print(id, "Last online %s", _time)
		} else console_print(id, "No data matching ^"%s^"", args);
	} else {	
		new players[32], num, pid, name[32], x;
		get_players(players, num, "ch");
			
		if (players[0]){
			console_print(id, "All Time activity");
			for (new i = 0; i < num; i++){
				pid = players[i]; x++;
				
				get_user_name(pid, name, charsmax(name));
				console_print(id, "%d) %s    %s", x, name, CalculateTime(Player[pid][iTotal_playtime]));
			}
		} else console_print(id, "No valid players online");
	}
	
	return PLUGIN_HANDLED;
}

public clcmd_activity(id){
	client_print(id, print_chat, "Current activity: %s", CalculateTime(get_user_time(id)/60));
	client_print(id, print_chat, "All Time activity: %s", CalculateTime(Player[id][iTotal_playtime]));
	return PLUGIN_HANDLED;
}

stock CalculateTime(Minutes){
	new pReturn[32];
	new hours, minutes = Minutes
	
	hours = minutes / 60;
	minutes = minutes - (hours * 60);

	if (hours) formatex(pReturn, charsmax(pReturn), "%d hour%s & %d minute%s", hours, hours == 1 ? "" : "s", minutes, minutes == 1 ? "" : "s");
	else formatex(pReturn, charsmax(pReturn), "%d minute%s", minutes, minutes == 1 ? "" : "s");
	
	return pReturn;
}

stock LoadTime(id){
	new vault = nvault_open(vault_name);
	
	if (nvault_lookup(vault, Player[id][steamid], Player[id][total_playtime], charsmax(Player[][total_playtime]), Player[id][timestamp]))
		Player[id][iTotal_playtime] = str_to_num(Player[id][total_playtime]);
	else {
		Player[id][total_playtime] = "0";
		Player[id][timestamp] = get_systime();
		nvault_set(vault, Player[id][steamid], Player[id][total_playtime]);
	}
	nvault_close(vault);
}
	
stock SaveTime(id){
	new vault = nvault_open(vault_name);
	formatex(Player[id][total_playtime], charsmax(Player[][total_playtime]), "%d", Player[id][iTotal_playtime] + get_user_time(id)/60);
	nvault_set(vault, Player[id][steamid], Player[id][total_playtime]);
	nvault_close(vault);
}

public _get_user_time(id)
	return is_user_connected(id) ? Player[id][iTotal_playtime] : 0;

public _get_user_time_timestamp(id)
	return is_user_connected(id) ? Player[id][timestamp] : 0;
