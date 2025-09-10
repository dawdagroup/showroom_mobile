# Purchase Order Serial Number Data Persistence Fix

## Issue Description
Previously, when a user entered a new purchase order and navigated to the receive PO screen, the scanned serial numbers from the previous purchase order would persist and be included in the new purchase order submission.

## Root Cause
The issue was caused by the way GetX controller instances were managed:

1. **Singleton Pattern**: Using `Get.put(PurchaseOderController(...))` without a unique tag created singleton instances
2. **Controller Reuse**: Different purchase orders were using the same controller instance
3. **Data Persistence**: Serial data from previous purchase orders remained in memory
4. **Incomplete Loading**: The `loadScans()` method had a check that prevented reloading existing item codes

## Solution Implemented

### 1. Tagged Controller Instances
- Modified `receive_po_body.dart` to use tagged controller registration:
  ```dart
  purchaseOderController = Get.put(PurchaseOderController(widget.purchaseOrderDetailsObj), 
                                  tag: widget.purchaseOrderDetailsObj.documentNumber.toString());
  ```

### 2. Controller Cleanup
- Added proper disposal of tagged controllers:
  ```dart
  @override
  void dispose() {
    // Cleanup the controller when leaving the screen
    Get.delete<PurchaseOderController>(tag: widget.purchaseOrderDetailsObj.documentNumber.toString());
    super.dispose();
  }
  ```

### 3. Data Reset in Controller
- Modified `po_controller.dart` to clear existing data before loading new data:
  ```dart
  Future<void> loadScans(PurchaseOrderDetailsModal purchaseOrderDetailsObj) async {
    // Clear any existing data first to ensure clean state
    scannedSerials.clear();
    // ... rest of the loading logic
  }
  ```

### 4. Tagged Controller Access
- Updated child widgets (`purchase_order_card.dart`, `purchase_order_product_screen.dart`) to use tagged controller instances
- Modified route handling to pass purchase order number for tagged access

## Result
- Each purchase order now gets its own dedicated controller instance
- Serial number data is properly isolated between different purchase orders
- Previous purchase order data does not persist when entering a new purchase order
- Controllers are properly cleaned up when leaving screens

## Files Modified
1. `lib/screens/purchase_receipt/components/receive_po_body.dart`
2. `lib/controllers/po_controller.dart`
3. `lib/screens/purchase_receipt/components/purchase_order_card.dart`
4. `lib/screens/purchase_receipt/components/purchase_order_product_screen.dart`
5. `lib/components/routes.dart`

## Testing
To verify the fix:
1. Enter a purchase order and scan some serial numbers
2. Navigate back to the purchase receipt screen
3. Enter a different purchase order number
4. Verify that no previous serial numbers are shown
5. Scan new serial numbers and submit
6. Verify only the new serial numbers are submitted
