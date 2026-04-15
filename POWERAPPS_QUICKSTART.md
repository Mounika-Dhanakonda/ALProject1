# Power Apps Quick Start Guide - Warehouse Process API

## Quick Reference

### API Endpoints

```
Base URL: https://{environment}.dynamics.com/api/neev/warehouse/v1.0/companies({companyId})/warehouseProcesses

Endpoint 1: /Microsoft.Dynamics.DataEntities.ProcessOrder
Endpoint 2: /Microsoft.Dynamics.DataEntities.CheckStatus
```

---

## Ready-to-Use Power Apps Formulas

### 1. Process Sales Order (Canvas App)

```powerapp
// Add a Button and paste into OnSelect:

Set(
    varProcessResponse,
    JSON(
        HttpRequest(
            "POST",
            "https://{ENVIRONMENT}.dynamics.com/api/neev/warehouse/v1.0/companies({COMPANY_ID})/warehouseProcesses/Microsoft.Dynamics.DataEntities.ProcessOrder",
            {
                "salesOrderNo": TextInput_SalesOrderNo.Value
            },
            {
                "Authorization": "Bearer " & User().Email,
                "Content-Type": "application/json"
            }
        )
    )
);

If(
    varProcessResponse.status = "success",
    Notify("✓ " & varProcessResponse.message & " - Shipment: " & varProcessResponse.shipmentNo, NotificationType.Success),
    Notify("✗ " & varProcessResponse.message, NotificationType.Error)
)
```

### 2. Check Order Status First (Safe Approach)

```powerapp
// Recommended: Check status before processing

Set(
    varCheckResponse,
    JSON(
        HttpRequest(
            "POST",
            "https://{ENVIRONMENT}.dynamics.com/api/neev/warehouse/v1.0/companies({COMPANY_ID})/warehouseProcesses/Microsoft.Dynamics.DataEntities.CheckStatus",
            {
                "salesOrderNo": TextInput_SalesOrderNo.Value
            },
            {
                "Authorization": "Bearer " & User().Email,
                "Content-Type": "application/json"
            }
        )
    )
);

If(
    varCheckResponse.isReleased = true,
    // Call ProcessOrder
    Set(
        varProcessResponse,
        JSON(
            HttpRequest(
                "POST",
                "https://{ENVIRONMENT}.dynamics.com/api/neev/warehouse/v1.0/companies({COMPANY_ID})/warehouseProcesses/Microsoft.Dynamics.DataEntities.ProcessOrder",
                {
                    "salesOrderNo": TextInput_SalesOrderNo.Value
                },
                {
                    "Authorization": "Bearer " & User().Email,
                    "Content-Type": "application/json"
                }
            )
        )
    );
    Notify("✓ Process started...", NotificationType.Success),
    
    // Order not released
    Notify("✗ Sales Order status is " & varCheckResponse.orderStatus & ". Please release the order first.", NotificationType.Error)
)
```

### 3. Cloud Flow (Power Automate) - HTTP Request

```json
{
  "method": "POST",
  "uri": "https://{ENVIRONMENT}.dynamics.com/api/neev/warehouse/v1.0/companies({COMPANY_ID})/warehouseProcesses/Microsoft.Dynamics.DataEntities.ProcessOrder",
  "headers": {
    "Content-Type": "application/json"
  },
  "body": {
    "salesOrderNo": "@{triggerOutputs()['body/salesOrderNo']}"
  }
}
```

### 4. Parse JSON Response in Power Automate

```json
{
  "type": "object",
  "properties": {
    "status": {
      "type": "string"
    },
    "message": {
      "type": "string"
    },
    "shipmentNo": {
      "type": "string"
    },
    "salesOrderNo": {
      "type": "string"
    }
  }
}
```

---

## Canvas App UI Components Setup

### Input Section
```
TextInput (Name: TextInput_SalesOrderNo)
  - Placeholder: "Enter Sales Order No."
  - Default: ""
```

### Button - Check Status
```
Button (Name: Btn_CheckStatus)
  - Text: "Check Status"
  - OnSelect:
    Set(varCheckResponse, JSON(HttpRequest(...)))
    If(varCheckResponse.isReleased, Notify("Ready to process"), Notify("Not Released"))
```

### Button - Process Order
```
Button (Name: Btn_ProcessOrder)
  - Text: "Create Shipment & Pick"
  - OnSelect: [Use "Safe Approach" formula above]
```

### Result Display
```
Label (Name: Lbl_Result)
  - Text: varProcessResponse.message
  - Color: If(varCheckResponse.isReleased, Color.Green, Color.Red)
```

