--namedSpawnables (SERVER)

--Configure
local showOnVehicleSpawn = true
local showOnVehicleEdited = true
local showOnVehicleDeleted = true

pluginName = debug.getinfo(1).source:sub(2)
local s, e
resources = debug.getinfo(1).source:sub(2)
local s, e = resources:find("\\")
resources = resources:sub(0,e-1)
local s, e = resources:find("Server")
resources = resources:sub(1,s-2)
s, e = pluginName:find("\\")
pluginName = pluginName:sub(s+1)
s, e = pluginName:find("\\")
pluginName = pluginName:sub(1,s-1)
package.path = package.path .. ";;" .. resources .. "/Server/" .. pluginName .. "/?.lua;;".. resources .. "/Server/" .. pluginName .. "/lua/?.lua"

json = require("json")
toml = require("toml")

function onInit()
	print("[namedSpawnables] ========== namedSpawnables initializing =========")
	RegisterEvent("onPlayerConnecting","onPlayerConnecting")
	RegisterEvent("onPlayerDisconnect","onPlayerDisconnect")
	RegisterEvent("onVehicleSpawn","onVehicleSpawn")
	RegisterEvent("onVehicleEdited","onVehicleEdited")
	RegisterEvent("onVehicleDeleted","onVehicleDeleted")
	print("[namedSpawnables] ========== namedSpawnables Initialized ==========")
end

function readCfg(path)
	local tomlFile, error = io.open(path, 'r')
	if error then return nil, error end
	local tomlText = tomlFile:read("*a")
	tomlFile:close()
	local cfg = toml.parse(tomlText)
	if cfg.General and cfg.General.Name then -- remove special chars from server name
		cfg.General.rawName = cfg.General.Name
		cfg.Name = cfg.General.Name
		local s,e = cfg.Name:find('%^')
		while s ~= nil do
			cfg.Name = cfg.Name:sub(0,s-1) .. cfg.Name:sub(s+2)
			s,e = cfg.Name:find('%^')
		end
	end
	return cfg
end

local beamMPconfig = {}
local currentcfg = {}
local beamMPcfg = readCfg("ServerConfig.toml").General
local beamMPconfigMetatable = {
	__index = function(table, key)
		return currentcfg[key] or beamMPcfg[key]
	end,
	__newindex = function(table, key, value)
		if key == "Debug" then
			Set(0, value)
		elseif key == "Private" then
			Set(1, value)
		elseif key == "MaxCars" then
			Set(2, value)
		elseif key == "MaxPlayers" then
			Set(3, value)
		elseif key == "Map" then
			Set(4, value)
		elseif key == "Name" then 
			Set(5, value)
		elseif key == "Description" then
			Set(6, value)
		else
			return nil
		end
		currentcfg[key] = value
	end
}

setmetatable(beamMPconfig, beamMPconfigMetatable)

local players = {}

