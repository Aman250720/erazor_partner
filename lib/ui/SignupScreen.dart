import 'package:erazor_partner/controllers/firebase_controller.dart';
import 'package:erazor_partner/models/employee_details.dart';
import 'package:erazor_partner/models/location_details.dart';
import 'package:erazor_partner/theme/theme.dart';
import 'package:erazor_partner/ui/GoogleMaps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:routemaster/routemaster.dart';

final currentLocationProvider = StateProvider<LatLng?>((ref) => null);
final currentAddressProvider = StateProvider<String?>((ref) => null);

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  //
  bool? serviceEnabled;
  LocationPermission? permission;
  Position? _currentPosition;
  //

  final salonController = TextEditingController();
  final ownerController = TextEditingController();
  final mobileController = TextEditingController();
  final stateController = TextEditingController();
  final cityController = TextEditingController();
  final addressController = TextEditingController();
  final pincodeController = TextEditingController();
  final openingController = TextEditingController();
  final closingController = TextEditingController();
  final intervalController = TextEditingController();
  final seatingController = TextEditingController();
  final genderController = TextEditingController();

  List<TextEditingController> nameControllers = [];
  List<TextEditingController> sexControllers = [];

  final List<String> gender = ['Gents Salon', 'Beauty Parlour', 'Unisex Salon'];
  final List<int> interval = [15, 30, 45, 60, 75, 90];
  final List<String> sex = ['Male', 'Female'];
  final List<String> time = [
    "00:00",
    "00:30",
    "01:00",
    "01:30",
    "02:00",
    "02:30",
    "03:00",
    "03:30",
    "04:00",
    "04:30",
    "05:00",
    "05:30",
    "06:00",
    "06:30",
    "07:00",
    "07:30",
    "08:00",
    "08:30",
    "09:00",
    "09:30",
    "10:00",
    "10:30",
    "11:00",
    "11:30",
    "12:00",
    "12:30",
    "13:00",
    "13:30",
    "14:00",
    "14:30",
    "15:00",
    "15:30",
    "16:00",
    "16:30",
    "17:00",
    "17:30",
    "18:00",
    "18:30",
    "19:00",
    "19:30",
    "20:00",
    "20:30",
    "21:00",
    "21:30",
    "22:00",
    "22:30",
    "23:00",
    "23:30"
  ];

  String? genderInitial;
  int? intervalInitial;

  bool display = false;

  bool enableButton() {
    SalonLocationDetails loc = ref.watch(latlnghashProvider);
    bool enable = salonController.text.isNotEmpty &&
        ownerController.text.isNotEmpty &&
        mobileController.text.isNotEmpty &&
        (mobileController.text.length == 10) &&
        stateController.text.isNotEmpty &&
        cityController.text.isNotEmpty &&
        addressController.text.isNotEmpty &&
        pincodeController.text.isNotEmpty &&
        (pincodeController.text.length == 6) &&
        openingController.text.isNotEmpty &&
        closingController.text.isNotEmpty &&
        seatingController.text.isNotEmpty &&
        int.parse(seatingController.text) != 0 &&
        intervalController.text.isNotEmpty &&
        genderController.text.isNotEmpty &&
        loc.geoPoint.isNotEmpty;

    for (var element in nameControllers) {
      enable = enable && element.text.isNotEmpty;
    }
    for (var element in sexControllers) {
      enable = enable && element.text.isNotEmpty;
    }

    //intervalInitial != null &&
    //genderInitial != null;

    return enable;
  }

  //List<Map<String, String>> employeesList = [];
  List<EmployeeDetails> employeesList = [];

  @override
  void dispose() {
    super.dispose();
    salonController.dispose();
    ownerController.dispose();
    mobileController.dispose();
    stateController.dispose();
    cityController.dispose();
    addressController.dispose();
    pincodeController.dispose();
    openingController.dispose();
    closingController.dispose();
    intervalController.dispose();
    seatingController.dispose();
    genderController.dispose();
    for (var element in nameControllers) {
      element.dispose();
    }
    for (var element in sexControllers) {
      element.dispose();
    }
  }

  void insertR() {
    SalonLocationDetails loc = ref.watch(latlnghashProvider);
    for (int i = 0; i < int.parse(seatingController.text); i++) {
      // employeesList.add(
      //     {'name': nameControllers[i].text, 'gender': sexControllers[i].text});
      employeesList.add(EmployeeDetails(
          name: nameControllers[i].text, gender: sexControllers[i].text));
      print(employeesList);
    }

    ref.read(firebaseControllerProvider.notifier).insertR(
        context: context,
        salonName: salonController.text,
        ownerName: ownerController.text,
        mobileNumber: int.parse(mobileController.text),
        gpsLocation: '',
        state_: stateController.text,
        city: cityController.text,
        address: addressController.text,
        pincode: int.parse(pincodeController.text),
        openingTime: openingController.text,
        closingTime: closingController.text,
        slotInterval: int.parse(intervalController.text.substring(0, 2)),
        seatingCapacity: int.parse(seatingController.text),
        genderType: genderController.text,
        employees: employeesList);

    ref
        .watch(firebaseControllerProvider.notifier)
        .insertSalonLocation(context: context, object: loc.geoPoint);
  }

  void employeeForm() async {
    nameControllers.clear();
    sexControllers.clear();
    int employees = int.parse(seatingController.text);
    if (employees < 100) {
      for (int i = 1; i <= employees; i++) {
        nameControllers.add(TextEditingController());
        sexControllers.add(TextEditingController());
      }
    }
    setState(() {});
/*
      Column(
        children: [
          Text('Employee $i'),
          Row(
            children: [
              TextField(
                controller: nameControllers[i],
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), label: Text('Name')),
              ),
              DropdownMenu(
                initialSelection: sex[1],
                controller: sexControllers[i],
                label: const Text('Gender'),
                dropdownMenuEntries: sex.map((String sex) {
                  return DropdownMenuEntry(value: sex, label: sex);
                }).toList(),
              ),
            ],
          )
        ],
      ),
      */
  }

  Future<bool> _handleLocationPermission() async {
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled!) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          'Location services are disabled. Please enable the services',
          style: Theme.of(context).textTheme.labelSmall,
        )));
      }
      await Geolocator.openLocationSettings();
      serviceEnabled = await Geolocator.isLocationServiceEnabled();

      setState(() {});
      //return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
            'Location permissions are denied',
            style: Theme.of(context).textTheme.labelSmall,
          )));
        }
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          'Location permissions are permanently denied, we cannot request permissions.',
          style: Theme.of(context).textTheme.labelSmall,
        )));
      }
      return false;
    }

    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        ref
            .watch(currentLocationProvider.notifier)
            .update((state) => LatLng(position.latitude, position.longitude));
        //_center = LatLng(position.latitude, position.longitude);
      });
      //_getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });

    await placemarkFromCoordinates(
            _currentPosition!.latitude, _currentPosition!.longitude)
        .then((value) {
      print('valueeee $value');
      ref.watch(currentAddressProvider.notifier).update((state) =>
          '${value[0].street}, ${value[0].subLocality}, ${value[0].locality}, ${value[0].administrativeArea}');
    }).catchError((e) {
      debugPrint(e);
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30))),
        centerTitle: true,
        title: const Text('Register with us!'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              TextField(
                controller: salonController,
                style: Theme.of(context).textTheme.bodySmall,
                onChanged: (text) => setState(() {}),
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Blue001, width: 2)),
                    label: Text(
                      'Salon Name',
                      style: Theme.of(context).textTheme.bodySmall,
                    )),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: ownerController,
                style: Theme.of(context).textTheme.bodySmall,
                onChanged: (text) => setState(() {}),
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Blue001, width: 2)),
                    label: Text(
                      'Owner Name',
                      style: Theme.of(context).textTheme.bodySmall,
                    )),
              ),
              const SizedBox(height: 20),
              TextField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: mobileController,
                style: Theme.of(context).textTheme.bodySmall,
                onChanged: (text) => setState(() {}),
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                    errorText: (mobileController.text.length == 10 ||
                            mobileController.text.isEmpty)
                        ? null
                        : 'Invalid mobile number!',
                    errorStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.normal),
                    border: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Blue001, width: 2)),
                    label: Text(
                      'Mobile Number',
                      style: Theme.of(context).textTheme.bodySmall,
                    )),
              ),
              const SizedBox(height: 20),
              SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                      onPressed: () {
                        if (serviceEnabled! &&
                            (permission == LocationPermission.whileInUse ||
                                permission == LocationPermission.always) &&
                            _currentPosition != null) {
                          Routemaster.of(context).push('/google_maps');
                        } else {
                          _handleLocationPermission();
                        }
                      },
                      child: Text(
                        'Add salon location',
                        style: Theme.of(context).textTheme.labelSmall,
                      ))),
              const SizedBox(height: 20),
              TextField(
                controller: stateController,
                style: Theme.of(context).textTheme.bodySmall,
                onChanged: (text) => setState(() {}),
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Blue001, width: 2)),
                    label: Text(
                      'State',
                      style: Theme.of(context).textTheme.bodySmall,
                    )),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: cityController,
                style: Theme.of(context).textTheme.bodySmall,
                onChanged: (text) => setState(() {}),
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Blue001, width: 2)),
                    label: Text(
                      'City/Town',
                      style: Theme.of(context).textTheme.bodySmall,
                    )),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: addressController,
                style: Theme.of(context).textTheme.bodySmall,
                onChanged: (text) => setState(() {}),
                keyboardType: TextInputType.streetAddress,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Blue001, width: 2)),
                    label: Text(
                      'Address',
                      style: Theme.of(context).textTheme.bodySmall,
                    )),
              ),
              const SizedBox(height: 20),
              TextField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: pincodeController,
                style: Theme.of(context).textTheme.bodySmall,
                onChanged: (text) => setState(() {}),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    errorText: (pincodeController.text.length == 6 ||
                            pincodeController.text.isEmpty)
                        ? null
                        : 'Invalid pincode!',
                    errorStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.normal),
                    border: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Blue001, width: 2)),
                    label: Text(
                      'Pincode',
                      style: Theme.of(context).textTheme.bodySmall,
                    )),
              ),
              const SizedBox(height: 20),
              DropdownMenu(
                width: MediaQuery.of(context).size.width * 0.91,
                menuHeight: 300,
                initialSelection: time[18],
                controller: openingController,
                textStyle: Theme.of(context).textTheme.bodySmall,
                label: Text(
                  'Opening Time',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                menuStyle: const MenuStyle(
                    surfaceTintColor: MaterialStatePropertyAll(Colors.white),
                    backgroundColor: MaterialStatePropertyAll(Colors.white)),
                dropdownMenuEntries: time.map((String time) {
                  return DropdownMenuEntry(
                      value: time,
                      label: time,
                      style: ButtonStyle(
                          textStyle: MaterialStatePropertyAll(
                            Theme.of(context).textTheme.bodySmall,
                          ),
                          backgroundColor:
                              const MaterialStatePropertyAll(Colors.white)));
                }).toList(),
                onSelected: (value) => setState(() {}),
              ),
              // const SizedBox(height: 20),
              // TextField(
              //   controller: openingController,
              //   onChanged: (text) => setState(() {}),
              //   keyboardType: TextInputType.datetime,
              //   decoration: const InputDecoration(
              //       border: OutlineInputBorder(), label: Text('Opening Time')),
              // ),
              const SizedBox(height: 20),
              DropdownMenu(
                width: MediaQuery.of(context).size.width * 0.91,
                menuHeight: 300,
                initialSelection: time[36],
                controller: closingController,
                textStyle: Theme.of(context).textTheme.bodySmall,
                label: Text(
                  'Closing Time',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                menuStyle: const MenuStyle(
                    surfaceTintColor: MaterialStatePropertyAll(Colors.white),
                    backgroundColor: MaterialStatePropertyAll(Colors.white)),
                dropdownMenuEntries: time.map((String time) {
                  return DropdownMenuEntry(
                      value: time,
                      label: time,
                      style: ButtonStyle(
                          textStyle: MaterialStatePropertyAll(
                            Theme.of(context).textTheme.bodySmall,
                          ),
                          backgroundColor:
                              const MaterialStatePropertyAll(Colors.white)));
                }).toList(),
                onSelected: (value) => setState(() {}),
              ),
              // TextField(
              //   controller: closingController,
              //   onChanged: (text) => setState(() {}),
              //   keyboardType: TextInputType.datetime,
              //   decoration: const InputDecoration(
              //       border: OutlineInputBorder(), label: Text('Closing Time')),
              // ),
              const SizedBox(height: 20),
              /*
              DropdownButtonFormField(
                  hint: const Text('Slot Interval'),
                  decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder()),
                  value: intervalInitial,
                  items: interval.map((int interval) {
                    return DropdownMenuItem(
                        value: interval, child: Text('$interval mins'));
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      intervalInitial = newValue!;
                    });
                  }),
              const SizedBox(height: 20),
              */

              DropdownMenu(
                width: MediaQuery.of(context).size.width * 0.91,
                initialSelection: interval[1],
                controller: intervalController,
                textStyle: Theme.of(context).textTheme.bodySmall,
                label: Text(
                  'Slot Interval',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                menuStyle: const MenuStyle(
                    surfaceTintColor: MaterialStatePropertyAll(Colors.white),
                    backgroundColor: MaterialStatePropertyAll(Colors.white)),
                dropdownMenuEntries: interval.map((int interval) {
                  return DropdownMenuEntry(
                      value: interval,
                      label: '$interval mins',
                      style: ButtonStyle(
                          textStyle: MaterialStatePropertyAll(
                            Theme.of(context).textTheme.bodySmall,
                          ),
                          backgroundColor:
                              const MaterialStatePropertyAll(Colors.white)));
                }).toList(),
                onSelected: (value) => setState(() {}),
              ),
              const SizedBox(height: 20),

              DropdownMenu(
                width: MediaQuery.of(context).size.width * 0.91,
                initialSelection: gender[2],
                controller: genderController,
                textStyle: Theme.of(context).textTheme.bodySmall,
                label: Text(
                  'Salon Type',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                menuStyle: const MenuStyle(
                    surfaceTintColor: MaterialStatePropertyAll(Colors.white),
                    backgroundColor: MaterialStatePropertyAll(Colors.white)),
                dropdownMenuEntries: gender.map((String gender) {
                  return DropdownMenuEntry(
                      value: gender,
                      label: gender,
                      style: ButtonStyle(
                          textStyle: MaterialStatePropertyAll(
                            Theme.of(context).textTheme.bodySmall,
                          ),
                          backgroundColor:
                              const MaterialStatePropertyAll(Colors.white)));
                }).toList(),
                onSelected: (value) => setState(() {}),
              ),
              const SizedBox(height: 20),

              /*
              DropdownButtonFormField(
                  hint: const Text('Salon Type'),
                  decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder()),
                  value: genderInitial,
                  items: gender.map((String gender) {
                    return DropdownMenuItem(value: gender, child: Text(gender));
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      genderInitial = newValue!;
                    });
                  }),
              const SizedBox(height: 20),
              */
              TextField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: seatingController,
                style: Theme.of(context).textTheme.bodySmall,
                onChanged: (text) => setState(() {
                  //if (seatingController.text.length < 3) {
                  employeeForm();
                  //}
                }),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    errorText: seatingController.text.length < 3
                        ? null
                        : 'Invalid seating capacity!',
                    errorStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.normal),
                    border: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Blue001, width: 2)),
                    label: Text(
                      'Seating Capacity',
                      style: Theme.of(context).textTheme.bodySmall,
                    )),
              ),
              /*
              if (display) ...[
                for (int i = 1;
                    i <= int.parse(seatingController.text);
                    i++) ...[
                  Column(
                    children: [
                      Text('Employee $i'),
                      Row(
                        children: [
                          TextField(
                            controller: nameControllers[i],
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                label: Text('Name')),
                          ),
                          DropdownMenu(
                            initialSelection: sex[1],
                            controller: sexControllers[i],
                            label: const Text('Gender'),
                            dropdownMenuEntries: sex.map((String sex) {
                              return DropdownMenuEntry(value: sex, label: sex);
                            }).toList(),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ],
              */
              const SizedBox(height: 15),
              const Divider(),
              ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: seatingController.text.isEmpty ||
                          seatingController.text.length > 2
                      ? 0
                      : int.parse(seatingController.text),
                  itemBuilder: ((context, i) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15),
                        Text(
                          'Employee ${i + 1}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: nameControllers[i],
                          style: Theme.of(context).textTheme.bodySmall,
                          onChanged: (text) => setState(() {}),
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              focusedBorder: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Blue001, width: 2)),
                              label: Text(
                                'Name',
                                style: Theme.of(context).textTheme.bodySmall,
                              )),
                        ),
                        const SizedBox(height: 15),
                        DropdownMenu(
                          width: MediaQuery.of(context).size.width * 0.91,
                          initialSelection: sex[0],
                          controller: sexControllers[i],
                          textStyle: Theme.of(context).textTheme.bodySmall,
                          label: Text(
                            'Gender',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          menuStyle: const MenuStyle(
                              surfaceTintColor:
                                  MaterialStatePropertyAll(Colors.white),
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.white)),
                          dropdownMenuEntries: sex.map((String sex) {
                            return DropdownMenuEntry(
                                value: sex,
                                label: sex,
                                style: ButtonStyle(
                                    textStyle: MaterialStatePropertyAll(
                                      Theme.of(context).textTheme.bodySmall,
                                    ),
                                    backgroundColor:
                                        const MaterialStatePropertyAll(
                                            Colors.white)));
                          }).toList(),
                          onSelected: (value) => setState(() {}),
                        ),
                        const SizedBox(height: 15),
                        const Divider(),
                      ],
                    );
                  })),
              //const SizedBox(height: 15),
              const SizedBox(height: 15),
              SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: enableButton()
                      ? ElevatedButton(
                          onPressed: insertR,
                          child: Text(
                            'Register',
                            style: Theme.of(context).textTheme.labelSmall,
                          ))
                      : ElevatedButton(
                          style: ButtonStyle(
                              elevation: const MaterialStatePropertyAll(0),
                              surfaceTintColor:
                                  const MaterialStatePropertyAll(Colors.white),
                              backgroundColor: MaterialStatePropertyAll(
                                  Colors.grey.shade300)),
                          onPressed: null,
                          child: Text(
                            'Register',
                            style: Theme.of(context).textTheme.labelSmall,
                          ))),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
