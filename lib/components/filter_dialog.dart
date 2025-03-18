import 'filter_params.dart';
import 'rounded_buttons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

import '../constant/constants.dart';
import 'labeled_text_field.dart';

class FilterDialog extends StatefulWidget {
  final Function(FilterParams) onSubmit;

  const FilterDialog({Key? key, required this.onSubmit}) : super(key: key);

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController customerNameInputController = TextEditingController();
  final TextEditingController phoneNumberInputController = TextEditingController();
  final TextEditingController fromDateInputController = TextEditingController();
  final TextEditingController toDateInputController = TextEditingController();
  final TextEditingController quotationNoInputController = TextEditingController();

  DateTime selectedFromDate = DateTime.now();
  DateTime selectedToDate = DateTime.now();

  void selectFromDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedFromDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != selectedFromDate) {
      setState(() {
        selectedFromDate = pickedDate;
        fromDateInputController.text = DateFormat('yyyy-MM-dd').format(selectedFromDate);
      });
    }
  }

  void selectToDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedToDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != selectedToDate) {
      setState(() {
        selectedToDate = pickedDate;
        toDateInputController.text = DateFormat('yyyy-MM-dd').format(selectedToDate);
      });
    }
  }

  void submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(FilterParams(
        customerName: customerNameInputController.text,
        phoneNumber: phoneNumberInputController.text,
        fromDate: fromDateInputController.text,
        toDate: toDateInputController.text,
        quotationNo: quotationNoInputController.text,
      ));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.8,
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Header with Image and Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  "assets/images/azone.png",
                  height: 50,
                  width: 50,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.clear,
                    size: 30,
                  ),
                ),
              ],
            ),
            const Text(
              "Filter Sales Quotation",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 10, thickness: 1),
            SizedBox(height: size.height * 0.01),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // From Date Field
                    LabeledDateField(
                      label: "From Date:",
                      hint: "Select From Date",
                      controller: fromDateInputController,
                      selectedDate: selectedFromDate,
                      onDateSelected: selectFromDate,
                      validator: (value) {
                        if(value != null && toDateInputController.text.isNotEmpty){
                          DateFormat formatter = DateFormat('yyyy-MM-dd');
                          DateTime fromDateParsed = formatter.parseStrict(fromDateInputController.text);
                          DateTime toDateParsed = formatter.parseStrict(toDateInputController.text);

                          if(fromDateParsed.isAfter(toDateParsed)){
                            return 'From date cannot be greater than to date';
                          }
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: size.height * 0.01),
                    // To Date Field
                    LabeledDateField(
                      label: "To Date:",
                      hint: "Select To Date",
                      controller: toDateInputController,
                      selectedDate: selectedToDate,
                      onDateSelected: selectToDate,
                      validator: (value) {
                        if(value != null && fromDateInputController.text.isNotEmpty){
                          DateFormat formatter = DateFormat('yyyy-MM-dd');
                          DateTime fromDateParsed = formatter.parseStrict(fromDateInputController.text);
                          DateTime toDateParsed = formatter.parseStrict(toDateInputController.text);

                          if(toDateParsed.isBefore(fromDateParsed)){
                            return 'To date cannot be less than from date';
                          }
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: size.height * 0.01),
                    // Quotation Number Field
                    LabeledTextField(
                      label: "Quotation Number:",
                      hint: "Enter Quotation Number",
                      controller: quotationNoInputController,
                      validator: (value) {
                        return null;
                      },
                    ),
                    SizedBox(height: size.height * 0.01),
                    // Customer Name Field
                    LabeledTextField(
                      label: "Customer Name:",
                      hint: "Enter Customer Name",
                      controller: customerNameInputController,
                      validator: (value) {
                        return null;
                      },
                    ),
                    SizedBox(height: size.height * 0.01),
                    // Phone Number Field
                    IntlPhoneField(
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                      initialCountryCode: 'KE',
                      controller: phoneNumberInputController,
                      onChanged: (phone) {},
                      disableLengthCheck: true,
                      validator: (PhoneNumber? value) {

                        if (value != null && value.completeNumber.isNotEmpty && !RegExp(r'^(\+254|254)?(11\d{7}|7\d{8})$').hasMatch(value.completeNumber)) {
                          return 'Please enter a valid Kenyan phone number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: size.height * 0.01),
                    // Submit Button
                    RoundedButton(
                      btnText: "Filter Sales Quotation",
                      press: submit,
                      btnColor: kSecondaryColor,
                      textColor: kPrimaryLightColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Reusable Labeled Date Field Widget
class LabeledDateField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final DateTime selectedDate;
  final VoidCallback onDateSelected;
  final String? Function(String?)? validator;

  const LabeledDateField({
    Key? key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.selectedDate,
    required this.onDateSelected,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            const Text("*", style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1.0),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              readOnly: true,
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                suffixIcon: IconButton(
                  onPressed: onDateSelected,
                  icon: const Icon(Icons.calendar_month_outlined, color: kSecondaryColor),
                ),
              ),
              validator: validator,
            ),
          ),
        ),
      ],
    );
  }
}


