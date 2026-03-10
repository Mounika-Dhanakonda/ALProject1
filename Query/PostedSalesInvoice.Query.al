query 50150 "Posted Sales Invoice API"
{
    QueryType = API;
    Caption = 'Posted Sales Invoice API';
    APIPublisher = 'custom';
    APIGroup = 'sales';
    APIVersion = 'v1.0';
    EntityName = 'postedSalesInvoice';
    EntitySetName = 'postedSalesInvoices';

    elements
    {
        // ROOT FOR DOCUMENT DATE FILTER
        dataitem(SalesInvHeader; "Sales Invoice Header")
        {
            column(DocumentDate; "Posting Date") { }
            column(SystemCreatedAt; SystemCreatedAt) { }
            column(VoidStatus; Cancelled) { }
            column(AddressCode; "Ship-to Code") { }
            column(AddressCodeShipToName; "Ship-to Name") { }
            column(StatefromLineItem; "Ship-to County") { }
            column(Country; "Ship-to Country/Region Code") { }
            column(CityfromSalesTransaction; "Ship-to City") { }
            column(ZipCodefromSalesTransaction; "Ship-to Post Code") { }
            column(SalesRepCode; "Salesperson Code") { } // required to get Sales Rep Name from Dimensions
            column(CustomerNo; "Ship-to Code") { }
            column(CustomerName; "Ship-to Name") { }

            // SALES INVOICE LINE
            dataitem(SalesInvLine; "Sales Invoice Line")
            {
                DataItemLink = "Document No." = SalesInvHeader."No.";

                column(DocumentNo; "Document No.") { }
                column(ItemNo; "No.") { }
                column(ItemDescription; Description) { }
                column(Quantity; Quantity) { }
                column(UnitPrice; "Unit Price") { }
                // column(CustomerNo; "Sell-to Customer No.") { }
                // column(CustomerName; Name) { }
                column(ExtendedPrice; "Line Amount") { }
                column(Amount; Amount) { }
                column(LocationCode; "Location Code") { }

                // CUSTOMER (ALL CUSTOMER FIELDS FROM CUSTOMER TABLE)
                dataitem(CustomerRec; Customer)
                {
                    DataItemLink = "No." = SalesInvHeader."Sell-to Customer No.";

                    //column(CustomerName; Name) { }
                    column(CityfromCustomerMaster; City) { }
                    column(ZipfromCustomerMaster; "Post Code") { }

                    // ITEM
                    dataitem(ItemRec; Item)
                    {
                        DataItemLink = "No." = SalesInvLine."No.";
                        column(ItemClassCode; "CS_shortcut Dimension 5 Code") { }

                        dataitem(DimSetEntry; "Dimension Set Entry")
                        {
                            DataItemLink = "Dimension Set ID" = SalesInvHeader."Dimension Set ID";
                            column(DimensionSetID; "Dimension Set ID") { }

                            column(DimensionCode; "Dimension Code")
                            {
                                ColumnFilter = DimensionCode = CONST('DEALER DIST');
                            }
                            column(SalespersonIDfromSalesTransaction; "Dimension Value Code") { }
                            column(SalespersonIDfromCustomerMaster; "Dimension Value Code") { }
                        }
                    }
                }
            }
        }
    }
}
