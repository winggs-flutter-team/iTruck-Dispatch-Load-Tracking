import 'package:flutter/material.dart';
import 'package:itruck_dispatch/constants.dart';
import 'package:itruck_dispatch/functions/dispatcher_functions.dart';
import 'package:itruck_dispatch/globals.dart';
import 'package:itruck_dispatch/models/delivery_model.dart';
import 'package:itruck_dispatch/models/driver_model.dart';
import 'package:itruck_dispatch/models/load_model.dart';
import 'package:itruck_dispatch/models/pickup_model.dart';
import 'package:itruck_dispatch/size_config.dart';
import 'package:itruck_dispatch/textstyles.dart';
import 'package:itruck_dispatch/views/dispatcher/screens/loads_screen.dart';
import 'package:itruck_dispatch/views/dispatcher/widgets/bottomnavbar.dart';
import 'package:itruck_dispatch/views/dispatcher/widgets/delivery_details_form.dart';
import 'package:itruck_dispatch/views/dispatcher/widgets/dispatcher_drawer.dart';
import 'package:itruck_dispatch/views/dispatcher/widgets/driver_details_form.dart';
import 'package:itruck_dispatch/views/dispatcher/widgets/pickup_details_form.dart';
import 'package:itruck_dispatch/views/widgets/header.dart';
import 'package:itruck_dispatch/views/widgets/loading.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

class UpdateLoadScreen extends StatefulWidget {
  final LoadModel load;

  const UpdateLoadScreen({Key? key, required this.load}) : super(key: key);

  @override
  State<UpdateLoadScreen> createState() => UpdateLoadScreenState(this.load);
}

class UpdateLoadScreenState extends State<UpdateLoadScreen> {
  int _pickupCount = 0;
  int _deliveryCount = 0;
  int _driverCount = 0;
  int _notescount = 0;

  List pickupforms = [];
  List deliveryforms = [];
  List driverforms = [];

  List<PickupModel> pickups = [];
  List<DeliveryModel> deliveries = [];
  List<DriverModel> drivers = [];
  List<GlobalKey<FormState>> driverdetailsformKey = [];
  List<GlobalKey<FormState>> deliverydetailsformKey = [];
  List<GlobalKey<FormState>> pickupdetailsformKey = [];
  final _formkey = GlobalKey<FormState>();
  String? pickupLoadNumber;
  String? deliveryLoadNumber;

  bool validform = true;

  String? notes;

  LoadModel load;

  UpdateLoadScreenState(this.load);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setload();
  }

  setload() {
    _pickupCount = widget.load.pickups!.length;
    _deliveryCount = widget.load.deliveries!.length;
    _driverCount = widget.load.drivers!.length;
    pickups = widget.load.pickups!;
    deliveries = widget.load.deliveries!;
    drivers = widget.load.drivers!;
    pickupLoadNumber = widget.load.loadnumber;
    setState(() {});
    for (var i = 0; i < _pickupCount; i++) {
      pickupdetailsformKey.add(new GlobalKey<FormState>());
      pickupforms.add(new PickupDetailsForm(
          pickup: pickups[i],
          i: i,
          addpickup: addpickup,
          formkey: pickupdetailsformKey[i]));
    }
    for (var i = 0; i < _deliveryCount; i++) {
      deliverydetailsformKey.add(new GlobalKey<FormState>());

      deliveryforms.add(new DeliveryDetailsForm(
          delivery: deliveries[i],
          i: i,
          adddelivery: adddelivery,
          formkey: deliverydetailsformKey[i]));
    }
    for (var i = 0; i < _driverCount; i++) {
      driverdetailsformKey.add(new GlobalKey<FormState>());

      driverforms.add(new DriverDetailsForm(
          driver: drivers[i],
          i: i,
          adddriver: adddriver,
          formkey: driverdetailsformKey[i]));
    }
    if (widget.load.notes != null) {
      _notescount = 1;
      notes = widget.load.notes;
    }
    loadno.text = widget.load.loadnumber!;
    setState(() {});
  }

