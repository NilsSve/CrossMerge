Use Dfclient.pkg
Use cRDCHeaderDbGroup.pkg
Use cRDCButton.pkg
Use cRDCComboForm.pkg   
Use cRDCDbView.pkg
Use cRDCButton.pkg
Use cCJGridColumnRowIndicator.pkg
Use cCJSyncTableCheckBoxGrid.pkg
Use cSynchronize.pkg

Use SncSys.dd
Use SncTable.dd
Use SncSchem.dd
Use cSncSchemRow.dd

Activate_View Activate_oRdcViewCollections for oRdcViewCollections
Object oRdcViewCollections is a cRDCDbView
    Set Location to 1 0
    Set Size to 236 431
    Set Label to "CrossMerge Engine Collections" 
    Set Border_Style to Border_Thick
    Set Auto_Clear_DEO_State to False
    Set Icon to "CollectionDetails.ico"
    Set pbAutoActivate to True

    Property Handle phoSncTableGrid

    Object oSynchronize is a cSynchronize
        Set Location to 90 451
        Set phoPanel to (oMain(Self))
    End_Object

    Object oSncSys_DD is a SncSys_DataDictionary
    End_Object

    Object oSncSchem_DD is a SncSchem_DataDictionary
    End_Object

    Object oSncSchemRow_DD is a SncSchemRow_DataDictionary
        Set Constrain_file to SncSchem.File_number
        Set DDO_Server to oSncSchem_DD
    End_Object

    Set Main_DD to oSncSchem_DD
    Set Server  to oSncSchem_DD

    Object oCollectionHeader_grp is a cRDCHeaderDbGroup
        Set Size to 49 406
        Set Location to 8 13
        Set Label to "Collection Header"
        Set psImage to "CollectionHeader2.ico"

        Object oSncSchem_cb is a cRDCComboForm
            Set Label to "Collection Name"
            Set Size to 14 192
            Set Location to 24 79
            Set Status_Help to "Create a new Collection Name; 1. Press the Clear button 2. Select items from the grid 3. Enter a descriptive Name 4. Press Save"
            Set peAnchors to anTopLeftRight
            Set Form_Border to 0
    
            Procedure Combo_Fill_List
                Send Combo_Delete_Data
                Clear SncSchem
                Find Gt SncSchem by Index.1
                While (Found)
                    Send Combo_Add_Item (Trim(SncSchem.Name))
                    Find Gt SncSchem by Index.1
                Loop
                Send Request_Assign of (Main_DD(Self))
            End_Procedure
    
            Procedure OnCloseUp
                Forward Send OnCloseUp
                Send AfterCloseUp
            End_Procedure
    
            Procedure AfterCloseUp
                Integer iItem
                String sValue
    
                Get WinCombo_Current_Item to iItem
                Get WinCombo_Value Item iItem to sValue
                If (sValue = "") Begin
                    Get Value to sValue
                End                          
                Set Value to sValue
                Move sValue to SncSchem.Name
                Find eq SncSchem by Index.1
                Send Request_Assign of (Main_DD(Self))
                Send LoadData of oSncSchem_grd
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
                Send Request_Assign of (Main_DD(Self))
            End_Procedure
            Send OnStartup
    
        End_Object   
        
        Object oSetDefaultCollection_bn is a cRDCButton
            Set Label to "Set as Default"
            Set psToolTip to "Set the selected Collection Name as the default for the CrossMerge Engine program."
            Set Size to 14 63
            Set Location to 24 278
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
        
        Object oRunMinimized_cb is a CheckBox
            Set Label to "Run &Minimized"
            Set Size to 14 60
            Set Location to 7 279
            Set Status_Help to "Run program minimized while connecting data tables."
            Set Checked_State to SncSys.RunMinimized
            Set peAnchors to anTopRight
        End_Object    
        
        Object oStart_bn is a cRDCButton
//            Set Size to 14 48
            Set Location to 24 346
            Set Label to "&Start"
