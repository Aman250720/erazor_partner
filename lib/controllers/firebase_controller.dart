import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:erazor_partner/common/error_text.dart';
import 'package:erazor_partner/common/snackbar.dart';
import 'package:erazor_partner/controllers/auth_controller.dart';
import 'package:erazor_partner/models/booked_person.dart';
import 'package:erazor_partner/models/booked_service.dart';
import 'package:erazor_partner/models/customer_details.dart';
import 'package:erazor_partner/models/employee_details.dart';
import 'package:erazor_partner/models/location_details.dart';
import 'package:erazor_partner/models/salon_details.dart';
import 'package:erazor_partner/models/salon_images.dart';
import 'package:erazor_partner/models/service_details.dart';
import 'package:erazor_partner/models/slot_details.dart';
import 'package:erazor_partner/providers/firebase_providers.dart';
import 'package:erazor_partner/repositories/firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

class MyParameter extends Equatable {
  const MyParameter({
    required this.employee,
    required this.slotDate,
  });

  final String employee;
  final Timestamp slotDate;

  @override
  List<Object> get props => [employee, slotDate];
}

final salonDetailsProvider = StateProvider<SalonDetails?>((ref) => null);

final salonProvider = StreamProvider((ref) {
  return ref.watch(firebaseControllerProvider.notifier).fetchR();
});

final servicesProvider = StreamProvider((ref) {
  return ref.watch(firebaseControllerProvider.notifier).fetchS();
});

final slotsProvider =
    StreamProvider.autoDispose.family<List<SlotDetails>, MyParameter>(
  (ref, args) {
    return ref
        .watch(firebaseControllerProvider.notifier)
        .fetchSlots(args.employee, args.slotDate);
  },
);

final bookedSlotsProvider = StreamProvider((ref) {
  return ref.watch(firebaseControllerProvider.notifier).fetchBookedSlots();
});

final slotsBIDProvider = StreamProvider.family((ref, String bid) {
  return ref.watch(firebaseControllerProvider.notifier).fetchSlotsWithBID(bid);
});

final servicesBIDProvider = StreamProvider.family((ref, String bid) {
  return ref
      .watch(firebaseControllerProvider.notifier)
      .fetchServicesWithBID(bid);
});

final personBIDProvider = StreamProvider.family((ref, String bid) {
  return ref.watch(firebaseControllerProvider.notifier).fetchPersonWithBID(bid);
});

final salonImagesProvider = StreamProvider((ref) {
  return ref.watch(firebaseControllerProvider.notifier).fetchSalonImages();
});

final firebaseControllerProvider =
    StateNotifierProvider<FirebaseController, bool>((ref) {
  final firebaseRepository = ref.watch(firebaseRepositoryProvider);
  //final storageRepository = ref.watch(storageRepositoryProvider);
  return FirebaseController(
    firebaseRepository: firebaseRepository,
    //storageRepository: storageRepository,
    ref: ref,
  );
});

class FirebaseController extends StateNotifier<bool> {
  final FirebaseRepository _firebaseRepository;
  final Ref _ref;
  //final StorageRepository _storageRepository;
  FirebaseController({
    required FirebaseRepository firebaseRepository,
    required Ref ref,
    //required StorageRepository storageRepository,
  })  : _firebaseRepository = firebaseRepository,
        _ref = ref,
        //_storageRepository = storageRepository,
        super(false);

  void insertR(
      {required BuildContext context,
      required String salonName,
      required String ownerName,
      required int mobileNumber,
      required String gpsLocation,
      required String state_,
      required String city,
      required String address,
      required int pincode,
      required String openingTime,
      required String closingTime,
      required int slotInterval,
      required int seatingCapacity,
      required String genderType,
      //required List<Map<String, String>> employees
      required List<EmployeeDetails> employees}) async {
    state = true;
    final user = _ref.watch(authStateChangeProvider).value;
    final fcm = _ref.watch(messagingProvider);
    final token = await fcm.getToken();
    final SalonDetails salon = SalonDetails(
        //cid: user!.uid,
        cid: user!.uid,
        salonName: salonName,
        ownerName: ownerName,
        mobileNumber: mobileNumber,
        gpsLocation: gpsLocation,
        state: state_,
        city: city,
        address: address,
        pincode: pincode,
        openingTime: openingTime,
        closingTime: closingTime,
        slotInterval: slotInterval,
        seatingCapacity: seatingCapacity,
        genderType: genderType,
        token: token ?? '',
        employees: employees);

    final res = await _firebaseRepository.insertR(salon);
    state = false;
    res.fold((l) => showSnackBar(context, 'Some error occurred!'), (r) {
      showSnackBar(context, 'Registered successfully!');
      Routemaster.of(context).replace('/');
    });
  }

