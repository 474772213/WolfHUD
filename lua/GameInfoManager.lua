
printf = function(...) 
	WolfHUD:print_log(string.format(...))
end

if RequiredScript == "lib/setups/gamesetup" then
	
	local init_managers_original = GameSetup.init_managers
	local update_original = GameSetup.update
	
	function GameSetup:init_managers(managers, ...)
		managers.gameinfo = managers.gameinfo or GameInfoManager:new()
		return init_managers_original(self, managers, ...)
	end
	
	function GameSetup:update(t, dt, ...)
		managers.gameinfo:update(t, dt)
		return update_original(self, t, dt, ...)
	end
	
	
	GameInfoManager = GameInfoManager or class()
	
	GameInfoManager._TIMER_CALLBACKS = {
		default = {
			--Digital specific functions
			set = function(timers, key, timer)
				GameInfoManager._TIMER_CALLBACKS.default.update(timers, key, Application:time(), timer)
			end,
			start_count_up = function(timers, key)
				if timers[key] and timers[key].ext._visible then
					GameInfoManager._TIMER_CALLBACKS.default.set_active(timers, key, true)
					GameInfoManager._TIMER_CALLBACKS.default.set_jammed(timers, key, false)
				end
			end,
			start_count_down = function(timers, key)
				if timers[key] and timers[key].ext._visible then
					GameInfoManager._TIMER_CALLBACKS.default.set_active(timers, key, true)
					GameInfoManager._TIMER_CALLBACKS.default.set_jammed(timers, key, false)
				end
			end,
			pause = function(timers, key)
				GameInfoManager._TIMER_CALLBACKS.default.set_jammed(timers, key, true)
			end,
			resume = function(timers, key)
				GameInfoManager._TIMER_CALLBACKS.default.set_jammed(timers, key, false)
			end,
			stop = function(timers, key)
				GameInfoManager._TIMER_CALLBACKS.default.set_active(timers, key, false)
			end,
			
			--General functions
			update = function(timers, key, t, timer)
				if timers[key] then
					timers[key].t = t
					timers[key].timer = timer
					managers.gameinfo:_listener_callback("timer", "update", key, timers[key])
				end
			end,
			set_active = function(timers, key, status)
				if timers[key] and timers[key].active ~= status then
					timers[key].active = status
					managers.gameinfo:_listener_callback("timer", "set_active", key, timers[key])
				end
			end,
			set_jammed = function(timers, key, status)
				if timers[key] and timers[key].jammed ~= status then
					timers[key].jammed = status
					managers.gameinfo:_listener_callback("timer", "set_jammed", key, timers[key])
				end
			end,
			set_powered = function(timers, key, status)
				if timers[key] and timers[key].powered ~= status then
					timers[key].powered = status
					managers.gameinfo:_listener_callback("timer", "set_powered", key, timers[key])
				end
			end,
			set_upgradable = function(timers, key, status)
				if timers[key] and timers[key].upgradable ~= status then
					timers[key].upgradable = status
					managers.gameinfo:_listener_callback("timer", "set_upgradable", key, timers[key])
				end
			end,
		},
		overrides = {
			--Common functions
			stop_on_loud_pause = function(...)
				if not managers.groupai:state():whisper_mode() then
					GameInfoManager._TIMER_CALLBACKS.default.stop(...)
				else
					GameInfoManager._TIMER_CALLBACKS.default.pause(...)
				end
			end,
			stop_on_pause = function(...)
				GameInfoManager._TIMER_CALLBACKS.default.stop(...)
			end,
		
			[132864] = {	--Meltdown vault temperature
				set = function(timers, key, timer)
					if timer > 0 then
						GameInfoManager._TIMER_CALLBACKS.default.set_active(timers, key, true)
					end
					GameInfoManager._TIMER_CALLBACKS.default.set(timers, key, timer)
				end,
				start_count_down = function(timers, key)
					GameInfoManager._TIMER_CALLBACKS.default.set_active(timers, key, false)
				end,
				pause = function(...) end,
			},
			[101936] = { pause = function(...) GameInfoManager._TIMER_CALLBACKS.overrides.stop_on_pause(...) end },	--GO Bank time lock
			[139706] = { pause = function(...) GameInfoManager._TIMER_CALLBACKS.overrides.stop_on_pause(...) end },	--Hoxton Revenge alarm	(UNTESTED)
			[132675] = { pause = function(...) GameInfoManager._TIMER_CALLBACKS.overrides.stop_on_loud_pause(...) end },	--Hoxton Revenge panic room time lock	(UNTESTED)
			[133922] = { pause = function(...) GameInfoManager._TIMER_CALLBACKS.overrides.stop_on_loud_pause(...) end },	--The Diamond pressure plates timer
			[130022] = { pause = function(...) GameInfoManager._TIMER_CALLBACKS.overrides.stop_on_loud_pause(...) end },	--Train heist vaults
			[130122] = { pause = function(...) GameInfoManager._TIMER_CALLBACKS.overrides.stop_on_loud_pause(...) end },	--Train heist vaults
			[130222] = { pause = function(...) GameInfoManager._TIMER_CALLBACKS.overrides.stop_on_loud_pause(...) end },	--Train heist vaults
			[130322] = { pause = function(...) GameInfoManager._TIMER_CALLBACKS.overrides.stop_on_loud_pause(...) end },	--Train heist vaults
			[130422] = { pause = function(...) GameInfoManager._TIMER_CALLBACKS.overrides.stop_on_loud_pause(...) end },	--Train heist vaults
			[130522] = { pause = function(...) GameInfoManager._TIMER_CALLBACKS.overrides.stop_on_loud_pause(...) end },	--Train heist vaults
			--[130320] = { },	--The Diamond outer time lock
			--[130395] = { },	--The Diamond inner time lock
			--[101457] = { },	--Big Bank time lock door #1
			--[104671] = { },	--Big Bank time lock door #2
			--[167575] = { },	--Golden Grin BFD timer
			--[135034] = { },	--Lab rats cloaker safe 1
			--[135076] = { },	--Lab rats cloaker safe 2
			--[135246] = { },	--Lab rats cloaker safe 3
			--[135247] = { },	--Lab rats cloaker safe 4
		}
	}
	
	GameInfoManager._INTERACTIONS = {
		INTERACTION_TO_CALLBACK = {
			corpse_alarm_pager =				"_pager_event",
			gen_pku_crowbar =					"_special_equipment_interaction_handler",
			pickup_keycard =					"_special_equipment_interaction_handler",
			pickup_hotel_room_keycard =			"_special_equipment_interaction_handler",
			gage_assignment =					"_special_equipment_interaction_handler",
			pickup_boards =						"_special_equipment_interaction_handler",
			stash_planks_pickup =				"_special_equipment_interaction_handler",
			muriatic_acid =						"_special_equipment_interaction_handler",
			hydrogen_chloride =					"_special_equipment_interaction_handler",
			caustic_soda =						"_special_equipment_interaction_handler",
			gen_pku_blow_torch =				"_special_equipment_interaction_handler",
			drk_pku_blow_torch = 				"_special_equipment_interaction_handler",
			gen_pku_thermite = 					"_special_equipment_interaction_handler",
			gen_pku_thermite_paste = 			"_special_equipment_interaction_handler",
			hold_take_gas_can = 				"_special_equipment_interaction_handler",
			money_wrap_single_bundle = 			"_special_equipment_interaction_handler",
			money_wrap_single_bundle_active = 	"_special_equipment_interaction_handler",
			money_wrap_single_bundle_dyn = 		"_special_equipment_interaction_handler",
			cas_chips_pile = 					"_special_equipment_interaction_handler",
			diamond_pickup = 					"_special_equipment_interaction_handler",
			diamond_pickup_pal = 				"_special_equipment_interaction_handler",
			ring_band = 						"_special_equipment_interaction_handler",
			safe_loot_pickup = 					"_special_equipment_interaction_handler",
			press_pick_up =						"_special_equipment_interaction_handler",
			firstaid_box =						"_deployable_interaction_handler",
			ammo_bag =							"_deployable_interaction_handler",
			doctor_bag =						"_deployable_interaction_handler",
			bodybags_bag =						"_deployable_interaction_handler",
			grenade_crate =						"_deployable_interaction_handler",
		},
		INTERACTION_TO_CARRY = {
			weapon_case =				"weapon",
			weapon_case_axis_z =		"weapon",
			samurai_armor =				"samurai_suit",
			gen_pku_warhead_box =		"warhead",
			corpse_dispose =			"person",
			hold_open_case =			"drone_control_helmet",	--May be reused in future heists for other loot
		},
		BAGGED_IDS = {
			painting_carry_drop = true,
			carry_drop = true,
			safe_carry_drop = true,
			goat_carry_drop = true,
		},
		COMPOSITE_LOOT_UNITS = {
			gen_pku_warhead_box = 2,	--[132925] = 2, [132926] = 2, [132927] = 2,	--Meltdown warhead cases
			--hold_open_bomb_case = 4,	--The Bomb heists cases, extra cases on docks screws with counter...
			[103428] = 4, [103429] = 3, [103430] = 2, [103431] = 1,	--Shadow Raid armor
			--[102913] = 1, [102915] = 1, [102916] = 1,	--Train Heist turret (unit fixed, need workaround)
			[105025] = 10, [105026] = 9, [104515] = 8, [104518] = 7, [104517] = 6, [104522] = 5, [104521] = 4, [104520] = 3, [104519] = 2, [104523] = 1, --Slaughterhouse alt 1.
			[105027] = 10, [105028] = 9, [104525] = 8, [104524] = 7, [104490] = 6, [100779] = 5, [100778] = 4, [100777] = 3, [100773] = 2, [100771] = 1, --Slaughterhouse alt 2.
		},
		CONDITIONAL_IGNORE_IDS = {
			ff3_vault = function(wall_id)
				if managers.job:current_level_id() == "framing_frame_3" then
					for _, unit in pairs(World:find_units_quick("all", 1)) do
						if unit:editor_id() == wall_id then
							return true
						end
					end
				end
			end,

			--FF3 lounge vault
			[100548] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(100448) end,
			[100549] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(100448) end,
			[100550] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(100448) end,
			[100551] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(100448) end,
			[100552] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(100448) end,
			[100553] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(100448) end,
			[100554] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(100448) end,
			[100555] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(100448) end,
			--FF3 bedroom vault
			[100556] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101431) end,
			[100557] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101431) end,
			[100558] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101431) end,
			[100559] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101431) end,
			[100560] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101431) end,
			[100561] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101431) end,
			[100562] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101431) end,
			[100563] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101431) end,
			--FF3 upstairs vault
			[100564] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101423) end,
			[100566] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101423) end,
			[100567] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101423) end,
			[100568] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101423) end,
			[100569] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101423) end,
			[100570] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101423) end,
			[100571] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101423) end,
			[100572] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101423) end,
		},
		IGNORE_IDS = {
			watchdogs_2 = {	--Watchdogs day 2 (8x coke)
				[100054] = true, [100058] = true, [100426] = true, [100427] = true, [100428] = true, [100429] = true, [100491] = true, [100492] = true, [100494] = true, [100495] = true,
			},
			family = {	--Diamond store (1x money)
				[100899] = true,
			},	--Hotline Miami day 1 (1x money)
			mia_1 = {	--Hotline Miami day 1 (1x money)
				[104526] = true,
			},
			welcome_to_the_jungle_1 = {	--Big Oil day 1 (1x money, 1x gold)
				[100886] = true, [100872] = true,
			},
			mus = {	--The Diamond (RNG)
				[300047] = true, [300686] = true, [300457] = true, [300458] = true, [301343] = true, [301346] = true,
			},
			arm_und = {	--Transport: Underpass (8x money)
				[101237] = true, [101238] = true, [101239] = true, [103835] = true, [103836] = true, [103837] = true, [103838] = true, [101240] = true,
			},
			ukrainian_job = {	--Ukrainian Job (3x money)
				[101514] = true,
				[102052] = true,
				[102402] = true,
			},
			firestarter_2 = {	--Firestarter day 2 (1x keycard)
				[107208] = true,
			},
			big = {	--Big Bank (1x keycard)
				[101499] = true,
			},
			roberts = {	--GO Bank (1x keycard)
				[106104] = true,
			},
			jewelry_store = {	--Jewelry Store (2x money)
				[102052] = true,
				[102402] = true,
			},
		},
	}
	GameInfoManager._INTERACTIONS.IGNORE_IDS.watchdogs_2_day = table.deep_map_copy(GameInfoManager._INTERACTIONS.IGNORE_IDS.watchdogs_2)
	GameInfoManager._INTERACTIONS.IGNORE_IDS.welcome_to_the_jungle_1_night = table.deep_map_copy(GameInfoManager._INTERACTIONS.IGNORE_IDS.welcome_to_the_jungle_1)
	
	GameInfoManager._EQUIPMENT = {
		AMOUNT_OFFSETS = {
			--interaction_id or editor_id
			firstaid_box = -1,	--GGC drill asset, HB infirmary
		},
		AGGREAGATE_ITEMS = {
			[136859] = "hb_armory_grenade",
			[136870] = "hb_armory_grenade",
			[136869] = "hb_armory_grenade",
			[136864] = "hb_armory_grenade",
			[136866] = "hb_armory_grenade",
			[136860] = "hb_armory_grenade",
			[136867] = "hb_armory_grenade",
			[136865] = "hb_armory_grenade",
			[136868] = "hb_armory_grenade",
			[136846] = "hb_armory_ammo",
			[136844] = "hb_armory_ammo",
			[136845] = "hb_armory_ammo",
			[136847] = "hb_armory_ammo",
			[101470] = "hb_infirmary_cabinet",
			[101472] = "hb_infirmary_cabinet",
			[101473] = "hb_infirmary_cabinet",
			[151596] = "ggc_armory_grenade",
			[151597] = "ggc_armory_grenade",
			[151598] = "ggc_armory_grenade",
			[151611] = "ggc_armory_ammo",
			[151612] = "ggc_armory_ammo",
			[100776] = "biker_bunker_grenade",
			[101226] = "biker_bunker_grenade",
			[101469] = "biker_bunker_grenade",
			[101472] = "biker_bunker_ammo",
			[101473] = "biker_bunker_ammo",
		},
	}
	
	GameInfoManager._BUFFS = {
		on_activate = {
			armor_break_invulnerable_debuff = function(id, data)
				local upgrade_value = managers.player:upgrade_value("temporary", "armor_break_invulnerable")
				managers.gameinfo:event("timed_buff", "activate", "armor_break_invulnerable", { t = data.t, duration = upgrade_value and upgrade_value[1] or 0 })
			end,
		},
		on_set_duration = {
			overkill = function(id, data)
				if managers.player:has_category_upgrade("player", "overkill_all_weapons") then
					managers.gameinfo:event("timed_buff", "activate", "overkill_aced", data)
				end
			end,
		},
		on_set_value = {
			overkill = function(id, data)
				if managers.player:has_category_upgrade("player", "overkill_all_weapons") then
					managers.gameinfo:event("buff", "set_value", "overkill_aced", { value = data.value })
				end
			end,
		},
		
		--Temporary upgrades
		temporary = {
			damage_speed_multiplier = "second_wind",
			dmg_multiplier_outnumbered = "underdog",
			dmg_dampener_outnumbered = "underdog_aced",
			dmg_dampener_outnumbered_strong = "overdog",
			dmg_dampener_close_contact = { "close_contact_1", "close_contact_2", "close_contact_3" },
			overkill_damage_multiplier = "overkill",
			--melee_kill_increase_reload_speed = "bloodthirst_aced",
			passive_revive_damage_reduction = { "pain_killer", "pain_killer_aced" },
			berserker_damage_multiplier = { "swan_song", "swan_song_aced" },
			first_aid_damage_reduction = "quick_fix",
			increased_movement_speed = "running_from_death_aced",
			reload_weapon_faster = "running_from_death_basic",
			revive_damage_reduction = "combat_medic",
			revived_damage_resist = "up_you_go",
			swap_weapon_faster = "running_from_death_basic",
			team_damage_speed_multiplier_received = "second_wind",
			melee_life_leech = "life_drain_debuff",
			loose_ammo_restore_health = "medical_supplies_debuff",
			loose_ammo_give_team = "ammo_give_out_debuff",
			armor_break_invulnerable = "armor_break_invulnerable_debuff",
			single_shot_fast_reload = "aggressive_reload_aced",
			
			--"properties"
			bloodthirst_reload_speed = "bloodthirst_aced",
			revived_damage_reduction = "pain_killer",
		},
		cooldown = {
			long_dis_revive = "inspire_revive_debuff",
		},
		--Team upgrades
		damage_dampener = {
			hostage_multiplier =  { id = "crew_chief_9", level = 9 },
			team_damage_reduction = { id = "crew_chief_1", level = 1 },
		},
		stamina = {
			multiplier = { id = "endurance", level = 0 },
			passive_multiplier = { id = "crew_chief_3", level = 3 }, 
			hostage_multiplier =  { id = "crew_chief_9", level = 9 },
		},
		health = {
			passive_multiplier = { id = "crew_chief_5", level = 5 },
			hostage_multiplier = { id = "crew_chief_9", level = 9 },
		},
		armor = {
			multiplier =  { id = "crew_chief_7", level = 7 },
			regen_time_multiplier = { id = "bulletproof", level = 0 },
			passive_regen_time_multiplier = { id = "armorer_9", level = 9 },
		},
		damage = {
			hostage_absorption = { id = "forced_friendship", level = 0 },
		},
--[[
		weapon = {
			recoil_multiplier = "leadership_aced", 
			suppression_recoil_multiplier = "leadership_aced", 
		},
		pistol = {
			recoil_multiplier = "leadership", 
			suppression_recoil_multiplier = "leadership", 
		},
		akimbo = {
			recoil_multiplier = "leadership", 
			suppression_recoil_multiplier = "leadership", 
		},
]]
	}
	
	function GameInfoManager:init()
		self._t = 0
		self._listeners = {}
		
		self._timers = {}
		self._units = {}
		self._unit_count = {}
		self._minions = {}
		self._turrets = {}
		self._pagers = {}
		self._cams = {}
		self._loot = {}
		self._special_equipment = {}
		self._ecms = {}
		self._deployables = {}
		self._sentries = {}
		self._buffs = {}
		self._player_actions = {}
		
		self._auto_expire_timers = {
			on_expire = {},
			expire_t = {},
		}
		self._timed_buff_expire_clbk = callback(self, self, "_on_timed_buff_expired")
		self._timed_stack_expire_clbk = callback(self, self, "_on_timed_stack_expired")
		self._player_actions_expire_clbk = callback(self, self, "_on_player_action_expired")
	end
	
	function GameInfoManager:update(t, dt)
		self:_update_player_timer_expiration(t, dt)
	end
	
	function GameInfoManager:event(source, ...)
		local target = "_" .. source .. "_event"
		
		if self[target] then
			self[target](self, ...)
		else
			printf("Error: No event handler for %s", target)
		end
	end
	
	function GameInfoManager:get_timers(key)
		if key then
			return self._timers[key]
		else
			return self._timers
		end
	end
	
	function GameInfoManager:get_units(key)
		if key then
			return self._units[key]
		else
			return self._units
		end
	end
	
	function GameInfoManager:get_unit_count(id)
		if id then
			return self._unit_count[id] or 0
		else
			return self._unit_count
		end
	end
	
	function GameInfoManager:get_minions(key)
		if key then
			return self._minions[key]
		else
			return self._minions
		end
	end
	
	function GameInfoManager:get_pagers(key)
		if key then
			return self._pagers[key]
		else
			return self._pagers
		end
	end
	
	function GameInfoManager:get_cams(key)
		if key then
			return self._cams[key]
		else
			return self._cams
		end
	end
	function GameInfoManager:get_special_equipment(key)
		if key then
			return self._special_equipment[key]
		else
			return self._special_equipment
		end
	end
	
	function GameInfoManager:get_loot(key)
		if key then
			return self._loot[key]
		else
			return self._loot
		end
	end
	
	function GameInfoManager:get_ecms(key)
		if key then
			return self._ecms[key]
		else
			return self._ecms
		end
	end
	
	function GameInfoManager:get_deployables(key)
		if key then
			return self._deployables[key]
		else
			return self._deployables
		end
	end
	
	function GameInfoManager:get_sentries(key)
		if key then
			return self._sentries[key]
		else
			return self._sentries
		end
	end
	
	function GameInfoManager:get_buffs(id)
		if id then
			return self._buffs[id]
		else
			return self._buffs
		end
	end
	
	function GameInfoManager:get_player_actions(id)
		if id then
			return self._player_actions[id]
		else
			return self._player_actions
		end
	end
	
	function GameInfoManager:_timer_event(event, key, ...)
		if event == "create" then
			if not self._timers[key] then	
				local unit, ext, device_type = ...
				local id = unit:editor_id()		
				self._timers[key] = { unit = unit, ext = ext, device_type = device_type, id = id, jammed = false, powered = true, upgradable = false }
				self:_listener_callback("timer", "create", key, self._timers[key])
			end
		elseif event == "destroy" then
			if self._timers[key] then
				GameInfoManager._TIMER_CALLBACKS.default.set_active(self._timers, key, false)
				self:_listener_callback("timer", "destroy", key, self._timers[key])
				self._timers[key] = nil
			end
		elseif self._timers[key] then
			local timer_id = self._timers[key].id
			local timer_override = GameInfoManager._TIMER_CALLBACKS.overrides[timer_id]
			
			if timer_override and timer_override[event] then
				timer_override[event](self._timers, key, ...)
			else
				GameInfoManager._TIMER_CALLBACKS.default[event](self._timers, key, ...)
			end
		end
	end
	
	function GameInfoManager:_unit_event(event, key, unit, unit_type)
		if event == "add" then
			if not self._units[key] then
				self._units[key] = { unit = unit, type = unit_type }
				self:_listener_callback("unit", event, key, self._units[key])
				self:_unit_count_event("change", unit_type, 1)
			end
		elseif event == "remove" then
			if self._units[key] then
				self:_listener_callback("unit", event, key, self._units[key])
				self:_unit_count_event("change", self._units[key].type, -1)
				self._units[key] = nil
				
				if self._minions[key] then
					self:_minion_event("remove", key)
				end
			end
		end
	end
	
	function GameInfoManager:_unit_count_event(event, unit_type, value)
		if event == "change" then
			if value ~= 0 then
				self._unit_count[unit_type] = (self._unit_count[unit_type] or 0) + value
				self:_listener_callback("unit_count", "change", unit_type, value)
			end
		elseif event == "set" then
			self:_unit_count_event("change", unit_type, value - (self._unit_count[unit_type] or 0))
		end
	end
	
	function GameInfoManager:_minion_event(event, key, ...)
		if event == "add" then
			local unit, owner, health_multiplier, damage_multiplier = ...
			
			if not self._minions[key] then
				self._minions[key] = { unit = unit, kills = 0 }
				self:_listener_callback("minion", "add", key, self._minions[key])
				self:_unit_count_event("change", "minion", 1)
			end
			
			if owner and self._minions[key].owner ~= owner then
				self._minions[key].owner = owner
				self:_listener_callback("minion", "set_owner", key, self._minions[key])
			end
			
			if health_multiplier and self._minions[key].health_multiplier ~= health_multiplier then
				self._minions[key].health_multiplier = health_multiplier
				self:_listener_callback("minion", "set_health_multiplier", key, self._minions[key])
			end
			
			if damage_multiplier and self._minions[key].damage_multiplier ~= damage_multiplier then
				self._minions[key].damage_multiplier = damage_multiplier
				self:_listener_callback("minion", "set_damage_multiplier", key, self._minions[key])
			end
		elseif self._minions[key] then
			if event == "remove" then
				self:_listener_callback("minion", "remove", key, self._minions[key])
				self:_unit_count_event("change", "minion", -1)
				self._minions[key] = nil
			elseif event == "set_health" then
				local health = ...
				self._minions[key].health = health
				self:_listener_callback("minion", "set_health", key, self._minions[key])
			elseif event == "increment_kills" then
				self._minions[key].kills = self._minions[key].kills + 1
				self:_listener_callback("minion", "set_kills", key, self._minions[key])
			end
		end
	end
	
	function GameInfoManager:_turret_event(event, key, unit)
		if event == "add" then
			if not self._turrets[key] then
				self._turrets[key] = unit
				self:_unit_count_event("change", "turret", 1)
			end
		elseif event == "remove" then
			if self._turrets[key] then
				self:_unit_count_event("change", "turret", -1)
				self._turrets[key] = nil
			end
		end
	end
	
	function GameInfoManager:_interactive_unit_event(event, key, unit)
		local lookup = GameInfoManager._INTERACTIONS
		local level_id = managers.job:current_level_id()
		local editor_id = unit:editor_id()
		
		if lookup.IGNORE_IDS[level_id] and lookup.IGNORE_IDS[level_id][editor_id] then
			return
		end
		
		if lookup.CONDITIONAL_IGNORE_IDS[editor_id] then
			if lookup.CONDITIONAL_IGNORE_IDS[editor_id]() then
				return
			end
		end
		
		local interact_id = unit:interaction().tweak_data
		local interact_clbk = lookup.INTERACTION_TO_CALLBACK[interact_id]
		
		if interact_clbk then
			self[interact_clbk](self, event, key, unit, interact_id)
		else
			local carry_id = unit:carry_data() and unit:carry_data():carry_id() or lookup.INTERACTION_TO_CARRY[interact_id] or (self._loot[key] and self._loot[key].carry_id)
			
			if carry_id then
				printf("%s - %s: %d", event, carry_id, editor_id)
				self:_loot_interaction_handler(event, key, unit, interact_id, carry_id)
			else
				self:_listener_callback("interactable_unit", event, key, unit, interact_id, carry_id)
			end
		end
	end
	
	function GameInfoManager:_pager_event(event, key, unit)
		if event == "add" then
			if not self._pagers[key] then
				self._pagers[key] = { unit = unit, active = true, answered = false }
				self:_listener_callback("pager", "add", key, self._pagers[key])
			end
		elseif event == "remove" then
			if self._pagers[key] and self._pagers[key].active then
				self._pagers[key].active = false
				self:_listener_callback("pager", "remove", key, self._pagers[key])
			end
		elseif event == "answered" then
			if self._pagers[key] and not self._pagers[key].answered then
				self._pagers[key].answered = true
				self:_listener_callback("pager", "answered", key, self._pagers[key])
			end
		end
	end
	
	function GameInfoManager:_camera_event(event, key, unit)
		if event == "add" then
			if not self._cams[key] then
				self._cams[key] = { unit = unit, active = true, destroyed = false }
				self:_listener_callback("camera", "add", key, self._cams[key])
			else
				self._cams[key].active = true
			end
		elseif event == "enable" then
			if self._cams[key] and not self._cams[key].active and not self._cams[key].destroyed then
				self._cams[key].active = true
				self:_listener_callback("camera", "enable", key, self._cams[key])
			end
		
		elseif event == "disable" then
			if self._cams[key] and self._cams[key].active and not self._cams[key].destroyed then
				self._cams[key].active = false
				self:_listener_callback("camera", "disable", key, self._cams[key])
			end
		elseif event == "destroy" then
			if self._cams[key] and not self._cams[key].destroyed then
				self._cams[key].active = false
				self._cams[key].destroyed = true
				self:_listener_callback("camera", "destroy", key, self._cams[key])
			end
		end
	end
	
	function GameInfoManager:_bodybags_event(event, key)
		if event == "set" then
			self:_listener_callback("bodybags", "set", key)
		end
	end
	
	function GameInfoManager:_special_equipment_interaction_handler(event, key, unit, interact_id)
		if event == "add" then
			if not self._special_equipment[key] then
				self._special_equipment[key] = { unit = unit, interact_id = interact_id }
				self:_listener_callback("special_equipment", "add", key, self._special_equipment[key])
			end
		elseif event == "remove" then
			if self._special_equipment[key] then
				self:_listener_callback("special_equipment", "remove", key, self._special_equipment[key])
				self._special_equipment[key] = nil
			end
		end
	end
	
	function GameInfoManager:_deployable_interaction_handler(event, key, unit, interact_id)
		if self._deployables[key] then
			local active = event == "add"
			self:_bag_deployable_event("set_active", key, active)
			
			local offset = GameInfoManager._EQUIPMENT.AMOUNT_OFFSETS[unit:editor_id()] or GameInfoManager._EQUIPMENT.AMOUNT_OFFSETS[interact_id]
			if active and offset then
				self:_bag_deployable_event("set_amount_offset", key, offset)
			end
		end
	end
	
	function GameInfoManager:_loot_interaction_handler(event, key, unit, interact_id, carry_id)
		if event == "add" then
			if not self._loot[key] then
				local composite_lookup = GameInfoManager._INTERACTIONS.COMPOSITE_LOOT_UNITS
				local count = composite_lookup[unit:editor_id()] or composite_lookup[interact_id] or 1
				local bagged = GameInfoManager._INTERACTIONS.BAGGED_IDS[interact_id] and true or false
			
				self._loot[key] = { unit = unit, carry_id = carry_id, count = count, bagged = bagged }
				self:_listener_callback("loot", "add", key, self._loot[key])
			end
		elseif event == "remove" then
			if self._loot[key] then
				self:_listener_callback("loot", "remove", key, self._loot[key])
				self._loot[key] = nil
			end
		end
	end
	
	function GameInfoManager:_ecm_event(event, key, ...)
		if event == "create" then
			if not self._ecms[key] then
				local unit = ...
				self._ecms[key] = { unit = unit }
				self:_listener_callback("ecm", "create", key, self._ecms[key])
			end
		elseif event == "destroy" then
			if self._ecms[key] then
				self:_listener_callback("ecm", "destroy", key, self._ecms[key])
				self._ecms[key] = nil
			end
		else
			if self._ecms[key] then
				if event == "set_jammer_active" then
					local active = ...
					if self._ecms[key].active ~= active then
						self._ecms[key].active = active
						self:_listener_callback("ecm", "set_jammer_active", key, self._ecms[key])
					end
				elseif event == "set_retrigger_active" then
					local active = ...
					if self._ecms[key].retrigger ~= active then
						self._ecms[key].retrigger = active
						self:_listener_callback("ecm", "set_retrigger_active", key, self._ecms[key])
					end
				elseif event == "update" then
					local battery, retrigger_t = ...
					
					if self._ecms[key].active then
						self._ecms[key].battery = battery
						self:_listener_callback("ecm", "set_battery", key, self._ecms[key])
					end
					
					if self._ecms[key].retrigger then
						self._ecms[key].retrigger_t = retrigger_t
						self:_listener_callback("ecm", "set_retrigger", key, self._ecms[key])
					end
				end
			end
		end
	end
	
	function GameInfoManager:_bag_deployable_event(event, key, ...)
		if event == "create" then
			if not self._deployables[key] then
				local unit, bag_type = ...
				self._deployables[key] = { unit = unit, type = bag_type }
				self:_listener_callback("bag_deployable", "create", key, self._deployables[key])
			end
		elseif self._deployables[key] then
			local function update_aggregate_attribute(aggregate_key, attr)
				if not self._deployables[aggregate_key] then return end
			
				local total = 0
				for k, v in pairs(self._deployables[aggregate_key].aggregate_members or {}) do
					if self._deployables[k].active then
						total = total + (self._deployables[k][attr] or 0)
					end
				end
				
				self._deployables[aggregate_key][attr] = total
				self:_listener_callback("bag_deployable", "set_" .. attr, aggregate_key, self._deployables[aggregate_key])
				printf("UPDATE AGGREGATE %s: %s", tostring(attr), tostring(total))
			end
			
			local aggregate_key = GameInfoManager._EQUIPMENT.AGGREAGATE_ITEMS[self._deployables[key].unit:editor_id()]
			--log(self._deployables[key].type .. " | " .. self._deployables[key].unit:editor_id())
			if event == "destroy" then
				self:_listener_callback("bag_deployable", "destroy", key, self._deployables[key])
				self._deployables[key] = nil
				
				if aggregate_key and self._deployables[aggregate_key] then
					self._deployables[aggregate_key].aggregate_members[key] = nil
					
					if next(self._deployables[aggregate_key].aggregate_members or {}) == nil then
						self:_listener_callback("bag_deployable", "destroy", aggregate_key, self._deployables[aggregate_key])
						self._deployables[aggregate_key] = nil
						--update_aggregate_attribute(aggregate_key, "amount")
						--update_aggregate_attribute(aggregate_key, "max_amount")
						--update_aggregate_attribute(aggregate_key, "amount_offset")
					end
				end
			elseif event == "set_active" then
				local active = ...
				
				if aggregate_key then
					self._deployables[key].aggregate_key = aggregate_key
				end
				
				if self._deployables[key].active ~= active then
					self._deployables[key].active = active
					self:_listener_callback("bag_deployable", "set_active", key, self._deployables[key])
				end
				
				if aggregate_key then
					self._deployables[aggregate_key] = self._deployables[aggregate_key] or {
						type = self._deployables[key].type, 
						position = self._deployables[key].unit:interaction():interact_position(),
						aggregate_members = {},
					}
					self._deployables[aggregate_key].aggregate_members[key] = true
					--TODO: Update position for each member added?
					
					local aggregate_active = false
					for k, v in pairs(self._deployables[aggregate_key].aggregate_members or {}) do
						if self._deployables[k].active then
							aggregate_active = true
							break
						end
					end
			
					if self._deployables[aggregate_key].active ~= aggregate_active then
						self._deployables[aggregate_key].active = aggregate_active
						self:_listener_callback("bag_deployable", "set_active", aggregate_key, self._deployables[aggregate_key])
					end
					
					update_aggregate_attribute(aggregate_key, "amount")
					update_aggregate_attribute(aggregate_key, "max_amount")
					update_aggregate_attribute(aggregate_key, "amount_offset")
				end
			elseif event == "set_owner" then
				local owner = ...
				self._deployables[key].owner = owner
				self:_listener_callback("bag_deployable", "set_owner", key, self._deployables[key])
					
				if aggregate_key then
					self._deployables[aggregate_key].owner = owner
					self:_listener_callback("bag_deployable", "set_owner", aggregate_key, self._deployables[aggregate_key])
				end
			elseif event == "set_max_amount" then
				local max_amount = ...
				self._deployables[key].max_amount = max_amount
				self:_listener_callback("bag_deployable", "set_max_amount", key, self._deployables[key])
				
				if aggregate_key then
					update_aggregate_attribute(aggregate_key, "max_amount")
				end
			elseif event == "set_amount_offset" then
				local amount_offset = ...
				self._deployables[key].amount_offset = amount_offset
				self:_listener_callback("bag_deployable", "set_amount_offset", key, self._deployables[key])
				
				if aggregate_key then
					update_aggregate_attribute(aggregate_key, "amount_offset")
				end
			elseif event == "set_amount" then
				local amount = ...
				self._deployables[key].amount = amount
				self:_listener_callback("bag_deployable", "set_amount", key, self._deployables[key])
				
				if aggregate_key then
					update_aggregate_attribute(aggregate_key, "amount")
				end
			end
		end
	end
	
	function GameInfoManager:_tape_loop_event(event, key, ...)
		if event == "start" then
			local unit, duration = ...
			self:_listener_callback("tape_loop", "start", key, unit, duration)
		elseif event == "stop" then
			self:_listener_callback("tape_loop", "stop", key)
		end
	end
	
	function GameInfoManager:_sentry_event(event, key, ...)
		printf("GameInfoManager:_sentry_event(%s, %s)", event, key)
		
		if event == "create" then
			if not self._sentries[key] then
				local unit = ...
				self._sentries[key] = { unit = unit }
				self:_listener_callback("sentry", "create", key, self._sentries[key])
			end
		elseif self._sentries[key] then
			if event == "destroy" then
				self._sentries[key].active = false
				self:_listener_callback("sentry", "set_active", key, self._sentries[key])
				self:_listener_callback("sentry", "destroy", key, self._sentries[key])
				self._sentries[key] = nil
			elseif event == "set_active" then
				local active = ...
				if self._sentries[key].active ~= active then
					self._sentries[key].active = active
					self:_listener_callback("sentry", "set_active", key, self._sentries[key])
				end
			elseif event == "set_ammo_ratio" then
				local ammo_ratio = ...
				self._sentries[key].ammo_ratio = ammo_ratio
				self:_listener_callback("sentry", "set_ammo_ratio", key, self._sentries[key])
			elseif event == "set_health_ratio" then
				local health_ratio = ...
				self._sentries[key].health_ratio = health_ratio
				self:_listener_callback("sentry", "set_health_ratio", key, self._sentries[key])
			elseif event == "set_owner" then
				local owner = ...
				self._sentries[key].owner = owner
				self:_listener_callback("sentry", "set_owner", key, self._sentries[key])
			end
		end
	end
	
	function GameInfoManager:_whisper_mode_event(event, key, status)
		self:_listener_callback("whisper_mode", "change", key, status)
	end
	
	function GameInfoManager:_temporary_buff_event(event, data)
		local buff_data = GameInfoManager._BUFFS[data.category][data.upgrade]
		local id = data.level and type(buff_data) == "table" and buff_data[data.level] or buff_data
		
		if id then
			self:_timed_buff_event(event, id, data)
			if data.value ~= 0 then
				self:_buff_event("set_value", id, { value = data.value })
			end
		else
			printf("Unknown temporary buff event: %s, %s, %s", event, data.category, data.upgrade)
		end
	end
	
	function GameInfoManager:_timed_buff_event(event, id, data)
		self:_buff_event(event, id, data)
		
		if event == "activate" then
			self:_buff_event("set_duration", id, { t = data.t, duration = data.duration, expire_t = data.expire_t })
			self:_add_player_timer_expiration(id, id, self._buffs[id].expire_t, self._timed_buff_expire_clbk)
		elseif event == "deactivate" then
			self:_remove_player_timer_expiration(id)
		end
	end
	
	function GameInfoManager:_timed_stack_buff_event(event, id, data)
		printf("GameInfoManager:_timed_stack_buff_event(%s, %s, %s)", tostring(event), tostring(id), tostring(data))
	
		if event == "add_stack" then
			if not self._buffs[id] then
				self:_buff_event("activate", id)
				self._buffs[id].stacks = {}
			end
			
			local t = data.t or Application:time()
			local expire_t = data.expire_t or data.duration and (data.duration + t) or t
			local key = string.format("%s_%f_%f", id, t, math.random())
			
			local i = #self._buffs[id].stacks
			while self._buffs[id].stacks[i] and self._buffs[id].stacks[i].expire_t > expire_t do
				i = i - 1
			end
			table.insert(self._buffs[id].stacks, i + 1, { key = key, t = t, expire_t = expire_t })
			self:_add_player_timer_expiration(key, id, expire_t, self._timed_stack_expire_clbk)
			
			self:_listener_callback("buff", "add_timed_stack", id, self._buffs[id])
		end
	end
	
	function GameInfoManager:_buff_event(event, id, data)
		printf("GameInfoManager:_buff_event(%s, %s)", event, id)
		
		if event == "activate" then
			if not self._buffs[id] then
				self._buffs[id] = data or {}
			else
				return
			end
		elseif self._buffs[id] then
			if event == "deactivate" then
				self._buffs[id] = nil
			elseif event == "set_duration" then
				local t = data.t or Application:time()
				local expire_t = data.expire_t or data.duration and (data.duration + t) or t
				self._buffs[id].t = t
				self._buffs[id].expire_t = expire_t
			elseif event == "set_stack_count" then
				self._buffs[id].stack_count = data.stack_count
			elseif event == "change_stack_count" then
				self._buffs[id].stack_count = (self._buffs[id].stack_count or 0) + data.difference
				event = "set_stack_count"
			elseif event == "set_progress" then
				self._buffs[id].progress = data.progress
			elseif event == "set_value" then
				self._buffs[id].show_value = data.show_value
				self._buffs[id].value = data.value
			end
		else
			return
		end

		self:_listener_callback("buff", event, id, self._buffs[id])
		
		local clbk_name = "on_" .. event
		if GameInfoManager._BUFFS[clbk_name] and GameInfoManager._BUFFS[clbk_name][id] then
			GameInfoManager._BUFFS[clbk_name][id](id, self._buffs[id])
		end
	end
	
	function GameInfoManager:_team_buff_event(event, data)
		local buff_data = GameInfoManager._BUFFS[data.category] and GameInfoManager._BUFFS[data.category][data.upgrade]
		local id = buff_data and buff_data.id
		local level = buff_data and buff_data.level
		
		if id then
			if event == "activate" then
				local was_active = self._buffs[id]
				
				if not was_active then
					self:_buff_event("activate", id)
					self._buffs[id].peers = {}
					self._buffs[id].level = level
				end
				
				if not self._buffs[id].peers[data.peer] then
					self._buffs[id].peers[data.peer] = true
					self:_buff_event("change_stack_count", id, { difference = 1 })
				end
				
				if not was_active and data.value ~= 0 then
					self:_buff_event("set_value", id, { value = data.value })
				end
			elseif event == "deactivate" then
				if self._buffs[id] and self._buffs[id].peers[data.peer] then
					self._buffs[id].peers[data.peer] = nil
					self:_buff_event("change_stack_count", id, { difference = -1 })
					
					if next(self._buffs[id].peers) == nil then
						self:_buff_event("deactivate", id)
					end
				end
			end
		else
			printf("Unknown team buff event: %s, %s, %s", event, data.category, data.upgrade)
		end
	end
	
	function GameInfoManager:_player_action_event(event, id, data)
		printf("GameInfoManager:_player_action_event(%s, %s)", event, id)
	
		if event == "activate" then
			if not self._player_actions[id] then
				self._player_actions[id] = {}
				self:_listener_callback("player_action", "activate", id, self._player_actions[id])
			end
			
			if data and (data.duration or data.expire_t) then
				self:_player_action_event("set_duration", id, data)
				self:_add_player_timer_expiration(id, id, self._player_actions[id].expire_t, self._player_actions_expire_clbk)
			end
		elseif self._player_actions[id] then
			if event == "deactivate" then
				self:_remove_player_timer_expiration(id)
				self._player_actions[id] = nil
			elseif event == "set_duration" then
				local t = data.t or Application:time()
				local expire_t = data.expire_t or data.duration and (data.duration + t) or t
				self._player_actions[id].t = t
				self._player_actions[id].expire_t = expire_t
			elseif event == "set_data" then
				self._player_actions[id].data = data
			end
			
			self:_listener_callback("player_action", event, id, self._player_actions[id])
		end
	end
	
	
	function GameInfoManager:register_listener(listener_id, source_type, event, clbk)
		self._listeners[source_type] = self._listeners[source_type] or {}
		self._listeners[source_type][event] = self._listeners[source_type][event] or {}
		self._listeners[source_type][event][listener_id] = clbk
	end
	
	function GameInfoManager:unregister_listener(listener_id, source_type, event)
		if self._listeners[source_type] then
			if self._listeners[source_type][event] then
				self._listeners[source_type][event][listener_id] = nil
			end
		end
	end
	
	function GameInfoManager:_listener_callback(source, event, key, ...)
		for listener_id, clbk in pairs(self._listeners[source] and self._listeners[source][event] or {}) do
			clbk(event, key, ...)
		end
	end
	
	function GameInfoManager:_add_player_timer_expiration(key, id, expire_t, expire_clbk)
		if self._auto_expire_timers.on_expire[key] then
			self:_remove_player_timer_expiration(key)
		end
		
		local expire_data = { key = key, id = id, expire_t = expire_t }
		local t_size = #self._auto_expire_timers.expire_t
		
		if (t_size <= 0) or (expire_t >= self._auto_expire_timers.expire_t[t_size].expire_t) then
			table.insert(self._auto_expire_timers.expire_t, expire_data)
		else
			for i = 1, t_size, 1 do
				if expire_t < self._auto_expire_timers.expire_t[i].expire_t then
					table.insert(self._auto_expire_timers.expire_t, i, expire_data)
					break
				end
			end
		end
		
		self._auto_expire_timers.on_expire[key] = expire_clbk
	end
	
	function GameInfoManager:_remove_player_timer_expiration(key)
		if self._auto_expire_timers.on_expire[key] then
			for i, data in ipairs(self._auto_expire_timers.expire_t) do
				if data.key == key then
					table.remove(self._auto_expire_timers.expire_t, i)
					break
				end
			end
			
			self._auto_expire_timers.on_expire[key] = nil
		end
	end
	
	function GameInfoManager:_update_player_timer_expiration(ut, udt)
		local t = Application:time()
		local dt = t - self._t
		self._t = t
		
		printf("_update_player_timer_expiration: %f - %f / %f - %f\n", ut, udt, t, dt)
	
		while self._auto_expire_timers.expire_t[1] and self._auto_expire_timers.expire_t[1].expire_t < t do
			local data = self._auto_expire_timers.expire_t[1]
			local id = data.id
			local key = data.key
			self._auto_expire_timers.on_expire[key](t, key, id)
			self:_remove_player_timer_expiration(key)
		end
	end
	
	function GameInfoManager:_on_timed_buff_expired(t, key, id)
		self:_buff_event("deactivate", id)
	end
	
	function GameInfoManager:_on_timed_stack_expired(t, key, id)
		if self._buffs[id].stacks[1] then
			table.remove(self._buffs[id].stacks, 1)
			self:_listener_callback("buff", "remove_timed_stack", id, self._buffs[id])
			
			if #self._buffs[id].stacks <= 0 then
				self:_buff_event("deactivate", id)
			end
		end
	end
	
	function GameInfoManager:_on_player_action_expired(t, key, id)
		self:_player_action_event("deactivate", id)
	end
	
