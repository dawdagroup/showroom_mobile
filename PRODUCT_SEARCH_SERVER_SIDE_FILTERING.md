# Product Search Server-Side Filtering Implementation

## Overview
This document describes the implementation of server-side filtering for the product input in the Complaint Registration Screen to improve performance and user experience.

## Changes Made

### 1. API Service Enhancement (`lib/services/api_service.dart`)

Added a new method `searchProductDetails()` that:
- Accepts a search query parameter
- Returns an empty result set if the search query has less than 3 characters
- Calls a new endpoint `/products/search` with the search parameter
- Handles errors gracefully

```dart
Future<Map<String, dynamic>> searchProductDetails(String sessionToken, String searchQuery) async {
  // Only search if query has at least 3 characters
  if (searchQuery.length < 3) {
    output["status"] = "success";
    output["data"] = [];
    return output;
  }
  // ... rest of implementation
}
```

### 2. Complaint Registration Screen Updates (`lib/screens/complaints/components/complaint_registration_screen.dart`)

#### Key Changes:
- **Import added**: `dart:async` for Timer functionality
- **Timer added**: `Timer? _searchTimer` for debouncing search requests
- **Updated `getProductData()` method**: Now implements server-side filtering with debouncing
- **Enhanced DropdownSearch widget**: Better user experience with helpful messages
- **Added dispose method**: Proper cleanup of timer resources

#### Features Implemented:

1. **Minimum Character Requirement**: Users must type at least 3 characters before search is triggered
2. **Debouncing**: 500ms delay to prevent excessive API calls while user is typing
3. **Better UX**: Clear messaging about character requirements and empty states
4. **Error Handling**: Graceful handling of network and authentication errors
5. **Resource Cleanup**: Proper disposal of timer resources

### 3. User Experience Improvements

The DropdownSearch now includes:
- Hint text: "Search with at least 3 characters"
- Search field placeholder: "Type at least 3 characters to search..."
- Empty state message when less than 3 characters entered
- "No products found" message when search returns no results

## Backend Requirements

The backend should implement a new endpoint:
- **Endpoint**: `GET /products/search`
- **Query Parameter**: `search` - the search term
- **Functionality**: Perform a LIKE search on relevant product fields (model, brand, etc.)
- **Response**: Same structure as existing `/products` endpoint

Example backend implementation (conceptual):
```sql
SELECT * FROM products 
WHERE model_no LIKE '%{search}%' 
   OR brand LIKE '%{search}%' 
   OR description LIKE '%{search}%'
LIMIT 50;
```

## Benefits

1. **Performance**: Reduces data transfer and processing on the client side
2. **User Experience**: Faster search results and better feedback
3. **Network Efficiency**: Fewer API calls due to debouncing and minimum character requirement
4. **Scalability**: Can handle large product databases efficiently

## Testing Considerations

- Test with various search terms (short, long, special characters)
- Verify debouncing works correctly (no excessive API calls)
- Test network error scenarios
- Verify proper cleanup when navigating away from the screen
- Test with empty search results