//            Set FontWeight to fw_Bold
            Set psToolTip to "Start connecting selected data tables"
            Set psImage to "Runprogram.ico"
            Set Default_State to True
            Set peAnchors to anTopRight
    
            Procedure OnClick
                Boolean bChecked
                Get Checked_State of oRunMinimized_cb to bChecked
                If bChecked Begin
                    Set View_Mode of oMain to ViewMode_Iconize
                End
                Send DoProcess of oSynchronize (oSncSchem_grd(Self))
                If bChecked Begin
                    Set View_Mode of oMain to ViewMode_Normal
                End
            End_Procedure
        End_Object

    End_Object

    Object oCollectionDetails_grp is a cRDCHeaderDbGroup
        Set Size to 158 406
        Set Location to 68 13
        Set Label to "Collection Details"
        Set psImage to "CollectionDetails2.ico"
        Set peAnchors to anAll 

        Object oSncSchem_grd is a cCJSyncTableCheckBoxGrid
            Set Size to 124 329
            Set Location to 24 10
            Set phoDD to (oSncSchem_DD(Self))
            Set pbSynchSetup to True
            Set peAnchors to anAll   
            Set phoSncTableGrid to Self
            
            Object oCJGridColumnRowIndicator is a cCJGridColumnRowIndicator
                Set piWidth to 18
                Set pbResizable to False
            End_Object  
            
            Object oCJSyncTableCheckBoxColumn is a cCJSyncTableCheckBoxColumn
                Set piCheckboxCol to Self
                Set piWidth to 49
            End_Object     
    
            Object oName_col is a cCJGridColumn  
                Set phoDataCol to Self
                Set piWidth to 202
                Set psCaption to "Name (Sort Field)"
                Set psToolTip to "The name is used to sort connection items."
            End_Object
    
            Object oDescription_col is a cCJGridColumn  
                Set phoDescriptionCol to Self
                Set piWidth to 279
                Set psCaption to "Description"
                Set psToolTip to "A description for the connection item"
            End_Object
    
            Object oSncTableID_col is a cCJGridColumn
                Set phoIDCol to Self
                Set piWidth to 75
                Set psCaption to "SncTable ID"
                Set psToolTip to "Hidden column for the SncTable ID"
                Set peDataType to Mask_Numeric_Window
                Set pbVisible to False   
                Set pbShowInFieldChooser to False
            End_Object
    
            Object oDeleteSource_col is a cCJGridColumn   
                Set piCheckboxCol2 to Self
                Set piWidth to 60
                Set psCaption to "Del Source"
                Set psToolTip to "Select an item by using the space bar or click with the mouse."
                Set pbCheckbox to True
                Set peHeaderAlignment to xtpAlignmentCenter
                Set peFooterAlignment to xtpAlignmentCenter
                Set peDataType to Mask_Numeric_Window
                Set pbVisible to False              
                Set pbShowInFieldChooser to False
            End_Object
    
            Object oDeleteTarget_col is a cCJGridColumn
                Set piCheckboxCol3 to Self
                Set piWidth to 60
                Set psCaption to "Del Target"
                Set psToolTip to "Select an item by using the space bar or click with the mouse."
                Set pbCheckbox to True
                Set peHeaderAlignment to xtpAlignmentCenter
                Set peFooterAlignment to xtpAlignmentCenter
                Set peDataType to Mask_Numeric_Window
                Set pbVisible to False 
                Set pbShowInFieldChooser to False
            End_Object
    
            Function CurrentSchemaID Returns Integer
                String sName 
                Integer iSncSchemID
                
                Move 0 to iSncSchemID                
                Get Value of oSncSchem_cb to sName
                Move (Trim(sName)) to sName
                Clear SncSchem
                Move sName to SncSchem.Name
                Find Eq SncSchem by Index.1
                If (Found = True) Begin
                    Move SncSchem.ID to iSncSchemID
                End
                
                Function_Return iSncSchemID
            End_Function
    
            Procedure LoadData
                Handle hoDataSource
                tDataSourceRow[] TheData TheDataEmpty
                tsGridContent[] asGridContent
                Integer iSize iCount iRow iSncSchemID
                Integer iCheckBoxCol iNameCol iDescriptionCol iDeleteSourceCol iDeleteTargetCol iSncTableID
                 
                If (not(IsComObjectCreated(Self))) Begin
                    Procedure_Return
                End
    
                Get phoDataSource to hoDataSource
                Get DataSource of hoDataSource to TheData
                Move TheDataEmpty to TheData
                Get piColumnId of (piCheckboxCol(Self)) to iCheckBoxCol
                Get piColumnId of oName_col             to iNameCol
                Get piColumnId of oDescription_col      to iDescriptionCol
                Get piColumnId of oDeleteSource_col     to iDeleteSourceCol
                Get piColumnId of oDeleteTarget_col     to iDeleteTargetCol                                             
                Get piColumnId of oSncTableID_col       to iSncTableID
                
                Get CurrentSchemaID to iSncSchemID
                Get FillCollectionArray iSncSchemID to asGridContent
                Move (SizeOfArray(asGridContent)) to iSize
                Decrement iSize
                Move 0 to iCount                          
                
                Move 0 to iRow
                For iCount from 0 to iSize
                    Move asGridContent[iCount].bSelected     to TheData[iRow].sValue[iCheckBoxCol]
                    Move asGridContent[iCount].sName         to TheData[iRow].sValue[iNameCol]
                    Move asGridContent[iCount].sDescription  to TheData[iRow].sValue[iDescriptionCol]
                    Move asGridContent[iCount].bDeleteSource to TheData[iRow].sValue[iDeleteSourceCol]
                    Move asGridContent[iCount].bDeleteTarget to TheData[iRow].sValue[iDeleteTargetCol]
                    Move asGridContent[iCount].iSncTableID   to TheData[iRow].sValue[iSncTableID]
                    Increment iRow
                Loop
    
                If (iRow <> 0) Begin
                    Send ReInitializeData TheData False
                    Send MoveToFirstRow
                End
                Else Begin
                    Send InitializeData TheDataEmpty
                End
                Send DoSetCheckboxFooterText
            End_Procedure 
            
            Function FillCollectionArray Integer iSncSchemID Returns tsGridContent[]
                tsGridContent[] asGridContent 
                String sName sDescription   
                Integer iRow iRecnum
                Boolean bSelected bDeleteSource bDeleteTarget
                
                Move 0 to iRow      
                Move SncTable.Recnum to iRecnum
                Clear SncTable
                Constraint_Set Self
                Constrain SncTable.Hide eq 0
                Constrained_Find First SncTable by Index.2
    
                While (Found)  
                    If (SncTable.Hide = False) Begin  
                        Clear SncSchemRow                   
                        Move iSncSchemID to SncSchemRow.SncSchemID
                        Move SncTable.ID to SncSchemRow.SncTableID
                        Find eq SncSchemRow by Index.2
                        If (Found and SncTable.ID = SncSchemRow.SncTableID) Begin
                            Move True to bSelected           
                            Move SncSchemRow.DeleteSource to bDeleteSource
                            Move SncSchemRow.DeleteTarget to bDeleteTarget
                        End                       
                        Else Begin
                            Move False to bSelected
                            Move False to bDeleteSource
                            Move False to bDeleteTarget
                        End
                        Move bSelected                  to asGridContent[iRow].bSelected
                        Move (Trim(SncTable.SortField)) to asGridContent[iRow].sName
                        Move (Trim(SncTable.Text))      to asGridContent[iRow].sDescription
                        Move bDeleteSource              to asGridContent[iRow].bDeleteSource
                        Move bDeleteTarget              to asGridContent[iRow].bDeleteTarget
                        Move (SncTable.ID)              to asGridContent[iRow].iSncTableID
                        Increment iRow
                    End
                    Constrained_Find Next
                Loop
        
                // Reset file buffer.
                Clear SncTable
                If iRecnum Begin
                    Move iRecnum to SncTable.Recnum
                    Find eq SncTable by Recnum
                End                          
                
                Function_Return asGridContent
            End_Function
    
            Procedure OnRowDoubleClick Integer iRow Integer iCol   
                Integer iID
                Forward Send OnRowDoubleClick iRow iCol
                If (pbCMBuilderMode(ghoApplication) = True) Begin
                    Get IDValue iRow to iID
                    If (iID <> 0) Begin
                        Send DisplaySncTableIDRecord iID    
                    End
                End
            End_Procedure    
            
        End_Object
        
        Object oSelectAll_bn is a cRDCButton
            Set Label to "All"
            Set Location to 38 346
            Set psToolTip to "Selecte all items in the grid"
            Set psImage to "SelectAll.ico"
            Set pbAutoEnable to True
            Set peAnchors to anTopRight
            
            Procedure OnClick
                Send SelectAll of oSncSchem_grd
            End_Procedure
        End_Object

        Object oDeselectAll_bn is a cRDCButton
            Set Label to "None"
            Set Location to 56 346
            Set psTooltip to "De-select all items in the grid"
            Set psImage to "SelectNone.ico"
            Set pbAutoEnable to True
            Set peAnchors to anTopRight
            
            Procedure OnClick
                Send SelectNone of oSncSchem_grd 
            End_Procedure
        
        End_Object
                    
        Object oInvertSelection_bn is a cRDCButton
            Set Label to "Invert"
            Set Location to 73 346
            Set Status_Help to "Invert the selection order"
            Set psImage to "SelectInvert.ico"
            Set peAnchors to anTopRight
            Set pbAutoEnable to True
    
            Procedure OnClick
                Send SelectInvert of oSncSchem_grd
            End_Procedure
        End_Object
        
        Object oNew_btn is a cRDCButton
            Set Location to 101 346
            Set Label to "New"
            Set Status_Help to "Clear selections and Collection name to create a new Collection Name"
            Set peAnchors to anTopRight
            Set psImage to "ActionClear.ico"
            Set pbAutoEnable to True
    
            Procedure OnClick
                Send SelectNone of oSncSchem_grd 
                Set Value of oSncSchem_cb to ""
                Send Clear of (Main_DD(Self))
                Set Changed_State to False
            End_Procedure
    
            Function IsEnabled Returns Boolean
                Boolean bSave bHasRecord bChangedCombo   
                Integer iItems
                Get Changed_State of oSncSchem_cb to bChangedCombo
                Get Should_Save   of (Main_DD(Self)) to bSave
                Get HasRecord     of (Main_DD(Self)) to bHasRecord
                Get CheckedItems  of oSncSchem_grd to iItems
                Function_Return (bChangedCombo = True or bSave = True or bHasRecord = True or iItems <> 0)
            End_Function
    
        End_Object
        
        Object oSave_bn is a cRDCButton
            Set Location to 118 346
            Set Label to "Save"
            Set Status_Help to "Save the entered Collection Name and it's grid selections"
            Set peAnchors to anTopRight
            Set psImage to "ActionSave.ico"
            Set pbAutoEnable to True
    
            Procedure OnClick
                Handle hoGrid hoSncSchem_cb hoDD
                String sSncTables sName
                Integer iRetval iSncTables iSncSchemID
    
                Move (oSncSchem_DD(Self)) to hoDD
                Move (oSncSchem_grd(Self)) to hoGrid
                Move (oSncSchem_cb(Self))  to hoSncSchem_cb
                Get SelectedItems of hoGrid to sSncTables
                Get Value of hoSncSchem_cb to sName
                Move (Trim(sName)) to sName
                If (Length(sName) > 0) Begin
                    Send Clear of hoDD
                    Move sName to SncSchem.Name
                    Send Find of hoDD Eq Index.1
                    If (not(Found)) Begin
                        Send Clear of hoDD
                    End
                End
                Set Field_Changed_Value of hoDD Field SncSchem.Name   to sName
                Set Field_Changed_Value of hoDD Field SncSchem.Tables to sSncTables
                Get Request_Validate    of hoDD to iRetval
                If (iRetval <> 0) Begin
                    Procedure_Return
                End
                Send Request_Save of hoDD
                Get Field_Current_Value of hoDD Field SncSchem.ID to iSncSchemID 
                Send Refind_Records of hoDD
                Send SaveRowSelections iSncSchemID
                Send Combo_Fill_List of hoSncSchem_cb
                Set Value of hoSncSchem_cb to sName
            End_Procedure  
            
            Procedure SaveRowSelections Integer iSncSchemID
                Handle hoGrid
                Handle hoDataSource
                tDataSourceRow[] TheData
                Integer iSize iCount iCheckboxCol iSncTableIDCol iDeleteSourceCol iDeleteTargetCol iSncTableID
                Boolean bChecked bDeleteSource bDeleteTarget
                
                Move (oSncSchem_grd(Self)) to hoGrid
                
                Get piColumnId of (piCheckboxCol(hoGrid)) to iCheckboxCol
                Get piColumnId of (phoIDCol(hoGrid))      to iSncTableIDCol
                Get piColumnid of oDeleteSource_col       to iDeleteSourceCol
                Get piColumnid of oDeleteTarget_col       to iDeleteTargetCol
                Get phoDataSource of hoGrid to hoDataSource
                Get DataSource of hoDataSource to TheData
                Move (SizeOfArray(TheData)) to iSize
                Decrement iSize
                
                For iCount from 0 to iSize
                    Move TheData[iCount].sValue[iCheckboxCol]     to bChecked
                    Move TheData[iCount].sValue[iSncTableIDCol]   to iSncTableID
                    Move TheData[iCount].sValue[iDeleteSourceCol] to bDeleteSource
                    Move TheData[iCount].sValue[iDeleteTargetCol] to bDeleteTarget
                    Clear SncSchemRow                                            
                    Move iSncSchemID to SncSchemRow.SncSchemID                  
                    Move iSncTableID to SncSchemRow.SncTableID
                    Find eq SncSchemRow by Index.2
                    If (Found = True and iSncTableID = SncSchemRow.SncTableID) Begin
                        Delete SncSchemRow
                    End
                    If (bChecked = True) Begin
                        Send SubSaveSaveSncSchemRow iSncTableID bDeleteSource bDeleteTarget
                    End
                Loop    
            End_Procedure                       
            
            Procedure SubSaveSaveSncSchemRow Integer iSncTableID Boolean bDeleteSource Boolean bDeleteTarget
                // First increment parent ID counter 
                Reread SncSchem
                    Increment SncSchem.NextSncSchemRowID
                    SaveRecord SncSchem
                    // Then create new SncSchemRow record.
                    Clear SncSchemRow                       
                    Move SncSchem.NextSncSchemRowID to SncSchemRow.ID
                    Move SncSchem.ID                to SncSchemRow.SncSchemID
                    Move iSncTableID                to SncSchemRow.SncTableID 
                    Move bDeleteSource              to SncSchemRow.DeleteSource
                    Move bDeleteTarget              to SncSchemRow.DeleteTarget
                    SaveRecord SncSchemRow
                Unlock
            End_Procedure
    
            Function IsEnabled Returns Boolean
                Boolean bSave
                Get Should_Save of (Main_DD(Self)) to bSave
                Function_Return (bSave = True)
            End_Function
    
        End_Object
        
        Object oDelete_bn is a cRDCButton
            Set Location to 135 346
            Set Label to "Delete"
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
                    Send Request_Delete   of hoDD
                    Send Combo_Fill_List  of ho
                    Send LoadData         of oSncSchem_grd
                End
            End_Procedure
    
            Function IsEnabled Returns Boolean
                Boolean bRecord
                Get HasRecord of (Main_DD(Self)) to bRecord
                Function_Return (bRecord = True)
            End_Function
    
        End_Object  
        
    End_Object

    // Do not allow to close panel:
    Procedure Request_Cancel
    End_Procedure

    Procedure CancelWizard // This is needed by the cdbComboFormat & cdbComboDriver classes.
    End_Procedure

    // This will disable all toolbar data related buttons for the program top row.
    Function Server Returns Handle
        Function_Return 0 
    End_Function
        
    Function DisplayDeleteWaring Returns Boolean
        String sText
        Integer iRetval
        Move "Are you sure you want to delete this collection name and its selections?" to sText
        Get YesNo_Box sText "Delete question" to iRetval
        Function_Return (iRetval <> MBR_YES)
    End_Function

    Set Verify_Delete_msg to get_DisplayDeleteWaring
    Set Verify_Save_msg   to msg_None

    Procedure Activating
        Handle hoGrid
        Boolean bSynchSetup bCMBuilderMode bMode
        
        Get pbCMBuilderMode of ghoApplication to bCMBuilderMode
        Get phoSncTableGrid to hoGrid                          
        Set pbSynchSetup of hoGrid to bCMBuilderMode
        
        If (bCMBuilderMode = True) Begin
            Set Visible_State of oStart_bn to False
            Set Skip_State    of oStart_bn to True
            Set Visible_State of oSetDefaultCollection_bn to True
            Set Skip_State    of oSetDefaultCollection_bn to False
            Set Visible_State of oRunMinimized_cb to False
            Set Skip_State    of oRunMinimized_cb to True
            Set Visible_State of oNew_btn to True
            Set Skip_State    of oNew_btn to False
            Set Visible_State of oSave_bn to True
            Set Skip_State    of oSave_bn to False
            Set Visible_State of oDelete_bn to True
            Set Skip_State    of oDelete_bn to False
            Set Verify_Delete_msg to get_DisplayDeleteWaring
            Set Entry_State of oSncSchem_cb to True
        End 
        Else Begin
            Set Visible_State of oStart_bn to True             
            Set Skip_State    of oStart_bn to False
            Set Visible_State of oSetDefaultCollection_bn to False
            Set Skip_State    of oSetDefaultCollection_bn to True
            Set Visible_State of oRunMinimized_cb to True
            Set Skip_State    of oRunMinimized_cb to False  
            Set Location      of oRunMinimized_cb to 24 278
            Set Visible_State of oNew_btn to False
            Set Skip_State    of oNew_btn to True
            Set Visible_State of oSave_bn to False
            Set Skip_State    of oSave_bn to True
            Set Visible_State of oDelete_bn to False
            Set Skip_State    of oDelete_bn to True
            Set Verify_Delete_msg to msg_None
            Set Entry_State of oSncSchem_cb to False
        End
    End_Procedure
            
    Procedure Activate Returns Integer
        String sNameDefault
        Move (Trim(SncSys.Default_Scheme)) to sNameDefault
        Set Value of oSncSchem_cb to sNameDefault
        Send LoadData of oSncSchem_grd
        Forward Send Activate
    End_Procedure
        
    Function RdsMain_Panel_Id Returns Integer
        Handle hoPanel
        Boolean bCMBuilderMode
        
        Get pbCMBuilderMode of ghoApplication to bCMBuilderMode
        If (bCMBuilderMode = True) Begin
            Move 0 to hoPanel
        End             
        Else Begin
            Move Self to hoPanel
        End
        Function_Return hoPanel
    End_Function

    Procedure DoStartEngine
        Send KeyAction of oStart_bn
    End_Procedure

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

    On_Key Key_Ctrl+Key_S Send DoSave
    On_Key Key_Alt+Key_A  Send KeyAction of oSelectAll_bn
    On_Key Key_Ctrl+Key_A Send KeyAction of oSelectAll_bn
    On_Key Key_Alt+Key_N  Send KeyAction of oDeselectAll_bn
    On_Key Key_Ctrl+Key_N Send KeyAction of oDeselectAll_bn
    On_Key Key_Alt+Key_I  Send KeyAction of oInvertSelection_bn
    On_Key Key_Ctrl+Key_I Send KeyAction of oInvertSelection_bn
End_Object
