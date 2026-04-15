// permissionset 50160 "Whse API Perm"
// {
//     Assignable = true;
//     Permissions = // Codeunits
//     codeunit WarehouseProcessAPI = X,
//         codeunit "Whse.-Shipment Release" = X,
//         codeunit "Create Pick" = X,
//     // Sales
//         tabledata "Sales Header" = RM,
//         tabledata "Sales Line" = RM,
//     // Warehouse Core
//         tabledata "Warehouse Request" = RIMD,
//         tabledata "Warehouse Shipment Header" = RIMD,
//         tabledata "Warehouse Shipment Line" = RIMD,
//         tabledata "Warehouse Activity Header" = RIMD,
//         tabledata "Warehouse Activity Line" = RIMD,
//     // IMPORTANT — Required in most warehouses
//         tabledata "Warehouse Employee" = RIMD,
//     // Setup & Master Data
//         tabledata Location = R,
//         tabledata Item = R,
//         tabledata "Warehouse Setup" = R,
//         tabledata "Bin" = R,
//     // Sometimes Required
//         tabledata "Source Code Setup" = R,
//         tabledata "Inventory Setup" = R,
//         codeunit PostedSalesReturnsAPI = X,
//         page ItemTrackingAPI = X,
//         query "AR Aging Report API" = X,
//         query "Daily Sales Report API" = X,
//         query "MAI Sales Quote Query" = X,
//         query "Posted Sales Invoice API" = X;
// }