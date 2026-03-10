query 50151 "Daily Sales Report API"
{
    QueryType = API;
    Caption = 'Daily Sales Report API';
    APIPublisher = 'custom';
    APIGroup = 'sales';
    APIVersion = 'v1.0';
    EntityName = 'dailySalesReportAPI';
    EntitySetName = 'dailySalesReportAPI';

    elements
    {
        // ROOT FOR DOCUMENT DATE FILTER
        dataitem(SalesInvHeader; "Sales Invoice Header")
        {
            column(DocumentDate; "Posting Date") { }
            column(SystemCreatedAt; SystemCreatedAt) { }
            column(CustomerNumber; "Ship-to Code") { }
            column(CustomerName; "Ship-to Name") { }

            // SALES INVOICE LINE
            dataitem(SalesInvLine; "Sales Invoice Line")
            {
                DataItemLink = "Document No." = SalesInvHeader."No.";
                DataItemTableFilter = "No." = FILTER(<> 'HANDLINGFEE' & <> 'FREIGHT');

                column(DocumentNumber; "Document No.") { }
                column(ItemNumber; "No.") { }
                column(ItemDescription; Description) { }
                column(QTY; Quantity) { }
                column(UnitPrice; "Unit Price") { }
                column(ExtendedPrice; "Line Amount") { }

                // ITEM
                dataitem(ItemRec; Item)
                {
                    DataItemLink = "No." = SalesInvLine."No.";
                    column(ItemClassCode; "CS_shortcut Dimension 5 Code") { }

                    dataitem(DimSetEntry; "Dimension Set Entry")
                    {
                        DataItemLink = "Dimension Set ID" = SalesInvHeader."Dimension Set ID";
                        DataItemTableFilter = "Dimension Code" = FILTER('DEALER DIST');
                        column("SalespersonID"; "Dimension Value Code") { }
                    }
                }
            }
        }
    }
}
