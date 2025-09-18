import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../services/master/api_master.dart';
import 'package:http/http.dart' as http;

class ApiService extends ApiMaster {
  
  Future<Map<String, dynamic>> login(String username, String password, String appVersion) async {
    Map<String, dynamic> output = {};
    final queryParameters = {
      'username': username,
      'password': password,
      'appVersion': appVersion,
    };

    final uri = buildUri('/auth/mobile/token/'); // Change to Uri.https if available

    try {
      final response = await http.post(uri, body: json.encode(queryParameters) ,headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["accessToken"] = responseData["access_token"];
          output["expiresIn"] = responseData["expires_in"];
          output["refreshToken"] = responseData["refresh_token"];
          output["data"] = responseData["data"];
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "Invalid username or password combination";
        }

      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['error_description'] ?? "Invalid username or password combination";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> filterSalesQuotations(Map<String, dynamic> filters, String sessionToken) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/showrooms/quotations', filters); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);


        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["data"] = responseData["data"];
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching sales quotations";
        }

      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while fetching sales quotations";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> fecthApprovedDiscount(String sessionToken, String barcode) async {
    Map<String, dynamic> output = {};

    return output;
  }

  Future<Map<String, dynamic>> fecthProductDetails(String sessionToken, Map<String, dynamic> filters) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/products', filters); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["data"] = responseData["data"];
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching product details";
        }

      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while fetching product details";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> getAftersalesProducts(String sessionToken) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/products/aftersales'); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["data"] = responseData["data"];
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching product details";
        }

      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while fetching product details";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> fetchUserAccountInfo(String sessionToken) async{
    Map<String, dynamic> output = {};

    final uri = buildUri('/core/sales-agent/account'); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["data"] = responseData["data"];

        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching user account information";
        }
      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while fetching user account information";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> filterTaxGroups(String sessionToken, Map<String, dynamic> filters) async{
    Map<String, dynamic> output = {};

    final uri = buildUri('/core/tax-groups/', filters); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["data"] = responseData["data"];

        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching user account information";
        }
      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while fetching user account information";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> filterCustomers(String sessionToken, Map<String, dynamic> filters) async{
    Map<String, dynamic> output = {};

    final uri = buildUri('/customers/', filters); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["data"] = responseData["data"];

        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching data";
        }
      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData["detail"]['message'] ?? "An error occurred while fetching data";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> filterCustomerHistory(String sessionToken, String customerId) async{
    Map<String, dynamic> output = {};

    final uri = buildUri('/customers/history/$customerId/',); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["data"] = responseData["data"];

        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching data";
        }
      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData["detail"]['message'] ?? "An error occurred while fetching data";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> initiateCouponRedemption(String sessionToken, String couponCode) async{
    Map<String, dynamic> output = {};

    final uri = buildUri('/coupons/redemption/start/'); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    final queryParameters = {
      'code': couponCode,
    };

    try {
      final response = await http.post(uri, body: json.encode(queryParameters), headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["data"] = responseData["data"];

        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while redeeming coupon";
        }
      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while redeeming coupon";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }
    
    return output;
  }

  Future<Map<String, dynamic>> validateCouponOtp(String sessionToken, String couponCode, String couponOtp) async{
    Map<String, dynamic> output = {};

    final uri = buildUri('/coupons/redemption/validation/'); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    final queryParameters = {
      'code': couponCode,
      'coupon_otp': couponOtp,
    };

    try {
      final response = await http.post(uri, body: json.encode(queryParameters), headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["message"] = responseData['message'] ?? "Coupon validated successfully";
          output["data"] = responseData["data"];

        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while redeeming coupon";
        }
      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while redeeming coupon";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }
    
    return output;
  }

  Future<Map<String, dynamic>> filterProductStock(String sessionToken, Map<String, dynamic> filters) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/products/stocks/', filters); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["data"] = responseData["data"];

        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching product stock";
        }
      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while fetching product stock";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> fetchProductSerialNumbers(String sessionToken, Map<String, dynamic> filters) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/products/warehouse/serial-numbers', filters); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["data"] = responseData["data"];

        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching product stock";
        }
      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while fetching product stock";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }
    return output;
  }

  Future<Map<String, dynamic>> postSalesQuotation(String sessionToken, Map<String, dynamic> queryParameters) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/showrooms/quotations/'); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.post(uri,body: json.encode(queryParameters), headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["message"] = responseData['message'] ?? "Sales quotation processed successfully";
          output["data"] = responseData["data"];

        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while processing sales quotation";
        }
      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while processing sales quotation";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }
    return output;
  }

  Future<Map<String, dynamic>> getProductDetails(String sessionToken,  Map<String, dynamic> filters) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/products/details', filters); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["message"] = responseData['message'] ?? "Product details fetched successfully";
          output["data"] = responseData["data"];

        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching product details";
        }
      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while fetching product details";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }
    return output;
  }

  Future<Map<String, dynamic>> getProductSupplierStocks(String sessionToken,  String barcode) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/products/supplier/stock/$barcode', ); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["message"] = responseData['message'] ?? "Product details fetched successfully";
          output["data"] = responseData["data"];

        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching product details";
        }
      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while fetching product details";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }
    return output;
  }

  Future<Map<String, dynamic>> getSalesQuotationDetails(String documentNo, String sessionToken) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/sales/quotation/$documentNo'); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';
    
    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);


        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["data"] = responseData["data"];
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching sales quotations";
        }

      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while fetching sales quotations";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }
  
  Future<Map<String, dynamic>> getSalesQuotationInvoiceNumber(String documentNo, String sessionToken) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/sales/quotation-invoice/$documentNo'); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';
    
    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["data"] = responseData["data"];
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching sales quotations";
        }

      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while fetching sales quotations";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> fetchInvoiceDeliveryNumbers(String documentNo, String sessionToken) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/sales/invoice-delivery/$documentNo'); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';
    
    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["data"] = responseData["data"];
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching sales quotations";
        }

      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while fetching sales quotations";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> fetchSalesOrderDeliveryNumbers(String documentNo, String sessionToken) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/sales/sales-order-delivery/$documentNo'); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';
    
    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["data"] = responseData["data"];
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching sales quotations";
        }

      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while fetching sales quotations";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> getSalesQuotationApprovalRequests(String sessionToken, String documentNo) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/sales/quotation/approval-requests/$documentNo'); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["data"] = responseData["data"];
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching sales quotation approval requests";
        }
      }else{
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while fetching sales quotation approval requests";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> filterPrintLayouts(String sessionToken, Map<String, dynamic> filters) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/core/print-layouts/', filters); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["data"] = responseData["data"];
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching print layouts";
        }

      }else{
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while fetching print layouts";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> getAfterSaleRegister(String sessionToken, Map<String, dynamic> filters) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/aftersales/', filters); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["data"] = responseData["data"];
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching aftersale register";
        }
      }else{
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while fetching aftersale register";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> getRegionData(String sessionToken, Map<String, dynamic> filters) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/locations/regions/', filters); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["data"] = responseData["data"];
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching region data";
        }
      }else{
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while fetching region data";
      }
      
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> getZoneData(String sessionToken, Map<String, dynamic> filters) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/locations/zones/', filters); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["data"] = responseData["data"];
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching zone data";
        }
      }else{
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while fetching zone data";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> getTownData(String sessionToken, Map<String, dynamic> filters) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/locations/towns/', filters); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["data"] = responseData["data"];
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching town data";
        }
      }else{
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while fetching town data";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> getStreetData(String sessionToken, Map<String, dynamic> filters) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/locations/streets/', filters); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["data"] = responseData["data"];
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching street data";
        }
      }else{
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while fetching street data";
      }
      
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> getComplaintTypes(String sessionToken, Map<String, dynamic> filters) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/core/complaint-origins/', filters);

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60));

      if(response.statusCode == 200 && response.body.isNotEmpty){
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["data"] = responseData["data"];
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching complaint types";
        }
      }else{
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while fetching complaint types";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> registerComplaint(String sessionToken, Map<String, dynamic> data) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/aftersales/');

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      
      final response = await http.post(uri, headers: headers, body: jsonEncode(data)).timeout(const Duration(seconds: 60));

      if(response.statusCode == 200 && response.body.isNotEmpty){
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["message"] = responseData["message"];
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while registering complaint";
        }
      }else{
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while registering complaint";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> getComplaintDetails(String sessionToken, String complaintNo) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/aftersales/$complaintNo');

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60));

      if(response.statusCode == 200 && response.body.isNotEmpty){
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["data"] = responseData["data"];
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching complaint details";
        }
      }else{
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while fetching complaint details";
      } 
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> getMovementTypes(String sessionToken, Map<String, dynamic> filters) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/aftersales/movements/', filters);

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60));

      if(response.statusCode == 200 && response.body.isNotEmpty){
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["data"] = responseData["data"];
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching movement types";
        }
      }else{
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while fetching movement types";
      } 
      
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
      
    }

    return output;
  }

  Future<Map<String, dynamic>> submitCollectItem(String sessionToken, Map<String, dynamic> data) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/aftersales/collect-item/');

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    print(json.encode(data)); // Debugging line to check the data being sent

    try {
      final response = await http.post(uri, headers: headers, body: jsonEncode(data)).timeout(const Duration(seconds: 60));

      if(response.statusCode == 200 && response.body.isNotEmpty){
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["message"] = responseData["message"];
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while submitting collection item";
        }
      }else{
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while submitting collection item";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> printItemCollection(String sessionToken, String complaintNo, String layoutType) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/aftersales/layouts/print/');

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';
    print(jsonEncode({"layout_id": layoutType, "complaint_no": complaintNo})); // Debugging line to check the data being sent

    try {
      final response = await http.post(uri, headers: headers, body: jsonEncode({"layout_id": layoutType, "complaint_no": complaintNo})).timeout(const Duration(seconds: 60));

      if(response.statusCode == 200 && response.body.isNotEmpty){
        var responseData = json.decode(response.body);

        print("API Response Data:"); 
        print(responseData); // Debugging line to check the response data
        print("Response Status: ${responseData["status"]}");
        print("Response Message: ${responseData["message"]}");

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["message"] = responseData["message"] ?? "Document printed successfully";
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while printing item collection";
        }
      }else{
        try {
          var errorData = json.decode(response.body);
          output["status"] = "failed";
          output["message"] = errorData['message'] ?? "An error occurred while printing item collection";
        } catch (e) {
          output["status"] = "failed";
          output["message"] = "Server returned an error (${response.statusCode}): ${response.body.isNotEmpty ? response.body : 'No details available'}";
        }
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    } 

    return output;
  }

  Future<Map<String, dynamic>> addCustomer(String sessionToken, Map<String, dynamic> data) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/customers/');

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.post(uri, headers: headers, body: jsonEncode(data)).timeout(const Duration(seconds: 60));

      if(response.statusCode == 200 && response.body.isNotEmpty){
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["message"] = responseData["message"];
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while adding customer";
        }
      }else{
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while adding customer";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> validatePointsRedemption(String sessionToken, Map<String, dynamic> filters) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/loyalty/validate-points-redemption/');

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.post(uri, headers: headers, body: jsonEncode(filters)).timeout(const Duration(seconds: 60));

      if(response.statusCode == 200 && response.body.isNotEmpty){
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["message"] = responseData["message"];
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while validating points redemption";
        }

      }else{
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while validating points redemption";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }
  
  Future<Map<String, dynamic>> validatePointsRedemptionOTP(String sessionToken, Map<String, dynamic> data) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/loyalty/validate-points-redemption-otp/');

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.post(uri, headers: headers, body: jsonEncode(data)).timeout(const Duration(seconds: 60));

      if(response.statusCode == 200 && response.body.isNotEmpty){
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["message"] = responseData["message"];
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while validating points redemption OTP";
        }
      }else{
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while validating points redemption OTP";
      }

    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;

  }

  Future<Map<String, dynamic>> filterSalesOrders(String sessionToken, Map<String, dynamic> filters) async{
    Map<String, dynamic> output = {};

    final uri = buildUri('/sales/sales-order/', filters); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["data"] = responseData["data"];

        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching data";
        }
      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData["detail"]['message'] ?? "An error occurred while fetching data";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> filterInvoices(Map<String, dynamic> filters, String sessionToken) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/sales/invoice', filters); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);


        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["data"] = responseData["data"];
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching sales invoice";
        }

      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while fetching sales invoice";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> getInvoiceDetails(String documentNo, String sessionToken) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/sales/invoice/$documentNo'); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';
    
    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);


        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["data"] = responseData["data"];
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching invoice details";
        }

      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while fetching invoice details";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> getPrinterLayouts(Map<String, dynamic> filters, String sessionToken) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/printer/layouts', filters); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';
    
    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);


        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["data"] = responseData["data"];
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching printer layouts";
        }

      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while fetching printer layouts";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }
  
  Future<Map<String, dynamic>> getPrinterShowroomAddress(String sessionToken, Map<String, dynamic> filters) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/printer/address', filters); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';
    
    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["data"] = responseData["data"];
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching printer address";
        }

      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while fetching printer address";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> postSalesOrder(String sessionToken, Map<String, dynamic> queryParameters) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/sales/sales-order'); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    print(json.encode(queryParameters));

    try {

      final response = await http.post(uri,body: json.encode(queryParameters), headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["message"] = responseData['message'] ?? "Sales order processed successfully";
          output["data"] = responseData["data"];

        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while processing sales order";
        }
      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while processing sales order";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }
    return output;
  }

  Future<Map<String, dynamic>> filterLoyaltyTransaction(String sessionToken, Map<String, dynamic> filters) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/loyalty/transaction', filters); // Change to Uri.https if available
    
    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';
    
    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["data"] = responseData["data"];
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching loyalty transactions";
        }

      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while fetching loyalty transactions";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }
  
  Future<Map<String, dynamic>> getCustomerLoyaltyPoints(String sessionToken, String customerId) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/loyalty/customer-points/$customerId'); // Change to Uri.https if available
    
    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';
    
    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["data"] = responseData["data"];
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching loyalty transactions";
        }

      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while fetching loyalty transactions";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> processDocumentPrint(String sessionToken, Map<String, dynamic> queryParameters) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/printer/print/'); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.post(uri,body: json.encode(queryParameters), headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["message"] = responseData['message'] ?? "Document printed successfully";
          output["data"] = responseData["data"];

        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while processing document print";
        }
      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while processing document print";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }
    return output;
  }

  Future<Map<String, dynamic>> getSalesOrderDetails(String documentNo, String sessionToken) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/sales/sales-order/$documentNo'); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';
    
    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);


        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["data"] = responseData["data"];
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching sales order details";
        }

      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while fetching sales order details";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> processSalesOrderUpdate(String sessionToken, String receiptNumber, String salesOrderNumber,  XFile capturedImage) async {
    Map<String, dynamic> output = {};

    // final uri = buildUri('/sales/sales-order'); // Change to Uri.https if available

    // headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    // print(json.encode(queryParameters));

    try {
      
      // Build URI for API
      final uri = buildUri('/sales/sales-order');

      // Create multipart request
      var request = http.MultipartRequest('PUT', uri)
        ..headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken'
        ..fields['receiptNumber'] = receiptNumber
        ..fields['salesOrderNumber'] = salesOrderNumber;

      // Attach the image
      request.files.add(await http.MultipartFile.fromPath('file', capturedImage.path));

      // Send request
      var response = await request.send();
      var responseBody = await http.Response.fromStream(response);

      //check the size of the file
      print("Request size: ${request.contentLength}");
      print("Request headers: ${request.headers.toString()}");

      if (responseBody.statusCode == 200 && responseBody.body.isNotEmpty) {
          // Parse the response body
          print("Response body: ${responseBody.body}");
          print("Response status code: ${responseBody.statusCode}");
          
          // Decode the JSON response
        var responseData = jsonDecode(responseBody.body);

          // Check if the response indicates success
          if(responseData["status"] == 'success'){
              output["status"] = "success";
              output["message"] = responseData['message'] ?? "Sales order updated successfully";
              output["data"] = responseData["data"];
          }else{
              output["status"] = "failed";
              output["message"] = responseData['message'] ?? "An error occurred while processing sales order update";
          }
      }
      else {
          var errorData = json.decode(responseBody.body);
          output["status"] = "failed";
          output["message"] = errorData['message'] ?? "An error occurred while processing sales order update";

      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
      print("Error: ${e.toString()}"); // Log the error for debugging
      
    }

    return output;
  }

  Future<Map<String, dynamic>> processSalesOrderUpdateOld(String sessionToken, Map<String, dynamic> queryParameters) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/sales/sales-order'); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    // print(json.encode(queryParameters));

    print("Url: $uri");

    try {
      final response = await http.put(uri,body: json.encode(queryParameters), headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      // print the request size and headers for debugging
      print("Request size: ${queryParameters.length}");
      print("Request headers: ${headers.toString()}");

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        print(responseData);

        if(responseData["status"] == 'success'){
          output["status"] = "success"; 
          output["message"] = responseData['message'] ?? "Sales order updated successfully";
          output["data"] = responseData["data"];

        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while processing sales order update";
        }
      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while processing sales order update";
      }
    } catch (e) {
      print("Error: ${e.toString()}"); // Log the error for debugging
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. ${e.toString()}"; // More specific error message
      // Uncomment the line below for a more generic error message
      // output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }
    return output;
  }

  Future<Map<String, dynamic>> processSalesQuoteToInvoice(String sessionToken, Map<String, dynamic> queryParameters) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/sales/quote2invoice'); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    print(json.encode(queryParameters));

    try {
      final response = await http.post(uri,body: json.encode(queryParameters), headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        print(responseData);

        if(responseData["status"] == 'success'){
          output["status"] = "success"; 
          output["message"] = responseData['message'] ?? "Sales quote converted to invoice successfully";
          output["data"] = responseData["data"];

        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while processing sales quote conversion";
        }
      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while processing sales quote conversion";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }
    return output;
  }

  Future<Map<String, dynamic>> processInvoiceDelivery(String sessionToken, String invoiceNumber,  Map<String, dynamic> queryParameters) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/delivery/invoice/'); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    print(json.encode(queryParameters));

    try {
      final response = await http.post(uri,body: json.encode(queryParameters), headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success"; 
          output["message"] = responseData['message'] ?? "Invoice delivered successfully";
          output["data"] = responseData["data"];

        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while processing invoice delivery";
        }
      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while processing invoice delivery";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }
    return output;
  }

  Future<Map<String, dynamic>> getPurchaseOrderDetails(String documentNo, String sessionToken) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/purchase/order/$documentNo'); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';
    
    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);


        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["data"] = responseData["data"];
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching purchase order details";
        }

      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while fetching purchase order details";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> processPurchaseOrderReceipt(String sessionToken, Map<String, dynamic> queryParameters) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/purchase/order/receipt'); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    print(json.encode(queryParameters));

    try {
      final response = await http.post(uri,body: json.encode(queryParameters), headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success"; 
          output["message"] = responseData['message'] ?? "Purchase order receipt processed successfully";
          output["data"] = responseData["data"];

        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while processing purchase order receipt";
        }
      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while processing purchase order receipt";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }
    return output;
  }

  Future<Map<String, dynamic>> getGoodsIssueDetails(String documentNo, String sessionToken) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/purchase/goods/issue/$documentNo'); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';
    
    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);


        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["data"] = responseData["data"];
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching goods issue details";
        }

      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while fetching goods issue details";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> generatePasswordResetOtp(Map<String, dynamic> queryParameters) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/auth/password-reset/validate/'); // Change to Uri.https if available

    try {
      final response = await http.post(uri,body: json.encode(queryParameters), headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success"; 
          output["message"] = responseData['message'] ?? "";
          output["data"] = responseData["data"];

        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while processing reset password request";
        }
      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while processing reset password request";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }
    return output;
  }

  Future<Map<String, dynamic>> updatePassword(Map<String, dynamic> queryParameters) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/auth/password-reset/update/'); // Change to Uri.https if available

    try {
      final response = await http.post(uri,body: json.encode(queryParameters), headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success"; 
          output["message"] = responseData['message'] ?? "Password updated successfully";
          output["data"] = responseData["data"];

        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while processing password update";
        }
      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while processing password update";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }
    return output;
  }
  
  Future<Map<String, dynamic>> processSalesOrderDelivery(String sessionToken, String salesOrderNumber,  Map<String, dynamic> queryParameters) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/delivery/sales-order/'); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.post(uri,body: json.encode(queryParameters), headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success"; 
          output["message"] = responseData['message'] ?? "Sales order has been delivered successfully";
          output["data"] = responseData["data"];

        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while processing sales order";
        }
      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while processing sales order";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }
    return output;
  }

  Future<Map<String, dynamic>> processGoodsIssueReceipt(String sessionToken, Map<String, dynamic> queryParameters) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/purchase/goods-issue/receipt'); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    print(json.encode(queryParameters));

    try {
      final response = await http.post(uri,body: json.encode(queryParameters), headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success"; 
          output["data"] = responseData["data"];
          output["message"] = responseData["message"] ?? "Operation completed successfully";

        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while processing goods receipt";
        }
      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while processing goods receipt";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }
    return output;
  }
  
  Future<Map<String, dynamic>> getPrintPreview(String sessionToken, Map<String, dynamic> queryParameters) async {
    Map<String, dynamic> output = {};
    
    final queryParams = {
      'documentType': queryParameters["documentType"],
      'documentNumber': queryParameters["documentNumber"],
      'printer_type_id': queryParameters["printer_type_id"],
      'layout_id': queryParameters["layout_id"],
      'showroom_id': queryParameters["showroom_id"],
    };

    final uri = buildUri('/printer/print/preview', queryParams);

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/temp.pdf');
        await file.writeAsBytes(response.bodyBytes);
        
        output["status"] = "success"; 
        output["message"] = "Document printed successfully";
        output["file"] = file.path;
        
      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while processing document print";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }
    return output;
  }
  
  Future<Map<String, dynamic>> getWarehouse(String sessionToken, Map<String, dynamic> queryParameters) async {
    Map<String, dynamic> output = {};
    
    final uri = buildUri('/warehouse/', queryParameters);

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success"; 
          output["data"] = responseData["data"];

        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching warehouses";
        }
        
      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while fetching warehouses";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }
    return output;
  }

  Future<Map<String, dynamic>> processStockTransferRequest(String sessionToken, Map<String, dynamic> queryParameters) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/stocks/transfer-request'); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.post(uri,body: json.encode(queryParameters), headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success"; 
          output["message"] = responseData['message'] ?? "Stock transfer request processed successfully";
          output["data"] = responseData["data"];

        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while processing stock transfer request";
        }
      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while processing stock transfer request";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }
    return output;
  }

  Future<Map<String, dynamic>> getStockTransferTypes(String sessionToken, Map<String, dynamic> queryParameters) async {
    Map<String, dynamic> output = {};
    
    final uri = buildUri('/stocks/transfer-types', queryParameters);

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success"; 
          output["message"] = responseData['message'] ?? "Stock transfer types fetched successfully";
          output["data"] = responseData["data"];

        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching stock transfer types";
        }
        
      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while fetching  stock transfer types";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }
    return output;
  }

  Future<Map<String, dynamic>> filterStockTransfer(String sessionToken, Map<String, dynamic> filters) async{
    Map<String, dynamic> output = {};

    final uri = buildUri('/stocks/transfer-request', filters); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["message"] = responseData['message'] ?? "Stock transfers fetched successfully";
          output["data"] = responseData["data"];

        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching stock transfers";
        }
      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData["detail"]['message'] ?? "An error occurred while fetching  stock transfers";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> getStockTransferDetails(String sessionToken, String stockTransferNumber) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/stocks/transfer-request/$stockTransferNumber'); // Change to Uri.https if available
    
    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';
    
    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["message"] = responseData['message'] ?? "Stock transfer details fetched successfully";
          output["data"] = responseData["data"];
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching stock transfer details";
        }

      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData["detail"]['message'] ?? "An error occurred while fetching  stock transfer details";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }
  
  Future<Map<String, dynamic>> filterEvents(String sessionToken, Map<String, dynamic> filters) async{
    Map<String, dynamic> output = {};

    final uri = buildUri('/coupons/events', filters); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["message"] = responseData['message'] ?? "Events fetched successfully";
          output["data"] = responseData["data"];

        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching events";
        }
      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData["detail"]['message'] ?? "An error occurred while fetching  events";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> processEventCouponValidation(String sessionToken, Map<String, dynamic> queryParameters) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/coupons/validate/event-coupon'); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.post(uri,body: json.encode(queryParameters), headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success"; 
          output["message"] = responseData['message'] ?? "Event coupon validated successfully";
          output["data"] = responseData["data"];

        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while validation event coupon";
        }
      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while validation event coupon";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }
    return output;
  }

  Future<Map<String, dynamic>> getInvoicePaymentDetails(String sessionToken, String invoiceNumber) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/sales/invoice-payment/$invoiceNumber'); // Change to Uri.https if available
    
    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';
    
    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["message"] = responseData['message'] ?? "Invoice payment details fetched successfully";
          output["data"] = responseData["data"];
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching invoice payment details";
        }

      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData["detail"]['message'] ?? "An error occurred while fetching invoice payment details";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> processStockTransferGoodsIssue(String sessionToken, Map<String, dynamic> queryParameters) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/stocks/goods-issue/create'); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.post(uri,body: json.encode(queryParameters), headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success"; 
          output["message"] = responseData["message"] ?? "Goods issue processed successfully";

        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while processing goods create";
        }
      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while processing goods create";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }
    return output;
  }
  
  Future<Map<String, dynamic>> fiscalizeInvoice(String sessionToken, String invoiceNumber) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/sales/fiscalize-invoice/'); // Change to Uri.https if available
    
    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    final queryParameters = {
      "fiscalize": true,
      "invoiceNumber": invoiceNumber,
    };
    
    try {
      final response = await http.post(uri, body: json.encode(queryParameters), headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      print("Fiscalize Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["message"] = responseData['message'] ?? "Invoice payment details fetched successfully";
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching invoice payment details";
        }

      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData["detail"]['message'] ?? "An error occurred while fetching invoice payment details";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> filterDailyStockTake(String sessionToken, Map<String, dynamic> filters) async{
    Map<String, dynamic> output = {};

    final uri = buildUri('/stocks/daily-stock-take', filters); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["message"] = responseData['message'] ?? "Daily stock take fetched successfully";
          output["data"] = responseData["data"];

        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching daily stock take";
        }
      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData["detail"]['message'] ?? "An error occurred while fetching daily stock take";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> filterDailyStockTakeType(String sessionToken, Map<String, dynamic> filters) async{
    Map<String, dynamic> output = {};

    final uri = buildUri('/stocks/daily-stock-take-type', filters); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["message"] = responseData['message'] ?? "Daily stock take fetched successfully";
          output["data"] = responseData["data"];

        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching daily stock take types";
        }
      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData["detail"]['message'] ?? "An error occurred while fetching daily stock take types";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> createPhysicalStockCount(String sessionToken, Map<String, dynamic> queryParameters) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/stocks/daily-stock-take/create'); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    print(json.encode(queryParameters));

    try {
      final response = await http.post(uri,body: json.encode(queryParameters), headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success"; 
          output["message"] = responseData['message'] ?? "Event coupon validated successfully";
          output["data"] = responseData["data"];

        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while validation event coupon";
        }
      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while validation event coupon";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }
    return output;
  }

  Future<Map<String, dynamic>> getPhysicalStockCountDetails(String sessionToken, String physicalStockCountId) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/stocks/daily-stock-take/$physicalStockCountId'); // Change to Uri.https if available
    
    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';
    
    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["message"] = responseData['message'] ?? "Physical stock count details fetched successfully";
          output["data"] = responseData["data"];
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching physical stock count details";
        }

      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData["detail"]['message'] ?? "An error occurred while fetching physical stock count details";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> processPhysicalStockData(String sessionToken, Map<String, dynamic> queryParameters) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/stocks/daily-stock-take/create/details'); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    print(json.encode(queryParameters));

    try {
      final response = await http.post(uri,body: json.encode(queryParameters), headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success"; 
          output["message"] = responseData['message'] ?? "Event coupon validated successfully";
          output["data"] = responseData["data"];

        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while validation event coupon";
        }
      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData['message'] ?? "An error occurred while validation event coupon";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }
    return output;
  }
  
  Future<Map<String, dynamic>> getSalesSummary(String sessionToken, String showroomId) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/showrooms/sales-summary/$showroomId'); // Change to Uri.https if available
    
    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';
    
    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["message"] = responseData['message'] ?? "Sales summary fetched successfully";
          output["data"] = responseData["data"];
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching sales summary";
        }

      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData["detail"]['message'] ?? "An error occurred while fetching sales summary";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> filterSalesDelivery(String sessionToken, Map<String, dynamic> filters) async{
    Map<String, dynamic> output = {};

    final uri = buildUri('/delivery/', filters); // Change to Uri.https if available

    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["message"] = responseData['message'] ?? "Sales delivery fetched successfully";
          output["data"] = responseData["data"];

        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching sales delivery";
        }
      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData["detail"]['message'] ?? "An error occurred while fetching sales delivery";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }
  
  Future<Map<String, dynamic>> getSalesDeliveryDetails(String sessionToken, String deliveryNumber) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/delivery/$deliveryNumber'); // Change to Uri.https if available
    
    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["message"] = responseData['message'] ?? "Sales delivery details fetched successfully";
          output["data"] = responseData["data"];
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching sales delivery details";
        }

      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData["detail"]['message'] ?? "An error occurred while fetching sales delivery details";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  Future<Map<String, dynamic>> getAfterSalesLayouts(String sessionToken) async {
    Map<String, dynamic> output = {};

    final uri = buildUri('/aftersales/layouts/'); // Change to Uri.https if available
    
    headers[HttpHeaders.authorizationHeader] = 'Bearer $sessionToken';

    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 60)); // Adding a timeout

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        if(responseData["status"] == 'success'){
          output["status"] = "success";
          output["message"] = responseData['message'] ?? "Aftersales layouts details fetched successfully";
          output["data"] = responseData["data"];
        }else{
          output["status"] = "failed";
          output["message"] = responseData['message'] ?? "An error occurred while fetching aftersales layouts details";
        }

      } else {
        var errorData = json.decode(response.body);
        output["status"] = "failed";
        output["message"] = errorData["detail"]['message'] ?? "An error occurred while fetching aftersales layouts details";
      }
    } catch (e) {
      output["status"] = "failed";
      output["message"] = "We are unable to connect to the server at the moment. Please check your internet connection and try again.";
    }

    return output;
  }

  

}
