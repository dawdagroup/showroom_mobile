// This file contains the code for the filter complaint dialog box

import 'package:flutter/material.dart';
import '../config/config.dart';
import 'filter_complaint_params.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'rounded_buttons.dart';

import 'labeled_text_field.dart';
import '../constant/constants.dart';
import 'labeled_date_field.dart';


class FilterComplaintDialog extends StatefulWidget {
  final Function(FilterComplaintParams) onSubmit;
  const FilterComplaintDialog({super.key, required this.onSubmit});

  @override
  _FilterComplaintDialogState createState() => _FilterComplaintDialogState();
}

class _FilterComplaintDialogState extends State<FilterComplaintDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController customerNameInputController = TextEditingController();
  final TextEditingController phoneNumberInputController = TextEditingController();
  final TextEditingController fromDateInputController = TextEditingController();
  final TextEditingController toDateInputController = TextEditingController();
  final TextEditingController complaintNoInputController = TextEditingController();

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
      widget.onSubmit(FilterComplaintParams(
        consumerName: customerNameInputController.text,
        consumerPhoneNo: phoneNumberInputController.text,
        fromDate: fromDateInputController.text,
        toDate: toDateInputController.text,
        complaintNo: complaintNoInputController.text,
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
            const Text("Filter Complaint", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
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
                    LabeledTextField(
                      label: "Complaint Number:",
                      hint: "Enter Complaint Number",
                      controller: complaintNoInputController,
                      validator: (value) {
                        return null;
                      },
                    ),
                    SizedBox(height: size.height * 0.01),
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
                    const Row(
                      children: [
                        Text("Phone Number:", style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(width: 4),
                        Text("*", style: TextStyle(color: Colors.red)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    IntlPhoneField(
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                      initialCountryCode: Config.releaseRegion == "UGANDA" ? 'UG' : 'KE',
                      controller: phoneNumberInputController,
                      onChanged: (phone) {},
                      disableLengthCheck: true,
                      validator: (PhoneNumber? value) {

                        if(Config.releaseRegion == "UGANDA"){
                          if (value != null && value.completeNumber.isNotEmpty && !RegExp(r'^(\+256|256)?(7\d{8}|4\d{8})$').hasMatch(value.completeNumber)) {
                            return 'Please enter a valid Ugandan phone number';
                          }
                          return null;
                        }

                        if (value != null && value.completeNumber.isNotEmpty && !RegExp(r'^(\+254|254)?(11\d{7}|7\d{8})$').hasMatch(value.completeNumber)) {
                          return 'Please enter a valid Kenyan phone number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: size.height * 0.01),
                    // Submit Button
                    RoundedButton(
                      btnText: "Filter Complaint",
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

