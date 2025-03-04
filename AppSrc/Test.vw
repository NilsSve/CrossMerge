// C:\Projects\DF18\CMOS\AppSrc\Test.vw
// Test
//

Use DFClient.pkg
Use DFEntry.pkg
Use cRDCButton.pkg
Use cSyncTableCheckBoxGrid.pkg

Use SncSys.dd
Use SncSchem.dd
Use SncSys.dd
Use SncTable.dd
Use SncSchem.dd
Use SncLog.dd
Use SncTHea.dd
Use SncTRow.dd

Activate_View Activate_oTest For oTest
Object oTest is a dbView
    Set Location to 5 5
    Set Size to 229 558
    Set Label to "Test"
    Set Border_Style to Border_Thick
    Set pbAutoActivate to True

    Object Sncsys_DD is a Sncsys_DataDictionary
    End_Object

    Object Snctable_DD is a SncTable_DataDictionary
        Set Auto_Fill_State to True
    End_Object

    Object Sncschem_DD is a Sncschem_DataDictionary
    End_Object

    Object Snclog_DD is a Snclog_DataDictionary
    End_Object

    Object Sncthea_DD is a Sncthea_DataDictionary
        Set Ordering to 1
        Set Allow_Foreign_New_Save_State to True

        Set DDO_Server to Snctable_DD
        Set Constrain_File to Snctable.File_Number

        Procedure Request_Save
            Integer iRecid
            Get File_Field_Current_Value File_Field SncTable.ID to iRecid
            If (not(pbGetHasCurrRowId(Self))) Begin
                Set Field_Changed_Value Field SncTHea.SncTableID to iRecid
            End
            Forward Send Request_Save
        End_Procedure

        Procedure DoCreateNewRecord  // Initialize new SncTHea record.
            Integer iRecid
            Get File_Field_Current_Value File_Field SncTable.ID to iRecid
            Send Clear
            Set Field_Changed_Value Field SncTHea.SncTableID to iRecid
        End_Procedure

        // Send from field value transformation table:
        Procedure DoFindRecord Integer iMode
            Integer iRecnum iOrdering
            Move SncTHea.Recnum to iRecnum
            Get Ordering to iOrdering
            Constraint_Set Self
            Constrain SncTHea Relates to SncTable
            If (iMode >= 0) Begin
                Constrained_Find iMode SncTHea.File_Number by iOrdering
            End
            Else If (iMode = -1) Begin
                Constrained_Find First SncTHea.File_Number by iOrdering
            End
            Else If (iMode = -2) Begin
                Constrained_Find Last  SncTHea.File_Number by iOrdering
            End
            If (Found) Begin
                Send Find_By_Recnum SncTHea.File_Number SncTHea.Recnum
            End
            Else Begin        // Reset record buffer.
                Clear SncTHea
                Move iRecnum to SncTHea.Recnum
                Find Eq SncTHea by Recnum
            End
        End_Procedure

    End_Object

    Object Snctrow_DD is a Snctrow_DataDictionary
        Set DDO_Server to Sncthea_DD
        Set Constrain_File to Sncthea.File_Number
    End_Object

    Set Main_DD to Sncschem_DD
    Set Server to Sncschem_DD
    Set DEO_Attach_All_State to True

    Object oSncSchem_grd is a cSyncTableCheckBoxGrid
        Set Size to 85 454
        Set Location to 108 10
        Set peResizeColumn to rcSelectedColumn
        Set piResizeColumn to 2
        Set phoDD to (SncTable_DD(Self))
        //        Set peAnchors to anAll

        Set Line_Width to 5 0

        Set Form_Width 0 to 34
        Set Header_Label  Item 0 to "Selected"

        Set Form_Width 1 to 103
        Set Header_Label  Item 1 to "Sort Name"

        Set Form_Width 2 to 207
        Set Header_Label  Item 2 to "Database Connection Record (Description)"

        Set Form_Width 3 to 52
        Set Header_Label  Item 3 to "Delete Source"

        Set Form_Width 4 to 51
        Set Header_Label  Item 4 to "Delete Target"

        Set pbSynchSetup   to True
        //                    Set psToolTipTitle to "Collections"
        //                    Set psToolTip      to "Select the connection records that should belong to the named or selected collection name in the combo below, and press the 'Save' button. You can NOT edit a row; only select or deselect it."

        Procedure Select_Toggling Integer iItem Integer bState
            Handle hoDD
            Forward Send Select_Toggling iItem bState
            Move (SncSchem_DD(Self)) to hoDD
            // Do this to trigger a change in this DDO to auto save before
            // the Engine is started.
            Set Changed_State of hoDD to True
        End_Procedure
    End_Object

    Object oSncSchem_cb is a ComboForm
        Set Label to "Collection Name"
        Set Size to 13 220
        Set Location to 84 69
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

            Send StartWorkingMessage "Displaying Collection..."
            Get WinCombo_Current_Item to iItem
            Get WinCombo_Value Item iItem to sValue
            If (sValue = "") Begin
                Get Value to sValue
            End
            Send DoFillGrid      of oSncSchem_grd
            Send DoDisplayScheme of oSncSchem_grd sValue
            Move sValue to SncSchem.NAME
            Find eq SncSchem by Index.1
            Send StopWorkingMessage
            Move (SncSchem_DD(Self)) to hoDD
            Send Request_Assign of hoDD
        End_Procedure

        // Display default Collection Name on program startup.
        Procedure OnStartup
            Send Combo_Fill_List
            Clear SncSchem
            Move SncSys.Default_Scheme to SncSchem.Name
            Find Eq SncSchem by Index.1
            If (Found) Begin
                Set Value Item 0 to (Trim(SncSchem.Name))
            End
            Send AfterCloseUp
        End_Procedure
        Send OnStartup

    End_Object  
    
    Object oSetDefaultCollection_bn is a Button
        Set Label to "Set as Default"
        Set psToolTip to "Set the selected Collection Name as the default for the CrossMerge Engine program."
        Set Size to 14 61
        Set Location to 84 296
        Set peAnchors to anTopRight

        Procedure OnClick
            Handle hoDD ho
            Integer iItem
            String sValue

            Move (oSncSchem_cb(Self))     to ho
            Move (SncSys_DD(Self))        to hoDD
            Get WinCombo_Current_Item     of ho to iItem
            Get WinCombo_Value            of ho Item iItem to sValue
            If (Trim(SncSys.Default_Scheme) <> Trim(sValue)) Begin
                Set Field_Changed_Value of hoDD Field SncSys.Default_Scheme to sValue
                Send Request_Save
            End
        End_Procedure
    End_Object

    Object oInfoText_Container is a Container3d
        Set Location to 11 10
        Set Size to 55 454
        Set Border_Style to Border_Normal
        Set peAnchors to anTopLeftRight

        Object oInfo_tb is a Textbox
            Set Location to 2 3
            Set Label to "The CrossMerge Engine can..."
            Set Auto_Size_State to False
            Set Size to 49 447
            Set Justification_Mode to jMode_Left
            Set peAnchors to anTopLeftRight

            Procedure OnStartUp
                String sText
                Move "The CrossMerge Engine can be started with a 'Collection Name' as a parameter on the command line. This is useful when e.g. the 'Windows Scheduled Tasks' is used to start the Engine." to sText
                Move (sText + Character(13) + Character(13) + "Note: You can only make changes to the 'Selected' column. ") to sText
                Move (sText * "The 'Delete Source' and 'Delete Target' refers to 'Auto delete Source table records' and 'Auto delete old Target table records' on the CMBuilder's 'Index/Sorting' tab-page.") to sText
                Set Label to sText
            End_Procedure
            Send OnStartUp

        End_Object

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
        Set Location to 174 473
        Set Status_Help to "Save the entered Collection Name and it's grid selections"
        Set peAnchors to anTopRight
        Set psImage to "ActionSave.ico"
        Set pbAutoEnable to True

        Procedure OnClick
            Handle hoGrid hoSncSchem_cb hoDD
            String sSncTables sName
            Integer iRetval

            Move (oSncSchem_grd(Self))    to hoGrid
            Move (oSncSchem_cb(Self))     to hoSncSchem_cb
            Move (SncSchem_DD(Self))      to hoDD
            Get SelectedItems             of hoGrid to sSncTables
            Get Value of hoSncSchem_cb Item 0       to sName
            Move (Trim(sName))                      to sName
            If (Length(sName) > 0) Begin
                Send Clear                  of hoDD
                Move sName                  to SncSchem.Name
                Send Find                   of hoDD Eq Index.1
                If not (Found) Begin
                    Send Clear   of hoDD
                End
            End
            Set File_Field_Changed_Value  of hoDD File_Field SncSchem.Name   to sName
            Set File_Field_Changed_Value  of hoDD File_Field SncSchem.Tables to sSncTables
            Get  Request_Validate         of hoDD to iRetval
            If (iRetval <> 0) Begin
                Procedure_Return
            End
            Send Request_Save             of hoDD
            Send Combo_Fill_List          of hoSncSchem_cb          // Refill combo with new data.
            Set Value                     of hoSncSchem_cb Item 0 to sName
        End_Procedure

        Function IsEnabled Returns Boolean
            Boolean bSave
            Get Should_Save of SncSchem_DD to bSave
            Function_Return (bSave = True)
        End_Function

    End_Object
    Object oClear_bn is a cRDCButton
        Set Size to 14 75
        Set Label to "New"
        Set Location to 190 473
        Set Status_Help to "Clear selections and Collection name to create a new Collection Name"
        Set peAnchors to anTopRight
        Set psImage to "ActionClear.ico"
        Set pbAutoEnable to True

        Procedure OnClick
            Send DoToggleAll of oSncSchem_grd (False)
            Set Value        of oSncSchem_cb Item 0 to ""
            Send Clear of Sncschem_DD
        End_Procedure

        Function IsEnabled Returns Boolean
            Boolean bSave
            Get HasRecord of SncSchem_DD to bSave
            Function_Return (bSave = True)
        End_Function

    End_Object
    Object oDelete_bn is a cRDCButton
        Set Size to 14 75
        Set Label to "&Delete"
        Set Location to 206 473
        Set Status_Help to "Delete the selected Collection Name and it's grid selections"
        Set peAnchors to anTopRight
        Set psImage to "ActionDelete.ico"
        Set pbAutoEnable to True

        Procedure OnClick
            Integer hoDD ho
            String sValue
            Move (SncSchem_DD(Self))  to hoDD
            Move (oSncSchem_cb(Self)) to ho
            Get Value of ho Item 0    to sValue
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
            Get HasRecord of SncSchem_DD to bSave
            Function_Return (bSave = True)
        End_Function

    End_Object

End_Object
