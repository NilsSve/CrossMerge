Use cRDCDbView.pkg
Use cDbCJGrid.pkg 
Use cRDCDbCJGrid.pkg
Use cRDCDbCJGridColumn.pkg
Use cCJGridColumnRowIndicator.pkg
Use cDbTextEdit.pkg
Use cRDCHeaderDbGroup.pkg
Use cRDCDbForm.pkg
Use cRDCForm.pkg
Use cRDCButton.pkg
Use cZeroLogBn.pkg

Use SncLog.dd

Activate_View Activate_oConnectViewLog For oConnectViewLog
Object oConnectViewLog is a cRDCDbView
    Set Label to "View Log"
    Set Size to 346 495
    Set piMinSize to 256 495
    Set Location to 2 0
    Set Icon to "Report.ico"
    Set Border_Style to Border_Thick
    Set Locate_Mode to Center_On_Parent

    Object oSnclog_DD is a Snclog_DataDictionary
    End_Object

    Set Main_DD to oSnclog_DD
    Set Server to oSnclog_DD

    Object oLogRecords_grp is a cRDCHeaderDbGroup
        Set Size to 187 470
        Set Location to 8 13
        Set Label to "Log Records"               
        Set psNote to "View Log records created by the CrossMerge Engine"
        Set psImage to "Report.ico"
        Set peAnchors to anAll

        Object oSncLog_grd is a cRDCDbCJGrid
            Set Size to 148 446
            Set Location to 30 12
//            Set peAnchors to anAll
            Set pbAllowEdit to False
//            Set pbAllowDeleteRow to False
//            Set pbAllowInsertRow to False
//            Set pbAutoAppend to False
            Set pbEditOnTyping to False
//            Set pbHeaderReorders to True
//            Set pbHeaderTogglesDirection to True
            Set pbReadOnly to True
//            Set pbRestoreLayout to True   
//            Set psLayoutSection to (Name(Self) + "_grd")
            Set pbReverseOrdering to True
            Set peHorizontalGridStyle to xtpGridNoLines
