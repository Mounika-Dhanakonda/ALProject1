# Warehouse Process API Documentation

## Overview
This API exposes warehouse management functionalities to Power Apps and other external systems. It handles the complete workflow of processing sales orders through warehouse operations.

## API Configuration
- **Publisher**: neev
- **Group**: warehouse
- **Version**: v1.0
- **Entity Name**: warehouseProcess
- **Entity Set Name**: warehouseProcesses

## Base URL
```
https://{environment}.dynamics.com/api/neev/warehouse/v1.0/companies({company_id})/warehouseProcesses
```

---

## Endpoints

### 1. Process Sales Order
**Endpoint**: `POST /warehouseProcesses/Microsoft.Dynamics.DataEntities.ProcessOrder`

**Purpose**: 
- Validates if Sales Order is Released
- Creates Warehouse Shipment (only if Released)
- Does NOT create shipment if Sales Order is in Open status
- Automatically creates Pick after Warehouse Shipment is created

**Request Parameters**:
```json
{
  "salesOrderNo": "SO-001234"
}
```

**Request Example (Power Apps)**:
```powerapp
{
  "salesOrderNo": @{triggerOutputs()['body/salesOrderNo']}
}
```

**Success Response (HTTP 200)**:
```json
{
  "status": "success",
  "message": "Warehouse Shipment and Pick created successfully",
  "shipmentNo": "WH-000100",
  "salesOrderNo": "SO-001234"
}
```

**Error Response (HTTP 400/500)**:
```json
{
  "status": "error",
  "message": "Sales Order is not Released. Current Status: Open"
}
```

**Possible Error Messages**:
- "Sales Order not found"
- "Sales Order is not Released. Current Status: Open"
- "Sales Order has no lines"
- "Sales Order location not defined"
- "Warehouse Shipment not created for Sales Order"
- "Failed to create warehouse pick"

---

### 2. Check Sales Order Status
**Endpoint**: `POST /warehouseProcesses/Microsoft.Dynamics.DataEntities.CheckStatus`

**Purpose**: 
- Check the current status of a Sales Order
- Determine if order can be processed
- Returns whether order is Released or Open

**Request Parameters**:
```json
{
  "salesOrderNo": "SO-001234"
}
```

**Success Response (HTTP 200)**:
```json
{
  "status": "success",
  "salesOrderNo": "SO-001234",
  "orderStatus": "Released",
  "isReleased": true
}
```

**Error Response (HTTP 400/500)**:
```json
{
  "status": "error",
  "message": "Sales Order not found"
}
```

---

## Process Flow

```
┌─────────────────────────────────────────────────────────────┐
│                  Power Apps /External System                 │
└────────────────────┬────────────────────────────────────────┘
                     │
         ┌───────────▼──────────────┐
         │  Call ProcessOrder API   │
         │  (Sales Order No.)       │
         └───────────┬──────────────┘
                     │
      ┌──────────────▼──────────────┐
      │  Validate Sales Order Exists │
      └──────────────┬──────────────┘
                     │
      ┌──────────────▼──────────────────────────┐
      │  Check Order Status                      │
      └──────┬────────────────────────────┬─────┘
             │                            │
        ✓ RELEASED                    ✗ OPEN/OTHER
             │                         │
             │                  Return Error:
             │                  "Order Not Released"
             │
      ┌──────▼───────────────────────┐
      │ Add Sales Lines to Shipment   │
      │ (Create Warehouse Shipment)   │
      └──────┬───────────────────────┘
             │
      ┌──────▼──────────────────────┐
      │  Release Warehouse Shipment  │
      └──────┬──────────────────────┘
             │
      ┌──────▼─────────────────┐
      │  Create Warehouse Pick   │
      └──────┬─────────────────┘
             │
      ┌──────▼───────────────────────────────────┐
      │  Return Success Response                  │
      │  (Shipment No & Pick Info)               │
      └──────────────────────────────────────────┘
```

---

## Power Apps Integration Example

### Flow 1: Process Sales Order with UI Confirmation