end

if RequiredScript == "lib/units/props/digitalgui" then
	
	local init_original = DigitalGui.init
	local update_original = DigitalGui.update
	local timer_set_original = DigitalGui.timer_set
	local timer_start_count_up_original = DigitalGui.timer_start_count_up
	local timer_start_count_down_original = DigitalGui.timer_start_count_down
	local timer_pause_original = DigitalGui.timer_pause
	local timer_resume_original = DigitalGui.timer_resume
	local _timer_stop_original = DigitalGui._timer_stop
	local load_original = DigitalGui.load
	local destroy_original = DigitalGui.destroy
	
	function DigitalGui:init(unit, ...)
		self._info_key = tostring(unit:key())
		self._ignore = self.TYPE == "number"	--Maybe need move to after init?
		return init_original(self, unit, ...)
	end
	
	function DigitalGui:update(unit, t, ...)
		update_original(self, unit, t, ...)
		self:_do_timer_callback("update", t, self._timer)
	end
	
	function DigitalGui:timer_set(timer, ...)
		if not self._info_created and Network:is_server() then
			self._info_created = true
			self:_do_timer_callback("create", self._unit, self, "digital")
		end
		self:_do_timer_callback("set", timer)
		return timer_set_original(self, timer, ...)
	end
	
	function DigitalGui:timer_start_count_up(...)
		self:_do_timer_callback("start_count_up")
		return timer_start_count_up_original(self, ...)
	end
	
	function DigitalGui:timer_start_count_down(...)
		self:_do_timer_callback("start_count_down")
		return timer_start_count_down_original(self, ...)
	end
	
	function DigitalGui:timer_pause(...)
		self:_do_timer_callback("pause")
		return timer_pause_original(self, ...)
	end
	
	function DigitalGui:timer_resume(...)
		self:_do_timer_callback("resume")
		return timer_resume_original(self, ...)
	end
	
	function DigitalGui:_timer_stop(...)
		self:_do_timer_callback("stop")
		return _timer_stop_original(self, ...)
	end
	
	function DigitalGui:load(data, ...)
		self:_do_timer_callback("create", self._unit, self, "digital")
	
		load_original(self, data, ...)
		
		local state = data.DigitalGui
		if state.timer then
			self:_do_timer_callback("set", state.timer)
		end
		if state.timer_count_up then
			self:_do_timer_callback("start_count_up")
		end
		if state.timer_count_down then
			self:_do_timer_callback("start_count_down")
		end
		if state.timer_paused then
			self:_do_timer_callback("pause")
		end
	end
	
	function DigitalGui:destroy(...)
		self:_do_timer_callback("destroy")
		return destroy_original(self, ...)
	end
	
	
	function DigitalGui:_do_timer_callback(event, ...)
		if not self._ignore then
			managers.gameinfo:event("timer", event, self._info_key, ...)
		end
	end
	
