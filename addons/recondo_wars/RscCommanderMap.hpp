/*
    Commander System - Squad Control dialog

    IDD: 58330

    A self-contained command dialog with its own map control. The map control is
    defined in full (not inherited) because map controls are very prone to failing
    to create if any required property/sub-class is missing - inheriting from a
    base class here caused createDialog to silently return false. The property set
    below mirrors the vanilla main-map control.

    Flow:
        - Squad icons are drawn on the map by Recondo_fnc_commanderMapDrawIcons (Draw EH).
        - Clicking the map selects the nearest own squad (Recondo_fnc_commanderMapClick),
          or, when a move is armed, sets that squad's destination.
        - The right-hand button column issues orders through Recondo_fnc_commanderIssueOrder
          on the server. Behaviour / Formation reveal a fly-out sub-panel.
*/

// RscText / RscButton are already forward-declared by RscIntelCard.hpp
// (included earlier in config.cpp). RscEdit is not, so declare it here.
class RscEdit;

class RW_CmdMapBtn: RscButton {
    idc = -1;
    colorBackground[] = {0.14, 0.14, 0.14, 0.9};
    colorBackgroundActive[] = {0.32, 0.32, 0.16, 1};
    colorFocused[] = {0.32, 0.32, 0.16, 1};
    colorText[] = {0.92, 0.92, 0.92, 1};
    sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9)";
};

class RW_CmdGridEdit: RscEdit {
    idc = -1;
    colorBackground[] = {0, 0, 0, 0.7};
    colorText[] = {1, 1, 0.6, 1};
    colorSelection[] = {0.3, 0.3, 0.16, 1};
    sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
    autocomplete = "";
    canModify = 1;
};

class RscCommanderMap {
    idd = 58330;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "uiNamespace setVariable ['RW_CmdMapDisplay', _this select 0];";
    onUnload = "uiNamespace setVariable ['RW_CmdMapDisplay', displayNull];";

    class controlsBackground {
        // Outer panel
        class Background: RscText {
            idc = -1;
            x = "0.10 * safezoneW + safezoneX";
            y = "0.08 * safezoneH + safezoneY";
            w = "0.80 * safezoneW";
            h = "0.84 * safezoneH";
            colorBackground[] = {0, 0, 0, 0.85};
        };
        // Header bar
        class HeaderBar: RscText {
            idc = -1;
            x = "0.10 * safezoneW + safezoneX";
            y = "0.08 * safezoneH + safezoneY";
            w = "0.80 * safezoneW";
            h = "0.045 * safezoneH";
            colorBackground[] = {0.3, 0.3, 0.1, 1};
        };
    };

    class controls {
        // Title
        class TitleText: RscText {
            idc = 58331;
            x = "0.11 * safezoneW + safezoneX";
            y = "0.083 * safezoneH + safezoneY";
            w = "0.40 * safezoneW";
            h = "0.038 * safezoneH";
            text = "COMMANDER - SQUAD CONTROL";
            colorText[] = {1, 1, 0.6, 1};
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.1)";
        };
        // Selected-squad readout (right of header)
        class SelectedLabel: RscText {
            idc = 58332;
            x = "0.55 * safezoneW + safezoneX";
            y = "0.083 * safezoneH + safezoneY";
            w = "0.34 * safezoneW";
            h = "0.038 * safezoneH";
            text = "";
            colorText[] = {0.6, 1, 0.6, 1};
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
            style = 1; // right align
        };

