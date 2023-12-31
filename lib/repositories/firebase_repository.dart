import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erazor_partner/common/failure.dart';
import 'package:erazor_partner/common/type_defs.dart';
import 'package:erazor_partner/models/booked_person.dart';
import 'package:erazor_partner/models/booked_service.dart';
import 'package:erazor_partner/models/location_details.dart';
import 'package:erazor_partner/models/salon_details.dart';
import 'package:erazor_partner/models/salon_images.dart';
import 'package:erazor_partner/models/service_details.dart';
import 'package:erazor_partner/models/slot_details.dart';
import 'package:erazor_partner/providers/firebase_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final firebaseRepositoryProvider = Provider(
  (ref) => FirebaseRepository(
      firestore: ref.read(firestoreProvider),
      auth: ref.read(authProvider),
      storage: ref.read(storageProvider)),
);

class FirebaseRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  FirebaseRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required FirebaseStorage storage,
  })  : _auth = auth,
        _firestore = firestore,
        _storage = storage;

  CollectionReference get _salons => _firestore.collection('salons');
  CollectionReference get _services => _firestore.collection('services');
  CollectionReference get _slots => _firestore.collection('slots');
  CollectionReference get _bookedServices =>
      _firestore.collection('booked_services');
  CollectionReference get _bookedPerson =>
      _firestore.collection('booked_person');
  CollectionReference get _salonImages => _firestore.collection('salon_images');
  CollectionReference get _salonLocations =>
      _firestore.collection('salon_locations');

  FutureVoid insertR(SalonDetails salon) async {
    try {
      return right(_salons.doc(salon.cid).set(salon.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<SalonDetails> fetchR(String uid) {
    return _salons.doc(uid).snapshots().map(
        (event) => SalonDetails.fromMap(event.data() as Map<String, dynamic>));
  }

  FutureVoid insertS(ServiceDetails service) async {
    try {
      return right(_services.doc().set(service.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<ServiceDetails>> fetchS(String uid) {
    return _services
        .where('uid', isEqualTo: uid)
        .orderBy('priority')
        .snapshots()
        .map((event) => event.docs.map((e) {
              return ServiceDetails.fromMap(
                  e.data() as Map<String, dynamic>, e.id);
            }).toList());
  }

  FutureVoid editS(ServiceDetails service, String key) async {
    try {
      return right(_services.doc(key).update(service.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid deleteS(String key) async {
    try {
      return right(_services.doc(key).delete());
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid updateS(String key, bool enabled) async {
    try {
      return right(_services.doc(key).update({'enabled': enabled}));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid insertSlot(SlotDetails slot) async {
    try {
      return right(_slots.doc().set(slot.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<SlotDetails>> fetchSlots(
      String uid, String employee, Timestamp slotDate) {
    return _slots
        .where('uid', isEqualTo: uid)
        .where('employee', isEqualTo: employee)
        .where('slotDate', isEqualTo: slotDate)
        .orderBy('slotTime')
        .snapshots()
        .map((event) => event.docs.map((e) {
              return SlotDetails.fromMap(
                  e.data() as Map<String, dynamic>, e.id);
            }).toList());
  }

  FutureVoid updateSlot(String key, bool enabled) async {
    try {
      return right(_slots.doc(key).update({'enabled': enabled}));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid cancelSlot(String bid) async {
    try {
      return right(
          _slots.where('bid', isEqualTo: bid).snapshots().forEach((element) {
        for (var element in element.docs) {
          _slots
              .doc(element.id)
              .update({'booked': false, 'bid': '', 'cid': ''});
        }
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid deleteBookedService(String bid) async {
    try {
      return right(_bookedServices
          .where('bid', isEqualTo: bid)
          .snapshots()
          .forEach((element) {
        for (var element in element.docs) {
          _bookedServices.doc(element.id).delete();
        }
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid deleteBookedPerson(String bid) async {
    try {
      return right(_bookedPerson
          .where('bid', isEqualTo: bid)
          .snapshots()
          .forEach((element) {
        for (var element in element.docs) {
          _bookedPerson.doc(element.id).delete();
        }
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<SlotDetails>> fetchBookedSlots(String cid) {
    return _slots
        .where('uid', isEqualTo: cid)
        .where('booked', isEqualTo: true)
        .orderBy('slotDate')
        .orderBy('slotTime')
        .snapshots()
        .map((event) => event.docs.map((e) {
              return SlotDetails.fromMap(
                  e.data() as Map<String, dynamic>, e.id);
            }).toList());
  }

  Stream<List<SlotDetails>> fetchSlotsWithBID(String bid) {
    return _slots
        .where('bid', isEqualTo: bid)
        .where('booked', isEqualTo: true)
        .orderBy('slotDate')
        .orderBy('slotTime')
        .snapshots()
        .map((event) => event.docs.map((e) {
              return SlotDetails.fromMap(
                  e.data() as Map<String, dynamic>, e.id);
            }).toList());
  }

  Stream<List<BookedService>> fetchServicesWithBID(String bid) {
    return _bookedServices
        .where('bid', isEqualTo: bid)
        .snapshots()
        .map((event) => event.docs.map((e) {
              return BookedService.fromMap(
                  e.data() as Map<String, dynamic>, e.id);
            }).toList());
  }

  Stream<List<BookedPerson>> fetchPersonWithBID(String bid) {
    return _bookedPerson
        .where('bid', isEqualTo: bid)
        .snapshots()
        .map((event) => event.docs.map((e) {
              return BookedPerson.fromMap(
                  e.data() as Map<String, dynamic>, e.id);
            }).toList());
  }

  // Storage
  FutureEither<String> storeImageFirebase({
    required String path,
    required String rid,
    required File? file,
  }) async {
    try {
      final ref = _storage.ref().child(path).child(rid);
      UploadTask uploadTask =
          ref.putFile(file!, SettableMetadata(contentType: 'image/jpeg'));

      final snapshot = await uploadTask;

      return right(await snapshot.ref.getDownloadURL());
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid insertImageDoc(SalonImageDetails imageDoc) async {
    try {
      return right(_salonImages.doc().set(imageDoc.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<SalonImageDetails>> fetchSalonImages(String uid) {
    return _salonImages
        .where('uid', isEqualTo: uid)
        .orderBy('order')
        .orderBy('date')
        .snapshots()
        .map((event) => event.docs.map((e) {
              return SalonImageDetails.fromMap(
                  e.data() as Map<String, dynamic>, e.id);
            }).toList());
  }

  FutureVoid updateToken(String cid, String token) async {
    try {
      return right(_salons.doc(cid).update({'token': token}));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid insertSalonLocation(
      //SalonLocationDetails location,
      Map object,
      String uid) async {
    try {
      return right(
          _salonLocations.doc(uid).set({'uid': uid, 'salonGeopoint': object}));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