local paths = {
	--Stock Vehicles
	--Autobello
	autobello_110_m = "vehicles/autobello/110_m.pc",
	autobello_110a_m = "vehicles/autobello/110a_m.pc",
	autobello_110b_m = "vehicles/autobello/110b_m.pc",
	autobello_130_m = "vehicles/autobello/130_m.pc",
	autobello_130a_m = "vehicles/autobello/130a_m.pc",
	autobello_130b_m = "vehicles/autobello/130b_m.pc",
	autobello_150 = "vehicles/autobello/150.pc",
	autobello_150_rally = "vehicles/autobello/150_rally.pc",
	autobello_150_track = "vehicles/autobello/150_track.pc",
	autobello_baja = "vehicles/autobello/baja.pc",
	autobello_carabinieri = "vehicles/autobello/carabinieri.pc",
	autobello_street = "vehicles/autobello/street.pc",
	autobello_tricolore = "vehicles/autobello/tricolore.pc",
	--Barstow
	barstow_291a = "vehicles/barstow/291a.pc",
	barstow_291a_sport = "vehicles/barstow/291a_sport.pc",
	barstow_291m = "vehicles/barstow/291m.pc",
	barstow_291m_sport = "vehicles/barstow/291m_sport.pc",
	barstow_353a = "vehicles/barstow/353a.pc",
	barstow_353a_sport = "vehicles/barstow/353a_sport.pc",
	barstow_353m = "vehicles/barstow/353m.pc",
	barstow_353m_sport = "vehicles/barstow/353m_sport.pc",
	barstow_423a = "vehicles/barstow/423a.pc",
	barstow_423a_sport = "vehicles/barstow/423a_sport.pc",
	barstow_423m = "vehicles/barstow/423m.pc",
	barstow_423m_sport = "vehicles/barstow/423m_sport.pc",
	barstow_awful = "vehicles/barstow/awful.pc",
	barstow_custom = "vehicles/barstow/custom.pc",
	barstow_drag = "vehicles/barstow/drag.pc",
	barstow_drift = "vehicles/barstow/drift.pc",
	barstow_i6a = "vehicles/barstow/i6a.pc",
	barstow_i6m = "vehicles/barstow/i6m.pc",
	barstow_kingsnake = "vehicles/barstow/kingsnake.pc",
	barstow_lancehead = "vehicles/barstow/lancehead.pc",
	barstow_tracksport = "vehicles/barstow/tracksport.pc",
	--Bluebuck
	bluebuck_291a_2door = "vehicles/bluebuck/291a_2door.pc",
	bluebuck_291a_2door_mid = "vehicles/bluebuck/291a_2door_mid.pc",
	bluebuck_291a_4door = "vehicles/bluebuck/291a_4door.pc",
	bluebuck_291a_4door_mid = "vehicles/bluebuck/291a_4door_mid.pc",
	bluebuck_291m_2door = "vehicles/bluebuck/291m_2door.pc",
	bluebuck_291m_2door_mid = "vehicles/bluebuck/291m_2door_mid.pc",
	bluebuck_291m_4door = "vehicles/bluebuck/291m_4door.pc",
	bluebuck_291m_4door_mid = "vehicles/bluebuck/291m_4door_mid.pc",
	bluebuck_353a_2door = "vehicles/bluebuck/353a_2door.pc",
	bluebuck_353a_2door_hardtop = "vehicles/bluebuck/353a_2door_hardtop.pc",
	bluebuck_353a_4door = "vehicles/bluebuck/353a_4door.pc",
	bluebuck_353a_4door_hardtop = "vehicles/bluebuck/353a_4door_hardtop.pc",
	bluebuck_353m_2door = "vehicles/bluebuck/353m_2door.pc",
	bluebuck_353m_2door_hardtop = "vehicles/bluebuck/353m_2door_hardtop.pc",
	bluebuck_353m_4door = "vehicles/bluebuck/353m_4door.pc",
	bluebuck_353m_4door_hardtop = "vehicles/bluebuck/353m_4door_hardtop.pc",
	bluebuck_423a_2door_hardtop = "vehicles/bluebuck/423a_2door_hardtop.pc",
	bluebuck_423a_4door_hardtop = "vehicles/bluebuck/423a_4door_hardtop.pc",
	bluebuck_423m_2door_hardtop = "vehicles/bluebuck/423m_2door_hardtop.pc",
	bluebuck_423m_4door_hardtop = "vehicles/bluebuck/423m_4door_hardtop.pc",
	bluebuck_423m_roadsport = "vehicles/bluebuck/423m_roadsport.pc",
	bluebuck_custom = "vehicles/bluebuck/custom.pc",
	bluebuck_drag = "vehicles/bluebuck/drag.pc",
	bluebuck_drift = "vehicles/bluebuck/drift.pc",
	bluebuck_horrible = "vehicles/bluebuck/horrible.pc",
	bluebuck_i6a_2door = "vehicles/bluebuck/i6a_2door.pc",
	bluebuck_i6a_4door = "vehicles/bluebuck/i6a_4door.pc",
	bluebuck_i6m_2door = "vehicles/bluebuck/i6m_2door.pc",
	bluebuck_i6m_4door = "vehicles/bluebuck/i6m_4door.pc",
	bluebuck_interceptor = "vehicles/bluebuck/interceptor.pc",
	bluebuck_lowrider = "vehicles/bluebuck/lowrider.pc",
	bluebuck_police = "vehicles/bluebuck/police.pc",
	bluebuck_taxi = "vehicles/bluebuck/taxi.pc",
	bluebuck_track = "vehicles/bluebuck/track.pc",
	--Burnside
	burnside_2a = "vehicles/burnside/2a.pc",
	burnside_3a = "vehicles/burnside/3a.pc",
	burnside_custom = "vehicles/burnside/custom.pc",
	burnside_drag = "vehicles/burnside/drag.pc",
	burnside_leadsled = "vehicles/burnside/leadsled.pc",
	burnside_police = "vehicles/burnside/police.pc",
	burnside_taxi = "vehicles/burnside/taxi.pc",
	burnside_v8m = "vehicles/burnside/v8m.pc",
	--Citybus
	citybus_base = "vehicles/citybus/base.pc",
	citybus_city = "vehicles/citybus/city.pc",
	citybus_hero = "vehicles/citybus/hero.pc",
	citybus_highway = "vehicles/citybus/highway.pc",
	citybus_rambus = "vehicles/citybus/rambus.pc",
	citybus_safari = "vehicles/citybus/safari.pc",
	citybus_zebra = "vehicles/citybus/zebra.pc",
	--Coupe
	coupe_base_A = "vehicles/coupe/base_A.pc",
	coupe_base_M = "vehicles/coupe/base_M.pc",
	coupe_custom = "vehicles/coupe/custom.pc",
	coupe_demon = "vehicles/coupe/demon.pc",
	coupe_drag = "vehicles/coupe/drag.pc",
	coupe_drift = "vehicles/coupe/drift.pc",
	coupe_malodorous = "vehicles/coupe/malodorous.pc",
	coupe_police = "vehicles/coupe/police.pc",
	coupe_powerglow = "vehicles/coupe/powerglow.pc",
	coupe_race = "vehicles/coupe/race.pc",
	coupe_type_l_A = "vehicles/coupe/type-l_A.pc",
	coupe_type_l_M = "vehicles/coupe/type-l_M.pc",
	coupe_type_ls_A = "vehicles/coupe/type-ls_A.pc",
	coupe_type_ls_M = "vehicles/coupe/type-ls_M.pc",
	--ETK800
	etk800_drift = "vehicles/etk800/drift.pc",
	etk800_etk854t_A = "vehicles/etk800/etk854t_A.pc",
	etk800_etk854t_M = "vehicles/etk800/etk854t_M.pc",
	etk800_etk854tc_A = "vehicles/etk800/etk854tc_A.pc",
	etk800_etk854tc_M = "vehicles/etk800/etk854tc_M.pc",
	etk800_etk854td_A = "vehicles/etk800/etk854td_A.pc",
	etk800_etk854td_M = "vehicles/etk800/etk854td_M.pc",
	etk800_etk854tx_A = "vehicles/etk800/etk854tx_A.pc",
	etk800_etk854tx_M = "vehicles/etk800/etk854tx_M.pc",
	etk800_etk856t_A = "vehicles/etk800/etk856t_A.pc",
	etk800_etk856t_M = "vehicles/etk800/etk856t_M.pc",
	etk800_etk856tc_A = "vehicles/etk800/etk856tc_A.pc",
	etk800_etk856tc_M = "vehicles/etk800/etk856tc_M.pc",
	etk800_etk856td_A = "vehicles/etk800/etk856td_A.pc",
	etk800_etk856td_M = "vehicles/etk800/etk856td_M.pc",
	etk800_etk856ttsport_A = "vehicles/etk800/etk856ttsport_A.pc",
	etk800_etk856ttsport_M = "vehicles/etk800/etk856ttsport_M.pc",
	etk800_etk856ttsportplus_A = "vehicles/etk800/etk856ttsportplus_A.pc",
	etk800_etk856ttsportplus_M = "vehicles/etk800/etk856ttsportplus_M.pc",
	etk800_etk856tx_A = "vehicles/etk800/etk856tx_A.pc",
	etk800_etk856tx_A_driving_experience = "vehicles/etk800/etk856tx_A_driving_experience.pc",
	etk800_etk856tx_M = "vehicles/etk800/etk856tx_M.pc",
	etk800_police = "vehicles/etk800/police.pc",
	--ETKC
	etkc_drift = "vehicles/etkc/drift.pc",
	etkc_kc4t_A = "vehicles/etkc/kc4t_A.pc",
	etkc_kc4t_M = "vehicles/etkc/kc4t_M.pc",
	etkc_kc6_A = "vehicles/etkc/kc6_A.pc",
	etkc_kc6_M = "vehicles/etkc/kc6_M.pc",
	etkc_kc6d_A = "vehicles/etkc/kc6d_A.pc",
	etkc_kc6d_M = "vehicles/etkc/kc6d_M.pc",
	etkc_kc6dx_M_driving_experience = "vehicles/etkc/kc6dx_M_driving_experience.pc",
	etkc_kc6t_A = "vehicles/etkc/kc6t_A.pc",
	etkc_kc6t_M = "vehicles/etkc/kc6t_M.pc",
	etkc_kc6tx_A = "vehicles/etkc/kc6tx_A.pc",
	etkc_kc6tx_M = "vehicles/etkc/kc6tx_M.pc",
	etkc_police_highway_A = "vehicles/etkc/police_highway_A.pc",
	etkc_trackday_A = "vehicles/etkc/trackday_A.pc",
	--ETKI
	etki_2400_A = "vehicles/etki/2400_A.pc",
	etki_2400_A_alt = "vehicles/etki/2400_A_alt.pc",
	etki_2400_M = "vehicles/etki/2400_M.pc",
	etki_2400_M_alt = "vehicles/etki/2400_M_alt.pc",
	etki_2400i_A = "vehicles/etki/2400i_A.pc",
	etki_2400i_A_alt = "vehicles/etki/2400i_A_alt.pc",
	etki_2400i_M = "vehicles/etki/2400i_M.pc",
	etki_2400i_M_alt = "vehicles/etki/2400i_M_alt.pc",
	etki_2400ix_A = "vehicles/etki/2400ix_A.pc",
	etki_2400ix_A_alt = "vehicles/etki/2400ix_A_alt.pc",
	etki_2400ix_M = "vehicles/etki/2400ix_M.pc",
	etki_2400ix_M_alt = "vehicles/etki/2400ix_M_alt.pc",
	etki_2400ti_sport_evo_M = "vehicles/etki/2400ti_sport_evo_M.pc",
	etki_2400ti_sport_M = "vehicles/etki/2400ti_sport_M.pc",
	etki_2400ti_sport_M_alt = "vehicles/etki/2400ti_sport_M_alt.pc",
	etki_2400tix_sport_evo_M = "vehicles/etki/2400tix_sport_evo_M.pc",
	etki_2400tix_sport_M = "vehicles/etki/2400tix_sport_M.pc",
	etki_2400tix_sport_M_alt = "vehicles/etki/2400tix_sport_M_alt.pc",
	etki_3000i_A = "vehicles/etki/3000i_A.pc",
	etki_3000i_A_alt = "vehicles/etki/3000i_A_alt.pc",
	etki_3000i_M = "vehicles/etki/3000i_M.pc",
	etki_3000i_M_alt = "vehicles/etki/3000i_M_alt.pc",
	etki_3000ix_A = "vehicles/etki/3000ix_A.pc",
	etki_3000ix_A_alt = "vehicles/etki/3000ix_A_alt.pc",
	etki_3000ix_M = "vehicles/etki/3000ix_M.pc",
	etki_3000ix_M_alt = "vehicles/etki/3000ix_M_alt.pc",
	etki_cool = "vehicles/etki/cool.pc",
	etki_custom = "vehicles/etki/custom.pc",
	etki_drift = "vehicles/etki/drift.pc",
	etki_race = "vehicles/etki/race.pc",
	etki_rally = "vehicles/etki/rally.pc",
	--Fullsize
	fullsize_bcpd = "vehicles/fullsize/bcpd.pc",
	fullsize_custom = "vehicles/fullsize/custom.pc",
	fullsize_drag = "vehicles/fullsize/drag.pc",
	fullsize_drift = "vehicles/fullsize/drift.pc",
	fullsize_excop = "vehicles/fullsize/excop.pc",
	fullsize_fleet = "vehicles/fullsize/fleet.pc",
	fullsize_interceptor = "vehicles/fullsize/interceptor.pc",
	fullsize_lowrider = "vehicles/fullsize/lowrider.pc",
	fullsize_luxe = "vehicles/fullsize/luxe.pc",
	fullsize_miserable = "vehicles/fullsize/miserable.pc",
	fullsize_police = "vehicles/fullsize/police.pc",
	fullsize_roadsport = "vehicles/fullsize/roadsport.pc",
	fullsize_sport = "vehicles/fullsize/sport.pc",
	fullsize_stock = "vehicles/fullsize/stock.pc",
	fullsize_taxi = "vehicles/fullsize/taxi.pc",
	fullsize_track = "vehicles/fullsize/track.pc",
	fullsize_unmarked = "vehicles/fullsize/unmarked.pc",
	--Hatch
	hatch_custom = "vehicles/hatch/custom.pc",
	hatch_drag = "vehicles/hatch/drag.pc",
	hatch_DX_M = "vehicles/hatch/DX_M.pc",
	hatch_DXi_A = "vehicles/hatch/DXi_A.pc",
	hatch_DXi_M = "vehicles/hatch/DXi_M.pc",
	hatch_gtz = "vehicles/hatch/gtz.pc",
	hatch_gtz_special = "vehicles/hatch/gtz_special.pc",
	hatch_guineapig_hatch = "vehicles/hatch/guineapig_hatch.pc",
	hatch_LXi_A = "vehicles/hatch/LXi_A.pc",
	hatch_LXi_M = "vehicles/hatch/LXi_M.pc",
	hatch_pointless = "vehicles/hatch/pointless.pc",
	hatch_race = "vehicles/hatch/race.pc",
	hatch_rally = "vehicles/hatch/rally.pc",
	hatch_skidplate = "vehicles/hatch/skidplate.pc",
	hatch_sport = "vehicles/hatch/sport.pc",
	hatch_sport_alt = "vehicles/hatch/sport_alt.pc",
	hatch_student_driver = "vehicles/hatch/student_driver.pc",
	--Hopper
	hopper_carabinieri = "vehicles/hopper/carabinieri.pc",
	hopper_classic = "vehicles/hopper/classic.pc",
	hopper_crawler = "vehicles/hopper/crawler.pc",
	hopper_custom = "vehicles/hopper/custom.pc",
	hopper_desert_A = "vehicles/hopper/desert_A.pc",
	hopper_desert_M = "vehicles/hopper/desert_M.pc",
	hopper_drag = "vehicles/hopper/drag.pc",
	hopper_guineapig_hopper = "vehicles/hopper/guineapig_hopper.pc",
	hopper_lxt4_A = "vehicles/hopper/lxt4_A.pc",
	hopper_lxt4_M = "vehicles/hopper/lxt4_M.pc",
	hopper_lxt6_A = "vehicles/hopper/lxt6_A.pc",
	hopper_lxt6_M = "vehicles/hopper/lxt6_M.pc",
	hopper_offroad = "vehicles/hopper/offroad.pc",
	hopper_parkranger = "vehicles/hopper/parkranger.pc",
	hopper_race = "vehicles/hopper/race.pc",
	hopper_sheriff = "vehicles/hopper/sheriff.pc",
	hopper_sport_A = "vehicles/hopper/sport_A.pc",
	hopper_sport_M = "vehicles/hopper/sport_M.pc",
	hopper_xt4_A = "vehicles/hopper/xt4_A.pc",
	hopper_xt4_M = "vehicles/hopper/xt4_M.pc",
	hopper_xt6_A = "vehicles/hopper/xt6_A.pc",
	hopper_xt6_M = "vehicles/hopper/xt6_M.pc",
	hopper_zxt6_A = "vehicles/hopper/zxt6_A.pc",
	hopper_zxt6_M = "vehicles/hopper/zxt6_M.pc",
	--LeGran
	legran_base_i4_facelift_M = "vehicles/legran/base_i4_facelift_M.pc",
	legran_base_i4_M = "vehicles/legran/base_i4_M.pc",
	legran_base_i4_wagon_facelift_M = "vehicles/legran/base_i4_wagon_facelift_M.pc",
	legran_custom = "vehicles/legran/custom.pc",
	legran_derby = "vehicles/legran/derby.pc",
	legran_derby_wagon = "vehicles/legran/derby_wagon.pc",
	legran_detective = "vehicles/legran/detective.pc",
	legran_firechief = "vehicles/legran/firechief.pc",
	legran_luxe_v6_A = "vehicles/legran/luxe_v6_A.pc",
	legran_luxe_v6_wagon_A = "vehicles/legran/luxe_v6_wagon_A.pc",
	legran_police = "vehicles/legran/police.pc",
	legran_race = "vehicles/legran/race.pc",
	legran_rally = "vehicles/legran/rally.pc",
	legran_s_i4_A = "vehicles/legran/s_i4_A.pc",
	legran_s_i4_wagon_A = "vehicles/legran/s_i4_wagon_A.pc",
	legran_s_v6_A = "vehicles/legran/s_v6_A.pc",
	legran_s_v6_facelift_A = "vehicles/legran/s_v6_facelift_A.pc",
	legran_se_i4_A = "vehicles/legran/se_i4_A.pc",
	legran_se_i4_wagon_facelift_A = "vehicles/legran/se_i4_wagon_facelift_A.pc",
	legran_se_v6_A = "vehicles/legran/se_v6_A.pc",
	legran_se_v6_towing_A = "vehicles/legran/se_v6_towing_A.pc",
	legran_se_v6_wagon_facelift_A = "vehicles/legran/se_v6_wagon_facelift_A.pc",
	legran_se_v6_wagon_offroad_facelift_A = "vehicles/legran/se_v6_wagon_offroad_facelift_A.pc",
	legran_sport_s_i4_A = "vehicles/legran/sport_s_i4_A.pc",
	legran_sport_s_i4_M = "vehicles/legran/sport_s_i4_M.pc",
	legran_sport_s_v6_A = "vehicles/legran/sport_s_v6_A.pc",
	legran_sport_s_v6_M = "vehicles/legran/sport_s_v6_M.pc",
	legran_sport_se_i4_facelift_A = "vehicles/legran/sport_se_i4_facelift_A.pc",
	legran_sport_se_i4_facelift_M = "vehicles/legran/sport_se_i4_facelift_M.pc",
	legran_sport_se_v6_awd_facelift_A = "vehicles/legran/sport_se_v6_awd_facelift_A.pc",
	legran_sport_se_v6_awd_facelift_M = "vehicles/legran/sport_se_v6_awd_facelift_M.pc",
	legran_taxi = "vehicles/legran/taxi.pc",
	--Midsize
	midsize_custom = "vehicles/midsize/custom.pc",
	midsize_DX_A = "vehicles/midsize/DX_A.pc",
	midsize_DX_M = "vehicles/midsize/DX_M.pc",
	midsize_LX_A = "vehicles/midsize/LX_A.pc",
	midsize_LX_M = "vehicles/midsize/LX_M.pc",
	midsize_LX_V6_A = "vehicles/midsize/LX_V6_A.pc",
	midsize_LX_V6_M = "vehicles/midsize/LX_V6_M.pc",
	midsize_LX_V6_sport_A = "vehicles/midsize/LX_V6_sport_A.pc",
	midsize_LX_V6_sport_M = "vehicles/midsize/LX_V6_sport_M.pc",
	midsize_stanced = "vehicles/midsize/stanced.pc",
	midsize_turboburger = "vehicles/midsize/turboburger.pc",
	--Miramar
	miramar_base_A = "vehicles/miramar/base_A.pc",
	miramar_base_M = "vehicles/miramar/base_M.pc",
	miramar_custom = "vehicles/miramar/custom.pc",
	miramar_drift = "vehicles/miramar/drift.pc",
	miramar_luxe_A = "vehicles/miramar/luxe_A.pc",
	miramar_luxe_M = "vehicles/miramar/luxe_M.pc",
	miramar_race = "vehicles/miramar/race.pc",
	miramar_sport = "vehicles/miramar/sport.pc",
	--Moonhawk
	moonhawk_detective = "vehicles/moonhawk/detective.pc",
	moonhawk_drag = "vehicles/moonhawk/drag.pc",
	moonhawk_drive = "vehicles/moonhawk/drive.pc",
	moonhawk_i6a = "vehicles/moonhawk/i6a.pc",
	moonhawk_i6a_alt = "vehicles/moonhawk/i6a_alt.pc",
	moonhawk_i6m = "vehicles/moonhawk/i6m.pc",
	moonhawk_i6m_alt = "vehicles/moonhawk/i6m_alt.pc",
	moonhawk_powerglow = "vehicles/moonhawk/powerglow.pc",
	moonhawk_race = "vehicles/moonhawk/race.pc",
	moonhawk_terrible = "vehicles/moonhawk/terrible.pc",
	moonhawk_v8a = "vehicles/moonhawk/v8a.pc",
	moonhawk_v8a_alt = "vehicles/moonhawk/v8a_alt.pc",
	moonhawk_v8a_sport = "vehicles/moonhawk/v8a_sport.pc",
	moonhawk_v8a_sport_alt = "vehicles/moonhawk/v8a_sport_alt.pc",
	moonhawk_v8m = "vehicles/moonhawk/v8m.pc",
	moonhawk_v8m_alt = "vehicles/moonhawk/v8m_alt.pc",
	moonhawk_v8m_sport = "vehicles/moonhawk/v8m_sport.pc",
	moonhawk_v8m_sport_alt = "vehicles/moonhawk/v8m_sport_alt.pc",
	moonhawk_v8special = "vehicles/moonhawk/v8special.pc",
	--Pessima
	pessima_custom = "vehicles/pessima/custom.pc",
	pessima_derby = "vehicles/pessima/derby.pc",
	pessima_drift = "vehicles/pessima/drift.pc",
	pessima_DX_A = "vehicles/pessima/DX_A.pc",
	pessima_DX_M = "vehicles/pessima/DX_M.pc",
	pessima_GTz = "vehicles/pessima/GTz.pc",
	pessima_hillclimb = "vehicles/pessima/hillclimb.pc",
	pessima_HX_M = "vehicles/pessima/HX_M.pc",
	pessima_LX_A = "vehicles/pessima/LX_A.pc",
	pessima_LX_M = "vehicles/pessima/LX_M.pc",
	pessima_race = "vehicles/pessima/race.pc",
	pessima_rally = "vehicles/pessima/rally.pc",
	pessima_ZX_4ws_M = "vehicles/pessima/ZX_4ws_M.pc",
	pessima_ZX_M = "vehicles/pessima/ZX_M.pc",
	--Pickup
	pickup_D10_4wd_A = "vehicles/pickup/d10_4wd_A.pc",
	pickup_D10_4wd_parkranger = "vehicles/pickup/d10_4wd_parkranger.pc",
	pickup_D10_4wd_zeta_A = "vehicles/pickup/d10_4wd_zeta_A.pc",
	pickup_D10_423sport_A = "vehicles/pickup/d10_423sport_A.pc",
	pickup_D10_diesel_4wd_marauder_M = "vehicles/pickup/d10_diesel_4wd_marauder_M.pc",
	pickup_D10_ext_4wd_A = "vehicles/pickup/d10_ext_4wd_A.pc",
	pickup_D15_4wd_A = "vehicles/pickup/d15_4wd_A.pc",
	pickup_D15_4wd_A_facelift = "vehicles/pickup/d15_4wd_A_facelift.pc",
	pickup_D15_4wd_M = "vehicles/pickup/d15_4wd_M.pc",
	pickup_D15_4wd_offroad_M = "vehicles/pickup/d15_4wd_offroad_M.pc",
	pickup_D15_423sport_A = "vehicles/pickup/d15_423sport_A.pc",
	pickup_D15_A = "vehicles/pickup/d15_A.pc",
	pickup_D15_crew_4wd_M = "vehicles/pickup/d15_crew_4wd_M.pc",
	pickup_D15_crew_A_facelift = "vehicles/pickup/d15_crew_A_facelift.pc",
	pickup_D15_crew_M = "vehicles/pickup/d15_crew_M.pc",
	pickup_D15_crew_shortbed_4wd_A = "vehicles/pickup/d15_crew_shortbed_4wd_A.pc",
	pickup_D15_drift_M = "vehicles/pickup/d15_drift_M.pc",
	pickup_D15_ext_4wd_A = "vehicles/pickup/d15_ext_4wd_A.pc",
	pickup_D15_ext_4wd_M = "vehicles/pickup/d15_ext_4wd_M.pc",
	pickup_D15_ext_A = "vehicles/pickup/d15_ext_A.pc",
	pickup_D15_ext_A_facelift = "vehicles/pickup/d15_ext_A_facelift.pc",
	pickup_D15_ext_customclassic_M = "vehicles/pickup/d15_ext_customclassic_M.pc",
	pickup_D15_ext_longbed_A = "vehicles/pickup/d15_ext_longbed_A.pc",
	pickup_D15_ext_longbed_M = "vehicles/pickup/d15_ext_longbed_M.pc",
	pickup_D15_ext_M = "vehicles/pickup/d15_ext_M.pc",
	pickup_D15_farmhand_M = "vehicles/pickup/d15_farmhand_M.pc",
	pickup_D15_fleet_ext_M = "vehicles/pickup/d15_fleet_ext_M.pc",
	pickup_D15_fleet_ext_M_facelift = "vehicles/pickup/d15_fleet_ext_M_facelift.pc",
	pickup_D15_fleet_longbed_M = "vehicles/pickup/d15_fleet_longbed_M.pc",
	pickup_D15_fleet_M_facelift = "vehicles/pickup/d15_fleet_M_facelift.pc",
	pickup_D15_longbed_4wd_A = "vehicles/pickup/d15_longbed_4wd_A.pc",
	pickup_D15_longbed_4wd_M = "vehicles/pickup/d15_longbed_4wd_M.pc",
	pickup_D15_longbed_drag_A = "vehicles/pickup/d15_longbed_drag_A.pc",
	pickup_D15_M = "vehicles/pickup/d15_M.pc",
	pickup_D15_roadsport_awd_M = "vehicles/pickup/d15_roadsport_awd_M.pc",
	pickup_D15_streettuned_M = "vehicles/pickup/d15_streettuned_M.pc",
	pickup_D15_track_awd_M = "vehicles/pickup/d15_track_awd_M.pc",
	pickup_D25_crew_4wd_A = "vehicles/pickup/d25_crew_4wd_A.pc",
	pickup_D25_crew_4wd_A_facelift = "vehicles/pickup/d25_crew_4wd_A_facelift.pc",
	pickup_D25_crew_4wd_M = "vehicles/pickup/d25_crew_4wd_M.pc",
	pickup_D25_crew_A_facelift = "vehicles/pickup/d25_crew_A_facelift.pc",
	pickup_D25_crew_dually_A = "vehicles/pickup/d25_crew_dually_A.pc",
	pickup_D25_ext_longbed_4wd_A = "vehicles/pickup/d25_ext_longbed_4wd_A.pc",
	pickup_D25_ext_longbed_4wd_A_facelift = "vehicles/pickup/d25_ext_longbed_4wd_A_facelift.pc",
	pickup_D25_ext_longbed_4wd_M = "vehicles/pickup/d25_ext_longbed_4wd_M.pc",
	pickup_D25_ext_longbed_A = "vehicles/pickup/d25_ext_longbed_A.pc",
	pickup_D25_ext_longbed_dually_A_facelift = "vehicles/pickup/d25_ext_longbed_dually_A_facelift.pc",
	pickup_D25_longbed_4wd_A = "vehicles/pickup/d25_longbed_4wd_A.pc",
	pickup_D25_longbed_4wd_lifted_A = "vehicles/pickup/d25_longbed_4wd_lifted_A.pc",
	pickup_D25_longbed_4wd_M = "vehicles/pickup/d25_longbed_4wd_M.pc",
	pickup_D25_longbed_A = "vehicles/pickup/d25_longbed_A.pc",
	pickup_D25_longbed_M = "vehicles/pickup/d25_longbed_M.pc",
	pickup_D30_ext_4wd_kentarch_A = "vehicles/pickup/d30_ext_4wd_kentarch_A.pc",
	pickup_D35_4WD_ext_longbed_A = "vehicles/pickup/d35_4WD_ext_longbed_A.pc",
	pickup_D35_4WD_longbed_A = "vehicles/pickup/d35_4WD_longbed_A.pc",
	pickup_D35_4wd_pig_M = "vehicles/pickup/d35_4wd_pig_M.pc",
	pickup_D35_crew_4wd_beast_A = "vehicles/pickup/d35_crew_4wd_beast_A.pc",
	pickup_D35_crew_diesel_chiefrancher_A = "vehicles/pickup/d35_crew_diesel_chiefrancher_A.pc",
	pickup_D35_crew_dually_A = "vehicles/pickup/d35_crew_dually_A.pc",
	pickup_D35_disappointment_A = "vehicles/pickup/d35_disappointment_A.pc",
	pickup_D35_ext_chiefrancher_dually_A = "vehicles/pickup/d35_ext_chiefrancher_dually_A.pc",
	pickup_D35_ext_diesel_dually_M = "vehicles/pickup/d35_ext_diesel_dually_M.pc",
	pickup_D35_longbed_dually_A = "vehicles/pickup/d35_longbed_dually_A.pc",
	pickup_D35_longbed_dually_M = "vehicles/pickup/d35_longbed_dually_M.pc",
	pickup_D45_ambulance_A = "vehicles/pickup/d45_ambulance_A.pc",
	pickup_D45_cargobox_A = "vehicles/pickup/d45_cargobox_A.pc",
	pickup_D45_diesel_rollback_M = "vehicles/pickup/d45_diesel_rollback_M.pc",
	pickup_Deserttruck_crawler_A = "vehicles/pickup/deserttruck_crawler_A.pc",
	pickup_Deserttruck_crew_crawler_A = "vehicles/pickup/deserttruck_crew_crawler_A.pc",
	pickup_Deserttruck_prerunner_A = "vehicles/pickup/deserttruck_prerunner_A.pc",
	pickup_Deserttruck_prerunner_short_A = "vehicles/pickup/deserttruck_prerunner_short_A.pc",
	pickup_Deserttruck_rockracer_A = "vehicles/pickup/deserttruck_rockracer_A.pc",
	--Pigeon
	pigeon_base = "vehicles/pigeon/base.pc",
	pigeon_base_4w = "vehicles/pigeon/base_4w.pc",
	pigeon_cool_4w = "vehicles/pigeon/cool_4w.pc",
	pigeon_drag = "vehicles/pigeon/drag.pc",
	pigeon_offroad_4w = "vehicles/pigeon/offroad_4w.pc",
	pigeon_race = "vehicles/pigeon/race.pc",
	pigeon_stabilizer = "vehicles/pigeon/stabilizer.pc",
	pigeon_streetcleaning = "vehicles/pigeon/streetcleaning.pc",
	pigeon_van = "vehicles/pigeon/van.pc",
	pigeon_van_4w = "vehicles/pigeon/van_4w.pc",
	--Roamer
	roamer_4wd_facelift = "vehicles/roamer/4wd_facelift.pc",
	roamer_4wd_lxt_facelift = "vehicles/roamer/4wd_lxt_facelift.pc",
	roamer_4wd_xt_facelift = "vehicles/roamer/4wd_xt_facelift.pc",
	roamer_adventure = "vehicles/roamer/adventure.pc",
	roamer_derby = "vehicles/roamer/derby.pc",
	roamer_drag = "vehicles/roamer/drag.pc",
	roamer_facelift = "vehicles/roamer/facelift.pc",
	roamer_firechief = "vehicles/roamer/firechief.pc",
	roamer_i6_4wd_m = "vehicles/roamer/i6_4wd_m.pc",
	roamer_i6_m = "vehicles/roamer/i6_m.pc",
	roamer_lxt_facelift = "vehicles/roamer/lxt_facelift.pc",
	roamer_offroad = "vehicles/roamer/offroad.pc",
	roamer_police = "vehicles/roamer/police.pc",
	roamer_sheriff = "vehicles/roamer/sheriff.pc",
	roamer_sport = "vehicles/roamer/sport.pc",
	roamer_sport_ext = "vehicles/roamer/sport_ext.pc",
	roamer_sport_ext_m = "vehicles/roamer/sport_ext_m.pc",
	roamer_sport_m = "vehicles/roamer/sport_m.pc",
	roamer_street_tuned = "vehicles/roamer/street_tuned.pc",
	roamer_unmarked = "vehicles/roamer/unmarked.pc",
	roamer_v8 = "vehicles/roamer/v8.pc",
	roamer_v8_4wd = "vehicles/roamer/v8_4wd.pc",
	roamer_v8_4wd_lxt = "vehicles/roamer/v8_4wd_lxt.pc",
	roamer_v8_4wd_lxt_m = "vehicles/roamer/v8_4wd_lxt_m.pc",
	roamer_v8_4wd_m = "vehicles/roamer/v8_4wd_m.pc",
	roamer_v8_4wd_xt = "vehicles/roamer/v8_4wd_xt.pc",
	roamer_v8_4wd_xt_m = "vehicles/roamer/v8_4wd_xt_m.pc",
	roamer_v8_lxt = "vehicles/roamer/v8_lxt.pc",
	roamer_v8_lxt_35 = "vehicles/roamer/v8_lxt_35.pc",
	roamer_v8_lxt_35_m = "vehicles/roamer/v8_lxt_35_m.pc",
	roamer_v8_lxt_m = "vehicles/roamer/v8_lxt_m.pc",
	roamer_v8_m = "vehicles/roamer/v8_m.pc",
	roamer_v8_xt = "vehicles/roamer/v8_xt.pc",
	roamer_v8_xt_m = "vehicles/roamer/v8_xt_m.pc",
	roamer_xt_facelift = "vehicles/roamer/xt_facelift.pc",
	--SBR
	sbr_base_RWD_DCT = "vehicles/sbr/base_RWD_DCT.pc",
	sbr_base_RWD_M = "vehicles/sbr/base_RWD_M.pc",
	sbr_electric_300 = "vehicles/sbr/electric_300.pc",
	sbr_electric_500 = "vehicles/sbr/electric_500.pc",
	sbr_electric_800 = "vehicles/sbr/electric_800.pc",
	sbr_hillclimb = "vehicles/sbr/hillclimb.pc",
	sbr_hillclimb_SQ = "vehicles/sbr/hillclimb_SQ.pc",
	sbr_powerglow = "vehicles/sbr/powerglow.pc",
	sbr_S_AWD_DCT = "vehicles/sbr/S_AWD_DCT.pc",
	sbr_S_AWD_M = "vehicles/sbr/S_AWD_M.pc",
	sbr_S_RWD_DCT = "vehicles/sbr/S_RWD_DCT.pc",
	sbr_S_RWD_M = "vehicles/sbr/S_RWD_M.pc",
	sbr_TT_AWD_S_DCT = "vehicles/sbr/TT_AWD_S_DCT.pc",
	sbr_TT_AWD_S_M = "vehicles/sbr/TT_AWD_S_M.pc",
	sbr_TT_AWD_S2_DCT = "vehicles/sbr/TT_AWD_S2_DCT.pc",
	sbr_TT_AWD_S2_M = "vehicles/sbr/TT_AWD_S2_M.pc",
	sbr_TT_RWD_S_DCT = "vehicles/sbr/TT_RWD_S_DCT.pc",
	sbr_TT_RWD_S_M = "vehicles/sbr/TT_RWD_S_M.pc",
	--Semi
	semi_t65_base = "vehicles/semi/t65_base.pc",
	semi_t65_base_short = "vehicles/semi/t65_base_short.pc",
	semi_t65_cargobox = "vehicles/semi/t65_cargobox.pc",
	semi_t65_fifthwheel = "vehicles/semi/t65_fifthwheel.pc",
	semi_t65_fifthwheel_short = "vehicles/semi/t65_fifthwheel_short.pc",
	semi_t65_flatbed = "vehicles/semi/t65_flatbed.pc",
	semi_t65_ramplow = "vehicles/semi/t65_ramplow.pc",
	semi_t65_rollback = "vehicles/semi/t65_rollback.pc",
	semi_t75_base = "vehicles/semi/t75_base.pc",
	semi_t75_dumptruck = "vehicles/semi/t75_dumptruck.pc",
	semi_t75_fifthwheel = "vehicles/semi/t75_fifthwheel.pc",
	semi_t75_mixer = "vehicles/semi/t75_mixer.pc",
	semi_t75_patriot = "vehicles/semi/t75_patriot.pc",
	semi_t75_ramplow = "vehicles/semi/t75_ramplow.pc",
	semi_t75_sleeper = "vehicles/semi/t75_sleeper.pc",
	semi_t75_special = "vehicles/semi/t75_special.pc",
	--Sunburst
	sunburst_base_CVT = "vehicles/sunburst/base_CVT.pc",
	sunburst_base_M = "vehicles/sunburst/base_M.pc",
	sunburst_custom = "vehicles/sunburst/custom.pc",
	sunburst_drift = "vehicles/sunburst/drift.pc",
	sunburst_firwood_police = "vehicles/sunburst/firwood_police.pc",
	sunburst_firwood_police_RS = "vehicles/sunburst/firwood_police_RS.pc",
	sunburst_gendarmerie = "vehicles/sunburst/gendarmerie.pc",
	sunburst_hillclimb_SQ = "vehicles/sunburst/hillclimb_SQ.pc",
	sunburst_interceptor = "vehicles/sunburst/interceptor.pc",
	sunburst_offroad = "vehicles/sunburst/offroad.pc",
	sunburst_police = "vehicles/sunburst/police.pc",
	sunburst_race_DCT = "vehicles/sunburst/race_DCT.pc",
	sunburst_race_M = "vehicles/sunburst/race_M.pc",
	sunburst_rally_SQ = "vehicles/sunburst/rally_SQ.pc",
	sunburst_sport_DCT = "vehicles/sunburst/sport_DCT.pc",
	sunburst_sport_M = "vehicles/sunburst/sport_M.pc",
	sunburst_sport_RS_DCT = "vehicles/sunburst/sport_RS_DCT.pc",
	sunburst_sport_RS_M = "vehicles/sunburst/sport_RS_M.pc",
	sunburst_sport_S_DCT = "vehicles/sunburst/sport_S_DCT.pc",
	sunburst_sport_S_M = "vehicles/sunburst/sport_S_M.pc",
	--Super
	super_320 = "vehicles/super/320.pc",
	super_350 = "vehicles/super/350.pc",
	super_350gt = "vehicles/super/350gt.pc",
	super_390gtr = "vehicles/super/390gtr.pc",
	super_group4 = "vehicles/super/group4.pc",
	super_notte = "vehicles/super/notte.pc",
	super_polizia = "vehicles/super/polizia.pc",
	super_powerglow = "vehicles/super/powerglow.pc",
	--Van
	van_ambulance = "vehicles/van/ambulance.pc",
	van_deliverytruck = "vehicles/van/deliverytruck.pc",
	van_derby = "vehicles/van/derby.pc",
	van_drift = "vehicles/van/drift.pc",
	van_h15_ext_vanster = "vehicles/van/h15_ext_vanster.pc",
	van_h15_vanster = "vehicles/van/h15_vanster.pc",
	van_h25_ext_vanster = "vehicles/van/h25_ext_vanster.pc",
	van_h25_vanster = "vehicles/van/h25_vanster.pc",
	van_h25_worker = "vehicles/van/h25_worker.pc",
	van_h35_ext_vanster = "vehicles/van/h35_ext_vanster.pc",
	van_h35_vanster = "vehicles/van/h35_vanster.pc",
	van_h45_chassiscab = "vehicles/van/h45_chassiscab.pc",
	van_h45_rollback = "vehicles/van/h45_rollback.pc",
	van_offroad = "vehicles/van/offroad.pc",
	van_offroad_alt = "vehicles/van/offroad_alt.pc",
	van_police = "vehicles/van/police.pc",
	van_street_tuned = "vehicles/van/street_tuned.pc",
	van_vantastic = "vehicles/van/vantastic.pc",
	--Vivace
	vivace_asphalt_SQ = "vehicles/vivace/asphalt_SQ.pc",
	vivace_gravel_SQ = "vehicles/vivace/gravel_SQ.pc",
	vivace_hillclimb_SQ = "vehicles/vivace/hillclimb_SQ.pc",
	vivace_race_SQ = "vehicles/vivace/race_SQ.pc",
	vivace_tograc_110_M = "vehicles/vivace/tograc_110_M.pc",
	vivace_tograc_110d_M = "vehicles/vivace/tograc_110d_M.pc",
	vivace_tograc_150dq_DCT = "vehicles/vivace/tograc_150dq_DCT.pc",
	vivace_tograc_150dq_M = "vehicles/vivace/tograc_150dq_M.pc",
	vivace_tograc_150dqX_DCT = "vehicles/vivace/tograc_150dqX_DCT.pc",
	vivace_tograc_160q_DCT = "vehicles/vivace/tograc_160q_DCT.pc",
	vivace_tograc_160q_M = "vehicles/vivace/tograc_160q_M.pc",
	vivace_tograc_190dq_DCT = "vehicles/vivace/tograc_190dq_DCT.pc",
	vivace_tograc_amrally_DCT = "vehicles/vivace/tograc_amrally_DCT.pc",
	vivace_tograc_polizia = "vehicles/vivace/tograc_polizia.pc",
	vivace_tograc_qE = "vehicles/vivace/tograc_qE.pc",
	vivace_trackday_M = "vehicles/vivace/trackday_M.pc",
	vivace_vivace_110_M = "vehicles/vivace/vivace_110_M.pc",
	vivace_vivace_110d_M = "vehicles/vivace/vivace_110d_M.pc",
	vivace_vivace_150d_DCT = "vehicles/vivace/vivace_150d_DCT.pc",
	vivace_vivace_150d_M = "vehicles/vivace/vivace_150d_M.pc",
	vivace_vivace_160_DCT = "vehicles/vivace/vivace_160_DCT.pc",
	vivace_vivace_160_M = "vehicles/vivace/vivace_160_M.pc",
	vivace_vivace_190Sd_DCT = "vehicles/vivace/vivace_190Sd_DCT.pc",
	vivace_vivace_230S_DCT = "vehicles/vivace/vivace_230S_DCT.pc",
	vivace_vivace_E = "vehicles/vivace/vivace_E.pc",
	vivace_vivace_polizia = "vehicles/vivace/vivace_polizia.pc",
	vivace_vivace_S_270_DCT = "vehicles/vivace/vivace_S_270_DCT.pc",
	vivace_vivace_S_270_M = "vehicles/vivace/vivace_S_270_M.pc",
	vivace_vivace_S_310_DCT = "vehicles/vivace/vivace_S_310_DCT.pc",
	vivace_vivace_S_310_M = "vehicles/vivace/vivace_S_310_M.pc",
	vivace_vivace_S_350q_DCT = "vehicles/vivace/vivace_S_350q_DCT.pc",
	vivace_vivace_S_350q_M = "vehicles/vivace/vivace_S_350q_M.pc",
	vivace_vivace_S_410q_DCT = "vehicles/vivace/vivace_S_410q_DCT.pc",
	vivace_vivace_S_410q_M = "vehicles/vivace/vivace_S_410q_M.pc",
	vivace_vivace_S_gendarmerie = "vehicles/vivace/vivace_S_gendarmerie.pc",
	--Wendover
	wendover_base_v6_A = "vehicles/wendover/base_v6_A.pc",
	wendover_base_v6_A_facelift = "vehicles/wendover/base_v6_A_facelift.pc",
	wendover_derby = "vehicles/wendover/derby.pc",
	wendover_hillclimb = "vehicles/wendover/hillclimb.pc",
	wendover_interceptor = "vehicles/wendover/interceptor.pc",
	wendover_race = "vehicles/wendover/race.pc",
	wendover_rally = "vehicles/wendover/rally.pc",
	wendover_s_v6_A = "vehicles/wendover/s_v6_A.pc",
	wendover_s_v6_A_facelift = "vehicles/wendover/s_v6_A_facelift.pc",
	wendover_safetycar = "vehicles/wendover/safetycar.pc",
	wendover_se_v6_A = "vehicles/wendover/se_v6_A.pc",
	wendover_se_v6_A_facelift = "vehicles/wendover/se_v6_A_facelift.pc",
	wendover_se_v8_A = "vehicles/wendover/se_v8_A.pc",
	wendover_se_v8_A_facelift = "vehicles/wendover/se_v8_A_facelift.pc",
	wendover_sport_s_v6_A = "vehicles/wendover/sport_s_v6_A.pc",
	wendover_sport_s_v6_A_facelift = "vehicles/wendover/sport_s_v6_A_facelift.pc",
	wendover_sport_se_v6_A = "vehicles/wendover/sport_se_v6_A.pc",
	wendover_sport_se_v6_A_facelift = "vehicles/wendover/sport_se_v6_A_facelift.pc",
	wendover_sport_se_v6_M = "vehicles/wendover/sport_se_v6_M.pc",
	wendover_sport_se_v6_M_facelift = "vehicles/wendover/sport_se_v6_M_facelift.pc",
	wendover_sport_se_v8_A = "vehicles/wendover/sport_se_v8_A.pc",
	wendover_sport_se_v8_A_facelift = "vehicles/wendover/sport_se_v8_A_facelift.pc",
	wendover_Street_tuned = "vehicles/wendover/Street_tuned.pc",
	wendover_super = "vehicles/wendover/super.pc",
	--Wigeon
	wigeon_base = "vehicles/wigeon/base.pc",
	wigeon_base_4w = "vehicles/wigeon/base_4w.pc",
	wigeon_drag = "vehicles/wigeon/drag.pc",
	wigeon_lx = "vehicles/wigeon/lx.pc",
	wigeon_lx_4w = "vehicles/wigeon/lx_4w.pc",
	wigeon_mantis = "vehicles/wigeon/mantis.pc",
	wigeon_pondskipper = "vehicles/wigeon/pondskipper.pc",

	--Stock Haulables
	--Box Utility
	boxutility_loaded_200 = "vehicles/boxutility/loaded_200.pc",
	boxutility_loaded_400 = "vehicles/boxutility/loaded_400.pc",
	boxutility_loaded_600 = "vehicles/boxutility/loaded_600.pc",
	boxutility_loaded_planks = "vehicles/boxutility/loaded_planks.pc",
	boxutility_unloaded = "vehicles/boxutility/unloaded.pc",
	--Box Utility Large
	boxutility_large_loaded_400 = "vehicles/boxutility_large/loaded_400.pc",
	boxutility_large_loaded_800 = "vehicles/boxutility_large/loaded_800.pc",
	boxutility_large_loaded_planks = "vehicles/boxutility_large/loaded_planks.pc",
	boxutility_large_loaded_planks_long = "vehicles/boxutility_large/loaded_planks_long.pc",
	boxutility_large_unloaded = "vehicles/boxutility_large/unloaded.pc",
	boxutility_large_unsafe = "vehicles/boxutility_large/unsafe.pc",
	--Caravan
	caravan_default = "vehicles/caravan/default.pc",
	caravan_empty = "vehicles/caravan/empty.pc",
	--Dryvan
	dryvan_clean = "vehicles/dryvan/clean.pc",
	dryvan_cola = "vehicles/dryvan/cola.pc",
	dryvan_cola_double = "vehicles/dryvan/cola_double.pc",
	dryvan_empty = "vehicles/dryvan/empty.pc",
	dryvan_loadingramp = "vehicles/dryvan/loadingramp.pc",
	--Flatbed
	flatbed_empty = "vehicles/flatbed/empty.pc",
	flatbed_Empty = "vehicles/flatbed/Empty.pc",
	flatbed_pipes_s = "vehicles/flatbed/pipes_s.pc",
	flatbed_woodplanks = "vehicles/flatbed/woodplanks.pc",
	flatbed_woodplanks_b = "vehicles/flatbed/woodplanks_b.pc",
	--Tanker
	tanker_diesel = "vehicles/tanker/diesel.pc",
	tanker_milk = "vehicles/tanker/milk.pc",
	tanker_petroleum = "vehicles/tanker/petroleum.pc",
	tanker_water = "vehicles/tanker/water.pc",
	--TSFB
	tsfb_loaded_400 = "vehicles/tsfb/loaded_400.pc",
	tsfb_loaded_800 = "vehicles/tsfb/loaded_800.pc",
	tsfb_loaded_planks = "vehicles/tsfb/loaded_planks.pc",
	tsfb_loaded_planks_long = "vehicles/tsfb/loaded_planks_long.pc",
	tsfb_unloaded = "vehicles/tsfb/unloaded.pc",

	--Stock Props
	--Ball
	ball = "ball",
	--Barrels
	barrels_empty = "vehicles/barrels/empty.pc",
	barrels_filled_oil = "vehicles/barrels/filled_oil.pc",
	--Barrier
	barrier = "barrier",
	--Blockwall
	blockwall = "blockwall",
	--Bollard
	bollard = "bollard",
	--Cannon
	cannon = "cannon",
	--Christmas Tree
	christmas_tree = "christmas_tree",
	--Cones
	cones_large = "vehicles/cones/large.pc",
	cones_small = "vehicles/cones/small.pc",
	--Flail
	flail = "flail",
	--Flipramp
	flipramp_large = "vehicles/flipramp/flipramp_large.pc",
	flipramp_medium = "vehicles/flipramp/flipramp_medium.pc",
	--Gate
	gate_4M = "vehicles/gate/4M.pc",
	gate_8M = "vehicles/gate/8M.pc",
	gate_4Meter = "4 Meter",
	--Haybale
	haybale = "haybale",
	--Inflated Mat
	inflated_mat = "inflated_mat",
	--Kickplate
	kickplate = "kickplate",
	--Large Angletester
	large_angletester = "large_angletester",
	--Large Bridge
	large_bridge = "large_bridge",
	--Large Cannon
	large_cannon = "large_cannon",
	--Large Crusher
	large_crusher = "large_crusher",
	--Large Hamster Wheel
	large_hamster_wheel = "large_hamster_wheel",
	--Large Roller
	large_roller = "large_roller",
	--Large Spinner
	large_spinner_base = "vehicles/large_spinner/base.pc",
	large_spinner_wall = "vehicles/large_spinner/wall.pc",
	--Large Tilt
	large_tilt = "large_tilt",
	--Mattress
	mattress_full = "vehicles/mattress/full.pc",
	mattress_full_alt = "vehicles/mattress/full_alt.pc",
	mattress_full_altb = "vehicles/mattress/full_altb.pc",
	mattress_king = "vehicles/mattress/king.pc",
	mattress_king_alt = "vehicles/mattress/king_alt.pc",
	mattress_king_altb = "vehicles/mattress/king_altb.pc",
	--Metal Box
	metal_box = "metal_box",
	--Metal Ramp
	metal_ramp_adjustable_metal_ramp = "vehicles/metal_ramp/adjustable_metal_ramp.pc",
	--Piano
	piano = "piano",
	--Roadsigns
	roadsigns_25mph = "vehicles/roadsigns/25mph.pc",
	roadsigns_35mph = "vehicles/roadsigns/35mph.pc",
	roadsigns_45mph = "vehicles/roadsigns/45mph.pc",
	roadsigns_55mph = "vehicles/roadsigns/55mph.pc",
	roadsigns_65mph = "vehicles/roadsigns/65mph.pc",
	roadsigns_stop = "vehicles/roadsigns/stop.pc",
	roadsigns_yield = "vehicles/roadsigns/yield.pc",
	--Rocks
	rocks_rock_stack = "vehicles/rocks/rock_stack.pc",
	rocks_rock1 = "vehicles/rocks/rock1.pc",
	rocks_rock2 = "vehicles/rocks/rock2.pc",
	rocks_rock3 = "vehicles/rocks/rock3.pc",
	rocks_rock4 = "vehicles/rocks/rock4.pc",
	rocks_rock5 = "vehicles/rocks/rock5.pc",
	rocks_rock6 = "vehicles/rocks/rock6.pc",
	rocks_rock7 = "vehicles/rocks/rock7.pc",
	rocks_rocks_three_large = "vehicles/rocks/rocks_three_large.pc",
	--Rollover
	rollover = "rollover",
	--Sawhorse
	sawhorse_closed = "vehicles/sawhorse/closed.pc",
	sawhorse_left = "vehicles/sawhorse/left.pc",
	sawhorse_lights = "vehicles/sawhorse/lights.pc",
	sawhorse_right = "vehicles/sawhorse/right.pc",
	sawhorse_stripes = "vehicles/sawhorse/stripes.pc",
	--Shipping Container
	shipping_container_container_beamng = "vehicles/shipping_container/container_beamng.pc",
	shipping_container_default = "default",
	--Streetlight
	streetlight = "streetlight",
	--Suspension Bridge
	suspensionbridge = "suspensionbridge",
	--Testroller
	testroller_multi = "vehicles/testroller/multi.pc",
	testroller_multi_straight = "vehicles/testroller/multi_straight.pc",
	testroller_multi_triple = "vehicles/testroller/multi_triple.pc",
	testroller_ramp = "vehicles/testroller/ramp.pc",
	testroller_ramp_etk = "vehicles/testroller/ramp_etk.pc",
	testroller_single = "vehicles/testroller/single.pc",
	--Tirestacks
	tirestacks = "tirestacks",
	--Tirewall
	tirewall_arrows_L = "vehicles/tirewall/arrows_L.pc",
	tirewall_arrows_R = "vehicles/tirewall/arrows_R.pc",
	tirewall_etk = "vehicles/tirewall/etk.pc",
	tirewall_gripall = "vehicles/tirewall/gripall.pc",
	tirewall_hirochi = "vehicles/tirewall/hirochi.pc",
	--Traffic Barrel
	trafficbarrel = "trafficbarrel",
	--Traffic Tube
	tube = "tube",
	--Wall
	wall = "wall",
	--Weightpad
	weightpad_multipad = "vehicles/weightpad/multipad.pc",
	weightpad_singlepad = "vehicles/weightpad/singlepad.pc",
	--Woodcrate
	woodcrate_large = "vehicles/woodcrate/large.pc",
	--Woodplanks
	woodplanks_large = "vehicles/woodplanks/large.pc",
	woodplanks_small = "vehicles/woodplanks/small.pc",

	--Stock Player Character
	--Unicycle
	unicycle_snowman = "vehicles/unicycle/snowman.pc",
	unicycle_with_mesh = "vehicles/unicycle/with_mesh.pc",
	unicycle_without_mesh = "vehicles/unicycle/without_mesh.pc"
	
	--add additional paths as a key value pair
	--make_configName = "path/to/config.pc"
}

