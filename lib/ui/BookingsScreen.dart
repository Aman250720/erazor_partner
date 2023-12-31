import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:erazor_partner/common/error_text.dart';
import 'package:erazor_partner/common/loader.dart';
import 'package:erazor_partner/controllers/firebase_controller.dart';
import 'package:erazor_partner/models/booked_person.dart';
import 'package:erazor_partner/models/booked_service.dart';
import 'package:erazor_partner/models/slot_details.dart';
import 'package:erazor_partner/theme/theme.dart';
import 'package:erazor_partner/ui/SlotsScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class Bookings extends ConsumerStatefulWidget {
  const Bookings({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BookingsState();
}

class _BookingsState extends ConsumerState<Bookings> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30))),
        title: const Text('Bookings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                    onTap: () {
                      setState(() {
                        index = 0;
                      });
                    },
                    child: Text(
                      'today',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: index == 0 ? Blue001 : Colors.black,
                          letterSpacing: 0),
                    )),
                InkWell(
                    onTap: () {
                      setState(() {
                        index = 1;
                      });
                    },
                    child: Text(
                      'upcoming',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: index == 1 ? Blue001 : Colors.black,
                          letterSpacing: 0),
                    )),
                InkWell(
                    onTap: () {
                      setState(() {
                        index = 2;
                      });
                    },
                    child: Text(
                      'history',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: index == 2 ? Blue001 : Colors.black,
                          letterSpacing: 0),
                    )),
              ],
            ),
            index == 0
                ? const Today()
                : index == 1
                    ? const Upcoming()
                    : const History()
          ],
        ),
      ),
    );
  }
}

