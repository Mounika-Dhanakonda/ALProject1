page 50150 ItemTrackingAPI
{
    PageType = API;
    APIPublisher = 'mizuho';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'itemtracking';
    EntitySetName = 'itemtrackings';

    SourceTable = Item;
    ODataKeyFields = SystemId;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(SystemId; Rec.SystemId) { }

                field(ItemNo; Rec."No.") { }

                field(GTIN; Rec.GTIN) { }

                field(Description; Rec.Description) { }

                field(MfgDate; MfgDate) { }

                field(LotNo; LotNo) { }

                field(SerialNo; SerialNo) { }

                field(ControlType; ControlType) { }
            }
        }
    }

    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        TrackingCode: Record "Item Tracking Code";

        MfgDate: Date;
        LotNo: Code[50];
        SerialNo: Code[50];
        ControlType: Text[20];

    trigger OnOpenPage()
    begin
        // Ignore items without tracking code
        Rec.SetFilter("Item Tracking Code", '<>%1', '');
    end;

    trigger OnAfterGetRecord()
    begin
        Clear(MfgDate);
        Clear(LotNo);
        Clear(SerialNo);
        Clear(ControlType);

        // Determine Control Type
        if TrackingCode.Get(Rec."Item Tracking Code") then begin
            if TrackingCode."Lot Specific Tracking" then
                ControlType := 'LOT';

            if TrackingCode."SN Specific Tracking" then
                ControlType := 'SERIAL';
        end;

        // Find latest valid ledger entry
        ItemLedgerEntry.Reset();
        ItemLedgerEntry.SetRange("Item No.", Rec."No.");

        ItemLedgerEntry.SetFilter("Entry Type", '%1|%2',
            ItemLedgerEntry."Entry Type"::Purchase,
            ItemLedgerEntry."Entry Type"::"Positive Adjmt.");

        // Apply filters based on control type
        if ControlType = 'LOT' then
            ItemLedgerEntry.SetFilter("Lot No.", '<>%1', '');

        if ControlType = 'SERIAL' then
            ItemLedgerEntry.SetFilter("Serial No.", '<>%1', '');

        ItemLedgerEntry.SetCurrentKey("Posting Date");
        ItemLedgerEntry.Ascending(false);

        if ItemLedgerEntry.FindFirst() then begin
            LotNo := ItemLedgerEntry."Lot No.";
            SerialNo := ItemLedgerEntry."Serial No.";
            MfgDate := ItemLedgerEntry."Posting Date";
        end;
    end;
}