local models = {
	--Stock Vehicles
	--Autobello
	autobello_110_m = "110",
	autobello_110a_m = "110 A",
	autobello_110b_m = "110 B",
	autobello_130_m = "130",
	autobello_130a_m = "130 A",
	autobello_130b_m = "130 B",
	autobello_150 = "150 Corse",
	autobello_150_rally = "150 Corse Rally - Gravel",
	autobello_150_track = "150 Corse Track",
	autobello_baja = "Baja",
	autobello_carabinieri = "Carabinieri",
	autobello_street = "Street Machine",
	autobello_tricolore = "Tricolore",
	--Barstow
	barstow_291a = "291 V8",
	barstow_291a_sport = "291 V8 RoadSport",
	barstow_291m = "291 V8",
	barstow_291m_sport = "291 V8 RoadSport",
	barstow_353a = "353 V8",
	barstow_353a_sport = "353 V8 RoadSport",
	barstow_353m = "353 V8",
	barstow_353m_sport = "353 V8 RoadSport",
	barstow_423a = "423 V8",
	barstow_423a_sport = "423 V8 RoadSport",
	barstow_423m = "423 V8",
	barstow_423m_sport = "423 V8 RoadSport",
	barstow_awful = "The Awful",
	barstow_custom = "Nightsnake",
	barstow_drag = "Drag",
	barstow_drift = "Drift",
	barstow_i6a = "232 I6",
	barstow_i6m = "232 I6",
	barstow_kingsnake = "Kingsnake",
	barstow_lancehead = "Lancehead",
	barstow_tracksport = "TrackSport",
	--Bluebuck
	bluebuck_291a_2door = "291 V8 2-Door Sedan",
	bluebuck_291a_2door_mid = "291 V8 Marshal 2-Door Sedan",
	bluebuck_291a_4door = "291 V8 4-Door Sedan",
	bluebuck_291a_4door_mid = "291 V8 Marshal 4-Door Sedan",
	bluebuck_291m_2door = "291 V8 2-Door Sedan",
	bluebuck_291m_2door_mid = "291 V8 Marshal 2-Door Sedan",
	bluebuck_291m_4door = "291 V8 4-Door Sedan",
	bluebuck_291m_4door_mid = "291 V8 Marshal 4-Door Sedan",
	bluebuck_353a_2door = "353 V8 Marshal 2-Door Sedan",
	bluebuck_353a_2door_hardtop = "353 V8 Marshal 2-Door Hardtop",
	bluebuck_353a_4door = "353 V8 Marshal 4-Door Sedan",
	bluebuck_353a_4door_hardtop = "353 V8 Marshal 4-Door Hardtop",
	bluebuck_353m_2door = "353 V8 Marshal 2-Door Sedan",
	bluebuck_353m_2door_hardtop = "353 V8 Marshal 2-Door Hardtop",
	bluebuck_353m_4door = "353 V8 Marshal 4-Door Sedan",
	bluebuck_353m_4door_hardtop = "353 V8 Marshal 4-Door Hardtop",
	bluebuck_423a_2door_hardtop = "423 V8 Sport 2-Door Hardtop",
	bluebuck_423a_4door_hardtop = "423 V8 Marshal 4-Door Hardtop",
	bluebuck_423m_2door_hardtop = "423 V8 Sport 2-Door Hardtop",
	bluebuck_423m_4door_hardtop = "423 V8 Marshal 4-Door Hardtop",
	bluebuck_423m_roadsport = "423 V8 RoadSport 2-Door Hardtop",
	bluebuck_custom = "Custom",
	bluebuck_drag = "Drag",
	bluebuck_drift = "Drift",
	bluebuck_horrible = "The Horrible",
	bluebuck_i6a_2door = "232 I6 2-Door Sedan",
	bluebuck_i6a_4door = "232 I6 4-Door Sedan",
	bluebuck_i6m_2door = "232 I6 2-Door Sedan",
	bluebuck_i6m_4door = "232 I6 4-Door Sedan",
	bluebuck_interceptor = "Police Interceptor",
	bluebuck_lowrider = "Lowrider",
	bluebuck_police = "Police Package",
	bluebuck_taxi = "Taxi",
	bluebuck_track = "Stock Car",
	--Burnside
	burnside_2a = "V8 Dual-Matic",
	burnside_3a = "V8 Super-Matic",
	burnside_custom = "Custom",
	burnside_drag = "Drag",
	burnside_leadsled = "Lead Sled",
	burnside_police = "Police",
	burnside_taxi = "Taxi",
	burnside_v8m = "V8",
	--Citybus
	citybus_base = "Base",
	citybus_city = "City",
	citybus_hero = "Hero",
	citybus_highway = "Highway",
	citybus_rambus = "Ram Bus",
	citybus_safari = "Safari",
	citybus_zebra = "Zebra",
	--Coupe
	coupe_base_A = "Base",
	coupe_base_M = "Base",
	coupe_custom = "Street Tuned",
	coupe_demon = "Demon",
	coupe_drag = "Drag",
	coupe_drift = "Drift",
	coupe_malodorous = "The Malodorous",
	coupe_police = "Special Pursuit Unit",
	coupe_powerglow = "Powerglow",
	coupe_race = "Track",
	coupe_type_l_A = "Type-L",
	coupe_type_l_M = "Type-L",
	coupe_type_ls_A = "Type-LS",
	coupe_type_ls_M = "Type-LS",
	--ETK800
	etk800_drift = "Drift",
	etk800_etk854t_A = "854t",
	etk800_etk854t_M = "854t",
	etk800_etk854tc_A = "854tc",
	etk800_etk854tc_M = "854tc",
	etk800_etk854td_A = "854td",
	etk800_etk854td_M = "854td",
	etk800_etk854tx_A = "854tx",
	etk800_etk854tx_M = "854tx",
	etk800_etk856t_A = "856t",
	etk800_etk856t_M = "856t",
	etk800_etk856tc_A = "856tc",
	etk800_etk856tc_M = "856tc",
	etk800_etk856td_A = "856td",
	etk800_etk856td_M = "856td",
	etk800_etk856ttsport_A = "856 ttSport",
	etk800_etk856ttsport_M = "856 ttSport",
	etk800_etk856ttsportplus_A = "856 ttSport+",
	etk800_etk856ttsportplus_M = "856 ttSport+",
	etk800_etk856tx_A = "856tx",
	etk800_etk856tx_A_driving_experience = "856tx Driving Experience",
	etk800_etk856tx_M = "856tx",
	etk800_police = "854t Polizei",
	--ETKC
	etkc_drift = "Drift",
	etkc_kc4t_A = "Kc4t",
	etkc_kc4t_M = "Kc4t",
	etkc_kc6_A = "Kc6",
	etkc_kc6_M = "Kc6",
	etkc_kc6d_A = "Kc6d",
	etkc_kc6d_M = "Kc6d",
	etkc_kc6dx_M_driving_experience = "Kc6dx Driving Experience",
	etkc_kc6t_A = "Kc6t",
	etkc_kc6t_M = "Kc6t",
	etkc_kc6tx_A = "Kc6tx",
	etkc_kc6tx_M = "Kc6tx",
	etkc_police_highway_A = "Highway Police",
	etkc_trackday_A = "Trackday",
	--ETKI
	etki_2400_A = "2400",
	etki_2400_A_alt = "2400 (Facelift)",
	etki_2400_M = "2400",
	etki_2400_M_alt = "2400 (Facelift)",
	etki_2400i_A = "2400i",
	etki_2400i_A_alt = "2400i (Facelift)",
	etki_2400i_M = "2400i",
	etki_2400i_M_alt = "2400i (Facelift)",
	etki_2400ix_A = "2400ix",
	etki_2400ix_A_alt = "2400ix (Facelift)",
	etki_2400ix_M = "2400ix",
	etki_2400ix_M_alt = "2400ix (Facelift)",
	etki_2400ti_sport_evo_M = "2400ti TTSport Evolution",
	etki_2400ti_sport_M = "2400ti TTSport",
	etki_2400ti_sport_M_alt = "2400ti TTSport (Facelift)",
	etki_2400tix_sport_evo_M = "2400tix TTSport Evolution",
	etki_2400tix_sport_M = "2400tix TTSport",
	etki_2400tix_sport_M_alt = "2400tix TTSport (Facelift)",
	etki_3000i_A = "3000i",
	etki_3000i_A_alt = "3000i (Facelift)",
	etki_3000i_M = "3000i",
	etki_3000i_M_alt = "3000i (Facelift)",
	etki_3000ix_A = "3000ix",
	etki_3000ix_A_alt = "3000ix (Facelift)",
	etki_3000ix_M = "3000ix",
	etki_3000ix_M_alt = "3000ix (Facelift)",
	etki_cool = "Knallhart",
	etki_custom = "Street Tuned",
	etki_drift = "Drift",
	etki_race = "Track",
	etki_rally = "Rally - Gravel",
	--Fullsize
	fullsize_bcpd = "Belasco City Police Department",
	fullsize_custom = "Street Tuned",
	fullsize_drag = "Drag",
	fullsize_drift = "Drift Missile",
	fullsize_excop = "Police Package (Retired)",
	fullsize_fleet = "Fleet",
	fullsize_interceptor = "Police Interceptor",
	fullsize_lowrider = "Lowrider",
	fullsize_luxe = "V8 Luxe",
	fullsize_miserable = "The Miserable",
	fullsize_police = "Police Package",
	fullsize_roadsport = "V8 RoadSport",
	fullsize_sport = "V8 Sport",
	fullsize_stock = "V8",
	fullsize_taxi = "Taxi",
	fullsize_track = "Track",
	fullsize_unmarked = "Police Package (Unmarked)",
	--Hatch
	hatch_custom = "Street Tuned",
	hatch_drag = "Drag",
	hatch_DX_M = "1.5 DX",
	hatch_DXi_A = "1.5 DXi",
	hatch_DXi_M = "1.5 DXi",
	hatch_gtz = "2.0 GTz",
	hatch_gtz_special = "2.0 GTz Special Edition",
	hatch_guineapig_hatch = "Guinea Pig",
	hatch_LXi_A = "1.5 LXi",
	hatch_LXi_M = "1.5 LXi",
	hatch_pointless = "The Pointless",
	hatch_race = "Track",
	hatch_rally = "Rally - Gravel",
	hatch_skidplate = "The Skidplate",
	hatch_sport = "1.5 ZXi",
	hatch_sport_alt = "1.5 ZXi Special Edition",
	hatch_student_driver = "Student Driver",
	--Hopper
	hopper_carabinieri = "Carabinieri",
	hopper_classic = "Classic",
	hopper_crawler = "Crawler",
	hopper_custom = "Custom",
	hopper_desert_A = "Dune Edition",
	hopper_desert_M = "Dune Edition",
	hopper_drag = "Drag",
	hopper_guineapig_hopper = "Guinea Pig",
	hopper_lxt4_A = "LXT-4",
	hopper_lxt4_M = "LXT-4",
	hopper_lxt6_A = "LXT-6",
	hopper_lxt6_M = "LXT-6",
	hopper_offroad = "Off-Road",
	hopper_parkranger = "Park Ranger",
	hopper_race = "Trackday",
	hopper_sheriff = "Sheriff",
	hopper_sport_A = "Sport Special",
	hopper_sport_M = "Sport Special",
	hopper_xt4_A = "XT-4",
	hopper_xt4_M = "XT-4",
	hopper_xt6_A = "XT-6",
	hopper_xt6_M = "XT-6",
	hopper_zxt6_A = "ZXT-6",
	hopper_zxt6_M = "ZXT-6",
	--LeGran
	legran_base_i4_facelift_M = "Regulier (Facelift)",
	legran_base_i4_M = "Regulier",
	legran_base_i4_wagon_facelift_M = "Regulier Wagon (Facelift)",
	legran_custom = "Custom",
	legran_derby = "The Atrocious",
	legran_derby_wagon = "The Objectionable",
	legran_detective = "Detective Special (Facelift)",
	legran_firechief = "Fire Chief (Facelift)",
	legran_luxe_v6_A = "Luxe V6",
	legran_luxe_v6_wagon_A = "Luxe Grandiose V6",
	legran_police = "Police Package",
	legran_race = "Race",
	legran_rally = "Rally",
	legran_s_i4_A = "S",
	legran_s_i4_wagon_A = "S Wagon",
	legran_s_v6_A = "S V6",
	legran_s_v6_facelift_A = "S V6 (Facelift)",
	legran_se_i4_A = "SE",
	legran_se_i4_wagon_facelift_A = "SE Wagon (Facelift)",
	legran_se_v6_A = "SE V6",
	legran_se_v6_towing_A = "SE V6 Towing Package",
	legran_se_v6_wagon_facelift_A = "SE V6 Wagon (Facelift)",
	legran_se_v6_wagon_offroad_facelift_A = "SE Campagne (Facelift)",
	legran_sport_s_i4_A = "Sport S",
	legran_sport_s_i4_M = "Sport S",
	legran_sport_s_v6_A = "Sport S V6",
	legran_sport_s_v6_M = "Sport S V6",
	legran_sport_se_i4_facelift_A = "Sport SE (Facelift)",
	legran_sport_se_i4_facelift_M = "Sport SE (Facelift)",
	legran_sport_se_v6_awd_facelift_A = "Sport SE V6 AWD (Facelift)",
	legran_sport_se_v6_awd_facelift_M = "Sport SE V6 AWD (Facelift)",
	legran_taxi = "Taxi Wagon",
	--Midsize
	midsize_custom = "Street Tuned",
	midsize_DX_A = "1.8 DX",
	midsize_DX_M = "1.8 DX",
	midsize_LX_A = "2.0 LX",
	midsize_LX_M = "2.0 LX",
	midsize_LX_V6_A = "2.7 LX V6",
	midsize_LX_V6_M = "2.7 LX V6",
	midsize_LX_V6_sport_A = "2.7 LX V6 Sport",
	midsize_LX_V6_sport_M = "2.7 LX V6 Sport",
	midsize_stanced = "Stanced",
	midsize_turboburger = "1.8 DX TurboBurger",
	--Miramar
	miramar_base_A = "Base Mira-Matic",
	miramar_base_M = "Base",
	miramar_custom = "Street Tuned",
	miramar_drift = "Drift",
	miramar_luxe_A = "Luxe Mira-Matic",
	miramar_luxe_M = "Luxe",
	miramar_race = "Track",
	miramar_sport = "GTz",
	--Moonhawk
	moonhawk_detective = "Detective Special",
	moonhawk_drag = "Drag",
	moonhawk_drive = "Elite Custom",
	moonhawk_i6a = "I6 (Facelift)",
	moonhawk_i6a_alt = "I6",
	moonhawk_i6m = "I6 (Facelift)",
	moonhawk_i6m_alt = "I6",
	moonhawk_powerglow = "Powerglow",
	moonhawk_race = "Track",
	moonhawk_terrible = "The Terrible",
	moonhawk_v8a = "V8 (Facelift)",
	moonhawk_v8a_alt = "V8",
	moonhawk_v8a_sport = "V8 Sport (Facelift)",
	moonhawk_v8a_sport_alt = "V8 Sport",
	moonhawk_v8m = "V8 (Facelift)",
	moonhawk_v8m_alt = "V8",
	moonhawk_v8m_sport = "V8 Sport (Facelift)",
	moonhawk_v8m_sport_alt = "V8 Sport",
	moonhawk_v8special = "V8 Special",
	--Pessima
	pessima_custom = "Street Tuned",
	pessima_derby = "The Pessimistic",
	pessima_drift = "Drift",
	pessima_DX_A = "1.8 DX",
	pessima_DX_M = "1.8 DX",
	pessima_GTz = "2.0 GTz",
	pessima_hillclimb = "Hillclimb - Asphalt",
	pessima_HX_M = "1.8 HX",
	pessima_LX_A = "2.0 LX",
	pessima_LX_M = "2.0 LX",
	pessima_race = "Track",
	pessima_rally = "Rally - Gravel",
	pessima_ZX_4ws_M = "2.0 ZX AWS",
	pessima_ZX_M = "2.0 ZX",
	--Pickup
	pickup_D10_4wd_A = "D10 Charro V8 4WD",
	pickup_D10_4wd_parkranger = "D10 Park Ranger",
	pickup_D10_4wd_zeta_A = "D10 Zeta",
	pickup_D10_423sport_A = "D10 Charro 423 Sport",
	pickup_D10_diesel_4wd_marauder_M = "L-TRV Marauder",
	pickup_D10_ext_4wd_A = "Kentarch D10 V8 4WD",
	pickup_D15_4wd_A = "D15 V8 4WD",
	pickup_D15_4wd_A_facelift = "D15 V8 4WD (Facelift)",
	pickup_D15_4wd_M = "D15 V8 4WD",
	pickup_D15_4wd_offroad_M = "D15 Off-Road",
	pickup_D15_423sport_A = "D15 423 Sport",
	pickup_D15_A = "D15 V8",
	pickup_D15_crew_4wd_M = "D15 V8 4WD Crew Cab",
	pickup_D15_crew_A_facelift = "D15 V8 Crew Cab (Facelift)",
	pickup_D15_crew_M = "D15 V8 Crew Cab",
	pickup_D15_crew_shortbed_4wd_A = "D15 4WD Crew Cab Short Bed",
	pickup_D15_drift_M = "D15 Drift",
	pickup_D15_ext_4wd_A = "D15 4WD Extended Cab",
	pickup_D15_ext_4wd_M = "D15 V8 4WD Extended Cab",
	pickup_D15_ext_A = "D15 V8 Extended Cab",
	pickup_D15_ext_A_facelift = "D15 V8 Extended Cab (Facelift)",
	pickup_D15_ext_customclassic_M = "D15 Custom Classic",
	pickup_D15_ext_longbed_A = "D15 V8 Extended Cab Long Bed",
	pickup_D15_ext_longbed_M = "D15 V8 Extended Cab Long Bed",
	pickup_D15_ext_M = "D15 V8 Extended Cab",
	pickup_D15_farmhand_M = "D15 Farmhand",
	pickup_D15_fleet_ext_M = "D15 Fleet Extended Cab",
	pickup_D15_fleet_ext_M_facelift = "D15 Fleet Extended Cab (Facelift)",
	pickup_D15_fleet_longbed_M = "D15 Fleet Long Bed",
	pickup_D15_fleet_M_facelift = "D15 Fleet (Facelift)",
	pickup_D15_longbed_4wd_A = "D15 V8 4WD Long Bed",
	pickup_D15_longbed_4wd_M = "D15 V8 4WD Long Bed",
	pickup_D15_longbed_drag_A = "D15 Drag",
	pickup_D15_M = "D15 V8",
	pickup_D15_roadsport_awd_M = "D15 V8 RoadSport",
	pickup_D15_streettuned_M = "D15 Street Tuned",
	pickup_D15_track_awd_M = "D15 Track",
	pickup_D25_crew_4wd_A = "D25 V8 4WD Crew Cab",
	pickup_D25_crew_4wd_A_facelift = "D25 V8 4WD Crew Cab (Facelift)",
	pickup_D25_crew_4wd_M = "D25 V8 4WD Crew Cab",
	pickup_D25_crew_A_facelift = "D25 V8 Crew Cab (Facelift)",
	pickup_D25_crew_dually_A = "D25 V8 Crew Cab Dually",
	pickup_D25_ext_longbed_4wd_A = "D25 V8 4WD Extended Cab Long Bed",
	pickup_D25_ext_longbed_4wd_A_facelift = "D25 V8 4WD Extended Cab Long Bed (Facelift)",
	pickup_D25_ext_longbed_4wd_M = "D25 V8 4WD Extended Cab Long Bed",
	pickup_D25_ext_longbed_A = "D25 V8 Extended Cab Long Bed",
	pickup_D25_ext_longbed_dually_A_facelift = "D25 V8 Extended Cab Dually (Facelift)",
	pickup_D25_longbed_4wd_A = "D25 V8 4WD Long Bed",
	pickup_D25_longbed_4wd_lifted_A = "D25 Lifted",
	pickup_D25_longbed_4wd_M = "D25 V8 4WD Long Bed",
	pickup_D25_longbed_A = "D25 Fleet Long Bed",
	pickup_D25_longbed_M = "D25 Fleet V8 Long Bed",
	pickup_D30_ext_4wd_kentarch_A = "Kentarch D30 V8 4WD",
	pickup_D35_4WD_ext_longbed_A = "D35 4WD Extended Cab Long Bed V8",
	pickup_D35_4WD_longbed_A = "D35 4WD Long Bed V8",
	pickup_D35_4wd_pig_M = "D35 'Pig'",
	pickup_D35_crew_4wd_beast_A = "D35 'Beast'",
	pickup_D35_crew_diesel_chiefrancher_A = "D35 Chief Rancher Diesel",
	pickup_D35_crew_dually_A = "D35 V8 Crew Cab Dually",
	pickup_D35_disappointment_A = "The Disappointment",
	pickup_D35_ext_chiefrancher_dually_A = "D35 Chief Rancher V8 Dually",
	pickup_D35_ext_diesel_dually_M = "D35 Diesel V8 Extended Cab Dually",
	pickup_D35_longbed_dually_A = "D35 Fleet V8 Dually",
	pickup_D35_longbed_dually_M = "D35 Fleet V8 Dually",
	pickup_D45_ambulance_A = "D45 Ambulance",
	pickup_D45_cargobox_A = "D45 Cargo Box Upfit",
	pickup_D45_diesel_rollback_M = "D45 Diesel Rollback Upfit",
	pickup_Deserttruck_crawler_A = "D35 'SuperPig'",
	pickup_Deserttruck_crew_crawler_A = "D15 Crawler Crew Cab",
	pickup_Deserttruck_prerunner_A = "D15 Pre-Runner Extended Cab",
	pickup_Deserttruck_prerunner_short_A = "D15 Pre-Runner",
	pickup_Deserttruck_rockracer_A = "D15 Rock Racer",
	--Pigeon
	pigeon_base = "Base",
	pigeon_base_4w = "Plus",
	pigeon_cool_4w = "Cool",
	pigeon_drag = "Drag",
	pigeon_offroad_4w = "Rock Dove",
	pigeon_race = "Race",
	pigeon_stabilizer = "The Stabilizer",
	pigeon_streetcleaning = "Street Cleaner",
	pigeon_van = "Van",
	pigeon_van_4w = "Van Plus",
	--Roamer
	roamer_4wd_facelift = "4WD Base (Facelift)",
	roamer_4wd_lxt_facelift = "4WD LXT (Facelift)",
	roamer_4wd_xt_facelift = "4WD XT (Facelift)",
	roamer_adventure = "Adventure",
	roamer_derby = "The Horrendous",
	roamer_drag = "Drag",
	roamer_facelift = "Base (Facelift)",
	roamer_firechief = "Fire Chief",
	roamer_i6_4wd_m = "I6 4WD",
	roamer_i6_m = "I6",
	roamer_lxt_facelift = "LXT (Facelift)",
	roamer_offroad = "Off-Road",
	roamer_police = "Belasco City Police Department",
	roamer_sheriff = "Sheriff",
	roamer_sport = "V8 RoadSport",
	roamer_sport_ext = "V8 RoadSport LXT",
	roamer_sport_ext_m = "V8 RoadSport LXT",
	roamer_sport_m = "V8 RoadSport",
	roamer_street_tuned = "Street Tuned",
	roamer_unmarked = "LXT35 Police Package (Unmarked)",
	roamer_v8 = "V8",
	roamer_v8_4wd = "V8 4WD",
	roamer_v8_4wd_lxt = "V8 4WD LXT",
	roamer_v8_4wd_lxt_m = "V8 4WD LXT",
	roamer_v8_4wd_m = "V8 4WD",
	roamer_v8_4wd_xt = "V8 4WD XT",
	roamer_v8_4wd_xt_m = "V8 4WD XT",
	roamer_v8_lxt = "V8 LXT",
	roamer_v8_lxt_35 = "Diesel V8 LXT35",
	roamer_v8_lxt_35_m = "Diesel V8 LXT35",
	roamer_v8_lxt_m = "V8 LXT",
	roamer_v8_m = "V8",
	roamer_v8_xt = "V8 XT",
	roamer_v8_xt_m = "V8 XT",
	roamer_xt_facelift = "XT (Facelift)",
	--SBR
	sbr_base_RWD_DCT = "RWD Base",
	sbr_base_RWD_M = "RWD Base",
	sbr_electric_300 = "eSBR 300",
	sbr_electric_500 = "eSBR 500",
	sbr_electric_800 = "eSBR 800",
	sbr_hillclimb = "Hillclimb - Asphalt",
	sbr_hillclimb_SQ = "Hillclimb - Asphalt",
	sbr_powerglow = "Powerglow",
	sbr_S_AWD_DCT = "AWD S",
	sbr_S_AWD_M = "AWD S",
	sbr_S_RWD_DCT = "RWD S",
	sbr_S_RWD_M = "RWD S",
	sbr_TT_AWD_S_DCT = "AWD TT S",
	sbr_TT_AWD_S_M = "AWD TT S",
	sbr_TT_AWD_S2_DCT = "AWD TT S2",
	sbr_TT_AWD_S2_M = "AWD TT S2",
	sbr_TT_RWD_S_DCT = "RWD TT S",
	sbr_TT_RWD_S_M = "RWD TT S",
	--Semi
	semi_t65_base = "T65 Base",
	semi_t65_base_short = "T65 Base (Short)",
	semi_t65_cargobox = "T65 Cargo Box Upfit",
	semi_t65_fifthwheel = "T65 Fifth Wheel Upfit",
	semi_t65_fifthwheel_short = "T65 Fifth Wheel Upfit (Short)",
	semi_t65_flatbed = "T65 Flatbed Upfit",
	semi_t65_ramplow = "T65 Ram Plow",
	semi_t65_rollback = "T65 Car Hauler Upfit",
	semi_t75_base = "T75 Base",
	semi_t75_dumptruck = "T75 Dump Bed Upfit",
	semi_t75_fifthwheel = "T75 Fifth Wheel Upfit",
	semi_t75_mixer = "T75 Cement Mixer Upfit",
	semi_t75_patriot = "T75 Patriot Special",
	semi_t75_ramplow = "T75 Destroyer",
	semi_t75_sleeper = "T75 Long Haul",
	semi_t75_special = "T75 Long Haul Special",
	--Sunburst
	sunburst_base_CVT = "1.8",
	sunburst_base_M = "1.8",
	sunburst_custom = "Street Tuned",
	sunburst_drift = "Drift Missile",
	sunburst_firwood_police = "Firwood Police Package",
	sunburst_firwood_police_RS = "Firwood Police RS",
	sunburst_gendarmerie = "Gendarmerie",
	sunburst_hillclimb_SQ = "Hillclimb - Asphalt",
	sunburst_interceptor = "Police Interceptor",
	sunburst_offroad = "Off-Road",
	sunburst_police = "Police Package",
	sunburst_race_DCT = "Track",
	sunburst_race_M = "Track",
	sunburst_rally_SQ = "Rally - Gravel",
	sunburst_sport_DCT = "2.0 Sport",
	sunburst_sport_M = "2.0 Sport",
	sunburst_sport_RS_DCT = "2.0 Sport RS AWD",
	sunburst_sport_RS_M = "2.0 Sport RS AWD",
	sunburst_sport_S_DCT = "2.0 Sport S AWD",
	sunburst_sport_S_M = "2.0 Sport S AWD",
	--Super
	super_320 = "320",
	super_350 = "350",
	super_350gt = "350 GT",
	super_390gtr = "390 GTR",
	super_group4 = "390 GTR Group 4",
	super_notte = "Notte",
	super_polizia = "Polizia",
	super_powerglow = "Powerglow",
	--Van
	van_ambulance = "H45 Ambulance",
	van_deliverytruck = "H45 Cabster Cargo Box Upfit",
	van_derby = "The Disastrous",
	van_drift = "Drift",
	van_h15_ext_vanster = "H15 Vanster Long Wheelbase",
	van_h15_vanster = "H15 Vanster",
	van_h25_ext_vanster = "H25 Vanster Long Wheelbase",
	van_h25_vanster = "H25 Vanster",
	van_h25_worker = "H25 Vanster Work Package",
	van_h35_ext_vanster = "H35 Vanster Long Wheelbase",
	van_h35_vanster = "H35 Vanster",
	van_h45_chassiscab = "H45 Cabster Chassis Cab",
	van_h45_rollback = "H45 Diesel Cabster Rollback Upfit",
	van_offroad = "H15 Vanster Off-Road",
	van_offroad_alt = "H35 Vandal",
	van_police = "H15 Vanster Police Package",
	van_street_tuned = "Street Tuned",
	van_vantastic = "The Vantastic",
	--Vivace
	vivace_asphalt_SQ = "Vivace Rally - Asphalt",
	vivace_gravel_SQ = "Vivace Rally - Gravel",
	vivace_hillclimb_SQ = "Vivace Hillclimb",
	vivace_race_SQ = "Vivace Race",
	vivace_tograc_110_M = "Tograc 110",
	vivace_tograc_110d_M = "Tograc 110d",
	vivace_tograc_150dq_DCT = "Tograc 150dQ",
	vivace_tograc_150dq_M = "Tograc 150dQ",
	vivace_tograc_150dqX_DCT = "Tograc 150dQX",
	vivace_tograc_160q_DCT = "Tograc 160Q",
	vivace_tograc_160q_M = "Tograc 160Q",
	vivace_tograc_190dq_DCT = "Tograc 190dq",
	vivace_tograc_amrally_DCT = "Tograc Amateur Rally - Gravel",
	vivace_tograc_polizia = "Tograc Polizia",
	vivace_tograc_qE = "Tograc qE",
	vivace_trackday_M = "Vivace S 310 Arsenic Trackday",
	vivace_vivace_110_M = "Vivace 110",
	vivace_vivace_110d_M = "Vivace 110d",
	vivace_vivace_150d_DCT = "Vivace 150d",
	vivace_vivace_150d_M = "Vivace 150d",
	vivace_vivace_160_DCT = "Vivace 160",
	vivace_vivace_160_M = "Vivace 160",
	vivace_vivace_190Sd_DCT = "Vivace 190Sd",
	vivace_vivace_230S_DCT = "Vivace 230S",
	vivace_vivace_E = "Vivace E",
	vivace_vivace_polizia = "Vivace Polizia",
	vivace_vivace_S_270_DCT = "Vivace S 270",
	vivace_vivace_S_270_M = "Vivace S 270",
	vivace_vivace_S_310_DCT = "Vivace S 310 Arsenic",
	vivace_vivace_S_310_M = "Vivace S 310 Arsenic",
	vivace_vivace_S_350q_DCT = "Vivace S 350Q",
	vivace_vivace_S_350q_M = "Vivace S 350Q",
	vivace_vivace_S_410q_DCT = "Vivace S 410Q Arsenic",
	vivace_vivace_S_410q_M = "Vivace S 410Q Arsenic",
	vivace_vivace_S_gendarmerie = "Vivace S Gendarmerie",
	--Wendover
	wendover_base_v6_A = "3300",
	wendover_base_v6_A_facelift = "3300 (Facelift)",
	wendover_derby = "The Unpunctual",
	wendover_hillclimb = "Hillclimb",
	wendover_interceptor = "Police Interceptor",
	wendover_race = "Race",
	wendover_rally = "Rally",
	wendover_s_v6_A = "S 3800",
	wendover_s_v6_A_facelift = "S 3800 (Facelift)",
	wendover_safetycar = "Safety Car",
	wendover_se_v6_A = "SE 3800",
	wendover_se_v6_A_facelift = "SE 3800 (Facelift)",
	wendover_se_v8_A = "SE 4400 V8",
	wendover_se_v8_A_facelift = "SE 4400 V8 (Facelift)",
	wendover_sport_s_v6_A = "Sport S 3800",
	wendover_sport_s_v6_A_facelift = "Sport S 3800 (Facelift)",
	wendover_sport_se_v6_A = "Sport SE 3800",
	wendover_sport_se_v6_A_facelift = "Sport SE 3800 (Facelift)",
	wendover_sport_se_v6_M = "Sport SE 3800",
	wendover_sport_se_v6_M_facelift = "Sport SE 3800 (Facelift)",
	wendover_sport_se_v8_A = "Sport SE 4400 V8",
	wendover_sport_se_v8_A_facelift = "Sport SE 4400 V8 (Facelift)",
	wendover_Street_tuned = "Street Tuned",
	wendover_super = "Fink Appliances Ten Thousand",
	--Wigeon
	wigeon_base = "Base",
	wigeon_base_4w = "Sprint",
	wigeon_drag = "The Darter",
	wigeon_lx = "LX",
	wigeon_lx_4w = "LX Sprint",
	wigeon_mantis = "The Mantis",
	wigeon_pondskipper = "The Pond Skipper",

	--Stock Haulables
	--Box Utility
	boxutility_loaded_200 = "200kg Crate",
	boxutility_loaded_400 = "400kg Crate",
	boxutility_loaded_600 = "600kg Crate",
	boxutility_loaded_planks = "1400kg Planks",
	boxutility_unloaded = "Unloaded",
	--Box Utility Large
	boxutility_large_loaded_400 = "400kg Crate",
	boxutility_large_loaded_800 = "800kg Crate",
	boxutility_large_loaded_planks = "1400kg Planks",
	boxutility_large_loaded_planks_long = "2100kg Planks",
	boxutility_large_unloaded = "Unloaded",
	boxutility_large_unsafe = "Dangerous",
	--Caravan
	caravan_default = "Standard",
	caravan_empty = "Empty",
	--Dryvan
	dryvan_clean = "Clean",
	dryvan_cola = "12900kg TastiCola",
	dryvan_cola_double = "25800kg TastiCola",
	dryvan_empty = "Empty",
	dryvan_loadingramp = "Loading Ramp",
	--Flatbed
	flatbed_empty = "Empty",
	flatbed_Empty = "Empty",
	flatbed_pipes_s = "20000kg Steel Pipes",
	flatbed_woodplanks = "12600kg Wood Planks",
	flatbed_woodplanks_b = "16800kg Wood Planks",
	--Tanker
	tanker_diesel = "Diesel",
	tanker_milk = "Milk",
	tanker_petroleum = "Petroleum",
	tanker_water = "Water",
	--TSFB
	tsfb_loaded_400 = "400kg Crate",
	tsfb_loaded_800 = "800kg Crate",
	tsfb_loaded_planks = "1400kg Planks",
	tsfb_loaded_planks_long = "2100kg Planks",
	tsfb_unloaded = "Unloaded",

	--Stock Props
	--Ball
	ball = "",
	--Barrels
	barrels_empty = "(Empty)",
	barrels_filled_oil = "(Filled with Oil)",
	--Barrier
	barrier = "",
	--Blockwall
	blockwall = "",
	--Bollard
	bollard = "",
	--Cannon
	cannon = "",
	--Christmas Tree
	christmas_tree = "",
	--Cones
	cones_large = "Large",
	cones_small = "Small",
	--Flail
	flail = "",
	--Flipramp
	flipramp_large = "Large",
	flipramp_medium = "Medium",
	--Gate
	gate_4M = "Single 4 Meter Swing",
	gate_8M = "Double 4 Meter Swing",
	gate_4Meter = "Single 4 Meter Swing",
	--Haybale
	haybale = "",
	--Inflated Mat
	inflated_mat = "",
	--Kickplate
	kickplate = "",
	--Large Angletester
	large_angletester = "",
	--Large Bridge
	large_bridge = "",
	--Large Cannon
	large_cannon = "",
	--Large Crusher
	large_crusher = "",
	--Large Hamster Wheel
	large_hamster_wheel = "",
	--Large Roller
	large_roller = "",
	--Large Spinner
	large_spinner_base = "Base",
	large_spinner_wall = "Wall",
	--Large Tilt
	large_tilt = "",
	--Mattress
	mattress_full = "Full Size",
	mattress_full_alt = "Full Size (Blue Striped)",
	mattress_full_altb = "Full Size (Floral)",
	mattress_king = "King Size",
	mattress_king_alt = "King Size (Blue Striped)",
	mattress_king_altb = "King Size (Floral)",
	--Metal Box
	metal_box = "",
	--Metal Ramp
	metal_ramp_adjustable_metal_ramp = "",
	--Piano
	piano = "",
	--Roadsigns
	roadsigns_25mph = "25 MPH Speed Limit",
	roadsigns_35mph = "35 MPH Speed Limit",
	roadsigns_45mph = "45 MPH Speed Limit",
	roadsigns_55mph = "55 MPH Speed Limit",
	roadsigns_65mph = "65 MPH Speed Limit",
	roadsigns_stop = "Stop",
	roadsigns_yield = "Yield",
	--Rocks
	rocks_rock_stack = "Stack",
	rocks_rock1 = "4850kg",
	rocks_rock2 = "1440kg",
	rocks_rock3 = "5265kg",
	rocks_rock4 = "6695kg",
	rocks_rock5 = "400kg",
	rocks_rock6 = "3195kg",
	rocks_rock7 = "230kg",
	rocks_rocks_three_large = "Three Large",
	--Rollover
	rollover = "",
	--Sawhorse
	sawhorse_closed = "Closed",
	sawhorse_left = "Left",
	sawhorse_lights = "Lights",
	sawhorse_right = "Right",
	sawhorse_stripes = "Stripes",
	--Shipping Container
	shipping_container_container_beamng = "BeamNG",
	shipping_container_default = "BeamNG",
	--Streetlight
	streetlight = "",
	--Suspension Bridge
	suspensionbridge = "",
	--Testroller
	testroller_multi = "Multiple - 2, Diagonal",
	testroller_multi_straight = "Multiple - 2, Straight",
	testroller_multi_triple = "Multiple - 3",
	testroller_ramp = "Tilt Ramp",
	testroller_ramp_etk = "Tilt Ramp (ETK)",
	testroller_single = "Single",
	--Tirestacks
	tirestacks = "",
	--Tirewall
	tirewall_arrows_L = "Left Arrows",
	tirewall_arrows_R = "Right Arrows",
	tirewall_etk = "ETK",
	tirewall_gripall = "Grip-All",
	tirewall_hirochi = "Hirochi",
	--Traffic Barrel
	trafficbarrel = "",
	--Traffic Tube
	tube = "",
	--Wall
	wall = "",
	--Weightpad
	weightpad_multipad = "Triple Pad",
	weightpad_singlepad = "Single Pad",
	--Woodcrate
	woodcrate_large = "200kg",
	--Woodplanks
	woodplanks_large = "2100kg",
	woodplanks_small = "1400kg",

	--Stock Player Character
	--Unicycle
	unicycle_snowman = "Snowman",
	unicycle_with_mesh = "With Mesh",
	unicycle_without_mesh = "Without Mesh"
	
	--add additional models as a key value pair
	--make_configName = "Model Name"
}

