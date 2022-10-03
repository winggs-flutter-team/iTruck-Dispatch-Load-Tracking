import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/web_symbols_icons.dart';
import 'package:itruck_dispatch/constants.dart';
import 'package:itruck_dispatch/models/delivery_model.dart';
import 'package:itruck_dispatch/size_config.dart';
import 'package:search_map_location/utils/google_search/place.dart';
import 'package:search_map_location/widget/search_widget.dart';

class DeliveryDetailsForm extends StatefulWidget {
  final adddelivery;

  final i;
  final formkey;

  final DeliveryModel delivery;

  const DeliveryDetailsForm(
      {Key? key,
      required this.i,
      required this.adddelivery,
      required this.formkey,
      required this.delivery})
      : super(key: key);

  @override
  State<DeliveryDetailsForm> createState() =>
      _DeliveryDetailsFormState(this.i, this.adddelivery, this.delivery);
}

class _DeliveryDetailsFormState extends State<DeliveryDetailsForm> {
  TextEditingController dateinput = TextEditingController();
  TextEditingController timeinput = TextEditingController();

  DeliveryModel delivery;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String? get _dateerrorText {
    // at any time, we can get the text from _controller.value.text
    final text = dateinput.value.text;
    // Note: you can do your own custom validation here
    // Move this logic this outside the widget for more testable code
    if (text.isEmpty) {
      return 'Please enter a date';
    }
    // return null if the text is valid
    return null;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setdateandtime();
  }

  setdateandtime() {
    if (delivery.deliverydate != null) {
      dateinput.text = delivery.deliverydate!;
      timeinput.text = delivery.deliverytime!;
    }
    setState(() {});
  }

  String? get _timeerrorText {
    // at any time, we can get the text from _controller.value.text
    final text = timeinput.value.text;
    // Note: you can do your own custom validation here
    // Move this logic this outside the widget for more testable code
    if (text.isEmpty) {
      return 'Please enter a time';
    }
    // return null if the text is valid
    return null;
  }

  var adddelivery;

  var i;

