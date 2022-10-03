import 'package:flutter/material.dart';
import 'package:itruck_dispatch/models/delivery_model.dart';
import 'package:itruck_dispatch/models/load_model.dart';
import 'package:itruck_dispatch/models/pickup_model.dart';
import 'package:itruck_dispatch/size_config.dart';

class DispatcherLoadDataTable extends StatefulWidget {
  final LoadModel? load;

  const DispatcherLoadDataTable({Key? key, LoadModel? this.load})
      : super(key: key);

  @override
  State<DispatcherLoadDataTable> createState() =>
      _DispatcherLoadDataTableState();
}

class _DispatcherLoadDataTableState extends State<DispatcherLoadDataTable> {
  _DispatcherLoadDataTableState();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setload();
  }

  PickupModel pickup1 = PickupModel(
      pickupdate: '22 June 2022',
      pickuptime: '10:30 AM',
      pickup: 'Frenso,CA,USA,93722');
  DeliveryModel delivery1 = DeliveryModel(
      deliverydate: '27 June 2022',
      deliverytime: '4:30 PM',
      delivery: 'Houston,TX,USA,77038');
  DeliveryModel delivery2 = DeliveryModel(
      deliverydate: '29 June 2022',
      deliverytime: '11:00 AM',
      delivery: 'Houston,TX,USA,77038');

  setload() {
    if (widget.load == null)
      load = LoadModel(pickups: [pickup1], deliveries: [delivery1, delivery2]);
    else
      load = widget.load;
  }

  LoadModel? load;
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      width: SizeConfig.screenWidth,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: DataTable(
            horizontalMargin: 1.0,
            columnSpacing: 0.0,
            dividerThickness: 0.0,
            headingRowHeight: 0,
            dataRowHeight: 70,
            columns: [
              DataColumn(
                label: Container(),
              ),
              DataColumn(
                label: Container(),
              ),
            ],
            rows: load!.pickups!
                    .asMap()
                    .map((i, e) => MapEntry(
                        i,
                        DataRow(cells: [
                          DataCell(Container(
                            decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(width: 0.7))),
                            height: 70,
                            width: SizeConfig.screenWidth * 0.25,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: SizeConfig.screenWidth * 0.25 - 21,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10.0),
                                          child: Text(
                                            e.pickupdate!,
                                            style: TextStyle(
                                                color: Colors.lightBlueAccent,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            e.pickuptime!,
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Stack(
                                    children: [
                                      Container(
                                          height: 70,
                                          child: VerticalDivider(
                                            color: Colors.black,
                                          )),
                                      Positioned(
                                        top: i != 0 ? 10 : 0,
                                        right: 4,
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.lightBlueAccent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          )),
                          DataCell(Container(
                            decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(width: 0.7))),
                            width: SizeConfig.screenWidth * 0.75,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  load!.pickups!.length != 1
                                      ? 'Pickup ' + (i + 1).toString()
                                      : 'Pickup',
                                  style: TextStyle(
                                      color: Colors.lightBlueAccent,
                                      fontSize: 12),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 5.0),
                                      child: Text(
                                        e.pickup!.split(', ').length > 3
                                            ? e.pickup!
                                                    .split(', ')
                                                    .reversed
                                                    .toList()[2] +
                                                ', ' +
                                                e.pickup!
                                                    .split(', ')
                                                    .reversed
                                                    .toList()[1] +
                                                ', ' +
                                                e.pickup!
                                                    .split(', ')
                                                    .reversed
                                                    .toList()[0]
                                            : e.pickup!,
                                        style: TextStyle(
                                            fontSize: 20,
                                            letterSpacing: 1,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ])))
                    .values
                    .toList() +
                load!.deliveries!
                    .asMap()
                    .map((i, e) => MapEntry(
                        i,
                        DataRow(cells: [
                          DataCell(Container(
                            decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(width: 0.7))),
                            height: 70,
                            width: SizeConfig.screenWidth * 0.25,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: SizeConfig.screenWidth * 0.25 - 21,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10.0),
                                          child: Text(
                                            e.deliverydate!,
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            e.deliverytime!,
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Stack(
                                    children: [
                                      Container(
                                          height: 70,
                                          child: VerticalDivider(
                                            color: Colors.black,
                                          )),
                                      Positioned(
                                        top: 10,
                                        right: 4,
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          )),
                          DataCell(Container(
                            decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(width: 0.7))),
                            width: SizeConfig.screenWidth * 0.75,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    load!.deliveries!.length != 1
                                        ? 'Dilevery ' + (i + 1).toString()
                                        : 'Dilevery',
                                    style: TextStyle(
                                        color: Colors.green, fontSize: 12),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 4.0),
                                      child: Text(
                                        e.delivery!.split(', ').length > 3
                                            ? e.delivery!
                                                    .split(', ')
                                                    .reversed
                                                    .toList()[2] +
                                                ', ' +
                                                e.delivery!
                                                    .split(', ')
                                                    .reversed
                                                    .toList()[1] +
                                                ', ' +
                                                e.delivery!
                                                    .split(', ')
                                                    .reversed
                                                    .toList()[0]
                                            : e.delivery!,
                                        style: TextStyle(
                                            fontSize: 20,
                                            letterSpacing: 1,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ])))
                    .values
                    .toList()),
      ),
    );
  }
}
