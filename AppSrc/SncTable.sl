Use cRDCDbModalPanel.pkg
Use cRDCDbCJGridPromptList.pkg
Use cRDCDbCJGridColumn.pkg
Use cRDCButton.pkg
Use cCJSyncTableCheckBoxGrid.pkg

Use SNCTABLE.DD

Cd_Popup_Object SncTable_sl is a cRDCDbModalPanel
    Set Location to 5 5
    Set Size to 181 537
    Set Label To "Select a Database Table Connection Record"
    Set Minimize_Icon to False
    Set piMinSize to 148 473
    Set Icon to "CmBuilder.ico" 
    Set Auto_Locate_State to True
    
    Object oSncTable_DD is a SncTable_DataDictionary
    End_Object 

    Set Main_DD To oSncTable_DD
    Set Server  To oSncTable_DD

    Object oSelList is a cRDCDbCJGridPromptList
        Set Size to 152 527
        Set Location to 5 5
        Set Ordering to 1
        Set pbAutoServer to True

        Object oSncTable_ID is a cRDCDbCJGridColumn
            Entry_Item SncTable.ID
            Set piWidth to 69
            Set psCaption to "ID"
        End_Object 

        Object oSncTable_SortField is a cRDCDbCJGridColumn
            Entry_Item SncTable.SortField
            Set piWidth to 219
            Set psCaption to "Name (Sort Name)"
        End_Object 

        Object oSncTable_Text is a cRDCDbCJGridColumn
            Entry_Item SncTable.Text
            Set piWidth to 406
            Set psCaption to "Description"
        End_Object 

        Object oSncTable_ToOwner is a cRDCDbCJGridColumn
            Entry_Item SncTable.ToOwner
            Set piWidth to 133
            Set psCaption to "Synchronization Type"

            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String ByRef sValue
                Handle hoVal 
                Integer iSynchType iID
                
                Get RowValue of oSncTable_ID iRow to iID
                Move iID to SncTable.ID
                Find eq SncTable.ID
                Move SncTable.SynchType to iSynchType
                Get Field_Table_Object  of (Server(Self)) Field SncTable.SynchType  to hoVal
                Get Validation_Table_Description of (Server(Self)) hoVal iSynchType to sValue
                
                Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
            End_Procedure   

        End_Object 

        Object oSncTable_Hide is a cRDCDbCJGridColumn
            Entry_Item SncTable.Hide
            Set piWidth to 52
            Set psCaption to "Hidden"
            Set pbCheckbox to True
        End_Object 

    End_Object 

    Object oOk_bn is a cRDCButton
        Set Label to "&Ok"
        Set Location to 162 374
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object 

    Object oCancel_bn is a cRDCButton
        Set Label to "&Cancel"
        Set Location to 162 428
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object 

    Object oSearch_bn is a cRDCButton
        Set Label to "&Search..."
        Set Location to 162 482
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object 

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn
Cd_End_Object 
