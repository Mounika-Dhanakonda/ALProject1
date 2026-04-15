// codeunit 50160 WarehouseProcessAPI
// {
//     [ServiceEnabled]
//     procedure GetData(): Text
//     begin
//         exit('Hello');
//     end;
//     // MAIN API METHOD
//     [ServiceEnabled]
//     procedure ProcessSalesOrder(SalesOrderNo: Code[20]): Text
//     var
//         ResultText: Text;
//     begin
//         if TryProcessSalesOrder(SalesOrderNo, ResultText) then
//             exit(ResultText)
//         else
//             exit('{"status":"error","message":"Unexpected error occurred while processing the sales order"}');
//     end;


//     // TRY FUNCTION WRAPPER
//     [TryFunction]
//     local procedure TryProcessSalesOrder(
//         SalesOrderNo: Code[20];
//         var ResultText: Text)
//     begin
//         ResultText := ProcessSalesOrderInternal(SalesOrderNo);
//     end;


//     // YOUR ORIGINAL LOGIC MOVED HERE
//     local procedure ProcessSalesOrderInternal(SalesOrderNo: Code[20]): Text
//     var
//         SalesHeader: Record "Sales Header";
//         SalesLine: Record "Sales Line";
//         WhseShipmentHeader: Record "Warehouse Shipment Header";
//         LocationCode: Code[10];
//         ShipmentNo: Code[20];
//         ResultMsg: Text;
//     begin
//         // STEP 1 — Validate Sales Order exists
//         if not SalesHeader.Get(SalesHeader."Document Type"::Order, SalesOrderNo) then
//             exit('{"status":"error","message":"Sales Order not found"}');

//         // STEP 2 — Check Released
//         if SalesHeader.Status <> SalesHeader.Status::Released then
//             exit('{"status":"error","message":"Sales Order is not Released"}');

//         // STEP 3 — Validate Lines
//         SalesLine.SetRange("Document Type", SalesHeader."Document Type");
//         SalesLine.SetRange("Type", SalesLine.Type::Item);
//         SalesLine.SetRange("Document No.", SalesOrderNo);

//         if not SalesLine.FindFirst() then
//             exit('{"status":"error","message":"Sales Order has no lines"}');

//         // STEP 4 — Location
//         LocationCode := SalesHeader."Location Code";

//         if LocationCode = '' then
//             exit('{"status":"error","message":"Sales Order location not defined"}');

//         // STEP 5 — Create Warehouse Request
//         if not CreateWarehouseRequest(SalesHeader) then
//             exit('{"status":"error","message":"Failed to create warehouse request"}');

//         // STEP 6 — Get Shipment
//         if not GetWarehouseShipment(
//             SalesOrderNo,
//             LocationCode,
//             WhseShipmentHeader) then
//             exit('{"status":"error","message":"Warehouse Shipment not created"}');

//         ShipmentNo := WhseShipmentHeader."No.";

//         // STEP 7 — Release Shipment
//         ReleaseWarehouseShipment(WhseShipmentHeader);

//         // STEP 8 — Create Pick
//         if not CreateWarehousePick(
//             WhseShipmentHeader,
//             SalesOrderNo) then
//             exit('{"status":"error","message":"Failed to create warehouse pick"}');

//         // SUCCESS RESPONSE
//         ResultMsg :=
//         '{"status":"success",' +
//         '"message":"Shipment and Pick created",' +
//         '"shipmentNo":"' + ShipmentNo + '",' +
//         '"salesOrderNo":"' + SalesOrderNo + '"}';

//         exit(ResultMsg);
//     end;



//     // ===== REMAINING FUNCTIONS (UNCHANGED) =====

//     local procedure CreateWarehouseRequest(
//         SalesHeader: Record "Sales Header"): Boolean
//     var
//         WarehouseRequest: Record "Warehouse Request";
//     begin
//         WarehouseRequest.Init();

//         WarehouseRequest.Type := WarehouseRequest.Type::Outbound;
//         WarehouseRequest."Location Code" := SalesHeader."Location Code";
//         WarehouseRequest."Source Type" := Database::"Sales Line";
//         WarehouseRequest."Source Subtype" := 1;
//         WarehouseRequest."Source No." := SalesHeader."No.";

//         WarehouseRequest."Document Status" := WarehouseRequest."Document Status"::Released;

//         if WarehouseRequest.Insert(true) then
//             exit(true);

//         WarehouseRequest.SetRange(
//             "Source No.",
//             SalesHeader."No.");

//         WarehouseRequest.SetRange(
//             "Location Code",
//             SalesHeader."Location Code");

//         exit(WarehouseRequest.FindFirst());
//     end;



//     local procedure GetWarehouseShipment(
//         SalesOrderNo: Code[20];
//         LocationCode: Code[10];
//         var WhseShipmentHeader: Record "Warehouse Shipment Header"): Boolean
//     begin
//         WhseShipmentHeader.Reset();

//         WhseShipmentHeader.SetRange(
//             "Location Code",
//             LocationCode);

//         if WhseShipmentHeader.FindLast() then
//             exit(true);

//         exit(false);
//     end;



//     local procedure ReleaseWarehouseShipment(
//         WhseShipmentHeader: Record "Warehouse Shipment Header")
//     var
//         WhseShipmentRelease: Codeunit "Whse.-Shipment Release";
//     begin
//         if WhseShipmentHeader.Status =
//            WhseShipmentHeader.Status::Open then
//             WhseShipmentRelease.Release(WhseShipmentHeader);
//     end;



//     local procedure CreateWarehousePick(
//         WhseShipmentHeader: Record "Warehouse Shipment Header";
//         SalesOrderNo: Code[20]): Boolean
//     begin
//         exit(true); // keep your existing logic
//     end;



//     // STATUS API

//     [ServiceEnabled]
//     procedure CheckSalesOrderStatus(
//         SalesOrderNo: Code[20]): Text
//     var
//         SalesHeader: Record "Sales Header";
//     begin
//         if not SalesHeader.Get(
//             SalesHeader."Document Type"::Order,
//             SalesOrderNo) then
//             exit('{"status":"error","message":"Sales Order not found"}');

//         exit(
//         '{"status":"success",' +
//         '"salesOrderNo":"' + SalesOrderNo + '",' +
//         '"orderStatus":"' +
//         Format(SalesHeader.Status) + '"}');
//     end;
// }