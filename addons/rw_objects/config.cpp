#define _ARMA_

class CfgPatches
{
	class rw_objects
	{
		name = "RW Objects";
		author = "TheDUDE";
		units[] =
		{
			"rw_obj_cassette_1",
			"rw_obj_card_1_ace",
			"rw_obj_card_1_jsar",
			"rw_obj_card_1_seal_1",
			"rw_obj_card_1_seal_2",
			"rw_obj_eldest_son_rounds",
			"rw_obj_enemy_map_01",
			"rw_obj_enemy_map_02",
			"rw_obj_enemy_map_03",
			"rw_obj_enemy_map_04",
			"rw_obj_enemy_map_05",
			"rw_obj_enemy_map_06",
			"rw_obj_enemy_map_07",
			"rw_obj_enemy_map_08",
			"rw_obj_enemy_map_09",
			"rw_obj_enemy_map_10",
			"rw_obj_film_roll",
			"rw_obj_infil_card_1",
			"rw_obj_infil_card_2",
			"rw_obj_infil_card_3",
			"rw_obj_infil_card_4",
			"rw_obj_ledger",
			"rw_obj_madar",
			"rw_obj_officer_id_1",
			"rw_obj_officer_id_2",
			"rw_obj_officer_id_3",
			"rw_obj_officer_id_4",
			"rw_obj_page",
			"rw_obj_prc77_battery",
			"rw_obj_tin_can_empty",
			"rw_obj_tin_can_full"
		};
		weapons[] = {};
		requiredVersion = 2.18;
		requiredAddons[] =
		{
			"A3_Data_F",
			"A3_Characters_F",
			"A3_Structures_F"
		};
	};
};


class CfgEditorCategories
{
	class rw_EdCat_Objects
	{
		displayName = "RW Objects";
	};
};

class CfgEditorSubcategories
{
	class rw_EdSubcat_InventoryItems
	{
		displayName = "RW Inventory Items";
	};
};

class CfgFunctions
{
	class rw
	{
		tag = "rw";

		class objects
		{
			file = "\rw_objects\functions";
			class initPickupObject {};
			class monitorDroppedItems
			{
				postInit = 1;
			};
		};
	};
};

class CfgMagazines
{
	class CA_Magazine;
	
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Cassette Tape

	class rw_inv_cassette_1: CA_Magazine
	{
		author = "TheDUDE";
		mass = 0.2;
		scope = 2;
		value = 1;
		displayName = "[RW] Cassette Tape for Recording Devices";
		picture = "\rw_objects\data\ui\rw_cassette_1_ca.paa";
		model = "\rw_objects\rw_cassette_1.p3d";
		type = 256;
		count = 1;
		initSpeed = 18;
		nameSound = "handgrenade";
		maxLeadSpeed = 6.94444;
		descriptionShort = "Cassette Tape";
		displayNameShort = "Cassette Tape";
	};
	
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Playin/Death Cards
	
	class rw_inv_card_1_ace: CA_Magazine
	{
		author = "TheDUDE";
		mass = 0.1;
		scope = 2;
		value = 1;
		displayName = "[RW] Ace of Spades Death Card";
		picture = "\rw_objects\data\ui\rw_card_1_ace_ca.paa";
		model = "\rw_objects\rw_card_1.p3d";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_card_1_ace_co.paa"};
		type = 256;
		count = 1;
		initSpeed = 18;
		nameSound = "handgrenade";
		maxLeadSpeed = 6.94444;
		descriptionShort = "Ace Death Card";
		displayNameShort = "Ace Death Card";
	};
	
	class rw_inv_card_1_jsar: CA_Magazine
	{
		author = "TheDUDE";
		mass = 0.1;
		scope = 2;
		value = 1;
		displayName = "[RW] JSAR Death Card";
		picture = "\rw_objects\data\ui\rw_card_1_jsar_ca.paa";
		model = "\rw_objects\rw_card_1.p3d";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_card_1_jsar_co.paa"};
		type = 256;
		count = 1;
		initSpeed = 18;
		nameSound = "handgrenade";
		maxLeadSpeed = 6.94444;
		descriptionShort = "JSAR Death Card";
		displayNameShort = "JSAR Death Card";
	};
	
