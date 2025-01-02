Use cControlPanel.pkg
Use Dftable.pkg
Use cDbTextEdit.pkg
Use cRDCDbForm.pkg
Use cRDCDbGroup.pkg
Use cDbComboformDataFormat.pkg
Use cDbComboformServer.pkg
Use cRDCRadio.pkg
Use cRDCTextbox.pkg
Use cFileDSNButton.pkg
Use cODBCAdminButton.pkg
Use cDbComboFormDatabase.pkg
Use cDbCheckBoxNtAuth.pkg
Use cRDCDbCheckbox.pkg
Use cDbFormUser.pkg
Use cDbFormPassword.pkg
Use cDbFormSchema.pkg
Use cLoginButton.pkg
Use cDbFormPath.pkg
Use cPathButton.pkg
Use cDbComboformDataTable.pkg
Use cRDCHeaderDbGroup.pkg
Use cRDCForm.pkg
Use cDbComboformDriver.pkg
Use cDbFieldComboform.pkg
Use cParentFieldsTreeView.pkg
Use cChildFieldsTreeView.pkg
Use cDbIndexComboform.pkg
Use cRDsTreeView.pkg
Use cRDCComboForm.pkg
Use cRDCGroup.pkg
Use cViewDataButton.pkg
Use cSyncTableCheckBoxGrid.pkg
Use cZeroLogBn.pkg
Use cToolbar.pkg
Use cCJGrid.pkg
Use cCJGridColumn.pkg
Use cDbCJGrid.pkg
Use cCJGridColumnRowIndicator.pkg
Use cDbCJGridColumn.pkg
Use cDbSplitterContainer.pkg

Use Append.dg
Use ManageSQLConnections.dg

Use SncSys.dd
Use SncTable.dd
Use SncSchem.dd
Use SncLog.dd
Use SncTHea.dd
Use SncTRow.dd

