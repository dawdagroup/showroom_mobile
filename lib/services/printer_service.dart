import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:intl/intl.dart';
import '../config/config.dart';
import '../modals/invoice_details_modal.dart';
import '../modals/payment_details_modal.dart';

class PrinterService {
  static const _port = 9100;
  static const _connectionTimeout = Duration(seconds: 10);
  static const _maxRetries = 3;
  static var _currencyFormat =  NumberFormat('#,##0.00');
  static var _dateFormat = DateFormat('dd/MM/yy');

  final String printerIp;
  final int port;

  PrinterService({required this.printerIp, this.port = _port});

  /// Test printer connectivity before printing
  Future<bool> testConnection() async {
    try {
      final profile = await CapabilityProfile.load();
      final printer = NetworkPrinter(PaperSize.mm80, profile);
      final result = await printer.connect(printerIp, port: port, timeout: _connectionTimeout);
      
      if (result == PosPrintResult.success) {
        printer.disconnect();
        return true;
      } else {
        printer.disconnect();
        return false;
      }
    } catch (e) {
      print("Connection test failed: $e");
      return false;
    }
  }

  /// Get detailed connection information for debugging
  Future<Map<String, dynamic>> getConnectionInfo() async {
    Map<String, dynamic> info = {
      'printer_ip': printerIp,
      'port': port,
      'timeout_seconds': _connectionTimeout.inSeconds,
      'max_retries': _maxRetries,
    };
    
    try {
      final stopwatch = Stopwatch()..start();
      bool connected = await testConnection();
      stopwatch.stop();
      
      info['connection_successful'] = connected;
      info['connection_time_ms'] = stopwatch.elapsedMilliseconds;
      
      if (!connected) {
        info['possible_issues'] = [
          'Printer is powered off',
          'Network connectivity issues', 
          'Incorrect IP address: $printerIp',
          'Port $port is blocked or incorrect',
          'Printer is busy with another job',
          'Firewall blocking connection'
        ];
      }
      
    } catch (e) {
      info['connection_successful'] = false;
      info['error'] = e.toString();
    }
    
    return info;
  }

  Future<void> printReceipt(InvoiceDetailsModal invoiceDetails, Map<String, String> pointsSummary, PaymentDetailsModal? paymentDetailsModal) async {
    NetworkPrinter? printer;
    int attempts = 0;
    
    while (attempts < _maxRetries) {
      try {
        print("Printing attempt ${attempts + 1} of $_maxRetries");
        
        final profile = await CapabilityProfile.load();
        printer = NetworkPrinter(PaperSize.mm80, profile);

        // String printerIp = '192.168.0.168'; // Replace with actual printer IP

        // Set connection timeout and connect
        final result = await printer.connect(printerIp, port: port, timeout: _connectionTimeout);

        if (result != PosPrintResult.success) {
          printer.disconnect();
          throw Exception('Printer connection failed: ${result.msg}');
        }

        print("Connected to printer successfully");
        _generateReceiptContent(printer, invoiceDetails, pointsSummary, paymentDetailsModal);
        printer.disconnect();
        print("Print job completed successfully");
        return; // Success, exit the retry loop
        
      } catch (e) {
        attempts++;
        print("Print attempt $attempts failed: $e");
        
        if (printer != null) {
          try {
            printer.disconnect();
          } catch (disconnectError) {
            print("Error disconnecting printer: $disconnectError");
          }
        }
        
        if (attempts >= _maxRetries) {
          // All retries exhausted
          throw Exception('Printing failed after $_maxRetries attempts. Last error: $e');
        }
        
        // Wait before retrying
        await Future.delayed(Duration(seconds: 2 * attempts));
      }
    }
  }

  void _generateReceiptContent(NetworkPrinter printer, InvoiceDetailsModal details, Map<String, String> points, PaymentDetailsModal? paymentDetailsModal) {
    var pointsRedeemed = points['Points Redeemed'] ?? 0;
    _printHeader(printer);
    _printCustomerInfo(printer, details);
    if (points.isNotEmpty) {
      _printLoyaltyPoints(printer, points);
    }
    _printItemsTable(printer, details.invoiceItems);
    _printTotals(printer, details, double.parse(pointsRedeemed.toString()));
    _printPaymentDetails(printer, details, paymentDetailsModal);
    _printFooter(printer, details.servedBy);

    _printDeliveryTermsInfo(printer, [
      {'DET': 'Delivery Terms'},
      {'TBD': 'To Be Delivered'},
      {'CBC': 'Collected By Customer'},
    ]);

    if (details.fiscalizationNumber != null) {

      if(Config.releaseRegion == "UGANDA"){
        _printControlUnitInfo(printer, [
          {'FDN No': details.fiscalizationNumber ?? 'N/A'},
          {'Verification Code': details.cuSerial ?? 'N/A'},
          {'Invoice ID': details.cuDate ?? 'N/A'},
        ]);

        _printQRCode(printer, details.qrCodeLink!);

      }else{
        _printControlUnitInfo(printer, [
          {'SCU Date': details.cuDate ?? 'N/A'},
          {'SCU ID': details.cuSerial ?? 'N/A'},
          {'SCU Serial No': details.cuSerial != null && details.fiscalizationNumber != null 
              ? "${details.cuSerial}/${details.fiscalizationNumber}" 
              : 'N/A'},
        ]);

        _printQRCode(printer, details.qrCodeLink!);
      }

    }else{

      if(Config.releaseRegion == "UGANDA"){
        _printControlUnitInfo(printer, [
          {'FDN No': 'N/A'},
          {'Verification Code': 'N/A'},
          {'Invoice ID': 'N/A'},
        ]);
      }else{
        _printControlUnitInfo(printer, [{'SCU Date': 'N/A'}, {'SCU ID': 'N/A'}, {'SCU Serial No': 'N/A'},]);
      }
    }

    printer.feed(2);
    printer.cut();
  }