	class rw_inv_card_1_seal_1: CA_Magazine
	{
		author = "TheDUDE";
		mass = 0.1;
		scope = 2;
		value = 1;
		displayName = "[RW] SEAL Death Card 1";
		picture = "\rw_objects\data\ui\rw_card_1_seal_1_ca.paa";
		model = "\rw_objects\rw_card_1.p3d";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_card_1_seal_1_co.paa"};
		type = 256;
		count = 1;
		initSpeed = 18;
		nameSound = "handgrenade";
		maxLeadSpeed = 6.94444;
		descriptionShort = "SEAL Death Card 1";
		displayNameShort = "SEAL Death Card 1";
	};
	
	class rw_inv_card_1_seal_2: CA_Magazine
	{
		author = "TheDUDE";
		mass = 0.1;
		scope = 2;
		value = 1;
		displayName = "[RW] SEAL Death Card 2";
		picture = "\rw_objects\data\ui\rw_card_1_seal_2_ca.paa";
		model = "\rw_objects\rw_card_1.p3d";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_card_1_seal_2_co.paa"};
		type = 256;
		count = 1;
		initSpeed = 18;
		nameSound = "handgrenade";
		maxLeadSpeed = 6.94444;
		descriptionShort = "SEAL Death Card 2";
		displayNameShort = "SEAL Death Card 2";
	};
	
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Eldest Son Rounds
	
	class rw_inv_eldest_son_rounds: CA_Magazine
	{
		author = "TheDUDE";
		mass = 0.7;
		scope = 2;
		value = 1;
		displayName = "[RW] Eldest Son Rigged Rounds";
		picture = "\rw_objects\data\ui\rw_eldest_son_ca.paa";
		model = "\rw_objects\rw_eldest_son.p3d";
		type = 256;
		count = 1;
		initSpeed = 18;
		nameSound = "handgrenade";
		maxLeadSpeed = 6.94444;
		descriptionShort = "Eldest Son Rounds";
		displayNameShort = "Eldest Son Rounds";
	};
	
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Enemy Map
	
	class rw_inv_enemy_map_01: CA_Magazine
	{
		author = "TheDUDE";
		mass = 0.1;
		scope = 2;
		value = 1;
		displayName = "[RW] Enemy Map 01";
		picture = "\rw_objects\data\ui\rw_map_1_ca.paa";
		model = "\rw_objects\rw_enemy_map.p3d";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_enemy_map_1_co.paa"};
		type = 256;
		count = 1;
		initSpeed = 18;
		nameSound = "handgrenade";
		maxLeadSpeed = 6.94444;
		descriptionShort = "Enemy Map 01";
		displayNameShort = "Enemy Map 01";
	};
	
	class rw_inv_enemy_map_02: CA_Magazine
	{
		author = "TheDUDE";
		mass = 0.1;
		scope = 2;
		value = 1;
		displayName = "[RW] Enemy Map 02";
		picture = "\rw_objects\data\ui\rw_map_2_ca.paa";
		model = "\rw_objects\rw_enemy_map.p3d";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_enemy_map_2_co.paa"};
		type = 256;
		count = 1;
		initSpeed = 18;
		nameSound = "handgrenade";
		maxLeadSpeed = 6.94444;
		descriptionShort = "Enemy Map 02";
		displayNameShort = "Enemy Map 02";
	};
	
	class rw_inv_enemy_map_03: CA_Magazine
	{
		author = "TheDUDE";
		mass = 0.1;
		scope = 2;
		value = 1;
		displayName = "[RW] Enemy Map 03";
		picture = "\rw_objects\data\ui\rw_map_3_ca.paa";
		model = "\rw_objects\rw_enemy_map.p3d";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_enemy_map_3_co.paa"};
		type = 256;
		count = 1;
		initSpeed = 18;
		nameSound = "handgrenade";
		maxLeadSpeed = 6.94444;
		descriptionShort = "Enemy Map 03";
		displayNameShort = "Enemy Map 03";
	};
	
