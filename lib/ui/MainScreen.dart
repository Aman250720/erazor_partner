import 'package:erazor_partner/common/error_text.dart';
import 'package:erazor_partner/common/loader.dart';
import 'package:erazor_partner/common/main_widgets.dart';
import 'package:erazor_partner/controllers/firebase_controller.dart';
import 'package:erazor_partner/theme/theme.dart';
import 'package:erazor_partner/ui/HomeScreen.dart';
import 'package:erazor_partner/ui/SlotsScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int index = 0;

  final serviceNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final servicePriceController = TextEditingController();
  final finalPriceController = TextEditingController();
  final serviceDurationController = TextEditingController();
  final priorityController = TextEditingController();

  final List<int> duration = [
    15,
    30,
    45,
    60,
    75,
    90,
    105,
    120,
    135,
    150,
    165,
    180
  ];
  final List<int> priority = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    21,
    22,
    23,
    24,
    25,
    26,
    27,
    28,
    29,
    30,
    31,
    32,
    33,
    34,
    35,
    36,
    37,
    38,
    39,
    40,
    41,
    42,
    43,
    44,
    45,
    46,
    47,
    48,
    49,
    50,
    51,
    52,
    53,
    54,
    55,
    56,
    57,
    58,
    59,
    60,
    61,
    62,
    63,
    64,
    65,
    66,
    67,
    68,
    69,
    70,
    71,
    72,
    73,
    74,
    75,
    76,
    77,
    78,
    79,
    80,
    81,
    82,
    83,
    84,
    85,
    86,
    87,
    88,
    89,
    90,
    91,
    92,
    93,
    94,
    95,
    96,
    97,
    98,
    99,
    100
  ];

  bool enableButton() {
    bool enable = serviceNameController.text.isNotEmpty &&
        //descriptionController.text.isNotEmpty &&
        servicePriceController.text.isNotEmpty &&
        finalPriceController.text.isNotEmpty &&
        serviceDurationController.text.isNotEmpty &&
        priorityController.text.isNotEmpty;

    return enable;
  }

  @override
  void dispose() {
    super.dispose();
    serviceNameController.dispose();
    descriptionController.dispose();
    servicePriceController.dispose();
    finalPriceController.dispose();
    serviceDurationController.dispose();
    priorityController.dispose();
  }

  void insertS() {
    ref.read(firebaseControllerProvider.notifier).insertS(
        context: context,
        serviceName: serviceNameController.text,
        description: descriptionController.text,
        imageUrl: '',
        servicePrice: int.parse(servicePriceController.text),
        finalPrice: int.parse(finalPriceController.text),
        serviceDuration: int.parse(serviceDurationController.text),
        enabled: true,
        priority: int.parse(priorityController.text));

    serviceNameController.clear();
    descriptionController.clear();
    servicePriceController.clear();
    finalPriceController.clear();
    serviceDurationController.clear();
    priorityController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: index == 1
              ? AppBar(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30))),
                  centerTitle: true,
                  title: const Text('Slots Info'),
                )
              : null,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: index,
            onTap: (value) => setState(() {
              index = value;
            }),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Slots'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.email), label: 'Bookings'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle), label: 'Profile'),
            ],
          ),
          floatingActionButton: index == 0
              ? FloatingActionButton.extended(
                  backgroundColor: Colors.black,
                  onPressed: () {
                    showModalBottomSheet(
                        backgroundColor: Colors.white,
                        showDragHandle: true,
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: 16,
                                  top: 16,
                                  right: 16,
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom +
                                          16),
                              child: Column(
                                children: [
                                  TextField(
                                    controller: serviceNameController,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    onChanged: (text) => setState(() {}),
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        focusedBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Blue001, width: 2)),
                                        label: Text(
                                          'Service Name',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        )),
                                  ),
                                  const SizedBox(height: 20),
                                  TextField(
                                    controller: descriptionController,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    onChanged: (text) => setState(() {}),
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        focusedBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Blue001, width: 2)),
                                        label: Text(
                                          'Description',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        )),
                                  ),
                                  const SizedBox(height: 20),
                                  TextField(
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    controller: servicePriceController,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    onChanged: (text) => setState(() {}),
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        focusedBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Blue001, width: 2)),
                                        label: Text(
                                          'Service Price',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        )),
                                  ),
                                  const SizedBox(height: 20),
                                  TextField(
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    controller: finalPriceController,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    onChanged: (text) => setState(() {}),
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        focusedBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Blue001, width: 2)),
                                        label: Text(
                                          'Final Price',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        )),
                                  ),
                                  const SizedBox(height: 20),
                                  DropdownMenu(
                                    width: MediaQuery.of(context).size.width *
                                        0.91,
                                    menuHeight: 300,
                                    initialSelection: duration[1],
                                    controller: serviceDurationController,
                                    textStyle:
                                        Theme.of(context).textTheme.bodySmall,
                                    label: Text(
                                      'Service Duration (in mins)',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    menuStyle: const MenuStyle(
                                        surfaceTintColor:
                                            MaterialStatePropertyAll(
                                                Colors.white),
                                        backgroundColor:
                                            MaterialStatePropertyAll(
                                                Colors.white)),
                                    dropdownMenuEntries:
                                        duration.map((int duration) {
                                      return DropdownMenuEntry(
                                          value: duration,
                                          label: duration.toString(),
                                          style: ButtonStyle(
                                            textStyle: MaterialStatePropertyAll(
                                              Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          ));
                                    }).toList(),
                                    onSelected: (value) => setState(() {}),
                                  ),
                                  const SizedBox(height: 20),
                                  DropdownMenu(
                                    width: MediaQuery.of(context).size.width *
                                        0.91,
                                    menuHeight: 300,
                                    initialSelection: priority[0],
                                    controller: priorityController,
                                    textStyle:
                                        Theme.of(context).textTheme.bodySmall,
                                    label: Text(
                                      'Order',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    menuStyle: const MenuStyle(
                                        surfaceTintColor:
                                            MaterialStatePropertyAll(
                                                Colors.white),
                                        backgroundColor:
                                            MaterialStatePropertyAll(
                                                Colors.white)),
                                    dropdownMenuEntries:
                                        priority.map((int priority) {
                                      return DropdownMenuEntry(
                                          value: priority,
                                          label: priority.toString(),
                                          style: ButtonStyle(
                                            textStyle: MaterialStatePropertyAll(
                                              Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          ));
                                    }).toList(),
                                    onSelected: (value) => setState(() {}),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                      width: double.infinity,
                                      child: enableButton()
                                          ? ElevatedButton(
                                              onPressed: insertS,
                                              child: Text(
                                                'Add Service',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall,
                                              ))
                                          : ElevatedButton(
                                              style: ButtonStyle(
                                                  elevation:
                                                      const MaterialStatePropertyAll(
                                                          0),
                                                  surfaceTintColor:
                                                      const MaterialStatePropertyAll(
                                                          Colors.white),
                                                  backgroundColor:
                                                      MaterialStatePropertyAll(
                                                          Colors
                                                              .grey.shade300)),
                                              onPressed: null,
                                              child: Text(
                                                'Add Service',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall,
                                              )))
                                ],
                              ),
                            ),
                          );
                        });
                  },
                  label: const Text(
                    'Add a service',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : null,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          body: widgetList[index]),
    );
  }
}
