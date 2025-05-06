import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:intl/intl.dart';

import '../modals/invoice_details_modal.dart';

class PrinterService {
  final String printerIp;
  final int port;

  PrinterService({required this.printerIp, this.port = 9100});

  Future<void> printReceipt(InvoiceDetailsModal invoiceDetails, Map<String, String> pointsSummary) async {
    try {
      // Load the printer profile
      final profile = await CapabilityProfile.load();

      // Initialize the printer
      final printer = NetworkPrinter(PaperSize.mm80, profile);

      // Attempt to connect to the printer
      final PosPrintResult res = await printer.connect(printerIp, port: port);

      if (res == PosPrintResult.success) {
        // Print the receipt
        _generateSmallReceipt(printer, invoiceDetails, pointsSummary);

        // Disconnect after printing
        printer.disconnect();
      } else {
        throw Exception('Could not connect to printer: ${res.msg}');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  void _generateSmallReceipt(NetworkPrinter printer, InvoiceDetailsModal invoiceDetails, Map<String, String> pointsSummary) {
    printer.setStyles(const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size5, width: PosTextSize.size5));
    printer.text('           APPLIANCE ZONE LIMITED');
    printer.text('     P.O.BOX 82580-80100 Mombasa Kenya');
    printer.text('           Email: info@azone.co.ke');
    printer.text('        Toll Free No: 0800 722242');
    printer.text('           PIN No: P051633009W');

    printer.emptyLines(2);

    printer.setStyles(const PosStyles(align: PosAlign.left, bold: true, height: PosTextSize.size5, width: PosTextSize.size5));
    printer.text('Cash Sale #: ${invoiceDetails.invoiceNumber}');
    printer.text('Date/Time: ${DateFormat('dd/MM/yy').format(invoiceDetails.invoiceDate)}');
    printer.text('Customer Name: ${invoiceDetails.customerName}');
    printer.text('Cust PIN No: ${invoiceDetails.customerKraPin ?? 'N/A'}');

    printer.emptyLines(1);
    printer.text('------------------------------------------');
    printer.text('ITEM            QTY     PRICE       AMOUNT');
    printer.text('------------------------------------------');

    for (var item in invoiceDetails.invoiceItems) {
      double itemTotal = item.itemPriceAfVat * item.quantity;
      printer.text('${item.itemGroup + '-' + item.itemModelNo}        ${item.quantity}       ${NumberFormat.simpleCurrency(name: "KES ", decimalDigits: 2).format(item.itemPriceAfVat)}      ${NumberFormat.simpleCurrency(name: "KES ", decimalDigits: 2).format(itemTotal)}');
    }

    printer.text('------------------------------------------');
    printer.text('TOTAL ITEMS:                             ${invoiceDetails.invoiceItems.length}');
    printer.text('------------------------------------------');
    double subTotal = invoiceDetails.invoiceTotal - invoiceDetails.invoiceVatTotal;
    printer.text('SUB-TOTAL:                  ${NumberFormat.simpleCurrency(name: "KES ", decimalDigits: 2).format(subTotal)}');
    printer.text('VAT:                        ${NumberFormat.simpleCurrency(name: "KES ", decimalDigits: 2).format(invoiceDetails.invoiceVatTotal)}');
    printer.text('TOTAL:                      ${NumberFormat.simpleCurrency(name: "KES ", decimalDigits: 2).format(invoiceDetails.invoiceTotal)}');
    printer.text('------------------------------------------');
    printer.text('CODE    RATE     VATABLE AMT       VAT AMT');
    printer.text('A        16%      ${NumberFormat.simpleCurrency(name: "KES ", decimalDigits: 2).format(subTotal)}        ${NumberFormat.simpleCurrency(name: "KES ", decimalDigits: 2).format(invoiceDetails.invoiceVatTotal)}');
    printer.text('------------------------------------------');
    printer.text('TOTAL:                        ${NumberFormat.simpleCurrency(name: "KES ", decimalDigits: 2).format(invoiceDetails.invoiceTotal)}');
    printer.text('CASH:                         ${NumberFormat.simpleCurrency(name: "KES ", decimalDigits: 2).format(invoiceDetails.invoiceAmtRecd)}');
    double change = invoiceDetails.invoiceAmtRecd - invoiceDetails.invoiceTotal;
    printer.text('CHANGE:                        ${NumberFormat.simpleCurrency(name: "KES ", decimalDigits: 2).format(change)}');

    printer.emptyLines(1);
    printer.text('------------------------------------------');
    printer.text('PRICES INCLUSIVE OF VAT WHERE APPLICABLE');
    printer.text('------------------------------------------');
    printer.text('You were served by: ${invoiceDetails.servedBy}');
    printer.text('------------------------------------------');

    if(pointsSummary.isNotEmpty){
      _printLoyaltyPointsSummary(printer, pointsSummary);
      printer.emptyLines(1);
    }

    final List<Map<String, String>> controlUnitInfo = [
      {'Date/Time': invoiceDetails.cuDate ?? 'N/A'},
      {'CU Serial': invoiceDetails.cuSerial ?? 'N/A'},
      {'CU No': invoiceDetails.fiscalizationNumber ?? 'N/A'},
    ];

    _printControlUnitTable(printer, controlUnitInfo);

    if(invoiceDetails.fiscalizationNumber != null){
      _printQRCode(printer, invoiceDetails.fiscalizationNumber);
    }

    printer.feed(2);
    printer.cut();
  }

  void _printControlUnitTable(NetworkPrinter printer, List<Map<String, String>> controlUnitInfo) {
    const int col1Width = 17;
    const int col2Width = 21;
    String separator = '+${List.filled(col1Width, '-').join()}+${List.filled(col2Width, '-').join()}+';

    printer.setStyles(const PosStyles(bold: true, align: PosAlign.center));
    printer.text(separator);
    printer.text('|       Control Unit Information        |');
    printer.text(separator);

    printer.setStyles(const PosStyles(bold: false, align: PosAlign.left));
    for (var info in controlUnitInfo) {
      final key = info.keys.first;
      final value = info.values.first;
      String formattedKey = key.padRight(col1Width - 2);
      String formattedValue = value.padRight(col2Width - 2);
      String row = '| $formattedKey | $formattedValue |';
      printer.text(row);
      printer.text(separator);
    }
  }

  void _printQRCode(NetworkPrinter printer, String invoiceNumber) {
    String qrContent = 'https://itax.kra.go.ke/KRA-Portal/invoiceChk.htm?actionCode=loadPage&invoiceNo=$invoiceNumber';
    printer.setStyles(const PosStyles(align: PosAlign.center, bold: false));
    printer.qrcode(qrContent, size: QRSize.Size6, align: PosAlign.center);
  }

  void _printLoyaltyPointsSummary(NetworkPrinter printer, Map<String, String> loyaltyPoints) {
    const int col1Width = 17;
    const int col2Width = 21;
    String separator = '+${List.filled(col1Width, '-').join()}+${List.filled(col2Width, '-').join()}+';

    printer.setStyles(const PosStyles(bold: true, align: PosAlign.center));
    printer.text(separator);
    printer.text('|       Loyalty Points Summary          |');
    printer.text(separator);

    printer.setStyles(const PosStyles(bold: false, align: PosAlign.left));
    for (var entry in loyaltyPoints.entries) {
      String formattedKey = entry.key.padRight(col1Width - 2);
      String formattedValue = entry.value.padLeft(col2Width - 2);
      String row = '| $formattedKey | $formattedValue |';
      printer.text(row);
      printer.text(separator);
    }
  }

}