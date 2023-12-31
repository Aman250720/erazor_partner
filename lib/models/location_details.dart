// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// class LocationDetails {
//   final String uid;
//   final double lat;
//   final double lng;
//   final String geohash;
// }

class SalonLocationDetails {
  final String uid;
  final Map<String, dynamic> geoPoint;
  SalonLocationDetails({
    required this.uid,
    required this.geoPoint,
  });

  SalonLocationDetails copyWith({
    String? uid,
    Map<String, dynamic>? geoPoint,
  }) {
    return SalonLocationDetails(
      uid: uid ?? this.uid,
      geoPoint: geoPoint ?? this.geoPoint,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'geoPoint': geoPoint,
    };
  }

  factory SalonLocationDetails.fromMap(Map<String, dynamic> map) {
    return SalonLocationDetails(
      uid: map['uid'] as String,
      geoPoint: map['geoPoint'] as Map<String, dynamic>,
    );
  }

  String toJson() => json.encode(toMap());

  factory SalonLocationDetails.fromJson(String source) =>
      SalonLocationDetails.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'SalonLocationDetails(uid: $uid, geoPoint: $geoPoint)';

  @override
  bool operator ==(covariant SalonLocationDetails other) {
    if (identical(this, other)) return true;

    return other.uid == uid && mapEquals(other.geoPoint, geoPoint);
  }

  @override
  int get hashCode => uid.hashCode ^ geoPoint.hashCode;
}

// SalonGeoPoint

// class SalonGeopoint {
//   final String geohash;
//   final GeoPoint geoPoint;
//   SalonGeopoint({
//     required this.geohash,
//     required this.geoPoint,
//   });
// }
