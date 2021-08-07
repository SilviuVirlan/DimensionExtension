page 50160 "Setup.SVIR"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Setup.SVIR";

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Main Dimension"; Rec."Main Dimension")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}