end

if RequiredScript == "lib/units/props/timergui" then
	
	local init_original = TimerGui.init
	local set_background_icons_original = TimerGui.set_background_icons
	local set_visible_original = TimerGui.set_visible
	local update_original = TimerGui.update
	local _start_original = TimerGui._start
	local _set_done_original = TimerGui._set_done
	local _set_jammed_original = TimerGui._set_jammed
	local _set_powered = TimerGui._set_powered
	local destroy_original = TimerGui.destroy
	
	function TimerGui:init(unit, ...)
		self._info_key = tostring(unit:key())
		local device_type = unit:base().is_drill and "drill" or unit:base().is_hacking_device and "hack" or unit:base().is_saw and "saw" or "timer"
		managers.gameinfo:event("timer", "create", self._info_key, unit, self, device_type)
		init_original(self, unit, ...)
	end
	
	function TimerGui:set_background_icons(...)
		local skills = self._unit:base().get_skill_upgrades and self._unit:base():get_skill_upgrades()
		local interact_ext = self._unit:interaction()
		local can_upgrade = false
		local pinfo = interact_ext and interact_ext.get_player_info_id and interact_ext:get_player_info_id()
		if skills and interact_ext and pinfo then
			for i, _ in pairs(interact_ext:split_info_id(pinfo)) do
				if not skills[i] then
					can_upgrade = true
					break
				end
			end
		end
		
		managers.gameinfo:event("timer", "set_upgradable", self._info_key, can_upgrade)
		
		return set_background_icons_original(self, ...)
	end
	
	function TimerGui:set_visible(visible, ...)
		if not visible and self._unit:base().is_drill then
			managers.gameinfo:event("timer", "set_active", self._info_key, false)
		end
		return set_visible_original(self, visible, ...)
	end
	
	function TimerGui:update(unit, t, dt, ...)
		update_original(self, unit, t, dt, ...)
		managers.gameinfo:event("timer", "update", self._info_key, t, self._time_left)
	end
	
	function TimerGui:_start(...)
		managers.gameinfo:event("timer", "set_active", self._info_key, true)
		return _start_original(self, ...)
	end
	
	function TimerGui:_set_done(...)
		managers.gameinfo:event("timer", "set_active", self._info_key, false)
		return _set_done_original(self, ...)
	end
	
	function TimerGui:_set_jammed(jammed, ...)
		managers.gameinfo:event("timer", "set_jammed", self._info_key, jammed and true or false)
		return _set_jammed_original(self, jammed, ...)
	end
	
	function TimerGui:_set_powered(powered, ...)
		managers.gameinfo:event("timer", "set_powered", self._info_key, powered and true or false)
		return _set_powered(self, powered, ...)
	end
	
	function TimerGui:destroy(...)
		managers.gameinfo:event("timer", "destroy", self._info_key)
		return destroy_original(self, ...)
	end
	