//popup a dialog box after created a user
  Widget _buildPopupDialog(BuildContext context) {
    // companies list provider
    return new AlertDialog(
      actionsAlignment: MainAxisAlignment.center,
      backgroundColor: popupcolor,
      title: null,
      content: Container(
        decoration: BoxDecoration(color: popupcolor),
        child: Text(
          "Load created successfully and details sent on driver's phone number.",
          style: popupdialogtextstyle,
          textAlign: TextAlign.center,
        ),
      ),
      actions: [
        ElevatedButton(
            onPressed: () {
              //push to manage users screen after pressing ok
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DispatcherLoadsScreen()));
            },
            style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                )),
                backgroundColor: MaterialStateProperty.all(Colors.green)),
            child: Container(
              height: 35,
              width: SizeConfig.screenWidth * 0.12,
              child: const Center(
                child: const Text(
                  'OK',
                  style: TextStyle(
                      color: Colors.white, fontSize: 18, letterSpacing: 1),
                ),
              ),
            )),
      ],
    );
  }

  void addpickup(PickupModel pickup, int i) {
    setState(() {
      pickups[i] = pickup;
    });
  }

  void adddelivery(DeliveryModel delivery, int i) {
    setState(() {
      deliveries[i] = delivery;
    });
  }

  void adddriver(DriverModel driver, int i) {
    setState(() {
      drivers[i] = driver;
    });
  }

  TextEditingController loadno = TextEditingController();
  _onsave(context) async {
    load.pickups = pickups;
    load.deliveries = deliveries;
    load.drivers = drivers;
    setState(() {});
    await DispatcherMethods()
        .updateload(load, pickupLoadNumber, notes, context);
  }

  bool hidepickups = false;
  bool hidedeliveries = false;
  bool hidedrivers = false;
  bool hidenotes = false;
  bool isloading = false;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return LoadingOverlay(
      isLoading: isloading,
      progressIndicator: loader,
      child: Scaffold(
        drawer: DispatcherDrawer(),
        bottomNavigationBar: DispatcherBottomNavBar(),
        body: SingleChildScrollView(
          child: Form(
            key: _formkey,
            child: Column(
              children: [
                Header(
                  height: SizeConfig.screenHeight * 0.2,
                  child: Padding(
                    padding:
                        EdgeInsets.only(top: SizeConfig.screenHeight * 0.06),
                    child: Container(
                      height: 80,
                      child: AppBar(
                        elevation: 0,
                        backgroundColor: kPrimaryColor,
                        title: Text(
                          'Update Load',
                          style: TextStyle(fontSize: 30),
                        ),
                        iconTheme: IconThemeData(color: Colors.black),
                        centerTitle: true,
                        actions: [
                          Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: IconButton(
                                onPressed: null,
                                icon: Icon(
                                  Icons.notifications,
                                  color: Colors.black,
                                )),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20.0, right: 20, top: 30),
                  child: InkWell(
                    onTap: () {
                      if (_driverCount != 0) {
                        setState(() {
                          hidedrivers = true;
                        });
                      }
                      if (_deliveryCount != 0) {
                        setState(() {
                          hidedeliveries = true;
                        });
                      }
                      if (_notescount != 0) {
                        setState(() {
                          hidenotes = true;
                        });
                      }
                      if (hidepickups) {
                        setState(() {
                          hidepickups = false;
                        });
                      } else {
                        if (_pickupCount <= 5) {
                          setState(() {
                            _pickupCount++;
                            pickupdetailsformKey
                                .add(new GlobalKey<FormState>());
                            pickupforms.add(new PickupDetailsForm(
                              pickup: PickupModel(),
                              formkey: pickupdetailsformKey[_pickupCount - 1],
                              i: _pickupCount - 1,
                              addpickup: addpickup,
                            ));
                            pickups.add(PickupModel());
                          });
                          setState(() {});
                        }
                      }
                    },
                    child: Container(
                      width: SizeConfig.screenWidth,
                      height: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: kPrimaryColor),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 30.0),
                            child: Text(
                              'Pickup Details',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                          if (_pickupCount <= 5)
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Icon(
                                hidepickups
                                    ? Icons.arrow_drop_down
                                    : Icons.add_circle_outline,
                                color: Colors.black,
                                size: 30,
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                ),
                for (int i = 1; i <= _pickupCount; i++)
                  Visibility(
                    visible: !hidepickups,
                    maintainState: true,
                    child: Column(
                      children: [
                        if (i == 1)
                          Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: TextFormField(
                              cursorColor: kPrimaryColor,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  pickupLoadNumber = value;
                                  deliveryLoadNumber = value;
                                  loadno.text = value;
                                });
                              },
                              initialValue: widget.load.loadnumber,
                              decoration: InputDecoration(
                                  border: UnderlineInputBorder(),
                                  focusColor: kPrimaryColor,
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: kPrimaryColor)),
                                  contentPadding: EdgeInsets.only(left: 30),
                                  label: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 0.0,
                                    ),
                                    child: Text(
                                      'Load no.',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  )),
                            ),
                          ),
                        if (i > 1)
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20.0, right: 20, top: 30),
                            child: Container(
                              width: SizeConfig.screenWidth,
                              height: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: kPrimaryColor),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 30.0),
                                    child: Text(
                                      'Extra Stop',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _pickupCount--;
                                          pickupforms.removeAt(i - 1);
                                          pickups.removeAt(i - 1);
                                        });
                                        setState(() {});
                                      },
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.black,
                                        size: 30,
                                      ))
                                ],
                              ),
                            ),
                          ),
                        // Text('ok'),
                        pickupforms[i - 1]
                      ],
                    ),
                  ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20.0, right: 20, top: 30),
                  child: InkWell(
                    onTap: () {
                      if (_pickupCount != 0) {
                        setState(() {
                          hidepickups = true;
                        });
                      }
                      if (_driverCount != 0) {
                        setState(() {
                          hidedrivers = true;
                        });
                      }

                      if (_notescount != 0) {
                        setState(() {
                          hidenotes = true;
                        });
                      }
                      if (hidedeliveries) {
                        setState(() {
                          hidedeliveries = false;
                        });
                      } else {
                        setState(() {
                          _deliveryCount++;
                          deliverydetailsformKey
                              .add(new GlobalKey<FormState>());
                          deliveryforms.add(DeliveryDetailsForm(
                            delivery: DeliveryModel(),
                            formkey: deliverydetailsformKey[_deliveryCount - 1],
                            adddelivery: adddelivery,
                            i: _deliveryCount - 1,
                          ));
                          deliveries.add(DeliveryModel());
                        });
                      }
                    },
                    child: Container(
                      height: 50,
                      width: SizeConfig.screenWidth,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: kPrimaryColor),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 30.0),
                            child: Text(
                              'Delivery Details',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                          if (_deliveryCount <= 5)
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Icon(
                                hidedeliveries
                                    ? Icons.arrow_drop_down
                                    : Icons.add_circle_outline,
                                color: Colors.black,
                                size: 30,
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                ),
                for (int i = 1; i <= _deliveryCount; i++)
                  Visibility(
                    visible: !hidedeliveries,
                    maintainState: true,
                    child: Column(
                      children: [
                        if (i == 1)
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: TextFormField(
                              cursorColor: kPrimaryColor,
                              // validator: (value) {
                              //   if (value == null || value.isEmpty) {
                              //     return 'Please enter some text';
                              //   }
                              //   return null;
                              // },
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  deliveryLoadNumber = value;
                                });
                              },
                              readOnly: true,
                              controller: loadno,
                              decoration: InputDecoration(
                                  border: UnderlineInputBorder(),
                                  focusColor: kPrimaryColor,
                                  contentPadding: EdgeInsets.only(left: 30),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: kPrimaryColor)),
                                  label: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 0.0,
                                    ),
                                    child: Text(
                                      'Load no.',
                                      style: TextStyle(fontSize: 17),
                                    ),
                                  )),
                            ),
                          ),
                        if (i > 1)
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20.0, right: 20, top: 30),
                            child: Container(
                              width: SizeConfig.screenWidth,
                              height: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: kPrimaryColor),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 30.0),
                                    child: Text(
                                      'Extra Stop',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _deliveryCount--;
                                          deliveryforms.removeAt(i - 1);
                                          deliveries.removeAt(i - 1);
                                        });
                                      },
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.black,
                                        size: 30,
                                      ))
                                ],
                              ),
                            ),
                          ),
                        // Text('ok'),
                        deliveryforms[i - 1]
                      ],
                    ),
                  ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20.0, right: 20, top: 30),
                  child: InkWell(
                    onTap: () {
                      if (_pickupCount != 0) {
                        setState(() {
                          hidepickups = true;
                        });
                      }
                      if (_deliveryCount != 0) {
                        setState(() {
                          hidedeliveries = true;
                        });
                      }

                      if (_notescount != 0) {
                        setState(() {
                          hidenotes = true;
                        });
                      }
                      if (hidedrivers) {
                        setState(() {
                          hidedrivers = false;
                        });
                      } else {
                        setState(() {
                          _driverCount++;
                          driverdetailsformKey.add(new GlobalKey<FormState>());
                          driverforms.add(DriverDetailsForm(
                            driver: DriverModel(),
                            formkey: driverdetailsformKey[_driverCount - 1],
                            adddriver: adddriver,
                            i: _driverCount - 1,
                          ));
                          drivers.add(DriverModel());
                        });
                      }
                    },
                    child: Container(
                      height: 50,
                      width: SizeConfig.screenWidth,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: kPrimaryColor),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 30.0),
                            child: Text(
                              'Driver Details',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                          if (_driverCount <= 3)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Icon(
                                hidedrivers
                                    ? Icons.arrow_drop_down
                                    : Icons.add_circle_outline,
                                color: Colors.black,
                                size: 30,
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                ),
                for (int i = 1; i <= _driverCount; i++)
                  Visibility(
                    visible: !hidedrivers,
                    maintainState: true,
                    child: Column(
                      children: [
                        if (i > 1)
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20.0, right: 20, top: 30),
                            child: Container(
                              height: 50,
                              width: SizeConfig.screenWidth,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: kPrimaryColor),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 30.0),
                                    child: Text(
                                      'Extra Driver',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _driverCount--;
                                          driverforms.removeAt(i - 1);
                                          drivers.removeAt(i - 1);
                                        });
                                      },
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.black,
                                        size: 30,
                                      ))
                                ],
                              ),
                            ),
                          ),
                        // Text('ok'),
                        driverforms[i - 1]
                      ],
                    ),
                  ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20.0, right: 20, top: 30),
                  child: InkWell(
                    onTap: () {
                      if (_driverCount != 0) {
                        setState(() {
                          hidedrivers = true;
                        });
                      }
                      if (_deliveryCount != 0) {
                        setState(() {
                          hidedeliveries = true;
                        });
                      }
                      if (_pickupCount != 0) {
                        setState(() {
                          hidepickups = true;
                        });
                      }

                      if (hidenotes) {
                        setState(() {
                          hidenotes = false;
                        });
                      } else {
                        if (_notescount < 1) {
                          setState(() {
                            _notescount++;
                          });
                          setState(() {});
                        }
                      }
                    },
                    child: Container(
                      width: SizeConfig.screenWidth,
                      height: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: kPrimaryColor),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 30.0),
                            child: Text(
                              'Notes',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Icon(
                              hidenotes && _notescount != 0
                                  ? Icons.arrow_drop_down
                                  : Icons.add_circle_outline,
                              color: Colors.black,
                              size: 30,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                if (_notescount == 1)
                  Visibility(
                    visible: !hidenotes,
                    maintainState: true,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: TextFormField(
                            cursorColor: kPrimaryColor,
                            onChanged: (value) {
                              setState(() {
                                notes = value;
                              });
                            },
                            initialValue: notes,
                            decoration: InputDecoration(
                                border: UnderlineInputBorder(),
                                focusColor: kPrimaryColor,
                                contentPadding: EdgeInsets.only(left: 30),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: kPrimaryColor)),
                                label: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 0.0,
                                  ),
                                  child: Text(
                                    'Notes',
                                    style: TextStyle(fontSize: 17),
                                  ),
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_deliveryCount >= 1 &&
                    _pickupCount >= 1 &&
                    _driverCount >= 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0, bottom: 50),
                    child: ElevatedButton(
                        onPressed: () async {
                          driverdetailsformKey.forEach((element) {
                            if (element.currentState != null &&
                                !element.currentState!.validate())
                              setState(() {
                                hidedrivers = false;
                                validform = false;
                              });
                          });
                          deliverydetailsformKey.forEach((element) {
                            if (element.currentState != null &&
                                !element.currentState!.validate())
                              setState(() {
                                hidedeliveries = false;
                                validform = false;
                              });
                          });
                          pickupdetailsformKey.forEach((element) {
                            if (element.currentState != null &&
                                !element.currentState!.validate())
                              setState(() {
                                hidepickups = false;
                                validform = false;
                              });
                          });
                          bool isemptyaddress = false;
                          for (var pickup in pickups) {
                            print(pickup.pickup);
                            if (pickup.pickup == null) {
                              return errorSnackBar(
                                  context, 'please enter valid pickup address');
                            }
                          }
                          for (var delivery in deliveries) {
                            if (delivery.delivery == null) {
                              return errorSnackBar(context,
                                  'please enter valid delivery address');
                            }
                          }
                          if (validform && _formkey.currentState!.validate()) {
                            setState(() {
                              isloading = true;
                            });
                            await _onsave(context);
                            setState(() {
                              isloading = false;
                            });
                          }
                        },
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            )),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.green)),
                        child: Container(
                          height: 50,
                          width: SizeConfig.screenWidth * 0.25,
                          child: const Center(
                            child: const Text(
                              'Update',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  letterSpacing: 1),
                            ),
                          ),
                        )),
                  ),
                SizedBox(
                  height: 50,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