	class rw_inv_enemy_map_04: CA_Magazine
	{
		author = "TheDUDE";
		mass = 0.1;
		scope = 2;
		value = 1;
		displayName = "[RW] Enemy Map 04";
		picture = "\rw_objects\data\ui\rw_map_4_ca.paa";
		model = "\rw_objects\rw_enemy_map.p3d";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_enemy_map_4_co.paa"};
		type = 256;
		count = 1;
		initSpeed = 18;
		nameSound = "handgrenade";
		maxLeadSpeed = 6.94444;
		descriptionShort = "Enemy Map 04";
		displayNameShort = "Enemy Map 04";
	};
	
	class rw_inv_enemy_map_05: CA_Magazine
	{
		author = "TheDUDE";
		mass = 0.1;
		scope = 2;
		value = 1;
		displayName = "[RW] Enemy Map 05";
		picture = "\rw_objects\data\ui\rw_map_5_ca.paa";
		model = "\rw_objects\rw_enemy_map.p3d";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_enemy_map_5_co.paa"};
		type = 256;
		count = 1;
		initSpeed = 18;
		nameSound = "handgrenade";
		maxLeadSpeed = 6.94444;
		descriptionShort = "Enemy Map 05";
		displayNameShort = "Enemy Map 05";
	};
	
	class rw_inv_enemy_map_06: CA_Magazine
	{
		author = "TheDUDE";
		mass = 0.1;
		scope = 2;
		value = 1;
		displayName = "[RW] Enemy Map 06";
		picture = "\rw_objects\data\ui\rw_map_6_ca.paa";
		model = "\rw_objects\rw_enemy_map.p3d";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_enemy_map_6_co.paa"};
		type = 256;
		count = 1;
		initSpeed = 18;
		nameSound = "handgrenade";
		maxLeadSpeed = 6.94444;
		descriptionShort = "Enemy Map 06";
		displayNameShort = "Enemy Map 06";
	};
	
	class rw_inv_enemy_map_07: CA_Magazine
	{
		author = "TheDUDE";
		mass = 0.1;
		scope = 2;
		value = 1;
		displayName = "[RW] Enemy Map 07";
		picture = "\rw_objects\data\ui\rw_map_7_ca.paa";
		model = "\rw_objects\rw_enemy_map.p3d";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_enemy_map_7_co.paa"};
		type = 256;
		count = 1;
		initSpeed = 18;
		nameSound = "handgrenade";
		maxLeadSpeed = 6.94444;
		descriptionShort = "Enemy Map 07";
		displayNameShort = "Enemy Map 07";
	};
	
	class rw_inv_enemy_map_08: CA_Magazine
	{
		author = "TheDUDE";
		mass = 0.1;
		scope = 2;
		value = 1;
		displayName = "[RW] Enemy Map 08";
		picture = "\rw_objects\data\ui\rw_map_8_ca.paa";
		model = "\rw_objects\rw_enemy_map.p3d";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_enemy_map_8_co.paa"};
		type = 256;
		count = 1;
		initSpeed = 18;
		nameSound = "handgrenade";
		maxLeadSpeed = 6.94444;
		descriptionShort = "Enemy Map 08";
		displayNameShort = "Enemy Map 08";
	};
	class rw_inv_enemy_map_09: CA_Magazine
	{
		author = "TheDUDE";
		mass = 0.1;
		scope = 2;
		value = 1;
		displayName = "[RW] Enemy Map 09";
		picture = "\rw_objects\data\ui\rw_map_9_ca.paa";
		model = "\rw_objects\rw_enemy_map.p3d";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_enemy_map_9_co.paa"};
		type = 256;
		count = 1;
		initSpeed = 18;
		nameSound = "handgrenade";
		maxLeadSpeed = 6.94444;
		descriptionShort = "Enemy Map 09";
		displayNameShort = "Enemy Map 09";
	};
	
	class rw_inv_enemy_map_10: CA_Magazine
	{
		author = "TheDUDE";
		mass = 0.1;
		scope = 2;
		value = 1;
		displayName = "[RW] Enemy Map 10";
		picture = "\rw_objects\data\ui\rw_map_10_ca.paa";
		model = "\rw_objects\rw_enemy_map.p3d";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_enemy_map_10_co.paa"};
		type = 256;
		count = 1;
		initSpeed = 18;
		nameSound = "handgrenade";
		maxLeadSpeed = 6.94444;
		descriptionShort = "Enemy Map 10";
		displayNameShort = "Enemy Map 10";
	};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Film Roll