end

if RequiredScript == "lib/units/props/securitylockgui" then
	
	local init_original = SecurityLockGui.init
	local update_original = SecurityLockGui.update
	local _start_original = SecurityLockGui._start
	local _set_done_original = SecurityLockGui._set_done
	local _set_jammed_original = SecurityLockGui._set_jammed
	local _set_powered = SecurityLockGui._set_powered
	local destroy_original = SecurityLockGui.destroy
	
	function SecurityLockGui:init(unit, ...)
		self._info_key = tostring(unit:key())
		managers.gameinfo:event("timer", "create", self._info_key, unit, self, "securitylock")
		init_original(self, unit, ...)
	end
	
	function SecurityLockGui:update(unit, t, ...)
		update_original(self, unit, t, ...)
		managers.gameinfo:event("timer", "update", self._info_key, t, self._current_timer)
	end
	
	function SecurityLockGui:_start(...)
		managers.gameinfo:event("timer", "set_active", self._info_key, true)
		return _start_original(self, ...)
	end
	
	function SecurityLockGui:_set_done(...)
		managers.gameinfo:event("timer", "set_active", self._info_key, false)
		return _set_done_original(self, ...)
	end
	
	function SecurityLockGui:_set_jammed(jammed, ...)
		managers.gameinfo:event("timer", "set_jammed", self._info_key, jammed and true or false)
		return _set_jammed_original(self, jammed, ...)
	end
	
	function SecurityLockGui:_set_powered(powered, ...)
		managers.gameinfo:event("timer", "set_powered", self._info_key, powered and true or false)
		return _set_powered(self, powered, ...)
	end
	
	function SecurityLockGui:destroy(...)
		managers.gameinfo:event("timer", "destroy", self._info_key)
		return destroy_original(self, ...)
	end
	
end

if RequiredScript == "lib/managers/enemymanager" then
	
	local on_enemy_registered_original = EnemyManager.on_enemy_registered
	local on_enemy_unregistered_original = EnemyManager.on_enemy_unregistered
	local register_civilian_original = EnemyManager.register_civilian
	local on_civilian_died_original = EnemyManager.on_civilian_died
	local on_civilian_destroyed_original = EnemyManager.on_civilian_destroyed
	
	function EnemyManager:on_enemy_registered(unit, ...)
		managers.gameinfo:event("unit", "add", tostring(unit:key()), unit, unit:base()._tweak_table)
		return on_enemy_registered_original(self, unit, ...)
	end
	
	function EnemyManager:on_enemy_unregistered(unit, ...)
		managers.gameinfo:event("unit", "remove", tostring(unit:key()))
		return on_enemy_unregistered_original(self, unit, ...)
	end
	
	function EnemyManager:register_civilian(unit, ...)
		managers.gameinfo:event("unit", "add", tostring(unit:key()), unit, unit:base()._tweak_table)
		return register_civilian_original(self, unit, ...)
	end
	
	function EnemyManager:on_civilian_died(unit, ...)
		managers.gameinfo:event("unit", "remove", tostring(unit:key()))
		return on_civilian_died_original(self, unit, ...)
	end
	
	function EnemyManager:on_civilian_destroyed(unit, ...)
		managers.gameinfo:event("unit", "remove", tostring(unit:key()))
		return on_civilian_destroyed_original(self, unit, ...)
	end
	
end

if RequiredScript == "lib/managers/group_ai_states/groupaistatebase" then
	
	local register_turret_original = GroupAIStateBase.register_turret
	local unregister_turret_original = GroupAIStateBase.unregister_turret
	local update_original = GroupAIStateBase.update
	local on_hostage_state_original = GroupAIStateBase.on_hostage_state
	local sync_hostage_headcount_original = GroupAIStateBase.sync_hostage_headcount
	local convert_hostage_to_criminal_original = GroupAIStateBase.convert_hostage_to_criminal
	local sync_converted_enemy_original = GroupAIStateBase.sync_converted_enemy
	local set_whisper_mode_original = GroupAIStateBase.set_whisper_mode
	
	function GroupAIStateBase:register_turret(unit, ...)
		managers.gameinfo:event("turret", "add", tostring(unit:key()), unit)
		return register_turret_original(self, unit, ...)
	end
	
	function GroupAIStateBase:unregister_turret(unit, ...)
		managers.gameinfo:event("turret", "remove", tostring(unit:key()), unit)
		return unregister_turret_original(self, unit, ...)
	end
	
	function GroupAIStateBase:update(t, ...)
		if self._client_hostage_count_expire_t and t < self._client_hostage_count_expire_t then
			self:_client_hostage_count_cbk()
		end
		
		return update_original(self, t, ...)
	end
	
	function GroupAIStateBase:on_hostage_state(...)
		on_hostage_state_original(self, ...)
		self:_update_hostage_count()
	end
	
	function GroupAIStateBase:sync_hostage_headcount(...)
		sync_hostage_headcount_original(self, ...)
		
		if Network:is_server() then
			self:_update_hostage_count()
		else
			self._client_hostage_count_expire_t = self._t + 10
		end
	end
	
	function GroupAIStateBase:convert_hostage_to_criminal(unit, peer_unit, ...)
		convert_hostage_to_criminal_original(self, unit, peer_unit, ...)
		
		if unit:brain()._logic_data.is_converted then
			local peer_id = peer_unit and managers.network:session():peer_by_unit(peer_unit):id() or managers.network:session():local_peer():id()
			local owner_base = peer_unit and peer_unit:base() or managers.player
			
			local health_mult = 1
			local damage_mult = 1
			local joker_level = (owner_base:upgrade_level("player", "convert_enemies_health_multiplier", 0) or 0)
			local partner_in_crime_level = owner_base:upgrade_level("player", "passive_convert_enemies_health_multiplier", 0) or 0
			if joker_level > 0 then
				health_mult = health_mult * managers.player:upgrade_value_by_level("player", "convert_enemies_health_multiplier", joker_level, 1)
				damage_mult = damage_mult * managers.player:upgrade_value_by_level("player", "convert_enemies_damage_multiplier", joker_level, 1)
			end
			if partner_in_crime_level > 0 then
				health_mult = health_mult * managers.player:upgrade_value_by_level("player", "passive_convert_enemies_health_multiplier", partner_in_crime_level, 1)
			end
			
			managers.gameinfo:event("minion", "add", tostring(unit:key()), unit, peer_id, health_mult, damage_mult)
		end
	end
	
	function GroupAIStateBase:sync_converted_enemy(converted_enemy, ...)
		sync_converted_enemy_original(self, converted_enemy, ...)
		managers.gameinfo:event("minion", "add", tostring(converted_enemy:key()), converted_enemy)
	end
	
	function GroupAIStateBase:set_whisper_mode(enabled, ...)
		if self._whisper_mode ~= enabled then
			managers.gameinfo:event("whisper_mode", "change", nil, enabled)
		end
		set_whisper_mode_original(self, enabled, ...)
	end
	
	
	function GroupAIStateBase:_client_hostage_count_cbk()
		local police_hostages = 0
		local civilian_hostages = self._hostage_headcount
	
		for u_key, u_data in pairs(managers.enemy:all_enemies()) do
			if u_data and u_data.unit and u_data.unit.anim_data and u_data.unit:anim_data() then
				if u_data.unit:anim_data().surrender then
					police_hostages = police_hostages + 1
				end
			end
		end
		
		civilian_hostages = civilian_hostages - police_hostages
		managers.gameinfo:event("unit_count", "set", "civ_hostage", civilian_hostages)
		managers.gameinfo:event("unit_count", "set", "cop_hostage", police_hostages)
	end
	
	function GroupAIStateBase:_update_hostage_count()
		if Network:is_server() then
			managers.gameinfo:event("unit_count", "set", "civ_hostage", self._hostage_headcount - self._police_hostage_headcount)
			managers.gameinfo:event("unit_count", "set", "cop_hostage", self._police_hostage_headcount)
		else
			self:_client_hostage_count_cbk()
		end
	end
	
end

if RequiredScript == "lib/network/handlers/unitnetworkhandler" then
	
	local mark_minion_original = UnitNetworkHandler.mark_minion
	local hostage_trade_original = UnitNetworkHandler.hostage_trade
	local unit_traded_original = UnitNetworkHandler.unit_traded
	local interaction_set_active_original = UnitNetworkHandler.interaction_set_active
	local alarm_pager_interaction_original = UnitNetworkHandler.alarm_pager_interaction
	
	function UnitNetworkHandler:mark_minion(unit, owner_id, joker_level, partner_in_crime_level, ...)
		mark_minion_original(self, unit, owner_id, joker_level, partner_in_crime_level, ...)
		
		if self._verify_character(unit) then
			local health_mult = 1
			local damage_mult = 1
			if joker_level > 0 then
				health_mult = health_mult * managers.player:upgrade_value_by_level("player", "convert_enemies_health_multiplier", joker_level, 1)
				damage_mult = damage_mult * managers.player:upgrade_value_by_level("player", "convert_enemies_damage_multiplier", joker_level, 1)
			end
			if partner_in_crime_level > 0 then
				health_mult = health_mult * managers.player:upgrade_value_by_level("player", "passive_convert_enemies_health_multiplier", partner_in_crime_level, 1)
			end
			
			managers.gameinfo:event("minion", "add", tostring(unit:key()), unit, owner_id, health_mult, damage_mult)
		end
	end
	
	function UnitNetworkHandler:hostage_trade(unit, ...)
		if self._verify_gamestate(self._gamestate_filter.any_ingame) and self._verify_character(unit) then
			managers.gameinfo:event("minion", "remove", tostring(unit:key()))
		end
		
		return hostage_trade_original(self, unit, ...)
	end
	
	function UnitNetworkHandler:unit_traded(unit, trader, ...)
		if self._verify_gamestate(self._gamestate_filter.any_ingame) and self._verify_character(unit) then
			managers.gameinfo:event("minion", "remove", tostring(unit:key()))
		end
		
		return unit_traded_original(self, unit, trader, ...)
	end
	
	function UnitNetworkHandler:interaction_set_active(unit, u_id, active, tweak_data, flash, sender, ...)
		if self._verify_gamestate(self._gamestate_filter.any_ingame) and self._verify_sender(sender) then
			if tweak_data == "corpse_alarm_pager" then
				if not alive(unit) then
					local u_data = managers.enemy:get_corpse_unit_data_from_id(u_id)
					if not u_data then return end
					unit = u_data and u_data.unit
				end
				
				if not active then
					managers.gameinfo:event("pager", "remove", tostring(unit:key()))
				elseif not flash then
					managers.gameinfo:event("pager", "answered", tostring(unit:key()))
				end
			end
		end

		return interaction_set_active_original(self, unit, u_id, active, tweak_data, flash, sender, ...)
	end
	
	function UnitNetworkHandler:alarm_pager_interaction(u_id, tweak_table, status, sender, ...)
		if self._verify_gamestate(self._gamestate_filter.any_ingame) then
			local unit_data = managers.enemy:get_corpse_unit_data_from_id(u_id)
			if unit_data and unit_data.unit:interaction():active() and unit_data.unit:interaction().tweak_data == tweak_table and self._verify_sender(sender) then
				if status == 1 then
					managers.gameinfo:event("pager", "answered", tostring(unit_data.unit:key()))
				else
					managers.gameinfo:event("pager", "remove", tostring(unit_data.unit:key()))
				end
			end
		end
	
		return alarm_pager_interaction_original(self, u_id, tweak_table, status, sender, ...)
	end
	
end

if RequiredScript == "lib/units/enemies/cop/copdamage" then
	
	local _on_damage_received_original = CopDamage._on_damage_received
	local chk_killshot_original = CopDamage.chk_killshot
	
	function CopDamage:_on_damage_received(damage_info, ...)
		if self._unit:in_slot(16) then
			managers.gameinfo:event("minion", "set_health", tostring(self._unit:key()), self._health)
		end
		return _on_damage_received_original(self, damage_info, ...)
	end
	
	function CopDamage:chk_killshot(attacker_unit, ...)
		if alive(attacker_unit) and managers.gameinfo:get_minions(tostring(attacker_unit:key())) then
			managers.gameinfo:event("minion", "increment_kills", tostring(attacker_unit:key()))
		end
		
		return chk_killshot_original(self, attacker_unit, ...)
	end
	
end

if RequiredScript == "lib/managers/objectinteractionmanager" then
	
	local init_original = ObjectInteractionManager.init
	local update_original = ObjectInteractionManager.update
	local add_unit_original = ObjectInteractionManager.add_unit
	local remove_unit_original = ObjectInteractionManager.remove_unit
	local interact_original = ObjectInteractionManager.interact
	local interupt_action_interact_original = ObjectInteractionManager.interupt_action_interact
	
	function ObjectInteractionManager:init(...)
		init_original(self, ...)
		self._queued_units = {}
	end
	
	function ObjectInteractionManager:update(t, ...)
		update_original(self, t, ...)
		self:_process_queued_units(t)
	end
	
	function ObjectInteractionManager:add_unit(unit, ...)
		self:add_unit_clbk(unit)
		return add_unit_original(self, unit, ...)
	end
	
	function ObjectInteractionManager:remove_unit(unit, ...)
		self:remove_unit_clbk(unit)
		return remove_unit_original(self, unit, ...)
	end
	
	function ObjectInteractionManager:interact(...)
		if alive(self._active_unit) and self._active_unit:interaction().tweak_data == "corpse_alarm_pager" then
			managers.gameinfo:event("pager", "answered", tostring(self._active_unit:key()))
		end
		
		return interact_original(self, ...)
	end
	
	function ObjectInteractionManager:interupt_action_interact(...)
		if alive(self._active_unit) and self._active_unit:interaction() and self._active_unit:interaction().tweak_data == "corpse_alarm_pager" then
			managers.gameinfo:event("pager", "remove", tostring(self._active_unit:key()))
		end
		
		return interupt_action_interact_original(self, ...)
	end
	
	
	function ObjectInteractionManager:add_unit_clbk(unit)
		self._queued_units[tostring(unit:key())] = unit
	end
	
	function ObjectInteractionManager:remove_unit_clbk(unit)
		local key = tostring(unit:key())
		
		if self._queued_units[key] then
			self._queued_units[key] = nil
		else
			managers.gameinfo:event("interactive_unit", "remove", key, unit)
		end
	end
	
	function ObjectInteractionManager:_process_queued_units(t)
		for key, unit in pairs(self._queued_units) do
			if alive(unit) then
				managers.gameinfo:event("interactive_unit", "add", key, unit)
			end
		end
	
		self._queued_units = {}
	end
	
end

if RequiredScript == "lib/units/interactions/interactionext" then
	
	local set_tweak_data_original = BaseInteractionExt.set_tweak_data
	
	function BaseInteractionExt:set_tweak_data(...)
		if self:active() then
			managers.interaction:remove_unit_clbk(self._unit)
		end
		
		set_tweak_data_original(self, ...)
		
		if self:active() then
			managers.interaction:add_unit_clbk(self._unit)
		end
	end
	
