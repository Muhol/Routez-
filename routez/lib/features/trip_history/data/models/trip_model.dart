import 'package:cloud_firestore/cloud_firestore.dart';

class TripModel {
  final String id;
  final String origin;
  final String destination;
  final String routeName;
  final String routeNumber;
  final int fare;
  final int durationMins;
  final DateTime departedAt;
  final DateTime? arrivedAt;
  final String paymentMethod; // 'M-Pesa' or 'Cash'
  final String? mpesaRef;
  final String status; // 'Completed' or 'Cancelled'

  TripModel({
    required this.id,
    required this.origin,
    required this.destination,
    required this.routeName,
    required this.routeNumber,
    required this.fare,
    required this.durationMins,
    required this.departedAt,
    this.arrivedAt,
    this.paymentMethod = 'Cash',
    this.mpesaRef,
    this.status = 'Completed',
  });

  factory TripModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TripModel(
      id: doc.id,
      origin: data['origin'] as String? ?? '',
      destination: data['destination'] as String? ?? '',
      routeName: data['routeName'] as String? ?? '',
      routeNumber: data['routeNumber'] as String? ?? '',
      fare: (data['fare'] as num?)?.toInt() ?? 0,
      durationMins: (data['durationMins'] as num?)?.toInt() ?? 0,
      departedAt: (data['departedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      arrivedAt: (data['arrivedAt'] as Timestamp?)?.toDate(),
      paymentMethod: data['paymentMethod'] as String? ?? 'Cash',
      mpesaRef: data['mpesaRef'] as String?,
      status: data['status'] as String? ?? 'Completed',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'origin': origin,
      'destination': destination,
      'routeName': routeName,
      'routeNumber': routeNumber,
      'fare': fare,
      'durationMins': durationMins,
      'departedAt': Timestamp.fromDate(departedAt),
      'arrivedAt': arrivedAt != null ? Timestamp.fromDate(arrivedAt!) : null,
      'paymentMethod': paymentMethod,
      'mpesaRef': mpesaRef,
      'status': status,
    };
  }
}
