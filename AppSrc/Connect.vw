Use Dfsellst.pkg
Use cRDCComboForm.pkg
Use cRDCButton.pkg
Use cSyncTableCheckBoxGrid.pkg
Use cRDCForm.pkg
Use cRDCCheckbox.pkg
Use cZeroLogBn.pkg
Use cSynchronize.pkg

Use SncSys.dd
Use SncTable.dd
Use SncSchem.dd
Use SncLog.dd

Activate_View Activate_oConnectView For oConnectView
Object oConnectView is a DbView
    Set Label to "Connect"
    Set Size to 195 528
    Set Location to 0 0
    Set pbAutoActivate to True
    Set Border_Style to Border_Thick
    Set Auto_Clear_DEO_State to False
    Set Verify_Save_msg to msg_None
    Set Icon to "CMEngine.ico"

    Object Sncsys_DD is a Sncsys_DataDictionary
    End_Object

    Object Snctable_DD is a SncTable_DataDictionary
        Procedure OnConstrain
            Forward Send OnConstrain
            Constrain SncTable.Hide Eq 0
        End_Procedure
    End_Object

    Object Sncschem_DD is a Sncschem_DataDictionary
    End_Object

    Object Snclog_DD is a Snclog_DataDictionary
    End_Object

    Set Main_DD to Sncsys_DD
    Set Server to Sncsys_DD

//    Object oImageList is a cImageList
//        Procedure OnCreate
//            Integer iIndex
//            Get AddTransparentImage "CmEngine16.bmp"   clFuchsia to iIndex
//            Get AddTransparentImage "Log16.bmp"        clFuchsia to iIndex
//        End_Procedure
//    End_Object

    Object oSncSchem_cf is a cRDCComboForm
        Set Label to "Collection Name:"
        Set Size to 14 275
        Set Location to 13 71
        Set Status_Help to "Select a collection name from the list"
        Set peAnchors to anTopLeftRight
        Set Form_Border to 0
        Set Label_Col_Offset to 2
        Set Label_Justification_Mode to jMode_Right
        Set Entry_State Item 0 to False

        // Combo_Fill_List is called when the list needs filling
        Procedure Combo_Fill_List
            Handle hoDD
            Move (SncSchem_DD(Self)) to hoDD
            Send Combo_Delete_Data
            Send Clear               of hoDD
            Send Find                of hoDD First_Record Index.1
            While (Found)
                Send Combo_Add_Item (Trim(SncSchem.Name))
                Send Find              of hoDD Next_Record Index.1
            Loop
            Set Value Item 0 to (Trim(SncSys.Default_Scheme))
        End_Procedure

        Procedure OnChange
            Handle ho
            Integer iItem iItems
            String sValue

            Get Combo_Item_Count to iItems
            If iItems Begin
                // *** Change 2012-06-04 Start Nils G. Svedmyr
                //  Get WinCombo_Current_Item     to iItem
                //  Get WinCombo_Value item iItem to sValue
                Get Value to sValue
                // *** Change 2012-06-04 Stop Nils G. Svedmyr
                Move (oSncTable_grd(Self))    to ho
                Send DoFillGrid               of ho
                Send DoDisplayScheme          of ho sValue
            End
        End_Procedure  
        
    End_Object

    Object oStart_bn is a cRDCButton
        Set Label to "&Start/Run"
        Set Size to 14 75
        Set Location to 13 358
        Set Status_Help to "Start connecting selected data tables"
        Set peAnchors to anTopRight
        Set Default_State to True
        Set FontWeight to fw_Bold
        Set psImage to "Runprogram.ico"

        Procedure OnClick
            Boolean bChecked
            Get Checked_State of oRunMinimized_cb to bChecked
            If bChecked Begin
                Set View_Mode of oMain to ViewMode_Iconize
            End
            Send DoProcess of oSynchronize (oSncTable_grd(Self)) // Proc in cSynchronize.pkg
            If bChecked Begin
                Set View_Mode of oMain to ViewMode_Normal
            End
        End_Procedure
    End_Object

    Object oSelectAll_bn is a cRDCButton
        Set Label to "S&elect All"
        Set Size to 14 75
        Set Location to 46 444
        Set Status_Help to "Select all grid items"
        Set peAnchors to anTopRight
        Set psImage to "SelectAll.ico"
        Set Enabled_State to SncSys.AllowTblChange

        Procedure OnClick
            Send DoToggleAll of oSncTable_grd True
        End_Procedure
    End_Object

    Object oDeselectAll_bn is a cRDCButton
        Set Label to "Select &None"
        Set Size to 14 75
        Set Location to 62 444
        Set Status_Help to "Deselect all grid items"
        Set peAnchors to anTopRight
        Set psImage to "SelectNone.ico"
        Set Enabled_State to SncSys.AllowTblChange

        Procedure OnClick
            Send DoToggleAll of oSncTable_grd (False)
        End_Procedure
    End_Object

    Object oInvertSelection_bn is a cRDCButton
        Set Label to "&Invert Selection"
        Set Size to 14 75
        Set Location to 78 444
        Set Status_Help to "Invert the current selection of grid items"
        Set peAnchors to anTopRight
        Set psImage to "SelectInvert.ico"
        Set Enabled_State to SncSys.AllowTblChange

        Procedure OnClick
            Send DoToggleAll of oSncTable_grd -1
        End_Procedure
    End_Object

    Object oSncTable_grd is a cSyncTableCheckboxGrid
