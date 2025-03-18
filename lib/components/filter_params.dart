class FilterParams {
  final String customerName;
  final String phoneNumber;
  final String fromDate;
  final String toDate;
  final String quotationNo;

  FilterParams({
    required this.customerName,
    required this.phoneNumber,
    required this.fromDate,
    required this.toDate,
    required this.quotationNo,
  });
}

class FilterSalesOrderParams {
  final String customerName;
  final String phoneNumber;
  final String fromDate;
  final String toDate;
  final String salesOrderNo;

  FilterSalesOrderParams({
    required this.customerName,
    required this.phoneNumber,
    required this.fromDate,
    required this.toDate,
    required this.salesOrderNo,
  });
}

class FilterInvoiceParams {
  final String customerName;
  final String phoneNumber;
  final String fromDate;
  final String toDate;
  final String invoiceNumber;

  FilterInvoiceParams({
    required this.customerName,
    required this.phoneNumber,
    required this.fromDate,
    required this.toDate,
    required this.invoiceNumber,
  });
}