	class rw_inv_film_roll: CA_Magazine
	{
		author = "TheDUDE";
		mass = 0.2;
		scope = 2;
		value = 1;
		displayName = "[RW] 35mm Film Roll";
		picture = "\rw_objects\data\ui\rw_film_canister_ca.paa";
		model = "\rw_objects\rw_film_roll.p3d";
		type = 256;
		count = 1;
		initSpeed = 18;
		nameSound = "handgrenade";
		maxLeadSpeed = 6.94444;
		descriptionShort = "Film Roll";
		displayNameShort = "Film Roll";
	};
	
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Infiltration Cards
	
	class rw_inv_infil_card_1: CA_Magazine
	{
		author = "TheDUDE";
		mass = 0.1;
		scope = 2;
		value = 1;
		displayName = "[RW] Infiltration Card 1";
		picture = "\rw_objects\data\ui\rw_infil_card_1_ca.paa";
		model = "\rw_objects\rw_infil_card.p3d";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_infil_card_1_co.paa"};
		type = 256;
		count = 1;
		initSpeed = 18;
		nameSound = "handgrenade";
		maxLeadSpeed = 6.94444;
		descriptionShort = "Infil Card 1";
		displayNameShort = "Infil Card 1";
	};
	
	class rw_inv_infil_card_2: CA_Magazine
	{
		author = "TheDUDE";
		mass = 0.1;
		scope = 2;
		value = 1;
		displayName = "[RW] Infiltration Card 2";
		picture = "\rw_objects\data\ui\rw_infil_card_2_ca.paa";
		model = "\rw_objects\rw_infil_card.p3d";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_infil_card_2_co.paa"};
		type = 256;
		count = 1;
		initSpeed = 18;
		nameSound = "handgrenade";
		maxLeadSpeed = 6.94444;
		descriptionShort = "Infil Card 2";
		displayNameShort = "Infil Card 2";
	};
	
	class rw_inv_infil_card_3: CA_Magazine
	{
		author = "TheDUDE";
		mass = 0.1;
		scope = 2;
		value = 1;
		displayName = "[RW] Infiltration Card 3";
		picture = "\rw_objects\data\ui\rw_infil_card_3_ca.paa";
		model = "\rw_objects\rw_infil_card.p3d";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_infil_card_3_co.paa"};
		type = 256;
		count = 1;
		initSpeed = 18;
		nameSound = "handgrenade";
		maxLeadSpeed = 6.94444;
		descriptionShort = "Infil Card 3";
		displayNameShort = "Infil Card 3";
	};
	
	class rw_inv_infil_card_4: CA_Magazine
	{
		author = "TheDUDE";
		mass = 0.1;
		scope = 2;
		value = 1;
		displayName = "[RW] Infiltration Card 4";
		picture = "\rw_objects\data\ui\rw_infil_card_4_ca.paa";
		model = "\rw_objects\rw_infil_card.p3d";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_infil_card_4_co.paa"};
		type = 256;
		count = 1;
		initSpeed = 18;
		nameSound = "handgrenade";
		maxLeadSpeed = 6.94444;
		descriptionShort = "Infil Card 4";
		displayNameShort = "Infil Card 4";
	};
	
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Ledger

	class rw_inv_ledger: CA_Magazine
	{
		author = "TheDUDE";
		mass = 0.3;
		scope = 2;
		value = 1;
		displayName = "[RW] Ledger";
		picture = "\rw_objects\data\ui\rw_journal_ca.paa";
		model = "\rw_objects\rw_ledger.p3d";
		type = 256;
		count = 1;
		initSpeed = 18;
		nameSound = "handgrenade";
		maxLeadSpeed = 6.94444;
		descriptionShort = "Ledger";
		displayNameShort = "Ledger";
	};
	
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////SR71 Madar

