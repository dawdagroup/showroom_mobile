import 'package:flutter/material.dart';

import '../modals/goods_issue_details_modal.dart';
import '../modals/invoice_details_modal.dart';
import '../modals/product_modal.dart';
import '../modals/product_serial_number_modal.dart';
import '../modals/purchase_order_details_modal.dart';
import '../modals/sales_order_details_modal.dart';
import '../modals/sales_quotation_details_modal.dart';
import '../modals/stock_transfer_details_modal.dart';
import '../screens/goods_issue/components/goods_issue_create_product_screen.dart';
import '../screens/goods_issue/components/goods_issue_create_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/invoice/invoice_screen.dart';
import '../screens/invoice_details/invoice_details_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/password_reset/components/password_otp_verification_screen.dart';
import '../screens/password_reset/components/password_update_screen.dart';
import '../screens/password_reset/password_reset_screen.dart';
import '../screens/pdf_view/pdf_view_screen.dart';
import '../screens/physical_stock_count/physical_stock_count_screen.dart';
import '../screens/physical_stock_count_details/components/physical_stock_take_product_screen.dart';
import '../screens/physical_stock_count_details/physical_stock_count_details_screen.dart';
import '../screens/product_details/product_details_screen.dart';
import '../screens/purchase_receipt/components/goods_issue_product_screen.dart';
import '../screens/purchase_receipt/components/purchase_order_product_screen.dart';
import '../screens/purchase_receipt/components/receive_goods_issue_screen.dart';
import '../screens/purchase_receipt/components/receive_po_screen.dart';
import '../screens/purchase_receipt/purcahse_receipt_screen.dart';
import '../screens/sales_delivery/components/invoice_delivery_product_screen.dart';
import '../screens/sales_delivery/components/invoice_delivery_screen.dart';
import '../screens/sales_delivery/components/sales_delivery_create_screen.dart';
import '../screens/sales_delivery/components/sales_order_delivery_product_screen.dart';
import '../screens/sales_delivery/components/sales_order_delivery_screen.dart';
import '../screens/sales_delivery/sales_delivery_screen.dart';
import '../screens/sales_delivery_details/sales_delivery_details_screen.dart';
import '../screens/sales_order_details/sales_order_details_screen.dart';
import '../screens/sales_quotation/components/checkout_screen.dart';
import '../screens/sales_quotation/components/sales_quotation_form.dart';
import '../screens/sales_quotation/sales_quotation_screen.dart';
import '../screens/sales_quotation_details/components/convert_to_invoice_checkout_screen.dart';
import '../screens/sales_quotation_details/sales_quotation_details_screen.dart';
import '../screens/complaints/complaint_screen.dart';
import '../screens/complaints/components/complaint_registration_screen.dart';
import '../screens/complaint_details/complaint_details_screen.dart';
import '../screens/stock_transfer/components/stock_transfer_form.dart';
import '../screens/stock_transfer/stock_transfer_screen.dart';
import '../screens/stock_transfer_details/stcok_transfer_details_screen.dart';
import '../screens/welcome/welcome_screen.dart';
import '../screens/loyalty_program/loyalty_program_screen.dart';
import '../screens/customer_details/customer_details_screen.dart';
import '../screens/sales_order/sales_order_screen.dart';
import '../screens/sales_order/components/sales_order_form.dart';
import '../screens/sales_order/components/checkout_sales_order_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/reset-password':
        return MaterialPageRoute(builder: (_) => const PasswordResetScreen());
      case '/password-otp-verification':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => PasswordOtpVerificationScreen(username: args["username"] as String, userId: args["userId"] as int, otp: args["otp"] as int, expiresAt: args["expires_at"] as String,));
      case '/password_update':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => PasswordUpdateScreen(username: args["username"] as String, userId: args["userId"] as int, otp: args["otp"] as int, expiresAt: args["expires_at"] as String, verified: args["verified"], verifiedOtp: args["verified_otp"],));
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/sales_quotation':
        return MaterialPageRoute(builder: (_) => const SalesQuotationScreen());
      case '/sales_quotation_form':
        return MaterialPageRoute(builder: (_) => const SalesQuotationForm());
      case '/sales_quotation_details':
        final args = settings.arguments;
        return MaterialPageRoute(builder: (_) => SalesQuotationDetailsScreen(salesQuotationNo: args as String,));
      case '/product_details':
        final args = settings.arguments;
        return MaterialPageRoute(builder: (_) => ProductDetailsScreen(barcode: args as String,));
      case '/checkout':
        return MaterialPageRoute(builder: (_) => const CheckoutScreen());
      case '/aftersale_register':
        return MaterialPageRoute(builder: (_) => const ComplaintRegistrationScreen());
      case '/complaints':
        return MaterialPageRoute(builder: (_) => const ComplaintScreen());
      case '/complaint_details':
        final args = settings.arguments;
        return MaterialPageRoute(builder: (_) => ComplaintDetailsScreen(complaintNo: args as String,));
      case '/customer_details':
        final args = settings.arguments;
        return MaterialPageRoute(builder: (_) => CustomerDetailsScreen(customerId: args as String,));
      case '/loyalty_program':
        return MaterialPageRoute(builder: (_) => const LoyaltyProgramScreen());
      case '/sales_order':
        return MaterialPageRoute(builder: (_) => const SalesOrderScreen());
      case '/sales_order_form':
        return MaterialPageRoute(builder: (_) => const SalesOrderForm());
      case '/checkout-sales-order':
        return MaterialPageRoute(builder: (_) => const CheckoutSalesOrderScreen());
      case '/sales_invoices':
        return MaterialPageRoute(builder: (_) => const InvoiceScreen());
      case '/invoice_details':
        final args = settings.arguments;
        return MaterialPageRoute(builder: (_) => InvoiceDetailsScreen(invoiceNumber: args as String,));
      case '/sales_order_details':
        final args = settings.arguments;
        return MaterialPageRoute(builder: (_) => SalesOrderDetailsScreen(salesOrderNumber: args as String,));
      case '/sales_deliveries':
        return MaterialPageRoute(builder: (_) => const SalesDeliveryScreen());
      case '/receive_goods':
        return MaterialPageRoute(builder: (_) => const PurcahseReceiptScreen());
      case '/invoice_delivery':
        final args = settings.arguments;
        return MaterialPageRoute(builder: (_) => InvoiceDeliveryScreen(invoiceDetailsObj: args as InvoiceDetailsModal,));
      case '/invoice_delivery_product_screen':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => InvoiceDeliveryProductScreen(
          invoiceItem: args['invoiceItem'] as InvoiceItem, 
          serialNumberList: args['serialNumberList'] as List<ProductSerialNumberModal>,
          invoiceNumber: args['invoiceNumber'] as String,
        ));
      case '/receive_po':
        final args = settings.arguments;
        return MaterialPageRoute(builder: (_) => ReceivePoScreen(purchaseOrderDetailsObj: args as PurchaseOrderDetailsModal,));
      case '/purchase_order_product_screen':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => PurchaseOrderProductScreen(
          purchaseOrderLineItem: args['purchaseOrderLineItem'] as PurchaseOrderLineItem,
          purchaseOrderNumber: args['purchaseOrderNumber'] as String,
        ));
      case '/receive_goods_issue':
        final args = settings.arguments;
        return MaterialPageRoute(builder: (_) => ReceiveGoodsIssueScreen(goodsIssueDetailsObj: args as GoodsIssueDetailsModal,));
      case '/goods_issue_product_screen':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => GoodsIssueProductScreen(
          goodsIssueDetailsLineItem: args['goodsIssueDetailsLineItem'] as GoodsIssueDetailsLineItem,
          goodsIssueNumber: args['goodsIssueNumber'] as String,
        ));
      case '/create_goods_issue':
        final args = settings.arguments;
        return MaterialPageRoute(builder: (_) => GoodsIssueCreateScreen(transferNumber: args as String));
      case '/sales_oder_delivery':
        final args = settings.arguments;
        return MaterialPageRoute(builder: (_) => SalesOrderDeliveryScreen(salesOrderDetailsObj: args as SalesOrderDetailsModal,));
      case '/sales_order_delivery_product_screen':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => SalesOrderDeliveryProductScreen(
          salesOrderDetailsLineItem: args['salesOrderDetailsLineItem'] as SalesOrderDetailsLineItem, 
          serialNumberList: args['serialNumberList'] as List<ProductSerialNumberModal>,
          salesOrderNumber: args['salesOrderNumber'] as String,
        ));
      case '/stock_transfer':
        return MaterialPageRoute(builder: (_) => const StockTransferScreen());
      case '/pdf_view':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => PdfViewerScreen( documentType: args["documentType"] as String, documentNumber: args["documentNumber"] as String, printerTypeId: args["printerTypeId"] as int, layoutId: args["layoutId"] as int, showroomId: args["showroomId"] as String, ));
      case '/stock_transfer_form':
        return MaterialPageRoute(builder: (_) => const StockTransferForm());
      case '/stock_transfer_details':
        final args = settings.arguments;
        return MaterialPageRoute(builder: (_) => StcokTransferDetailsScreen(strockTransferNumber: args as String,));
      case '/goods_issue_create_product':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => GoodsIssueCreateProductScreen(
          product: args['product'] as StockTransferProduct,
          transferNumber: args['transferNumber'] as String,
        ));
      case '/physical_stock_count':
        return MaterialPageRoute(builder: (_) => const PhysicalStockCountScreen());
      case '/physical_stock_count_details':
        final args = settings.arguments;
        return MaterialPageRoute(builder: (_) => PhysicalStockCountDetailsScreen(physicalStockCountId: args as String,));
      case '/physical_stock_take_product_screen':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => PhysicalStockTakeProductScreen(product: args['product'] as ProductModal, physicalStockCountId: args['physicalStockCountId'] as String));
      case '/delivery_details':
        final args = settings.arguments;
        return MaterialPageRoute(builder: (_) => SalesDeliveryDetailsScreen(deliveryNumber: args as String,));
      case '/convert_to_invoice_checkout':
        final args = settings.arguments;
        return MaterialPageRoute(builder: (_) => ConvertToInvoiceCheckoutScreen(salesQuotationDetailsObj: args as SalesQuotationDetailsModal,));
      case '/sales_delivery_create':
        return MaterialPageRoute(builder: (_) => const SalesDeliveryCreateScreen());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      Size size = MediaQuery.of(_).size;
      return Scaffold(
        appBar: AppBar(
          title: const Center(child: Text("Page Not Found!")),
        ),
        body: Center(
          child: Column(
            children: [
              SizedBox(height: size.height * 0.3,),
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              const Text("ERROR: 404 Not Found!"),
            ],
          ),
        ),
      );
    });
  }
}