        // ---- Map control (full self-contained definition) ----
        class CommanderMap {
            idc = 58333;
            type = 101;   // CT_MAP_MAIN
            style = 16;   // ST_MULTI
            deletable = 0;
            fade = 0;
            access = 0;
            onMouseButtonClick = "_this call Recondo_fnc_commanderMapClick";
            onDraw = "_this call Recondo_fnc_commanderMapDrawIcons";
            x = "0.11 * safezoneW + safezoneX";
            y = "0.14 * safezoneH + safezoneY";
            w = "0.585 * safezoneW";
            h = "0.72 * safezoneH";
            shadow = 0;
            font = "TahomaB";
            sizeEx = 0.04;
            colorBackground[] = {0.969, 0.957, 0.949, 1};
            colorOutside[] = {0, 0, 0, 1};
            colorText[] = {0, 0, 0, 1};
            colorSea[] = {0.467, 0.631, 0.851, 0.5};
            colorForest[] = {0.624, 0.78, 0.388, 0.5};
            colorRocks[] = {0, 0, 0, 0.3};
            colorCountlines[] = {0.572, 0.354, 0.188, 0.25};
            colorMainCountlines[] = {0.572, 0.354, 0.188, 0.5};
            colorCountlinesWater[] = {0.491, 0.577, 0.702, 0.3};
            colorMainCountlinesWater[] = {0.491, 0.577, 0.702, 0.6};
            colorForestBorder[] = {0, 0, 0, 0};
            colorRocksBorder[] = {0, 0, 0, 0};
            colorPowerLines[] = {0.1, 0.1, 0.1, 1};
            colorRailWay[] = {0.8, 0.2, 0, 1};
            colorNames[] = {0.1, 0.1, 0.1, 0.9};
            colorInactive[] = {1, 1, 1, 0.5};
            colorLevels[] = {0.286, 0.177, 0.094, 0.5};
            colorTracks[] = {0.84, 0.76, 0.65, 0.15};
            colorRoads[] = {0.7, 0.7, 0.7, 1};
            colorMainRoads[] = {0.9, 0.5, 0.3, 1};
            colorTracksFill[] = {0.84, 0.76, 0.65, 1};
            colorRoadsFill[] = {1, 1, 1, 1};
            colorMainRoadsFill[] = {1, 0.6, 0.4, 1};
            colorGrid[] = {0.1, 0.1, 0.1, 0.6};
            colorGridMap[] = {0.1, 0.1, 0.1, 0.6};
            stickX[] = {0.2, {"Gamma", 1, 1.5}};
            stickY[] = {0.2, {"Gamma", 1, 1.5}};
            moveOnEdges = 1;
            ptsPerSquareSea = 5;
            ptsPerSquareTxt = 20;
            ptsPerSquareCLn = 10;
            ptsPerSquareExp = 10;
            ptsPerSquareCost = 10;
            ptsPerSquareFor = 9;
            ptsPerSquareForEdge = 9;
            ptsPerSquareRoad = 6;
            ptsPerSquareObj = 9;
            showCountourInterval = 0;
            scaleMin = 0.001;
            scaleMax = 1;
            scaleDefault = 0.16;
            maxSatelliteAlpha = 0.85;
            alphaFadeStartScale = 2;
            alphaFadeEndScale = 2;
            colorTrails[] = {0.84, 0.76, 0.65, 0.15};
            colorTrailsFill[] = {0.84, 0.76, 0.65, 0.65};
            widthRailWay = 4;
            fontLabel = "RobotoCondensed";
            sizeExLabel = 0.02;
            fontGrid = "TahomaB";
            sizeExGrid = 0.02;
            fontUnits = "TahomaB";
            sizeExUnits = 0.02;
            fontNames = "RobotoCondensed";
            sizeExNames = 0.04;
            fontInfo = "RobotoCondensed";
            sizeExInfo = 0.02;
            fontLevel = "TahomaB";
            sizeExLevel = 0.02;
            text = "#(argb,8,8,3)color(1,1,1,1)";
            idcMarkerColor = -1;
            idcMarkerIcon = -1;
            textureComboBoxColor = "#(argb,8,8,3)color(1,1,1,1)";
            showMarkers = 1;
            class Legend {
                colorBackground[] = {1, 1, 1, 0.5};
                color[] = {0, 0, 0, 1};
                x = "0.02 * safezoneW + safezoneX";
                y = "0.80 * safezoneH + safezoneY";
                w = "0.10 * safezoneW";
                h = "0.06 * safezoneH";
                font = "RobotoCondensed";
                sizeEx = 0.02;
            };
            class ActiveMarker {
                color[] = {0.3, 0.1, 0.9, 1};
                size = 50;
            };
            class Command {
                color[] = {1, 1, 1, 1};
                icon = "\a3\ui_f\data\map\mapcontrol\waypoint_ca.paa";
                size = 18;
                importance = 1;
                coefMin = 1;
                coefMax = 1;
            };
            class Task {
                taskNone = "#(argb,8,8,3)color(0,0,0,0)";
                taskCreated = "#(argb,8,8,3)color(0,0,0,1)";
                taskAssigned = "#(argb,8,8,3)color(1,1,1,1)";
                taskSucceeded = "#(argb,8,8,3)color(0,1,0,1)";
                taskFailed = "#(argb,8,8,3)color(1,0,0,1)";
                taskCanceled = "#(argb,8,8,3)color(1,0.5,0,1)";
                colorCreated[] = {1, 1, 1, 1};
                colorCanceled[] = {0.7, 0.7, 0.7, 1};
                colorDone[] = {0.7, 1, 0.3, 1};
                colorFailed[] = {1, 0.3, 0.2, 1};
                color[] = {1, 1, 1, 0.8};
                icon = "\A3\ui_f\data\map\mapcontrol\taskIcon_CA.paa";
                iconCreated = "\A3\ui_f\data\map\mapcontrol\taskIconCreated_CA.paa";
                iconCanceled = "\A3\ui_f\data\map\mapcontrol\taskIconCanceled_CA.paa";
                iconDone = "\A3\ui_f\data\map\mapcontrol\taskIconDone_CA.paa";
                iconFailed = "\A3\ui_f\data\map\mapcontrol\taskIconFailed_CA.paa";
                size = 27;
                importance = 1;
                coefMin = 1;
                coefMax = 1;
            };
            class CustomMark {
                color[] = {1, 1, 1, 1};
                icon = "\a3\ui_f\data\map\mapcontrol\custommark_ca.paa";
                size = 18;
                importance = 1;
                coefMin = 1;
                coefMax = 1;
            };
            class Tree {
                color[] = {0.45, 0.64, 0.33, 0.4};
                icon = "\A3\ui_f\data\map\mapcontrol\bush_ca.paa";
                size = 12;
                importance = "0.9 * 16 * 0.05";
                coefMin = 0.25;
                coefMax = 4;
            };
            class SmallTree {
                color[] = {0.45, 0.64, 0.33, 0.4};
                icon = "\A3\ui_f\data\map\mapcontrol\bush_ca.paa";
                size = 12;
                importance = "0.6 * 12 * 0.05";
                coefMin = 0.25;
                coefMax = 4;
            };
            class Bush {
                color[] = {0.45, 0.64, 0.33, 0.4};
                icon = "\A3\ui_f\data\map\mapcontrol\bush_ca.paa";
                size = "14/2";
                importance = "0.2 * 14 * 0.05 * 0.05";
                coefMin = 0.25;
                coefMax = 4;
            };
            class Church {
                color[] = {1, 1, 1, 1};
                icon = "\A3\ui_f\data\map\mapcontrol\church_CA.paa";
                size = 24;
                importance = 1;
                coefMin = 0.85;
                coefMax = 1;
            };
            class Chapel {
                color[] = {0, 0, 0, 1};
                icon = "\A3\ui_f\data\map\mapcontrol\Chapel_CA.paa";
                size = 24;
                importance = 1;
                coefMin = 0.85;
                coefMax = 1;
            };
            class Cross {
                color[] = {0, 0, 0, 1};
                icon = "\A3\ui_f\data\map\mapcontrol\Cross_CA.paa";
                size = 24;
                importance = 1;
                coefMin = 0.85;
                coefMax = 1;
            };
            class Rock {
                color[] = {0.1, 0.1, 0.1, 0.8};
                icon = "\A3\ui_f\data\map\mapcontrol\rock_ca.paa";
                size = 12;
                importance = "0.5 * 12 * 0.05";
                coefMin = 0.25;
                coefMax = 4;
            };
            class Bunker {
                color[] = {0, 0, 0, 1};
                icon = "\A3\ui_f\data\map\mapcontrol\bunker_ca.paa";
                size = 14;
                importance = "1.5 * 14 * 0.05";
                coefMin = 0.25;
                coefMax = 4;
            };
            class Fortress {
                color[] = {0, 0, 0, 1};
                icon = "\A3\ui_f\data\map\mapcontrol\bunker_ca.paa";
                size = 16;
                importance = "2 * 16 * 0.05";
                coefMin = 0.25;
                coefMax = 4;
            };
            class Fountain {
                color[] = {0, 0, 0, 1};
                icon = "\A3\ui_f\data\map\mapcontrol\fountain_ca.paa";
                size = 11;
                importance = "1 * 12 * 0.05";
                coefMin = 0.25;
                coefMax = 4;
            };
            class ViewTower {
                color[] = {0, 0, 0, 1};
                icon = "\A3\ui_f\data\map\mapcontrol\viewtower_ca.paa";
                size = 16;
                importance = "2.5 * 16 * 0.05";
                coefMin = 0.5;
                coefMax = 4;
            };
            class Lighthouse {
                color[] = {1, 1, 1, 1};
                icon = "\A3\ui_f\data\map\mapcontrol\lighthouse_CA.paa";
                size = 24;
                importance = 1;
                coefMin = 0.85;
                coefMax = 1;
            };
            class Quay {
                color[] = {1, 1, 1, 1};
                icon = "\A3\ui_f\data\map\mapcontrol\quay_CA.paa";
                size = 24;
                importance = 1;
                coefMin = 0.85;
                coefMax = 1;
            };
            class Fuelstation {
                color[] = {1, 1, 1, 1};
                icon = "\A3\ui_f\data\map\mapcontrol\fuelstation_CA.paa";
                size = 24;
                importance = 1;
                coefMin = 0.85;
                coefMax = 1;
            };
            class Hospital {
                color[] = {1, 1, 1, 1};
                icon = "\A3\ui_f\data\map\mapcontrol\hospital_CA.paa";
                size = 24;
                importance = 1;
                coefMin = 0.85;
                coefMax = 1;
            };
            class BusStop {
                color[] = {1, 1, 1, 1};
                icon = "\A3\ui_f\data\map\mapcontrol\busstop_CA.paa";
                size = 24;
                importance = 1;
                coefMin = 0.85;
                coefMax = 1;
            };
            class LineMarker {
                textureComboBoxColor = "#(argb,8,8,3)color(1,1,1,1)";
                lineWidthThin = 0.008;
                lineWidthThick = 0.014;
                lineDistanceMin = 3e-005;
                lineLengthMin = 5;
            };
            class Transmitter {
                color[] = {1, 1, 1, 1};
                icon = "\A3\ui_f\data\map\mapcontrol\transmitter_CA.paa";
                size = 24;
                importance = 1;
                coefMin = 0.85;
                coefMax = 1;
            };
            class Stack {
                color[] = {0, 0, 0, 1};
                icon = "\A3\ui_f\data\map\mapcontrol\stack_ca.paa";
                size = 16;
                importance = "2 * 16 * 0.05";
                coefMin = 0.4;
                coefMax = 2;
            };
            class Ruin {
                color[] = {0, 0, 0, 1};
                icon = "\A3\ui_f\data\map\mapcontrol\ruin_ca.paa";
                size = 16;
                importance = "1.2 * 16 * 0.05";
                coefMin = 1;
                coefMax = 4;
            };
            class Tourism {
                color[] = {0, 0, 0, 1};
                icon = "\A3\ui_f\data\map\mapcontrol\tourism_ca.paa";
                size = 16;
                importance = "1 * 16 * 0.05";
                coefMin = 0.7;
                coefMax = 4;
            };
            class Watertower {
                color[] = {1, 1, 1, 1};
                icon = "\A3\ui_f\data\map\mapcontrol\watertower_CA.paa";
                size = 24;
                importance = 1;
                coefMin = 0.85;
                coefMax = 1;
            };
            class Waypoint {
                color[] = {1, 1, 1, 1};
                importance = 1;
                coefMin = 1;
                coefMax = 1;
                icon = "\a3\ui_f\data\map\mapcontrol\waypoint_ca.paa";
                size = 18;
            };
            class WaypointCompleted {
                color[] = {1, 1, 1, 1};
                importance = 1;
                coefMin = 1;
                coefMax = 1;
                icon = "\a3\ui_f\data\map\mapcontrol\waypointcompleted_ca.paa";
                size = 18;
            };
            class power {
                icon = "\A3\ui_f\data\map\mapcontrol\power_CA.paa";
                size = 24;
                importance = 1;
                coefMin = 0.85;
                coefMax = 1;
                color[] = {1, 1, 1, 1};
            };
            class powersolar {
                icon = "\A3\ui_f\data\map\mapcontrol\powersolar_CA.paa";
                size = 24;
                importance = 1;
                coefMin = 0.85;
                coefMax = 1;
                color[] = {1, 1, 1, 1};
            };
            class powerwave {
                icon = "\A3\ui_f\data\map\mapcontrol\powerwave_CA.paa";
                size = 24;
                importance = 1;
                coefMin = 0.85;
                coefMax = 1;
                color[] = {1, 1, 1, 1};
            };
            class powerwind {
                icon = "\A3\ui_f\data\map\mapcontrol\powerwind_CA.paa";
                size = 24;
                importance = 1;
                coefMin = 0.85;
                coefMax = 1;
                color[] = {1, 1, 1, 1};
            };
            class Shipwreck {
                icon = "\A3\ui_f\data\map\mapcontrol\Shipwreck_CA.paa";
                size = 24;
                importance = 1;
                coefMin = 0.85;
                coefMax = 1;
                color[] = {0, 0, 0, 1};
            };
        };