local makes = {
	--Stock Vehicles
	autobello = "Autobello Picollina",
	barstow = "Gavril Barstow",
	bluebuck = "Gavril Bluebuck",
	burnside = "Gavril Burnside Special",
	citybus = "Wentward DT40L",
	coupe = "Ibishu 200BX",
	etk800 = "ETK 800 Series",
	etkc = "ETK K-Series",
	etki = "ETK I-Series",
	fullsize = "Gavril Grand Marshal",
	hatch = "Ibishu Covet",
	hopper = "Ibishu Hopper",
	legran = "Bruckell LeGran",
	midsize = "Mk2 Ibishu Pessima",
	miramar = "Ibishu Miramar",
	moonhawk = "Bruckell Moonhawk",
	pessima = "Mk1 Ibishu Pessima",
	pickup = "Gavril D-Series",
	pigeon = "Ibishu Pigeon",
	roamer = "Gavril Roamer",
	sbr = "Hirochi SBR4",
	semi = "Gavril T-Series",
	sunburst = "Hirochi Sunburst",
	super = "Civetta Bolide",
	van = "Gavril H-Series",
	vivace = "Cherrier FCV",
	wendover = "Soliad Wendover",
	wigeon = "Ibishu Wigeon",

	--Stock Haulables
	boxutility = "Small Box Utility Trailer",
	boxutility_large = "Large Box Utility Trailer",
	caravan = "Travel Trailer",
	dryvan = "Randolph Dry Van Trailer",
	flatbed = "Randolph Flatbed Trailer",
	tanker = "Randolph Tanker Trailer",
	tsfb = "Small Flatbed Trailer",

	--Stock Props
	ball = "Ball",
	barrels = "Steel Barrel",
	barrier = "Concrete Barrier",
	blockwall = "Cinderblock Wall",
	bollard = "Bollard",
	cannon = "Old Cannon",
	christmas_tree = "Christmas Tree",
	cones = "Traffic Cone",
	flail = "Giant Flail",
	flipramp = "Flip Ramp",
	gate = "Gate",
	haybale = "Square Hay Bale",
	inflated_mat = "Inflated Mat",
	kickplate = "Kick Plate",
	large_angletester = "Large Angle Tester",
	large_bridge = "Large Bridge",
	large_cannon = "Large Cannon",
	large_crusher = "Large Crusher",
	large_hamster_wheel = "Large Hamster Wheel",
	large_roller = "Large Roller",
	large_spinner = "Large Spinner",
	large_tilt = "Tilt Board",
	mattress = "Mattress",
	metal_box = "Metal Box",
	metal_ramp = "Adjustable Metal Ramp",
	piano = "Upright Piano",
	roadsigns = "Road Sign",
	rocks = "Rocks & Boulders",
	rollover = "Rollover Sled",
	sawhorse = "Saw Horse Barrier",
	shipping_container = "Shipping Container",
	streetlight = "Street Light",
	suspensionbridge = "Suspension Bridge",
	testroller = "Wheel Roller",
	tirestacks = "Tire Stack",
	tirewall = "Tire Wall",
	trafficbarrel = "Traffic Barrel",
	tube = "Traffic Tube",
	wall = "Concrete Retaining Wall",
	weightpad = "Weight Pad",
	woodcrate = "Wood Crate",
	woodplanks = "Wood Planks",

	--Stock Player Character
	unicycle = "Player Model"

	--add additional makes as a key value pair
	--genericName = "fullName"
}