end

if RequiredScript == "lib/units/equipment/ecm_jammer/ecmjammerbase" then
	
	local init_original = ECMJammerBase.init
	local set_active_original = ECMJammerBase.set_active
	local _set_feedback_active_original = ECMJammerBase._set_feedback_active
	local update_original = ECMJammerBase.update
	local _send_net_event_original = ECMJammerBase._send_net_event
	local sync_net_event_original = ECMJammerBase.sync_net_event
	local destroy_original = ECMJammerBase.destroy
	
	function ECMJammerBase:init(...)
		init_original(self, ...)
		managers.gameinfo:event("ecm", "create", tostring(self._unit:key()), self._unit)
	end
	
	function ECMJammerBase:set_active(active, ...)
		managers.gameinfo:event("ecm", "set_jammer_active", tostring(self._unit:key()), active)
		return set_active_original(self, active, ...)
	end
	
	function ECMJammerBase:_set_feedback_active(state, ...)
		if not state then
			local peer_id = managers.network:session() and managers.network:session():local_peer() and managers.network:session():local_peer():id()
			if peer_id and (peer_id == self._owner_id) and managers.player:has_category_upgrade("ecm_jammer", "can_retrigger") then
				self._feedback_recharge_t = tweak_data.upgrades.ecm_feedback_retrigger_interval or 60
				managers.gameinfo:event("ecm", "set_retrigger_active", tostring(self._unit:key()), true)
			end
		end
	
		return _set_feedback_active_original(self, state, ...)
	end
	
	function ECMJammerBase:update(unit, t, dt, ...)
		update_original(self, unit, t, dt, ...)
		
		if self._chk_feedback_retrigger_t then
			self._feedback_recharge_t = self._chk_feedback_retrigger_t
		elseif self._feedback_recharge_t then
			self._feedback_recharge_t = self._feedback_recharge_t - dt
		end
			
		if self._feedback_recharge_t or self._jammer_active then
			managers.gameinfo:event("ecm", "update", tostring(self._unit:key()), self._battery_life or 0, self._feedback_recharge_t or 0)
		end
	end
	
	function ECMJammerBase:_send_net_event(event_id, ...)
		if event_id == self._NET_EVENTS.feedback_restart then
			self._feedback_recharge_t = nil
			managers.gameinfo:event("ecm", "set_retrigger_active", tostring(self._unit:key()), false)
		end
		
		return _send_net_event_original(self, event_id, ...)
	end
	
	function ECMJammerBase:sync_net_event(event_id, ...)
		if event_id == self._NET_EVENTS.feedback_restart then
			self._feedback_recharge_t = nil
			managers.gameinfo:event("ecm", "set_retrigger_active", tostring(self._unit:key()), false)
		end
		
		return sync_net_event_original(self, event_id, ...)
	end
	
	function ECMJammerBase:destroy(...)
		managers.gameinfo:event("ecm", "set_jammer_active", tostring(self._unit:key()), false)
		managers.gameinfo:event("ecm", "set_retrigger_active", tostring(self._unit:key()), false)
		managers.gameinfo:event("ecm", "destroy", tostring(self._unit:key()))
		destroy_original(self, ...)
	end
	
end

if RequiredScript == "lib/units/equipment/doctor_bag/doctorbagbase" then
	
	local spawn_original = DoctorBagBase.spawn
	local init_original = DoctorBagBase.init
	local sync_setup_original = DoctorBagBase.sync_setup
	local _set_visual_stage_original = DoctorBagBase._set_visual_stage
	local destroy_original = DoctorBagBase.destroy
	
	function DoctorBagBase.spawn(pos, rot, amount_upgrade_lvl, peer_id, ...)
		local unit = spawn_original(pos, rot, amount_upgrade_lvl, peer_id, ...)
		local key = tostring(unit:key())
		managers.gameinfo:event("bag_deployable", "create", key, unit, "doc_bag")
		managers.gameinfo:event("bag_deployable", "set_owner", key, peer_id)
		return unit
	end
	
	function DoctorBagBase:init(unit, ...)
		local key = tostring(unit:key())
		managers.gameinfo:event("bag_deployable", "create", key, unit, "doc_bag")
		init_original(self, unit, ...)
		managers.gameinfo:event("bag_deployable", "set_max_amount", key, self._max_amount)
	end
	
	function DoctorBagBase:sync_setup(amount_upgrade_lvl, peer_id, ...)
		managers.gameinfo:event("bag_deployable", "set_owner", tostring(self._unit:key()), peer_id)
		return sync_setup_original(self, amount_upgrade_lvl, peer_id, ...)
	end
	
	function DoctorBagBase:_set_visual_stage(...)
		managers.gameinfo:event("bag_deployable", "set_amount", tostring(self._unit:key()), self._amount)
		return _set_visual_stage_original(self, ...)
	end
	
	function DoctorBagBase:destroy(...)
		managers.gameinfo:event("bag_deployable", "destroy", tostring(self._unit:key()))
		return destroy_original(self, ...)
	end
	
end

if RequiredScript == "lib/units/equipment/ammo_bag/ammobagbase" then
	
	local spawn_original = AmmoBagBase.spawn
	local init_original = AmmoBagBase.init
	local sync_setup_original = AmmoBagBase.sync_setup
	local _set_visual_stage_original = AmmoBagBase._set_visual_stage
	local destroy_original = AmmoBagBase.destroy
	
	function AmmoBagBase.spawn(pos, rot, ammo_upgrade_lvl, peer_id, ...)
		local unit = spawn_original(pos, rot, ammo_upgrade_lvl, peer_id, ...)
		local key = tostring(unit:key())
		managers.gameinfo:event("bag_deployable", "create", key, unit, "ammo_bag")
		managers.gameinfo:event("bag_deployable", "set_owner", key, peer_id)
		return unit
	end
	
	function AmmoBagBase:init(unit, ...)
		local key = tostring(unit:key())
		managers.gameinfo:event("bag_deployable", "create", key, unit, "ammo_bag")
		init_original(self, unit, ...)
		managers.gameinfo:event("bag_deployable", "set_max_amount", key, self._max_ammo_amount * 100)
	end
	
	function AmmoBagBase:sync_setup(ammo_upgrade_lvl, peer_id, ...)
		managers.gameinfo:event("bag_deployable", "set_owner", tostring(self._unit:key()), peer_id)
		return sync_setup_original(self, ammo_upgrade_lvl, peer_id, ...)
	end
	
	function AmmoBagBase:_set_visual_stage(...)
		managers.gameinfo:event("bag_deployable", "set_amount", tostring(self._unit:key()), self._ammo_amount * 100)
		return _set_visual_stage_original(self, ...)
	end
	
	function AmmoBagBase:destroy(...)
		managers.gameinfo:event("bag_deployable", "destroy", tostring(self._unit:key()))
		return destroy_original(self, ...)
	end
	
end

if RequiredScript == "lib/units/equipment/bodybags_bag/bodybagsbagbase" then
	
	local spawn_original = BodyBagsBagBase.spawn
	local init_original = BodyBagsBagBase.init
	local sync_setup_original = BodyBagsBagBase.sync_setup
	local _set_visual_stage_original = BodyBagsBagBase._set_visual_stage
	local destroy_original = BodyBagsBagBase.destroy
	
	function BodyBagsBagBase.spawn(pos, rot, upgrade_lvl, peer_id, ...)
		local unit = spawn_original(pos, rot, upgrade_lvl, peer_id, ...)
		local key = tostring(unit:key())
		managers.gameinfo:event("bag_deployable", "create", key, unit, "body_bag")
		managers.gameinfo:event("bag_deployable", "set_owner", key, peer_id)
		return unit
	end
	
	function BodyBagsBagBase:init(unit, ...)
		local key = tostring(unit:key())
		managers.gameinfo:event("bag_deployable", "create", key, unit, "body_bag")
		init_original(self, unit, ...)
		managers.gameinfo:event("bag_deployable", "set_max_amount", key, self._max_bodybag_amount)
	end
	
	function BodyBagsBagBase:sync_setup(upgrade_lvl, peer_id, ...)
		managers.gameinfo:event("bag_deployable", "set_owner", tostring(self._unit:key()), peer_id)
		return sync_setup_original(self, upgrade_lvl, peer_id, ...)
	end
	
	function BodyBagsBagBase:_set_visual_stage(...)
		managers.gameinfo:event("bag_deployable", "set_amount", tostring(self._unit:key()), self._bodybag_amount)
		return _set_visual_stage_original(self, ...)
	end
	
	function BodyBagsBagBase:destroy(...)
		managers.gameinfo:event("bag_deployable", "destroy", tostring(self._unit:key()))
		return destroy_original(self, ...)
	end
	
end

if RequiredScript == "lib/units/equipment/grenade_crate/grenadecratebase" then
	
	local init_original = GrenadeCrateBase.init
	local _set_visual_stage_original = GrenadeCrateBase._set_visual_stage
	local destroy_original = GrenadeCrateBase.destroy
	local custom_init_original = CustomGrenadeCrateBase.init
	
	function GrenadeCrateBase:init(unit, ...)
		local key = tostring(unit:key())
		managers.gameinfo:event("bag_deployable", "create", key, unit, "grenade_crate")
		init_original(self, unit, ...)
		managers.gameinfo:event("bag_deployable", "set_max_amount", key, self._max_grenade_amount)
	end
	
	function GrenadeCrateBase:_set_visual_stage(...)
		managers.gameinfo:event("bag_deployable", "set_amount", tostring(self._unit:key()), self._grenade_amount)
		return _set_visual_stage_original(self, ...)
	end
	
	function GrenadeCrateBase:destroy(...)
		managers.gameinfo:event("bag_deployable", "destroy", tostring(self._unit:key()))
		return destroy_original(self, ...)
	end
	
	function CustomGrenadeCrateBase:init(unit, ...)
		local key = tostring(unit:key())
		managers.gameinfo:event("bag_deployable", "create", key, unit, "grenade_crate", true)
		custom_init_original(self, unit, ...)
		managers.gameinfo:event("bag_deployable", "set_max_amount", key, self._max_grenade_amount)
	end
	
end

if RequiredScript == "lib/units/props/securitycamera" then
	
	local _start_tape_loop_original = SecurityCamera._start_tape_loop
	local _deactivate_tape_loop_original = SecurityCamera._deactivate_tape_loop
	local init_original = SecurityCamera.init
	local on_unit_set_enabled_original = SecurityCamera.on_unit_set_enabled
	local set_update_enabled_original = SecurityCamera.set_update_enabled
	local destroy_original = SecurityCamera.destroy
	
	function SecurityCamera:_start_tape_loop(tape_loop_t, ...)
		managers.gameinfo:event("tape_loop", "start", tostring(self._unit:key()), self._unit, tape_loop_t + 6)
		return _start_tape_loop_original(self, tape_loop_t, ...)
	end
	
	function SecurityCamera:_deactivate_tape_loop(...)
		managers.gameinfo:event("tape_loop", "stop", tostring(self._unit:key()))
		managers.gameinfo:event("camera", "disable", tostring(self._unit:key()))
		return _deactivate_tape_loop_original(self, ...)
	end
	
	function SecurityCamera:init(unit)
		managers.gameinfo:event("camera", "add", tostring(unit:key()), unit)
		return init_original(self, unit)
	end
	

	function SecurityCamera:on_unit_set_enabled(enabled)
		if enabled then
			managers.gameinfo:event("camera", "enable", tostring(self._unit:key()))
		else
			managers.gameinfo:event("camera", "disable", tostring(self._unit:key()))
		end
	end
	
	function SecurityCamera:set_update_enabled(state)
		if state then
			managers.gameinfo:event("camera", "enable", tostring(self._unit:key()))
		else
			managers.gameinfo:event("camera", "disable", tostring(self._unit:key()))
		end
		return set_update_enabled_original(self, state)
	end
	
	function SecurityCamera:destroy(unit)
		managers.gameinfo:event("camera", "destroy", tostring(self._unit:key()))
		return destroy_original(self, unit)
	end
end

if RequiredScript == "lib/units/equipment/sentry_gun/sentrygunbase" then
	
	local spawn_original = SentryGunBase.spawn
	local init_original = SentryGunBase.init
	local sync_setup_original = SentryGunBase.sync_setup
	local activate_as_module_original = SentryGunBase.activate_as_module
	local destroy_original = SentryGunBase.destroy
	local load_original = SentryGunBase.load
	
	function SentryGunBase.spawn(owner, pos, rot, peer_id, ...)
		local unit = spawn_original(owner, pos, rot, peer_id, ...)
		managers.gameinfo:event("sentry", "create", tostring(unit:key()), unit)
		managers.gameinfo:event("sentry", "set_owner", tostring(unit:key()), peer_id)
		return unit
	end
	
	function SentryGunBase:init(unit, ...)
		managers.gameinfo:event("sentry", "create", tostring(unit:key()), unit)
		init_original(self, unit, ...)
	end
	
	function SentryGunBase:sync_setup(upgrade_lvl, peer_id, ...)
		managers.gameinfo:event("sentry", "set_owner", tostring(self._unit:key()), peer_id)
		return sync_setup_original(self, upgrade_lvl, peer_id, ...)
	end
	
	function SentryGunBase:activate_as_module(...)
		managers.gameinfo:event("sentry", "destroy", tostring(self._unit:key()))
		return activate_as_module_original(self, ...)
	end
	
	function SentryGunBase:destroy(...)
		managers.gameinfo:event("sentry", "destroy", tostring(self._unit:key()))
		return destroy_original(self, ...)
	end
	
	function SentryGunBase:load(...)
		load_original(self, ...)
		
		if self._is_module then
			managers.gameinfo:event("sentry", "destroy", tostring(self._unit:key()))
		end
	end
	
end

if RequiredScript == "lib/units/equipment/sentry_gun/sentrygundamage" then
	
	local init_original = SentryGunDamage.init
	local set_health_original = SentryGunDamage.set_health
	local _apply_damage_original = SentryGunDamage._apply_damage
	local die_original = SentryGunDamage.die
	local load_original = SentryGunDamage.load
	
	function SentryGunDamage:init(...)
		init_original(self, ...)
		managers.gameinfo:event("sentry", "set_active", tostring(self._unit:key()), true)
		managers.gameinfo:event("sentry", "set_health_ratio", tostring(self._unit:key()), self:health_ratio())
	end
	
	function SentryGunDamage:set_health(...)
		set_health_original(self, ...)
		managers.gameinfo:event("sentry", "set_health_ratio", tostring(self._unit:key()), self:health_ratio())
	end
	
	function SentryGunDamage:_apply_damage(...)
		local result = _apply_damage_original(self, ...)
		managers.gameinfo:event("sentry", "set_health_ratio", tostring(self._unit:key()), self:health_ratio())
		return result
	end
	
	function SentryGunDamage:die(...)
		managers.gameinfo:event("sentry", "set_active", tostring(self._unit:key()), false)
		return die_original(self, ...)
	end
	
	function SentryGunDamage:load(...)
		load_original(self, ...)
		managers.gameinfo:event("sentry", "set_health_ratio", tostring(self._unit:key()), self:health_ratio())
	end
	
end

if RequiredScript == "lib/units/weapons/sentrygunweapon" then
	
	local init_original = SentryGunWeapon.init
	local change_ammo_original = SentryGunWeapon.change_ammo
	local sync_ammo_original = SentryGunWeapon.sync_ammo
	local load_original = SentryGunWeapon.load
	
	function SentryGunWeapon:init(...)
		init_original(self, ...)
		managers.gameinfo:event("sentry", "set_ammo_ratio", tostring(self._unit:key()), self:ammo_ratio())
	end
	
	function SentryGunWeapon:change_ammo(...)
		change_ammo_original(self, ...)
		managers.gameinfo:event("sentry", "set_ammo_ratio", tostring(self._unit:key()), self:ammo_ratio())
	end
	
	function SentryGunWeapon:sync_ammo(...)
		sync_ammo_original(self, ...)
		managers.gameinfo:event("sentry", "set_ammo_ratio", tostring(self._unit:key()), self:ammo_ratio())
	end
	
	function SentryGunWeapon:load(...)
		load_original(self, ...)
		managers.gameinfo:event("sentry", "set_ammo_ratio", tostring(self._unit:key()), self:ammo_ratio())
	end
	
end