/*
class BookingItem extends ConsumerWidget {
  final int num;
  const BookingItem({super.key, required this.num});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    DateTime timeNow = DateTime.now();
    String stringTime = DateFormat.Hm().format(timeNow);
    Timestamp currentDate = Timestamp.fromDate(timeNow.copyWith(
        hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0));
    //late List<SlotDetails> bookedSlots;
    List<SlotDetails> bookedSlots = [];

    List<String> list = [];

    return ref.watch(bookedSlotsProvider).when(
        data: (data) {
          bookedSlots = data;
          bookedSlots.forEach((element) {
            list.add(element.bid);
          });

          List<String> listBID = list.toSet().toList();

          return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: listBID.length,
              itemBuilder: (context, index) {
                List<SlotDetails> tempSlots = [];
                for (var element in bookedSlots) {
                  if (element.bid == listBID[index]) {
                    tempSlots.add(element);
                  }
                }

                //late List<BookedService> bookedServices;
                List<BookedService> bookedServices = [];

                ref
                    .watch(servicesBIDProvider(listBID[index]))
                    .whenData((value) => bookedServices = value);

                //late BookedPerson bookedPerson;
                BookedPerson? bookedPerson;

                ref
                    .watch(personBIDProvider(listBID[index]))
                    .whenData((value) => bookedPerson = value[0]);

                return (num == 0 &&
                            tempSlots[0].slotTime.compareTo(stringTime) == 1 &&
                            tempSlots[0].slotDate == currentDate) ||
                        (num == 1 &&
                            tempSlots[0].slotDate.seconds >
                                currentDate.seconds) ||
                        (num == 2 &&
                            tempSlots[0].slotDate.seconds < currentDate.seconds)

                    // (tempSlots[0].slotTime.compareTo(stringTime) == num &&
                    //             tempSlots[0].slotDate == currentDate) ||
                    //         (num == 1
                    //             ? tempSlots[0].slotDate.seconds >
                    //                 currentDate.seconds
                    //             : tempSlots[0].slotDate.seconds <
                    //                 currentDate.seconds)
                    ? Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(tempSlots[0].salon),
                                      Text(DateFormat.MMMEd().format(
                                          tempSlots[0].slotDate.toDate())),
                                    ],
                                  ),
                                  if (num == 0 || num == 1)
                                    ElevatedButton(
                                        onPressed: () async {
                                          ref
                                              .watch(firebaseControllerProvider
                                                  .notifier)
                                              .cancelSlot(
                                                  context: context,
                                                  bid: listBID[index]);
                                          ref
                                              .watch(firebaseControllerProvider
                                                  .notifier)
                                              .deleteBookedServices(
                                                  context: context,
                                                  bid: listBID[index]);
                                          ref
                                              .watch(firebaseControllerProvider
                                                  .notifier)
                                              .deleteBookedPerson(
                                                  context: context,
                                                  bid: listBID[index]);

                                          final notifyCustomer =
                                              await FirebaseFunctions
                                                      .instanceFor(
                                                          region: 'asia-south1')
                                                  .httpsCallable(
                                                      'notifyCustomer',
                                                      options:
                                                          HttpsCallableOptions(
                                                              timeout:
                                                                  const Duration(
                                                                      seconds:
                                                                          5)))
                                                  .call({
                                            'salon': tempSlots[0].salon,
                                            'date': DateFormat.MMMEd().format(
                                                tempSlots[0].slotDate.toDate()),
                                            'time': tempSlots[0].slotTime,
                                            'token': bookedPerson!.token
                                          });
                                        },
                                        child: const Text('Decline')),
                                  if (num == 2)
                                    ElevatedButton(
                                        onPressed: () {},
                                        child: Text(tempSlots[0].status)),
                                ],
                              ),
                              const Divider(),
                              SizedBox(
                                height: 65,
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: tempSlots.length,
                                    itemBuilder: (context, i) {
                                      return SlotItem(
                                        time: tempSlots[i].slotTime,
                                        isBooked: true,
                                        isEnabled: true,
                                      );
                                    }),
                              ),
                              const Divider(),
                              Text('Customer: ${bookedPerson?.name ?? ''}'),
                              Text(
                                  '${bookedPerson?.gender ?? ''}, ${bookedPerson?.age ?? ''}'),
                              Text('${bookedPerson?.mobileNumber ?? ''}'),
                              const Divider(),
                              Text('Stylist: ${tempSlots[0].employee}'),
                              ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: bookedServices.length,
                                  itemBuilder: (context, i) {
                                    return Row(
                                      children: [
                                        Text(bookedServices[i].serviceName),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        const Text('|'),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                            'Rs ${bookedServices[i].finalPrice}'),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        const Text('|'),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                            '${bookedServices[i].serviceDuration} mins'),
                                      ],
                                    );
                                  }),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox(
                        height: 0,
                      );
              });
        },
        error: (error, stackTrace) => ErrorText(error: error.toString()),
        loading: () => const Loader());
  }
}
*/

