#define _ARMA_

class CfgPatches
{
	class rw_objects
	{
		units[] = {};
		weapons[] = {};
		requiredVersion = 0.1;
		requiredAddons[] = {"A3_Characters_F"};
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

	class rw_inv_tin_can: CA_Magazine
	{
		author = "TheDUDE";
		mass = 0.3;
		scope = 2;
		value = 1;
		displayName = "[RW] Tin Can for Soil Samples";
		picture = "\rw_objects\data\ui\rw_tin_can_ca.paa";
		model = "\rw_objects\rw_tin_can.p3d";
		type = 256;
		count = 1;
		initSpeed = 18;
		nameSound = "handgrenade";
		maxLeadSpeed = 6.94444;
		descriptionShort = "Tin Can";
		displayNameShort = "Tin Can";
	};
	
	
	
	
};

