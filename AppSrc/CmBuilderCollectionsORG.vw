Use Dfclient.pkg
Use Dftable.pkg
//Use cDbTextEdit.pkg
//Use cRDCDbForm.pkg
//Use cRDCDbGroup.pkg
//Use cRDCRadio.pkg
//Use cRDCTextbox.pkg
Use cRDCButton.pkg
//Use cRDCComboForm.pkg
//Use cRDCGroup.pkg
Use cSyncTableCheckBoxGrid.pkg

Use SncSys.dd
Use SncTable.dd
Use SncSchem.dd
Use SncLog.dd
Use SncTHea.dd
Use SncTRow.dd

Activate_View Activate_oRdcViewCollections for oRdcViewCollections
Object oRdcViewCollections is a dbView
    Set Location to 1 0
    Set Size to 242 558
    Set Label to "CrossMerge Engine Collections"
    Set Border_Style to Border_Thick
    Set Auto_Clear_DEO_State to False
    Set pbAutoActivate to True

    Property Handle phoSncTable_Recid 0

    Object oSncSys_DD is a Sncsys_DataDictionary
    End_Object

    Object oSncSchem_DD is a Sncschem_DataDictionary
    End_Object

    Set Main_DD to oSncSchem_DD
    Set Server  to oSncSchem_DD

    Object oInfoText_Container is a Container3d
        Set Location to 23 10
        Set Size to 44 454
        Set Border_Style to Border_Normal
        Set peAnchors to anTopLeftRight

        Object oInfo_tb is a Textbox
            Set Location to 2 3
            Set Label to "The CrossMerge Engine can..."
            Set Auto_Size_State to False
            Set Size to 38 447
            Set Justification_Mode to jMode_Left
            Set peAnchors to anTopLeftRight

            Procedure OnStartUp
                String sText
                Move "The CrossMerge Engine can be started with a 'Collection Name' as a parameter on the command line. This is useful when e.g. the 'Windows Scheduled Tasks' is used to start the Engine." to sText
                Move (sText + Character(13) + Character(13) + "A Collection Name consists of a series of 'Data Table Connection' records.") to sText
//                Move (sText * "The 'Delete Source' and 'Delete Target' refers to 'Auto delete Source table records' and 'Auto delete old Target table records' on the CMBuilder's 'Index/Sorting' tab-page.") to sText
                Set Label to sText
            End_Procedure
            Send OnStartUp

        End_Object

    End_Object

    Object oSncSchem_grd is a cSyncTableCheckBoxGrid
        Set Size to 128 454
        Set Location to 107 10
        Set peResizeColumn to rcSelectedColumn
        Set piResizeColumn to 2
        Set phoDD to (oSncschem_DD(Self))
        Set pbSynchSetup   to True
        Set piCheckboxColumn2 to 0
        Set piCheckboxColumn3 to 0
        Set peAnchors to anAll   

//        Set Line_Width to 5 0
        Set Line_Width to 3 0

        Set Form_Width 0 to 34
        Set Header_Label  Item 0 to "Selected"

        Set Form_Width 1 to 127
        Set Header_Label  Item 1 to "Name (Sort Field)"

        Set Form_Width 2 to 285
        Set Header_Label  Item 2 to "Description"