//            Set pbUseAlternateRowBackgroundColor to True
//            Set pbSelectionEnable to True
//            Set piSelectedRowBackColor to clGreenGreyLight
//            Set piHighlightBackColor   to clGreenGreyLight

            Object oCJGridColumnRowIndicator is a cCJGridColumnRowIndicator
                Set piWidth to 11
            End_Object

            Object oSncLog_RecID is a cRDCDbCJGridColumn
                Entry_Item SncLog.ID
                Set piWidth to 56
                Set psCaption to "Log ID"
            End_Object

            Object oSncLog_StatusText is a cRDCDbCJGridColumn
                Entry_Item SncLog.StatusText
                Set piWidth to 144
                Set psCaption to "Status Text"
                Set pbMultiLine to True

                Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                    Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
                    If (sValue contains "Error:") Begin
                        Set ComForeColor of hoGridItemMetrics to clRed
                    End
                End_Procedure
            End_Object

            Object oSncLog_SortName is a cRDCDbCJGridColumn
                Entry_Item SncLog.SncTableSortField
                Set piWidth to 143
                Set psCaption to "Name (Sort Field)"
            End_Object

            Object oSncLog_TableName is a cRDCDbCJGridColumn
                Entry_Item SncLog.TableName
                Set piWidth to 279
                Set psCaption to "Description"
            End_Object

            Object oSncLog_DateTimeCreated is a cRDCDbCJGridColumn
                Entry_Item SncLog.DateTimeCreated
                Set piWidth to 76
                Set psCaption to "Date and Time"
            End_Object

            Object oSncLog_NetworkUserName is a cRDCDbCJGridColumn
                Entry_Item SncLog.NetworkUserName
                Set piWidth to 71
                Set psCaption to "User Name"
            End_Object 

            Procedure Activate Returns Integer
                Integer iRetVal
                Forward Get msg_Activate to iRetVal
                Send MoveToFirstRow
                Procedure_Return iRetVal
            End_Procedure   
            
        End_Object

        Object oDeleteLog_bn is a cZeroLogBn
            Set Label to "&Delete Log"
            Set Size to 14 63
            Set Location to 10 395
            Set Status_Help to "Press to delete all records in the log."
            Set peAnchors to anTopRight
            Set psImage to "DeleteLog.ico"    

            // We need these, else the "Escape" key doesn't close the 
            // dialog when in popup_modal state.
            Procedure Close_Panel
                Delegate Send Close_Panel    
            End_Procedure

            On_Key kCancel Send Close_Panel
        End_Object
        
        Procedure Close_Panel
            Delegate Send Close_Panel    
        End_Procedure

        On_Key kCancel Send Close_Panel   
    End_Object

    Object oLogDetails_grp is a cRDCHeaderDbGroup
        Set Size to 109 470
        Set Location to 207 13
        Set Label to "Log Details"
        Set peAnchors to anBottomLeftRight  
        Set psImage to "ReportDetails.ico"

        Object oSnclog_Statustext is a cDbTextEdit
            Entry_Item Snclog.StatusText
            Set Server to Snclog_DD
            Set Label to "Status Text"
            Set Size to 33 379
            Set Location to 18 80
            Set Label_Row_Offset to 0
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to jMode_Right
            Set Read_Only_State to True
            Set Skip_State to True
            Set peAnchors to anBottomLeftRight
            
            Procedure Refresh Integer iNotifyMode
                String sValue

                Forward Send Refresh iNotifyMode
                Get Field_Current_Value of (Main_DD(Self)) Field SncLog.StatusText to sValue
                If (sValue contains "Error:") Begin
                    Set pbBold to True
                End                     
                Else Begin
                    Set pbBold to False
                End                         
            End_Procedure
        
        End_Object 

        Object oSnclog_SncTableSortField is a cRDCDbForm
            Entry_Item Snclog.SncTableSortField
            Set Server to Snclog_DD
            Set Label to "Name (Sort Field)"
            Set Size to 13 379
            Set Location to 54 80
            Set peAnchors to anBottomLeftRight
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to jMode_Right
            Set Enabled_State to False
        End_Object  
        
        Object oSnclog_Tablename is a cRDCDbForm
            Entry_Item Snclog.Tablename
            Set Server to Snclog_DD
            Set Label to "Description"
            Set Size to 13 379
            Set Location to 69 80
            Set peAnchors to anBottomLeftRight
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to jMode_Right
            Set Enabled_State to False
        End_Object  
        
        Object oSnclog_Datetime is a cRDCDbForm
            Entry_Item Snclog.DateTimeCreated
            Set Server to Snclog_DD
            Set Label to "Date and Time"
            Set Size to 13 69
            Set Location to 85 80
            Set peAnchors to anBottomLeft
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to jMode_Right
            Set Enabled_State to False
        End_Object          
        
        Object oSnclog_Networkusername is a cRDCDbForm
            Entry_Item Snclog.Networkusername
            Set Server to Snclog_DD
            Set Label to "User Name"
            Set Size to 13 77
            Set Location to 85 191
            Set peAnchors to anBottomLeft
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to jMode_Right
            Set Enabled_State to False
        End_Object  
        
        Object oCurrentRecords_fm is a cRDCForm
            Set Label to "Log Records"
            Set Size to 13 41
            Set Location to 85 314
            Set Status_Help to "Current number of Log records."
            Set peAnchors to anBottomRight
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to jMode_Right
            Set Form_Datatype Item 0 to Mask_Numeric_Window
            Set Form_Mask     Item 0 to "#,###########"
            Set Enabled_State to False
    
            Procedure DoSetRecordCount
                Integer iRecords
                Get_Attribute DF_FILE_RECORDS_USED of SncLog.File_Number to iRecords
                Set Value Item 0 to iRecords
            End_Procedure
            Send DoSetRecordCount
    
        End_Object    
        
        Object oMaxRecords_fm is a cRDCForm
            Set Label to "Max no Records"
            Set Size to 13 41
            Set Location to 85 418
            Set Status_Help to "Maximum number of records the log can contain."
            Set peAnchors to anBottomRight
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to jMode_Right
            Set Form_Datatype Item 0 to Mask_Numeric_Window
            Set Form_Mask     Item 0 to "#,###########"
            Set Enabled_State to False
    
            Procedure DoSetRecordCount
                Integer iRecords
                Get_Attribute DF_FILE_MAX_RECORDS of SncLog.File_Number to iRecords
                Set Value Item 0 to iRecords
            End_Procedure
            Send DoSetRecordCount
    
        End_Object 
        
    End_Object     
    
    Procedure Popup
        Set Locate_Mode to Center_On_Parent  
        Forward Send Popup
    End_Procedure
    
    Procedure Close_Panel
        Boolean bPopup
        Get Popup_State to bPopup
        If (bPopup = True) Begin
            Send Stop_UI
        End
    End_Procedure

    Procedure Page Integer iPageObject
        Forward Send Page iPageObject
        Set Icon to "Report.ico"
    End_Procedure

    Object oCancel_btn is a Button
        Set Size to 14 50
        Set Label    to "&Close"
        Set Location to 324 433
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Close_Panel
        End_Procedure

    End_Object
    
    On_Key Key_Alt+Key_D Send KeyAction of oDeleteLog_bn
    On_Key kCancel       Send Close_Panel   
End_Object
