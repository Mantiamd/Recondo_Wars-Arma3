/*
    RscIntelCard.hpp
    Intel Card UI Definition for Recondo Wars
    
    A stylized notification card for intel turn-in feedback
    Supports optional face photo display for HVT/Hostage intel
*/

// Base classes for controls
class RscText;
class RscStructuredText;
class RscPicture;
class RscListbox;
class RscButton;

class RscTitles {
    class Recondo_IntelCard {
        idd = -1;
        movingEnable = 0;
        duration = 9999;
        fadein = 0;
        fadeout = 0;
        name = "Recondo_IntelCard";
        
        onLoad = "uiNamespace setVariable ['Recondo_IntelCard_Display', _this select 0];";
        onUnload = "uiNamespace setVariable ['Recondo_IntelCard_Display', displayNull];";
        
        class Controls {
            // Background - Dark semi-transparent panel
            class Background: RscText {
                idc = 9200;
                x = "safezoneX + safezoneW - safezoneW * 0.32 - safezoneW * 0.02";
                y = "safezoneY + safezoneH * 0.15";
                w = "safezoneW * 0.32";
                h = "safezoneH * 0.08";
                colorBackground[] = {0.05, 0.05, 0.05, 0.85};
            };
            
            // Accent Bar - Colored strip on left edge
            class AccentBar: RscText {
                idc = 9201;
                x = "safezoneX + safezoneW - safezoneW * 0.32 - safezoneW * 0.02";
                y = "safezoneY + safezoneH * 0.15";
                w = "safezoneW * 0.006";
                h = "safezoneH * 0.08";
                colorBackground[] = {1, 0.7, 0, 1};
            };
            
            // Title Text
            class TitleText: RscText {
                idc = 9202;
                x = "safezoneX + safezoneW - safezoneW * 0.32 - safezoneW * 0.02 + safezoneW * 0.015";
                y = "safezoneY + safezoneH * 0.155";
                w = "safezoneW * 0.29";
                h = "safezoneH * 0.025";
                colorBackground[] = {0, 0, 0, 0};
                colorText[] = {1, 0.7, 0, 1};
                font = "PuristaBold";
                sizeEx = "safezoneH * 0.024";
                text = "";
            };
            
            // Priority Tag
            class PriorityTag: RscText {
                idc = 9203;
                x = "safezoneX + safezoneW - safezoneW * 0.32 - safezoneW * 0.02 + safezoneW * 0.015";
                y = "safezoneY + safezoneH * 0.18";
                w = "safezoneW * 0.1";
                h = "safezoneH * 0.018";
                colorBackground[] = {0, 0, 0, 0};
                colorText[] = {0.6, 0.6, 0.6, 1};
                font = "PuristaMedium";
                sizeEx = "safezoneH * 0.016";
                text = "";
            };
            
            // Photo Frame Background (dark border for photo)
            class PhotoFrame: RscText {
                idc = 9206;
                x = "safezoneX + safezoneW - safezoneW * 0.32 - safezoneW * 0.02 + safezoneW * 0.015";
                y = "safezoneY + safezoneH * 0.205";
                w = "safezoneH * 0.06";
                h = "safezoneH * 0.088";
                colorBackground[] = {0.15, 0.15, 0.15, 1};
            };
            
            // Photo Image (480x700 portrait photo)
            class PhotoImage: RscPicture {
                idc = 9207;
                x = "safezoneX + safezoneW - safezoneW * 0.32 - safezoneW * 0.02 + safezoneW * 0.015 + safezoneH * 0.003";
                y = "safezoneY + safezoneH * 0.208";
                w = "safezoneH * 0.054";
                h = "safezoneH * 0.079";
                text = "";
            };
            
            // Summary Text (Structured text for multi-line support)
            // Position adjusts when photo is shown
            class SummaryText: RscStructuredText {
                idc = 9205;
                x = "safezoneX + safezoneW - safezoneW * 0.32 - safezoneW * 0.02 + safezoneW * 0.015";
                y = "safezoneY + safezoneH * 0.20";
                w = "safezoneW * 0.29";
                h = "safezoneH * 0.05";
                colorBackground[] = {0, 0, 0, 0};
                class Attributes {
                    font = "PuristaLight";
                    color = "#CCCCCC";
                    size = 0.9;
                };
                text = "";
            };
        };
    };
};

/*
    Minimal dialog for Intel Board
    This dialog exists only to provide cursor visibility and input blocking.
    All actual controls are created dynamically via SQF.
*/
class Recondo_IntelBoard_Base {
    idd = 9300;
    movingEnable = 0;
    enableSimulation = 1;
    
    onLoad = "uiNamespace setVariable ['Recondo_IntelBoard_Display', _this select 0];";
    onUnload = "uiNamespace setVariable ['Recondo_IntelBoard_Display', displayNull]; RECONDO_INTELBOARD_OPEN = false;";
    
    class ControlsBackground {};
    class Controls {};
};

class Recondo_OPORD_Base {
    idd = 9400;
    movingEnable = 0;
    enableSimulation = 1;
    
    onLoad = "uiNamespace setVariable ['Recondo_OPORD_Display', _this select 0];";
    onUnload = "uiNamespace setVariable ['Recondo_OPORD_Display', displayNull]; RECONDO_OPORD_OPEN = false;";
    
    class ControlsBackground {};
    class Controls {};
};