//        Set phoSynchGrid of ghoApplication to Self
        Set Size to 151 428
        Set Location to 36 8
        Set peAnchors to anAll
        Set peResizeColumn to rcSelectedColumn
        Set piResizeColumn to 2
        Set phoDD to (SncTable_DD(Self))
        Set piCheckboxColumn2 to 0
        Set piCheckboxColumn3 to 0
        Set pbSynchSetup to False

//        Set Line_Width to 5 0
        Set Line_Width to 3 0

        Set Form_Width 0 to 34
        Set Header_Label  Item 0 to "Selected"

        Set Form_Width 1 to 129
        Set Header_Label  Item 1 to "Name (Sort Field)"

        Set Form_Width 2 to 288
        Set Header_Label  Item 2 to "Description"

//        Set Form_Width 3 to 52
//        Set Header_Label  Item 3 to "Delete Source"
//
//        Set Form_Width 4 to 49
//        Set Header_Label  Item 4 to "Delete Target"

        Procedure OnStartUp
            String sValue

            Send DoFillGrid
            Move (Trim(SncSys.Default_Scheme)) to sValue
            Send DoFillGrid
            Send DoDisplayScheme sValue
            If (Length(psOrgCollectionName(ghoApplication)) > 0) Begin
                Send KeyAction of oStart_bn
                // Reset settings prior to collection name passed on command line:
                Reread SncSys
                    Move (psOrgCollectionName(ghoApplication)) to SncSys.Default_Scheme
                    Move 0                                     to SncSys.AutoStart
                    Move 0                                     to SncSys.RunMinimized
                    SaveRecord SncSys
                Unlock
                Abort
            End
        End_Procedure
        Send OnStartUp
        
    End_Object

    Object oRunMinimized_cb is a CheckBox
        Set Label to "Run &Minimized"
        Set Size to 14 63
        Set Location to 15 446
        Set Status_Help to "Run program minimized while connecting data tables."
        Set Checked_State to SncSys.RunMinimized
        Set peAnchors to anTopRight
    End_Object

    Procedure DoChangeCheckbox
        Integer ho bState
        Move (oRunMinimized_cb(Self)) to ho
        Get Select_State of ho to bState
        Set Select_State of ho to (not(bState))
    End_Procedure

    Object oSynchronize is a cSynchronize
        Set Location to 90 451
        Set phoPanel to (oMain(Self))
    End_Object

    Procedure DoStartEngine
        Send KeyAction of oStart_bn
    End_Procedure

    // Do not allow to close panel:
    Procedure Request_Cancel
    End_Procedure

    Function RdsMain_Panel_Id Returns Integer
        Function_Return Self
    End_Function

    Function Item_Count Returns Integer
    End_Function

    On_Key Key_Alt+Key_E  Send KeyAction of oSelectAll_bn
    On_Key Key_Ctrl+Key_E Send KeyAction of oSelectAll_bn
    On_Key Key_Alt+Key_N  Send KeyAction of oDeselectAll_bn
    On_Key Key_Ctrl+Key_N Send KeyAction of oDeselectAll_bn
    On_Key Key_Alt+Key_I  Send KeyAction of oInvertSelection_bn
    On_Key Key_Ctrl+Key_I Send KeyAction of oInvertSelection_bn
    On_Key Key_Alt+Key_S  Send DoStartEngine
    On_Key Key_Ctrl+Key_S Send DoStartEngine
    On_Key Key_Alt+Key_M  Send DoChangeCheckBox
    On_Key Key_Ctrl+Key_M Send DoChangeCheckBox
End_Object