class Today extends ConsumerStatefulWidget {
  const Today({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TodayState();
}

class _TodayState extends ConsumerState<Today> {
  @override
  Widget build(BuildContext context) {
    DateTime timeNow = DateTime.now();
    String stringTime = DateFormat.Hm().format(timeNow);
    Timestamp currentDate = Timestamp.fromDate(timeNow.copyWith(
        hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0));
    //late List<SlotDetails> bookedSlots;
    List<SlotDetails> bookedSlots = [];

    List<String> list = [];

    return ref.watch(bookedSlotsProvider).when(
        data: (data) {
          bookedSlots = data;
          bookedSlots.forEach((element) {
            list.add(element.bid);
          });

          List<String> listBID = list.toSet().toList();

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: listBID.length,
                itemBuilder: (context, index) {
                  List<SlotDetails> tempSlots = [];
                  for (var element in bookedSlots) {
                    if (element.bid == listBID[index]) {
                      tempSlots.add(element);
                    }
                  }

                  //late List<BookedService> bookedServices;
                  List<BookedService> bookedServices = [];

                  ref
                      .watch(servicesBIDProvider(listBID[index]))
                      .whenData((value) => bookedServices = value);

                  //late BookedPerson bookedPerson;
                  BookedPerson? bookedPerson;

                  ref
                      .watch(personBIDProvider(listBID[index]))
                      .whenData((value) => bookedPerson = value[0]);

                  return (tempSlots[0].slotTime.compareTo(stringTime) == 1 &&
                          tempSlots[0].slotDate == currentDate)
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Card(
                            shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(24))),
                            elevation: 10,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tempSlots[0].salon,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                          Text(
                                            DateFormat.MMMEd().format(
                                                tempSlots[0].slotDate.toDate()),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                        ],
                                      ),
                                      ElevatedButton(
                                          onPressed: () async {
                                            ref
                                                .watch(
                                                    firebaseControllerProvider
                                                        .notifier)
                                                .cancelSlot(
                                                    context: context,
                                                    bid: listBID[index]);
                                            ref
                                                .watch(
                                                    firebaseControllerProvider
                                                        .notifier)
                                                .deleteBookedServices(
                                                    context: context,
                                                    bid: listBID[index]);
                                            ref
                                                .watch(
                                                    firebaseControllerProvider
                                                        .notifier)
                                                .deleteBookedPerson(
                                                    context: context,
                                                    bid: listBID[index]);

                                            final notifyCustomer =
                                                await FirebaseFunctions
                                                        .instanceFor(
                                                            region:
                                                                'asia-south1')
                                                    .httpsCallable(
                                                        'notifyCustomer',
                                                        options:
                                                            HttpsCallableOptions(
                                                                timeout:
                                                                    const Duration(
                                                                        seconds:
                                                                            5)))
                                                    .call({
                                              'salon': tempSlots[0].salon,
                                              'date': DateFormat.MMMEd().format(
                                                  tempSlots[0]
                                                      .slotDate
                                                      .toDate()),
                                              'time': tempSlots[0].slotTime,
                                              'token': bookedPerson!.token
                                            });
                                          },
                                          style: const ButtonStyle(
                                              backgroundColor:
                                                  MaterialStatePropertyAll(
                                                      Colors.black)),
                                          child: Text(
                                            'Decline',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall,
                                          )),
                                    ],
                                  ),
                                  const Divider(
                                    height: 20,
                                  ),
                                  SizedBox(
                                    height: 80,
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: tempSlots.length,
                                        itemBuilder: (context, i) {
                                          return SlotItem(
                                            time: tempSlots[i].slotTime,
                                            isBooked: true,
                                            isEnabled: true,
                                          );
                                        }),
                                  ),
                                  const Divider(
                                    height: 20,
                                  ),
                                  Text(
                                    'Customer: ${bookedPerson?.name ?? ''}',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    '${bookedPerson?.gender ?? ''}, ${bookedPerson?.age ?? ''}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    '${bookedPerson?.mobileNumber ?? ''}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const Divider(
                                    height: 20,
                                  ),
                                  Text(
                                    'Stylist: ${tempSlots[0].employee}',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: bookedServices.length,
                                      itemBuilder: (context, i) {
                                        return Row(
                                          children: [
                                            Text(
                                              bookedServices[i].serviceName,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              '|',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              '\u{20B9}${bookedServices[i].servicePrice}',
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.normal,
                                                  decoration: TextDecoration
                                                      .lineThrough),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              '\u{20B9}${bookedServices[i].finalPrice}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              '|',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            const Icon(
                                              Icons.access_time,
                                              size: 15,
                                              color: Blue001,
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              '${bookedServices[i].serviceDuration} mins',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          ],
                                        );
                                      }),
                                  const SizedBox(
                                    height: 5,
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(
                          height: 0,
                        );
                }),
          );
        },
        error: (error, stackTrace) => ErrorText(error: error.toString()),
        loading: () => SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: const Loader()));
  }
}

