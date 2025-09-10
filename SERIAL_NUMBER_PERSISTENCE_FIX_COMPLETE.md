# Complete Serial Number Data Persistence Fix

## Issue Description
Serial numbers scanned for previous documents (Purchase Orders and Goods Issue) would persist when entering new document numbers, causing previous data to be included in new document submissions.

## Root Cause
The issue was caused by GetX controller singleton pattern:
1. Controllers were registered without unique tags using `Get.put()`
2. Same controller instances were reused across different documents
3. Serial data persisted in memory between document switches
4. Loading logic prevented proper data reset

## Solution Applied

### Purchase Order Fix
- **Tagged Controllers**: `Get.put(PurchaseOderController(...), tag: documentNumber)`
- **Data Reset**: Clear existing data in `loadScans()` before loading new data
- **Controller Cleanup**: Dispose tagged controllers on navigation/screen exit
- **Child Widget Updates**: Updated cards/screens to use tagged controller access

### Goods Issue Fix (Same Pattern)
- **Tagged Controllers**: `Get.put(GoodsIssueController(...), tag: documentNumber)`
- **Data Reset**: Clear existing data in `loadScans()` before loading new data
- **Controller Cleanup**: Dispose tagged controllers on navigation/screen exit
- **Child Widget Updates**: Updated cards/screens to use tagged controller access

## Files Modified

### Purchase Order:
1. `lib/screens/purchase_receipt/components/receive_po_body.dart`
2. `lib/controllers/po_controller.dart`
3. `lib/screens/purchase_receipt/components/purchase_order_card.dart`
4. `lib/screens/purchase_receipt/components/purchase_order_product_screen.dart`
5. `lib/components/routes.dart`

### Goods Issue:
1. `lib/screens/purchase_receipt/components/receive_goods_issue_body.dart`
2. `lib/controllers/goods_issue_controller.dart`
3. `lib/screens/purchase_receipt/components/goods_issue_product_card.dart`
4. `lib/screens/purchase_receipt/components/goods_issue_product_screen.dart`
5. `lib/components/routes.dart` (updated for goods issue routes)

## Key Changes Made

### Controller Registration (Before)
```dart
purchaseOderController = Get.put(PurchaseOderController(widget.purchaseOrderDetailsObj));
goodsIssueController = Get.put(GoodsIssueController(widget.goodsIssueDetailsObj));
```

### Controller Registration (After)
```dart
purchaseOderController = Get.put(PurchaseOderController(widget.purchaseOrderDetailsObj), 
                                tag: widget.purchaseOrderDetailsObj.documentNumber.toString());
goodsIssueController = Get.put(GoodsIssueController(widget.goodsIssueDetailsObj), 
                              tag: widget.goodsIssueDetailsObj.documentNumber.toString());
```

### Data Loading (Before)
```dart
if (scannedSerials.containsKey(product.itemCode)) {
  continue; // Skip if already exists
}
```

### Data Loading (After)
```dart
// Clear any existing data first to ensure clean state
scannedSerials.clear();
// Then load all products without skipping
```

### Controller Cleanup
```dart
@override
void dispose() {
  Get.delete<PurchaseOderController>(tag: widget.purchaseOrderDetailsObj.documentNumber.toString());
  Get.delete<GoodsIssueController>(tag: widget.goodsIssueDetailsObj.documentNumber.toString());
  super.dispose();
}
```

## Result
- Each document now gets its own dedicated controller instance
- Serial number data is properly isolated between different documents
- Previous document data does not persist when entering new documents
- Controllers are properly cleaned up to prevent memory leaks
- Both Purchase Order and Goods Issue receipt functionality now work correctly

## Testing
1. Enter a purchase order/goods issue and scan serial numbers
2. Navigate back and enter a different document number
3. Verify no previous serial numbers are shown
4. Scan new serials and submit
5. Verify only new serials are submitted
