import 'dart:io';
import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_state.dart';
import 'package:erazor_partner/common/error_text.dart';
import 'package:erazor_partner/common/loader.dart';
import 'package:erazor_partner/controllers/firebase_controller.dart';
import 'package:erazor_partner/models/service_details.dart';
import 'package:erazor_partner/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  File? imageFile;
  final picker = ImagePicker();

  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageFile = File(pickedFile!.path);
      insertImage(imageFile);
    });
  }

  void insertImage(File? file) {
    ref
        .watch(firebaseControllerProvider.notifier)
        .storeImageFirebase(context: context, file: file);
  }

  @override
  Widget build(BuildContext context) {
    final salon = ref.watch(salonDetailsProvider);
    final width = MediaQuery.of(context).size.width;
    int random = Random().nextInt(10);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 20,
          ),
          // Row(
          //   children: [
          //     Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         Text(salon?.salonName ?? ''),
          //         Text(salon?.address ?? '')
          //       ],
          //     )
          //   ],
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  salon?.salonName ?? '',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  salon?.address ?? '',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      salon?.genderType ?? '',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      '|',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Card(
                      color: Blue001,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        child: Row(
                          children: [
                            Text(
                              '4.$random',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            const SizedBox(
                              width: 2,
                            ),
                            const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 18,
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          //
          const SizedBox(
            height: 30,
          ),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              //imageFile != null
              //? Image.file(imageFile!)
              ref.watch(salonImagesProvider).when(
                  data: (data) {
                    print('dataaaaa $data');
                    return data != []
                        ? CarouselSlider(
                            items: data.map((e) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return Container(
                                    width: MediaQuery.of(context).size.width,
                                    //child: ,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: NetworkImage(e.url),
                                          fit: BoxFit.cover),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                            options: CarouselOptions(
                              enableInfiniteScroll: data.length > 1,
                              viewportFraction: data.length > 2 ? 0.8 : 1,
                              aspectRatio: 16 / 9,
                              //height: 200,
                              autoPlay: data.length > 1,
                              enlargeCenterPage: true,
                            ))
                        : Image.asset('assets/images/login_img.jpeg');
                  },
                  error: (error, stackTrace) {
                    print(error);
                    print(stackTrace);
                    return ErrorText(error: error.toString());
                  },
                  loading: () => const Loader()),

              Padding(
                padding: const EdgeInsets.all(4.0),
                child: FloatingActionButton.small(
                  onPressed: () {
                    getImageFromGallery();
                    //insertImage(imageFile);
                  },
                  shape: const CircleBorder(),
                  child: const Icon(Icons.add),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 24,
          ),
          // const Divider(
          //   height: 50,
          //   indent: 50,
          //   endIndent: 50,
          // ),
          // const Text(
          //   'Services',
          // ),
          // const SizedBox(
          //   height: 30,
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(width: 100, child: Divider()),
                    Text(
                      'Services',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(width: 100, child: Divider()),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                ref.watch(servicesProvider).when(
                      data: (data) {
                        return data.isNotEmpty
                            ? ListView.builder(
                                itemCount: data.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, int i) {
                                  return ServiceItem(service: data[i]);
                                })
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 100, horizontal: 0),
                                child: Text(
                                  'No service added yet!',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              );
                      },
                      error: (error, stackTrace) =>
                          ErrorText(error: error.toString()),
                      loading: () => const Loader(),
                    ),
              ],
            ),
          ),
          const SizedBox(
            height: 100,
          )
        ],
      ),
    );
  }
}

class ServiceItem extends ConsumerStatefulWidget {
  final ServiceDetails service;
  const ServiceItem({super.key, required this.service});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ServiceItemState();
}