  _DeliveryDetailsFormState(this.i, this.adddelivery, this.delivery);

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: kPrimaryColor,
                onPrimary: Colors.white,
                onSurface: kPrimaryColor,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  primary: kPrimaryColor,
                ),
              ),
            ),
            child: child!,
          );
        },
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateinput.text = selectedDate.month.toString() +
            '/' +
            selectedDate.day.toString() +
            '/' +
            selectedDate.year.toString();

        delivery.deliverydate = dateinput.text;
        adddelivery(delivery, i);
      });
    }
  }

  _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: kPrimaryColor,
              onPrimary: Colors.white,
              onSurface: kPrimaryColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                primary: kPrimaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
      setState(() {
        timeinput.text =
            selectedTime.format(context); //set the value of text field.
      });
      delivery.deliverydatetime = DateTime.parse(
          DateFormat("yyyy-MM-dd").format(selectedDate) +
              ' ' +
              MaterialLocalizations.of(context)
                  .formatTimeOfDay(picked, alwaysUse24HourFormat: true));
      delivery.deliverytime = timeinput.text;
      adddelivery(delivery, i);
    }
  }

  TextEditingController add = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formkey,
      child: Container(
        child: Column(
          children: [
            // Padding(
            //   padding: const EdgeInsets.only(top: 15.0),
            //   child: TextFormField(
            //     controller: add,
            //     cursorColor: kPrimaryColor,
            //     onChanged: (value) {
            //       setState(() {
            //         delivery.delivery = value;
            //         widget.adddelivery(delivery, widget.i);
            //       });
            //     },
            //     validator: (value) {
            //       if (delivery.delivery == null || delivery.delivery!.isEmpty) {
            //         return 'Please enter some text';
            //       }
            //       return null;
            //     },
            //     onTap: () => showDialog(
            //         context: context,
            //         builder: (BuildContext context) => Scaffold(
            //               body: Center(
            //                 child: SearchLocation(
            //                   apiKey: googleMapsApiKey,
            //                   // The language of the autocompletion
            //                   language: 'en',
            //                   //Search only work for this specific country
            //                   country: 'IN',
            //                   onSelected: (Place place) async {
            //                     final geolocation = await place.geolocation;
            //                     Navigator.of(context).pop();
            //                     setState(() {
            //                       delivery.deliverygeopoint = GeoPoint(
            //                           geolocation!.coordinates.latitude,
            //                           geolocation.coordinates.longitude);
            //                       add.text = place.description;
            //                       delivery.delivery = place.description;
            //                     });
            //                   },
            //                 ),
            //               ),
            //             )),
            //     decoration: InputDecoration(
            //         suffixIcon: Padding(
            //           padding: const EdgeInsets.only(right: 20.0),
            //           child: Icon(
            //             Icons.location_pin,
            //             color: Colors.black,
            //             size: 30,
            //           ),
            //         ),
            //         border: UnderlineInputBorder(),
            //         focusColor: kPrimaryColor,
            //         contentPadding: EdgeInsets.only(left: 30),
            //         focusedBorder: UnderlineInputBorder(
            //             borderSide: BorderSide(color: kPrimaryColor)),
            //         label: Padding(
            //           padding: const EdgeInsets.only(
            //             left: 0.0,
            //           ),
            //           child: Text(
            //             'Delivery',
            //             style: TextStyle(fontSize: 15),
            //           ),
            //         )),
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: SearchLocation(
                // placeholder: 'Delivery',
                placeholder: 'Delivery',
                hasClearButton: false,
                apiKey: googleMapsApiKey,
                // The language of the autocompletion
                language: 'en',
                //Search only work for this specific country
                country: 'US',
                initvalue: delivery.delivery,
                onSelected: (Place place) async {
                  print(place.fullJSON);
                  final geolocation = await place.geolocation;
                  // Navigator.of(context).pop();
                  setState(() {
                    delivery.deliverygeopoint = GeoPoint(
                        geolocation!.coordinates.latitude,
                        geolocation.coordinates.longitude);
                    add.text = place.description;
                    delivery.delivery = place.description;
                    widget.adddelivery(delivery, widget.i);
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: TextFormField(
                cursorColor: kPrimaryColor,
                onChanged: (value) {
                  setState(() {
                    delivery.companyname = value;
                    widget.adddelivery(delivery, widget.i);
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.sentences,
                initialValue: delivery.companyname,
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
                        'Company Name',
                        style: TextStyle(fontSize: 15),
                      ),
                    )),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Container(
                    width: SizeConfig.screenWidth * 0.4,
                    child: TextFormField(
                      controller: dateinput,
                      onTap: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        _selectDate(context);
                      },
                      cursorColor: kPrimaryColor,
                      validator: (_) {
                        if (dateinput.text == null || dateinput.text.isEmpty) {
                          return 'Please enter a date';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          suffixIcon: Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.black,
                            size: 20,
                          ),
                          isCollapsed: false,
                          hintStyle: TextStyle(fontSize: 15),
                          border: UnderlineInputBorder(),
                          contentPadding: EdgeInsets.only(left: 30, top: 15),
                          focusColor: kPrimaryColor,
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: kPrimaryColor)),
                          hintText: 'Delivery Date'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Container(
                    width: SizeConfig.screenWidth * 0.4,
                    child: TextFormField(
                      controller: timeinput,
                      onTap: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        _selectTime(context);
                      },
                      validator: (_) {
                        if (timeinput.text == null || timeinput.text.isEmpty) {
                          return 'Please enter a time';
                        }
                        return null;
                      },
                      cursorColor: kPrimaryColor,
                      decoration: InputDecoration(
                        suffixIcon: Icon(
                          WebSymbols.clock,
                          color: Colors.black,
                          size: 20,
                        ),
                        border: UnderlineInputBorder(),
                        hintStyle: TextStyle(fontSize: 15),
                        focusColor: kPrimaryColor,
                        contentPadding: EdgeInsets.only(left: 30, top: 15),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: kPrimaryColor)),
                        hintText: 'Delivery Time',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
