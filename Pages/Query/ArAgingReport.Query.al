query 50160 "AR Aging Report API"
{
    QueryType = API;
    Caption = 'AR Aging Report';

    APIPublisher = 'custom';
    APIGroup = 'finance';
    APIVersion = 'v1.0';

    EntityName = 'arAging';
    EntitySetName = 'arAging';

    elements
    {
        dataitem(CustLedgerEntry; "Cust. Ledger Entry")
        {
            // 🔹 Basic Customer Info
            column(Cust_Ledger_Entry_No; "Entry No.") { }
            column(Customer_Number; "Customer No.") { }
            column(Customer_Name; "Customer Name") { }

            // 🔹 Document Info
            column(Document_Type; "Document Type") { }
            column(Document_Number; "Document No.") { }
            column(Document_Date; "Document Date") { }
            column(Due_Date; "Due Date") { }
            column(Closed_at_Date; "Closed at Date") { }

            // 🔹 Amounts
            column(Amount; Amount) { }
            column(Remaining_Amount; "Remaining Amount") { }

            // 🔹 Extra Fields (You were missing these)
            column(Customer_PO_Number; "External Document No.") { }
            column(Salesperson_ID; "Global Dimension 2 Code") { }
            column(Document_Description; Description) { }

            // 🔹 Salesperson (Dimension)
            dataitem(Customer; "Customer")
            {
                DataItemLink = "No." = CustLedgerEntry."Customer No.";
                column(Terms; "Payment Terms Code") { }
            }
        }
    }
}