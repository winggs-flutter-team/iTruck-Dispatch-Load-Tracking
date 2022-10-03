import 'package:flutter/material.dart';
import 'package:itruck_dispatch/constants.dart';
import 'package:itruck_dispatch/models/driver_model.dart';

class DriverDetailsForm extends StatefulWidget {
  final adddriver;

  final i;
  final formkey;

  final DriverModel driver;

  const DriverDetailsForm(
      {Key? key,
      required this.adddriver,
      required this.i,
      required this.formkey,
      required this.driver})
      : super(key: key);

  @override
  State<DriverDetailsForm> createState() => DriverDetailsFormState(this.driver);
}

class DriverDetailsFormState extends State<DriverDetailsForm> {
  DriverModel driver;

  DriverDetailsFormState(this.driver);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formkey,
      child: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: TextFormField(
                cursorColor: kPrimaryColor,
                onChanged: (value) {
                  setState(() {
                    driver.name = value;
                    widget.adddriver(driver, widget.i);
                  });
                },
                initialValue: driver.name,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(left: 30),
                    border: UnderlineInputBorder(),
                    focusColor: kPrimaryColor,
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: kPrimaryColor)),
                    label: Padding(
                      padding: const EdgeInsets.only(
                        left: 0.0,
                      ),
                      child: Text(
                        'Driver Name',
                        style: TextStyle(fontSize: 15),
                      ),
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: TextFormField(
                cursorColor: kPrimaryColor,
                onChanged: (value) {
                  setState(() {
                    driver.phonenumber = value;
                    widget.adddriver(driver, widget.i);
                  });
                },
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  } else if (!RegExp(r'(^[0-9]{10}$)').hasMatch(value)) {
                    return 'Please enter valid phonenumber';
                    // ignore: unrelated_type_equality_checks
                  }
                  return null;
                },
                initialValue: driver.phonenumber,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(left: 30),
                    border: UnderlineInputBorder(),
                    focusColor: kPrimaryColor,
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: kPrimaryColor)),
                    label: Padding(
                      padding: const EdgeInsets.only(
                        left: 0.0,
                      ),
                      child: Text(
                        'Driver Contact',
                        style: TextStyle(fontSize: 15),
                      ),
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