  Stream<SalonDetails> fetchR() {
    final user = _ref.watch(authStateChangeProvider).value;
    return _firebaseRepository.fetchR(user!.uid);
  }

  void insertS({
    required BuildContext context,
    //required String uid,
    required String serviceName,
    required String description,
    required String imageUrl,
    required int servicePrice,
    required int finalPrice,
    required int serviceDuration,
    required bool enabled,
    required int priority,
  }) async {
    state = true;
    final user = _ref.watch(authStateChangeProvider).value;
    final ServiceDetails service = ServiceDetails(
        key: '',
        uid: user!.uid,
        serviceName: serviceName,
        description: description,
        imageUrl: imageUrl,
        servicePrice: servicePrice,
        finalPrice: finalPrice,
        serviceDuration: serviceDuration,
        enabled: enabled,
        priority: priority);

    final res = await _firebaseRepository.insertS(service);
    state = false;
    res.fold((l) {
      showSnackBar(context, 'Some error occurred!');
    }, (r) {
      showSnackBar(context, 'Service added!');
      Routemaster.of(context).pop();
    });
  }

  Stream<List<ServiceDetails>> fetchS() {
    final user = _ref.watch(authStateChangeProvider).value;
    return _firebaseRepository.fetchS(user!.uid);
  }

  void editS({
    required BuildContext context,
    required String key,
    required String serviceName,
    required String description,
    required String imageUrl,
    required int servicePrice,
    required int finalPrice,
    required int serviceDuration,
    required bool enabled,
    required int priority,
  }) async {
    state = true;
    final user = _ref.watch(authStateChangeProvider).value;
    final ServiceDetails service = ServiceDetails(
        key: key,
        uid: user!.uid,
        serviceName: serviceName,
        description: description,
        imageUrl: imageUrl,
        servicePrice: servicePrice,
        finalPrice: finalPrice,
        serviceDuration: serviceDuration,
        enabled: enabled,
        priority: priority);

    final res = await _firebaseRepository.editS(service, key);
    state = false;
    res.fold((l) => showSnackBar(context, 'Some error occurred!'), (r) {
      showSnackBar(context, 'Service updated!');
      Routemaster.of(context).pop();
    });
  }

  void deleteS({
    required BuildContext context,
    required String key,
  }) async {
    state = true;
    final res = await _firebaseRepository.deleteS(key);
    state = false;
    res.fold((l) => showSnackBar(context, 'Some error occurred!'), (r) {
      showSnackBar(context, 'Service deleted!');
    });
  }

  void updateS({
    required BuildContext context,
    required String key,
    required bool enabled,
  }) async {
    state = true;
    final res = await _firebaseRepository.updateS(key, enabled);
    state = false;
    res.fold((l) => showSnackBar(context, 'Some error occurred!'), (r) {
      showSnackBar(context, 'Success!');
    });
  }

  void insertSlot({
    required BuildContext context,
    required Timestamp slotDate,
    required String slotTime,
    required String employee,
    required String salon,
  }) async {
    state = true;
    final user = _ref.watch(authStateChangeProvider).value;
    final SlotDetails slot = SlotDetails(
        key: '',
        uid: user!.uid,
        cid: '',
        bid: '',
        slotDate: slotDate,
        slotTime: slotTime,
        employee: employee,
        salon: salon,
        enabled: true,
        booked: false,
        status: 'Pending');

    final res = await _firebaseRepository.insertSlot(slot);
    state = false;
    res.fold((l) => showSnackBar(context, 'Some error occurred!'), (r) {});
  }