if RequiredScript == "lib/managers/playermanager" then

	local spawned_player_original = PlayerManager.spawned_player
	local disable_cooldown_upgrade_original = PlayerManager.disable_cooldown_upgrade
	local activate_temporary_upgrade_original = PlayerManager.activate_temporary_upgrade
	local activate_temporary_upgrade_by_level_original = PlayerManager.activate_temporary_upgrade_by_level
	local deactivate_temporary_upgrade_original = PlayerManager.deactivate_temporary_upgrade
	local count_up_player_minions_original = PlayerManager.count_up_player_minions
	local count_down_player_minions_original = PlayerManager.count_down_player_minions
	local update_hostage_skills_original = PlayerManager.update_hostage_skills
	local set_melee_dmg_multiplier_original = PlayerManager.set_melee_dmg_multiplier
	local mul_to_accuracy_multiplier_original = PlayerManager.mul_to_accuracy_multiplier
	local on_killshot_original = PlayerManager.on_killshot
	local aquire_team_upgrade_original = PlayerManager.aquire_team_upgrade
	local unaquire_team_upgrade_original = PlayerManager.unaquire_team_upgrade
	local add_synced_team_upgrade_original = PlayerManager.add_synced_team_upgrade
	local peer_dropped_out_original = PlayerManager.peer_dropped_out
	local on_headshot_dealt_original = PlayerManager.on_headshot_dealt
	local _on_messiah_recharge_event_original = PlayerManager._on_messiah_recharge_event
	local use_messiah_charge_original = PlayerManager.use_messiah_charge
	local mul_to_property_original = PlayerManager.mul_to_property
	local set_property_original = PlayerManager.set_property
	local remove_property_original = PlayerManager.remove_property
	local add_to_temporary_property_original = PlayerManager.add_to_temporary_property
	local chk_wild_kill_counter_original = PlayerManager.chk_wild_kill_counter
	local set_synced_cocaine_stacks_original = PlayerManager.set_synced_cocaine_stacks
	local _set_body_bags_amount_original = PlayerManager._set_body_bags_amount
	
	local PLAYER_HAS_SPAWNED = false
	function PlayerManager:spawned_player(id, ...)
		spawned_player_original(self, id, ...)
		
		if id == 1 then
			if not PLAYER_HAS_SPAWNED then
				PLAYER_HAS_SPAWNED = true
		
				for category, data in pairs(self._global.team_upgrades) do
					for upgrade, value in pairs(data) do
						local value = self:team_upgrade_value(category, upgrade, 0)
						managers.gameinfo:event("team_buff", "activate", { peer = 0, category = category, upgrade = upgrade, value = value })
					end
				end
			end
		
			if managers.gameinfo and self:has_category_upgrade("player", "messiah_revive_from_bleed_out") and self._messiah_charges > 0 then
				managers.gameinfo:event("buff", "activate", "messiah")
				managers.gameinfo:event("buff", "set_stack_count", "messiah", { stack_count = self._messiah_charges })
 			end
			
			if self:has_category_upgrade("player", "headshot_regen_armor_bonus") then
				local function on_headshot()
					managers.gameinfo:event("timed_buff", "activate", "bullseye_debuff", { duration = tweak_data.upgrades.on_headshot_dealt_cooldown or 0 })
				end
				
				self._message_system:register(Message.OnHeadShot, "bullseye_debuff_listener", on_headshot)
			end
			
			self._is_sociopath = self:has_category_upgrade("player", "killshot_regen_armor_bonus") or 
				self:has_category_upgrade("player", "killshot_close_regen_armor_bonus") or 
				self:has_category_upgrade("player", "killshot_close_panic_chance") or 
				self:has_category_upgrade("player", "melee_kill_life_leech")
		end
	end
	
	function PlayerManager:activate_temporary_upgrade(category, upgrade, ...)
		activate_temporary_upgrade_original(self, category, upgrade, ...)
	
		if self._temporary_upgrades[category] and self._temporary_upgrades[category][upgrade] then
			local t = Application:time()
			local expire_t = self._temporary_upgrades[category][upgrade].expire_time
			local level
			local upgrade_level = self:upgrade_level(category, upgrade, 0)
			if upgrade_level > 0 then
				level = upgrade_level
			end
			local value = self:temporary_upgrade_value(category, upgrade, 0)
			
			if expire_t > t then
				managers.gameinfo:event("temporary_buff", "activate", { t = t, expire_t = expire_t, category = category, upgrade = upgrade, level = level, value = value })
			end
		end
	end
	
	function PlayerManager:disable_cooldown_upgrade(category, upgrade, ...)
		disable_cooldown_upgrade_original(self, category, upgrade, ...)
		
		if self._global.cooldown_upgrades[category] and self._global.cooldown_upgrades[category][upgrade] then
			local t = Application:time()
			local expire_t = self._global.cooldown_upgrades[category][upgrade].cooldown_time
			
			if expire_t > t then
				managers.gameinfo:event("temporary_buff", "activate", { t = t, expire_t = expire_t, category = category, upgrade = upgrade })
			end
		end
	end
	
	function PlayerManager:activate_temporary_upgrade_by_level(category, upgrade, level, ...)
		activate_temporary_upgrade_by_level_original(self, category, upgrade, level, ...)
	
		if self._temporary_upgrades[category] and self._temporary_upgrades[category][upgrade] then
			local t = Application:time()
			local expire_t = self._temporary_upgrades[category][upgrade].expire_time
			local value = self:temporary_upgrade_value(category, upgrade, 0)
			if expire_t > t then
				managers.gameinfo:event("temporary_buff", "activate", { t = t, expire_t = expire_t, category = category, upgrade = upgrade, level = level, value = value })
			end
		end
	end
	
	function PlayerManager:deactivate_temporary_upgrade(category, upgrade, ...)
		if self._temporary_upgrades[category] and self._temporary_upgrades[category][upgrade] then
			managers.gameinfo:event("temporary_buff", "deactivate", { category = category, upgrade = upgrade })
		end

		return deactivate_temporary_upgrade_original(self, category, upgrade, ...)
	end
	
	function PlayerManager:count_up_player_minions(...)
		local result = count_up_player_minions_original(self, ...)
		if self._local_player_minions > 0 then
			if self:has_category_upgrade("player", "minion_master_speed_multiplier") then
				managers.gameinfo:event("buff", "activate", "partner_in_crime")
			end
			if self:has_category_upgrade("player", "minion_master_health_multiplier") then
				managers.gameinfo:event("buff", "activate", "partner_in_crime_aced")
			end
		end
		return result
	end
	
	function PlayerManager:count_down_player_minions(...)
		local result = count_down_player_minions_original(self, ...)
		if self._local_player_minions <= 0 then
			managers.gameinfo:event("buff", "deactivate", "partner_in_crime")
			managers.gameinfo:event("buff", "deactivate", "partner_in_crime_aced")
		end
		return result
	end
	
	function PlayerManager:update_hostage_skills(...)
		local hostages = managers.groupai and managers.groupai:state():hostage_count() or 0
		local minions = self:num_local_minions() or 0
		local stack_count = hostages + minions
		
		if self:has_team_category_upgrade("health", "hostage_multiplier") or self:has_team_category_upgrade("stamina", "hostage_multiplier") or self:has_team_category_upgrade("damage_dampener", "hostage_multiplier") then
			if stack_count > 0 then
				local value = self:team_upgrade_value("damage_dampener", "hostage_multiplier", 0)
				managers.gameinfo:event("buff", "activate", "hostage_situation")
				managers.gameinfo:event("buff", "set_stack_count", "hostage_situation", { stack_count = stack_count })
				if value ~= 0 then
					managers.gameinfo:event("buff", "set_value", "hostage_situation", { value = value })
				end
			else
				managers.gameinfo:event("buff", "deactivate", "hostage_situation")
			end
		end
		
		if self:has_category_upgrade("player", "hostage_health_regen_addend") then
			if stack_count > 0 then
				managers.gameinfo:event("buff", "activate", "hostage_taker")
				--managers.gameinfo:event("buff", "set_stack_count", "hostage_taker", { stack_count = stack_count })
			else
				managers.gameinfo:event("buff", "deactivate", "hostage_taker")
			end
		end
		
		return update_hostage_skills_original(self, ...)
	end
	
	function PlayerManager:set_melee_dmg_multiplier(...)
		local old_mult = self._melee_dmg_mul
		set_melee_dmg_multiplier_original(self, ...)
		if old_mult ~= self._melee_dmg_mul then
			managers.gameinfo:event("buff", "change_stack_count", "bloodthirst_basic", { difference = 1 })
		end
		managers.gameinfo:event("buff", "set_value", "bloodthirst_basic", { value = self._melee_dmg_mul })
	end
	
	function PlayerManager:on_killshot(...)
		local last_killshot = self._on_killshot_t
		local result = on_killshot_original(self, ...)
		
		if self._is_sociopath and self._on_killshot_t ~= last_killshot then
			managers.gameinfo:event("timed_buff", "activate", "sociopath_debuff", { expire_t = self._on_killshot_t })
		end
		
		return result
	end
	
	function PlayerManager:aquire_team_upgrade(upgrade, ...)
		aquire_team_upgrade_original(self, upgrade, ...)
		
		if managers.gameinfo then
			local value = self:team_upgrade_value(upgrade.category, upgrade.upgrade, 0)
			managers.gameinfo:event("team_buff", "activate", { peer = 0, category = upgrade.category, upgrade = upgrade.upgrade, value = value })
		end
	end
	
	function PlayerManager:unaquire_team_upgrade(upgrade, ...)
		unaquire_team_upgrade_original(self, upgrade, ...)
		
		if managers.gameinfo then
			managers.gameinfo:event("team_buff", "deactivate", { peer = 0, category = upgrade.category, upgrade = upgrade.upgrade })
		end
	end
	
	function PlayerManager:add_synced_team_upgrade(peer_id, category, upgrade, ...)
		add_synced_team_upgrade_original(self, peer_id, category, upgrade, ...)
		
		local value = self:team_upgrade_value(category, upgrade, 0)
		managers.gameinfo:event("team_buff", "activate", { peer = peer_id, category = category, upgrade = upgrade, value = value })
	end
	
	function PlayerManager:peer_dropped_out(peer, ...)
		local peer_id = peer:id()
		
		for category, data in pairs(self._global.synced_team_upgrades[peer_id] or {}) do
			for upgrade, value in pairs(data) do
				managers.gameinfo:event("team_buff", "deactivate", { peer = peer_id, category = category, upgrade = upgrade })
			end
		end
		
		return peer_dropped_out_original(self, peer, ...)
	end
	
	function PlayerManager:on_headshot_dealt(...)
		local t = Application:time()
		if (self._on_headshot_dealt_t or 0) <= t and self:has_category_upgrade("player", "headshot_regen_armor_bonus") then
			managers.gameinfo:event("timed_buff", "activate", "bullseye_debuff", { t = t, duration = tweak_data.upgrades.on_headshot_dealt_cooldown or 0 })
		end
		
		return on_headshot_dealt_original(self, ...)
	end
	
	function PlayerManager:_on_messiah_recharge_event(...)
		_on_messiah_recharge_event_original(self, ...)
	
		if self._messiah_charges > 0 then
			managers.gameinfo:event("buff", "activate", "messiah")
			managers.gameinfo:event("buff", "set_stack_count", "messiah", { stack_count = self._messiah_charges })
		else
			managers.gameinfo:event("buff", "deactivate", "messiah")
		end
	end
	
	
	function PlayerManager:use_messiah_charge(...)
		use_messiah_charge_original(self, ...)
		if self._messiah_charges > 0 then
			managers.gameinfo:event("buff", "activate", "messiah")
			managers.gameinfo:event("buff", "set_stack_count", "messiah", { stack_count = self._messiah_charges })
		else
			managers.gameinfo:event("buff", "deactivate", "messiah")
		end
	end
	
	function PlayerManager:mul_to_property(name, value, ...)
		mul_to_property_original(self, name, value, ...)
		managers.gameinfo:event("buff", "change_stack_count", name, { difference = 1 })
		managers.gameinfo:event("buff", "set_value", name, { value = self:get_property(name, 1) })
	end
	
	function PlayerManager:set_property(name, value, ...)
		set_property_original(self, name, value, ...)
		
		if name == "revive_damage_reduction" then
			managers.gameinfo:event("buff", "activate", "combat_medic_passive")
			managers.gameinfo:event("buff", "set_value", "combat_medic_passive", { value = value })
		end
	end
	
	function PlayerManager:remove_property(name, ...)
		remove_property_original(self, name, ...)
		
		if name == "revive_damage_reduction" then
			managers.gameinfo:event("buff", "deactivate", "combat_medic_passive")
		end
	end
	
	function PlayerManager:add_to_temporary_property(name, time, ...)
		add_to_temporary_property_original(self, name, time, ...)
		
		if name == "bullet_storm" then
			local t = self._temporary_properties._properties[name][2]
			managers.gameinfo:event("timed_buff", "activate", name, { expire_t = t })
		end
	end
	
	function PlayerManager:chk_wild_kill_counter(...)
		local t = Application:time()
		local player = self:player_unit()
		local expire_t
		
		if alive(player) and (managers.player:has_category_upgrade("player", "wild_health_amount") or managers.player:has_category_upgrade("player", "wild_armor_amount")) then
			local dmg = player:character_damage()
			local missing_health_ratio = math.clamp(1 - dmg:health_ratio(), 0, 1)
			local missing_armor_ratio = math.clamp(1 - dmg:armor_ratio(), 0, 1)
			local less_armor_wild_cooldown = managers.player:upgrade_value("player", "less_armor_wild_cooldown", 0)
			local less_health_wild_cooldown = managers.player:upgrade_value("player", "less_health_wild_cooldown", 0)
			local trigger_cooldown = tweak_data.upgrades.wild_trigger_time or 30

			if less_health_wild_cooldown ~= 0 and less_health_wild_cooldown[1] ~= 0 then
				local missing_health_stacks = math.floor(missing_health_ratio / less_health_wild_cooldown[1])
				trigger_cooldown = trigger_cooldown - less_health_wild_cooldown[2] * missing_health_stacks
			end
			if less_armor_wild_cooldown ~= 0 and less_armor_wild_cooldown[1] ~= 0 then
				local missing_armor_stacks = math.floor(missing_armor_ratio / less_armor_wild_cooldown[1])
				trigger_cooldown = trigger_cooldown - less_armor_wild_cooldown[2] * missing_armor_stacks
			end
			
			expire_t = t + math.max(trigger_cooldown, 0)
		end
		
		local old_stacks = 0
		if self._wild_kill_triggers then
			old_stacks = #self._wild_kill_triggers
			for i = 1, #self._wild_kill_triggers, 1 do
				if self._wild_kill_triggers[i] > t then
					break
				end
				old_stacks = old_stacks - 1
			end
		end
		
		chk_wild_kill_counter_original(self, ...)
		
		if self._wild_kill_triggers and #self._wild_kill_triggers > old_stacks then
			managers.gameinfo:event("timed_stack_buff", "add_stack", "biker", { t = t, expire_t = expire_t })
		end
	end
	
	function PlayerManager:set_synced_cocaine_stacks(...)
		set_synced_cocaine_stacks_original(self, ...)
		
		local max_stack = 0
		for peer_id, data in pairs(self._global.synced_cocaine_stacks) do
			if data.in_use and data.amount > max_stack then
				max_stack = data.amount
			end
		end
		
		local ratio = max_stack / tweak_data.upgrades.max_total_cocaine_stacks
		if ratio > 0 then
			managers.gameinfo:event("buff", "activate", "maniac")
			managers.gameinfo:event("buff", "set_value", "maniac", { value = string.format("%.0f%%", ratio*100), show_value = true } )
		else
			managers.gameinfo:event("buff", "deactivate", "maniac")
		end
	end
	
	function PlayerManager:_set_body_bags_amount(body_bags_amount)
		managers.gameinfo:event("bodybags", "set", body_bags_amount)
		_set_body_bags_amount_original(self, body_bags_amount)
	end
	
end

if RequiredScript == "lib/utils/temporarypropertymanager" then

	local activate_property_original = TemporaryPropertyManager.activate_property
	local remove_property_original = TemporaryPropertyManager.remove_property
	
	function TemporaryPropertyManager:activate_property(prop, time, value, ...)
		managers.gameinfo:event("temporary_buff", "activate", { duration = time, category = "temporary", upgrade = prop, value = value })
		return activate_property_original(self, prop, time, value, ...)
	end
	
	function TemporaryPropertyManager:remove_property(prop, ...)
		managers.gameinfo:event("temporary_buff", "deactivate", { category = "temporary", upgrade = prop })
		return remove_property_original(self, prop, ...)
	end
	
end