Activate_View Activate_oRdcView For oRdcView
Object oRdcView is a dbView
    Set Size to 357 766
    Set Label to "Data Table Connection"
    Set Auto_Clear_DEO_State to False
    Set View_Latch_State to True
    Set Border_Style to Border_Thick
    Set Icon to "CMBuilder.ico"
    Set pbAutoActivate to True

    Set phoMainView of ghoApplication to Self
    
    Object oSncsys_DD is a Sncsys_DataDictionary
    End_Object

    Object oSncTable_DD is a SncTable_DataDictionary

        Procedure New_Current_Record Integer iOld Integer iNew
            Forward Send New_Current_Record iOld iNew
            If (Operation_Mode = Mode_Finding) Begin
                // This will be received by the cDbComboformDataFormat and cDbComboformServer classes.
                // and cDbComboformServer sends a message to cDbComboformDataTable to open
                // tables and also update other DEO's:
                Broadcast Recursive Send DoFindData of (Parent(Self))
            End
        End_Procedure

        Procedure Set Field_Changed_State Integer iField Boolean bState
            Handle hoDD
            Boolean bFromTableChanged bToTableChanged
            String sFromTo

            Forward Set Field_Changed_State to iField bState

            Move (oSncTHea_DD(Self)) to hoDD
            // If table has been changed for an existing record and SncTHea (and rows) exist,
            // warn user that the Value Transformation tables are not valid any longer:
            If (pbGetHasCurrRowId(Self) and pbGetHasCurrRowId(hoDD)) Begin
                Get Field_Changed_State Field SncTable.FromDataTable to bFromTableChanged
                Get Field_Changed_State Field SncTable.ToDataTable   to bToTableChanged
                If (bFromTableChanged or bToTableChanged) Begin
                    If (bFromTableChanged and not(bToTableChanged)) Begin
                        Move "Source"                 to sFromTo
                    End
                    Else If (not(bFromTableChanged) and bToTableChanged) Begin
                        Move "Destination"       to sFromTo
                    End
                    Else If (bFromTableChanged and bToTableChanged) Begin
                        Move "Source and Destination" to sFromTo
                    End
                    Send Info_Box ("WARNING! The Table Name has been changed for the" * sFromTo * "database(s) and Value Conversion table(s) exists for the old Table Name. You need to delete them on the 'Value Conversion' tab page.")
                End
            End
        End_Procedure

        Procedure Clear
            Integer iFile iOpen

            Forward Send Clear
            Move giFromFile to iFile                        // From File
            Get_Attribute DF_FILE_OPENED of iFile  to iOpen
            If iOpen Begin
                Close iFile
            End
            Move giToFile to iFile                          // To File
            Get_Attribute DF_FILE_OPENED of iFile  to iOpen
            If iOpen Begin
                Close iFile
            End
            Move 100 to iFile                               // From DDF File
            Get_Attribute DF_FILE_OPENED of iFile to iOpen
            If iOpen Begin
                Close iFile
            End
            Move 110 to iFile                               // to DDF File
            Get_Attribute DF_FILE_OPENED of iFile to iOpen
            If iOpen Begin
                Close iFile
            End

            Broadcast Recursive Send DoCheckClear of (Parent(Self))
            // Must be after Recursive Send DoCheckClear...
            Set Changed_State to False
        End_Procedure

        Procedure Clear_All
            Forward Send Clear_All
            Send Clear
        End_Procedure

    End_Object

    Object oSncSchem_DD is a Sncschem_DataDictionary
    End_Object

    Object oSncLog_DD is a Snclog_DataDictionary
    End_Object

    Object oSncTHea_DD is a Sncthea_DataDictionary
        Set Ordering to 1
        Set Allow_Foreign_New_Save_State to True

        Set DDO_Server to oSnctable_DD
        Set Constrain_File to Snctable.File_Number

        Procedure Request_Save
            Integer iID
            Get File_Field_Current_Value File_Field SncTable.ID to iID
            If (not(pbGetHasCurrRowId(Self))) Begin
                Set Field_Changed_Value Field SncTHea.SncTableID to iID
            End
            Forward Send Request_Save
        End_Procedure

        Procedure DoCreateNewRecord  // Initialize new SncTHea record.
            Integer iID
            Get File_Field_Current_Value File_Field SncTable.ID to iID
            Send Clear
            Set Field_Changed_Value Field SncTHea.SncTableID to iID
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

    Object oSnctRow_DD is a Snctrow_DataDictionary
        Set DDO_Server to oSncthea_DD
        Set Constrain_File to Sncthea.File_Number   
    End_Object

    Set Main_DD to oSnctable_DD
    Set Server  to oSnctable_DD
    Set phoMain_DDO of ghoApplication to (oSncTable_DD(Self))

    Object oImage_lst is a cImageList
        Set piMaxImages to 11

        Procedure OnCreate
            Integer iIndex
            // Data Table Connection tab-pages:
            Get AddTransparentImage "DatabaseTables.bmp"    clWhite to iIndex
            Get AddTransparentImage "Columns.bmp"           clWhite to iIndex
            Get AddTransparentImage "TableIndex.bmp"        clWhite to iIndex
            Get AddTransparentImage "Filter.bmp"            clWhite to iIndex
            Get AddTransparentImage "DatabaseDefaults.bmp"  clWhite to iIndex
            Get AddTransparentImage "ValueConversion.bmp"   clWhite to iIndex
            Get AddTransparentImage "MarkRows.bmp"          clWhite to iIndex
            Get AddTransparentImage "Notes.bmp"             clWhite to iIndex
        End_Procedure

    End_Object

    Object oDbSplitterContainer1 is a cDbSplitterContainer
        Set piSplitterLocation to 345

        Object oDbSplitterContainerChild1 is a cDbSplitterContainerChild

            Object oDataTableConnectionTop_grp is a cRDCHeaderDbGroup
                Set Size to 74 326
                Set Location to 8 13
                Set Label to "Connection Header Info"
                Set psImage to "Connections.ico"
                Set peAnchors to anNone
        
                Object oSnctable_Sortfield is a cRDCDbForm
                    Entry_Item Snctable.SortField
                    Set Label to "Name (Sort Field)"
                    Set Size to 13 100
                    Set piMinSize to 13 82
                    Set Location to 24 188
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set peAnchors to anTopLeftRight
                End_Object
        
                Object oSnctable_Text is a cRDCDbForm
                    Entry_Item SncTable.Text
                    Set Label to "Description"
                    Set Size to 13 209
                    Set piMinSize to 13 191
                    Set Location to 40 79
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set peAnchors to anTopLeftRight
            
                    Procedure OnExitObject
                        Boolean bShould_Save
                        Get Should_Save of (Main_DD(Self)) to bShould_Save
                        If (bShould_Save = True) Begin
                            Send Request_Save_No_Clear
                        End
                    End_Procedure
            
                End_Object
        
                Object oSnctable_Checkintegrity is a cRDCDbCheckBox
                    Entry_Item SncTable.CheckIntegrity
                    Set Auto_Size_State to False
                    Set Label to "Check for database changes"
                    Set Size to 10 105
                    Set Location to 58 79
                End_Object
        
                Object oSnctable_Hide is a cRDCDbCheckbox
                    Entry_Item Snctable.Hide
                    Set Label to "Hide record"
                    Set Size to 10 50
                    Set Location to 58 188
                End_Object
        
                Object oSnctable_Recid is a cRDCDbForm
                    Entry_Item SncTable.ID
                    Set Label to "Id (Auto generated)"
                    Set Size to 13 44
                    Set Location to 24 79
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set Prompt_Button_Mode to pb_PromptOn
                End_Object
        
            End_Object

            Object oFromDatabase_grp is a cRDCHeaderDbGroup
                Set Size to 121 326
                Set Location to 93 12
                Set peAnchors to anNone
                Set psLabel to "Source Database"
                Set psNote to "Select From database table"
                Set psImage to "DatabaseSource.ico"
        
                Object oSnctable_Fromdbtype is a cDbComboformDataFormat
                    Entry_Item SncTable.FromDbType
                    Set Label to "Database Type"
                    Set Size to 14 150
                    Set Location to 31 78
                    Set pbFrom to True
                End_Object
        
        //                Object oSnctable_Fromdriver is a cDbComboformDriver
        //                    Entry_Item SncTable.FromDriver
        //                    Set Label to "Driver ID"
        //                    Set Size to 14 150
        //                    Set Location to 43 78
        //                    Set pbFrom to True
        //                End_Object
        
                Object oEditFromDatabase_btn is a cRDCButton
                    Set Size to 14 58
                    Set Location to 31 234
                    Set Label to "Edit Settings"
                    Set psImage to "Edit.ico"
                    Set pbAutoEnable to True
        
                    Procedure OnClick
                        Integer iID iDbType
                        Boolean bNew bChanged bFrom
                        Handle hoDD hoFromPath_btn
                        tSQLConnection SQLConnection
                        tDataSourceRow[] TheData
        
                        Move (Main_DD(Self)) to hoDD  
                        Get Field_Current_Value of hoDD Field SncTable.FromDbType to iDbType
                        If (iDbType = EN_DbTypeDataFlex or iDbType = EN_DbTypePervasive) Begin
                            Get Create (RefClass(cPathButton)) to hoFromPath_btn
                            Set pbFrom of hoFromPath_btn to True
                            Send DoOpenFileDialog of hoFromPath_btn
                            Send Destroy of hoFromPath_btn
                            Procedure_Return // We're done.
                        End
        
                        Get Field_Current_Value of hoDD Field SncTable.ID to iID
                        If (iID <> 0) Begin
                            Get FillSQLConnectionStruct True hoDD to SQLConnection
                        End
                        Move (iID = 0) to bNew
        
                        Send Activate_SQLMaintainConnections_dg of (Client_Id(ghoCommandBars)) bNew iID (&SQLConnection) (&bChanged) False TheData
        
                        If (bChanged = True) Begin
                            Get UpdateSncTableRecordFromSQLConnectionStruct True hoDD SQLConnection to bChanged 
                            Send Request_Save
                            Send Find of hoDD EQ 1     
                        End
                    End_Procedure
        
                    Function IsEnabled Returns Boolean
                        Handle hoDD      
                        String sDriverID
                        Boolean bHasRecord
                        Get Main_DD to hoDD
                        Get HasRecord of hoDD to bHasRecord
                        Get Field_Current_Value of hoDD Field SncTable.FromDriver to sDriverID
                        Function_Return (bHasRecord =  True and sDriverID <> "")
                    End_Function
        
                End_Object
        
                Object oSnctable_Fromserver is a cDbComboformServer
                    Entry_Item Snctable.FromServer
                    Set Label to "Server"
                    Set Size to 14 150
                    Set Location to 48 78
                    Set pbFrom to True
                End_Object
        
                Object oSnctable_Fromdatabase is a cDbComboFormDatabase
                    Entry_Item Snctable.FromDatabase
                    Set Label to "Database Name"
                    Set Size to 14 150
                    Set Location to 65 78
                    Set pbFrom to True
                End_Object
        
                Object oSnctable_FrFileOEMToANSI is a cRDCDbCheckBox
                    Entry_Item Snctable.FrFileOEMToANSI
                    Set Label to "Data is in ANSI format"
                    Set Size to 10 84
                    Set Location to 68 235
        
                    Procedure DoEnableDisable Integer iValue
                        If (not(pbGetHasCurrRowId(Main_DD(Self))) and iValue <> 1 and iValue <> 6) Begin
                            Set Checked_State to True
                        End
                        Set Enabled_State to  (iValue <> 1 and iValue <> 6)
                    End_Procedure
        
                End_Object
        
                Object oSnctable_FromDataTable is a cDbComboformDataTable
                    Entry_Item Snctable.FromDataTable
                    Set Label to "Table Name"
                    Set Size to 14 150
                    Set Location to 82 78
                    Set Combo_Sort_State to True
                    Set pbFrom to True
                End_Object
        
                Object oViewFromData_bn is a cViewDataButton
                    Set Label to "View Data"
                    Set Size to 14 58
                    Set Location to 82 234
                    Set Status_Help to "View data for the Source database table."
                    Set Enabled_State to False
                    Set psImage to "ViewData.ico"
                    Set pbFrom to True
        
                    Procedure OnClick
                        Send DoViewData True -1
                    End_Procedure
                End_Object
        
                Object oSnctable_FromFilepath is a cDbFormPath
                    Entry_Item SncTable.FromFilepath
                    Set Label to "File Path"
                    Set Size to 14 143
                    Set Location to 99 78
                    Set peAnchors to anTopLeftRight
                    Set pbFrom to True 
                    Procedure Refresh Integer iMode
                        Forward Send Refresh iMode
                        Set Value of oNoOfFromRecords_fm to ""
                    End_Procedure
                End_Object
        
                Object oNoOfFromRecords_fm is a cRDCForm
                    Set Size to 14 52
                    Set Location to 99 227
                    Set Status_Help to "Current number of physical records for the selected database table. For other formats then DataFlex and Pervasive you need to press the Refresh button to the right."
                    Set peAnchors to anTopRight
                    Set Label_Justification_Mode to JMode_Top
                    Set Form_DataType to Mask_Numeric_Window
                    Set Form_Mask Item 0 to "#,###########"
                    Set Enabled_State to False
                    Set Label_Row_Offset to 1
                    Set Label_Col_Offset to 0
                End_Object
        
                Object oFromRecordRefresh_bn is a cRDCButton
                    Set Size to 14 17
                    Set Location to 99 283
                    Set Status_Help to "Refresh number of records. (Alt+R)"
                    Set psToolTip to (Status_Help(Self))
                    Set peAnchors to anTopRight
        //                    Set Label to "Refresh"
                    Set psImage to "Refresh.ico"
                    Set pbAutoEnable to True
        
                    Procedure OnClick
                        Integer iFile iRecords
                        Boolean bOpen
                        
                        Move 0 to iRecords
                        Move False to bOpen
                        Move giFromFile to iFile
                        Get_Attribute DF_FILE_OPENED of iFile to bOpen
                        If (bOpen = True) Begin
                            Get_Attribute DF_FILE_RECORDS_USED of iFile to iRecords
                        End
                        Set Value of oNoOfFromRecords_fm to iRecords
                    End_Procedure    
                    
                    Function IsEnabled Returns Boolean
                        Integer iFile
                        Boolean bOpen
                        
                        Move False to bOpen
                        Move giFromFile to iFile
                        Get_Attribute DF_FILE_OPENED of iFile to bOpen
                        Function_Return (iFile <> 0 and bOpen = True)
                    End_Function
        
                End_Object
        
                Procedure OnEnterArea Handle hoFrom
                    Handle hoDD                      
                    Boolean bShould_Save bHasRecord
        
                    Forward Send OnEnterArea hoFrom
                    Get Main_DD to hoDD            
                    Get Should_Save of hoDD to bShould_Save
                    Get HasRecord   of hoDD to bHasRecord
                    If (bShould_Save = True and bHasRecord = False) Begin
                        Send Request_Save
                    End
                End_Procedure
            
                On_Key Key_Alt+Key_R Send KeyAction of oFromRecordRefresh_bn
            End_Object

            Object oToDatabase_grp is a cRDCHeaderDbGroup
                Set Size to 122 326
                Set Location to 224 12
                Set psLabel to "Target Database"
                Set psNote to "Select To database table"
                Set psImage to "DatabaseTarget.ico"
                Set peAnchors to anTopBottom
        
                Object oSnctable_ToDbType is a cDbComboformDataFormat
                    Entry_Item Snctable.ToDbType
                    Set Label to "Database Type"
                    Set Size to 14 150
                    Set Location to 31 78
                    Set pbFrom to False
                End_Object
        
        //                Object oSnctable_ToDdriver is a cDbComboformDriver
        //                    Entry_Item SncTable.ToDriver
        //                    Set Label to "Driver ID"
        //                    Set Size to 14 150
        //                    Set Location to 43 78
        //                    Set pbFrom to False
        //                End_Object
        
                Object oEditToDatabase_btn is a cRDCButton
                    Set Size to 14 58
                    Set Location to 31 234
                    Set Label to "Edit Settings"
                    Set psImage to "Edit.ico"
                    Set pbAutoEnable to True
        
                    Procedure OnClick
                        Integer iID iDbType
                        Boolean bNew bChanged
                        Handle hoDD hoToPath_btn
                        tSQLConnection SQLConnection
                        tDataSourceRow[] TheData
        
                        Move (Main_DD(Self)) to hoDD
                        Get Field_Current_Value of hoDD Field SncTable.ToDbType to iDbType
                        If (iDbType = EN_DbTypeDataFlex or iDbType = EN_DbTypePervasive) Begin
                            Get Create (RefClass(cPathButton)) to hoToPath_btn
                            Set pbFrom of hoToPath_btn to False
                            Send DoOpenFileDialog of hoToPath_btn
                            Send Destroy of hoToPath_btn
                            Procedure_Return // We're done.
                        End
        
                        Get Field_Current_Value of hoDD Field SncTable.ID to iID
                        If (iID <> 0) Begin
                            Get FillSQLConnectionStruct False hoDD to SQLConnection
                        End
                        Move (iID = 0) to bNew
        
                        Send Activate_SQLMaintainConnections_dg of (Client_Id(ghoCommandBars)) bNew iID (&SQLConnection) (&bChanged) False TheData
        
                        If (bChanged = True) Begin
                            Get UpdateSncTableRecordFromSQLConnectionStruct False hoDD SQLConnection to bChanged
                            Send Request_Save
                            Send Find of hoDD EQ 1     
                        End
                    End_Procedure
        
                    Function IsEnabled Returns Boolean
                        Handle hoDD
                        Boolean bHasRecord       
                        String sDriverID                              
                        Get Main_DD to hoDD
                        Get HasRecord of hoDD to bHasRecord
                        Get Field_Current_Value of hoDD Field SncTable.ToDriver to sDriverID
                        Function_Return (bHasRecord =  True and sDriverID <> "")
                    End_Function
        
                End_Object
        
                Object oSnctable_ToServer is a cDbComboformServer
                    Entry_Item Snctable.Toserver
                    Set Label to "Server"
                    Set Size to 14 150
                    Set Location to 48 78
                    Set pbFrom to False
                End_Object
        
                Object oSnctable_ToDatabase is a cDbComboFormDatabase
                    Entry_Item Snctable.ToDatabase
                    Set Label to "Database Name"
                    Set Size to 14 150
                    Set Location to 65 78
                    Set pbFrom to False
                End_Object
        
                Object oSnctable_ToFileOEMToANSI is a cRDCDbCheckBox
                    Entry_Item Snctable.ToFileOEMToANSI
                    Set Label to "Save in ANSI format"
                    Set Size to 10 79
                    Set Location to 68 235
        
                    Procedure DoEnableDisable Integer iValue
                        If (not(pbGetHasCurrRowId(Main_DD(Self))) and iValue <> EN_DbTypeDataFlex and iValue <> EN_DbTypePervasive) Begin
                            Set Checked_State to True
                        End
                    End_Procedure
        
                End_Object
        
                Object oSnctable_ToDataTable is a cDbComboFormDataTable
                    Entry_Item Snctable.ToDataTable
                    Set Label to "Table Name"
                    Set Size to 14 150
                    Set Location to 82 78
                    Set pbFrom to False
                End_Object
        
                Object oViewToData_bn is a cViewDataButton
                    Set Size to 14 58
                    Set Label to "View Data"
                    Set Location to 82 234
                    Set Status_Help to "View data for the Target database table."
                    Set Enabled_State to False
                    Set pbFrom to False
                    Set psImage to "ViewData.ico"
        
                    Procedure OnClick
                        Send DoViewData True -1
                    End_Procedure
                End_Object
        
                Object oSnctable_ToFilePath is a cDbFormPath
                    Entry_Item Snctable.ToFilePath
                    Set Label to "File Path"
                    Set Size to 14 143
                    Set Location to 99 78
                    Set peAnchors to anTopLeftRight
                    Set pbFrom to False
                    Procedure Refresh Integer iMode
                        Forward Send Refresh iMode
                        Set Value of oNoOfToRecords_fm to ""
                    End_Procedure
                End_Object
        
                Object oNoOfToRecords_fm is a cRDCForm
                    Set Size to 14 51
                    Set Location to 99 228
                    Set Status_Help to "Current number of physical records for the selected database table. For other formats then DataFlex and Pervasive you need to press the Refresh button to the right."
                    Set peAnchors to anTopRight
                    Set Label_Col_Offset to 0
                    Set Label_Justification_Mode to JMode_Top
                    Set Form_DataType to Mask_Numeric_Window
                    Set Form_Mask     Item 0 to "#,###########"
                    Set Enabled_State to False
                    Set Label_Row_Offset to 1
                End_Object
        
                Object oToRecordRefresh_bn is a cRDCButton
                    Set Size to 14 17
                    Set Location to 99 284
                    Set Status_Help to "Refresh the number of records. (Alt+R)"
                    Set psToolTip to (Status_Help(Self))
                    Set peAnchors to anTopRight
                    Set psImage to "Refresh.ico"
                    Set pbAutoEnable to True
        
                    Procedure OnClick
                        Integer iFile iRecords
                        Boolean bOpen
        
                        Move 0 to iRecords
                        Move False to bOpen
                        Move giToFile to iFile
                        Get_Attribute DF_FILE_OPENED of iFile to bOpen
                        If (bOpen = True) Begin
                            Get_Attribute DF_FILE_RECORDS_USED of iFile to iRecords
                        End
                        Set Value of oNoOfToRecords_fm to iRecords
                    End_Procedure
        
                    Function IsEnabled Returns Boolean
                        Integer iFile 
                        Boolean bOpen
                        
                        Move False to bOpen
                        Move giToFile to iFile
                        Get_Attribute DF_FILE_OPENED of iFile to bOpen
                        Function_Return (iFile <> 0 and bOpen = True)
                    End_Function
        
                End_Object
        
                On_Key Key_Alt+Key_R Send KeyAction of oToRecordRefresh_bn
            End_Object
        End_Object


        Object oDbSplitterContainerChild2 is a cDbSplitterContainerChild

            Object oSncTable_SynchType is a cRDCDbComboForm
                Entry_Item SncTable.SynchType
                Set Label to "Set Field Selection Type"
                Set Size to 14 150
                Set Location to 51 3
                Set Label_Col_Offset to 0
                Set Label_Row_Offset to 1
                Set Label_Justification_Mode to JMode_Top
                Set Entry_State Item 0 to False
                Set Code_Display_Mode to CB_Code_Display_Both
                Set peAnchors to anNone
            End_Object

            Object oDbTables_td is a dbTabDialog
                Set Size to 276 418
                Set Location to 74 3
                Set TabWidth_Mode to twRightJustify
                Set Rotate_Mode to RM_Rotate
                Set phoImageList to oImage_lst
                Set Auto_Clear_DEO_state to False
                Set peAnchors to anAll
                
        //        Object oDatabaseTables_tp is a dbTabPage
        //            Set Label to "Database Tables"
        //            Set Tab_ToolTip_Value to "Source and target database table details"
        //            Set piImageIndex to 0
        //
        //            Procedure OnEnterArea Handle hoFrom
        //                Handle hoDD                      
        //                Boolean bShould_Save bHasRecord
        //    
        //                Forward Send OnEnterArea hoFrom
        //                Get Main_DD to hoDD            
        //                Get Should_Save of hoDD to bShould_Save
        //                Get HasRecord   of hoDD to bHasRecord
        //                If (bShould_Save = True and bHasRecord = False) Begin
        //                    Send Request_Save
        //                End
        //            End_Procedure
        //    
        //        End_Object
        
                Object oFields_tp is a dbTabPage
                    Set Label to "Fields/Columns"
                    Set Tab_ToolTip_Value to "Field selection method and fields to include for the two tables"
                    Set piImageIndex to 1
        
                    Object oMatchingFields_grp is a cRDCHeaderDbGroup
                        Set Size to 253 395
                        Set Location to 7 7
                        Set Label to "1 - Matching Field Names"  
                        Set psNote to "Field names that are the same in Source and Target table"
                        Set psImage to "MatchingFields.ico"
                        Set peAnchors to anAll  
        
                        Object oSourceFieldsInfo_tb is a cRDCTextbox
                            Set Size to 10 44
                            Set Location to 47 24
                            Set Label to "Source Fields:"
                        End_Object
        
                        Object oTargetFieldsInfo_tb is a cRDCTextbox
                            Set Size to 10 42
                            Set Location to 47 237
                            Set Label to "Target Fields:"
                            Set peAnchors to anTopRight
                        End_Object
        
                        Object oFieldNames_grd is a cCJGrid
                            Set Size to 183 375
                            Set Location to 62 10
                            Set pbRestoreLayout to True
                            Set psLayoutSection to (Name(Self) + "_grid")
                            Set psNoItemsText to "No data found..."
                            Set pbHeaderReorders to True
                            Set pbHeaderPrompts to False
                            Set pbHeaderTogglesDirection to True
                            Set pbSelectionEnable to True
                            Set pbReadOnly to True
                            Set pbShowRowFocus to True
                            Set pbHotTracking to True
                            Set piLayoutBuild to 1
                            Set pbUseAlternateRowBackgroundColor to True
                            Set piSelectedRowBackColor to clGreenGreyLight
                            Set piHighlightBackColor   to clGreenGreyLight
                            Set peAnchors to anAll
                            Set pbShowFooter to True
        
                            Object oSourceFieldNumber_col is a cCJGridColumn
                                Set piWidth to 62
                                Set psCaption to "No"
                            End_Object
        
                            Object oSourceFieldName_col is a cCJGridColumn
                                Set piWidth to 119
                                Set psCaption to "Field Name" 
                                Set psFooterText to "Matching Fields:"
        
                                Procedure OnSetDisplayMetrics Handle hoMetrics Integer iRow String  ByRef sValue
                                    Handle hoCompareCol 
                                    String sCompareValue
                                    Move (oTargetFieldName_col(Self)) to hoCompareCol
                                    Get RowValue of hoCompareCol iRow to sCompareValue
                                    If (sCompareValue <> sValue) Begin        
                                        Set ComBackColor of hoMetrics to clRed
                                    End
                                    Forward Send OnSetDisplayMetrics hoMetrics iRow (&sValue)
                                End_Procedure
        
                            End_Object
        
                            Object oSourceFieldType_col is a cCJGridColumn
                                Set piWidth to 65
                                Set psCaption to "Type"
                                Set psFooterText to "of Total:"
        
                                Procedure OnSetDisplayMetrics Handle hoMetrics Integer iRow String  ByRef sValue
                                    Handle hoCompareCol 
                                    String sCompareValue
                                    Move (oTargetFieldType_col(Self)) to hoCompareCol
                                    Get RowValue of hoCompareCol iRow to sCompareValue
                                    If (sCompareValue <> sValue) Begin        
                                        Set ComBackColor of hoMetrics to clRed
                                    End
                                    Forward Send OnSetDisplayMetrics hoMetrics iRow (&sValue)
                                End_Procedure
        
                            End_Object
        
                            Object oSourceFieldLength_col is a cCJGridColumn
                                Set piWidth to 63
                                Set psCaption to "Length"
        
                                Procedure OnSetDisplayMetrics Handle hoMetrics Integer iRow String  ByRef sValue
                                    Handle hoCompareCol 
                                    String sCompareValue
                                    Move (oTargetFieldLength_col(Self)) to hoCompareCol
                                    Get RowValue of hoCompareCol iRow to sCompareValue
                                    If (sCompareValue <> sValue) Begin        
                                        Set ComBackColor of hoMetrics to clRed
                                    End
                                    Forward Send OnSetDisplayMetrics hoMetrics iRow (&sValue)
                                End_Procedure
        
                            End_Object
        
                            Object oSeparator_col is a cCJGridColumn
                                Set piWidth to 10
                                Set psCaption to ""   
                                Set Color to clGreenGreyLight
                            End_Object
        
                            Object oTargetFieldNumber_col is a cCJGridColumn
                                Set piWidth to 59
                                Set psCaption to "No"
                            End_Object
        
                            Object oTargetFieldName_col is a cCJGridColumn
                                Set piWidth to 120
                                Set psCaption to "Name"
        
                                Procedure OnSetDisplayMetrics Handle hoMetrics Integer iRow String  ByRef sValue
                                    Handle hoCompareCol 
                                    String sCompareValue
                                    Move (oSourceFieldName_col(Self)) to hoCompareCol
                                    Get RowValue of hoCompareCol iRow to sCompareValue
                                    If (sCompareValue <> sValue) Begin        
                                        Set ComBackColor of hoMetrics to clRed
                                    End
                                    Forward Send OnSetDisplayMetrics hoMetrics iRow (&sValue)
                                End_Procedure
        
                            End_Object
        
                            Object oTargetFieldType_col is a cCJGridColumn
                                Set piWidth to 53
                                Set psCaption to "Type"
        
                                Procedure OnSetDisplayMetrics Handle hoMetrics Integer iRow String  ByRef sValue
                                    Handle hoCompareCol
                                    String sCompareValue
                                    Move (oSourceFieldType_col(Self)) to hoCompareCol
                                    Get RowValue of hoCompareCol iRow to sCompareValue
                                    If (sCompareValue <> sValue) Begin        
                                        Set ComBackColor of hoMetrics to clRed
                                    End
                                    Forward Send OnSetDisplayMetrics hoMetrics iRow (&sValue)
                                End_Procedure
        
                            End_Object
        
                            Object oTargetFieldLength_col is a cCJGridColumn
                                Set piWidth to 74
                                Set psCaption to "Length"
        
                                Procedure OnSetDisplayMetrics Handle hoMetrics Integer iRow String  ByRef sValue
                                    Handle hoCompareCol
                                    String sCompareValue
                                    Move (oSourceFieldLength_col(Self)) to hoCompareCol
                                    Get RowValue of hoCompareCol iRow to sCompareValue
                                    If (sCompareValue <> sValue) Begin        
                                        Set ComBackColor of hoMetrics to clRed
                                    End
                                    Forward Send OnSetDisplayMetrics hoMetrics iRow (&sValue)
                                End_Procedure
        
                            End_Object
        
                            // Returns number of items.
                            Function ItemCount Returns Integer
                                Integer iItems
                                Handle hoDataSource
                                tDataSourceRow[] TheData
                        
                                Get phoDataSource to hoDataSource
                                Get DataSource of hoDataSource to TheData
                                Move (SizeOfArray(TheData)) to iItems
                        
                                Function_Return iItems
                            End_Function
        
                            Procedure DoDeleteItem
                                Integer iItem
                                Get ItemCount to iItem
                                If (not(iItem)) Begin
                                    Procedure_Return
                                End
                                Send Request_Delete 
                                Send MoveToFirstRow
                            End_Procedure  
                            
                            Function Value Integer iItem Integer iCol Returns String
                                Handle hoDataSource                   
                                tDataSourceRow[] TheData       
                                String sValue
                                
                                If (iItem < 0) Begin
                                    Function_Return ""
                                End                   
                                Move "" to sValue
                                Get phoDataSource to hoDataSource
                                Get DataSource of hoDataSource to TheData
                                If (SizeOfArray(TheData) <> 0) Begin
                                    Move TheData[iItem].sValue[iCol] to sValue
                                End
                        
                                Function_Return sValue
                            End_Function
                            
                            Procedure Delete_Data  
                                If (not(IsComObjectCreated(Self))) Begin
                                    Procedure_Return
                                End
                                Send ResetGrid  
                                Set psFooterText of oSourceFieldName_col to ("Matching Fields:")
                                Set psFooterText of oSourceFieldType_col to ("of Total:")
                            End_Procedure   
                            
                            Procedure Add_Item Integer iRow String sValue Integer iCol
                                Handle hoDataSource
                                tDataSourceRow[] TheData
                                Integer iSize 
                        
                                If (not(IsComObjectCreated(Self))) Begin
                                    Procedure_Return
                                End
                                Get phoDataSource to hoDataSource
                                Get DataSource of hoDataSource to TheData
                                Move sValue to TheData[iRow].sValue[iCol]
                                Send ReInitializeData TheData False
                            End_Procedure
        
                            Procedure Add_Focus Handle hoParent Returns Integer
                                Forward Send Add_Focus hoParent
                                Send DoFillGrid
                            End_Procedure
        
                            Procedure DoFillGrid
                                Handle ho hoDD
                                Integer iCount iFromFile iToFile iFromFields iToField iFrField iStart iCol iRow
                                Integer iFromLength iToLength iFromType iToType iFromPrec iToPrec iMatch
                                Boolean bIsOpen
                                String sFieldName sType sFromDriver sToDriver
        
                                If (not(IsComObjectCreated(Self))) Begin
                                    Procedure_Return
                                End
                                Send Delete_Data  
                                Move (Main_DD(Self)) to hoDD
                                
                                Move giFromFile to iFromFile
                                Get_Attribute DF_FILE_OPENED of iFromFile to bIsOpen
                                If (bIsOpen = False) Begin
                                    Procedure_Return 
                                End
                                Move giToFile to iToFile
                                Get_Attribute DF_FILE_OPENED of iToFile to bIsOpen
                                If (bIsOpen = False) Begin
                                    Procedure_Return 
                                End
        
                                Send Ignore_Error of Error_Info_Object DFERR_CANT_FIND_FIELD    // "Cannot find field". Used to not trigger error while trying to find a matching field name in ToFile.
                                Send Ignore_Error of Error_Info_Object DFERR_FIELD_NUMBER_RANGE // "Field number out of range"
        
                                Get_Attribute DF_FILE_NUMBER_FIELDS of iFromFile to iFromFields
                                Get_Attribute DF_FILE_DRIVER        of iFromFile to sFromDriver
                                Get_Attribute DF_FILE_DRIVER        of iToFile   to sToDriver
                                If (sFromDriver = DATAFLEX_ID) Begin
                                    Move 0 to iStart // Then start at Recnum.
                                End
                                Else Begin
                                    Move 1 to iStart
                                End
                                
                                Move 0 to iRow
                                For iCount from iStart to iFromFields
                                    Get_Attribute DF_FIELD_NUMBER of iFromFile iCount   to iFrField
                                    Get_Attribute DF_FIELD_TYPE   of iFromFile iFrField to iFromType
        
                                    If (iFromType <> DF_OVERLAP) Begin
                                        Get FieldType iFromType to sType
                                        Get_Attribute DF_FIELD_NAME of iFromFile iFrField to sFieldname
                                        Move False to Err
                                        Get FieldMap iToFile sFieldName to iToField
                                        Get UpperFirstChar sFieldName   to sFieldName
        
                                        If (iToField <> - 1)  Begin
                                            // Source Table:
                                            Send Add_Item iRow iFrField   (piColumnId(oSourceFieldNumber_col))    // iFromFile field number
                                            Send Add_Item iRow sFieldName (piColumnId(oSourceFieldName_col))      // iFromFile field name
                                            Send Add_Item iRow sType      (piColumnId(oSourceFieldType_col))      // iFromFile field type
                                            Get_Attribute DF_FIELD_LENGTH    of iFromFile iFrField to iFromLength
                                            Get_Attribute DF_FIELD_PRECISION of iFromFile iFrField to iFromPrec
                                            If (iFromType = DF_BCD) Begin
                                                Move (iFromLength - iFromPrec) to iFromLength
                                            End
                                            Else Begin
                                                Move 0 to iFromPrec
                                            End
        
                                            Send Add_Item iRow (String(iFromLength) + "," + String(iFromPrec)) (piColumnId(oSourceFieldLength_col)) // iFromFile field length
        
                                            // Target Table:
                                            Send Add_Item iRow iToField   (piColumnId(oTargetFieldNumber_col))        // iToFile field number
                                            Get_Attribute DF_FIELD_NAME      of iToFile iToField to sFieldname
                                            Get UpperFirstChar sFieldName                        to sFieldName   // Function in SyncFuncs.pkg
                                            Send Add_Item iRow sFieldName (piColumnId(oTargetFieldName_col))          // iToFile field name
                                            Get_Attribute DF_FIELD_TYPE      of iToFile iToField to iToType
                                            Get FieldType iToType                                to sType        // Function in SyncFuncs.pkg
                                            Send Add_Item iRow sType      (piColumnId(oTargetFieldType_col))          // iToFile field type
                                            Get_Attribute DF_FIELD_LENGTH    of iToFile iToField to iToLength
                                            Get_Attribute DF_FIELD_PRECISION of iToFile iToField to iToPrec
                                            If (iToType = DF_BCD) Begin
                                                Move (iToLength - iToPrec)                       to iToLength
                                            End
                                            Else Begin
                                                Move 0                                           to iToPrec
                                            End
        
                                            Send Add_Item iRow (String(iToLength) + "," + String(iToPrec)) (piColumnId(oTargetFieldLength_col))  // iToFile field length
                                            Increment iRow
                                        End
                                    End
                                Loop
        
                                Get ItemCount to iMatch
                                If (sFromDriver = DATAFLEX_ID) Begin
                                    Add 1 to iFromFields
                                End
                                Send Trap_Error of Error_Info_Object DFERR_CANT_FIND_FIELD
                                Send Trap_Error of Error_Info_Object DFERR_FIELD_NUMBER_RANGE
                                Set psFooterText of oSourceFieldName_col to ("No of Matching Fields:" * String(iMatch))
                                Set psFooterText of oSourceFieldType_col to ("of Total:" * String(iFromFields))  
                                Send MoveToFirstRow
                            End_Procedure
        
                            Function FieldMap Integer iFile String sFieldName Returns String
                                Integer iFields iField iStart
                                String sTableFieldName sDriver
        
                                Move (Uppercase(sFieldName))           to sFieldName
                                Get_Attribute DF_FILE_DRIVER of iFile  to sDriver
                                If (sDriver = DATAFLEX_ID) Begin
                                    Move 0 to iStart // Then start at Recnum.
                                End
                                Else Begin
                                    Move 1 to iStart
                                End
        
                                Get_Attribute DF_FILE_NUMBER_FIELDS of iFile to iFields
                                For iField from iStart to iFields
                                    Get_Attribute DF_FIELD_NAME of iFile iField to sTableFieldName
                                    If (Uppercase(sTableFieldName) = sFieldName) Begin
                                        Function_Return iField
                                    End
                                Loop
                                Move False to Err
                                Function_Return -1
                            End_Function
        
                            // As the cCJGrid class has a message like this that "saves" the current row,
                            // we need to relay it to the parent for the toolbar keys to work.
                            Procedure Request_Save
                                Delegate Send Request_Save
                            End_Procedure
        
                        End_Object
                        
                    End_Object
        
                    Object oFieldRange_grp is a cRDCHeaderDbGroup
                        Set Size to 253 395
                        Set Location to 7 7
                        Set Label to "2 - Range of Field Numbers"
                        Set psImage to "RangeOfFields.ico"
                        Set peAnchors to anAll
        
                        Object oFromStartField_cf is a cDbFieldComboform
                            Entry_Item Snctable.FromStartField
                            Set Label to "Source Start Field"
                            Set Size to 13 103
                            Set Location to 38 10
                            Set pbFrom to True
                            Set Label_Col_Offset to 0
                            Set Label_Justification_Mode to JMode_Top
                            Set Label_Row_Offset to 1
                        End_Object
        
                        Object oFromStopField_cf is a cDbFieldComboform
                            Entry_Item Snctable.FromStopField
                            Set Label to "Source Stop Field"
                            Set Size to 13 103
                            Set Location to 38 119
                            Set pbFrom to True
                            Set Label_Col_Offset to 0
                            Set Label_Justification_Mode to JMode_Top
                            Set Label_Row_Offset to 1
                        End_Object
        
                        Object oToStartField_cf is a cDbFieldComboForm
                            Entry_Item Snctable.ToStartField
                            Set Label to "Target Start Field"
                            Set Size to 13 103
                            Set Location to 38 228
                            Set pbFrom to False
                            Set Label_Col_Offset to 0
                            Set Label_Justification_Mode to JMode_Top
                            Set Label_Row_Offset to 1
                        End_Object
        
                    End_Object
        
                    Object oSelectedFields_grp is a cRDCHeaderDbGroup
                        Set Size to 253 395
                        Set Location to 7 7
                        Set Label to "3 - Selected Field Numbers"
                        Set psImage to "SelectAll.ico"
                        Set peAnchors to anAll
        
                        // Hidden object!
                        Object oFromParentFields_tv is a cParentFieldsTreeView
                            Set pbFrom to True
                            Set peAnchors to anTopLeftRight
                            Set Size to 54 138
                            Set Location to 276 169
                            Set Status_Help to "Double-click or press space-bar to select a Source field or the Ins key to insert a Source field"
                            Set Visible_State to False
        
                            Procedure DoUpdateData Integer iFromFile Integer iToFile Boolean bFrom
                                Set piFile to iFromFile
                            End_Procedure
                        End_Object
        
                        // Hidden object!
                        Object oToParentFields_tv is a cParentFieldsTreeView
                            Set pbFrom to False
                            Set Size to 54 147
                            Set Location to 254 324
                            Set Status_Help to "Double-click or press space-bar to select a Target field or the Ins key to insert a Target field"
                            Set Visible_State to False
        
                            Procedure DoUpdateData Integer iFromFile Integer iToFile Boolean bFrom
                                Set piFile to iToFile
                            End_Procedure
                        End_Object
        
                        Object oFromChildFields_tb is a cRDCTextbox
                            Set Label to "Selected Source Fields:"
                            Set Location to 47 24
                            Set Size to 10 73
                        End_Object
        
                        Object oFromChildFields_tv is a cChildFieldsTreeView
                            Set Size to 157 156
                            Set Location to 62 10
                            Set phoParent to (oFromParentFields_tv(Self))
                            Set psFieldName to "SelFromFields"
                            Set Server to (Main_DD(Self))
                            Set pbFrom to True
                            Set peAnchors to anTopBottom
        
                            Procedure DoUpdateData Integer iFromFile Integer iToFile Boolean bFrom
                                Set piFile to iFromFile
                                Send OnCreateTree
                            End_Procedure
        
                            Procedure UpdateDDO
                                Send DoUpdateDDBuffer (Main_DD(Self)) "SelFromFields" "SelFieldCount"  // Class procedure.
                            End_Procedure
        
                            Procedure DoAddItem String sLabel Integer iData
                                Integer iItems
                                Forward Send DoAddItem sLabel iData
                                Get ItemCount to iItems
                                Set Value of oSelFromCount_fm to iItems
                                Set Enabled_State of oAppend_bn to True
                                Send UpdateDDO
                            End_Procedure
        
                            Procedure DoCreateTree
                                Integer iItems
                                Forward Send DoCreateTree
                                Get ItemCount to iItems
                                Set Value of oSelFromCount_fm   to iItems
                            End_Procedure
        
                            Procedure DoFindMatchingItem Integer iItem
                                Handle hNew
                                Get ItemHandle iItem to hNew
                                Set CurrentTreeItem  to hNew
                            End_Procedure
        
                            Procedure OnItemChanged Handle hItem Handle hItemOld
                                Integer iItem
                                Get ItemNumber hItem to iItem
                                Send DoFindMatchingItem of oToChildFields_tv iItem
                            End_Procedure
        
                        End_Object
        
                        Object oToChildFields_tb is a cRDCTextbox
                            Set Label to "Selected Target Fields:"
                            Set Location to 47 184
                            Set Size to 10 70
                        End_Object
        
                        Object oToChildFields_tv is a cChildFieldsTreeView
                            Set Size to 157 156
                            Set Location to 62 171
                            Set phoParent to (oToParentFields_tv(Self))
                            Set psFieldName to "SelToFields"
                            Set Status_Help to "Double-click or press the Del key to de-select a Target field."
                            Set Server to (Main_DD(Self))
                            Set pbFrom to False
                            Set peAnchors to anTopBottom
        
                            Procedure DoUpdateData Integer iFromFile Integer iToFile Boolean bFrom
                                Set piFile to iToFile
                                Send OnCreateTree
                            End_Procedure
        
                            Procedure UpdateDDO
                                Send DoUpdateDDBuffer (Main_DD(Self)) "SelToFields"   ""
                            End_Procedure
        
                            Procedure DoAddItem String sLabel Integer iData
                                Integer iItems
                                Forward Send DoAddItem sLabel iData
                                Send UpdateDDO
                            End_Procedure
        
                            Procedure DoInsertItem String sLabel Integer iData
                            End_Procedure
        
                            Procedure DoCutItem
                            End_Procedure
        
        //                    Procedure DoCreateTree
        //                        Forward Send DoCreateTree
        //                    End_Procedure
        
                            Procedure DoFindMatchingItem Integer iItem
                                Handle hNew
                                Get ItemHandle iItem to hNew
                                Set CurrentTreeItem  to hNew
                            End_Procedure
        
                            Procedure OnItemChanged Handle hItem Handle hItemOld
                                Integer iItem
                                Get ItemNumber hItem to iItem
                                Send DoFindMatchingItem of oFromChildFields_tv iItem
                            End_Procedure  
                            
                        End_Object
        
                        Object oSelFromCount_fm is a cRDCForm
                            Set Label to "Selected Fields"
                            Set Size to 13 21
                            Set Location to 92 334
                            Set Status_Help to "Number of selected fields/columns for the source table"
                            Set Enabled_State to False
                            Set Label_Col_Offset to 0
                            Set Form_Datatype to 0
                            Set Label_Row_Offset to 1
                            Set Label_Justification_Mode to JMode_Top
        
                            Procedure Set Enabled_State Boolean bState
                                Forward Set Enabled_State to False
                            End_Procedure
                        End_Object
        
                        #Include SelectSourceAndTargetFields.dg
        
                        Object oSelectFields_btn is a cRDCButton
                            Set Location to 62 333
                            Set Label to "Edit"
                            Set psImage to "Edit.ico"
        
                            Procedure OnClick
                                Handle hoDDO
                                Boolean bOK
        
                                Set pbEnabled of oFieldIdleHandler to False
                                Get Main_DD to hoDDO
                                Get Edit_oSelectSourceAndTargetFields hoDDO to bOK
                                If (bOK = True) Begin
                                    Send DoCreateTree of oFromChildFields_tv
                                    Send DoCreateTree of oToChildFields_tv
                                End
                                Else Begin
                                    // This will reset the DDO, if changes where made in
                                    // the popup and then the Cancel button was pressed.
                                    Send Refind_Records of hoDDO
                                End
                                Set pbEnabled of oFieldIdleHandler to True
                            End_Procedure
        
                        End_Object
        
                        Procedure DoEnableDisable Integer iType
                            If (iType = 3) Begin
                                Set Visible_State to True
                                Set Location to 38 7
                            End
                            Else Begin
                                Set Visible_State to False
                            End
                        End_Procedure
        
        //                Procedure Set Enabled_State Boolean bState
        //                    Forward Set Enabled_State to bState
        //                    Send Enable_Window of (Label_Object(oSelFromCount_fm(Self))) bState
        //                    Set Enabled_State  of oAppend_bn to bState
        //                End_Procedure
        
                    End_Object
        
                    Property String psFromDataTable
                    Property String psToDataTable    
                    Property Integer piSynchType 1 // 1,2 or 3.  
                    Property Boolean pbRefreshDone False
                    
                    Procedure Refresh Integer eMode
                        String sFromDataTable sToDataTable
                        Integer iSynchType
                        Handle hoDD
                        
                        Forward Send Refresh eMode
                        Move (Main_DD(Self)) to hoDD
                        Get Field_Current_Value of hoDD Field SncTable.FromDataTable to sFromDataTable 
                        Get Field_Current_Value of hoDD Field SncTable.ToDataTable   to sToDataTable 
                        Get Field_Current_Value of hoDD Field SncTable.SynchType     to iSynchType
                        Set psFromDataTable to sFromDataTable
                        Set psToDataTable   to sToDataTable
                        Set piSynchType     to iSynchType   
                        Set pbRefreshDone   to True // Tells the DoTimerUpdate message that data might need to be refreshed.
                        Send DoTimerUpdate
                    End_Procedure
        
                    Object oFieldIdleHandler is a cIdleHandler
                        Set pbEnabled to False
                        Procedure OnIdle
                            Delegate Send DoTimerUpdate
                        End_Procedure
                    End_Object     
                    
                    // Enable the idle handler timer when the tab-page is activated
                    Procedure OnEnterArea Handle hoFrom
                        Set pbEnabled of oFieldIdleHandler to True
                    End_Procedure
                
                    // Disable the idle handler when the tab-page is deactivated
                    Procedure OnExitArea Handle hoFrom
                        Set pbEnabled of oFieldIdleHandler to False
                    End_Procedure
                    
                    Procedure DoTimerUpdate  
                        String sFromDataTable sToDataTable sFromDataTableLocal sToDataTableLocal
                        Integer iSynchType iSynchTypeLocal iFromFile iToFile
                        Handle hoDD ho                   
                        Boolean bShouldRefresh bRefreshDone bFromFileOpen bToFileOpen
        
                        Move False to bFromFileOpen
                        Move False to bToFileOpen
                        Move (Main_DD(Self)) to hoDD
                        Get Field_Current_Value of hoDD Field SncTable.FromDataTable to sFromDataTable
                        Get Field_Current_Value of hoDD Field SncTable.ToDataTable   to sToDataTable 
                        Get Field_Current_Value of hoDD Field SncTable.SynchType     to iSynchType
                        Get psFromDataTable to sFromDataTableLocal
                        Get psToDataTable   to sToDataTableLocal
                        Get piSynchType     to iSynchTypeLocal  
                        Get pbRefreshDone   to bRefreshDone
                        
                        If (bRefreshDone = False) Begin
                            Move (sFromDataTable <> sFromDataTableLocal or sToDataTable <> sToDataTableLocal or iSynchType <> iSynchTypeLocal) to bShouldRefresh
                        End 
                        Else Begin
                            Move True to bShouldRefresh 
                        End
                                        
                        If (bShouldRefresh = True) Begin     
                            Move giFromFile to iFromFile
                            Get_Attribute DF_FILE_OPENED of iFromFile to bFromFileOpen
                            If (bFromFileOpen = False) Begin
                                Get RDSOpenAsFile hoDD True False to bFromFileOpen
                            End 
        
                            Move giToFile to iToFile
                            Get_Attribute DF_FILE_OPENED of iToFile to bToFileOpen
                            If (bToFileOpen = False) Begin
                                Get RDSOpenAsFile hoDD False False to bToFileOpen 
                            End
        
                            Set piSynchType     to iSynchType
                            Set Visible_State of oMatchingFields_grp to (iSynchType = 1)
                            Set Visible_State of oFieldRange_grp     to (iSynchType = 2)
                            Set Visible_State of oSelectedFields_grp to (iSynchType = 3)
                            // If table is not open, it means that the refresh message has got us here and
                            // the tables have not yet been opened by the two cDbComboformDataTable objects.
                            // If so, we wait until they have been.
                            If (bFromFileOpen = False or bToFileOpen = False) Begin
                                Set Enabled_State of oSncTable_SynchType to False
                                Send Delete_Data of oFieldNames_grd
                                Procedure_Return
                            End
                            
                            Set Enabled_State of oSncTable_SynchType to True
                            Set pbRefreshDone   to False
                            Set psFromDataTable to sFromDataTable
                            Set psToDataTable   to sToDataTable
                            
                            If (iSynchType = 1) Begin   
                                Move (oFieldNames_grd(Self)) to ho
                                Send DoFillGrid of ho iFromFile iToFile
                            End   
                            Else If (iSynchType = 2) Begin
                                Move (oFieldRange_grp(Self)) to ho
                                Set Location of ho to 38 7 
                                Broadcast Recursive Send DoUpdateData of ho iFromFile iToFile True
                                Send DoUpdateData of (oToStartField_cf(ho)) iFromFile iToFile False 
                            End   
                            Else If (iSynchType = 3) Begin
                                Move (oSelectedFields_grp(Self)) to ho   
                                Broadcast Recursive Send DoUpdateData of ho iFromFile iToFile True
                            End
                        End
                    End_Procedure
        
                End_Object
        
                Object oIndex_tp is a dbTabPage
                    Set Label to "Index/Sorting"
                    Set Tab_ToolTip_Value to "Index to use to finding an equal Destination table record"
                    Set piImageIndex to 2
        
                    Object oFromIndex_grp is a dbGroup
                        Set Size to 146 534
                        Set Location to 293 14
                        Set Label to "Source Database Table Index (Only available when 'Auto delete old records' is checked. See below)"
                        Set Visible_State to False
        
                        Object oSnctable_FromdataTable_Index is a cRDCDbForm
                            Entry_Item Snctable.Fromdatatable
                            Set Label to "Table Name"
                            Set Size to 13 150
                            Set Location to 10 78
                            Set Enabled_State to False
        
                            Procedure Set Enabled_State Boolean bState
                                Forward Set Enabled_State to False
                            End_Procedure
                        End_Object
        
                        Object oSnctable_Fromindex is a cDbIndexComboform
                            Entry_Item Snctable.Fromindex
                            Set Label to "Select Unique Index"
                            Set Size to 12 150
                            Set Location to 25 78
                            Set pbFrom to True
        
                            Procedure OnChange
                                Forward Send OnChange
                                Send DoCreateTree of oChildIndexSegments
                                Send OnCreateTree of oFromIndexFields_tv
                            End_Procedure
                        End_Object
        
                        Object oViewFromData_bn is a cViewDataButton
                            Set Label to "&View Data"
                            Set Size to 13 60
                            Set Location to 40 79
                            Set Status_Help to "View data for the Source database table."
                            Set pbFrom to True
        
                            Procedure OnClick
                                Send DoViewData True -1
                            End_Procedure
                        End_Object
        
                        Object oSnctable_Fridxselcount is a cRDCDbForm
                            Entry_Item Snctable.Fridxselcount
                            Set Label to "Select Count"
                            Set Size to 13 23
                            Set Location to 130 205
                            Set Label_Col_Offset to 2
                            Set Label_Justification_Mode to jMode_Right
        
                            Procedure Set Enabled_State Boolean bState
                                Forward Set Enabled_State to False
                            End_Procedure
                        End_Object
        
                        Object oParentToFields_tb is a cRDCTextbox
                            Set Label to "Available Target Field Numbers:"
                            Set Location to 63 312
                            Set Size to 10 101
                        End_Object
        
                        Object oParentIndexSegments is a cParentFieldsTreeView
                            Set pbFrom to False
                            Set peAnchors to anTopLeftRight
                            Set Size to 54 134
                            Set Location to 70 246
                            Set Status_Help to "Double-click or press space-bar or the Ins key to select a Target field"
                            Set phoChild to (oChildIndexSegments(Self))
        
                            Procedure DoUpdateData Integer iFromFile Integer iToFile Boolean bFrom
                                Set piFile to iToFile
                            End_Procedure
                        End_Object
        
                        Object oInfo_tb is a cRDCTextbox
                            Set Label to "Select the fields that should be used to populate the Source table's index, to do a find equal search. Only used when 'Auto delete old records' is checked."
                            Set Auto_Size_State to False
                            Set Location to 60 391
                            Set Size to 54 140
                            Set Border_Style to Border_StaticEdge
                            Set Justification_Mode to jMode_Left
                        End_Object
        
                        Object oChildToFields_tb is a cRDCTextbox
                            Set Label to "Selected Target Field Numbers:"
                            Set Location to 79 246
                            Set Size to 10 101
                        End_Object
        
                        Object oChildIndexSegments is a cChildFieldsTreeView
                            Set Size to 54 134
                            Set Location to 89 246
                            Set phoChild  of oParentIndexSegments to (Self)
                            Set phoParent to (oParentIndexSegments(Self))
                            Set psFieldName to "ToFieldsFromIdx"
                            Set Status_Help to "Double-click or press the Del key to de-select a Target field."
                            Set pbFrom to False
                            Set Server to (Main_DD(Self))
        
                            Property Handle phoCount (oSnctable_Fridxselcount(Self))
        
                            Procedure DoUpdateData Integer iFromFile Integer iToFile Boolean bFrom
                                Set piFile to iFromFile
                                Send OnCreateTree
                            End_Procedure
        
                            Procedure UpdateDDO
                                Send DoUpdateDDBuffer (Main_DD(Self)) "ToFieldsFromIdx" "FrIdxSelCount" // Class procedure.
                            End_Procedure
        
                            Procedure DoAddItem String sLabel Integer iData
                                Forward Send DoAddItem sLabel iData
                                Send UpdateDDO
                            End_Procedure
        
                            Procedure DoInsertItem String sLabel Integer iData
                                Forward Send DoInsertItem sLabel iData
                                Send UpdateDDO
                            End_Procedure
        
                            Procedure DoCutItem
                                Forward Send DoCutItem
                                Send UpdateDDO
                            End_Procedure
                        End_Object
        
                        Object oFromIndexFields_tb is a cRDCTextbox
                            Set Label to "Source Index Segments:"
                            Set Location to 79 391
                            Set Size to 10 79
                        End_Object
        
                        Object oFromIndexFields_tv is a TreeView
                            Set peAnchors to anBottomRight
                            Set Size to 54 140
                            Set Location to 89 388
                            Set piBackColor to clLtGray
                            Set TreeRootLinesState to False
                            Set TreeLinesState to False
                            Set TreeButtonsState to False
                            Set Status_Help to "The segments (or fields) that the selected Source index consist of."
        
                            Procedure DoDeleteAllData
                                Handle hRootItem
                                Get RootItem to hRootItem
                                While (hRootItem <> 0)
                                    Send DoDeleteItem hRootItem
                                    Get RootItem to hRootItem
                                Loop
                            End_Procedure
        
                            Procedure OnCreateTree
                                Handle hItem
                                Integer iFile iIndex iFields iField iCount 
                                Boolean bOpen
                                String sFieldName sSpace
                                
                                Move giFromFile to iFile
                                Get Field_Current_Value of (Main_DD(Self)) Field SncTable.FromIndex to iIndex
                                Send DoDeleteAllData
                                Get_Attribute DF_FILE_OPENED of iFile to bOpen
                                If (bOpen = False) Begin
                                    Procedure_Return
                                End
                                Get_Attribute DF_INDEX_NUMBER_SEGMENTS of iFile iIndex to iFields
                                For iCount from 1 to iFields
                                    Move "" to sSpace
                                    If (iFields >= 10 and iCount < 10) Begin
                                        Move " " to sSpace
                                    End
                                    Get_Attribute DF_INDEX_SEGMENT_FIELD of iFile iIndex iCount to iField
                                    Get FieldSpecs iFile iField to sFieldName 
                                    Get AddTreeItem (sSpace + String(iCount) * "-" * sFieldName) 0 iCount 0 0 to hItem
                                Loop
                            End_Procedure                                     
                            
                        End_Object
        
                        Procedure DoUpdateData Integer iFromFile Integer iToFile Boolean bFrom
                            Handle ho
                            String sTable
                            Integer iOpen bState
                            Get Field_Current_Value of (Main_DD(Self)) Field SncTable.FromDataTable  to sTable
                            Get Field_Current_Value of (Main_DD(Self)) Field SncTable.Delete_Records to bState
                            If iFromFile Begin
                                Get_Attribute DF_FILE_OPENED of iFromFile to iOpen
                            End
                            Set Enabled_State to (iOpen and Length(sTable) > 0 and bState)
                        End_Procedure
        
                    End_Object
        
                    Object oToIndex_grp is a cRDCHeaderDbGroup
                        Set Size to 253 395
                        Set Location to 7 7
                        Set Label to "Target Database Table Index"
                        Set psNote to "Selected Target index fields that are needed to make an equal find from the Source Table"
                        Set psImage to "TableIndex.ico"
                        Set peAnchors to anAll
        
                        // ToDo: I don't think this is necessary; it only confuses...
                        Object oHiddenText_tb is a cRDCTextbox
                            Set Label to "Hidden Parent treeview object!"
                            Set Location to 264 172
                            Set Size to 10 98
                            Set Visible_State to False
                        End_Object
        
                        Object oParentFromFields_tv is a cParentFieldsTreeView
                            Set pbFrom to True
                            Set peAnchors to anTopBottom
                            Set Size to 95 150
                            Set Location to 271 83
                            Set Status_Help to "Double-click or press space-bar or the Ins key to select a Source field"
                            Set Visible_State to False
                            Set phoChild to (oChildSelectedToIndexFields_tv(Self))  
                            
                            Procedure DoUpdateData Integer iFromFile Integer iToFile Boolean bFrom
                                Set piFile to iFromFile
                            End_Procedure
                        
                        End_Object
        
                        Object oChildFromFields_tb is a cRDCTextbox
                            Set Auto_Size_State to False
                            Set Label to "Source Index Fields:"
                            Set Location to 225 22
                            Set Size to 10 124
                            Set peAnchors to anBottomLeft
                        End_Object
        
                        Object oChildSelectedToIndexFields_tv is a cChildFieldsTreeView
                            Set peAnchors to anTopBottom
                            Set Size to 157 156
                            Set Location to 62 10
                            Set phoParent to (oParentFromFields_tv(Self))
                            Set psFieldName to "FromFieldsToIdx"
                            Set Status_Help to "Double-click or press the Del key to de-select a Source field."
                            Set pbFrom to True
                            Set Server to (Main_DD(Self))
        
                            Property Handle phoCount (oSnctable_Toidxselcount(Self))
        
                            Procedure Set Enabled_State Boolean bState
                                Forward Set Enabled_State to False
                            End_Procedure   
                            
                            Procedure DoUpdateData Integer iFromFile Integer iToFile Boolean bFrom
                                Set piFile to iFromFile  
                                Send OnCreateTree to oToIndexFields_tv
                                Send OnCreateTree
                            End_Procedure
        
                            Procedure UpdateDDO
                            End_Procedure
        
                            Procedure DoCutItem
                            End_Procedure
        
                            Procedure DoFindMatchingItem Integer iItem
                                Handle hNew
                                Get ItemHandle iItem to hNew
                                Set CurrentTreeItem  to hNew
                            End_Procedure
        
                            Procedure OnItemChanged Handle hItem Handle hItemOld
                                Integer iItem
                                Get ItemNumber hItem to iItem
                                Send DoFindMatchingItem of oToIndexFields_tv iItem
                            End_Procedure
        
                        End_Object
        
                        Object oToIndexFields_tv is a TreeView
                            Set Size to 157 156
                            Set Location to 62 173
                            Set piBackColor to clLtGray
                            Set Status_Help to "The segments (or fields) that the selected Target index consist of."
                            Set TreeEditLabelsState to False
                            Set TreeSortedState     to False
                            Set pbFullRowSelect     to True
                            Set TreeButtonsState    to True
                            Set TreeLinesState      to True
                            Set TreeRetainSelState  to True
                            Set TreeRootLinesState  to True
                            Set peAnchors to anTopBottom
        
                            Procedure DoDeleteAllData
                                Handle hRootItem
                                Get RootItem to hRootItem
                                While (hRootItem <> 0)
                                    Send DoDeleteItem hRootItem
                                    Get RootItem to hRootItem
                                Loop
                            End_Procedure
        
                            Procedure OnCreateTree
                                Handle hItem
                                Integer iFile iIndex iFields iField iCount iOpen
                                String sFieldName sSpace
                                Move giToFile to iFile
                                
                                Get Field_Current_Value of (Main_DD(Self)) Field SncTable.ToIndex to iIndex
                                Send DoDeleteAllData
                                Move giToFile to iFile
                                Get_Attribute DF_FILE_OPENED of iFile to iOpen
                                If (not(iOpen)) Begin
                                    Procedure_Return
                                End
                                Get_Attribute DF_INDEX_NUMBER_SEGMENTS of iFile iIndex to iFields
                                For iCount from 1 to iFields
                                    Move "" to sSpace
                                    If (iFields >= 10 and iCount < 10) Begin
                                        Move " " to sSpace
                                    End
                                    Get_Attribute DF_INDEX_SEGMENT_FIELD of iFile iIndex iCount to iField
                                    Get FieldSpecs iFile iField                                 to sFieldName
                                    Get AddTreeItem (sSpace + String(iCount) * "-" * sFieldName) 0 iCount 0 0 to hItem
                                Loop
                            End_Procedure
        
                            Function ItemNumber Handle hItem Returns Integer
                                Integer iItems iCount iData iDataNew
                                Handle hNext
                        
                                Get ItemCount to iItems
                                Decrement iItems
                                Get ItemData hItem to iData
                                Get RootItem to hNext
                                For iCount from 0 to iItems
                                    Get ItemData hNext to iDataNew
                                    If (iData = iDataNew) Break
                                    Get NextSiblingItem hNext to hNext
                                Loop
                                Function_Return iCount
                            End_Function
        
                            Function ItemHandle Integer iItem Returns Handle
                                Integer iCount
                                Handle hItem
                        
                                Get RootItem to hItem
                                For iCount from 0 to (iItem -1)
                                    Get NextSiblingItem hItem to hItem
                                Loop
                                Function_Return hItem
                            End_Function
        
                            Procedure DoFindMatchingItem Integer iItem
                                Handle hNew
                                Get ItemHandle iItem to hNew
                                Set CurrentTreeItem  to hNew
                            End_Procedure
        
                            Procedure OnItemChanged Handle hItem Handle hItemOld
                                Integer iItem
                                Get ItemNumber hItem to iItem
                                Send DoFindMatchingItem of oChildSelectedToIndexFields_tv iItem
                            End_Procedure
        
                        End_Object
        
                        Object oSnctable_Toidxselcount is a cRDCDbForm
                            Entry_Item Snctable.Toidxselcount
                            Set Label to "Index Fields:"
                            Set Size to 13 23
                            Set Location to 89 336
                            Set Label_Col_Offset to 0
                            Set Label_Justification_Mode to JMode_Top
                            Set Label_Row_Offset to 1
        
                            Procedure Set Enabled_State Boolean bState
                                Forward Set Enabled_State to False
                            End_Procedure
                        End_Object
        
                        Object oToIndexFields_tb is a cRDCTextbox
                            Set Auto_Size_State to False
                            Set Label to "Target Index Fields:"
                            Set Location to 47 186
                            Set Size to 10 91
                        End_Object
        
                        #Include SelectIndexAndSegments.dg
        
                        Object oSelectFields_btn is a cRDCButton
                            Set Location to 62 335
                            Set Label to "Edit"
                            Set psImage to "Edit.ico"
        
                            Procedure OnClick
                                Handle hoDDO
                                Boolean bOK
        
                                Set pbEnabled of oIndexIdleHandler to False
                                Get Main_DD to hoDDO
                                Get Edit_oSelectIndexAndSegments hoDDO to bOK
                                If (bOK = True) Begin
                                    Send DoCreateTree of oChildSelectedToIndexFields_tv
                                    Send OnCreateTree of oToIndexFields_tv
                                End
                                Else Begin
                                    // This will reset the DDO, if changes where made in
                                    // the popup and then the Cancel button was pressed.
                                    Send Refind_Records of hoDDO
                                End
                                Set pbEnabled of oIndexIdleHandler to True
                            End_Procedure
        
                            Function IsEnabled Returns Boolean
                                Boolean bFromOpen bToOpen                           
                                Get_Attribute DF_FILE_OPENED of giFromFile to bFromOpen
                                Get_Attribute DF_FILE_OPENED of giToFile   to bToOpen
                                Function_Return (bFromOpen = True and bToOpen = True)    
                            End_Function
                            
                        End_Object
        
                        Object oSnctable_Toindex is a cDbIndexComboform
                            Entry_Item Snctable.Toindex
                            Set Label to "Selected Target Index"
                            Set Size to 14 156
                            Set Location to 38 10
                            Set Label_Col_Offset to 0
                            Set Label_Row_Offset to 1
                            Set Label_Justification_Mode to JMode_Top
                            Set pbFrom to False 
                            Set Enabled_State to False
            
                            Procedure OnChange
                                Forward Send OnChange
                                Send DoCreateTree of oChildSelectedToIndexFields_tv
                            End_Procedure
                        End_Object
        
                    End_Object
        
                    Property String psFromDataTable
                    Property String psToDataTable    
                    Property Boolean pbRefreshDone False
                    
                    Procedure Refresh Integer eMode
                        String sFromDataTable sToDataTable
                        Integer iSynchType
                        Handle hoDD
                        
                        Forward Send Refresh eMode
                        Move (Main_DD(Self)) to hoDD
                        Get Field_Current_Value of hoDD Field SncTable.FromDataTable to sFromDataTable 
                        Get Field_Current_Value of hoDD Field SncTable.ToDataTable   to sToDataTable 
                        Set psFromDataTable to sFromDataTable
                        Set psToDataTable   to sToDataTable
                        Set pbRefreshDone   to True // Tells the DoTimerUpdate message that data might need to be refreshed.
                        Broadcast Recursive Send DoUpdateData of oToIndex_grp giFromFile giToFile False 
                        Send DoTimerUpdate
                    End_Procedure
        
                    Object oIndexIdleHandler is a cIdleHandler
                        Set pbEnabled to False
                        Procedure OnIdle
                            Delegate Send DoTimerUpdate
                        End_Procedure
                    End_Object     
                    
                    // Enable the idle handler timer when the tab-page is activated
                    Procedure OnEnterArea Handle hoFrom
                        Set pbEnabled of oIndexIdleHandler to True
                    End_Procedure
                
                    // Disable the idle handler when the tab-page is deactivated
                    Procedure OnExitArea Handle hoFrom
                        Set pbEnabled of oIndexIdleHandler to False
                    End_Procedure
                    
                    Procedure DoTimerUpdate  
                        String sFromDataTable sToDataTable sFromDataTableLocal sToDataTableLocal
                        Integer iFromFile iToFile
                        Handle hoDD ho                   
                        Boolean bShouldRefresh bRefreshDone bFromFileOpen bToFileOpen
        
                        Move False to bFromFileOpen
                        Move False to bToFileOpen
                        Move (Main_DD(Self)) to hoDD
                        Get Field_Current_Value of hoDD Field SncTable.FromDataTable to sFromDataTable
                        Get Field_Current_Value of hoDD Field SncTable.ToDataTable   to sToDataTable 
                        Get psFromDataTable to sFromDataTableLocal
                        Get psToDataTable   to sToDataTableLocal
                        Get pbRefreshDone   to bRefreshDone
                        
                        If (bRefreshDone = False) Begin
                            Move (sFromDataTable <> sFromDataTableLocal or sToDataTable <> sToDataTableLocal) to bShouldRefresh
                        End 
                        Else Begin
                            Move True to bShouldRefresh 
                        End
                                        
                        If (bShouldRefresh = True) Begin     
                            Move giFromFile to iFromFile
                            Get_Attribute DF_FILE_OPENED of iFromFile to bFromFileOpen
                            If (bFromFileOpen = False) Begin
                                Get RDSOpenAsFile hoDD True False to bFromFileOpen
                            End 
                            Move giToFile to iToFile
                            Get_Attribute DF_FILE_OPENED of iToFile   to bToFileOpen
                            If (bToFileOpen = False) Begin
                                Get RDSOpenAsFile hoDD False False to bToFileOpen 
                            End
                            // If table is not open, it means that the refresh message has got us here and
                            // the tables have not yet been opened by the two cDbComboformDataTable objects.
                            // If so, we wait until they have been.
                            If (bFromFileOpen = False or bToFileOpen = False) Begin
                                Procedure_Return
                            End
                            
                            Set pbRefreshDone   to False
                            Set psFromDataTable to sFromDataTable
                            Set psToDataTable   to sToDataTable
                            
                           Send DoUpdateData of oSnctable_Toindex iFromFile iToFile False
                           Broadcast Recursive Send DoUpdateData of oToIndex_grp iFromFile iToFile False 
                        End
                    End_Procedure
        
                End_Object
        
                Object oFilters_tp is a dbTabPage
                    Set Label to "Filters"
                    Set Tab_ToolTip_Value to "Filters or selections for the source table"
                    Set piImageIndex to 3
        
                    Object oConstraints_grp is a cRDCHeaderDbGroup
                        Set Size to 253 395
                        Set Location to 7 7
                        Set peAnchors to anAll
                        Set Label to "Source table Filters"
                        Set psNote to "Use it to select records from the source table"
                        Set psImage to "Filter.ico"
        
                        Object oFields_cf is a cDbFieldComboform
                            Set Label to "Field Name"
                            Set Size to 14 103
                            Set Location to 38 10
                            Set Status_Help to "Fields/columns for the selected Source data table"
                            Set pbFrom to True
                            Set Label_Justification_Mode to JMode_Top
                            Set Label_Row_Offset to 1
                            Set Label_Col_Offset to 0
        
                            Procedure OnChange
                                Handle hoList
                                String sType sField
                                Integer iLength iPrec iField iFile iType
                                Boolean bOpen
                                
                                Move -1 to iType
                                Get Value Item 0    to sField
                                Get FileFieldNumber to iField     // Class function.
                                Move (Trim(sField)) to sField
                                If (sField contains CS_None or sField = "") Begin
                                    Set Value   of oValue_fm to ""
                                    Set Value   of oType_fm to ""
                                    Set Value   of oLength_fm to ""
                                    Set Enabled_State of oSelect_bn to False
                                    Procedure_Return
                                End
        
                                Move giFromFile to iFile
                                Get_Attribute DF_FILE_OPENED of iFile to bOpen
                                If (bOpen = False) Begin
                                    Procedure_Return
                                End
                                
                                Get_Attribute DF_FIELD_TYPE      of iFile iField  to iType
                                Get_Attribute DF_FIELD_LENGTH    of iFile iField  to iLength
                                Get_Attribute DF_FIELD_PRECISION of iFile iField  to iPrec
                                If (iType = DF_BCD) Begin
                                    Move (iLength - iPrec) to iLength
                                End
                                Else Begin
                                    Move 0 to iPrec
                                End
                                Get_Attribute DF_FIELD_NAME of iFile iField to sField
                                Get UpperFirstChar sField       to sField
                                Get FieldType iType             to sType
                                Set Value   of oType_fm         to sType
                                Set Value   of oLength_fm       to (String(iLength) + "," + String(iPrec))
                                Set psField of oConstraints_lst to sField
                                Set piType  of oConstraints_lst to iType
                            End_Procedure
        
                            // This is a dbComboform but not attached to a db field.
                            // We kill these two procedures so the DDO doesn't get triggered:
                            Procedure Set Changed_Value Integer iField String sValue
                            End_Procedure
                            Procedure Set Changed_State Boolean bState
                            End_Procedure
        
                        End_Object
        
                        Object oType_fm is a cRDCForm
                            Set Label to "Type"
                            Set Size to 14 44
                            Set Location to 38 118
                            Set Status_Help to "The selected field/column type"
                            Set Label_Col_Offset to 0
                            Set Label_Justification_Mode to JMode_Top
                            Set Enabled_State to False
                            Set Label_Row_Offset to 1
        
                            Procedure Set Enabled_State Boolean bState
                                Forward Set Enabled_State to False
                            End_Procedure
                        End_Object
        
                        Object oLength_fm is a cRDCForm
                            Set Label to "Length"
                            Set Size to 14 33
                            Set Location to 38 169
                            Set Status_Help to "The selected field/column length and precision"
                            Set Label_Col_Offset to 0
                            Set Label_Justification_Mode to JMode_Top
                            Set Enabled_State to False
                            Set Label_Row_Offset to 1
        
                            Procedure Set Enabled_State Boolean bState
                                Forward Set Enabled_State to False
                            End_Procedure
                        End_Object
        
                        Object oMode_cf is a cRDCComboForm
                            Set Label to "Mode"
                            Set Size to 14 47
                            Set Location to 38 208
                            Set Status_Help to "Logical operators to use for the filter"
                            Set Entry_State Item 0 to False
                            Set Combo_Sort_State to False
                            Set Label_Col_Offset to 0
                            Set Label_Justification_Mode to JMode_Top
                            Set Label_Row_Offset to 1
        
                            Procedure Combo_Fill_List
                                Send Combo_Add_Item "<"
                                Send Combo_Add_Item "<="
                                Send Combo_Add_Item "="
                                Send Combo_Add_Item "<>"
                                Send Combo_Add_Item ">"
                                Send Combo_Add_Item ">="
                                Send Combo_Add_Item "Matches"
                                Send Combo_Add_Item "Contains"
                                Set Value Item 0 to "<"
                            End_Procedure
        
                            Procedure DoFillList
                                Send Combo_Delete_Data
                                Send Combo_Fill_List
                            End_Procedure
        
                            Procedure OnChange
                                Integer iItem
                                String sMode
                                Get WinCombo_Current_Item      to iItem
                                Get WinCombo_Value Item iItem  to sMode
                                If (Trim(sMode) = "") Begin
                                    Move "<" to sMode
                                End
                                Set psMode of oConstraints_lst to sMode
                            End_Procedure
        
                            Procedure DoCheckClear
                                Send DoFillList
                            End_Procedure
                        End_Object
        
                        Object oValue_fm is a cRDCForm
                            Set Label to "Value"
                            Set Size to 14 69
                            Set Location to 38 261
                            Set Status_Help to "The value to filter the selected Source data field."
                            Set Label_Col_Offset to 0
                            Set Label_Justification_Mode to JMode_Top
                            Set Label_Row_Offset to 1
        
                            Procedure OnChange
                                String sValue
                                Get Value to sValue
                                Set psValue of oConstraints_lst to sValue
                            End_Procedure
        
                            Procedure DoCheckClear
                                Set Value to ""
                            End_Procedure
                        End_Object
        
                        Object oSelect_bn is a cRDCButton
                            Set Label to "Add"
                            Set Location to 38 337
                            Set Status_Help to "Add the entered filter to the list below"
                            Set psImage to "FilterAdd.ico"
        
                            Procedure OnClick
                                Handle ho
                                String sValue sField sText
                                Integer iType iRetval
        
                                Move (oConstraints_lst(Self)) to ho
                                Get piType  of ho to iType 
                                Get psValue of ho to sValue
                                Get psField of ho to sField     
                                If (sField = "") Begin
                                    Send Info_Box "You need to select a field first."
                                    Procedure_Return
                                End
                                If (iType = DF_DATE or iType = DF_BCD) Begin
                                    If (iType = DF_DATE) Begin
                                        Get IsDate sValue to iRetval
                                        If (not(iRetval)) Begin
                                            Move "Incorrect date format. Hint: Press the 'View Data' button and press Enter on a date." to sText
                                        End
                                    End
                                    If (iType = DF_BCD)  Begin
                                        Get IsNumeric sValue to iRetval
                                        If (not(iRetval)) Begin
                                            Move "Value should be numeric." to sText
                                        End
                                    End
                                    If (not(iRetval)) Begin
                                        Send Info_Box sText
                                        Procedure_Return
                                    End
                                End
                                Send DoAddToList of ho iType sField sValue
                                Send DoUpdateDDBuffer of ho
                            End_Procedure
        
                            Function IsEnabled Returns Boolean
                                Boolean bFromOpen bToOpen                           
                                Get_Attribute DF_FILE_OPENED of giFromFile to bFromOpen
                                Get_Attribute DF_FILE_OPENED of giToFile   to bToOpen
                                Function_Return (bFromOpen = True and bToOpen = True)    
                            End_Function
                            
                        End_Object
        
                        Object oDeleteValueTable_bn is a cRDCButton
                            Set Label to "Delete"
                            Set Location to 73 337
                            Set Status_Help to "Delete the currently selected filter"
                            Set psImage to "ActionDelete.ico"
                            
                            Procedure OnClick
                                Integer iItem       
                                Handle hoList
                                Move (oConstraints_lst(Self)) to hoList
                                Send DoDeleteItem of hoList 
                            End_Procedure
        
                            Function IsEnabled Returns Boolean
                                Boolean bFromOpen bToOpen                           
                                Get_Attribute DF_FILE_OPENED of giFromFile to bFromOpen
                                Get_Attribute DF_FILE_OPENED of giToFile   to bToOpen
                                Function_Return (bFromOpen = True and bToOpen = True)    
                            End_Function
                            
                        End_Object
        
                        Object oConstraints_lst is a cCJGrid
                            Set Size to 157 322
                            Set Location to 62 10
                            Set peAnchors to anTopBottom
                            Set pbUseAlternateRowBackgroundColor to True
                            Set psNoItemsText to "No data found..."
                            Set pbShowRowFocus to True
                            Set pbAllowEdit to False
                            Set pbAutoAppend to False
                            Set pbAllowAppendRow to False
                            Set pbAllowInsertRow to False
                            Set pbAllowColumnRemove to False
                            Set pbAllowColumnReorder to False
                            Set pbAllowColumnResize to False
                            Set pbEditOnTyping to False
                            Set pbSelectionEnable to True
                            Set piSelectedRowBackColor to clGreenGreyLight
                            Set piHighlightBackColor   to clGreenGreyLight
                            Set pbShowFooter to True
        
                            Object oConstraint_col is a cCJGridColumn
                                Set piWidth to 537
                                Set psCaption to "Selected Filters (Filters are additive)"
                                Set psToolTip to "List with entered filters/selections. Press Del or Ctrl+X to remove an item."
                                Set psFooterText to "No of Filters:"
                            End_Object
        
                            Property Integer piType  -1
                            Property String  psField ""
                            Property String  psValue ""
                            Property String  psMode  "<"
        
                            Procedure DoAddToList
                                Integer iType
                                String sTable sField sMode sValue sText
                                
                                Get piType to iType
                                Get Field_Current_Value of (Main_DD(Self)) Field SncTable.Fromdatatable to sTable
                                Get StripExt sTable to sTable
                                Get psField to sField
                                Get psMode  to sMode
                                Get psValue to sValue
                                Move ("Constrain" * String(sTable) + "." + String(sField) * String(sMode))         to sText
                                If (iType = DF_ASCII or iType = DF_TEXT) Begin
                                    Move (sText * '"' + String(sValue) + '"') to sText
                                End
                                Else Begin
                                    If (Trim(sValue) = "") Begin
                                        Move 0 to sValue
                                    End
                                    Move (sText * String(sValue)) to sText
                                End
                                Send AddItem sText
                                Send MoveToFirstRow
                            End_Procedure
        
                            Procedure AddItem String sConstraint
                                Handle hoDataSource
                                tDataSourceRow[] TheData
                                Integer iSize iDataCol
                        
                                If (not(IsComObjectCreated(Self))) Begin
                                    Procedure_Return
                                End
                                Get piColumnId of oConstraint_col to iDataCol
                                Get phoDataSource to hoDataSource
                                Get DataSource of hoDataSource to TheData
                                Move (SizeOfArray(TheData)) to iSize
                                Move sConstraint to TheData[iSize].sValue[iDataCol]
                                Send ReInitializeData TheData False
                            End_Procedure
        
                            // Returns number of items.
                            Function ItemCount Returns Integer
                                Integer iItems
                                Handle hoDataSource
                                tDataSourceRow[] TheData
                        
                                Get phoDataSource to hoDataSource
                                Get DataSource of hoDataSource to TheData
                                Move (SizeOfArray(TheData)) to iItems
                        
                                Function_Return iItems
                            End_Function
        
                            Procedure DoDeleteItem
                                Integer iItem
                                Get ItemCount to iItem
                                If (not(iItem)) Begin
                                    Procedure_Return
                                End
                                Send Request_Delete 
                                Send MoveToFirstRow
                                Send DoUpdateDDBuffer
                            End_Procedure  
                            
                            Function Value Integer iItem Returns String
                                Handle hoDataSource                   
                                Integer iCol
                                tDataSourceRow[] TheData       
                                String sValue
                                
                                If (iItem < 0) Begin
                                    Function_Return ""
                                End                   
                                Move "" to sValue
                                Get piColumnId of oConstraint_col to iCol
                                Get phoDataSource to hoDataSource
                                Get DataSource of hoDataSource to TheData
                                If (SizeOfArray(TheData) <> 0) Begin
                                    Move TheData[iItem].sValue[iCol] to sValue
                                End
                        
                                Function_Return sValue
                            End_Function
                            
                            Procedure Delete_Data  
                                If (not(IsComObjectCreated(Self))) Begin
                                    Procedure_Return
                                End
                                Send ResetGrid
                                Set psFooterText of oConstraint_col to ("No of Filters:")
                            End_Procedure   
                            
                            Procedure Add_Focus Handle hoParent Returns Integer
                                Forward Send Add_Focus hoParent
                                Send DoFillList
                            End_Procedure
        
                            Procedure DoFillList
                                Handle hoDD
                                Boolean bTableChanged
                                Integer iCount iFile iField iType iConstr iMode iOpen
                                String sTable sField sConstr sMode sValue sChar
        
                                If (not(IsComObjectCreated(Self))) Begin
                                    Procedure_Return
                                End
        
                                Send Delete_Data
                                Delegate Get Main_DD to hoDD
                                Get Field_Current_Value of hoDD Field SncTable.Constraints to sConstr
                                Move (Trim(sConstr)) to sConstr
                                If (Length(sConstr) = 0) Begin
                                    Procedure_Return
                                End
                                Move (sConstr + "|") to sConstr // Format: "Field_Number|Mode|Value"
                                Move giFromFile to iFile
                                Send Ignore_Error of Error_Info_Object 4105 // 'Bad file number'
                                Get_Attribute DF_FILE_OPENED of iFile to iOpen
                                Send Trap_Error   of Error_Info_Object 4105 // 'Bad file number'
                                If (not(iOpen)) Begin
                                    Procedure_Return
                                End
        
                                // This will take care of a special situation.
                                // The user has created a record and has also specified Selfields, and then changes the
                                // datatable comboform to another table...
                                Get Field_Changed_State of hoDD Field SncTable.FromDataTable  to bTableChanged
                                If bTableChanged Begin
                                    // Reset DDO buffer value in case user saves the new config.
                                    Set Field_Changed_Value of hoDD Field SncTable.Constraints  to ""
                                    Procedure_Return
                                End
        
                                Get Field_Current_Value of hoDD Field SncTable.Fromdatatable  to sTable
                                Get StripExt sTable                                           to sTable
                                Get Field_Current_Value of hoDD Field SncTable.ConstrainCount to iConstr
        
                                For iCount from 1 to iConstr
                                    Get ExtractValue sConstr " "                 to iField     // Extract Field Value. (From SyncFuncs.pkg)
                                    Move (Replace((String(iField) + " "), sConstr, "")) to sConstr
                                    Get_Attribute DF_FIELD_NAME of iFile iField  to sField
                                    Get_Attribute DF_FIELD_TYPE of iFile iField  to iType
                                    Set piType                                   to iType
                                    Move (Uppercase(Left(sField, 1)))            to sChar
                                    Move (sChar + Right(Lowercase(sField), (Length(sField) -1))) to sField // Uppercase first letter.
                                    Set psField                                  to sField
                                    Move (Left(sConstr, 1))                      to iMode
                                    Get ExtractMode sConstr                      to sMode
                                    Move (Replace((String(iMode) + " "), sConstr, ""))  to sConstr
                                    Set psMode                                   to sMode
                                    Get ExtractValue sConstr "|"                 to sValue
                                    Move (Replace((sValue + "|"), sConstr, ""))  to sConstr
                                    Set psValue                                  to sValue
                                    Send DoAddToList
                                Loop
                                Set psFooterText of oConstraint_col to ("No of Filters:" * String(iConstr))
                            End_Procedure
        
                            Procedure DoUpdateDDBuffer
                                Handle hoDD
                                Integer iCount iFile iField iPos iItems iMode
                                String sTable sField sConstr sValue sText
                                
                                Move "" to sConstr
                                Get Main_DD to hoDD
                                Move giFromFile to iFile
                                Get ItemCount to iItems
                                For iCount from 0 to (iItems - 1)
                                    Get Value Item iCount                       to sText
                                    If (Trim(sText) = "") Break
                                    Move (sText - " ")                          to sText
                                    Move (Pos(".", sText))                      to iPos
                                    Move (Left(sText, iPos))                    to sTable   // File:
                                    Move (Replace(sTable, sText, ""))           to sText
                                    Get ExtractValue sText " "                  to sField   // Function in SysFuncs.pkg
                                    Field_Map iFile sField                      to iField   // Field:
                                    Move (Replace((sField + " "), sText, ""))   to sText
                                    Get ExtractMode sText                       to iMode    // Mode (Operator)
                                    Move (Pos(" ", sText))                      to iPos
                                    Move (Right(sText, (Length(sText) - iPos))) to sText
                                    Get ExtractValue sText " "                  to sValue
                                    Move (Replace((sValue + " "), sText, ""))   to sText
                                    Move (Replaces('"', sValue, ''))            to sValue   // Value
                                    Move (String(iField) * String(iMode) * String(sValue)) to sText
                                    If (iCount < (iItems -1)) Begin
                                        Move (sText + "|") to sText
                                    End
                                    Move (sConstr + String(sText)) to sConstr
                                Loop
        
                                If (Trim(sConstr) = "") Begin
                                    Move 0 to iItems
                                End
                                Set Field_Changed_Value of hoDD Field SncTable.Constraints    to sConstr
                                Set Field_Changed_Value of hoDD Field SncTable.ConstrainCount to iItems   
                            End_Procedure   
                            
                            // As the cCJGrid class has a message like this that "saves" the current row,
                            // we need to relay it to the parent for the toolbar keys to work.
                            Procedure Request_Save
                                Delegate Send Request_Save
                            End_Procedure
        
                            On_Key kDelete_Character Send DoDeleteItem
                            On_Key Key_Ctrl+Key_X    Send DoDeleteItem
                        End_Object
        
                        Procedure DoUpdateData Integer iFromFile Integer iToFile Boolean bFrom
                            Handle ho
                            String sTable
                            Integer iFile
                            Boolean bOpen
                            
                            Move False to bOpen
                            Get Field_Current_Value of (Main_DD(Self)) Field SncTable.FromDataTable to sTable
                            Move giFromFile to iFile
                            Get_Attribute DF_FILE_OPENED of iFile to bOpen
                            Set Enabled_State to (Length(sTable) > 0 and bOpen)
        
                            Move (oConstraints_lst(Self)) to ho
                            Send DoFillList of ho
                            Set Enabled_State of (Label_Object(ho))                       to (Length(sTable) > 0 and bOpen)
                            Set Enabled_State of (Label_Object(oType_fm))                 to (Length(sTable) > 0 and bOpen)
                            Set Enabled_State of (Label_Object(oLength_fm))               to (Length(sTable) > 0 and bOpen)
                        End_Procedure
        
                    End_Object
        
                    Property String psFromDataTable
                    Property String psToDataTable    
                    Property Boolean pbRefreshDone False
                    
                    Procedure Refresh Integer eMode
                        String sFromDataTable sToDataTable
                        Integer iSynchType
                        Handle hoDD
                        
                        Forward Send Refresh eMode
                        Move (Main_DD(Self)) to hoDD
                        Get Field_Current_Value of hoDD Field SncTable.FromDataTable to sFromDataTable 
                        Get Field_Current_Value of hoDD Field SncTable.ToDataTable   to sToDataTable 
                        Set psFromDataTable to sFromDataTable
                        Set psToDataTable   to sToDataTable
                        Set pbRefreshDone   to True // Tells the DoTimerUpdate message that data might need to be refreshed.
                        Send DoTimerUpdate
                    End_Procedure
        
                    Object oFiltersIdleHandler is a cIdleHandler
                        Set pbEnabled to False
                        Procedure OnIdle
                            Delegate Send DoTimerUpdate
                        End_Procedure
                    End_Object     
                    
                    // Enable the idle handler timer when the tab-page is activated
                    Procedure OnEnterArea Handle hoFrom
                        Set pbEnabled of oFiltersIdleHandler to True
                    End_Procedure
                
                    // Disable the idle handler when the tab-page is deactivated
                    Procedure OnExitArea Handle hoFrom
                        Set pbEnabled of oFiltersIdleHandler to False
                    End_Procedure
                    
                    Procedure DoTimerUpdate  
                        String sFromDataTable sToDataTable sFromDataTableLocal sToDataTableLocal
                        Integer iFromFile iToFile
                        Handle hoDD ho                   
                        Boolean bShouldRefresh bRefreshDone bFromFileOpen bToFileOpen
        
                        Move False to bFromFileOpen
                        Move False to bToFileOpen
                        Move (Main_DD(Self)) to hoDD
                        Get Field_Current_Value of hoDD Field SncTable.FromDataTable to sFromDataTable
                        Get Field_Current_Value of hoDD Field SncTable.ToDataTable   to sToDataTable 
                        Get psFromDataTable to sFromDataTableLocal
                        Get psToDataTable   to sToDataTableLocal
                        Get pbRefreshDone   to bRefreshDone
                        
                        If (bRefreshDone = False) Begin
                            Move (sFromDataTable <> sFromDataTableLocal or sToDataTable <> sToDataTableLocal) to bShouldRefresh
                        End 
                        Else Begin
                            Move True to bShouldRefresh 
                        End
                                        
                        If (bShouldRefresh = True) Begin     
                            Move giFromFile to iFromFile
                            Get_Attribute DF_FILE_OPENED of iFromFile to bFromFileOpen 
                            If (bFromFileOpen = False) Begin
                                Get RDSOpenAsFile hoDD True False to bFromFileOpen
                            End 
                            Move giToFile to iToFile
                            Get_Attribute DF_FILE_OPENED of iToFile to bToFileOpen
                            If (bToFileOpen = False) Begin
                                Get RDSOpenAsFile hoDD False False to bToFileOpen 
                            End                    
                            
                            Set pbRefreshDone   to False
                            Set psFromDataTable to sFromDataTable
                            Set psToDataTable   to sToDataTable
                            Broadcast Recursive Send DoUpdateData of oConstraints_grp iFromFile iToFile True 
                            Send DoFillList of oConstraints_lst
                            Set Enabled_State of oConstraints_grp to (bFromFileOpen = True and bToFileOpen = True)
                        End
                    End_Procedure
        
                End_Object
        
                Object oNulls_tp is a dbTabPage
                    Set Label to "Null Defaults"
                    Set Tab_ToolTip_Value to "Null defaults for the Destination table to use for undefined Source table values."
                    Set piImageIndex to 4
        
                    Property Integer piFile      0
                    Property Boolean pbUpdateOk  True
                    Property String  psDefaults  ''
        
                    Object oNullDefaults_grp is a cRDCHeaderDbGroup
                        Set Size to 253 395
                        Set Location to 7 7
                        Set Label to "Null Defaults"
                        Set psNote to "Used when a source table's field value is undefined."
                        Set psImage to "DatabaseDefaults.ico"
                        Set peAnchors to anAll
        
                        Object oEditDefaultsInfo_tb is a TextBox
                            Set Size to 10 62
                            Set Location to 50 213
                            Set Label to "Edit defaults here:"
                            Set FontWeight to fw_Bold
                            Set peAnchors to anTopRight
                        End_Object
        
                        Object oValues_grd is a cCJGrid
                            Set Size to 157 272
                            Set Location to 62 10
                            Set pbRestoreLayout to True
                            Set psLayoutSection to (Name(Self) + "_grid")
                            Set psNoItemsText to "No data found..."
                            Set pbAllowInsertRow to False
                            Set pbAllowAppendRow to False
                            Set pbHeaderPrompts to False
                            Set pbHeaderReorders to True
                            Set pbHeaderTogglesDirection to True
                            Set pbSelectionEnable to True
                            Set pbShowRowFocus to True
                            Set pbHotTracking to True
                            Set piLayoutBuild to 1
                            Set pbUseAlternateRowBackgroundColor to True
                            Set piSelectedRowBackColor to clGreenGreyLight
                            Set piHighlightBackColor   to clGreenGreyLight
                            Set peAnchors to anAll
                            Set pbShowFooter to True
                            
                            Object oFieldNumber_Col is a cCJGridColumn
                                Set piWidth to 44
                                Set psCaption to "Field No"
                                Set pbEditable to False
                                Set peDataType to 0
                                Set TextColor to clDkGray
                            End_Object
        
                            Object oFieldName_Col is a cCJGridColumn
                                Set piWidth to 81
                                Set psCaption to "Field Name"
                                Set pbEditable to False
                                Set TextColor to clDkGray
                            End_Object
        
                            Object oFieldType_Col is a cCJGridColumn
                                Set piWidth to 56
                                Set psCaption to "Type"
                                Set pbEditable to False
                                Set TextColor to clDkGray
                            End_Object
        
                            Object oFieldLength_Col is a cCJGridColumn
                                Set piWidth to 45
                                Set psCaption to "Length"
                                Set pbEditable to False
                                Set TextColor to clDkGray
                                Set pbDrawHeaderDivider to False
                            End_Object
        
                            Object oNullAllowed_Col is a cCJGridColumn
                                Set piWidth to 69
                                Set psCaption to "Null Allowed"
                                Set pbCheckbox to True
                                Set pbEditable to False
                                Set TextColor to clDkGray  
                                Set pbDrawHeaderDivider to False
                            End_Object
        
                            Object oDefinedDefault_Col is a cCJGridColumn
                                Set piWidth to 73
                                Set psCaption to "Std Default"
                                Set pbEditable to False
                                Set TextColor to clDkGray
                                Set pbDrawHeaderDivider to False
                            End_Object
        
                            Object oUseDefaultValue_Col is a cCJGridColumn
                                Set piWidth to 85
                                Set psCaption to "Use Default" 
        //                        Set psFooterText to "Edit defaults in this col"
                                Set pbAllowRemove to False
                                
                                // Sadly there is no way to change the font attributes for
                                // a single column header text. However, the footer text can
                                // be manipulated.
        //                        Procedure OnCreateColumn
        //                            Handle hoFont
        //                            Variant vFont
        //                           
        //                            Forward Send OnCreateColumn
        //                            Get Create (RefClass(cComStdFont)) to hoFont  
        //                            Get ComFooterFont to vFont  
        //                            Set pvComObject of hoFont to vFont
        //                            Set ComBold of hoFont to True
        //                            
        //                            Send Destroy to hoFont 
        //                        End_Procedure
        
                                Procedure OnEndEdit String sOldValue String sNewValue
                                    Forward Send OnEndEdit sOldValue sNewValue
                                    Send Request_Save
                                    Send DoUpdateDDBuffer
                                End_Procedure
        
                            End_Object
                            
                            // Returns number of items.
                            Function ItemCount Returns Integer
                                Integer iItems
                                Handle hoDataSource
                                tDataSourceRow[] TheData
                        
                                Get phoDataSource to hoDataSource
                                Get DataSource of hoDataSource to TheData
                                Move (SizeOfArray(TheData)) to iItems
                        
                                Function_Return iItems
                            End_Function
        
                            Procedure DoDeleteItem
                                Integer iItem
                                Get ItemCount to iItem
                                If (not(iItem)) Begin
                                    Procedure_Return
                                End
                                Send Request_Delete 
                                Send MoveToFirstRow
                            End_Procedure  
                            
                            Procedure Set Value Integer iItem Integer iCol String sValue 
                                Handle hoDataSource                   
                                tDataSourceRow[] TheData       
                                
                                If (iItem < 0) Begin
                                    Procedure_Return
                                End                   
                                Get phoDataSource to hoDataSource
                                Get DataSource of hoDataSource to TheData
                                Move sValue to TheData[iItem].sValue[iCol]
                                Send ReInitializeData TheData False
                            End_Procedure
                            
                            Function Value Integer iItem Integer iCol Returns String
                                Handle hoDataSource                   
                                tDataSourceRow[] TheData       
                                String sValue
                                
                                If (iItem < 0) Begin
                                    Function_Return ""
                                End                   
                                Move "" to sValue
                                Get phoDataSource to hoDataSource
                                Get DataSource of hoDataSource to TheData
                                If (SizeOfArray(TheData) <> 0) Begin
                                    Move TheData[iItem].sValue[iCol] to sValue
                                End
                        
                                Function_Return sValue
                            End_Function
                            
                            Procedure Delete_Data  
                                If (not(IsComObjectCreated(Self))) Begin
                                    Procedure_Return
                                End
                                Send ResetGrid  
                            End_Procedure   
                            
                            Procedure Add_Item Integer iRow String sValue Integer iCol
                                Handle hoDataSource
                                tDataSourceRow[] TheData
                                Integer iSize 
                        
                                If (not(IsComObjectCreated(Self))) Begin
                                    Procedure_Return
                                End
                                Get phoDataSource to hoDataSource
                                Get DataSource of hoDataSource to TheData
                                Move sValue to TheData[iRow].sValue[iCol]
                                Send ReInitializeData TheData False
                            End_Procedure
        
                            Procedure Add_Focus Handle hoParent Returns Integer
                                Forward Send Add_Focus hoParent
                                Send DoFillGrid
                            End_Procedure
        
                            Procedure DoFillGrid
                                Handle hoDD
                                Boolean bTableChanged bOpen
                                Integer iFile iCount iFields iType iLength iPrec
                                Integer iNul iItmCnt iItem iDbType iRow
                                String sDefaults sValue sField sType sDefaultValue sLength
                                String asDefaults
                                
                                If (not(IsComObjectCreated(Self))) Begin
                                    Procedure_Return
                                End
                                Send Delete_Data
                                Get Main_DD to hoDD
                                Move giToFile to iFile
                                Get_Attribute DF_FILE_OPENED of iFile to bOpen
                                If (bOpen = False) Begin
                                    Procedure_Return
                                End
        
                                Get Field_Current_Value of hoDD Field SncTable.ToDbType    to iDbType
                                Get Field_Changed_State of hoDD Field SncTable.ToDataTable to bTableChanged
                                If bTableChanged Begin
                                    // Reset DDO buffer value in case user saves the new config.
                                    Set Field_Changed_Value of hoDD Field SncTable.ToDefaults to ""
                                End
                                Send Default_Value of oDate_fm iDbType // Sets proper default date depending on selected driver.
                                Get Field_Current_Value of hoDD Field SncTable.ToDefaults to sDefaults
                                Move (Trim(sDefaults))  to sDefaults
                                Get_Attribute DF_FILE_NUMBER_FIELDS of iFile to iFields
                                Move 0 to iItem
                                Send Ignore_Error of Error_Info_Object DFERR_FIELD_NUMBER_RANGE
                                Move False to Err
                                Move 0 to iRow
                                
                                For iCount from 1 to iFields                  
                                    // Field number:
                                    Send Add_Item iRow iCount (piColumnId(oFieldNumber_Col))
                                    // Field name:
                                    Get_Attribute DF_FIELD_NAME of iFile iCount to sField
                                    Get UpperFirstChar sField to sField
                                    Send Add_Item iRow sField (piColumnId(oFieldName_Col))
        
                                    // Type:
                                    Get_Attribute DF_FIELD_TYPE of iFile iCount to iType
                                    Get FieldType iType to sType
                                    Send Add_Item iRow sType (piColumnId(oFieldType_Col))
        
                                    // Length:
                                    Get_Attribute DF_FIELD_LENGTH    of iFile iCount to iLength
                                    Get_Attribute DF_FIELD_PRECISION of iFile iCount to iPrec
                                    If (iType = DF_BCD) Begin
                                        Move (iLength - iPrec) to iLength
                                    End
                                    Else Begin
                                        Move 0 to iPrec
                                    End
                                    Move (String(iLength) + "," + String(iPrec)) to sLength
                                    Send Add_Item iRow sLength (piColumnId(oFieldLength_Col))
        
                                    // Nullable:
                                    Get_Attribute DF_FIELD_NULL_ALLOWED of iFile iCount to iNul
                                    Send Add_Item iRow iNul (piColumnId(oNullAllowed_Col))
        
                                    // The solution to the problem was to use square brackets and/or a string variable with the format of the default.
                                    //
                                    // Instead of:
                                    // Set_Attribute DF_FIELD_DEFAULT_VALUE of hTable iFieldNo to "(0)"
                                    //
                                    // The logic now uses:
                                    // Move '[(0)]' to sDefault
                                    // Set_Attribute DF_FIELD_DEFAULT_VALUE of hTable iFieldNo to sDefault
        
                                    // Default Value:
                                    Get_Attribute DF_FIELD_DEFAULT_VALUE   of iFile iCount to sDefaultValue
                                    Send Add_Item iRow sDefaultValue (piColumnId(oDefinedDefault_Col))
        
                                    // Null Default Value to be entered:
                                    If (Length(sDefaults)) Begin
                                        Get ExtractFieldValue sDefaults iCount to sValue
                                    End
                                    Else Begin
                                        Move "" to sValue
                                    End
                                    Send Add_Item iRow sValue (piColumnId(oUseDefaultValue_Col))
                                    Increment iRow
                                    If (Err) Break // Has been set to False before the loop.
                                Loop
        
                                Send Trap_Error of Error_Info_Object DFERR_FIELD_NUMBER_RANGE  
                                Send MoveToFirstRow
                            End_Procedure
        
                            Function ExtractFieldValue String sDefaults Integer iField Returns String
                                Integer iStart iEnd iCount
                                For iCount from 1 to (iField - 1)
                                    Move (Replace("|", sDefaults, "")) to sDefaults
                                Loop
                                Move (Pos("|", sDefaults))         to iStart
                                Move (Replace("|", sDefaults, "")) to sDefaults
                                Move (Pos("|", sDefaults))         to iEnd
                                Function_Return (Mid(sDefaults, (iEnd - iStart), iStart))
                            End_Function
        
                            Procedure DoRemoveValues
                                Integer iCount iSize iCol
                                Handle hoDataSource
                                tDataSourceRow[] TheData
                                
                                Get piColumnId of (oUseDefaultValue_Col(Self)) to iCol
                                Get phoDataSource to hoDataSource
                                Get DataSource of hoDataSource to TheData
                                Move (SizeOfArray(TheData)) to iSize
                                Decrement iSize
                                For iCount from 0 to iSize
                                    Move "" to TheData[iCount].sValue[iCol]
                                Loop
                                Send ReInitializeData TheData False
                                Set Field_Changed_Value of (Main_DD(Self)) Field SncTable.ToDefaults to ""
                            End_Procedure
        
                            Procedure DoApplyNewValues String sAscii String sText String sNumeric String sDate String sBinary
                                Integer iItems iCount iFieldTypeCol iUseDefaultCol
                                String sType sValue
        
                                If (sAscii contains "|" or sText contains "|" or sNumeric contains "|" or sDate contains "|" or sBinary contains "|") Begin
                                    Send Info_Box ("Sorry, the vertical bar character (|) cannot be used for a default value. It is used as a divider when the defaults are saved to the SncTable record.")
                                    Procedure_Return
                                End
                                Get ItemCount to iItems 
                                Decrement iItems
                                Get piColumnId of oFieldType_Col       to iFieldTypeCol
                                Get piColumnId of oUseDefaultValue_Col to iUseDefaultCol
        
                                For iCount from 0 to iItems
                                    Get Value Item iCount iFieldTypeCol to sType
                                    Case Begin
                                        Case (sType = "ASCII")
                                            Move sAscii to sValue
                                            Case Break
                                        Case (sType = "Numeric")
                                            Move sNumeric to sValue
                                            Case Break
                                        Case (sType = "Date")
                                            Move sDate to sValue
                                            Case Break
                                        Case (sType = "Text")
                                            Move sText to sValue
                                            Case Break
                                        Case (sType = "Binary")
                                            Move sBinary to sValue
                                            Case Break
                                    Case End
                                    Set Value Item iCount iUseDefaultCol to sValue
                                Loop
        
                                Send DoUpdateDDBuffer
                            End_Procedure
        
                            Procedure DoUpdateDDBuffer
                                Handle hoDD
                                Integer iItems iCount iSize iCols iCol
                                String sValue sDefaults sCrntDefaults sCheck
                                Handle hoDataSource
                                tDataSourceRow[] TheData
        
                                Delegate Get Main_DD to hoDD
                                Move "|" to sDefaults
                                Get piColumnId of oUseDefaultValue_Col to iCol
                                Get phoDataSource to hoDataSource
                                Get DataSource of hoDataSource to TheData
                                Move (SizeOfArray(TheData)) to iSize
                                Decrement iSize
        
                                For iCount from 0 to iSize
                                    Move TheData[iCount].sValue[iCol] to sValue
                                    If (sValue contains "|") Begin
                                        Send Info_Box ("Sorry, the vertical bar character (|) cannot be used for a default value. It is used as a divider when the defaults are saved to the SncTable record.")
                                        Procedure_Return
                                    End
                                    Move (sDefaults + String(sValue) + "|") to sDefaults
                                Loop
                                Move (Trim(sDefaults)) to sDefaults
                                Move (Repeat("|", iSize)) to sCheck
                                If (sCheck = sDefaults) Begin
                                    Move " " to sDefaults // Must be at least a space to be able to save a change to the DDO
                                End
                                Get Field_Current_Value of hoDD Field SncTable.ToDefaults to sCrntDefaults
                                If (Trim(sCrntDefaults) <> sDefaults) Begin
                                    Set Field_Changed_Value of hoDD Field SncTable.ToDefaults   to sDefaults
                                    Set Field_Changed_Value of hoDD Field SncTable.ZeroLengthOk to (sDefaults <> " ")
                                End  
                            End_Procedure
        
                            On_Key Key_Ctrl+Key_S Send DoSave
                            On_Key Key_F2         Send DoSave
                            On_Key kCancel        Send None
                        End_Object
        
                        Object oDefaults_grp is a dbGroup
                            Set Size to 192 100
                            Set Location to 28 289
                            Set Label to "Use These Default Values"
                            Set peAnchors to anTopBottomRight
        
                            Object oASCII_fm is a cRDCForm
                                Set Label to "ASCII Fields"
                                Set Size to 14 81
                                Set Location to 23 9
                                Set Status_Help to "Default value to apply for all fields/columns of type ASCII. Surround the value with single quotes."
                                Set Label_Justification_Mode to jMode_Top
                                Set Label_Row_Offset to 1
                                Set Label_Col_Offset to 0
                                Set Value to "' '"
                            End_Object
        
                            Object oText_fm is a cRDCForm
                                Set Label to "Text Fields"
                                Set Size to 14 81
                                Set Location to 50 9
                                Set Status_Help to "Default value to apply for all fields/columns of type Text or Note"
                                Set Label_Justification_Mode to jMode_Top
                                Set Label_Row_Offset to 1
                                Set Label_Col_Offset to 0
                                Set Value Item 0 to "' '"
                            End_Object
        
                            Object oNumeric_fm is a cRDCForm
                                Set Label to "Numeric Fields"
                                Set Size to 14 81
                                Set Location to 79 9
                                Set Status_Help to "Default value to apply for all fields/columns of type Number"
                                Set Label_Justification_Mode to jMode_Top
                                Set Label_Row_Offset to 1
                                Set Label_Col_Offset to 0
                                Set Value Item 0 to "0"
                            End_Object
        
                            Object oDate_fm is a cRDCForm
                                Set Label to "Date Fields"
                                Set Size to 14 81
                                Set Location to 106 9
                                Set Status_Help to "Default value to apply for all fields/columns of type Date"
                                Set Label_Justification_Mode to jMode_Top
                                Set Label_Row_Offset to 1
                                Set Label_Col_Offset to 0
                                Set Value to "1900-01-01"
        
                                Procedure Default_Value Integer iDbType
                                    Integer iDateFormat
                                    String  sDefaultDate
                                    If (iDbType = EN_DbTypeDB2) Begin
                                        Set Value to "0001-01-01"
                                    End
                                    If (iDbType = EN_DbTypeMSSQL) Begin
                                        Set Value to "1753-01-01" 
                                    End
                                    If (iDbType = EN_DbTypeMySQL or iDbType = EN_DbTypePostgre) Begin
                                        Set Value to "1900-01-01" 
                                    End
                                    If (iDbType = EN_DbTypeOracle) Begin
                                        Set Value to "1900-01-01" 
                                    End
                                    If (iDbType = EN_DbTypeDataFlex or iDbType = EN_DbTypePervasive) Begin
                                        Get_Attribute DF_DATE_FORMAT to iDateFormat
                                        If (iDateFormat = DF_DATE_USA) Begin
                                            Move "01-01-1900" to sDefaultDate
                                        End
                                        If (iDateFormat = DF_DATE_EUROPEAN) Begin
                                            Move "01-01-1900" to sDefaultDate
                                        End
                                        If (iDateFormat = DF_DATE_MILITARY) Begin
                                            Move "1900-01-01" to sDefaultDate
                                        End
                                        Set Value to sDefaultDate
                                    End
                                End_Procedure
                            
                            End_Object
        
                            Object oBinary_fm is a cRDCForm
                                Set Label to "Binary Fields"
                                Set Size to 14 81
                                Set Location to 135 9
                                Set Status_Help to "Default value to apply for all fields/columns of type Binary"
                                Set Label_Col_Offset to 0
                                Set Label_Justification_Mode to jMode_Top
                                Set Label_Row_Offset to 1
                                Set Value Item 0 to "0"
                            End_Object
        
                            Object oApplyAllRows_bn is a cRDCButton
                                Set Label to "&Apply for All Rows"
                                Set Size to 14 81
                                Set Location to 154 9
                                Set Status_Help to "Apply for All rows in the grid to the left" 
                                Set psImage to "ActionOK.ico"
        
                                Procedure OnClick
                                    String sAscii sText sNumeric sDate sBinary
                                    Get Value of oAscii_fm   to sAscii
                                    Get Value of oText_fm    to sText
                                    Get Value of oNumeric_fm to sNumeric
                                    Get Value of oDate_fm    to sDate
                                    Get Value of oBinary_fm  to sBinary
                                    Send DoApplyNewValues of oValues_grd sAscii sText sNumeric sDate sBinary
                                End_Procedure 
                                
                                Function IsEnabled Returns Boolean
                                    Boolean bFromOpen bToOpen                           
                                    Get_Attribute DF_FILE_OPENED of giFromFile to bFromOpen
                                    Get_Attribute DF_FILE_OPENED of giToFile   to bToOpen
                                    Function_Return (bFromOpen = True and bToOpen = True)    
                                End_Function
                            
                                On_Key Key_Ctrl+Key_S Send Request_Save 
                            End_Object
        
                            Object oRemoveAllRows_bn is a cRDCButton
                                Set Label to "&Remove all Defaults"
                                Set Size to 14 81
                                Set Location to 170 9
                                Set Status_Help to "Remove all 'Use Default Value(s)' from the grid to the left"  
                                Set psImage to "ActionRemove.ico"
        
                                Procedure OnClick
                                    Send DoRemoveValues of oValues_grd
                                End_Procedure
        
                                Function IsEnabled Returns Boolean
                                    Boolean bFromOpen bToOpen                           
                                    Get_Attribute DF_FILE_OPENED of giFromFile to bFromOpen
                                    Get_Attribute DF_FILE_OPENED of giToFile   to bToOpen
                                    Function_Return (bFromOpen = True and bToOpen = True)    
                                End_Function
                            
                            End_Object
        
                        End_Object
        
                        // Note: Do not use cRDCDbGroup here as other tab-pages objects will "bleed" over these objects
        
                        Procedure DoUpdateData Integer iFromFile Integer iToFile Boolean bFrom
                            Handle ho
                            String sTable
                            Integer iDbType
                            Boolean bOpen
        
                            Move False to bOpen
                            Get Field_Current_Value of (Main_DD(Self)) Field SncTable.ToDatatable to sTable
                            If (iToFile <> 0) Begin
                                Get_Attribute DF_FILE_OPENED of iToFile to bOpen
                            End
                            Get Field_Current_Value of (Main_DD(Self)) Field SncTable.ToDbType to iDbType
                            Set Enabled_State  to (Length(sTable) > 0 and (bOpen = True))
                            If (Length(sTable) > 0 and bOpen = True) Begin
                                Set Enabled_State  of oDefaults_grp to True
                                Broadcast Recursive Set Enabled_State of (oDefaults_grp(Self)) to True
                            End
                            Move (oValues_grd(Self)) to ho
                            If (Enabled_State(Self)) Begin
                                Set Color of ho to clWindow
                            End
                            Else Begin
                                Set Color of ho to clLtGray
                            End
                            If (ho) Begin
                                Send DoFillGrid of ho
                            End
                        End_Procedure
        
                    End_Object
        
                    Property String psFromDataTable
                    Property String psToDataTable    
                    Property Boolean pbRefreshDone False
                    
                    Procedure Refresh Integer eMode
                        String sFromDataTable sToDataTable
                        Integer iSynchType
                        Handle hoDD
                        
                        Forward Send Refresh eMode
                        Move (Main_DD(Self)) to hoDD
                        Get Field_Current_Value of hoDD Field SncTable.FromDataTable to sFromDataTable 
                        Get Field_Current_Value of hoDD Field SncTable.ToDataTable   to sToDataTable 
                        Set psFromDataTable to sFromDataTable
                        Set psToDataTable   to sToDataTable
                        Set pbRefreshDone   to True // Tells the DoTimerUpdate message that data might need to be refreshed.
                        Send Delete_Data of oValues_grd
                        Send DoTimerUpdate
                    End_Procedure
        
                    Object oNullsIdleHandler is a cIdleHandler
                        Set pbEnabled to False
                        Procedure OnIdle
                            Delegate Send DoTimerUpdate
                        End_Procedure
                    End_Object     
                    
                    // Enable the idle handler timer when the tab-page is activated
                    Procedure OnEnterArea Handle hoFrom
                        Set pbEnabled of oNullsIdleHandler to True
                    End_Procedure
                
                    // Disable the idle handler when the tab-page is deactivated
                    Procedure OnExitArea Handle hoFrom
                        Set pbEnabled of oNullsIdleHandler to False
                    End_Procedure
                    
                    Procedure DoTimerUpdate  
                        String sFromDataTable sToDataTable sFromDataTableLocal sToDataTableLocal
                        Integer iFromFile iToFile
                        Handle hoDD ho                   
                        Boolean bShouldRefresh bRefreshDone bFromFileOpen bToFileOpen
        
                        Move False to bFromFileOpen
                        Move False to bToFileOpen
                        Move (Main_DD(Self)) to hoDD
                        Get Field_Current_Value of hoDD Field SncTable.FromDataTable to sFromDataTable
                        Get Field_Current_Value of hoDD Field SncTable.ToDataTable   to sToDataTable 
                        Get psFromDataTable to sFromDataTableLocal
                        Get psToDataTable   to sToDataTableLocal
                        Get pbRefreshDone   to bRefreshDone
                        
                        If (bRefreshDone = False) Begin
                            Move (sFromDataTable <> sFromDataTableLocal or sToDataTable <> sToDataTableLocal) to bShouldRefresh
                        End 
                        Else Begin
                            Move True to bShouldRefresh 
                        End
                                        
                        If (bShouldRefresh = True) Begin     
                            Move giFromFile to iFromFile
                            Get_Attribute DF_FILE_OPENED of iFromFile to bFromFileOpen 
                            If (bFromFileOpen = False) Begin
                                Get RDSOpenAsFile hoDD True False to bFromFileOpen
                            End 
                            Move giToFile to iToFile
                            Get_Attribute DF_FILE_OPENED of iToFile to bToFileOpen
                            If (bToFileOpen = False) Begin
                                Get RDSOpenAsFile hoDD False False to bToFileOpen 
                            End                    
                            // If table is not open, it means that the refresh message has got us here and
                            // the tables have not yet been opened by the two cDbComboformDataTable objects.
                            // If so, we wait until they have been.
                            If (bFromFileOpen = False or bToFileOpen = False) Begin
                                Procedure_Return
                            End
                            
                            Set pbRefreshDone   to False
                            Set psFromDataTable to sFromDataTable
                            Set psToDataTable   to sToDataTable   
                            Send DoFillGrid of oValues_grd
                            Broadcast Recursive Send DoUpdateData of oNullDefaults_grp iFromFile iToFile False 
                        End
                    End_Procedure
        
                    On_Key Key_Alt+Key_A  Send KeyAction to oApplyAllRows_bn
                    On_Key Key_Alt+Key_R  Send KeyAction to oRemoveAllRows_bn
                End_Object
        
                Object oValueConversion_tp is a dbTabPage
                    Set Label to "Value Conversion"
                    Set Tab_ToolTip_Value to "Change a Source field value into something else for the Target table"
                    Set piImageIndex to 5
        
                    Object oSncTRow_grp is a cRDCHeaderDbGroup
        Set Size to 253 395
                        Set Location to 7 7
                        Set Label to "Field Value Conversions"
                        Set psImage to "ValueConversion.ico"
                        Set psNote to "Change a Source field value into something else for the Target table"
                        Set peAnchors to anAll
        
                        Object oFromField_cf is a cDbFieldComboform
                            Entry_Item SncTHea.FromField
                            Set Server to oSncthea_DD
                            Set Label to "Source Field"
                            Set Size to 14 128
                            Set Location to 38 10
                            Set Label_Row_Offset to 1
                            Set Label_Col_Offset to 0
                            Set Label_Justification_Mode to jMode_Top
                        End_Object
        
                        Object oToField_cf is a cDbFieldComboform
                            Entry_Item SncTHea.ToField
                            Set Server to oSncthea_DD
                            Set Label to "Target Field"
                            Set Size to 14 135
                            Set Location to 38 145
                            Set Label_Row_Offset to 1
                            Set Label_Col_Offset to 0
                            Set Label_Justification_Mode to jMode_Top
                            Set pbFrom to False
                        End_Object
        
                        Object oInfoValue_tb is a cRDCTextbox
                            Set Label to "An example of a conversion value could be a source field that contains 'Y' or 'N' but the target field needs to be a 0 or 1. Use one table for each pair of selected fields."
                            Set Auto_Size_State to False
                            Set Location to 165 289
                            Set Size to 54 96
                            Set Border_Style to Border_StaticEdge
                            Set Justification_Mode to jMode_Left
                            Set peAnchors to anTopRight
                        End_Object
        
                        Object oSncTRow_Grid is a cDbCJGrid
                            Set Server to oSnctrow_DD
                            Set Size to 157 271
                            Set Location to 62 10
                            Set pbRestoreLayout to True
                            Set psLayoutSection to (Name(Self) + "_grid")
                            Set psNoItemsText to "No data found..."
                            Set pbHeaderReorders to False
                            Set pbHeaderPrompts to False
                            Set pbHeaderTogglesDirection to False
                            Set pbSelectionEnable to True
                            Set pbAllowInsertRow to False
                            Set pbAllowAppendRow to True
                            Set pbShowRowFocus to True
                            Set pbShowFooter to True
                            Set pbMultipleSelection to False
                            Set pbHotTracking to True
                            Set pbEditOnClick to True
                            Set piLayoutBuild to 1
                            Set pbUseAlternateRowBackgroundColor to True
                            Set piSelectedRowBackColor to clGreenGreyLight
                            Set piHighlightBackColor   to clGreenGreyLight
                            Set peAnchors to anAll    
        
                            Procedure OnEntering
                                Set pbNeedPostEntering to True
                            End_Procedure
        
                             Function OnPostEntering Returns Boolean
                                Handle hoDD hoDD2
                                Integer iFrom iTo iSncTableRecid iRetval iSncTHeaRecnum iSncTRowRecnum iID
                                Boolean bState bHasRecord
        
                                Move (oSncTable_DD(Self)) to hoDD2
                                Move (oSncTHea_DD(Self))  to hoDD
                                Get HasRecord of hoDD to bHasRecord
        
                                Get Field_Current_Value of hoDD Field SncTHea.FromField to iFrom
                                Get Field_Current_Value of hoDD Field SncTHea.ToField   to iTo
                                If (iFrom < 1 or iTo < 1) Begin
                                    Send Info_Box "You need to select both a Source and a Destination field from the comboforms above. (And the Destination field cannot be 'Recnum'. Please adjust and try again."
                                    Function_Return 1
                                End
                                If (not(pbGetHasCurrRowId(hoDD2))) Begin
                                    Move False to Err
                                    Get YesNo_Box "You are creating a new 'Database Tables Setup record'. It needs to be saved before a Transformation table can be entered. Save record now?" to iRetval
                                    If (iRetval = MBR_NO) Begin
                                        Function_Return 1
                                    End
                                    Send Request_Save of hoDD2
                                    If (Err) Begin
                                        Function_Return 1
                                    End
                                End
                                If (bHasRecord = False) Begin
                                    Send Request_Save of hoDD                              
                                End      
                                Function_Return False
                             End_Function
                            
                            Object oSncTRow_ID is a cDbCJGridColumn
                                Entry_Item SncTRow.ID
                                Set piWidth to 35
                                Set psCaption to "ID"
                                Set pbEditable to False
                            End_Object
        
                            Object oSncTRow_FromValue is a cDbCJGridColumn
                                Entry_Item SncTRow.FromValue
                                Set piWidth to 178
                                Set psCaption to "If Source Field Value Equals:"
                            End_Object
        
                            Object oSncTRow_ToValue is a cDbCJGridColumn
                                Entry_Item SncTRow.ToValue
                                Set piWidth to 173
                                Set psCaption to "Update Target Field with:"
                            End_Object
        
                            Object oSncTRow_IgnoreCase is a cDbCJGridColumn
                                Entry_Item SncTRow.IgnoreCase
                                Set piWidth to 66
                                Set psCaption to "Ignore Case"
                                Set pbCheckbox to True
                            End_Object
                            
                        End_Object
        
                        Object oNewValueTable_bn is a cRDCButton
                            Set Label to "Create &New Value Table"
                            Set Size to 14 96
                            Set Location to 62 288
                            Set Status_Help to "Create a new Transformation Table for a different set of Source and Target fields."
                            Set psImage to "ActionAddButton.ico"
                            Set peAnchors to anTopRight
                            
                            Procedure OnClick
                                Send DoCreateNewRecord of oSncTHea_DD
                                Send Activate          of oFromField_cf
                            End_Procedure
        
                            Function IsEnabled Returns Boolean
                                Boolean bFromOpen bToOpen                           
                                Get_Attribute DF_FILE_OPENED of giFromFile to bFromOpen
                                Get_Attribute DF_FILE_OPENED of giToFile   to bToOpen
                                Function_Return (bFromOpen = True and bToOpen = True)    
                            End_Function
                            
                        End_Object
        
                        Object oFirst_bn is a cRDCButton 
                            Set Location to 82 288
                            Set Size to 17 23
                            Set psTooltip to "Find the first transformation table (Ctrl+Home)"
                            Set psImage to "ActionFirst.ico" 
                            Set piImageSize to 24
                            Set peAnchors to anTopRight
        
                            Procedure OnClick
                                Send DoFindRecord of oSncTHea_DD -1
                            End_Procedure
        
                            Function IsEnabled Returns Boolean
                                Boolean bFromOpen bToOpen                           
                                Get_Attribute DF_FILE_OPENED of giFromFile to bFromOpen
                                Get_Attribute DF_FILE_OPENED of giToFile   to bToOpen
                                Function_Return (bFromOpen = True and bToOpen = True)    
                            End_Function
                            
                        End_Object
        
                        Object oPrev_bn is a cRDCButton
                            Set Location to 82 312
                            Set Size to 17 23
                            Set psToolTip to "Find previous conversion table (F7)"
                            Set psImage to "ActionPrevious.ico"
                            Set piImageSize to 24
                            Set peAnchors to anTopRight
                            
                            Procedure OnClick
                                Send DoFindRecord of oSncTHea_DD LT
                            End_Procedure
        
                            Function IsEnabled Returns Boolean
                                Boolean bFromOpen bToOpen                           
                                Get_Attribute DF_FILE_OPENED of giFromFile to bFromOpen
                                Get_Attribute DF_FILE_OPENED of giToFile   to bToOpen
                                Function_Return (bFromOpen = True and bToOpen = True)    
                            End_Function
                            
                        End_Object
        
                        Object oNext_bn is a cRDCButton
                            Set Location to 82 336
                            Set Size to 17 23
                            Set psTooltip to "Find next conversion table (F8)"
                            Set psImage to "ActionFind.ico"
                            Set piImageSize to 24
                            Set peAnchors to anTopRight
                            
                            Procedure OnClick
                                Send DoFindRecord of oSncTHea_DD GT
                            End_Procedure
        
                            Function IsEnabled Returns Boolean
                                Boolean bFromOpen bToOpen                           
                                Get_Attribute DF_FILE_OPENED of giFromFile to bFromOpen
                                Get_Attribute DF_FILE_OPENED of giToFile   to bToOpen
                                Function_Return (bFromOpen = True and bToOpen = True)    
                            End_Function
                            
                        End_Object
        
                        Object oLast_bn is a cRDCButton
                            Set Location to 82 360
                            Set Size to 17 23
                            Set psTooltip to "Find the last conversion table (Ctrl+End)"
                            Set psImage to "ActionLast.ico"
                            Set piImageSize to 24
                            Set peAnchors to anTopRight
        
                            Procedure OnClick
                                Send DoFindRecord of oSncTHea_DD -2
                            End_Procedure
        
                            Function IsEnabled Returns Boolean
                                Boolean bFromOpen bToOpen                           
                                Get_Attribute DF_FILE_OPENED of giFromFile to bFromOpen
                                Get_Attribute DF_FILE_OPENED of giToFile   to bToOpen
                                Function_Return (bFromOpen = True and bToOpen = True)    
                            End_Function
                            
                        End_Object 
        
                        Object oSaveValueTable_bn is a cRDCButton
                            Set Label to "Save Value Table"
                            Set Size to 14 96
                            Set Location to 104 288
                            Set Status_Help to "Save changes to the current Transformation Table"
                            Set psImage to "ActionSave.ico"
                            Set peAnchors to anTopRight
                            
                            Procedure OnClick
                                Send Request_Save of oSncTHea_DD
                                Send Activate of oFromField_cf // Do not stay in the grid.
                            End_Procedure
        
                            Function IsEnabled Returns Boolean
                                Boolean bShould_Save                  
                                Get Should_Save of oSncthea_DD to bShould_Save
                                Function_Return (bShould_Save = True)    
                            End_Function
                            
                        End_Object
        
                        Object oDeleteValueTable_bn is a cRDCButton
                            Set Label to "D&elete Value Table"
                            Set Size to 14 96
                            Set Location to 120 288
                            Set Status_Help to "Delete current Transformation Table"
                            Set psImage to "ActionDelete.ico"
                            Set peAnchors to anTopRight
                            
                            Procedure OnClick
                                Integer iRecord hoDD iRetval
                                Move (oSncTHea_DD(Self)) to hoDD
                                Get pbGetHasCurrRowId of hoDD to iRecord
                                If (not(iRecord)) Begin
                                    Send Info_Box "No Value Transformation table to delete."
                                    Procedure_Return
                                End
                                Get YesNo_Box "Are you sure you want to delete the current Value Transformation table?" to iRetval
                                If (iRetval = MBR_NO) Begin
                                    Procedure_Return
                                End
                                Send Request_Delete    of oSncThea_DD  // Will delete header and all rows
                                Send DoCreateNewRecord of oSncThea_DD  // Init DDO's for creating a new record.
                                Send Activate of oFromField_cf        // Do not stay in the grid.
                            End_Procedure
        
                            Function IsEnabled Returns Boolean
                                Boolean bFromOpen bToOpen                           
                                Get_Attribute DF_FILE_OPENED of giFromFile to bFromOpen
                                Get_Attribute DF_FILE_OPENED of giToFile   to bToOpen
                                Function_Return (bFromOpen = True and bToOpen = True)    
                            End_Function
                            
                        End_Object
        
                        Object oSnctable_Sncthea_Count is a cRDCDbForm
                            Entry_Item SncTable.SncTHea_Count
                            Set Label to "No of Conversion Tables"
                            Set Size to 13 18
                            Set Location to 140 366
                            Set peAnchors to anTopRight
        
                            Procedure Set Enabled_State Boolean bState
                                Forward Set Enabled_State to False
                            End_Procedure
                        End_Object
        
        //                Procedure DoEnableDisable Integer iValue
        //                    Handle ho
        //                    Set Enabled_State                                                       to iValue
        //                    Set Enabled_State of oInfoValue_tb                                      to iValue
        //                    Set Enabled_State of (Label_Object(oSnctable_FromdataTable_Conv(Self))) to iValue
        //                    Set Enabled_State of (Label_Object(oSnctable_Sncthea_Count(Self)))      to iValue
        //                    Set Enabled_State of oNewValueTable_bn                                  to iValue
        //                    Set Enabled_State of oDeleteValueTable_bn                               to iValue
        //                    Move (oSncTRow_Grid(Self)) to ho
        //                    If (Enabled_State(Self)) Begin
        //                        Set Color of ho to clWindow
        //                    End
        //                    Else Begin
        //                        Set Color of ho to clLtGray
        //                    End
        //                End_Procedure
        
                    End_Object
        
                    Property String psFromDataTable
                    Property String psToDataTable    
                    Property Boolean pbRefreshDone False
                    
                    Procedure Refresh Integer eMode
                        String sFromDataTable sToDataTable
                        Integer iSynchType
                        Handle hoDD
                        
                        Forward Send Refresh eMode
                        Move (Main_DD(Self)) to hoDD
                        Get Field_Current_Value of hoDD Field SncTable.FromDataTable to sFromDataTable 
                        Get Field_Current_Value of hoDD Field SncTable.ToDataTable   to sToDataTable 
                        Set psFromDataTable to sFromDataTable
                        Set psToDataTable   to sToDataTable
                        Set pbRefreshDone   to True // Tells the DoTimerUpdate message that data might need to be refreshed.
                        Send DoTimerUpdate
                    End_Procedure
        
                    Object oValueConversionIdleHandler is a cIdleHandler
                        Set pbEnabled to False
                        Procedure OnIdle
                            Delegate Send DoTimerUpdate
                        End_Procedure
                    End_Object     
                    
                    // Enable the idle handler timer when the tab-page is activated
                    Procedure OnEnterArea Handle hoFrom
                        Set pbEnabled of oValueConversionIdleHandler to True
                    End_Procedure
                
                    // Disable the idle handler when the tab-page is deactivated
                    Procedure OnExitArea Handle hoFrom
                        Set pbEnabled of oValueConversionIdleHandler to False
                    End_Procedure
                    
                    Procedure DoTimerUpdate  
                        String sFromDataTable sToDataTable sFromDataTableLocal sToDataTableLocal
                        Integer iFromFile iToFile iSncTHea_Count
                        Handle hoDD ho                   
                        Boolean bShouldRefresh bRefreshDone bFromFileOpen bToFileOpen
        
                        Move False to bFromFileOpen
                        Move False to bToFileOpen
                        Move (Main_DD(Self)) to hoDD
                        Get Field_Current_Value of hoDD Field SncTable.FromDataTable to sFromDataTable
                        Get Field_Current_Value of hoDD Field SncTable.ToDataTable   to sToDataTable 
                        Get psFromDataTable to sFromDataTableLocal
                        Get psToDataTable   to sToDataTableLocal
                        Get pbRefreshDone   to bRefreshDone
                        
                        If (bRefreshDone = False) Begin
                            Move (sFromDataTable <> sFromDataTableLocal or sToDataTable <> sToDataTableLocal) to bShouldRefresh
                        End 
                        Else Begin
                            Move True to bShouldRefresh 
                        End    
                        
                        If (not(IsComObjectCreated(oSncTRow_Grid(Self)))) Begin
                            Procedure_Return
                        End
                        
                        If (bShouldRefresh = True) Begin     
                            Move giFromFile to iFromFile
                            Get_Attribute DF_FILE_OPENED of iFromFile to bFromFileOpen 
                            If (bFromFileOpen = False) Begin
                                Get RDSOpenAsFile hoDD True False to bFromFileOpen
                            End 
                            Move giToFile to iToFile
                            Get_Attribute DF_FILE_OPENED of iToFile to bToFileOpen
                            If (bToFileOpen = False) Begin
                                Get RDSOpenAsFile hoDD False False to bToFileOpen 
                            End                    
                            // If table is not open, it means that the refresh message has got us here and
                            // the tables have not yet been opened by the two cDbComboformDataTable objects.
                            // If so, we wait until they have been.
                            If (bFromFileOpen = False or bToFileOpen = False) Begin
                                Procedure_Return
                            End
                            
                            Set pbRefreshDone   to False
                            Set psFromDataTable to sFromDataTable
                            Set psToDataTable   to sToDataTable
                            Get Field_Current_Value of hoDD Field SncTable.SncTHea_Count to iSncTHea_Count
                            Broadcast Recursive Send DoUpdateData iFromFile iToFile True
                            Broadcast Recursive Send DoUpdateData iFromFile iToFile False                 
                            If (iSncTHea_Count <> 0) Begin    
                                Send Ignore_Error of Error_Object_Id 4402
                                Send DoFindRecord of oSncTHea_DD -1    
                                Send Trap_Error of Error_Object_Id 4402
                            End
                        End
                    End_Procedure
        
                End_Object
        
                Object oMarkSourceRows_tp is a dbTabPage
                    Set Label to "Mark Source Rows"
                    Set Tab_ToolTip_Value to "Set field values for the source table records when a new Target record is created"
                    Set piImageIndex to 6
        
                    Object oFlagField_grp is a cRDCHeaderDbGroup
                        Set Size to 253 395
                        Set Location to 7 7
                        Set Label to "Mark fields for the Source Table"
                        Set psNote to "When a Target record is updated, a Source field/column can be changed/updated"
                        Set psImage to "MarkRows.ico"
                        Set peAnchors to anAll
        
                        Property String psFuncDateTxt     "Today's Date"
                        Property String psFuncDate        "##1##"
                        Property String psFuncTimeTxt     "Current Time"
                        Property String psFuncTime        "##2##"
                        Property String psFuncDateTimeTxt "Today's Date and Current Time"
                        Property String psFuncDateTime    "##3##"
        
                        Object oFieldsMark_cf is a cDbFieldComboform
                            Set Label to "Field Name"
                            Set Size to 14 103
                            Set Location to 38 10
                            Set Status_Help to "Available Fields/columns for the selected Source data table"
                            Set pbFrom to True
                            Set Label_Justification_Mode to JMode_Top
                            Set Label_Col_Offset to 0
                            Set Label_Row_Offset to 1
        
                            Procedure OnChange
                                Handle hoList
                                String sType sField
                                Integer iLength iPrec iField iFile iType iOpen
        
                                Move -1 to iType
                                Get Value Item 0    to sField
                                Get FileFieldNumber to iField     // Class function.
                                Move (Trim(sField)) to sField
                                If (sField contains CS_None or sField = "") Begin
                                    Set Value   of oValueFunction_cf to ""
                                    Set Value   of oTypeMark_fm to ""
                                    Set Value   of oLengthMark_fm to ""
                                    Set Enabled_State of oSelectMark_bn to False
                                    Procedure_Return
                                End
        
                                Move giFromFile to iFile
                                Get_Attribute DF_FILE_OPENED of iFile to iOpen
                                If (not(iOpen)) Begin
                                    Procedure_Return
                                End
        
                                Get_Attribute DF_FIELD_TYPE      of iFile iField  to iType
                                Get_Attribute DF_FIELD_LENGTH    of iFile iField  to iLength
                                Get_Attribute DF_FIELD_PRECISION of iFile iField  to iPrec
                                If (iType = DF_BCD) Begin
                                    Move (iLength - iPrec)       to iLength
                                End
                                Else Begin
                                    Move 0 to iPrec
                                End
                                Get_Attribute DF_FIELD_NAME of iFile iField to sField
                                Get UpperFirstChar sField                   to sField
                                Get FieldType iType                         to sType
                                Set Value of oTypeMark_fm                   to sType
                                Set Value of oLengthMark_fm                 to (String(iLength) + "," + String(iPrec))
                                Move (oFlags_lst(Self))                     to hoList
                                Set psField of hoList                       to sField
                                Set piType of hoList                        to iType
                                Set piLength of hoList                      to iLength
                                Set Enabled_State of oSelectMark_bn         to True
                            End_Procedure
        
                            // This is a dbComboform but not attached to a db field.
                            // We kill these two procedures so the DDO doesn't get triggered:
                            Procedure Set Changed_Value Integer iField String sValue
                            End_Procedure
                            Procedure Set Changed_State Boolean bState
                            End_Procedure
                        End_Object
        
                        Object oValueFunction_cf is a cRDCForm
                            Set Label to "Value"
                            Set Size to 14 122
                            Set Location to 38 208
                            Set Status_Help to "Enter a value to set the selected field/column to."
                            Set Label_Col_Offset to 0
                            Set Label_Justification_Mode to JMode_Top
                            Set Label_Row_Offset to 1
        
                            Procedure OnChange
                                String sValue
                                Get Value Item 0    to sValue
                                Move (Trim(sValue)) to sValue
                                If      (sValue = (psFuncDateTxt(Self))) Begin
                                    Move (psFuncDate(Self))     to sValue // dbGroup properties.
                                End
                                Else If (sValue = (psFuncTimeTxt(Self))) Begin
                                    Move (psFuncTime(Self))     to sValue
                                End
                                Else If (sValue = (psFuncDateTimeTxt(Self))) Begin
                                    Move (psFuncDateTime(Self)) to sValue
                                End
                                Set psValue of oFlags_lst to sValue
                            End_Procedure
        
                        End_Object
        
                        Object oTypeMark_fm is a cRDCForm
                            Set Label to "Type"
                            Set Size to 14 44
                            Set Location to 38 118
                            Set Status_Help to "The selected field/column type"
                            Set Label_Col_Offset to 0
                            Set Label_Justification_Mode to JMode_Top
                            Set Enabled_State to False
                            Set Label_Row_Offset to 1
        
                            Procedure Set Enabled_State Boolean bState
                                Forward Set Enabled_State to False
                            End_Procedure
                        End_Object
        
                        Object oLengthMark_fm is a cRDCForm
                            Set Label to "Length"
                            Set Size to 14 33
                            Set Location to 38 169
                            Set Status_Help to "The selected field/column length and precision"
                            Set Label_Col_Offset to 0
                            Set Label_Justification_Mode to JMode_Top
                            Set Enabled_State to False
                            Set Label_Row_Offset to 1
        
                            Procedure Set Enabled_State Boolean bState
                                Forward Set Enabled_State to False
                            End_Procedure
                        End_Object
        
                        Object oFlags_lst is a cCJGrid
                            Set Size to 157 322
                            Set Location to 62 10
                            Set psNoItemsText to "No data found..."
                            Set pbRestoreLayout to True
                            Set psLayoutSection to (Name(Self) + "_grid")
                            Set pbShowRowFocus to True
                            Set pbAllowEdit to False
                            Set pbAutoAppend to False
                            Set pbAllowAppendRow to False
                            Set pbAllowInsertRow to False
                            Set pbAllowColumnRemove to False
                            Set pbAllowColumnReorder to False
                            Set pbAllowColumnResize to False
                            Set pbEditOnTyping to False
                            Set pbSelectionEnable to True
                            Set pbUseAlternateRowBackgroundColor to True
                            Set piSelectedRowBackColor to clGreenGreyLight
                            Set piHighlightBackColor   to clGreenGreyLight
                            Set pbShowFooter to True
                            Set peAnchors to anTopBottom
        
                            Object oFlags_col is a cCJGridColumn
                                Set piWidth to 620
                                Set psCaption to "Selected Fields and Values"
                                Set psToolTip to "List with Source data table fields that should be updated with specified values during a connection with a Target data table. Press Del or Ctrl+X to remove an item"
                                Set psFooterText to "No of Selections:"
                            End_Object
        
                            Property Integer piType  -1
                            Property String  psField ""
                            Property String  psValue ""
                            Property Integer piLength 0
        
                            Procedure DoAddToList Boolean bUpdate
                                Integer iType iLength
                                String sTable sField sValue sText sFlags
        
                                Get piType to iType
                                Get piLength to iLength
                                Get Field_Current_Value of (Main_DD(Self)) Field SncTable.Fromdatatable to sTable
                                Get StripExt sTable to sTable
                                Get psField to sField
                                Get psValue to sValue
                                Move ("Source Row Field Value" * String(sTable) + "." + String(sField) + " = ") to sText
                                If (sValue = psFuncDate(Self)) Begin
                                    Get psFuncDateTxt to sFlags
                                End
                                Else If (sValue = psFuncTime(Self)) Begin
                                    Get psFuncTimeTxt to sFlags
                                End
                                Else If (sValue = psFuncDateTime(Self)) Begin
                                    Get psFuncDateTimeTxt to sFlags
                                End
                                Else Begin
                                    Move sValue to sFlags
                                End
        
                                If (iType = DF_ASCII or iType = DF_TEXT) Begin
                                    If (sValue = psFuncDate(Self) and iLength < 10) Begin
                                        Send Info_Box "The length of the field/column needs to be at least 10 characters for this function."
                                        If (iLength < 10) Begin
                                            Procedure_Return
                                        End
                                    End
                                    If (sValue = psFuncTime(Self) and iLength < 8) Begin
                                        Send Info_Box "The length of the field/column needs to be at least 8 characters for this function."
                                        Procedure_Return
                                    End
                                    If (sValue = psFuncDateTime(Self) and iLength < 19) Begin
                                        Send Info_Box "The length of the field/column needs to be at least 19 characters for this function."
                                        Procedure_Return
                                    End
                                    Move (sText * '"' + String(sFlags) + '"') to sText
                                End
                                Else Begin
                                    If (iType <> DF_DATE and sValue = psFuncDate(Self)) Begin
                                        Send Info_Box "The selected function can only be applied to a field/column of type Ascii, Text or Date."
                                        Procedure_Return
                                    End
                                    Else If (sValue = psFuncDateTime(Self) or sValue = psFuncDateTime(Self)) Begin
                                        Send Info_Box "The selected function can only be applied to a field/column of type Ascii."
                                        Procedure_Return
                                    End
                                    If (Trim(sFlags) = "") Begin
                                        Move 0 to sFlags
                                    End
                                    Move (sText * String(sFlags)) to sText
                                End
                                Send AddItem sText
                                If (bUpdate = True) Begin
                                    Send DoUpdateDDBuffer
                                End
                            End_Procedure
        
                            Procedure AddItem String sConstraint
                                Handle hoDataSource
                                tDataSourceRow[] TheData
                                Integer iSize iDataCol
                        
                                If (not(IsComObjectCreated(Self))) Begin
                                    Procedure_Return
                                End
                                Get piColumnId of oFlags_col to iDataCol
                                Get phoDataSource to hoDataSource
                                Get DataSource of hoDataSource to TheData
                                Move (SizeOfArray(TheData)) to iSize
                                Move sConstraint to TheData[iSize].sValue[iDataCol]
                                Send ReInitializeData TheData False
                            End_Procedure
        
                            // Returns number of items.
                            Function ItemCount Returns Integer
                                Integer iItems
                                Handle hoDataSource
                                tDataSourceRow[] TheData
                        
                                Get phoDataSource to hoDataSource
                                Get DataSource of hoDataSource to TheData
                                Move (SizeOfArray(TheData)) to iItems
                        
                                Function_Return iItems
                            End_Function
        
                            Procedure DoDeleteItem
                                Integer iItem
                                Get ItemCount to iItem
                                If (not(iItem)) Begin
                                    Procedure_Return
                                End
                                Send Request_Delete 
                                Send MoveToFirstRow
                                Send DoUpdateDDBuffer
                            End_Procedure  
                            
                            Function Value Integer iItem Returns String
                                Handle hoDataSource                   
                                Integer iCol
                                tDataSourceRow[] TheData       
                                String sValue
                                
                                If (iItem < 0) Begin
                                    Function_Return ""
                                End                   
                                Move "" to sValue
                                Get piColumnId of oFlags_col to iCol
                                Get phoDataSource to hoDataSource
                                Get DataSource of hoDataSource to TheData
                                If (SizeOfArray(TheData) <> 0) Begin
                                    Move TheData[iItem].sValue[iCol] to sValue
                                End
                        
                                Function_Return sValue
                            End_Function
                            
                            Procedure Delete_Data  
                                If (not(IsComObjectCreated(Self))) Begin
                                    Procedure_Return
                                End
                                Send ResetGrid
                                Set psFooterText of oFlags_col to ("No of Selections:")
                            End_Procedure   
                            
                            Procedure Add_Focus Handle hoParent Returns Integer
                                Forward Send Add_Focus hoParent
                                Send DoFillList
                            End_Procedure
        
                            Procedure DoDeleteItem
                                Integer iItem
                                Get ItemCount to iItem
                                If (not(iItem)) Begin
                                    Procedure_Return
                                End
                                Send Request_Delete 
                                Send MoveToFirstRow
                                Send DoUpdateDDBuffer
                            End_Procedure  
        
                            Procedure DoFillList
                                Handle hoDD
                                Boolean bTableChanged
                                Integer iCount iFile iField iType iFlags iOpen
                                String sTable sField sFlags sValue
        
                                If (not(IsComObjectCreated(Self))) Begin
                                    Procedure_Return
                                End
        
                                Send Delete_Data
                                Delegate Get Main_DD to hoDD
                                Get Field_Current_Value of hoDD Field SncTable.SynchFlags to sFlags
                                Move (Trim(sFlags)) to sFlags
                                If (Length(sFlags) = 0) Begin
                                    Procedure_Return
                                End
                                Move (sFlags + "|") to sFlags // Format: "Field_Number|Mode|Value"
                                Move giFromFile to iFile
                                Get_Attribute DF_FILE_OPENED of iFile to iOpen
                                If (not(iOpen)) Begin
                                    Procedure_Return
                                End
        
                                // This will take care of a special situation.
                                // The user has created a record and has also specified Selfields, he then changes the
                                // datatable comboform to another table...
                                Get Field_Changed_State of hoDD Field SncTable.FromDataTable to bTableChanged
                                If (bTableChanged = True) Begin
                                    // Reset DDO buffer value in case user saves the new config.
                                    Set Field_Changed_Value of hoDD Field SncTable.SynchFlags to ""
                                    Procedure_Return
                                End
        
                                Get Field_Current_Value of hoDD Field SncTable.Fromdatatable  to sTable
                                Get StripExt sTable                                           to sTable
                                Get Field_Current_Value of hoDD Field SncTable.SynchFlagCount to iFlags
        
                                For iCount from 1 to iFlags
                                    Get ExtractValue sFlags " "                               to iField // Extract Field Value. (From SyncFuncs.pkg)
                                    Move (Replace((String(iField) + " "), sFlags, ""))        to sFlags
                                    Get_Attribute DF_FIELD_NAME of iFile iField               to sField
                                    Get UpperFirstChar sField                                 to sField
                                    Set psField                                               to sField
                                    Get_Attribute DF_FIELD_TYPE of iFile iField               to iType
                                    Set piType                                                to iType
                                    Get ExtractValue sFlags "|"                               to sValue
                                    Move (Replace((sValue + "|"), sFlags, ""))                to sFlags
                                    If (sValue = psFuncDate(Self)) Begin
                                        Move (psFuncDateTxt(Self))  to sValue
                                    End
                                    Else If (sValue = psFuncTime(Self)) Begin
                                        Move (psFuncTimeTxt(Self))  to sValue
                                    End
                                    Else If (sValue = psFuncDateTime(Self)) Begin
                                        Move (psFuncDateTime(Self)) to sValue
                                    End
                                    Set psValue to sValue
                                    Send DoAddToList False
                                Loop  
                                Set psFooterText of oFlags_col to ("No of Selections:" * String(SncTable.SynchFlagCount)) 
                                Send MoveToFirstRow
                            End_Procedure
        
                            Procedure DoUpdateDDBuffer
                                Handle hoDD
                                Integer iCount iFile iField iPos iItems
                                String sTable sField sFlags sValue sText
        
                                Delegate Get Main_DD to hoDD
                                Move giFromFile  to iFile
                                Get ItemCount to iItems
                                For iCount from 0 to (iItems - 1)
                                    Get Value Item iCount                        to sText
                                    Move (sText + " ")                           to sText
                                    Move (Pos(".", sText))                       to iPos
                                    Move (Left(sText, iPos))                     to sTable   // Table:
                                    Move (Replace(sTable, sText, ""))            to sText
                                    Get ExtractValue sText " "                   to sField   // Function in SysFuncs.pkg
                                    Field_Map iFile sField                       to iField   // Field:
                                    Move (Replace((sField + " "), sText, ""))    to sText
                                    Move (Pos("=", sText))                       to iPos
                                    Move (Right(sText, (Length(sText) - iPos)))  to sText
                                    Move sText                                   to sValue
                                    Move (Replace((sValue + " "), sText, ""))    to sText
                                    Move (Replaces('"', sValue, ''))             to sValue   // Value
                                    Move (Trim(sValue))                          to sValue
                                    If (sValue = psFuncDateTxt(Self)) Begin
                                        Move (psFuncDate(Self)) to sValue
                                    End
                                    Else If (sValue = psFuncTimeTxt(Self)) Begin
                                        Move (psFuncTime(Self)) to sValue
                                    End
                                    Else If (sValue = psFuncDateTimeTxt(Self)) Begin
                                        Move (psFuncDateTime(Self)) to sValue
                                    End
                                    Move (String(iField) * String(sValue)) to sText
                                    If (iCount < (iItems -1)) Begin
                                        Move (sText + "|") to sText
                                    End
                                    Move (sFlags + String(sText)) to sFlags
                                Loop
                                
                                Get Field_Current_Value of hoDD Field SncTable.SynchFlags     to sText
                                Move (Trim(sText))                                            to sText
                                Get Field_Current_Value of hoDD Field SncTable.SynchFlagCount to iCount
                                If (sText <> sFlags) Begin
                                    Set Field_Changed_Value of hoDD Field SncTable.SynchFlags to sFlags
                                    Set Field_Changed_Value of hoDD Field SncTable.SynchFlagCount to iItems
                                End
                            End_Procedure
        
                        End_Object
                        Object oSelectMark_bn is a cRDCButton
                            Set Label to "Add"
                            Set Location to 38 337
                            Set Status_Help to "Add the entered selection to the list below"
                            Set psImage to "ActionAddButton.ico"
        
                            Procedure OnClick
                                Handle ho
                                String sValue sField
                                Integer iType iRetval
        
                                Move (oFlags_lst(Self)) to ho
                                Get piType  of ho to iType
                                Get psValue of ho to sValue
                                Get psField of ho to sField
                                If (sField = "") Begin
                                    Send Info_Box "You need to select a field first."
                                    Procedure_Return
                                End
                                Get psValue of ho to sValue
                                If (iType = DF_DATE or iType = DF_BCD) Begin
                                    Get IsNumeric sValue to iRetval
                                    If (not(iRetval)) Begin
                                        Send Info_Box "Value should be numeric."
                                        Procedure_Return
                                    End
                                End
                                Send DoAddToList of ho True
                            End_Procedure
        
                            Procedure DoEnableDisable Integer iValue
                                String sTable sField
                                Integer iFile iOpen
        
                                Get psField of oConstraints_lst to sField
                                Move giFromFile to iFile
                                Get Field_Current_Value of (Main_DD(Self)) Field SncTable.FromDataTable to sTable
                                Move (Rtrim(sTable)) to sTable
                                Get_Attribute DF_FILE_OPENED of iFile to iOpen
                                Set Enabled_State to (Length(sField) > 0 and Length(sTable) > 0 and iOpen)
                            End_Procedure
        
                            Procedure DoCheckClear
                                Send DoEnableDisable 0
                            End_Procedure
                        End_Object
        
                        Procedure DoUpdateData Integer iFromFile Integer iToFile Boolean bFrom
                            Handle ho
                            String sTable
                            Integer iOpen
        
                            Get Field_Current_Value of (Main_DD(Self)) Field SncTable.Fromdatatable to sTable
                            If iFromFile Begin
                                Get_Attribute DF_FILE_OPENED of iFromFile to iOpen
                            End
                            Set Enabled_State  to (Length(sTable) > 0 and iOpen)
                            Move (oFlags_lst(Self)) to ho
                            Send DoFillList of ho
        //                    Set Enabled_State of (Label_Object(oSnctable_FromdataTable_Mark)) to (Length(sTable) > 0 and iOpen)
        //                    Set Enabled_State of (Label_Object(oTypeMark_fm))                 to (Length(sTable) > 0 and iOpen)
        //                    Set Enabled_State of (Label_Object(oLengthMark_fm))               to (Length(sTable) > 0 and iOpen)
                        End_Procedure
        
                        Object oDeleteFieldValue_bn is a cRDCButton
                            Set Label to "Delete"
                            Set Location to 73 337
                            Set Status_Help to "Delete the currently selected field and value"
                            Set psImage to "ActionDelete.ico"
                            
                            Procedure OnClick
                                Integer iItem       
                                Handle hoList
                                Move (oFlags_lst(Self)) to hoList
                                Send DoDeleteItem of hoList 
                            End_Procedure
        
                            Function IsEnabled Returns Boolean
                                Boolean bFromOpen bToOpen                           
                                Get_Attribute DF_FILE_OPENED of giFromFile to bFromOpen
                                Get_Attribute DF_FILE_OPENED of giToFile   to bToOpen
                                Function_Return (bFromOpen = True and bToOpen = True)    
                            End_Function
                            
                        End_Object
        
                        On_Key Key_Alt+Key_S Send KeyAction of oSelectMark_bn
                        On_Key Key_Alt+Key_V Send KeyAction of oViewFromData_bn
                    End_Object
        
                    Property String psFromDataTable
                    Property String psToDataTable    
                    Property Boolean pbRefreshDone False
                    
                    Procedure Refresh Integer eMode
                        String sFromDataTable sToDataTable
                        Integer iSynchType
                        Handle hoDD
                        
                        Forward Send Refresh eMode
                        Move (Main_DD(Self)) to hoDD
                        Get Field_Current_Value of hoDD Field SncTable.FromDataTable to sFromDataTable 
                        Get Field_Current_Value of hoDD Field SncTable.ToDataTable   to sToDataTable 
                        Set psFromDataTable to sFromDataTable
                        Set psToDataTable   to sToDataTable
                        Set pbRefreshDone   to True // Tells the DoTimerUpdate message that data might need to be refreshed.
                        Send DoTimerUpdate
                    End_Procedure
        
                    Object oMarkSourceRowsIdleHandler is a cIdleHandler
                        Set pbEnabled to False
                        Procedure OnIdle
                            Delegate Send DoTimerUpdate
                        End_Procedure
                    End_Object     
                    
                    // Enable the idle handler timer when the tab-page is activated
                    Procedure OnEnterArea Handle hoFrom
                        Set pbEnabled of oMarkSourceRowsIdleHandler to True
                    End_Procedure
                
                    // Disable the idle handler when the tab-page is deactivated
                    Procedure OnExitArea Handle hoFrom
                        Set pbEnabled of oMarkSourceRowsIdleHandler to False
                    End_Procedure
                    
                    Procedure DoTimerUpdate  
                        String sFromDataTable sToDataTable sFromDataTableLocal sToDataTableLocal
                        Integer iFromFile iToFile
                        Handle hoDD ho                   
                        Boolean bShouldRefresh bRefreshDone bFromFileOpen bToFileOpen
        
                        Move False to bFromFileOpen
                        Move False to bToFileOpen
                        Move (Main_DD(Self)) to hoDD
                        Get Field_Current_Value of hoDD Field SncTable.FromDataTable to sFromDataTable
                        Get Field_Current_Value of hoDD Field SncTable.ToDataTable   to sToDataTable 
                        Get psFromDataTable to sFromDataTableLocal
                        Get psToDataTable   to sToDataTableLocal
                        Get pbRefreshDone   to bRefreshDone
                        
                        If (bRefreshDone = False) Begin
                            Move (sFromDataTable <> sFromDataTableLocal or sToDataTable <> sToDataTableLocal) to bShouldRefresh
                        End 
                        Else Begin
                            Move True to bShouldRefresh 
                        End    
                        
                        If (bShouldRefresh = True) Begin     
                            Move giFromFile to iFromFile
                            Get_Attribute DF_FILE_OPENED of iFromFile to bFromFileOpen 
                            If (bFromFileOpen = False) Begin
                                Get RDSOpenAsFile hoDD True False to bFromFileOpen
                            End 
                            Move giToFile to iToFile
                            Get_Attribute DF_FILE_OPENED of iToFile to bToFileOpen
                            If (bToFileOpen = False) Begin
                                Get RDSOpenAsFile hoDD False False to bToFileOpen 
                            End                    
                            
                            Set pbRefreshDone   to False
                            Set psFromDataTable to sFromDataTable
                            Set psToDataTable   to sToDataTable
                            Broadcast Recursive Send DoUpdateData iFromFile iToFile True
                        End
                    End_Procedure
        
                End_Object
        
                Object oOther_tp is a dbTabPage
                    Set Label to "Notes"
                    Set Tab_ToolTip_Value to "To write notes about the connection."
                    Set piImageIndex to 7
        
                    Procedure DoUpdateData Integer iFromFile Integer iToFile Boolean bFrom
                        Set Enabled_State of oSnctable_Checkintegrity to (iFromFile and iToFile)
                        Set Enabled_State of oSnctable_Notes          to (iFromFile and iToFile)
                    End_Procedure
        
                    Object oNotes_grp is a cRDCHeaderDbGroup
                        Set Size to 253 395
                        Set Location to 7 7
                        Set Label to "Notes"
                        Set psNote to "Save comments about the current connection record here"
                        Set psImage to "Notes.ico"
                        Set peAnchors to anAll
        
                        Object oSnctable_Notes is a cDbTextEdit
                            Entry_Item Snctable.Notes
                            Set Size to 157 322
                            Set Location to 62 10
                            Set peAnchors to anTopBottom
                            On_Key Key_Ctrl+Key_S Send Request_Save
                        End_Object
        
                        Object oSnctable_Datetime is a cRDCDbForm
                            Entry_Item Snctable.Date_Time
                            Set Label to "Record Created"
                            Set Size to 13 73
                            Set Location to 38 10
                            Set peAnchors to anNone
                            Set Label_Justification_Mode to JMode_Top
                            Set Label_Col_Offset to 0
                            Set Label_Row_Offset to 1
                        End_Object

                        Object oSnctable_Createdby is a cRDCDbForm
                            Entry_Item SncTable.Createdby
                            Set Label to "By"
                            Set Size to 13 78
                            Set Location to 38 89
                            Set peAnchors to anNone
                            Set Label_Col_Offset to 0
                            Set Label_Justification_Mode to JMode_Top
                            Set Label_Row_Offset to 1
                        End_Object

                        Object oSnctable_Lastedited is a cRDCDbForm
                            Entry_Item SncTable.Lastedited
                            Set Label to "Last Edited"
                            Set Size to 13 73
                            Set Location to 38 172
                            Set peAnchors to anNone
                            Set Label_Col_Offset to 0
                            Set Label_Justification_Mode to JMode_Top
                            Set Label_Row_Offset to 1
                        End_Object

                        Object oSnctable_Editedby is a cRDCDbForm
                            Entry_Item Snctable.Editedby
                            Set Label to "By"
                            Set Size to 13 78
                            Set Location to 38 251
                            Set peAnchors to anNone
                            Set Label_Col_Offset to 0
                            Set Label_Justification_Mode to JMode_Top
                            Set Label_Row_Offset to 1
                        End_Object
        
                    End_Object
        
                End_Object
        
            End_Object

        End_Object

    End_Object


End_Object 

// General purpose access method for this view, to show the passed
// SncTable.ID record.
Procedure DisplaySncTableIDRecord Integer iID
    Handle ho hoDD
    Move (oRdcView(Self)) to ho
    Get Main_DD of ho to hoDD
    Send Request_Clear of hoDD
    Move iID to SncTable.ID
    Send Request_Find of hoDD EQ SncTable.File_Number 1
    Send Switch_Next_View    
End_Procedure