class _ServiceItemState extends ConsumerState<ServiceItem> {
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
  void initState() {
    serviceNameController.text = widget.service.serviceName;
    descriptionController.text = widget.service.description;
    servicePriceController.text = widget.service.servicePrice.toString();
    finalPriceController.text = widget.service.finalPrice.toString();
    serviceDurationController.text = widget.service.serviceDuration.toString();
    priorityController.text = widget.service.priority.toString();
    super.initState();
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

  void editS(String key) {
    ref.read(firebaseControllerProvider.notifier).editS(
        context: context,
        key: key,
        serviceName: serviceNameController.text,
        description: descriptionController.text,
        imageUrl: '',
        servicePrice: int.parse(servicePriceController.text),
        finalPrice: int.parse(finalPriceController.text),
        serviceDuration: int.parse(serviceDurationController.text),
        enabled: true,
        priority: int.parse(priorityController.text));

    // serviceNameController.clear();
    // descriptionController.clear();
    // servicePriceController.clear();
    // finalPriceController.clear();
    // serviceDurationController.clear();
    // priorityController.clear();
  }

  void deleteS(String key) {
    ref
        .read(firebaseControllerProvider.notifier)
        .deleteS(context: context, key: key);
  }

  void updateS(String key, bool enabled) {
    ref
        .read(firebaseControllerProvider.notifier)
        .updateS(context: context, key: key, enabled: enabled);
  }

  @override
  Widget build(BuildContext context) {
    bool enabled = widget.service.enabled;
    int discount = 100 -
        (widget.service.finalPrice / widget.service.servicePrice * 100).toInt();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: Card(
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.service.serviceName,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '\u{20B9}${widget.service.servicePrice}',
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                    decoration: TextDecoration.lineThrough),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                '\u{20B9}${widget.service.finalPrice}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          Text(
                            '$discount% off!',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Blue001),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 15,
                            color: Blue001,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            '${widget.service.serviceDuration} mins',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Image.asset(
                    'assets/images/login_img.jpeg',
                    width: 150,
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              if (widget.service.description.isNotEmpty) ...[
                Text(
                  widget.service.description,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
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
                                      bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom +
                                          16),
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: serviceNameController,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                        onChanged: (text) => setState(() {}),
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                            border: const OutlineInputBorder(),
                                            focusedBorder:
                                                const OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Blue001,
                                                        width: 2)),
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
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                        onChanged: (text) => setState(() {}),
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                            border: const OutlineInputBorder(),
                                            focusedBorder:
                                                const OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Blue001,
                                                        width: 2)),
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
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                        onChanged: (text) => setState(() {}),
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                            border: const OutlineInputBorder(),
                                            focusedBorder:
                                                const OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Blue001,
                                                        width: 2)),
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
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                        onChanged: (text) => setState(() {}),
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                            border: const OutlineInputBorder(),
                                            focusedBorder:
                                                const OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Blue001,
                                                        width: 2)),
                                            label: Text(
                                              'Final Price',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            )),
                                      ),
                                      const SizedBox(height: 20),
                                      DropdownMenu(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.91,
                                        menuHeight: 300,
                                        initialSelection:
                                            widget.service.serviceDuration,
                                        controller: serviceDurationController,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                        label: Text(
                                          'Service Duration (in mins)',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
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
                                                textStyle:
                                                    MaterialStatePropertyAll(
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
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.91,
                                        menuHeight: 300,
                                        initialSelection:
                                            widget.service.priority,
                                        controller: priorityController,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                        label: Text(
                                          'Order',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
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
                                                textStyle:
                                                    MaterialStatePropertyAll(
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
                                                  onPressed: () =>
                                                      editS(widget.service.key),
                                                  child: Text(
                                                    'Edit Service',
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
                                                              Colors.grey
                                                                  .shade300)),
                                                  onPressed: null,
                                                  child: Text(
                                                    'Edit Service',
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
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.black,
                      )),
                  IconButton(
                      onPressed: () => deleteS(widget.service.key),
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.black,
                      )),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      activeColor: Colors.white,
                      activeTrackColor: Blue001,
                      inactiveThumbColor: Colors.black,
                      inactiveTrackColor: Colors.white,
                      value: enabled,
                      onChanged: (bool newValue) {
                        updateS(widget.service.key, newValue);
                        enabled = newValue;
                      },
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