  void _printHeader(NetworkPrinter printer) {
    printer
      ..setStyles(Styles.header)
      ..text('           ${Config.regionName}')
      ..text('     ${Config.regionPoBox}')
      ..text('           Email: ${Config.regionEmail}')
      ..text('        Toll Free No: ${Config.regionTelephone}')
      ..text('           ${Config.taxPinName}: ${Config.taxPinValue}')
      ..emptyLines(1)
      ..text('               INVOICE    ')
      ..emptyLines(1);
  }

  void _printCustomerInfo(NetworkPrinter printer, InvoiceDetailsModal details) {
    printer
      ..setStyles(Styles.leftBold)
      ..text('Showroom Name #: ${details.showroomName}')
      ..text('Cash Sale #: ${details.invoiceNumber}')
      ..text('Date/Time: ${_dateFormat.format(details.invoiceDate)} ${details.invoiceTime}')
      ..text('Customer Name: ${details.customerName}')
      ..text('Cust PIN No: ${details.customerKraPin ?? 'N/A'}')
      ..emptyLines(1);
  }

  void _printItemsTable(NetworkPrinter printer, List<InvoiceItem> items) {
    printer
      ..text('-' * 42)
      ..text('ITEM${' ' * 5}DET${' ' * 4}QTY${' ' * 5}PRICE${' ' * 5}AMOUNT(KES)')
      ..text('-' * 42);

    for (final item in items) {
      final total = item.itemPriceAfVat * item.quantity;
      printer.text(
        _formatColumn(item.itemGroup + '-' + item.itemModelNo, 20)
      );

      String deliveryStatus = 'CBC';
      if (item.itemWarehouseCode.toString().contains('03')){
        deliveryStatus = "TBD";
      }
      
      printer.text(
        '${' ' * 4}${_formatColumn(deliveryStatus, 0)}'
        '${' ' * 6}${_formatColumn(item.quantity.toString(), 5)}'
        '${' ' * 1}${_formatColumn(_currencyFormat.format(item.itemPriceAfVat), 10)}'
        '${' ' * 2}${_formatColumn(_currencyFormat.format(total), 12)}',
      );
    }
    printer.text('-' * 42);
  }

  void _printTotals(NetworkPrinter printer, InvoiceDetailsModal details, double pointsRedeemed) {
    final subTotal = details.invoiceTotal - details.invoiceVatTotal;

    printer
      ..text('TOTAL ITEMS:${' ' * 29}${details.invoiceItems.length}')
      ..text('-' * 42)
      ..text(_leftRightAlign('SUB-TOTAL:', _formatCurrency(subTotal, 0)))
      ..text(_leftRightAlign('VAT:', _formatCurrency(details.invoiceVatTotal, 0)))
      ..text(_leftRightAlign('TOTAL:', _formatCurrency(details.invoiceTotal, 0)))
      ..text('-' * 42)
      ..text('CODE    RATE     VATABLE AMT       VAT AMT')
      ..text('A        16%    ${_formatCurrency(subTotal, 0)}    ${_formatCurrency(details.invoiceVatTotal, 0)}')
      ..text('-' * 42)
      ..text(_leftRightAlign('TOTAL:', _formatCurrency(details.invoiceTotal, 0)))
      ..text(_leftRightAlign('SHUKRANI AMT:', _formatCurrency(pointsRedeemed, 0)))
      ..text(_leftRightAlign('NET PAYABLE:', _formatCurrency(details.invoiceTotal - pointsRedeemed, 0)))
      ..text('-' * 42);
  }

