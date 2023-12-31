import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erazor_partner/common/error_text.dart';
import 'package:erazor_partner/common/loader.dart';
import 'package:erazor_partner/common/main_widgets.dart';
import 'package:erazor_partner/common/snackbar.dart';
import 'package:erazor_partner/controllers/firebase_controller.dart';
import 'package:erazor_partner/models/employee_details.dart';
import 'package:erazor_partner/models/slot_details.dart';
import 'package:erazor_partner/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:intl/intl.dart';

class SlotsScreen extends ConsumerStatefulWidget {
  const SlotsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SlotsScreenState();
}

class _SlotsScreenState extends ConsumerState<SlotsScreen> {
  final List<String> dates = [];
  final List<DateTime> actualDates = [];

  int index = 0;

  @override
  void initState() {
    DateTime currentDate = DateTime.now().copyWith(
        hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

    for (int i = 0; i < 7; i++) {
      dates.add(DateFormat.MMMEd().format(currentDate.add(Duration(days: i))));
      actualDates.add(currentDate.add(Duration(days: i)));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.17,
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: [
                InkWell(
                  child: DateItem(
                    date: dates[0],
                    isSelected: index == 0,
                  ),
                  onTap: () {
                    setState(() {
                      index = 0;
                    });
                  },
                ),
                InkWell(
                  child: DateItem(
                    date: dates[1],
                    isSelected: index == 1,
                  ),
                  onTap: () {
                    setState(() {
                      index = 1;
                    });
                  },
                ),
                InkWell(
                  child: DateItem(
                    date: dates[2],
                    isSelected: index == 2,
                  ),
                  onTap: () {
                    setState(() {
                      index = 2;
                    });
                  },
                ),
                InkWell(
                  child: DateItem(
                    date: dates[3],
                    isSelected: index == 3,
                  ),
                  onTap: () {
                    setState(() {
                      index = 3;
                    });
                  },
                ),
                InkWell(
                  child: DateItem(
                    date: dates[4],
                    isSelected: index == 4,
                  ),
                  onTap: () {
                    setState(() {
                      index = 4;
                    });
                  },
                ),
                InkWell(
                  child: DateItem(
                    date: dates[5],
                    isSelected: index == 5,
                  ),
                  onTap: () {
                    setState(() {
                      index = 5;
                    });
                  },
                ),
                InkWell(
                  child: DateItem(
                    date: dates[6],
                    isSelected: index == 6,
                  ),
                  onTap: () {
                    setState(() {
                      index = 6;
                    });
                  },
                ),
              ],
            ),
          ),
          const Divider(
            height: 50,
            indent: 50,
            endIndent: 50,
          ),
          SlotsBody(
            slotDate: dates[index],
            actualDate: actualDates[index],
          )
        ],
      ),
    );
  }
}

class DateItem extends ConsumerWidget {
  final String date;
  final bool isSelected;
  const DateItem({super.key, required this.date, required this.isSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Card(
        elevation: 10,
        color: isSelected ? Colors.black : Colors.white,
        child: Container(
          alignment: Alignment.center,
          //width: 100,
          constraints: const BoxConstraints(minWidth: 100),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
            child: Text(
              date,
              style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.normal),
            ),
          ),
        ),
      ),
    );
  }
}

class SlotItem extends ConsumerWidget {
  final String time;
  final bool isBooked;
  final bool isEnabled;
  const SlotItem(
      {super.key,
      required this.time,
      required this.isBooked,
      required this.isEnabled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Card(
        surfaceTintColor: isBooked
            ? Blue001
            : !isEnabled
                ? Colors.grey
                : Colors.white,
        elevation: 10,
        color: isBooked
            ? Blue001
            : !isEnabled
                ? Colors.grey
                : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
              child: Text(
            time,
            style: TextStyle(
                color: isBooked || !isEnabled ? Colors.white : Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.normal),
          )),
        ),
      ),
    );
  }
}

