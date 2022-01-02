
//--- OffroadsHelper
class dzn_Offroads_HelperInitGroup: RscControlsGroup
{
    idd = 134810;
    idc = 2000;
    x = 14 * GUI_GRID_W + GUI_GRID_X;
    y = 6 * GUI_GRID_H + GUI_GRID_Y;
    w = 13 * GUI_GRID_W;
    h = 8 * GUI_GRID_H;
    colorBackground[] = { 0,0,0,0.75 };

    class controls
    {
        class dzn_Offroads_Init_BG: IGUIBack
        {
            idc = -1;
            x = 14 * GUI_GRID_W + GUI_GRID_X;
            y = 6 * GUI_GRID_H + GUI_GRID_Y;
            w = 13 * GUI_GRID_W;
            h = 8 * GUI_GRID_H;
            colorBackground[] = {0,0,0,0.75};
        };
        class dzn_Offroads_Init_Btn_Scan: RscButton
        {
            idc = 1000;
            text = "Map Scan"; //--- ToDo: Localize;
            x = 15 * GUI_GRID_W + GUI_GRID_X;
            y = 7 * GUI_GRID_H + GUI_GRID_Y;
            w = 5 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
        };
        class dzn_Offroads_Init_Edit_ScanSize: RscEdit
        {
            idc = 1001;
            x = 21 * GUI_GRID_W + GUI_GRID_X;
            y = 8 * GUI_GRID_H + GUI_GRID_Y;
            w = 5 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
        };
        class dzn_Offroads_Init_Label_ScanSize: RscText
        {
            idc = -1;
            text = "Grid size"; //--- ToDo: Localize;
            x = 21 * GUI_GRID_W + GUI_GRID_X;
            y = 7 * GUI_GRID_H + GUI_GRID_Y;
            w = 5 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
        };
        class dzn_Offroads_Init_Btn_Manual: RscButton
        {
            idc = 1002;
            text = "Manual"; //--- ToDo: Localize;
            x = 15 * GUI_GRID_W + GUI_GRID_X;
            y = 11.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 11 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
        };
        class dzn_Offroads_Init_Label_Separator: RscText
        {
            idc = -1;
            text = "or"; //--- ToDo: Localize;
            x = 19.5 * GUI_GRID_W + GUI_GRID_X;
            y = 10 * GUI_GRID_H + GUI_GRID_Y;
            w = 2 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
        };
    };
};

class dzn_Offroads_HelperGroup: RscControlsGroup
{
    idd = 134811;
    idc = 2000;
    x = 0 * GUI_GRID_W + GUI_GRID_X;
    y = 1 * GUI_GRID_H + GUI_GRID_Y;
    w = 30 * GUI_GRID_W;
    h = 12 * GUI_GRID_H;
    colorBackground[] = {0,0,0,0.75};

    class controls
    {
        class dzn_Offroads_BG: IGUIBack
        {
            x = 0 * GUI_GRID_W + GUI_GRID_X;
            y = 1 * GUI_GRID_H + GUI_GRID_Y;
            w = 30 * GUI_GRID_W;
            h = 12 * GUI_GRID_H;
            colorBackground[] = {0,0,0,0.75};
        };

        class dzn_Offroads_Listbox_Positions: RscListbox
        {
            idc = 2201;
            x = 1 * GUI_GRID_W + GUI_GRID_X;
            y = 4 * GUI_GRID_H + GUI_GRID_Y;
            w = 13.5 * GUI_GRID_W;
            h = 8 * GUI_GRID_H;
        };
        class dzn_Offroads_Dropdown_Surfaces: RscCombo
        {
            idc = 2202;
            x = 1 * GUI_GRID_W + GUI_GRID_X;
            y = 2 * GUI_GRID_H + GUI_GRID_Y;
            w = 28.5 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
        };

