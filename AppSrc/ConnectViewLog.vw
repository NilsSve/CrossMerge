Use Dfclient.pkg
Use cRDCButton.pkg
Use cRDCForm.pkg
Use cZeroLogBn.pkg

Use LogDialog.dg

Use SncSys.dd
Use SncTable.dd
Use SncSchem.dd
Use SncLog.dd

Activate_View Activate_oConnectViewLog For oConnectViewLog
Object oConnectViewLog is a DbView
    Set Size to 189 522
    Set Location to 0 0
    Set Label to "View Log"
    Set Border_Style to Border_Thick
    Set Auto_Clear_DEO_State to False
    Set Verify_Save_msg to msg_None
    Set pbAutoActivate to True

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

    Object oSncLog_grd is a dbList
        Set Main_File to Snclog.File_Number
        Set Server to Snclog_DD
        Set Ordering to 1
        Set Size to 157 493
        Set Location to 6 4
        Set TextColor to clNavy
        Set CurrentCellColor to clYellow
        Set peGridLineColor to clNavy
        Set peDisabledTextColor to clNavy
        Set peResizeColumn to rcSelectedColumn
        Set piResizeColumn to 2
        Set pbHeaderTogglesDirection to True
        Set pbReverseOrdering to True
        Set Auto_Column_State to False
        Set Move_Value_Out_State to False
        Set peAnchors to anAll

        Begin_Row
            Entry_Item Snclog.RecID
            Entry_Item (Snclog.RecID)
            Entry_Item Snclog.StatusText
            Entry_Item Snclog.TableName
            Entry_Item Snclog.DateTimeCreated
            Entry_Item Snclog.NetworkUserName
        End_Row

        Set Form_Width   Item 0 to 30
        Set Header_Label Item 0 to "Log ID"

        Set Form_Width   Item 1 to 29
        Set Header_Label Item 1 to "Status"
        Set Column_Checkbox_State Item 1 to True

        Set Form_Width   Item 2 to 166
        Set Header_Label Item 2 to "Status Text"

        Set Form_Width 3 to 136
        Set Header_Label Item 3 to "Database Connection"

        Set Form_Width   Item 4 to 72
        Set Header_Label Item 4 to "Date and Time"

        Set Form_Width 5 to 54
        Set Header_Label Item 5 to "User Name"

        Set Status_Help Item 0 to "Double-click to better view the selected status message."

        Procedure Entry_Display Integer iFile Integer iType
            Integer iBase_Item
            String sValue

            Forward Send Entry_Display iFile iType
            Get Base_Item to iBase_Item
            If (iBase_Item < 0) Begin
                Procedure_Return
            End

            Increment iBase_Item
            Get Value Item (iBase_Item + 1) to sValue
            If (Uppercase(sValue) contains "ERROR") ;
                Set Form_Bitmap Item iBase_Item to "Error.bmp/t"
            Else If (Uppercase(sValue) contains "WARNING") Begin
                Set Form_Bitmap Item iBase_Item to "Warning.bmp/t"
            End
            Else Begin
                Set Form_Bitmap Item iBase_Item to "Info.bmp/t"
            End
        End_Procedure

        Procedure Mouse_Click Integer iWin
            Forward Send Mouse_Click iWin
            Send DoPopupLogDialog
        End_Procedure

        Procedure DoMouseClick
            Send DoPopupLogDialog
        End_Procedure

        On_Key kNext_Item     Send Down
        On_Key kPrevious_Item Send Up
    End_Object

    Object oCurrentRecords_fm is a cRDCForm
        Set Label to "Number of Log Records:"
        Set Size to 13 43
        Set Location to 166 89
        Set Status_Help to "Current number of records in the Synchronize log."
        Set peAnchors to anBottomLeft
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
        Set Label to "Max no of Log Records:"
        Set Size to 13 43
        Set Location to 166 225
        Set Status_Help to "Maximum number of records the log can contain."
        Set peAnchors to anBottomLeft
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

    Object oDeleteLog_bn is a cZeroLogBn
        Set Label to "&Delete Log"
        Set Size to 14 59
        Set Location to 166 438
        Set Status_Help to "Press to delete all records in the log."
        Set peAnchors to anBottomRight
        Set Enabled_State to SncSys.AllowDeleteLog
        Set psImage to "DeleteLog.ico"
    End_Object

    // Do not allow to close if used as a view
//    Procedure Request_Cancel
//        Boolean bPopup
//        Get Popup_State to bPopup
//        If (bPopup = False) Begin
//            Procedure_Return
//        End
//        Forward Send Request_Cancel  
//        Send Close_Panel
//    End_Procedure

//    Function RdsMain_Panel_Id Returns Integer
//        Function_Return Self
//    End_Function
//
    Function Item_Count Returns Integer
    End_Function

    On_Key Key_Alt+Key_E  Send KeyAction of oSelectAll_bn
    On_Key Key_Ctrl+Key_E Send KeyAction of oSelectAll_bn
    On_Key Key_Alt+Key_N  Send KeyAction of oDeselectAll_bn
    On_Key Key_Ctrl+Key_N Send KeyAction of oDeselectAll_bn
    On_Key Key_Alt+Key_I  Send KeyAction of oInvertSelection_bn
    On_Key Key_Ctrl+Key_I Send KeyAction of oInvertSelection_bn
    On_Key Key_Alt+Key_D  Send KeyAction of oDeleteLog_bn
    On_Key Key_Ctrl+Key_D Send KeyAction of oDeleteLog_bn

End_Object