function parseVehData(data)
	local s, e = data:find('%{')
	data = data:sub(s)
	local sucessful, tempData = pcall(json.parse, data)
	if not sucessful then
		return false
	end
	data = tempData
	data.serverVID = vehID
	data.clientVID = data.VID
	data.name = data.jbm
	data.cfg = data.vcf
	if data[4] ~= nil then
		local sucessful, tempData = pcall(json.parse, data[4])
		if not sucessful then
			return false
		end
		data.info = tempData 
	end
	return data
end

function store(ID, vehID, data, blocked)
	players[ID][vehID] = {}
	players[ID][vehID].vehData = data
	if players[ID][vehID].vehData == nil then
	else
		players[ID][vehID].vehName = data.name
		players[ID][vehID].vehCfg = data.cfg.partConfigFilename
	end
	players[ID].vehBlocked = blocked
end

function release(ID, vehID)
	players[ID].vehBlocked = false
	players[ID][vehID] = nil
end

function getVehCfg(data)
	local configPath = data.cfg.partConfigFilename
	local vehCfg
	for configName,path in pairs(paths) do
		if configPath == path then
			vehCfg = configName
			for configName,shortName in pairs(models) do
				if vehCfg == configName then
					vehCfg = shortName
				end
			end
		end
	end
	return vehCfg
