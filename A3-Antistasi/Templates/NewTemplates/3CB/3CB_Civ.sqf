//////////////////////////////
//   Civilian Information   //
//////////////////////////////

["civilianUniforms", []] call _fnc_saveToTemplate;

["civilianHeadgear", []] call _fnc_saveToTemplate;



["vehiclesCivCar", ["UK3CB_CHC_C_Ikarus", 0					// bus, dangerously large
	,"UK3CB_TKC_C_Datsun_Civ_Closed", 0.5
	,"UK3CB_TKC_C_Datsun_Civ_Open", 1.0			// cargo capable
	,"UK3CB_TKC_C_Hatchback", 0.5
	,"UK3CB_TKC_C_Hilux_Civ_Closed", 0.5
	,"UK3CB_TKC_C_Hilux_Civ_Open", 1.0			// cargo capable
	,"UK3CB_TKC_C_Lada", 0.5
	,"UK3CB_TKC_C_Lada_Taxi", 0.5
	,"UK3CB_TKC_C_LR_Closed", 0.5		// land rovers
	,"UK3CB_TKC_C_LR_Open", 0.5
	,"UK3CB_TKC_C_Sedan", 0.5
	,"UK3CB_TKC_C_Skoda", 0.5
	,"UK3CB_TKC_C_S1203", 0.5
	,"UK3CB_TKC_C_UAZ_Closed", 0.5
	,"UK3CB_TKC_C_UAZ_Open", 0.5
	,"UK3CB_TKC_C_Gaz24", 0.5
	,"UK3CB_TKC_C_Golf", 0.5]] call _fnc_saveToTemplate; 			//this line determines civilian cars -- Example: ["vehiclesCivCar", ["C_Offroad_01_F"]] -- Array, can contain multiple assets

["vehiclesCivTruck", ["UK3CB_TKC_C_Tractor", 0.2
	,"UK3CB_TKC_C_Tractor_Old", 0.2
	,"UK3CB_TKC_C_Kamaz_Covered", 0.3
	,"UK3CB_TKC_C_Kamaz_Open", 0.3
	,"UK3CB_TKC_C_Ural", 0.3				// Urals
	,"UK3CB_TKC_C_Ural_Open", 0.3
	,"UK3CB_TKC_C_Ural_Empty", 0.3
	,"UK3CB_TKC_C_V3S_Closed", 0.3
	,"UK3CB_TKC_C_V3S_Open", 0.3]] call _fnc_saveToTemplate; 			//this line determines civilian trucks -- Example: ["vehiclesCivTruck", ["C_Truck_02_transport_F"]] -- Array, can contain multiple assets

["vehiclesCivHeli", ["not_supported"]] call _fnc_saveToTemplate; 			//this line determines civilian helis -- Example: ["vehiclesCivHeli", ["C_Heli_Light_01_civil_F"]] -- Array, can contain multiple assets

["vehiclesCivBoat", ["C_Boat_Civil_01_rescue_F", 0.1			// motorboats
	,"C_Boat_Civil_01_police_F", 0.1
	,"C_Boat_Civil_01_F", 1.0
	,"C_Rubberboat", 1.0					// rescue boat
	,"C_Boat_Transport_02_F", 1.0			// RHIB
	,"C_Scooter_Transport_01_F", 0.5		// jetski]] call _fnc_saveToTemplate; 			//this line determines civilian boats -- Example: ["vehiclesCivBoat", ["C_Boat_Civil_01_F"]] -- Array, can contain multiple assets

["vehiclesCivRepair", ["UK3CB_TKC_C_Kamaz_Repair", 0.1
	,"UK3CB_TKC_C_Ural_Repair", 0.1
	,"UK3CB_TKC_C_V3S_Repair", 0.1]] call _fnc_saveToTemplate;			//this line determines civilian repair vehicles

["vehiclesCivMedical", ["UK3CB_TKC_C_S1203_Amb", 0.1]] call _fnc_saveToTemplate;			//this line determines civilian medic vehicles

["vehiclesCivFuel", ["UK3CB_TKC_C_Kamaz_Fuel", 0.1
	,"UK3CB_TKC_C_Ural_Fuel", 0.1				// Ural
	,"UK3CB_TKC_C_V3S_Refuel", 0.1]] call _fnc_saveToTemplate;			//this line determines civilian fuel vehicles