	class rw_inv_madar: CA_Magazine
	{
		author = "TheDUDE";
		mass = 0.3;
		scope = 2;
		value = 1;
		displayName = "[RW] SR71 MADAR box";
		picture = "\rw_objects\data\ui\rw_madar_ca.paa";
		model = "\rw_objects\rw_madar.p3d";
		type = 256;
		count = 1;
		initSpeed = 18;
		nameSound = "handgrenade";
		maxLeadSpeed = 6.94444;
		descriptionShort = "SR71 Madar";
		displayNameShort = "SR71 Madar";
	};
	
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Officer ID
	
	class rw_inv_officer_id_1: CA_Magazine
	{
		author = "TheDUDE";
		mass = 0.1;
		scope = 2;
		value = 1;
		displayName = "[RW] Officer ID Card 1";
		picture = "\rw_objects\data\ui\rw_officer_id_1_ca.paa";
		model = "\rw_objects\rw_officer_id.p3d";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_officer_id_1_co.paa"};
		type = 256;
		count = 1;
		initSpeed = 18;
		nameSound = "handgrenade";
		maxLeadSpeed = 6.94444;
		descriptionShort = "Officer ID 1";
		displayNameShort = "Officer ID 1";
	};
	
	class rw_inv_officer_id_2: CA_Magazine
	{
		author = "TheDUDE";
		mass = 0.1;
		scope = 2;
		value = 1;
		displayName = "[RW] Officer ID Card 2";
		picture = "\rw_objects\data\ui\rw_officer_id_2_ca.paa";
		model = "\rw_objects\rw_officer_id.p3d";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_officer_id_2_co.paa"};
		type = 256;
		count = 1;
		initSpeed = 18;
		nameSound = "handgrenade";
		maxLeadSpeed = 6.94444;
		descriptionShort = "Officer ID 2";
		displayNameShort = "Officer ID 2";
	};
	
	class rw_inv_officer_id_3: CA_Magazine
	{
		author = "TheDUDE";
		mass = 0.1;
		scope = 2;
		value = 1;
		displayName = "[RW] Officer ID Card 3";
		picture = "\rw_objects\data\ui\rw_officer_id_3_ca.paa";
		model = "\rw_objects\rw_officer_id.p3d";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_officer_id_3_co.paa"};
		type = 256;
		count = 1;
		initSpeed = 18;
		nameSound = "handgrenade";
		maxLeadSpeed = 6.94444;
		descriptionShort = "Officer ID 3";
		displayNameShort = "Officer ID 3";
	};
	
	class rw_inv_officer_id_4: CA_Magazine
	{
		author = "TheDUDE";
		mass = 0.1;
		scope = 2;
		value = 1;
		displayName = "[RW] Officer ID Card 4";
		picture = "\rw_objects\data\ui\rw_officer_id_4_ca.paa";
		model = "\rw_objects\rw_officer_id.p3d";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_officer_id_4_co.paa"};
		type = 256;
		count = 1;
		initSpeed = 18;
		nameSound = "handgrenade";
		maxLeadSpeed = 6.94444;
		descriptionShort = "Officer ID 4";
		displayNameShort = "Officer ID 4";
	};
	
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Paper

	class rw_inv_page: CA_Magazine
	{
		author = "TheDUDE";
		mass = 0.3;
		scope = 2;
		value = 1;
		displayName = "[RW] Page from a Journal";
		picture = "\rw_objects\data\ui\rw_page_1_ca.paa";
		model = "\rw_objects\rw_paper.p3d";
		type = 256;
		count = 1;
		initSpeed = 18;
		nameSound = "handgrenade";
		maxLeadSpeed = 6.94444;
		descriptionShort = "Journal Page";
		displayNameShort = "Journal Page";
	};
	
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////PRC77 Battery

	class rw_inv_prc77_battery: CA_Magazine
	{
		author = "TheDUDE";
		mass = 0.3;
		scope = 2;
		value = 1;
		displayName = "[RW] PRC77 Battery";
		picture = "\rw_objects\data\ui\rw_prc77_battery_ca.paa";
		model = "\rw_objects\rw_prc77_battery.p3d";
		type = 256;
		count = 1;
		initSpeed = 18;
		nameSound = "handgrenade";
		maxLeadSpeed = 6.94444;
		descriptionShort = "PRC77 Battery";
		displayNameShort = "PRC77 Battery";
	};
	
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Tin Can