        // Instruction line (below the map)
        class InstructionText: RscText {
            idc = 58335;
            x = "0.11 * safezoneW + safezoneX";
            y = "0.865 * safezoneH + safezoneY";
            w = "0.585 * safezoneW";
            h = "0.03 * safezoneH";
            text = "Click a squad icon to select it.";
            colorText[] = {0.75, 0.75, 0.75, 1};
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.85)";
        };

        // ---- Fly-out sub-panel (Behaviour / Formation) ----
        class SubPanelBG: RscText {
            idc = 58348;
            x = "0.545 * safezoneW + safezoneX";
            y = "0.14 * safezoneH + safezoneY";
            w = "0.16 * safezoneW";
            h = "0.45 * safezoneH";
            colorBackground[] = {0.05, 0.05, 0.05, 0.95};
            show = 0;
        };

        // ---- Right-hand main button column ----
        class MoveBtn: RW_CmdMapBtn {
            idc = 58340;
            x = "0.71 * safezoneW + safezoneX";
            y = "0.14 * safezoneH + safezoneY";
            w = "0.18 * safezoneW";
            h = "0.05 * safezoneH";
            text = "Move Here";
        };
        class HaltBtn: RW_CmdMapBtn {
            idc = 58341;
            x = "0.71 * safezoneW + safezoneX";
            y = "0.20 * safezoneH + safezoneY";
            w = "0.18 * safezoneW";
            h = "0.05 * safezoneH";
            text = "Halt / Hold";
        };
        class BehBtn: RW_CmdMapBtn {
            idc = 58342;
            x = "0.71 * safezoneW + safezoneX";
            y = "0.26 * safezoneH + safezoneY";
            w = "0.18 * safezoneW";
            h = "0.05 * safezoneH";
            text = "Behaviour  >";
        };
        class FormBtn: RW_CmdMapBtn {
            idc = 58343;
            x = "0.71 * safezoneW + safezoneX";
            y = "0.32 * safezoneH + safezoneY";
            w = "0.18 * safezoneW";
            h = "0.05 * safezoneH";
            text = "Formation  >";
        };
        // ---- Grid move entry (hidden until 'Move Here' is pressed) ----
        class GridLabel: RscText {
            idc = 58347;
            x = "0.71 * safezoneW + safezoneX";
            y = "0.40 * safezoneH + safezoneY";
            w = "0.18 * safezoneW";
            h = "0.03 * safezoneH";
            text = "Enter 8-digit grid:";
            colorText[] = {0.85, 0.85, 0.85, 1};
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.85)";
            show = 0;
        };
        class GridInput: RW_CmdGridEdit {
            idc = 58345;
            x = "0.71 * safezoneW + safezoneX";
            y = "0.435 * safezoneH + safezoneY";
            w = "0.18 * safezoneW";
            h = "0.04 * safezoneH";
            text = "";
            show = 0;
        };
        class GridConfirmBtn: RW_CmdMapBtn {
            idc = 58346;
            x = "0.71 * safezoneW + safezoneX";
            y = "0.485 * safezoneH + safezoneY";
            w = "0.18 * safezoneW";
            h = "0.05 * safezoneH";
            text = "Confirm Move";
            colorBackground[] = {0.16, 0.30, 0.16, 0.9};
            colorBackgroundActive[] = {0.25, 0.5, 0.25, 1};
            colorFocused[] = {0.25, 0.5, 0.25, 1};
            show = 0;
        };

        class CloseBtn: RW_CmdMapBtn {
            idc = 58344;
            x = "0.71 * safezoneW + safezoneX";
            y = "0.81 * safezoneH + safezoneY";
            w = "0.18 * safezoneW";
            h = "0.05 * safezoneH";
            text = "Close";
            colorBackground[] = {0.35, 0.16, 0.16, 0.9};
            colorBackgroundActive[] = {0.5, 0.25, 0.25, 1};
            colorFocused[] = {0.5, 0.25, 0.25, 1};
        };

        // ---- Behaviour sub-panel buttons (hidden by default) ----
        class Beh0: RW_CmdMapBtn { idc = 58350; x = "0.55 * safezoneW + safezoneX"; y = "0.145 * safezoneH + safezoneY"; w = "0.15 * safezoneW"; h = "0.045 * safezoneH"; text = "Careless"; show = 0; };
        class Beh1: RW_CmdMapBtn { idc = 58351; x = "0.55 * safezoneW + safezoneX"; y = "0.195 * safezoneH + safezoneY"; w = "0.15 * safezoneW"; h = "0.045 * safezoneH"; text = "Safe"; show = 0; };
        class Beh2: RW_CmdMapBtn { idc = 58352; x = "0.55 * safezoneW + safezoneX"; y = "0.245 * safezoneH + safezoneY"; w = "0.15 * safezoneW"; h = "0.045 * safezoneH"; text = "Aware"; show = 0; };
        class Beh3: RW_CmdMapBtn { idc = 58353; x = "0.55 * safezoneW + safezoneX"; y = "0.295 * safezoneH + safezoneY"; w = "0.15 * safezoneW"; h = "0.045 * safezoneH"; text = "Combat"; show = 0; };
        class Beh4: RW_CmdMapBtn { idc = 58354; x = "0.55 * safezoneW + safezoneX"; y = "0.345 * safezoneH + safezoneY"; w = "0.15 * safezoneW"; h = "0.045 * safezoneH"; text = "Stealth"; show = 0; };

        // ---- Formation sub-panel buttons (hidden by default) ----
        class Form0: RW_CmdMapBtn { idc = 58360; x = "0.55 * safezoneW + safezoneX"; y = "0.145 * safezoneH + safezoneY"; w = "0.15 * safezoneW"; h = "0.045 * safezoneH"; text = "Column"; show = 0; };
        class Form1: RW_CmdMapBtn { idc = 58361; x = "0.55 * safezoneW + safezoneX"; y = "0.195 * safezoneH + safezoneY"; w = "0.15 * safezoneW"; h = "0.045 * safezoneH"; text = "Staggered Column"; show = 0; };
        class Form2: RW_CmdMapBtn { idc = 58362; x = "0.55 * safezoneW + safezoneX"; y = "0.245 * safezoneH + safezoneY"; w = "0.15 * safezoneW"; h = "0.045 * safezoneH"; text = "Wedge"; show = 0; };
        class Form3: RW_CmdMapBtn { idc = 58363; x = "0.55 * safezoneW + safezoneX"; y = "0.295 * safezoneH + safezoneY"; w = "0.15 * safezoneW"; h = "0.045 * safezoneH"; text = "Echelon Left"; show = 0; };
        class Form4: RW_CmdMapBtn { idc = 58364; x = "0.55 * safezoneW + safezoneX"; y = "0.345 * safezoneH + safezoneY"; w = "0.15 * safezoneW"; h = "0.045 * safezoneH"; text = "Echelon Right"; show = 0; };
        class Form5: RW_CmdMapBtn { idc = 58365; x = "0.55 * safezoneW + safezoneX"; y = "0.395 * safezoneH + safezoneY"; w = "0.15 * safezoneW"; h = "0.045 * safezoneH"; text = "Vee"; show = 0; };
        class Form6: RW_CmdMapBtn { idc = 58366; x = "0.55 * safezoneW + safezoneX"; y = "0.445 * safezoneH + safezoneY"; w = "0.15 * safezoneW"; h = "0.045 * safezoneH"; text = "Line"; show = 0; };
        class Form7: RW_CmdMapBtn { idc = 58367; x = "0.55 * safezoneW + safezoneX"; y = "0.495 * safezoneH + safezoneY"; w = "0.15 * safezoneW"; h = "0.045 * safezoneH"; text = "File"; show = 0; };
        class Form8: RW_CmdMapBtn { idc = 58368; x = "0.55 * safezoneW + safezoneX"; y = "0.545 * safezoneH + safezoneY"; w = "0.15 * safezoneW"; h = "0.045 * safezoneH"; text = "Diamond"; show = 0; };
    };
};