```powerapp
// When button is clicked:
ProcessOrder:
  1. Set inputSalesOrderNo = TextInput1.Value
  
  2. Check Status First:
     CheckStatusResponse = HTTP POST
     {
       URL: [Your API URL] + "/warehouseProcesses/Microsoft.Dynamics.DataEntities.CheckStatus",
       Method: "POST",
       Headers: 
       {
         "Content-Type": "application/json",
         "Authorization": "Bearer " & User().Email
       },
       Body: 
       {
         "salesOrderNo": inputSalesOrderNo
       }
     }
  
  3. If CheckStatusResponse isReleased = true:
     ProcessResponse = HTTP POST
     {
       URL: [Your API URL] + "/warehouseProcesses/Microsoft.Dynamics.DataEntities.ProcessOrder",
       Method: "POST",
       Headers: {...},
       Body: {"salesOrderNo": inputSalesOrderNo}
     }
     
     If ProcessResponse.status = "success":
       Notify(ProcessResponse.message & " Shipment: " & ProcessResponse.shipmentNo)
     Else:
       Notify(ProcessResponse.message, Error)
  
  4. If CheckStatusResponse isReleased = false:
     Notify("Cannot process. Sales Order status is " & CheckStatusResponse.orderStatus, Error)
```

### Flow 2: Bulk Process Multiple Orders

```powerapp
// Process multiple sales orders from a table
BulkProcess:
  ForEach(Table1 As OrderRow)
  {
    Call ProcessOrder(OrderRow.SalesOrderNo)
    
    If ProcessOrder.status = "success" Then
      Patch(ResultTable, 
        {
          SalesOrderNo: OrderRow.SalesOrderNo,
          Status: "Success",
          ShipmentNo: ProcessOrder.shipmentNo,
          ProcessedDate: Now()
        })
    Else
      Patch(ResultTable,
        {
          SalesOrderNo: OrderRow.SalesOrderNo,
          Status: "Failed",
          ErrorMessage: ProcessOrder.message,
          ProcessedDate: Now()
        })
  }
```

---

## Business Logic Rules

### ✅ Success Conditions
- Sales Order exists in the system
- Sales Order Status = **Released** (NOT Open, Pending, or other statuses)
- Sales Order has at least one line item
- Location Code is defined on the order
- Warehouse is configured for the location

### ❌ Failure Conditions
- Sales Order is in "Open" status → **Warehouse Shipment will NOT be created**
- Sales Order does not exist
- Sales Order has no line items
- Location is not defined
- Item warehouse setup is missing

---

## HTTP Status Codes

| Code | Meaning | Example |
|------|---------|---------|
| 200 | Success | Shipment and Pick created successfully |
| 400 | Bad Request | Sales Order No. field is missing |
| 404 | Not Found | Sales Order does not exist |
| 500 | Internal Server Error | Database error or system failure |

---

## Authentication

All API calls require:
- **OAuth 2.0** authentication
- Valid Business Central user credentials
- Appropriate permissions for warehouse operations

**Header Example**:
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

---

## Response Message Format

All responses follow JSON format:

**Success**:
```json
{
  "status": "success",
  "message": "Detailed success message",
  "shipmentNo": "WH-000100",
  "salesOrderNo": "SO-001234"
}
```

**Error**:
```json
{
  "status": "error",
  "message": "Detailed error message"
}
```

---

## Testing the API

### Using Postman

1. **Request URL**: 
   ```
   POST https://{environment}.dynamics.com/api/neev/warehouse/v1.0/companies(b0353c72-94a4-ec11-a7b5-0022481fa05c)/warehouseProcesses/Microsoft.Dynamics.DataEntities.ProcessOrder
   ```

2. **Headers**:
   ```
   Authorization: Bearer {your_token}
   Content-Type: application/json
   ```

3. **Body**:
   ```json
   {
     "salesOrderNo": "SO-001234"
   }
   ```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Sales Order is not Released" | Release the Sales Order in Business Central before calling the API |
| "Warehouse Shipment not created" | Check if location has warehouse enabled and inventory is available |
| "Failed to create warehouse pick" | Verify item bin setup and warehouse location configuration |
| 401 Unauthorized | Check authentication token and user permissions |
| 404 Not Found | Verify Sales Order number is correct and exists in the system |

---

## API Limitations

- Processes one Sales Order at a time
- Requires order to be fully released
- Pick creation depends on warehouse configuration
- Returns JSON response only (no XML)

---

## Support & Updates

For issues or feature requests, contact your Business Central administrator or development team.

**Last Updated**: April 2026
**API Version**: 1.0
