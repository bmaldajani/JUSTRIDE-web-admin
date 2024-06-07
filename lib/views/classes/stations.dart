import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:web_admin/views/classes/scooter.dart';
// import 'location.dart';
// import 'package:web_admin/views/screens/station_detail_screen.dart';
// class StationScreen extends StatefulWidget {
//   const StationScreen({super.key});

//   @override
//   State<StationScreen> createState() => _StationScreenState();
// }

// class _StationScreenState extends State<StationScreen> {
//   late StationService _stationService;
//   late Stream<List<Station>> _stationsStream;

//   @override
//   void initState() {
//     super.initState();
//     _stationService = StationService();
//     _stationsStream = _stationService.getStations();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<List<Station>>(
//       stream: _stationsStream,
//       builder: (context, snapshot) {
//         if (snapshot.hasError) {
//           return Text('Error: ${snapshot.error}');
//         }

//         if (!snapshot.hasData) {
//           return CircularProgressIndicator();
//         }

//         return ListView.builder(
//           itemCount: snapshot.data!.length,
//           itemBuilder: (context, index) {
//             final station = snapshot.data![index];
//             return ListTile(
//               title: Text(station.name),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => StationDetailScreen(station: station),
//                   ),
//                 );
//               },
//             );
//           },
//         );
//       },
//     );
//   }
// }
// class Station {
//   String id;
//   String name;
//   List<Scooter> scooters;
//   Location location;

//   Station({required this.id, required this.name, required this.scooters, required this.location});

//   factory Station.fromFirestore(DocumentSnapshot doc) {
//     return Station(
//       id: doc.id,
//       name: doc['name'],
//       scooters: (doc['scooters'] as List).map((scooter) => Scooter.fromMap(scooter)).toList(),
//       location: Location.fromMap(doc['location']),
//     );
//   }

//   Map<String, dynamic> toFirestore() {
//     return {
//       'name': name,
//       'scooters': scooters.map((scooter) => scooter.toMap()).toList(),
//       'location': location.toMap(),
//     };
//   }

//   void addScooter(Scooter scooter) {
//     scooters.add(scooter);
//   }

//   void removeScooter(Scooter scooter) {
//     scooters.remove(scooter);
//   }
// }

// class StationService {
//   final CollectionReference _stationsCollection = FirebaseFirestore.instance.collection('stations');

//   Future<void> addStation(Station station) async {
//     await _stationsCollection.doc(station.id).set(station.toFirestore());
//   }

//   Stream<List<Station>> getStations() {
//     return _stationsCollection.snapshots().map((querySnapshot) => querySnapshot.docs.map((doc) => Station.fromFirestore(doc)).toList());
//   }

//   Future<void> deleteStation(String stationId) async {
//     await _stationsCollection.doc(stationId).delete();
//   }

//   Future<void> updateStation(Station station) async {
//     await _stationsCollection.doc(station.id).update(station.toFirestore());
//   }
// }