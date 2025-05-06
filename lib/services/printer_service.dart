import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:intl/intl.dart';
import '../modals/invoice_details_modal.dart';
import '../modals/payment_details_modal.dart';

class PrinterService {
  static const _port = 9100;
  static var _currencyFormat =  NumberFormat('#,##0.00');
  static var _dateFormat = DateFormat('dd/MM/yy');

  final String printerIp;
  final int port;

  PrinterService({required this.printerIp, this.port = _port});

  Future<void> printReceipt(InvoiceDetailsModal invoiceDetails, Map<String, String> pointsSummary, PaymentDetailsModal? paymentDetailsModal) async {
    try {
      final profile = await CapabilityProfile.load();
      final printer = NetworkPrinter(PaperSize.mm80, profile);
      final result = await printer.connect(printerIp, port: port);

      if (result != PosPrintResult.success) {
        printer.disconnect();
        throw Exception('Printer connection failed: ${result.msg}');
      }

      _generateReceiptContent(printer, invoiceDetails, pointsSummary, paymentDetailsModal);
      printer.disconnect();
    } catch (e) {
      throw Exception('Printing error: $e');
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
      {'CBC': 'Colleced By Customer'},
    ]);

    _printControlUnitInfo(printer, [
      {'Date/Time': details.cuDate ?? 'N/A'},
      {'CU Serial': details.cuSerial ?? 'N/A'},
      {'CU No': details.fiscalizationNumber ?? 'N/A'},
    ]);


    if (details.fiscalizationNumber != null) {
      _printQRCode(printer, details.fiscalizationNumber!);
    }

    printer.feed(2);
    printer.cut();
  }

  void _printHeader(NetworkPrinter printer) {
    printer
      ..setStyles(Styles.header)
      ..text('           APPLIANCE ZONE LIMITED')
      ..text('     P.O.BOX 82580-80100 Mombasa Kenya')
      ..text('           Email: info@azone.co.ke')
      ..text('        Toll Free No: 0800 722242')
      ..text('           PIN No: P051633009W')
      ..emptyLines(1)
      ..text('               TAX INVOICE    ')
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
    double totalPaid = paymentDetailsModal!.cashAmount + paymentDetailsModal.mpesaAmount + paymentDetailsModal.creditCardAmount;

    printer
      ..text('PAYMENT DETAILS')
      ..text('-' * 42)
      ..text(_leftRightAlign('CASH:', _formatCurrency(paymentDetailsModal.cashAmount, 0)))
      ..text(_leftRightAlign('MPESA:', _formatCurrency(paymentDetailsModal.mpesaAmount, 0)))
      ..text(_leftRightAlign('CREDIT CARD:', _formatCurrency(paymentDetailsModal.creditCardAmount, 0)))
      ..text(_leftRightAlign('GIFT VOUCHER:', _formatCurrency(0, 0)))
      ..text(_leftRightAlign('CHEQUE:', _formatCurrency(0, 0)))
      ..emptyLines(1)
      ..text(_leftRightAlign('TOTAL PAID:', _formatCurrency(totalPaid, 0)))
      ..text(_leftRightAlign('CHANGE:', _formatCurrency(totalPaid - details.invoiceTotal, 0)));
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
      title: 'Control Unit Information',
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

  void _printQRCode(NetworkPrinter printer, String invoiceNumber) {
    printer.qrcode(
      'https://itax.kra.go.ke/KRA-Portal/invoiceChk.htm?'
      'actionCode=loadPage&invoiceNo=$invoiceNumber',
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