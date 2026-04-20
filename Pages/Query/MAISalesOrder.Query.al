query 50153 "MAI Sales Order Query"
{
    QueryType = API;
    Caption = 'MAI Sales Order Query';
    APIPublisher = 'custom';
    APIGroup = 'sales';
    APIVersion = 'v1.0';
    EntityName = 'MAIsalesOrders';
    EntitySetName = 'MAIsalesOrders';

    elements
    {
        dataitem(SalesHeader; "Sales Header")
        {
            DataItemTableFilter = "Document Type" = filter(Order);

            // Sales Header Columns
            column("DocumentType";
            "Document Type")
            {
                Caption = 'Document Type';
            }
            column("SalesHeaderNo"; "No.")
            {
                Caption = 'SalesHeader No.';
            }
            column("SelltoCustomerNo"; "Sell-to Customer No.")
            {
                Caption = 'Sell-to Customer No.';
            }
            column("Name"; "Bill-to Name")
            {
                Caption = 'Bill-to Name';
            }
            column("ShiptoCode"; "Ship-to Code")
            {
                Caption = 'Ship-to Code';
            }
            column("ShiptoName"; "Ship-to Name")
            {
                Caption = 'Ship-to Name';
            }
            column("ShiptoAddress"; "Ship-to Address")
            {
                Caption = 'Ship-to Address';
            }
            column("ShiptoAddress2"; "Ship-to Address 2")
            {
                Caption = 'Ship-to Address 2';
            }
            column("ShiptoCity"; "Ship-to City")
            {
                Caption = 'Ship-to City';
            }
            column("OrderDate"; "Order Date")
            {
                Caption = 'Order Date';
            }

            column("shippingmethodcode"; "Shipment Method Code")
            {
                Caption = 'Shipment Method Code';
            }

            column("SalespersonCode"; "Salesperson Code")
            {
                Caption = 'Salesperson Code';
            }

            column("ShiptoZipCode"; "Ship-to Post Code")
            {
                Caption = 'Ship-to ZIP Code';
            }

            column("ShiptoState"; "Ship-to county")
            {
                Caption = 'Ship-to State';
            }
            column("ShiptoCountryRegionCode"; "Ship-to Country/Region Code")
            {
                Caption = 'Ship-to Country/Region Code';
            }

            column("ExternalDocumentNo"; "External Document No.")
            {
                Caption = 'External Document No.';
            }
            column("SalesHeaderShippingAgentCode"; "Shipping Agent Code")
            {
                Caption = 'Shipping Agent Code';
            }

            column("status"; Status)
            {
                Caption = 'Status';
            }

            column("salesQuoteno"; "Quote No.")
            {
                Caption = 'Quote No.';
            }
            column("QuoteValidToDate"; "Quote Valid Until Date")
            {
                Caption = 'Quote Valid To Date';
            }

            column("quoteAccepted"; "Quote Accepted")
            {
                Caption = 'Quote Accepted';
            }

            column("quoteAcceptedDate"; "Quote Accepted Date")
            {
                Caption = 'Quote Accepted Date';
            }

            column("Email"; "Sell-to E-Mail")
            {
                Caption = 'Email';
            }
            column("shippingAdvice"; "Shipping Advice")
            {
                Caption = 'Shipping Advice';
            }

            column("SalesHeaderShippingAgentServiceCode"; "Shipping Agent Service Code")
            {
                Caption = 'Shipping Agent Service Code';
            }

            column("QuoteGroup"; "Quote Group")
            {
                Caption = 'Quote Group';
            }

            column("TargetClosingDate"; "Target Closing Date")
            {
                Caption = 'Target Closing Date';
            }

            column("ProbabilityToWin"; "Probability to Win")
            {
                Caption = 'Probability to Win';
            }

            column("SalesStatus"; "Sales Status")
            {
                Caption = 'Sales Status';
            }

            column("SalesComment"; "Sales Comment")
            {
                Caption = 'Sales Comment';
            }

            dataitem(SalesLine; "Sales Line")
            {
                DataItemLink = "Document Type" = SalesHeader."Document Type",
                               "Document No." = SalesHeader."No.";
                DataItemTableFilter = "Document Type" = filter(Order);

                column(LineNo; "Line No.")
                {
                    Caption = 'Line No.';
                }
                column(Type; Type)
                {
                    Caption = 'Type';
                }
                column(No; "No.")
                {
                    Caption = 'No.';
                }
                column(LocationCode; "Location Code")
                {
                    Caption = 'Location Code';
                }
                column(ShipmentDate; "Shipment Date")
                {
                    Caption = 'Shipment Date';
                }
                column(Description; Description)
                {
                    Caption = 'Description';
                }
                column(Description2; "Description 2")
                {
                    Caption = 'Description 2';
                }
                column(UnitOfMeasure; "Unit of Measure")
                {
                    Caption = 'Unit of Measure';
                }
                column(Quantity; Quantity)
                {
                    Caption = 'Quantity';
                }
                column(OutstandingQuantity; "Outstanding Quantity")
                {
                    Caption = 'Outstanding Quantity';
                }
                column(UnitPrice; "Unit Price")
                {
                    Caption = 'Unit Price Excl. Tax';
                }
                column(Amount; Amount)
                {
                    Caption = 'Amount';
                }
                column(AmountIncludingVAT; "Amount Including VAT")
                {
                    Caption = 'Amount Including Tax';
                }
                column(TaxLiable; "Tax Liable")
                {
                    Caption = 'Tax Liable';
                }
                column(TaxGroupCode; "Tax Group Code")
                {
                    Caption = 'Tax Group Code';
                }
                column(Reserve; Reserve)
                {
                    Caption = 'Reserve';
                }
                column(PlannedDeliveryDate; "Planned Delivery Date")
                {
                    Caption = 'Planned Delivery Date';
                }
                column(PlannedShipmentDate; "Planned Shipment Date")
                {
                    Caption = 'Planned Shipment Date';
                }
                column(ShippingAgentCode; "Shipping Agent Code")
                {
                    Caption = 'Shipping Agent Code';
                }
                column(ShippingAgentServiceCode; "Shipping Agent Service Code")
                {
                    Caption = 'Shipping Agent Service Code';
                }
                column(BOMItemNo; "BOM Item No.")
                {
                    Caption = 'BOM Item No.';
                }
                column(SystemCreatedAt; SystemCreatedAt)
                {
                    Caption = 'System Created At';
                }
                column(SystemCreatedBy; SystemCreatedBy)
                {
                    Caption = 'System Created By';
                }
                column(SystemModifiedAt; SystemModifiedAt)
                {
                    Caption = 'System Modified At';
                }
                column(SystemModifiedBy; SystemModifiedBy)
                {
                    Caption = 'System Modified By';
                }
            }
        }
    }
}