class Upcoming extends ConsumerStatefulWidget {
  const Upcoming({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UpcomingState();
}

class _UpcomingState extends ConsumerState<Upcoming> {
  @override
  Widget build(BuildContext context) {
    DateTime timeNow = DateTime.now();
    String stringTime = DateFormat.Hm().format(timeNow);
    Timestamp currentDate = Timestamp.fromDate(timeNow.copyWith(
        hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0));
    //late List<SlotDetails> bookedSlots;
    List<SlotDetails> bookedSlots = [];

    List<String> list = [];

    return ref.watch(bookedSlotsProvider).when(
        data: (data) {
          bookedSlots = data;
          bookedSlots.forEach((element) {
            list.add(element.bid);
          });

          List<String> listBID = list.toSet().toList();

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: listBID.length,
                itemBuilder: (context, index) {
                  List<SlotDetails> tempSlots = [];
                  for (var element in bookedSlots) {
                    if (element.bid == listBID[index]) {
                      tempSlots.add(element);
                    }
                  }

                  //late List<BookedService> bookedServices;
                  List<BookedService> bookedServices = [];

                  ref
                      .watch(servicesBIDProvider(listBID[index]))
                      .whenData((value) => bookedServices = value);

                  //late BookedPerson bookedPerson;
                  BookedPerson? bookedPerson;

                  ref
                      .watch(personBIDProvider(listBID[index]))
                      .whenData((value) => bookedPerson = value[0]);

                  return (tempSlots[0].slotDate.seconds > currentDate.seconds)
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Card(
                            shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(24))),
                            elevation: 10,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tempSlots[0].salon,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                          Text(
                                            DateFormat.MMMEd().format(
                                                tempSlots[0].slotDate.toDate()),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                        ],
                                      ),
                                      ElevatedButton(
                                          onPressed: () async {
                                            ref
                                                .watch(
                                                    firebaseControllerProvider
                                                        .notifier)
                                                .cancelSlot(
                                                    context: context,
                                                    bid: listBID[index]);
                                            ref
                                                .watch(
                                                    firebaseControllerProvider
                                                        .notifier)
                                                .deleteBookedServices(
                                                    context: context,
                                                    bid: listBID[index]);
                                            ref
                                                .watch(
                                                    firebaseControllerProvider
                                                        .notifier)
                                                .deleteBookedPerson(
                                                    context: context,
                                                    bid: listBID[index]);

                                            final notifyCustomer =
                                                await FirebaseFunctions
                                                        .instanceFor(
                                                            region:
                                                                'asia-south1')
                                                    .httpsCallable(
                                                        'notifyCustomer',
                                                        options:
                                                            HttpsCallableOptions(
                                                                timeout:
                                                                    const Duration(
                                                                        seconds:
                                                                            5)))
                                                    .call({
                                              'salon': tempSlots[0].salon,
                                              'date': DateFormat.MMMEd().format(
                                                  tempSlots[0]
                                                      .slotDate
                                                      .toDate()),
                                              'time': tempSlots[0].slotTime,
                                              'token': bookedPerson!.token
                                            });
                                          },
                                          style: const ButtonStyle(
                                              backgroundColor:
                                                  MaterialStatePropertyAll(
                                                      Colors.black)),
                                          child: Text(
                                            'Decline',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall,
                                          )),
                                    ],
                                  ),
                                  const Divider(
                                    height: 20,
                                  ),
                                  SizedBox(
                                    height: 80,
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: tempSlots.length,
                                        itemBuilder: (context, i) {
                                          return SlotItem(
                                            time: tempSlots[i].slotTime,
                                            isBooked: true,
                                            isEnabled: true,
                                          );
                                        }),
                                  ),
                                  const Divider(
                                    height: 20,
                                  ),
                                  Text(
                                    'Customer: ${bookedPerson?.name ?? ''}',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    '${bookedPerson?.gender ?? ''}, ${bookedPerson?.age ?? ''}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    '${bookedPerson?.mobileNumber ?? ''}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const Divider(
                                    height: 20,
                                  ),
                                  Text(
                                    'Stylist: ${tempSlots[0].employee}',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: bookedServices.length,
                                      itemBuilder: (context, i) {
                                        return Row(
                                          children: [
                                            Text(
                                              bookedServices[i].serviceName,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              '|',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              '\u{20B9}${bookedServices[i].servicePrice}',
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.normal,
                                                  decoration: TextDecoration
                                                      .lineThrough),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              '\u{20B9}${bookedServices[i].finalPrice}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              '|',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            const Icon(
                                              Icons.access_time,
                                              size: 15,
                                              color: Blue001,
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              '${bookedServices[i].serviceDuration} mins',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          ],
                                        );
                                      }),
                                  const SizedBox(
                                    height: 5,
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(
                          height: 0,
                        );
                }),
          );
        },
        error: (error, stackTrace) => ErrorText(error: error.toString()),
        loading: () => SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: const Loader()));
  }
}