if RequiredScript == "lib/units/beings/player/playermovement" then
	
	local update_original = PlayerMovement.update
	local on_morale_boost_original = PlayerMovement.on_morale_boost
	
	function PlayerMovement:update(unit, t, ...)
		self:_update_uppers_buff(t)
		return update_original(self, unit, t, ...)
	end
	
	function PlayerMovement:on_morale_boost(...)
		managers.gameinfo:event("timed_buff", "activate", "inspire", { duration = tweak_data.upgrades.morale_boost_time })
		return on_morale_boost_original(self, ...)
	end
	
	
	local FAK_IN_RANGE = false
	local FAK_RECHECK_T = 0
	local FAK_RECHECK_INTERVAL = 0.25
	
	function PlayerMovement:_update_uppers_buff(t)
		if t > FAK_RECHECK_T and alive(self._unit) then
			if FirstAidKitBase.GetFirstAidKit(self._unit:position()) then
				if not FAK_IN_RANGE then
					FAK_IN_RANGE = true
					managers.gameinfo:event("buff", "activate", "uppers")
				end
			elseif FAK_IN_RANGE then
				FAK_IN_RANGE = false
				managers.gameinfo:event("buff", "deactivate", "uppers")
			end
			FAK_RECHECK_T = t + FAK_RECHECK_INTERVAL
		end
	end
	
end