end

function isRecognized(playerName, data, fullName, vehCfg, blocked)
	if showOnVehicleSpawn then
		local namedSpawnable = fullName .. " " .. vehCfg
		if not blocked then
			if data.name == "woodplanks" or data.name == "rocks" then
				TriggerClientEvent(-1, "namedMessage", playerName .. " spawned some " .. namedSpawnable)
				SendChatMessage(-1, playerName .. " spawned some " .. namedSpawnable)
				print("[namedSpawnables] " .. playerName .. " spawned some " .. namedSpawnable)
			elseif string.match(string.sub(fullName,1,1), "[AEIOU]") then
				TriggerClientEvent(-1, "namedMessage", playerName .. " spawned an " .. namedSpawnable)
				SendChatMessage(-1, playerName .. " spawned an " .. namedSpawnable)
				print("[namedSpawnables] " .. playerName .. " spawned an " .. namedSpawnable)
			else
				TriggerClientEvent(-1, "namedMessage", playerName .. " spawned a " .. namedSpawnable)
				SendChatMessage(-1, playerName .. " spawned a " .. namedSpawnable)
				print("[namedSpawnables] " .. playerName .. " spawned a " .. namedSpawnable)
			end
		else
			TriggerClientEvent(-1, "namedMessage", playerName .. "'s " .. namedSpawnable .. " was blocked")
			SendChatMessage(-1, playerName .. "'s " .. namedSpawnable .. " was blocked")
			print("[namedSpawnables] " .. playerName .. "'s " .. namedSpawnable .. " was blocked")
		end
	end
