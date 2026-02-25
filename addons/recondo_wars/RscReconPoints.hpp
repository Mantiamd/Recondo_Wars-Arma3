/*
    Recon Points Unlock Shop Dialog
    
    IDD: 58200
    
    Controls:
        - Category listbox (left)
        - Items listbox (center)
        - Item info panel (right)
        - Point balance display
        - Unlock/Take buttons
*/

class RscReconPointsShop {
    idd = 58200;
    movingEnable = 1;
    enableSimulation = 1;
    
    class controls {
        
        // Background
        class Background: RscText {
            idc = -1;
            x = 0.2 * safezoneW + safezoneX;
            y = 0.15 * safezoneH + safezoneY;
            w = 0.6 * safezoneW;
            h = 0.7 * safezoneH;
            colorBackground[] = {0, 0, 0, 0.8};
        };
        
        // Header bar
        class HeaderBar: RscText {
            idc = -1;
            x = 0.2 * safezoneW + safezoneX;
            y = 0.15 * safezoneH + safezoneY;
            w = 0.6 * safezoneW;
            h = 0.05 * safezoneH;
            colorBackground[] = {0.3, 0.3, 0.1, 1};
        };
        
        // Title
        class TitleText: RscText {
            idc = 58201;
            x = 0.21 * safezoneW + safezoneX;
            y = 0.155 * safezoneH + safezoneY;
            w = 0.3 * safezoneW;
            h = 0.04 * safezoneH;
            text = "RECON POINTS - UNLOCK SHOP";
            colorText[] = {1, 1, 0.6, 1};
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.2)";
        };
        
