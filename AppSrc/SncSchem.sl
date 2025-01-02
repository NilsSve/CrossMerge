Use Dfsellst.pkg

Use SncSchem.DD

Object SncSchem_SL is a dbModalPanel
    Set Label to "Select a scheme"
    Set Size to 134 324
    Set Location to 4 5

    Object SncSchem_DD is a SncSchem_DataDictionary
    End_Object    

    Set Main_DD to (SncSchem_DD(self))
    Set Server to (SncSchem_DD(self))

    Object oSelList is a dbList
        Set Main_File to SncSchem.File_Number
        Set Size to 105 307
        Set Location to 6 6

        Begin_Row
            Entry_Item SncSchem.Name
        End_Row

        Set Form_Width    Item 0 to 300
        Set Header_Label  Item 0 to "Name"
    End_Object    

    Object oOK_bn is a Button
        Set Label to "&OK"
        Set Location to 114 154
        Procedure OnClick
            Send OK to oSelList
        End_Procedure
    End_Object    

    Object oCancel_bn is a Button
        Set Label to "&Cancel"
        Set Location to 114 208
        Procedure OnClick
            Send Cancel to oSelList
        End_Procedure
    End_Object    

    Object oSearch_bn is a Button
        Set Label to "&Search..."
        Set Location to 114 264
        Procedure OnClick
            Send Search to oSelList
        End_Procedure
    End_Object    

    On_Key Key_Alt+Key_O Send KeyAction to oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction to oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction to oSearch_bn
End_Object    