        class dzn_Offroads_Label_Resistance: RscText
        {
            text = "Surf. Resistance"; //--- ToDo: Localize;
            x = 16 * GUI_GRID_W + GUI_GRID_X;
            y = 4 * GUI_GRID_H + GUI_GRID_Y;
            w = 7 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
        };
        class dzn_Offroads_Label_SlidingForce: RscText
        {
            text = "Sliding force"; //--- ToDo: Localize;
            x = 16 * GUI_GRID_W + GUI_GRID_X;
            y = 6 * GUI_GRID_H + GUI_GRID_Y;
            w = 7 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
        };
        class dzn_Offroads_Label_BouncingForce: RscText
        {
            text = "Bouncing force"; //--- ToDo: Localize;
            x = 16 * GUI_GRID_W + GUI_GRID_X;
            y = 8 * GUI_GRID_H + GUI_GRID_Y;
            w = 7 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
        };
        class dzn_Offroads_Edit_Resistance: RscEdit
        {
            idc = 2210;
            x = 24 * GUI_GRID_W + GUI_GRID_X;
            y = 4 * GUI_GRID_H + GUI_GRID_Y;
            w = 5 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
        };
        class dzn_Offroads_Edit_SlidingForce: RscEdit
        {
            idc = 2211;
            x = 24 * GUI_GRID_W + GUI_GRID_X;
            y = 6 * GUI_GRID_H + GUI_GRID_Y;
            w = 5 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
        };
        class dzn_Offroads_Edit_BouncingForce: RscEdit
        {
            idc = 2212;
            x = 24 * GUI_GRID_W + GUI_GRID_X;
            y = 8 * GUI_GRID_H + GUI_GRID_Y;
            w = 5 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
        };

        class dzn_Offroads_Btn_Save: RscButtonMenu
        {
            idc = 2220;
            text = "Save"; //--- ToDo: Localize;
            x = 24 * GUI_GRID_W + GUI_GRID_X;
            y = 10 * GUI_GRID_H + GUI_GRID_Y;
            w = 5 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
        };
        class dzn_Offroads_Btn_Export: RscButtonMenu
        {
            idc = 2221;
            text = "EXPORT"; //--- ToDo: Localize;
            x = 24 * GUI_GRID_W + GUI_GRID_X;
            y = 11.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 5 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
        };

        class dzn_Offroads_Btn_GoTo: RscButtonMenu
        {
            idc = 2222;
            text = "GO TO"; //--- ToDo: Localize;
            x = 0 * GUI_GRID_W + GUI_GRID_X;
            y = 13 * GUI_GRID_H + GUI_GRID_Y;
            w = 10 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
        };
        class dzn_Offroads_Btn_Mode: RscButtonMenu
        {
            idc = 2223;
            text = "Mode select"; //--- ToDo: Localize;
            x = 10 * GUI_GRID_W + GUI_GRID_X;
            y = 13 * GUI_GRID_H + GUI_GRID_Y;
            w = 9.5 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
        };
        class dzn_Offroads_Btn_Cancel: RscButtonMenuCancel
        {
            x = 19.5 * GUI_GRID_W + GUI_GRID_X;
            y = 13 * GUI_GRID_H + GUI_GRID_Y;
            w = 10.5 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
            onButtonClick = "closeDialog 2;";
        };
    };
};

class dzn_Offroads_HelperExportGroup: RscControlsGroup
{
    idd = 134812;
    idc = 2000;
    x = 15 * GUI_GRID_W + GUI_GRID_X;
    y = 6 * GUI_GRID_H + GUI_GRID_Y;
    w = 11 * GUI_GRID_W;
    h = 9 * GUI_GRID_H;
    colorBackground[] = {0,0,0,0.75};

    class controls
    {
        class dzn_Offroads_HelperExport_BG: IGUIBack
        {
            x = 15 * GUI_GRID_W + GUI_GRID_X;
            y = 6 * GUI_GRID_H + GUI_GRID_Y;
            w = 11 * GUI_GRID_W;
            h = 9 * GUI_GRID_H;
            colorBackground[] = {0,0,0,0.75};
        };
        class dzn_Offroads_HelperExport_Btn_ExportSQF: RscButtonMenu
        {
            idc = 2901;
            text = "Export as SQF"; //--- ToDo: Localize;
            x = 16 * GUI_GRID_W + GUI_GRID_X;
            y = 7 * GUI_GRID_H + GUI_GRID_Y;
            w = 9 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
        };
        class dzn_Offroads_HelperExport_Btn_ExportCPP: RscButtonMenu
        {
            idc = 2902;
            text = "Export as Config"; //--- ToDo: Localize;
            x = 16 * GUI_GRID_W + GUI_GRID_X;
            y = 10 * GUI_GRID_H + GUI_GRID_Y;
            w = 9 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
        };
        class dzn_Offroads_HelperExport_Btn_Cancel: RscButtonMenuCancel
        {
            x = 16 * GUI_GRID_W + GUI_GRID_X;
            y = 13 * GUI_GRID_H + GUI_GRID_Y;
            w = 9 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
            onButtonClick = "closeDialog 2;";
        };
    };
};