        // Balance display
        class BalanceText: RscText {
            idc = 58202;
            x = 0.55 * safezoneW + safezoneX;
            y = 0.155 * safezoneH + safezoneY;
            w = 0.24 * safezoneW;
            h = 0.04 * safezoneH;
            text = "Balance: 0 RP";
            colorText[] = {0.5, 1, 0.5, 1};
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.1)";
            style = 1;  // Right align
        };
        
        // Category label
        class CategoryLabel: RscText {
            idc = -1;
            x = 0.21 * safezoneW + safezoneX;
            y = 0.21 * safezoneH + safezoneY;
            w = 0.12 * safezoneW;
            h = 0.03 * safezoneH;
            text = "CATEGORY";
            colorText[] = {0.8, 0.8, 0.6, 1};
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9)";
        };
        
        // Category listbox
        class CategoryList: RscListbox {
            idc = 58210;
            x = 0.21 * safezoneW + safezoneX;
            y = 0.24 * safezoneH + safezoneY;
            w = 0.12 * safezoneW;
            h = 0.55 * safezoneH;
            colorBackground[] = {0.1, 0.1, 0.1, 0.6};
            colorSelect[] = {0.4, 0.4, 0.2, 1};
            colorSelect2[] = {0.4, 0.4, 0.2, 1};
            colorSelectBackground[] = {0.3, 0.3, 0.15, 1};
            colorSelectBackground2[] = {0.3, 0.3, 0.15, 1};
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9)";
            rowHeight = 0.035;
            onLBSelChanged = "[] call Recondo_fnc_rpRefreshUnlockShop;";
        };
        
        // Items label
        class ItemsLabel: RscText {
            idc = -1;
            x = 0.34 * safezoneW + safezoneX;
            y = 0.21 * safezoneH + safezoneY;
            w = 0.25 * safezoneW;
            h = 0.03 * safezoneH;
            text = "AVAILABLE ITEMS";
            colorText[] = {0.8, 0.8, 0.6, 1};
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9)";
        };
        
        // Items listbox
        class ItemsList: RscListbox {
            idc = 58211;
            x = 0.34 * safezoneW + safezoneX;
            y = 0.24 * safezoneH + safezoneY;
            w = 0.25 * safezoneW;
            h = 0.55 * safezoneH;
            colorBackground[] = {0.1, 0.1, 0.1, 0.6};
            colorSelect[] = {0.4, 0.4, 0.2, 1};
            colorSelect2[] = {0.4, 0.4, 0.2, 1};
            colorSelectBackground[] = {0.3, 0.3, 0.15, 1};
            colorSelectBackground2[] = {0.3, 0.3, 0.15, 1};
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9)";
            rowHeight = 0.03;
            onLBSelChanged = "[] call Recondo_fnc_rpRefreshUnlockShop;";
        };
        
        // Info panel label
        class InfoLabel: RscText {
            idc = -1;
            x = 0.60 * safezoneW + safezoneX;
            y = 0.21 * safezoneH + safezoneY;
            w = 0.19 * safezoneW;
            h = 0.03 * safezoneH;
            text = "ITEM INFO";
            colorText[] = {0.8, 0.8, 0.6, 1};
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9)";
        };
        
        // Info panel background
        class InfoPanelBG: RscText {
            idc = -1;
            x = 0.60 * safezoneW + safezoneX;
            y = 0.24 * safezoneH + safezoneY;
            w = 0.19 * safezoneW;
            h = 0.40 * safezoneH;
            colorBackground[] = {0.1, 0.1, 0.1, 0.6};
        };
        
        // Item name
        class InfoItemName: RscText {
            idc = 58220;
            x = 0.605 * safezoneW + safezoneX;
            y = 0.25 * safezoneH + safezoneY;
            w = 0.18 * safezoneW;
            h = 0.04 * safezoneH;
            text = "";
            colorText[] = {1, 1, 1, 1};
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
        };
        
        // Item classname
        class InfoClassName: RscText {
            idc = 58221;
            x = 0.605 * safezoneW + safezoneX;
            y = 0.29 * safezoneH + safezoneY;
            w = 0.18 * safezoneW;
            h = 0.025 * safezoneH;
            text = "";
            colorText[] = {0.6, 0.6, 0.6, 1};
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.75)";
        };
        
        // Item cost label
        class InfoCostLabel: RscText {
            idc = -1;
            x = 0.605 * safezoneW + safezoneX;
            y = 0.33 * safezoneH + safezoneY;
            w = 0.05 * safezoneW;
            h = 0.03 * safezoneH;
            text = "Cost:";
            colorText[] = {0.8, 0.8, 0.6, 1};
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9)";
        };
        
        // Item cost value
        class InfoCostValue: RscText {
            idc = 58222;
            x = 0.65 * safezoneW + safezoneX;
            y = 0.33 * safezoneH + safezoneY;
            w = 0.13 * safezoneW;
            h = 0.03 * safezoneH;
            text = "";
            colorText[] = {1, 1, 0.5, 1};
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9)";
        };
        
        // Unlock status
        class InfoStatus: RscText {
            idc = 58223;
            x = 0.605 * safezoneW + safezoneX;
            y = 0.37 * safezoneH + safezoneY;
            w = 0.18 * safezoneW;
            h = 0.03 * safezoneH;
            text = "";
            colorText[] = {0.5, 1, 0.5, 1};
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9)";
        };
        
        // Unlock button
        class UnlockButton: RscButton {
            idc = 58230;
            x = 0.605 * safezoneW + safezoneX;
            y = 0.65 * safezoneH + safezoneY;
            w = 0.085 * safezoneW;
            h = 0.035 * safezoneH;
            text = "UNLOCK";
            colorBackground[] = {0.3, 0.5, 0.2, 1};
            colorBackgroundActive[] = {0.4, 0.6, 0.3, 1};
            colorFocused[] = {0.4, 0.6, 0.3, 1};
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9)";
            action = "[] call Recondo_fnc_rpUnlockItem;";
        };
        
        // Take button
        class TakeButton: RscButton {
            idc = 58231;
            x = 0.695 * safezoneW + safezoneX;
            y = 0.65 * safezoneH + safezoneY;
            w = 0.085 * safezoneW;
            h = 0.035 * safezoneH;
            text = "TAKE";
            colorBackground[] = {0.2, 0.3, 0.5, 1};
            colorBackgroundActive[] = {0.3, 0.4, 0.6, 1};
            colorFocused[] = {0.3, 0.4, 0.6, 1};
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9)";
            action = "[] call Recondo_fnc_rpTakeItem;";
        };
        
        // Close button
        class CloseButton: RscButton {
            idc = 58240;
            x = 0.60 * safezoneW + safezoneX;
            y = 0.80 * safezoneH + safezoneY;
            w = 0.19 * safezoneW;
            h = 0.035 * safezoneH;
            text = "CLOSE";
            colorBackground[] = {0.4, 0.2, 0.2, 1};
            colorBackgroundActive[] = {0.5, 0.3, 0.3, 1};
            colorFocused[] = {0.5, 0.3, 0.3, 1};
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9)";
            action = "closeDialog 0;";
        };
        
        // Stats section background
        class StatsBG: RscText {
            idc = -1;
            x = 0.21 * safezoneW + safezoneX;
            y = 0.80 * safezoneH + safezoneY;
            w = 0.38 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = {0.15, 0.15, 0.1, 0.8};
        };
        
        // Stats text
        class StatsText: RscText {
            idc = 58250;
            x = 0.22 * safezoneW + safezoneX;
            y = 0.803 * safezoneH + safezoneY;
            w = 0.36 * safezoneW;
            h = 0.03 * safezoneH;
            text = "Total Earned: 0 RP | Items Unlocked: 0";
            colorText[] = {0.7, 0.7, 0.7, 1};
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
        };
        
    };
};
