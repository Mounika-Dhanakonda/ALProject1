codeunit 50120 PostedSalesReturnsAPI
{
    [ServiceEnabled]
    procedure GetData(fromDat: DateTime; toDat: DateTime): Text
    var
        saCrMemoHeader: Record "Sales Cr.Memo Header";
        PoSalCretMemoLine: Record "Sales Cr.Memo Line";
        DimSetEntry: Record "Dimension Set Entry";
        Customer: Record Customer;
        DealerDistValue: Code[20];
        ItemClassValue: Code[20];
        data: Text;
    begin
        Clear(jsonarray);

        if PoSalCretMemoLine.FindSet() then
            repeat
                if saCrMemoHeader.Get(PoSalCretMemoLine."Document No.") then begin

                    // Filter by SystemCreatedAt
                    if (fromDat <> 0DT) and (toDat <> 0DT) then
                        if not ((saCrMemoHeader.SystemCreatedAt >= fromDat) and
                                (saCrMemoHeader.SystemCreatedAt <= toDat)) then
                            continue;

                    DealerDistValue := '';
                    ItemClassValue := '';

                    // Read Dimension Set
                    DimSetEntry.Reset();
                    DimSetEntry.SetRange("Dimension Set ID", PoSalCretMemoLine."Dimension Set ID");

                    if DimSetEntry.FindSet() then
                        repeat
                            case DimSetEntry."Dimension Code" of
                                'DEALER DIST':
                                    DealerDistValue := DimSetEntry."Dimension Value Code";
                                'ITEM CLASS':
                                    ItemClassValue := DimSetEntry."Dimension Value Code";
                            end;
                        until DimSetEntry.Next() = 0;

                    // Handle Customer
                    Clear(Customer);
                    if not Customer.Get(saCrMemoHeader."Sell-to Customer No.") then
                        Customer.Init();

                    PrepareData(
                        PoSalCretMemoLine,
                        saCrMemoHeader,
                        DealerDistValue,
                        ItemClassValue,
                        Customer);

                end;
            until PoSalCretMemoLine.Next() = 0;

        jsonarray.WriteTo(data);
        exit(data);
    end;


    local procedure PrepareData(
        var PoSalCretMemoLine: Record "Sales Cr.Memo Line";
        var saCrMemoHeader: Record "Sales Cr.Memo Header";
        DealerDistValue: Code[20];
        ItemClassValue: Code[20];
        var Customer: Record Customer)
    begin
        Clear(jsonobject);

        jsonobject.Add('DocumentDate', saCrMemoHeader."Posting Date");
        jsonobject.Add('SystemCreatedAt', saCrMemoHeader.SystemCreatedAt);
        jsonobject.Add('VoidStatus', saCrMemoHeader.Cancelled);

        jsonobject.Add('AddressCode', saCrMemoHeader."Ship-to Code");
        jsonobject.Add('AddressCodeShipToName', saCrMemoHeader."Ship-to Name");
        jsonobject.Add('CityfromSalesTransaction', saCrMemoHeader."Ship-to City");
        jsonobject.Add('ZipCodefromSalesTransaction', saCrMemoHeader."Ship-to Post Code");
        jsonobject.Add('StatefromLineItem', saCrMemoHeader."Ship-to County");
        jsonobject.Add('Country', saCrMemoHeader."Ship-to Country/Region Code");
        jsonobject.Add('SalesRepCode', saCrMemoHeader."Salesperson Code");

        jsonobject.Add('CustomerNo', saCrMemoHeader."Ship-to Code");
        jsonobject.Add('CustomerName', saCrMemoHeader."Ship-to Name");

        jsonobject.Add('DocumentNo', PoSalCretMemoLine."Document No.");
        jsonobject.Add('ItemNo', PoSalCretMemoLine."No.");
        jsonobject.Add('ItemDescription', PoSalCretMemoLine.Description);

        // Convert returns to positive
        jsonobject.Add('Quantity', PoSalCretMemoLine.Quantity * -1);
        jsonobject.Add('UnitPrice', PoSalCretMemoLine."Unit Price");
        jsonobject.Add('ExtendedPrice', PoSalCretMemoLine."Line Amount" * -1);
        jsonobject.Add('Amount', PoSalCretMemoLine.Amount * -1);

        jsonobject.Add('LocationCode', PoSalCretMemoLine."Location Code");

        jsonobject.Add('CityfromCustomerMaster', Customer.City);
        jsonobject.Add('ZipfromCustomerMaster', Customer."Post Code");

        // Dimensions
        jsonobject.Add('ItemClassCode', ItemClassValue);
        jsonobject.Add('SalespersonIDfromSalesTransaction', DealerDistValue);
        jsonobject.Add('SalespersonIDfromCustomerMaster', DealerDistValue);

        jsonarray.Add(jsonobject);
    end;


    var
        jsonobject: JsonObject;
        jsonarray: JsonArray;
}