if RequiredScript == "lib/units/beings/player/states/playerstandard" then
	
	local _do_action_intimidate_original = PlayerStandard._do_action_intimidate
	local _start_action_melee_original = PlayerStandard._start_action_melee
	local _interupt_action_melee_original = PlayerStandard._interupt_action_melee
	local _do_melee_damage_original = PlayerStandard._do_melee_damage
	local _start_action_interact_original = PlayerStandard._start_action_interact
	local _interupt_action_interact_original = PlayerStandard._interupt_action_interact
	local _start_action_use_item_original = PlayerStandard._start_action_use_item
	local _interupt_action_use_item_original = PlayerStandard._interupt_action_use_item
	local _start_action_reload_original = PlayerStandard._start_action_reload
	local _update_reload_timers_original = PlayerStandard._update_reload_timers
	local _interupt_action_reload_original = PlayerStandard._interupt_action_reload
	local _start_action_charging_weapon_original = PlayerStandard._start_action_charging_weapon
	local _end_action_charging_weapon_original = PlayerStandard._end_action_charging_weapon
	
	function PlayerStandard:_do_action_intimidate(t, interact_type, ...)
		if interact_type == "cmd_gogo" or interact_type == "cmd_get_up" then
			local duration = (tweak_data.upgrades.morale_boost_base_cooldown * managers.player:upgrade_value("player", "morale_boost_cooldown_multiplier", 1)) or 3.5
			managers.gameinfo:event("timed_buff", "activate", "inspire_debuff", { duration = duration })
		end
		
		return _do_action_intimidate_original(self, t, interact_type, ...)
	end
	
	function PlayerStandard:_start_action_melee(t, input, instant, ...)
		if not instant then
			local duration = tweak_data.blackmarket.melee_weapons[managers.blackmarket:equipped_melee_weapon()].stats.charge_time
			managers.gameinfo:event("player_action", "activate", "melee_charge")
			managers.gameinfo:event("player_action", "set_duration", "melee_charge", { duration = duration })
		end
		
		return _start_action_melee_original(self, t, input, instant, ...)
	end
	
	function PlayerStandard:_interupt_action_melee(...)
		if self._state_data.melee_start_t then
			managers.gameinfo:event("player_action", "deactivate", "melee_charge")
		end
		
		return _interupt_action_melee_original(self, ...)
	end
	
	function PlayerStandard:_do_melee_damage(t, ...)
		if self._state_data.melee_start_t then
			managers.gameinfo:event("player_action", "deactivate", "melee_charge")
		end
		
		local result = _do_melee_damage_original(self, t, ...)
		
		if self._state_data.stacking_dmg_mul then
			self:_check_damage_stack_skill(t, "melee")
		end
		
		return result
	end
	
	function PlayerStandard:_start_action_interact(t, input, timer, interact_object, ...)
		if managers.player:has_category_upgrade("player", "interacting_damage_multiplier") then
			local value = managers.player:upgrade_value("player", "interacting_damage_multiplier", 0)
			managers.gameinfo:event("buff", "activate", "die_hard")
			managers.gameinfo:event("buff", "set_value", "die_hard", { value = value })
		end
		
		managers.gameinfo:event("player_action", "activate", "interact", { duration = timer })
		managers.gameinfo:event("player_action", "set_data", "interact", { interact_id = interact_object:interaction().tweak_data })
		
		return _start_action_interact_original(self, t, input, timer, interact_object, ...)
	end
	
	function PlayerStandard:_interupt_action_interact(t, input, complete, ...)
		if self._interact_expire_t then
			if managers.player:has_category_upgrade("player", "interacting_damage_multiplier") then
				managers.gameinfo:event("buff", "deactivate", "die_hard")
			end
			
			managers.gameinfo:event("player_action", "set_data", "interact", { completed = complete and true or false })
			managers.gameinfo:event("player_action", "deactivate", "interact")
		end
		
		return _interupt_action_interact_original(self, t, input, complete, ...)
	end
	
	function PlayerStandard._start_action_use_item(self, t, ...)
		local equipment_id = managers.player:selected_equipment_id()
		local timer = managers.player:selected_equipment_deploy_timer()
		managers.gameinfo:event("player_action", "activate", "place_equipment", { t = t, duration = timer })
		managers.gameinfo:event("player_action", "set_data", "place_equipment", { interact_id = equipment_id })
		
		return _start_action_use_item_original(self, t, ...)
	end
	
	function PlayerStandard._interupt_action_use_item(self, t, input, complete, ...)
		if self._use_item_expire_t then
			managers.gameinfo:event("player_action", "set_data", "place_equipment", { completed = complete and true or false })
			managers.gameinfo:event("player_action", "deactivate", "place_equipment")
		end
		
		return _interupt_action_use_item_original(self, t, input, complete, ...)
	end
	
	function PlayerStandard:_start_action_reload(t, ...)
		_start_action_reload_original(self, t, ...)
		
		if self._state_data.reload_expire_t then
			managers.gameinfo:event("player_action", "activate", "reload", { expire_t = self._state_data.reload_expire_t })
		end
	end
	
	function PlayerStandard:_update_reload_timers(...)
		local reloading = self._state_data.reload_expire_t
	
		_update_reload_timers_original(self, ...)
		
		if reloading and not self._state_data.reload_expire_t then
			managers.gameinfo:event("player_action", "deactivate", "reload")
		end
	end
	
	function PlayerStandard:_interupt_action_reload(...)
		if self._state_data.reload_expire_t then
			managers.gameinfo:event("player_action", "deactivate", "reload")
		end
		return _interupt_action_reload_original(self, ...)
	end
	
	function PlayerStandard:_start_action_charging_weapon(t, ...)
		managers.gameinfo:event("player_action", "activate", "weapon_charge")
		managers.gameinfo:event("player_action", "set_duration", "weapon_charge", { duration = self._equipped_unit:base():charge_max_t() })
		return _start_action_charging_weapon_original(self, t, ...)
	end

	function PlayerStandard:_end_action_charging_weapon(...)
		if self._state_data.charging_weapon then
			managers.gameinfo:event("player_action", "deactivate", "weapon_charge")
		end
		return _end_action_charging_weapon_original(self, ...)
	end
	
	--OVERRIDE
	function PlayerStandard:_update_omniscience(t, dt)
		local action_forbidden = 
			not managers.player:has_category_upgrade("player", "standstill_omniscience") or 
			managers.player:current_state() == "civilian" or 
			self:_interacting() or 
			self._ext_movement:has_carry_restriction() or 
			self:is_deploying() or 
			self:_changing_weapon() or 
			self:_is_throwing_projectile() or 
			self:_is_meleeing() or 
			self:_on_zipline() or 
			self._moving or 
			self:running() or 
			self:_is_reloading() or 
			self:in_air() or 
			self:in_steelsight() or 
			self:is_equipping() or 
			self:shooting() or 
			not managers.groupai:state():whisper_mode() or 
			not tweak_data.player.omniscience
		
		if action_forbidden then
			if self._state_data.omniscience_t then
				managers.gameinfo:event("buff", "deactivate", "sixth_sense")
				self._state_data.omniscience_t = nil
			end
			return
		end
		
		if not self._state_data.omniscience_t then
			managers.gameinfo:event("buff", "activate", "sixth_sense")
			managers.gameinfo:event("buff", "set_duration", "sixth_sense", { duration = tweak_data.player.omniscience.start_t })
			managers.gameinfo:event("buff", "set_stack_count", "sixth_sense", { stack_count = nil })
		end
		
		self._state_data.omniscience_t = self._state_data.omniscience_t or t + tweak_data.player.omniscience.start_t
		if t >= self._state_data.omniscience_t then
			local sensed_targets = World:find_units_quick("sphere", self._unit:movement():m_pos(), tweak_data.player.omniscience.sense_radius, managers.slot:get_mask("trip_mine_targets"))
			managers.gameinfo:event("buff", "set_stack_count", "sixth_sense", { stack_count = #sensed_targets })
			
			for _, unit in ipairs(sensed_targets) do
				if alive(unit) and not unit:base():char_tweak().is_escort then
					self._state_data.omniscience_units_detected = self._state_data.omniscience_units_detected or {}
					if not self._state_data.omniscience_units_detected[unit:key()] or t >= self._state_data.omniscience_units_detected[unit:key()] then
						self._state_data.omniscience_units_detected[unit:key()] = t + tweak_data.player.omniscience.target_resense_t
						managers.game_play_central:auto_highlight_enemy(unit, true)
					end
				else
				end
			end
			self._state_data.omniscience_t = t + tweak_data.player.omniscience.interval_t
			managers.gameinfo:event("buff", "set_duration", "sixth_sense", { duration = tweak_data.player.omniscience.interval_t })
		end
	end
	
	
	--local PREV_DMG_STACK = {}	--Prevent event flooding
	function PlayerStandard:_check_damage_stack_skill(t, category)
		local stack = self._state_data.stacking_dmg_mul[category]
		
		if stack then
			local buff_id = category .. "_stack_damage"
			
			--if not PREV_DMG_STACK[category] or (PREV_DMG_STACK[category][1] ~= stack[1] or PREV_DMG_STACK[category][2] ~= stack[2]) then
			--	PREV_DMG_STACK[category] = { stack[1], stack[2] }
				
				if stack[2] > 0 then
					local value = managers.player:upgrade_value(category, "stacking_hit_damage_multiplier", 0)
					managers.gameinfo:event("timed_buff", "activate", buff_id, { expire_t = stack[1] })
					managers.gameinfo:event("buff", "set_stack_count", buff_id, { stack_count = stack[2] })
					managers.gameinfo:event("buff", "set_value", buff_id, { value = 1 + stack[2] * value })
				else
					managers.gameinfo:event("buff", "deactivate", buff_id)
				end
			--end
		end
	end
	
end

if RequiredScript == "lib/units/beings/player/playerdamage" then
	
	local init_original = PlayerDamage.init
	local add_damage_to_hot_original = PlayerDamage.add_damage_to_hot
	local set_health_original = PlayerDamage.set_health
	local _upd_health_regen_original = PlayerDamage._upd_health_regen
	local _start_regen_on_the_side_original = PlayerDamage._start_regen_on_the_side
	local _regenerate_armor_original = PlayerDamage._regenerate_armor
	local _update_armor_grinding_original = PlayerDamage._update_armor_grinding
	local _on_damage_armor_grinding_original = PlayerDamage._on_damage_armor_grinding
	local change_regenerate_speed_original = PlayerDamage.change_regenerate_speed
	local build_suppression_original = PlayerDamage.build_suppression
	local set_armor_original = PlayerDamage.set_armor
	local _check_bleed_out_original = PlayerDamage._check_bleed_out
	
	local HEALTH_RATIO_BONUSES = {
		melee_damage_health_ratio_multiplier = { category = "melee", buff_id = "berserker" },
		damage_health_ratio_multiplier = { category = "damage", buff_id = "berserker_aced" },
		armor_regen_damage_health_ratio_multiplier = { category = "armor_regen", buff_id = "yakuza_recovery" },
		movement_speed_damage_health_ratio_multiplier = { category = "movement_speed", buff_id = "yakuza_speed" },
	}
	local LAST_HEALTH_RATIO = 0
	local LAST_ARMOR_REGEN_BUFF_RESET = 0
	local LAST_CHECK_T = 0
	local ARMOR_GRIND_ACTIVE = false
	
	function PlayerDamage:init(...)
		init_original(self, ...)
		
		if managers.player:has_category_upgrade("player", "damage_to_armor") then
			local function on_damage(dmg_info)
				if self._unit == dmg_info.attacker_unit then
					local t = Application:time()
					if (self._damage_to_armor.elapsed == t) or (t - self._damage_to_armor.elapsed > self._damage_to_armor.target_tick) then
						managers.gameinfo:event("timed_buff", "activate", "anarchist_armor_recovery_debuff", { t = t, duration = self._damage_to_armor.target_tick })
					end
 				end
			end
			
			CopDamage.register_listener("anarchist_debuff_listener", {"on_damage"}, on_damage)
		end
		
		self._listener_holder:add("custom_on_damage", { "on_damage" }, callback(self, self, "_custom_on_damage_clbk"))
	end
	
	function PlayerDamage:add_damage_to_hot(...)
		local num_old_stacks = #self._damage_to_hot_stack or 0
		
		add_damage_to_hot_original(self, ...)
		
		local num_new_stacks = #self._damage_to_hot_stack or 0
		
		if num_new_stacks > num_old_stacks then
			local stack_duration = ((self._doh_data.total_ticks or 1) + managers.player:upgrade_value("player", "damage_to_hot_extra_ticks", 0)) * (self._doh_data.tick_time or 1)
			managers.gameinfo:event("timed_buff", "activate", "grinder_debuff", { duration = tweak_data.upgrades.damage_to_hot_data.stacking_cooldown })
			managers.gameinfo:event("timed_stack_buff", "add_stack", "grinder", { duration = stack_duration })
		end
	end
	
	function PlayerDamage:set_health(...)
		set_health_original(self, ...)
		
		local health_ratio = self:health_ratio()
		
		if health_ratio ~= LAST_HEALTH_RATIO then
			LAST_HEALTH_RATIO = health_ratio
		
			for upgrade, data in pairs(HEALTH_RATIO_BONUSES) do
				if managers.player:has_category_upgrade("player", upgrade) then
					local bonus_ratio = managers.player:get_damage_health_ratio(health_ratio, data.category)
					if bonus_ratio > 0 then
						managers.gameinfo:event("buff", "activate", data.buff_id)
						managers.gameinfo:event("buff", "set_value", data.buff_id, { value = bonus_ratio, show_value = true })
					else
						managers.gameinfo:event("buff", "deactivate", data.buff_id)
					end
				end
			end
			
			if managers.player:has_category_upgrade("player", "passive_damage_reduction") then
				local threshold = managers.player:upgrade_value("player", "passive_damage_reduction")
				local value = managers.player:team_upgrade_value("damage_dampener", "team_damage_reduction")
				if health_ratio < threshold then
					value = 2 * value - 1
				end
				managers.gameinfo:event("buff", "set_value", "crew_chief_1", { value = value })
			end
		end
	end
	
	function PlayerDamage:_upd_health_regen(t, ...)
		local old_timer = self._health_regen_update_timer
		
		local result = _upd_health_regen_original(self, t, ...)
		
		if self._health_regen_update_timer then
			if self._health_regen_update_timer > (old_timer or 0) and self:health_ratio() < 1 then
				--TODO: Muscle regen?
				managers.gameinfo:event("buff", "set_duration", "hostage_taker", { duration = self._health_regen_update_timer })
			end
		end
	end
	
	function PlayerDamage:_start_regen_on_the_side(time, ...)
		if not self._regen_on_the_side and time > 0 then
			managers.gameinfo:event("timed_buff", "activate", "tooth_and_claw", { duration = time })
		end
		
		return _start_regen_on_the_side_original(self, time, ...)
	end
	
	function PlayerDamage:_update_armor_grinding(t, ...)
		_update_armor_grinding_original(self, t, ...)
		
		if self._armor_grinding.elapsed == 0 and ARMOR_GRIND_ACTIVE then
			managers.gameinfo:event("player_action", "set_duration", "anarchist_armor_regeneration", { duration = self._armor_grinding.target_tick })
		end
	end
	
	function PlayerDamage:_on_damage_armor_grinding(...)
		if not ARMOR_GRIND_ACTIVE then
			local t = Application:time() - (self._armor_grinding.elapsed or 0)
			managers.gameinfo:event("player_action", "activate", "anarchist_armor_regeneration")
			managers.gameinfo:event("player_action", "set_duration", "anarchist_armor_regeneration", { t = t, duration = self._armor_grinding.target_tick })
			ARMOR_GRIND_ACTIVE = true
		end
		return _on_damage_armor_grinding_original(self, ...)
	end
	
	function PlayerDamage:change_regenerate_speed(...)
		change_regenerate_speed_original(self, ...)
		self:_check_armor_regen_timer()
	end
	
	function PlayerDamage:build_suppression(...)
		build_suppression_original(self, ...)
		if self:get_real_armor() < self:_max_armor() then
			LAST_ARMOR_REGEN_BUFF_RESET = Application:time()
			self:_check_armor_regen_timer()
		end
	end
	
	function PlayerDamage:set_armor(armor, ...)
		set_armor_original(self, armor, ...)
		
		if armor >= self:_total_armor() then
			ARMOR_GRIND_ACTIVE = false
			managers.gameinfo:event("player_action", "deactivate", "anarchist_armor_regeneration")
			managers.gameinfo:event("player_action", "deactivate", "standard_armor_regeneration")
		end
	end
	
	function PlayerDamage:_check_bleed_out(...)
		local last_uppers = self._uppers_elapsed or 0
		
		local result = _check_bleed_out_original(self, ...)
		
		if (self._uppers_elapsed or 0) > last_uppers then
			managers.gameinfo:event("timed_buff", "activate", "uppers_debuff", { duration = self._UPPERS_COOLDOWN })
		end
	end
	
	function PlayerDamage:_custom_on_damage_clbk()
		if not self:is_downed() then
			LAST_ARMOR_REGEN_BUFF_RESET = Application:time()
			self:_check_armor_regen_timer()
		end
	end
	
	function PlayerDamage:_check_armor_regen_timer()
		if self._regenerate_timer then
			local t = Application:time()
			local duration = self._regenerate_timer / (self._regenerate_speed or 1)
			
			if self._supperssion_data.decay_start_t and self._supperssion_data.decay_start_t > t then
				duration = duration + (self._supperssion_data.decay_start_t - t)
			end
			
			if duration > 0 and t > LAST_CHECK_T then
				local start_t = LAST_ARMOR_REGEN_BUFF_RESET
				local expire_t = t + duration
				LAST_CHECK_T = t
				managers.gameinfo:event("player_action", "activate", "standard_armor_regeneration")
				managers.gameinfo:event("player_action", "set_duration", "standard_armor_regeneration", { t = start_t, expire_t = expire_t })
			end
		end
	end
	
	
end

if RequiredScript == "lib/units/weapons/raycastweaponbase" then
	
	local setup_original = RaycastWeaponBase.setup
	local set_ammo_remaining_in_clip_original = RaycastWeaponBase.set_ammo_remaining_in_clip
	
	function RaycastWeaponBase:setup(...)
		setup_original(self, ...)
		
		local user_unit = self._setup and self._setup.user_unit
		local player_unit = managers.player:player_unit()
		self._player_is_owner = alive(user_unit) and alive(player_unit) and user_unit:key() == player_unit:key()
	end
	
	function RaycastWeaponBase:set_ammo_remaining_in_clip(ammo, ...)
		if RaycastWeaponBase.LOCK_N_LOAD_ACTIVE and self._player_is_owner then
			local data = RaycastWeaponBase.LOCK_N_LOAD_ACTIVE
			if ammo <= data.max_threshold and ammo >= data.min_threshold then
				local bonus = math.clamp(data.max_bonus * math.pow(data.penalty, ammo - data.min_threshold), data.min_bonus, data.max_bonus)
				managers.gameinfo:event("buff", "set_value", "lock_n_load", { value = bonus, show_value = true })
			end
		end
		
		return set_ammo_remaining_in_clip_original(self, ammo, ...)
 	end
	
end

if RequiredScript == "lib/player_actions/skills/playeractionbloodthirstbase" then
	
	local bloodthirstbase_original = PlayerAction.BloodthirstBase.Function
	
	function PlayerAction.BloodthirstBase.Function(...)
		managers.gameinfo:event("buff", "activate", "bloodthirst_basic")
		managers.gameinfo:event("buff", "set_value", "bloodthirst_basic", { value = 1 })
		bloodthirstbase_original(...)
		managers.gameinfo:event("buff", "deactivate", "bloodthirst_basic")
	end
	
end

if RequiredScript == "lib/player_actions/skills/playeractionexperthandling" then
	
	local experthandling_original = PlayerAction.ExpertHandling.Function
	
	function PlayerAction.ExpertHandling.Function(player_manager, accuracy_bonus, max_stacks, max_time, ...)
		managers.gameinfo:event("buff", "activate", "desperado")
		managers.gameinfo:event("buff", "set_duration", "desperado", { expire_t = max_time })
		experthandling_original(player_manager, accuracy_bonus, max_stacks, max_time, ...)
		managers.gameinfo:event("buff", "deactivate", "desperado")
	end
	
end

if RequiredScript == "lib/player_actions/skills/playeractionshockandawe" then
	
	local shockandawe_original = PlayerAction.ShockAndAwe.Function
	
	function PlayerAction.ShockAndAwe.Function(player_manager, target_enemies, max_reload_increase, min_reload_increase, penalty, min_bullets, ...)
		local kill_count = 1
		local active = false
	
		local function on_enemy_killed(weapon_unit, variant)
			if not active and alive(weapon_unit) then
				kill_count = kill_count + 1
				
				if kill_count >= target_enemies then
					active = true
					local min_threshold = min_bullets + (weapon_unit:base():is_category("smg", "assault_rifle", "lmg") and player_manager:upgrade_value("player", "automatic_mag_increase", 0) or 0)
					local max_threshold = math.floor(min_threshold + math.log(min_reload_increase/max_reload_increase) / math.log(penalty))
					local data = { 
						max_bonus = max_reload_increase, 
						min_bonus = min_reload_increase, 
						penalty = penalty,
						min_threshold = min_threshold,
						max_threshold = max_threshold,
					}
 					
					RaycastWeaponBase.LOCK_N_LOAD_ACTIVE = data
					
					local ammo = weapon_unit:base():get_ammo_remaining_in_clip()
					local bonus = math.clamp(data.max_bonus * math.pow(data.penalty, ammo - data.min_threshold), data.min_bonus, data.max_bonus)
					managers.gameinfo:event("buff", "activate", "lock_n_load")
					managers.gameinfo:event("buff", "set_value", "lock_n_load", { value = bonus, show_value = true })
				end
			end
		end
		
		--managers.gameinfo:event("buff", "activate", "shock_and_awe")
		--managers.gameinfo:event("buff", "set_stack_count", "shock_and_awe" { stack_count = target_enemies - kill_count })
		managers.player:register_message(Message.OnEnemyKilled, "lock_n_load_buff_listener", on_enemy_killed)
		shockandawe_original(player_manager, target_enemies, max_reload_increase, min_reload_increase, penalty, min_bullets, ...)
		managers.gameinfo:event("buff", "deactivate", "lock_n_load")
		managers.player:unregister_message(Message.OnEnemyKilled, "lock_n_load_buff_listener")
		RaycastWeaponBase.LOCK_N_LOAD_ACTIVE = nil
	end
	
end

if RequiredScript == "lib/player_actions/skills/playeractiondireneed" then
	
	local direneed_original = PlayerAction.DireNeed.Function
	
	function PlayerAction.DireNeed.Function(...)
		managers.gameinfo:event("buff", "activate", "dire_need")
		direneed_original(...)
		managers.gameinfo:event("buff", "deactivate", "dire_need")
	end
	
end

if RequiredScript == "lib/player_actions/skills/playeractionunseenstrike" then
	
	local unseenstrike_original = PlayerAction.UnseenStrike.Function
	local unseenstrike_start_original = PlayerAction.UnseenStrikeStart.Function
	
	function PlayerAction.UnseenStrike.Function(player_manager, min_time, ...)
		local function on_damage_taken()
			managers.gameinfo:event("buff", "set_duration", "unseen_strike_debuff", { duration = min_time })
		end
		
		managers.player:register_message(Message.OnPlayerDamage, "unseen_strike_debuff_listener", on_damage_taken)
		managers.gameinfo:event("buff", "activate", "unseen_strike_debuff")
		on_damage_taken()
		unseenstrike_original(player_manager, min_time, ...)
		managers.player:unregister_message(Message.OnPlayerDamage, "unseen_strike_debuff_listener")
		managers.gameinfo:event("buff", "deactivate", "unseen_strike_debuff")
	end
	
	function PlayerAction.UnseenStrikeStart.Function(player_manager, max_duration, ...)
		local start_t = Application:time()
		
		local function on_damage_taken()
			local stop_t = Application:time()
			local diff = stop_t - start_t
			local offset = diff - math.floor(diff/max_duration) * max_duration	--Has error margin, grows every reset
			managers.gameinfo:event("buff", "set_duration", "unseen_strike", { t = stop_t - offset, duration = max_duration })
		end
		
		managers.player:register_message(Message.OnPlayerDamage, "unseen_strike_buff_listener", on_damage_taken)
		managers.gameinfo:event("buff", "activate", "unseen_strike")
		unseenstrike_start_original(player_manager, max_duration, ...)
		managers.player:unregister_message(Message.OnPlayerDamage, "unseen_strike_buff_listener")
		managers.gameinfo:event("buff", "deactivate", "unseen_strike")
	end
	
end

if RequiredScript == "lib/player_actions/skills/playeractionammoefficiency" then

	local ammo_efficieny_original = PlayerAction.AmmoEfficiency.Function
	
	function PlayerAction.AmmoEfficiency.Function(player_manager, target_headshots, bullet_refund, target_time, ...)
		local headshots = 1
		
		local function on_headshot()
			headshots = headshots + 1
			if headshots < target_headshots then
				managers.gameinfo:event("buff", "set_stack_count", "ammo_efficiency", { stack_count = target_headshots - headshots })
 			end
		end
		
		ammo_efficieny_original(player_manager, target_headshots, bullet_refund, target_time, ...)
		
		player_manager:unregister_message(Message.OnHeadShot, "ammo_efficiency_buff_listener")
		managers.gameinfo:event("buff", "deactivate", "ammo_efficiency")
	end
	
end

if RequiredScript == "lib/player_actions/skills/playeractiontriggerhappy" then

	local trigger_happy_original = PlayerAction.TriggerHappy.Function
	
	function PlayerAction.TriggerHappy.Function(player_manager, damage_bonus, max_stacks, max_time, ...)
		managers.gameinfo:event("buff", "activate", "trigger_happy")
		managers.gameinfo:event("buff", "set_duration", "trigger_happy", { expire_t = max_time })
		trigger_happy_original(player_manager, damage_bonus, max_stacks, max_time, ...)
		managers.gameinfo:event("buff", "deactivate", "trigger_happy")
	end
	
end


 
--[[
if RequiredScript == "lib/managers/objectinteractionmanager" then
	
	local init_original = ObjectInteractionManager.init
	local update_original = ObjectInteractionManager.update
	local add_unit_original = ObjectInteractionManager.add_unit
	local remove_unit_original = ObjectInteractionManager.remove_unit
	
	
	ObjectInteractionManager.TRIGGERS = {
		[136843] = {
			136844, 136845, 136846, 136847, --HB armory ammo shelves
			136859, 136860, 136864, 136865, 136866, 136867, 136868, 136869, 136870, --HB armory grenades
		},	
		[151868] = { 151611 }, --GGC armory ammo shelf 1
		[151869] = {
			151612, --GGC armory ammo shelf 2
			151596, 151597, 151598, --GGC armory grenades
		},
		--[101835] = { 101470, 101472, 101473 },	--HB infirmary med boxes (not needed, triggers on interaction activation)
	}
	
	ObjectInteractionManager.INTERACTION_TRIGGERS = {
		requires_ecm_jammer_double = {
			[Vector3(-2217.05, 2415.52, -354.502)] = 136843,	--HB armory door 1
			[Vector3(1817.05, 3659.48, 45.4985)] = 136843,	--HB armory door 2
		},
		drill = {
			[Vector3(142, 3098, -197)] = 151868,	--GGC armory cage 1 alt 1
			[Vector3(-166, 3413, -197)] = 151869,	--GGC armory cage 2 alt 1
			[Vector3(3130, 1239, -195.5)] = 151868,	--GGC armory cage X alt 2	(may be reversed)
			[Vector3(3445, 1547, -195.5)] = 151869,	--GGC armory cage Y alt 2	(may be reversed)
		},
	}
	
	function ObjectInteractionManager:init(...)
		init_original(self, ...)
		
		self._queued_units = {}
		self._unit_triggers = {}
		self._trigger_blocks = {}
		
		GroupAIStateBase.register_listener_clbk("ObjectInteractionManager_cancel_pager_listener", "on_whisper_mode_change", callback(self, self, "_whisper_mode_change"))
	end
	
	function ObjectInteractionManager:update(t, ...)
		update_original(self, t, ...)
		self:_check_queued_units(t)
	end
	
	function ObjectInteractionManager:add_unit(unit, ...)		
		for pos, trigger_id in pairs(ObjectInteractionManager.INTERACTION_TRIGGERS[unit:interaction().tweak_data] or {}) do
			if mvector3.distance(unit:position(), pos) <= 10 then
				self:block_trigger(trigger_id, true)
				break
			end
		end
	
		table.insert(self._queued_units, unit)
		return add_unit_original(self, unit, ...)
	end
	
	function ObjectInteractionManager:remove_unit(unit, ...)
		for pos, trigger_id in pairs(ObjectInteractionManager.INTERACTION_TRIGGERS[unit:interaction().tweak_data] or {}) do
			if mvector3.distance(unit:position(), pos) <= 10 then
				self._trigger_blocks[trigger_id] = false
				break
			end
		end
	
		self:_check_remove_unit(unit)
		return remove_unit_original(self, unit, ...)
	end
	
	function ObjectInteractionManager:_check_queued_units(t)
		local level_id = managers.job:current_level_id()
		
		for i, unit in ipairs(self._queued_units) do
			if alive(unit) then
				local editor_id = unit:editor_id()
				local interaction_id = unit:interaction().tweak_data

				if false then --ObjectInteractionManager.EQUIPMENT_INTERACTION_ID[interaction_id] then
					local data = ObjectInteractionManager.EQUIPMENT_INTERACTION_ID[interaction_id]
					local blocked
					
					for trigger_id, editor_ids in pairs(ObjectInteractionManager.TRIGGERS) do
						if table.contains(editor_ids, editor_id) then							
							blocked = self._trigger_blocks[trigger_id]
							self._unit_triggers[trigger_id] = self._unit_triggers[trigger_id] or {}
							table.insert(self._unit_triggers[trigger_id], { unit = unit, class = data.class, offset = data.offset })
							break
						end
					end
					
					unit:base():set_equipment_active(data.class, not blocked, data.offset)
				end
				
				self._do_listener_callback("on_unit_added", unit)
			end
		end
		
		self._queued_units = {}
	end
	
	function ObjectInteractionManager:_check_remove_unit(unit)
		for i, queued_unit in ipairs(self._queued_units) do
			if queued_unit:key() == unit:key() then
				table.remove(self._queued_units, i)
				return
			end
		end
		
		local editor_id = unit:editor_id()
		local interaction_id = unit:interaction().tweak_data
		
		if false then --ObjectInteractionManager.EQUIPMENT_INTERACTION_ID[interaction_id] then
			unit:base():set_equipment_active(ObjectInteractionManager.EQUIPMENT_INTERACTION_ID[interaction_id].class, false)
		end
		
		self._do_listener_callback("on_unit_removed", unit)
	end
	
	function ObjectInteractionManager:block_trigger(trigger_id, status)
		if ObjectInteractionManager.TRIGGERS[trigger_id] then
			--io.write("ObjectInteractionManager:block_trigger(" .. tostring(trigger_id) .. ", " .. tostring(status) .. ")\n")
			self._trigger_blocks[trigger_id] = status
			
			for id, data in ipairs(self._unit_triggers[trigger_id] or {}) do
				if alive(data.unit) then
					--io.write("Set active " .. tostring(data.unit:editor_id()) .. ": " .. tostring(not status) .. "\n")
					data.unit:base():set_equipment_active(data.class, not status, data.offset)
				end
			end
		end
	end
	
end

if RequiredScript == "lib/units/props/missiondoor" then

	local deactivate_original = MissionDoor.deactivate
	
	function MissionDoor:deactivate(...)
		managers.interaction:block_trigger(self._unit:editor_id(), false)
		return deactivate_original(self, ...)
	end
	
end
]]