end

function isUnrecognized(playerName, data, blocked)
	if showOnVehicleSpawn then
		if not blocked then
			TriggerClientEvent(-1, "namedMessage", playerName .. " spawned an unrecognized vehicle: '" .. data.name .. "'")
			SendChatMessage(-1, playerName .. " spawned an unrecognized vehicle: '" .. data.name .. "'")
			print("[namedSpawnables] " .. playerName .. " spawned an unrecognized vehicle: '" .. data.name .. "'")
		else
			TriggerClientEvent(-1, "namedMessage", playerName .. "'s unrecognized vehicle: '" .. data.name .. "' was blocked")
			SendChatMessage(-1, playerName .. "'s unrecognized vehicle: '" .. data.name .. "' was blocked")
			print("[namedSpawnables] " .. playerName .. "'s unrecognized vehicle: '" .. data.name .. "' was blocked")
		end
	end
end

function onPlayerConnecting(ID)
	players[ID] = {}
	players[ID].name = GetPlayerName(ID)
	players[ID].vehBlocked = false
end

function onPlayerDisconnect(ID)
	players[ID] = nil
end

function onVehicleSpawn(ID, vehID, data)
	local playerName = players[ID].name
	local data = parseVehData(data)
	local fullName = makes[data.name]
	local vehCfg = getVehCfg(data)
	if players[ID].vehBlocked == false then
		store(ID, vehID, data, false)
		players[ID][vehID].vehCount = 1
		local vehList = GetPlayerVehicles(ID)
		if vehList then
			for k,v in pairs(vehList) do
				if k then
					players[ID][vehID].vehCount = players[ID][vehID].vehCount + 1
				end
			end
		end
		if players[ID][vehID].vehCount <= beamMPconfig.MaxCars then
			if fullName and vehCfg then
				isRecognized(playerName, data, fullName, vehCfg, false)
			elseif fullName and not vehCfg then
				vehCfg = "[Custom Configuration]"
				isRecognized(playerName, data, fullName, vehCfg, false)
			else
				isUnrecognized(playerName, data, false)
			end
		else
			if fullName and vehCfg then
				isRecognized(playerName, data, fullName, vehCfg, true)
			elseif fullName and not vehCfg then
				vehCfg = "[Custom Configuration]"
				isRecognized(playerName, data, fullName, vehCfg, true)
			else
				isUnrecognized(playerName, data, true)
			end
		end
	else
		release(ID, vehID)
	end
