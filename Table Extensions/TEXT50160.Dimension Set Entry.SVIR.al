tableextension 50160 "Dimension Set Entry.SVIR." extends "Dimension Set Entry"
{
    fields
    {
        field(50160; "Dimension Value Code.SVIR"; Code[20])
        {
            Caption = 'Dimension Value Code.SVIR';
            NotBlank = true;

            //TableRelation = "Dimension Value".Code WHERE("Dimension Code" = FIELD("Dimension Code"));
            trigger OnValidate()
            begin
                Rec.Validate("Dimension Value Code", "Dimension Value Code.SVIR");
            end;
        }
    }

    procedure ValidateMainDimension()
    var
        _setup: Record "Setup.SVIR";
        _dimMgt: Codeunit DimensionManagement;
        _dimSetEntryTemp: Record "Dimension Set Entry" temporary;
        _dimValueComb: Record "Dimension Value Combination";
        Rec2: Record "Dimension Set Entry" temporary;

        _i: integer;
        _mainDim: Code[20];
        _mainDimValue: Code[20];
    begin
        ReadSetup(_setup, false);
        Rec2 := Rec;
        _dimMgt.GetDimensionSet(_dimSetEntryTemp, _dimMgt.GetDimensionSetID(Rec));
        _dimSetEntryTemp.SetRange("Dimension Code", _setup."Main Dimension");
        if _dimSetEntryTemp.FindFirst() then begin
            _mainDim := _dimSetEntryTemp."Dimension Code";
            _mainDimValue := _dimSetEntryTemp."Dimension Value Code";
            _dimSetEntryTemp.SetFilter("Dimension Code", '<>%1', _setup."Main Dimension");
            if _dimSetEntryTemp.FindSet() then
                repeat
                    if _dimValueComb.Get(_mainDim, _mainDimValue, _dimSetEntryTemp."Dimension Code", _dimSetEntryTemp."Dimension Value Code") or
                        _dimValueComb.Get(_dimSetEntryTemp."Dimension Code", _dimSetEntryTemp."Dimension Value Code", _mainDim, _mainDimValue) then begin
                        Rec2.SetRange("Dimension Code", _dimSetEntryTemp."Dimension Code");
                        if Rec2.FindFirst() then begin
                            Rec2."Dimension Value Code.SVIR" := '';
                            Rec2.Modify();
                            Commit();
                        end;
                        Message('Dimension %1 - %2 is blocked for %3 - %4. Please choose other dimension value for %1 or delete it.',
                                        _dimSetEntryTemp."Dimension Code",
                                        _dimSetEntryTemp."Dimension Value Code",
                                        _mainDim, _mainDimValue);
                    end;
                until _dimSetEntryTemp.Next() = 0;
            _dimSetEntryTemp.SetRange("Dimension Code");
        end;
    end;

    procedure ReadSetup(var _setup: Record "Setup.SVIR"; allowCommit: boolean)
    begin
        if not _setup.Get() then begin
            _setup.Init();
            _setup.Insert();
            if allowCommit then Commit();
        end;
    end;

}