//        Set Form_Width 3 to 52
//        Set Header_Label  Item 3 to "Delete Source"
//
//        Set Form_Width 4 to 51
//        Set Header_Label  Item 4 to "Delete Target"

        Procedure Select_Toggling Integer iItem Integer iState
            Forward Send Select_Toggling iItem iState
            // Do this to trigger a change in this DDO to auto save before
            // the Engine is started.
            Set Changed_State of (Main_DD(Self)) to True
        End_Procedure  
        
    End_Object

    Object oSncSchem_cb is a ComboForm
        Set Label to "Collection Name"
        Set Size to 13 220
        Set Location to 75 69
        Set Status_Help to "Create a new Collection Name; 1. Press the Clear button 2. Select items from the grid 3. Enter a descriptive Name 4. Press Save"
        Set peAnchors to anTopLeftRight
        Set Form_Border to 0
        Set Label_Col_Offset to 2
        Set Label_Justification_Mode to jMode_Right

        Procedure Combo_Fill_List
            Send Combo_Delete_Data
            Clear SncSchem
            Find Gt SncSchem by Index.1
            While (Found)
                Send Combo_Add_Item (Trim(SncSchem.Name))
                Find Gt SncSchem by Index.1
            Loop
            Clear SncSchem
        End_Procedure

        Procedure OnCloseUp
            Forward Send OnCloseUp
            Send AfterCloseUp
        End_Procedure

        Procedure AfterCloseUp
            Integer iItem
            String sValue
            Handle hoDD

            Get WinCombo_Current_Item to iItem
            Get WinCombo_Value Item iItem to sValue
            If (sValue = "") Begin
                Get Value to sValue
            End
            Send DoFillGrid      of oSncSchem_grd
            Send DoDisplayScheme of oSncSchem_grd sValue
            Move sValue to SncSchem.Name
            Find eq SncSchem by Index.1
            Move (Main_DD(Self)) to hoDD
            Send Request_Assign of hoDD
        End_Procedure

        // Display default Collection Name on program startup.
        Procedure OnStartup
            Send Combo_Fill_List
            Clear SncSchem
            Move SncSys.Default_Scheme to SncSchem.Name
            Find Eq SncSchem by Index.1
            If (Found) Begin
                Set Value to (Trim(SncSchem.Name))
            End
            Send AfterCloseUp
        End_Procedure
        Send OnStartup

    End_Object

    Object oSetDefaultCollection_bn is a Button
        Set Label to "Set as Default"
        Set psToolTip to "Set the selected Collection Name as the default for the CrossMerge Engine program."
        Set Size to 14 75
        Set Location to 75 296        
        Set psImage to "SetAsDefault.ico"
        Set peAnchors to anTopRight

        Procedure OnClick
            Handle hoDD
            String sValue

            Move (oSncSys_DD(Self)) to hoDD
            Get Value of oSncSchem_cb to sValue
            Set Field_Changed_Value of hoDD Field SncSys.Default_Scheme to sValue
            Send Request_Save of hoDD
            Move (oSncSchem_DD(Self)) to hoDD
            Set Field_Changed_Value of hoDD Field SncSchem.Name to sValue
            Send Request_Save of hoDD
        End_Procedure
    End_Object

    Object oNew_btn is a cRDCButton
        Set Size to 14 75
        Set Label to "New Collection"
        Set Location to 75 473
        Set Status_Help to "Clear selections and Collection name to create a new Collection Name"
        Set peAnchors to anTopRight
        Set psImage to "ActionClear.ico"
        Set pbAutoEnable to True

        Procedure OnClick
            Send DoToggleAll of oSncSchem_grd (False)
            Set Value        of oSncSchem_cb to ""
            Send Clear of (Main_DD(Self))
            Set Changed_State to False
        End_Procedure

        Function IsEnabled Returns Boolean
            Boolean bSave bHasRecord bChangedCombo   
            Integer iItems
            Get Changed_State of oSncSchem_cb to bChangedCombo
            Get Should_Save   of (Main_DD(Self)) to bSave
            Get HasRecord     of (Main_DD(Self)) to bHasRecord
            Get NumberSelectedItems of oSncSchem_grd to iItems
            Function_Return (bChangedCombo = True or bSave = True or bHasRecord = True or iItems <> 0)
        End_Function

    End_Object

    Object oSelectAll_bn is a Button
        Set Label to "Select &All"
        Set Size to 14 75
        Set Location to 118 473
        Set Status_Help to "Select all items in the grid"
        Set peAnchors to anTopRight
        Set psImage to "SelectAll.ico"

        Procedure OnClick
            Send DoToggleAll of oSncSchem_grd 1
        End_Procedure
    End_Object

    Object oDeselectAll_bn is a Button
        Set Label to "Select &None"
        Set Size to 14 75
        Set Location to 134 473
        Set Status_Help to "De-select all items in the grid"
        Set peAnchors to anTopRight
        Set psImage to "SelectNone.ico"

        Procedure OnClick
            Send DoToggleAll of oSncSchem_grd 0
        End_Procedure
    End_Object

    Object oInvertSelection_bn is a Button
        Set Label to "&Invert Selection"
        Set Size to 14 75
        Set Location to 150 473
        Set Status_Help to "Invert the selection order"
        Set peAnchors to anTopRight
        Set psImage to "SelectInvert.ico"

        Procedure OnClick
            Send DoToggleAll of oSncSchem_grd -1
        End_Procedure
    End_Object

    Object oSave_bn is a cRDCButton
        Set Size to 14 75
        Set Label to "&Save"
        Set Location to 179 473
        Set Status_Help to "Save the entered Collection Name and it's grid selections"
        Set peAnchors to anTopRight
        Set psImage to "ActionSave.ico"
        Set pbAutoEnable to True

        Procedure OnClick
            Handle hoGrid hoSncSchem_cb hoDD
            String sSncTables sName
            Integer iRetval

            Move (oSncSchem_grd(Self)) to hoGrid
            Move (oSncSchem_cb(Self))  to hoSncSchem_cb
            Get Main_DD to hoDD
            Get SelectedItems of hoGrid to sSncTables
            Get Value of hoSncSchem_cb Item 0 to sName
            Move (Trim(sName)) to sName
            If (Length(sName) > 0) Begin
                Send Clear of hoDD
                Move sName to SncSchem.Name
                Send Find of hoDD Eq Index.1
                If (not(Found)) Begin
                    Send Clear of hoDD
                End
            End
            Set File_Field_Changed_Value  of hoDD File_Field SncSchem.Name   to sName
            Set File_Field_Changed_Value  of hoDD File_Field SncSchem.Tables to sSncTables
            Get  Request_Validate         of hoDD to iRetval
            If (iRetval <> 0) Begin
                Procedure_Return
            End
            Send Request_Save    of hoDD
            Send Combo_Fill_List of hoSncSchem_cb
            Set Value            of hoSncSchem_cb Item 0 to sName
        End_Procedure

        Function IsEnabled Returns Boolean
            Boolean bSave
            Get Should_Save of (Main_DD(Self)) to bSave
            Function_Return (bSave = True)
        End_Function

    End_Object

    Object oDelete_bn is a cRDCButton
        Set Size to 14 75
        Set Label to "&Delete"
        Set Location to 196 473
        Set Status_Help to "Delete the selected Collection Name and it's grid selections"
        Set peAnchors to anTopRight
        Set psImage to "ActionDelete.ico"
        Set pbAutoEnable to True

        Procedure OnClick
            Integer hoDD ho
            String sValue
            
            Move (oSncSchem_cb(Self)) to ho
            Get Value of ho Item 0    to sValue
            Get Main_DD               to hoDD
            Send Request_Clear        of hoDD
            Move (Trim(sValue))       to SncSchem.Name
            Send Find                 of hoDD Eq Index.1
            If (Found) Begin
                Send Request_Delete     of hoDD
                Send Combo_Fill_List    of ho
                Send DoDisplayScheme    of oSncSchem_grd ""
            End
        End_Procedure

        Function IsEnabled Returns Boolean
            Boolean bSave
            Get HasRecord of (Main_DD(Self)) to bSave
            Function_Return (bSave = True)
        End_Function

    End_Object

    Procedure DoSave
        Send KeyAction of oSave_bn
    End_Procedure

    Procedure Request_Save
        Boolean bSave
        Forward Send Request_Save
        Get Should_Save of (Main_DD(Self)) to bSave
        If (bSave = True) Begin
            Send Request_Save of oSncsys_DD
        End
        Get Should_Save of (Main_DD(Self)) to bSave
        If (bSave = True) Begin
            Send KeyAction of oSave_bn
        End
    End_Procedure

    Function DisplayDeleteWaring Returns Boolean
        String sText
        Integer iRetval

        Move "If you delete a record that has been included in a Collection it will disrupt the Collection data for selected Table Setup records." to sText
        Move (sText * "If you do, you might need to edit selections for each Collection name .") to sText
        Move (sText + "\n\nActually, the last selected record for each Collection name will be removed automatically.")       to sText
        Move (sText + "\nNote:  If this is the last record for a Collection name the Collection record itself will be deleted.\n\nContinue to Delete Record?") to sText
        Get YesNo_Box sText "Delete question" to iRetval
        Function_Return (iRetval <> MBR_YES)
    End_Function

    Set Verify_Delete_msg    to get_DisplayDeleteWaring
    Set Verify_Save_msg      to msg_None

    // Do not allow to close panel:
    Procedure Request_Cancel
    End_Procedure

    Procedure CancelWizard // This is needed by the cdbComboFormat & cdbComboDriver classes.
    End_Procedure

    // This will disable all toolbar data related buttons for the program top row.
    Function Server Returns Handle
        Function_Return 0 // (Sncschem_DD(Self))
    End_Function

    On_Key Key_Ctrl+Key_S Send DoSave
    On_Key Key_Alt+Key_A  Send KeyAction of oSelectAll_bn
    On_Key Key_Alt+Key_N  Send KeyAction of oDeselectAll_bn
    On_Key Key_Alt+Key_I  Send KeyAction of oInvertSelection_bn
    On_Key Key_Ctrl+Key_A Send KeyAction of oSelectAll_bn
    On_Key Key_Ctrl+Key_N Send KeyAction of oDeselectAll_bn
    On_Key Key_Ctrl+Key_I Send KeyAction of oInvertSelection_bn
End_Object
