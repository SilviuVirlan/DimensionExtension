table 50160 "Setup.SVIR"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "PK"; Code[20])
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Main Dimension"; Code[20])
        {
            DataClassification = SystemMetadata;
            TableRelation = Dimension;
        }
    }

    keys
    {
        key(Key1; PK)
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}