	class rw_inv_tin_can_empty: CA_Magazine
	{
		author = "TheDUDE";
		mass = 0.3;
		scope = 2;
		value = 1;
		displayName = "[RW] Empty Tin Can for Soil Samples";
		picture = "\rw_objects\data\ui\rw_tin_can_ca.paa";
		model = "\rw_objects\rw_tin_can.p3d";
		type = 256;
		count = 1;
		initSpeed = 18;
		nameSound = "handgrenade";
		maxLeadSpeed = 6.94444;
		descriptionShort = "Empty Tin Can";
		displayNameShort = "Empty Tin Can";
	};
	
	class rw_inv_tin_can_full: CA_Magazine
	{
		author = "TheDUDE";
		mass = 0.8;
		scope = 2;
		value = 1;
		displayName = "[RW] Full Tin Can for Soil Samples";
		picture = "\rw_objects\data\ui\rw_tin_can_ca.paa";
		model = "\rw_objects\rw_tin_can.p3d";
		type = 256;
		count = 1;
		initSpeed = 18;
		nameSound = "handgrenade";
		maxLeadSpeed = 6.94444;
		descriptionShort = "Full Tin Can";
		displayNameShort = "Full Tin Can";
	};
	
	
	
	
};

class CfgVehicles
{
	class ThingX;

	class rw_obj_base: ThingX
	{
		author = "TheDUDE";
		scope = 0;
		scopeCurator = 0;

		editorCategory = "rw_EdCat_Objects";
		editorSubcategory = "rw_EdSubcat_InventoryItems";

		simulation = "thing";
		mapSize = 0.1;
		armor = 1;
		destrType = "DestructNo";

		// Child classes override this with the matching CfgMagazines classname.
		rw_inventoryClass = "";

		class EventHandlers
		{
			init = "if (hasInterface) then {[_this # 0] call rw_fnc_initPickupObject};";
		};
	};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Cassette Tape
	class rw_obj_cassette_1: rw_obj_base
	{
		scope = 2;
		scopeCurator = 2;
		displayName = "[RW] Cassette Tape for Recording Devices";
		model = "\rw_objects\rw_cassette_1.p3d";
		rw_inventoryClass = "rw_inv_cassette_1";
	};
	
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Playin/Death Cards
	class rw_obj_card_1_ace: rw_obj_base
	{
		scope = 2;
		scopeCurator = 2;
		displayName = "[RW] Ace of Spades Death Card";
		model = "\rw_objects\rw_card_1.p3d";
		rw_inventoryClass = "rw_inv_card_1_ace";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_card_1_ace_co.paa"};
	};

	class rw_obj_card_1_jsar: rw_obj_base
	{
		scope = 2;
		scopeCurator = 2;
		displayName = "[RW] JSAR Death Card";
		model = "\rw_objects\rw_card_1.p3d";
		rw_inventoryClass = "rw_inv_card_1_jsar";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_card_1_jsar_co.paa"};
	};

	class rw_obj_card_1_seal_1: rw_obj_base
	{
		scope = 2;
		scopeCurator = 2;
		displayName = "[RW] SEAL Death Card 1";
		model = "\rw_objects\rw_card_1.p3d";
		rw_inventoryClass = "rw_inv_card_1_seal_1";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_card_1_seal_1_co.paa"};
	};

	class rw_obj_card_1_seal_2: rw_obj_base
	{
		scope = 2;
		scopeCurator = 2;
		displayName = "[RW] SEAL Death Card 2";
		model = "\rw_objects\rw_card_1.p3d";
		rw_inventoryClass = "rw_inv_card_1_seal_2";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_card_1_seal_2_co.paa"};
	};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Eldest Son Rounds
	class rw_obj_eldest_son_rounds: rw_obj_base
	{
		scope = 2;
		scopeCurator = 2;
		displayName = "[RW] Eldest Son Rigged Rounds";
		model = "\rw_objects\rw_eldest_son.p3d";
		rw_inventoryClass = "rw_inv_eldest_son_rounds";
	};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Enemy Map
	class rw_obj_enemy_map_01: rw_obj_base
	{
		scope = 2;
		scopeCurator = 2;
		displayName = "[RW] Enemy Map 01";
		model = "\rw_objects\rw_enemy_map.p3d";
		rw_inventoryClass = "rw_inv_enemy_map_01";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_enemy_map_1_co.paa"};
	};

