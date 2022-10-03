// import 'package:address_search_field/address_search_field.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:search_map_location/search_map_location.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/web_symbols_icons.dart';
import 'package:itruck_dispatch/constants.dart';

import 'package:intl/intl.dart';
import 'package:itruck_dispatch/models/pickup_model.dart';

import 'package:itruck_dispatch/size_config.dart';
import 'package:itruck_dispatch/views/dispatcher/screens/post_load_screen.dart';
import 'package:provider/provider.dart';
import 'package:search_map_location/utils/google_search/latlng.dart';
import 'package:search_map_location/utils/google_search/place.dart';

class PickupDetailsForm extends StatefulWidget {
  final i;

  final addpickup;
  final formkey;

  final PickupModel pickup;

  const PickupDetailsForm(
      {Key? key,
      required this.i,
      required this.addpickup,
      required this.formkey,
      required this.pickup})
      : super(key: key);

  @override
  State<PickupDetailsForm> createState() =>
      PickupDetailsFormState(this.addpickup, this.i, this.pickup);
}

class PickupDetailsFormState extends State<PickupDetailsForm> {
  TextEditingController dateinput = TextEditingController();
  TextEditingController timeinput = TextEditingController();
  // PickupModel pickup = PickupModel();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setdateandtime();
  }

  setdateandtime() {
    if (pickup.pickupdate != null) {
      dateinput.text = pickup.pickupdate!;
      timeinput.text = pickup.pickuptime!;
    }
    setState(() {});
  }

  final addpickup;
  final i;
  PickupModel pickup;
  PickupDetailsFormState(this.addpickup, this.i, this.pickup);
  // final geoMethods = GeoMethods(
  //   googleApiKey: googleMapsApiKey,
  //   language: 'en',
  //   countryCode: 'ec',
  // );

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
      print(picked.toString());
      setState(() {
        selectedDate = picked;
        dateinput.text = selectedDate.month.toString() +
            '/' +
            selectedDate.day.toString() +
            '/' +
            selectedDate.year.toString();
        pickup.pickupdate = dateinput.text;
        pickup.pickupdatetime = selectedDate;
        addpickup(pickup, i);
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
      print(DateTime.parse(DateFormat("yyyy-MM-dd").format(DateTime.now()) +
          ' ' +
          MaterialLocalizations.of(context)
              .formatTimeOfDay(picked, alwaysUse24HourFormat: true)));
      setState(() {
        selectedTime = picked;
      });

      setState(() {
        timeinput.text =
            selectedTime.format(context); //set the value of text field.
      });
      pickup.pickuptime = timeinput.text;
      pickup.pickupdatetime = DateTime.parse(
          DateFormat("yyyy-MM-dd").format(selectedDate) +
              ' ' +
              MaterialLocalizations.of(context)
                  .formatTimeOfDay(picked, alwaysUse24HourFormat: true));
      addpickup(pickup, i);
    }
  }

  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: googleMapsApiKey);
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
            //     cursorColor: kPrimaryColor,
            //     onChanged: (value) {
            //       setState(() {
            //         pickup.pickup = value;
            //         widget.addpickup(pickup, widget.i);
            //       });
            //     },
            //     onTap: () => showDialog(
            //         context: context,
            //         builder: (BuildContext context) => AlertDialog(
            //               content: SearchLocation(
            //                 apiKey: googleMapsApiKey,
            //                 // The language of the autocompletion
            //                 language: 'en',
            //                 //Search only work for this specific country
            //                 country: 'IN',
            //                 onSelected: (Place place) async {
            //                   print(place.fullJSON);
            //                   final geolocation = await place.geolocation;
            //                   Navigator.of(context).pop();
            //                   setState(() {
            //                     pickup.pickupgeopoint = GeoPoint(
            //                         geolocation!.coordinates.latitude,
            //                         geolocation.coordinates.longitude);
            //                     add.text = place.description;
            //                     pickup.pickup = place.description;
            //                   });
            //                 },
            //               ),
            //             )),
            //     validator: (value) {
            //       if (pickup.pickup == null || pickup.pickup!.isEmpty) {
            //         return 'Please enter some text';
            //       }
            //       return null;
            //     },
            //     controller: add,
            //     readOnly: true,
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
            //             'Pickup',
            //             style: TextStyle(fontSize: 15),
            //           ),
            //         )),
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: SearchLocation(
                // placeholder: 'Pickup',
                placeholder: 'Pickup',

                hasClearButton: false,
                apiKey: googleMapsApiKey,
                // The language of the autocompletion
                language: 'en',
                //Search only work for this specific country

                country: 'US',
                initvalue: pickup.pickup,
                onSelected: (Place place) async {
                  print(place.fullJSON);

                  final geolocation = await place.geolocation;
                  // Navigator.of(context).pop();
                  setState(() {
                    pickup.pickupgeopoint = GeoPoint(
                        geolocation!.coordinates.latitude,
                        geolocation.coordinates.longitude);
                    add.text = place.description;
                    pickup.pickup = place.description;
                    widget.addpickup(pickup, widget.i);
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
                    pickup.companyname = value;
                    widget.addpickup(pickup, widget.i);
                  });
                },
                textCapitalization: TextCapitalization.sentences,
                initialValue: pickup.companyname,
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
                          border: UnderlineInputBorder(),
                          contentPadding: EdgeInsets.only(left: 30, top: 15),
                          focusColor: kPrimaryColor,
                          hintStyle: TextStyle(fontSize: 15),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: kPrimaryColor)),
                          hintText: 'Pickup Date'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Container(
                    width: SizeConfig.screenWidth * 0.4,
                    child: TextFormField(
                      controller: timeinput,
                      onTap: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        _selectTime(context);
                      },
                      cursorColor: kPrimaryColor,
                      validator: (_) {
                        if (timeinput.text == null || timeinput.text.isEmpty) {
                          return 'Please enter a time';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        suffixIcon: Icon(
                          WebSymbols.clock,
                          color: Colors.black,
                          size: 20,
                        ),
                        hintStyle: TextStyle(fontSize: 15),
                        border: UnderlineInputBorder(),
                        focusColor: kPrimaryColor,
                        contentPadding: EdgeInsets.only(left: 30, top: 15),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: kPrimaryColor)),
                        hintText: 'Pickup Time',
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