  Stream<List<SlotDetails>> fetchSlots(String employee, Timestamp slotDate) {
    final user = _ref.watch(authStateChangeProvider).value;
    return _firebaseRepository.fetchSlots(user!.uid, employee, slotDate);
  }

  void updateSlot({
    required BuildContext context,
    required String key,
    required bool enabled,
  }) async {
    state = true;
    final res = await _firebaseRepository.updateSlot(key, enabled);
    state = false;
    res.fold((l) => showSnackBar(context, 'Some error occurred!'), (r) {
      showSnackBar(context, 'Success!');
    });
  }

  void cancelSlot({
    required BuildContext context,
    required String bid,
  }) async {
    state = true;
    final res = await _firebaseRepository.cancelSlot(bid);
    state = false;
    res.fold((l) => showSnackBar(context, 'Some error occurred!'), (r) {
      showSnackBar(context, 'Success!');
    });
  }

  void deleteBookedServices({
    required BuildContext context,
    required String bid,
  }) async {
    state = true;
    final res = await _firebaseRepository.deleteBookedService(bid);
    state = false;
    res.fold((l) => showSnackBar(context, 'Some error occurred!'), (r) {
      showSnackBar(context, 'Success!');
    });
  }

  void deleteBookedPerson({
    required BuildContext context,
    required String bid,
  }) async {
    state = true;
    final res = await _firebaseRepository.deleteBookedPerson(bid);
    state = false;
    res.fold((l) => showSnackBar(context, 'Some error occurred!'), (r) {
      showSnackBar(context, 'Success!');
    });
  }

  Stream<List<SlotDetails>> fetchBookedSlots() {
    final user = _ref.watch(authStateChangeProvider).value;
    return _firebaseRepository.fetchBookedSlots(user!.uid);
  }

  Stream<List<SlotDetails>> fetchSlotsWithBID(String bid) {
    return _firebaseRepository.fetchSlotsWithBID(bid);
  }

  Stream<List<BookedService>> fetchServicesWithBID(String bid) {
    return _firebaseRepository.fetchServicesWithBID(bid);
  }

  Stream<List<BookedPerson>> fetchPersonWithBID(String bid) {
    return _firebaseRepository.fetchPersonWithBID(bid);
  }

  void storeImageFirebase({
    required BuildContext context,
    required File? file,
  }) async {
    state = true;
    String rid = const Uuid().v1();
    final user = _ref.watch(authStateChangeProvider).value;

    final imageRes = await _firebaseRepository.storeImageFirebase(
      path: 'salon_images/${user!.uid}',
      rid: rid,
      file: file,
    );

    imageRes.fold((l) => showSnackBar(context, l.message), (url) async {
      final imageDoc = SalonImageDetails(
          key: '',
          uid: user.uid,
          url: url,
          order: 1,
          date: Timestamp.fromDate(DateTime.now()));

      final res = await _firebaseRepository.insertImageDoc(imageDoc);
      state = false;
      res.fold((l) => showSnackBar(context, 'Some error occurred!'), (r) {
        showSnackBar(context, 'Image inserted!');
      });
    });
  }

  Stream<List<SalonImageDetails>> fetchSalonImages() {
    final user = _ref.watch(authStateChangeProvider).value;
    return _firebaseRepository.fetchSalonImages(user!.uid);
  }

  void updateToken({required String token}) async {
    state = true;
    final user = _ref.watch(authStateChangeProvider).value;

    final res = await _firebaseRepository.updateToken(user!.uid, token);
    state = false;
    res.fold((l) => ErrorText(error: l.toString()), (r) => null);
  }

  void insertSalonLocation(
      {required BuildContext context,
      //required SalonLocationDetails location,
      required Map<String, dynamic> object}) async {
    state = true;
    final user = _ref.watch(authStateChangeProvider).value;
    // final SalonLocationDetails salonLocation =
    //     SalonLocationDetails(uid: user!.uid, geoPoint: object);

    final res =
        await _firebaseRepository.insertSalonLocation(object, user!.uid);
    state = false;
    res.fold((l) => showSnackBar(context, 'Some error occurred!'), (r) {
      showSnackBar(context, 'Location saved!');
    });
  }
}