---

## Model-Driven App Integration

### Add Custom Page

1. Go to **App Designer**
2. Add new **Main form page**
3. Add **Web resource** or **Custom Control**
4. Configure Data Source to Sales Orders table
5. In **JavaScript**:

```javascript
// Test the API
function ProcessSalesOrder() {
    const salesOrderNo = Xrm.Page.getAttribute("name").getValue();
    
    const request = new XMLHttpRequest();
    const apiUrl = "https://{ENVIRONMENT}.dynamics.com/api/neev/warehouse/v1.0/companies({COMPANY_ID})/warehouseProcesses/Microsoft.Dynamics.DataEntities.ProcessOrder";
    
    request.open("POST", apiUrl, true);
    request.setRequestHeader("Content-Type", "application/json");
    request.onreadystatechange = function () {
        if (request.readyState === 4) {
            if (request.status === 200) {
                const response = JSON.parse(request.responseText);
                alert("Success! Shipment: " + response.shipmentNo);
            } else {
                alert("Error: " + request.responseText);
            }
        }
    };
    
    request.send(JSON.stringify({ "salesOrderNo": salesOrderNo }));
}
```

---

## Step-by-Step Integration in Power Apps

### Step 1: Create Input Form
1. Add **Text input** field for Sales Order No.
2. Add **Button** to check/process order

### Step 2: Add HTTP Request
3. In button's **OnSelect**, add HTTP request using connector

### Step 3: Handle Response
4. Parse JSON response
5. Display result in **Label** or **Gallery**

### Step 4: Error Handling
5. Check `status` field in response
6. Show appropriate notification to user

### Step 5: Test
6. Deploy app
7. Test with sample Sales Order No.

---

## Configuration Variables

Replace these in all formulas:

| Variable | Description | Example |
|----------|-------------|---------|
| {ENVIRONMENT} | Your BC environment | mycompany.dynamics.com |
| {COMPANY_ID} | Your company GUID | b0353c72-94a4-ec11-a7b5-0022481fa05c |

**How to find Company ID:**
1. Open Business Central
2. Go to **Settings > About**
3. Find **Company ID** (GUID format)

---

## Common Response Examples

### ✅ Success Response
```json
{
  "status": "success",
  "message": "Warehouse Shipment and Pick created successfully",
  "shipmentNo": "WH-000100",
  "salesOrderNo": "SO-001234"
}
```

### ❌ Error: Order Not Released
```json
{
  "status": "error",
  "message": "Sales Order is not Released. Current Status: Open"
}
```

### ❌ Error: Order Not Found
```json
{
  "status": "error",
  "message": "Sales Order not found"
}
```

---

## Testing Checklist

- [ ] Sales Order is in **Released** status
- [ ] Sales Order has line items
- [ ] Location is defined on the order
- [ ] Warehouse is enabled for that location
- [ ] Test with Check Status first
- [ ] Verify response contains shipmentNo
- [ ] Check Business Central for created shipment
- [ ] Verify pick was created

---

## Power Apps Expression Helper

### Get Authorization Token
```powerapp
"Bearer " & User().Email
```

### Build API URL Dynamically
```powerapp
"https://" & YourEnvironmentVariable & "/api/neev/warehouse/v1.0/companies(" & YourCompanyId & ")/warehouseProcesses/Microsoft.Dynamics.DataEntities.ProcessOrder"
```

### Parse and Display Error
```powerapp
If(varResponse.status = "error",
    Notify(varResponse.message, NotificationType.Error),
    Notify(varResponse.message, NotificationType.Success)
)
```

### Conditional Shipment Display
```powerapp
If(varResponse.status = "success",
    "Shipment Created: " & varResponse.shipmentNo,
    "Failed: " & varResponse.message
)
```

---

## Troubleshooting in Power Apps

### Issue: 401 Unauthorized
**Solution**: Check if user has BC permissions and token is valid

### Issue: 404 Not Found
**Solution**: Verify Sales Order No. exists and environment URL is correct

### Issue: Missing Response Fields
**Solution**: Ensure API response is valid JSON and schema parsing is correct

### Issue: App Timeout
**Solution**: Set increased timeout or use Power Automate for better control

---

## Next Steps

1. ✓ Review API documentation
2. ✓ Copy formulas from this guide
3. ✓ Replace {ENVIRONMENT} and {COMPANY_ID}
4. ✓ Test in development first
5. ✓ Deploy to production
6. ✓ Monitor for errors

---

**Ready to integrate? Start with the "Safe Approach" formula and test with a sample order!**
