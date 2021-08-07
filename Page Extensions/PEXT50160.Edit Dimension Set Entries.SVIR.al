pageextension 50160 "Edit Dim. Set Entries.SVIR" extends "Edit Dimension Set Entries"
{

    layout
    {
        modify(DimensionValueCode) { Editable = false; }

        addbefore(DimensionValueCode)
        {
            field("Dimension Value Code"; Rec."Dimension Value Code.SVIR")
            {
                ApplicationArea = All;
                Lookup = true;
                trigger OnLookup(var Text: Text): Boolean
                var
                    _dimVal: Record "Dimension Value";
                    _dimValTemp: REcord "Dimension Value" temporary;
                    _dimValueComb: Record "Dimension Value Combination";
                    _dimSetEntry2: Record "Dimension Set Entry";
                    _dimSetEntryTemp: Record "Dimension Set Entry" temporary;
                    _dimValListPage: Page "Dimension Value List";
                    _setup: Record "Setup.SVIR";
                    _filterVal: Text;
                    _mainDimCode: Text;
                    _mainDimValCode: Text;
                    i: integer;
                    _dimmgt: Codeunit DimensionManagement;
                    _selectedVal: Text;
                begin
                    Rec.ReadSetup(_setup, true);
                    _setup.TestField("Main Dimension");
                    //check if main dim is there in Rec temp
                    i := _dimMgt.GetDimensionSetID(Rec);
                    if Rec."Dimension Set ID" <> 0 then begin
                        _dimMgt.GetDimensionSet(_dimSetEntryTemp, _dimMgt.GetDimensionSetID(Rec));
                        i := _dimSetEntryTemp.Count;
                        _dimSetEntryTemp.SetRange("Dimension Code", _setup."Main Dimension");

                        if _dimSetEntryTemp.FindSet() then
                            repeat
                                if _dimSetEntryTemp."Dimension Code" = _setup."Main Dimension" then begin
                                    _mainDimCode := _dimSetEntryTemp."Dimension Code";
                                    _mainDimValCode := _dimSetEntryTemp."Dimension Value Code";
                                end;
                            until _dimSetEntryTemp.Next() = 0;
                        if _mainDimValCode <> '' then begin
                            // if yes, use dimension code + dimension value code to scan through the allowed dim combos
                            _dimVal.SetRange("Dimension Code", Rec."Dimension Code");
                            _dimValTemp.DeleteAll();
                            if _dimVal.FindSet() then
                                repeat
                                    if not _dimValueComb.Get(_mainDimCode, _mainDimValCode,
                                                            _dimVal."Dimension Code", _dimVal.Code) then
                                        if not _dimValueComb.Get(_dimVal."Dimension Code", _dimVal.Code,
                                                                _mainDimCode, _mainDimValCode) then begin
                                            //_dimValTemp := _dimVal;
                                            //_dimValTemp.Insert();
                                            if _filterVal = '' then
                                                _filterVal := _dimVal.Code
                                            else
                                                _filterVal += '|' + _dimVal.Code;
                                        end;

                                until _dimVal.Next() = 0;
                        end else begin
                            _dimVal.SetRange("Dimension Code", Rec."Dimension Code");
                            _filterVal := '';
                        end;
                        Commit();
                        _dimValListPage.LookupMode := true;
                        if _filterVal <> '' then
                            _dimVal.SetFilter(Code, _filterVal);
                        _dimValListPage.GetRecord(_dimVal);
                        _dimValListPage.SetTableView(_dimVal);
                        If _dimValListPage.RunModal() = Action::LookupOK then begin
                            _selectedVal := _dimValListPage.GetSelectionFilter();
                            Rec.Validate("Dimension Value Code.SVIR", _selectedVal);
                            Rec.Modify();
                            Rec.ValidateMainDimension();
                        end;
                    end else begin
                        _dimVal.SetRange("Dimension Code", Rec."Dimension Code");
                        _dimValListPage.LookupMode := true;
                        _dimValListPage.SetTableView(_dimVal);
                        If _dimValListPage.RunModal() = Action::LookupOK then begin
                            _selectedVal := _dimValListPage.GetSelectionFilter();
                            Rec.Validate("Dimension Value Code.SVIR", _selectedVal);
                            Rec.Modify();
                            Rec.ValidateMainDimension();
                        end;
                    end;
                end;
            }
        }
    }
    trigger OnClosePage()
    var
        myInt: Integer;
    begin
        Rec.ValidateMainDimension();
    end;

    trigger OnAfterGetRecord()
    begin
        Rec."Dimension Value Code.SVIR" := Rec."Dimension Value Code";
    end;
}