	class rw_obj_enemy_map_02: rw_obj_base
	{
		scope = 2;
		scopeCurator = 2;
		displayName = "[RW] Enemy Map 02";
		model = "\rw_objects\rw_enemy_map.p3d";
		rw_inventoryClass = "rw_inv_enemy_map_02";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_enemy_map_2_co.paa"};
	};

	class rw_obj_enemy_map_03: rw_obj_base
	{
		scope = 2;
		scopeCurator = 2;
		displayName = "[RW] Enemy Map 03";
		model = "\rw_objects\rw_enemy_map.p3d";
		rw_inventoryClass = "rw_inv_enemy_map_03";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_enemy_map_3_co.paa"};
	};

	class rw_obj_enemy_map_04: rw_obj_base
	{
		scope = 2;
		scopeCurator = 2;
		displayName = "[RW] Enemy Map 04";
		model = "\rw_objects\rw_enemy_map.p3d";
		rw_inventoryClass = "rw_inv_enemy_map_04";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_enemy_map_4_co.paa"};
	};

	class rw_obj_enemy_map_05: rw_obj_base
	{
		scope = 2;
		scopeCurator = 2;
		displayName = "[RW] Enemy Map 05";
		model = "\rw_objects\rw_enemy_map.p3d";
		rw_inventoryClass = "rw_inv_enemy_map_05";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_enemy_map_5_co.paa"};
	};

	class rw_obj_enemy_map_06: rw_obj_base
	{
		scope = 2;
		scopeCurator = 2;
		displayName = "[RW] Enemy Map 06";
		model = "\rw_objects\rw_enemy_map.p3d";
		rw_inventoryClass = "rw_inv_enemy_map_06";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_enemy_map_6_co.paa"};
	};

	class rw_obj_enemy_map_07: rw_obj_base
	{
		scope = 2;
		scopeCurator = 2;
		displayName = "[RW] Enemy Map 07";
		model = "\rw_objects\rw_enemy_map.p3d";
		rw_inventoryClass = "rw_inv_enemy_map_07";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_enemy_map_7_co.paa"};
	};

	class rw_obj_enemy_map_08: rw_obj_base
	{
		scope = 2;
		scopeCurator = 2;
		displayName = "[RW] Enemy Map 08";
		model = "\rw_objects\rw_enemy_map.p3d";
		rw_inventoryClass = "rw_inv_enemy_map_08";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_enemy_map_8_co.paa"};
	};

	class rw_obj_enemy_map_09: rw_obj_base
	{
		scope = 2;
		scopeCurator = 2;
		displayName = "[RW] Enemy Map 09";
		model = "\rw_objects\rw_enemy_map.p3d";
		rw_inventoryClass = "rw_inv_enemy_map_09";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_enemy_map_9_co.paa"};
	};

	class rw_obj_enemy_map_10: rw_obj_base
	{
		scope = 2;
		scopeCurator = 2;
		displayName = "[RW] Enemy Map 10";
		model = "\rw_objects\rw_enemy_map.p3d";
		rw_inventoryClass = "rw_inv_enemy_map_10";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_enemy_map_10_co.paa"};
	};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Film Roll
	class rw_obj_film_roll: rw_obj_base
	{
		scope = 2;
		scopeCurator = 2;
		displayName = "[RW] 35mm Film Roll";
		model = "\rw_objects\rw_film_roll.p3d";
		rw_inventoryClass = "rw_inv_film_roll";
	};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Infiltration Cards
	class rw_obj_infil_card_1: rw_obj_base
	{
		scope = 2;
		scopeCurator = 2;
		displayName = "[RW] Infiltration Card 1";
		model = "\rw_objects\rw_infil_card.p3d";
		rw_inventoryClass = "rw_inv_infil_card_1";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_infil_card_1_co.paa"};
	};