  void _printPaymentDetails(NetworkPrinter printer, InvoiceDetailsModal details, PaymentDetailsModal? paymentDetailsModal) {
    // Handle null payment details by setting default values
    double cashAmount = paymentDetailsModal?.cashAmount ?? 0.0;
    double mpesaAmount = paymentDetailsModal?.mpesaAmount ?? 0.0;
    double creditCardAmount = paymentDetailsModal?.creditCardAmount ?? 0.0;
    
    double totalPaid = cashAmount + mpesaAmount + creditCardAmount;

    List<String> creditCustomersCodes = ["CL000202", "CL000198"];
    if (creditCustomersCodes.contains(details.cardCode)) {
      printer
        ..text('PAYMENT DETAILS')
        ..text('-' * 42)
        ..text(_leftRightAlign('Credited To:', details.cardName ?? 'N/A'));
    }else {
      printer
        ..text('PAYMENT DETAILS')
        ..text('-' * 42)
        ..text(_leftRightAlign('CASH:', _formatCurrency(cashAmount, 0)))
        ..text(_leftRightAlign('MPESA:', _formatCurrency(mpesaAmount, 0)))
        ..text(_leftRightAlign('CREDIT CARD:', _formatCurrency(creditCardAmount, 0)))
        ..text(_leftRightAlign('GIFT VOUCHER:', _formatCurrency(0, 0)))
        ..text(_leftRightAlign('CHEQUE:', _formatCurrency(0, 0)))
        ..emptyLines(1)
        ..text(_leftRightAlign('TOTAL PAID:', _formatCurrency(totalPaid, 0)))
        ..text(_leftRightAlign('CHANGE:', _formatCurrency(totalPaid - details.invoiceTotal, 0)));
    }
  }

  String _leftRightAlign(String label, String value, {int width = 42}) {
    int space = width - label.length - value.length;
    return label + (' ' * space) + value;
  }

  void _printFooter(NetworkPrinter printer, String servedBy) {
    printer
      ..emptyLines(1)
      ..text('-' * 42)
      ..text('PRICES INCLUSIVE OF VAT WHERE APPLICABLE')
      ..text('-' * 42)
      ..emptyLines(1)
      ..text('-' * 42)
      ..text('TERMS AND CONDITIONS:')
      ..text('-' * 42)
      ..text('1. Notify us immediately incase of any     discrepancies on this document')
      ..text('2. Goods once sold are not returnable')
      ..text('3. No cash refund')
      ..text('4. Your data is collected with consent and handled as per our privacy policy')
      ..text('-' * 42)
      ..emptyLines(1)
      ..text('-' * 42)
      ..text('You were served by: $servedBy')
      ..text('-' * 42);
  }

  void _printLoyaltyPoints(NetworkPrinter printer, Map<String, String> points) {
    _printTable(
      printer,
      title: 'Shukrani Loyalty Points Summary',
      rows: points.entries.map((e) => {e.key: e.value}).toList(),
    );
  }

  void _printControlUnitInfo(NetworkPrinter printer, List<Map<String, String>> info) {
    _printTable(
      printer,
      title: 'SCU Information',
      rows: info,
    );
  }

  void _printDeliveryTermsInfo(NetworkPrinter printer, List<Map<String, String>> info) {
    _printTable(
      printer,
      title: 'Delivery Terms',
      rows: info,
    );
  }

  void _printTable(NetworkPrinter printer, {required String title, required List<Map<String, String>> rows}) {
    const columns = [17, 21];
    final separator = '+${'-' * columns[0]}+${'-' * columns[1]}+';

    printer
      ..setStyles(Styles.tableHeader)
      ..text(separator)
      ..text('| $title${' ' * (columns[0] + columns[1] - title.length - 2)} |')
      ..text(separator)
      ..setStyles(Styles.tableBody);

    for (final row in rows) {
      final entry = row.entries.first;
      printer.text(
        '| ${_formatColumn(entry.key, columns[0] - 2)} '
        '| ${_formatColumn(entry.value, columns[1] - 2, alignRight: true)} |',
      );
      printer.text(separator);
    }
  }

  void _printQRCode(NetworkPrinter printer, String qrCodeLink) {
    printer.qrcode(
      qrCodeLink,
      size: QRSize.Size6,
      align: PosAlign.center,
    );
  }

  String _formatColumn(dynamic content, int width, {bool alignRight = false}) {
    final text = content.toString();
    return alignRight ? text.padLeft(width) : text.padRight(width);
  }

  String _formatCurrency(double amount, int padding) {
    return _currencyFormat.format(amount).padLeft(padding);
  }
}

class Styles {
  static const header = PosStyles(
    align: PosAlign.center,
    bold: true,
    height: PosTextSize.size5,
    width: PosTextSize.size5,
  );

  static const leftBold = PosStyles(
    align: PosAlign.left,
    bold: true,
    height: PosTextSize.size5,
    width: PosTextSize.size5,
  );

  static const tableHeader = PosStyles(
    bold: true,
    align: PosAlign.center,
  );

  static const tableBody = PosStyles(
    bold: false,
    align: PosAlign.left,
  );
}