class History extends ConsumerStatefulWidget {
  const History({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HistoryState();
}

class _HistoryState extends ConsumerState<History> {
  @override
  Widget build(BuildContext context) {
    DateTime timeNow = DateTime.now();
    String stringTime = DateFormat.Hm().format(timeNow);
    Timestamp currentDate = Timestamp.fromDate(timeNow.copyWith(
        hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0));
    //late List<SlotDetails> bookedSlots;
    List<SlotDetails> bookedSlots = [];

    List<String> list = [];

    return ref.watch(bookedSlotsProvider).when(
        data: (data) {
          bookedSlots = data;
          bookedSlots.forEach((element) {
            list.add(element.bid);
          });

          List<String> listBID = list.toSet().toList().reversed.toList();

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: listBID.length,
                itemBuilder: (context, index) {
                  List<SlotDetails> tempSlots = [];
                  for (var element in bookedSlots) {
                    if (element.bid == listBID[index]) {
                      tempSlots.add(element);
                    }
                  }

                  //late List<BookedService> bookedServices;
                  List<BookedService> bookedServices = [];

                  ref
                      .watch(servicesBIDProvider(listBID[index]))
                      .whenData((value) => bookedServices = value);

                  //late BookedPerson bookedPerson;
                  BookedPerson? bookedPerson;

                  ref
                      .watch(personBIDProvider(listBID[index]))
                      .whenData((value) => bookedPerson = value[0]);

                  return (tempSlots[0].slotTime.compareTo(stringTime) == -1 &&
                              tempSlots[0].slotDate == currentDate) ||
                          (tempSlots[0].slotDate.seconds < currentDate.seconds)
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Card(
                            shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(24))),
                            elevation: 10,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tempSlots[0].salon,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                          Text(
                                            DateFormat.MMMEd().format(
                                                tempSlots[0].slotDate.toDate()),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                        ],
                                      ),
                                      // Important stuff
                                      // ElevatedButton(
                                      //     onPressed: () {},
                                      //     style: const ButtonStyle(
                                      //         backgroundColor:
                                      //             MaterialStatePropertyAll(
                                      //                 Colors.black)),
                                      //     child: Text(
                                      //       tempSlots[0].status,
                                      //       style: Theme.of(context)
                                      //           .textTheme
                                      //           .labelSmall,
                                      //     )),
                                    ],
                                  ),
                                  const Divider(
                                    height: 20,
                                  ),
                                  SizedBox(
                                    height: 80,
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: tempSlots.length,
                                        itemBuilder: (context, i) {
                                          return SlotItem(
                                            time: tempSlots[i].slotTime,
                                            isBooked: true,
                                            isEnabled: true,
                                          );
                                        }),
                                  ),
                                  const Divider(
                                    height: 20,
                                  ),
                                  Text(
                                    'Customer: ${bookedPerson?.name ?? ''}',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    '${bookedPerson?.gender ?? ''}, ${bookedPerson?.age ?? ''}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    '${bookedPerson?.mobileNumber ?? ''}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const Divider(
                                    height: 20,
                                  ),
                                  Text(
                                    'Stylist: ${tempSlots[0].employee}',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: bookedServices.length,
                                      itemBuilder: (context, i) {
                                        return Row(
                                          children: [
                                            Text(
                                              bookedServices[i].serviceName,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              '|',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              '\u{20B9}${bookedServices[i].servicePrice}',
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.normal,
                                                  decoration: TextDecoration
                                                      .lineThrough),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              '\u{20B9}${bookedServices[i].finalPrice}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              '|',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            const Icon(
                                              Icons.access_time,
                                              size: 15,
                                              color: Blue001,
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              '${bookedServices[i].serviceDuration} mins',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          ],
                                        );
                                      }),
                                  const SizedBox(
                                    height: 5,
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(
                          height: 0,
                        );
                }),
          );
        },
        error: (error, stackTrace) => ErrorText(error: error.toString()),
        loading: () => SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: const Loader()));
  }
}