class SlotsBody extends ConsumerStatefulWidget {
  final String slotDate;
  final DateTime actualDate;

  const SlotsBody(
      {super.key, required this.slotDate, required this.actualDate});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SlotsBodyState();
}

class _SlotsBodyState extends ConsumerState<SlotsBody> {
  List<String> slots = [];
  List<EmployeeDetails> employees = [];

  @override
  void initState() {
    String openingTime =
        ref.read(salonDetailsProvider.notifier).state!.openingTime;
    String closingTime =
        ref.read(salonDetailsProvider.notifier).state!.closingTime;
    int interval = ref.read(salonDetailsProvider.notifier).state!.slotInterval;
    employees = ref.read(salonDetailsProvider.notifier).state!.employees;

    int millis = DateFormat('HH:mm').parse(openingTime).millisecondsSinceEpoch;

    final difference =
        DateFormat('HH:mm').parse(closingTime).millisecondsSinceEpoch -
            DateFormat('HH:mm').parse(openingTime).millisecondsSinceEpoch;

    final minutes = difference / 60000;
    final slotsCount = (minutes / interval).floor();
    slots.add(openingTime);
    for (int i = 1; i < slotsCount; i++) {
      millis += interval * 60000;
      slots.add(DateFormat('HH:mm')
          .format(DateTime.fromMillisecondsSinceEpoch(millis)));
    }

    super.initState();
  }

  void insertSlot(Timestamp slotDate, String slotTime, String employee) {
    final salon = ref.watch(salonDetailsProvider);
    //final timestamp = Timestamp.fromDate(widget.actualDate);

    ref.read(firebaseControllerProvider.notifier).insertSlot(
        context: context,
        slotDate: slotDate,
        slotTime: slotTime,
        employee: employee,
        salon: salon!.salonName);
  }

  @override
  Widget build(BuildContext context) {
    //final formattedDate = DateFormat.MMMEd().parse(widget.slotDate);
    //print('formatted date $formattedDate');

    return Column(
      children: [
        ListView.builder(
            shrinkWrap: true,
            //scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: employees.length,
            itemBuilder: (context, int i) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.chair_sharp,
                          color: Blue001,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          employees[i].name,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ref
                        .watch(slotsProvider(MyParameter(
                            employee: employees[i].name,
                            slotDate: Timestamp.fromDate(widget.actualDate))))
                        .when(
                            data: (data) {
                              return data.isEmpty
                                  ? SizedBox(
                                      width: double.infinity,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          ElevatedButton(
                                              onPressed: () {
                                                for (var element in slots) {
                                                  insertSlot(
                                                      Timestamp.fromDate(
                                                          widget.actualDate),
                                                      element,
                                                      employees[i].name);
                                                }
                                                showSnackBar(context,
                                                    'Slots generated!');
                                              },
                                              child: Text(
                                                'Generate Slots',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall,
                                              )),
                                          const SizedBox(
                                            height: 30,
                                          ),
                                        ],
                                      ),
                                    )
                                  : Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          height: 80,
                                          child: ListView.builder(
                                              itemCount: data.length,
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              itemBuilder:
                                                  (context, int index) {
                                                return InkWell(
                                                  onTap: () {
                                                    if (!data[index].booked) {
                                                      ref
                                                          .watch(
                                                              firebaseControllerProvider
                                                                  .notifier)
                                                          .updateSlot(
                                                              context: context,
                                                              key: data[index]
                                                                  .key,
                                                              enabled:
                                                                  !data[index]
                                                                      .enabled);
                                                    }
                                                  },
                                                  child: SlotItem(
                                                    time: data[index].slotTime,
                                                    isBooked:
                                                        data[index].booked,
                                                    isEnabled:
                                                        data[index].enabled,
                                                  ),
                                                );
                                              }),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        )
                                      ],
                                    );
                            },
                            error: (error, stackTrace) =>
                                ErrorText(error: error.toString()),
                            loading: () => const Loader())
                  ],
                ),
              );
            }),
      ],
    );
  }
}