end

function onVehicleEdited(ID, vehID, data)
	local playerName = players[ID].name
	local data = parseVehData(data)
	local fullName = makes[data.name]
	local vehCfg = getVehCfg(data)
	if players[ID].vehBlocked == false then
		store(ID, vehID, data, false)
		if fullName and vehCfg then
			local namedSpawnable = fullName .. " " .. vehCfg
			if players[ID][vehID].vehCfg == data.cfg.partConfigFilename then
				if showOnVehicleEdited then
					TriggerClientEvent(-1, "namedMessage", playerName .. " edited their " .. namedSpawnable)
					SendChatMessage(-1, playerName .. " edited their " .. namedSpawnable)
					print("[namedSpawnables] " .. playerName .. " edited their " .. namedSpawnable)
				end
			else
				isRecognized(playerName, data, fullName, vehCfg)
			end
		elseif fullName and not vehCfg then
			local namedSpawnable = fullName .. " [Custom Configuration]"
			if players[ID][vehID].vehName == data.name then
				if showOnVehicleEdited then
					TriggerClientEvent(-1, "namedMessage", playerName .. " edited their " .. namedSpawnable)
					SendChatMessage(-1, playerName .. " edited their " .. namedSpawnable)
					print("[namedSpawnables] " .. playerName .. " edited their " .. namedSpawnable)
				end
			else
				vehCfg = " [Custom Configuration]"
				isRecognized(playerName, data, fullName, vehCfg)
			end
		else
			if players[ID][vehID].vehName == data.name then
				if showOnVehicleEdited then
					TriggerClientEvent(-1, "namedMessage", playerName .. " edited their unrecognized vehicle: '" .. data.name .. "'")
					SendChatMessage(-1, playerName .. " edited their unrecognized vehicle: '" .. data.name .. "'")
					print("[namedSpawnables] " .. playerName .. " edited their unrecognized vehicle: '" .. data.name .. "'")
				end
			else
				isUnrecognized(playerName, data)
			end
		end
	else
		release(ID, vehID)
	end
end

function onVehicleDeleted(ID, vehID)
	if showOnVehicleDeleted then
		local ID = tonumber(ID)
		local vehID = tonumber(vehID)
		local playerName = players[ID].name
		if players[ID][vehID] then
			local data = players[ID][vehID].vehData
			local genericName = data.name
			local fullName = makes[data.name]
			local vehCfg = getVehCfg(data)
			if fullName and vehCfg then
				local namedSpawnable = fullName .. " " .. vehCfg
				TriggerClientEvent(-1, "namedMessage", playerName .. " deleted their " .. namedSpawnable)
				SendChatMessage(-1, playerName .. " deleted their " .. namedSpawnable)
				print("[namedSpawnables] " .. playerName .. " deleted their " .. namedSpawnable)
			elseif fullName and not vehCfg then
				local namedSpawnable = fullName .. " [Custom Configuration]"
				TriggerClientEvent(-1, "namedMessage", playerName .. " deleted their " .. namedSpawnable)
				SendChatMessage(-1, playerName .. " deleted their " .. namedSpawnable)
				print("[namedSpawnables] " .. playerName .. " deleted their " .. namedSpawnable)
			else
				TriggerClientEvent(-1, "namedMessage", playerName .. " deleted their unrecognized vehicle: " .. genericName)
				SendChatMessage(-1, playerName .. " deleted their unrecognized vehicle: " .. genericName)
				print("[namedSpawnables] " .. playerName .. " deleted their unrecognized vehicle: " .. genericName)
			end
			release(ID, vehID)
		else
			store(ID, vehID, nil, true)
			TriggerClientEvent(-1, "namedMessage", playerName .. "'s vehicle spawn was blocked")
			SendChatMessage(-1, playerName .. "'s vehicle spawn was blocked")
			print("[namedSpawnables] " .. playerName .. "'s vehicle spawn was blocked")
		end
	end
end