	class rw_obj_infil_card_2: rw_obj_base
	{
		scope = 2;
		scopeCurator = 2;
		displayName = "[RW] Infiltration Card 2";
		model = "\rw_objects\rw_infil_card.p3d";
		rw_inventoryClass = "rw_inv_infil_card_2";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_infil_card_2_co.paa"};
	};

	class rw_obj_infil_card_3: rw_obj_base
	{
		scope = 2;
		scopeCurator = 2;
		displayName = "[RW] Infiltration Card 3";
		model = "\rw_objects\rw_infil_card.p3d";
		rw_inventoryClass = "rw_inv_infil_card_3";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_infil_card_3_co.paa"};
	};

	class rw_obj_infil_card_4: rw_obj_base
	{
		scope = 2;
		scopeCurator = 2;
		displayName = "[RW] Infiltration Card 4";
		model = "\rw_objects\rw_infil_card.p3d";
		rw_inventoryClass = "rw_inv_infil_card_4";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_infil_card_4_co.paa"};
	};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Ledger
	class rw_obj_ledger: rw_obj_base
	{
		scope = 2;
		scopeCurator = 2;
		displayName = "[RW] Ledger";
		model = "\rw_objects\rw_ledger.p3d";
		rw_inventoryClass = "rw_inv_ledger";
	};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////SR71 Madar
	class rw_obj_madar: rw_obj_base
	{
		scope = 2;
		scopeCurator = 2;
		displayName = "[RW] SR71 MADAR box";
		model = "\rw_objects\rw_madar.p3d";
		rw_inventoryClass = "rw_inv_madar";
	};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Officer ID
	class rw_obj_officer_id_1: rw_obj_base
	{
		scope = 2;
		scopeCurator = 2;
		displayName = "[RW] Officer ID Card 1";
		model = "\rw_objects\rw_officer_id.p3d";
		rw_inventoryClass = "rw_inv_officer_id_1";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_officer_id_1_co.paa"};
	};

	class rw_obj_officer_id_2: rw_obj_base
	{
		scope = 2;
		scopeCurator = 2;
		displayName = "[RW] Officer ID Card 2";
		model = "\rw_objects\rw_officer_id.p3d";
		rw_inventoryClass = "rw_inv_officer_id_2";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_officer_id_2_co.paa"};
	};

	class rw_obj_officer_id_3: rw_obj_base
	{
		scope = 2;
		scopeCurator = 2;
		displayName = "[RW] Officer ID Card 3";
		model = "\rw_objects\rw_officer_id.p3d";
		rw_inventoryClass = "rw_inv_officer_id_3";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_officer_id_3_co.paa"};
	};

	class rw_obj_officer_id_4: rw_obj_base
	{
		scope = 2;
		scopeCurator = 2;
		displayName = "[RW] Officer ID Card 4";
		model = "\rw_objects\rw_officer_id.p3d";
		rw_inventoryClass = "rw_inv_officer_id_4";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\rw_objects\data\tx\rw_officer_id_4_co.paa"};
	};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Paper
	class rw_obj_page: rw_obj_base
	{
		scope = 2;
		scopeCurator = 2;
		displayName = "[RW] Page from a Journal";
		model = "\rw_objects\rw_paper.p3d";
		rw_inventoryClass = "rw_inv_page";
	};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////PRC77 Battery
	class rw_obj_prc77_battery: rw_obj_base
	{
		scope = 2;
		scopeCurator = 2;
		displayName = "[RW] PRC77 Battery";
		model = "\rw_objects\rw_prc77_battery.p3d";
		rw_inventoryClass = "rw_inv_prc77_battery";
	};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Tin Can
	class rw_obj_tin_can_empty: rw_obj_base
	{
		scope = 2;
		scopeCurator = 2;
		displayName = "[RW] Empty Tin Can for Soil Samples";
		model = "\rw_objects\rw_tin_can.p3d";
		rw_inventoryClass = "rw_inv_tin_can_empty";
	};

	class rw_obj_tin_can_full: rw_obj_base
	{
		scope = 2;
		scopeCurator = 2;
		displayName = "[RW] Full Tin Can for Soil Samples";
		model = "\rw_objects\rw_tin_can.p3d";
		rw_inventoryClass = "rw_inv_tin_can_full";
	};
};
