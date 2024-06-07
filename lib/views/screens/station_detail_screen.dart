import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:web_admin/app_router.dart';
import 'package:web_admin/constants/dimens.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/theme/theme_extensions/app_button_theme.dart';
import 'package:web_admin/utils/app_focus_helper.dart';
import 'package:web_admin/views/widgets/card_elements.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class StationDetailScreen extends StatefulWidget {
  final String id;

  const StationDetailScreen({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  State<StationDetailScreen> createState() => _StationDetailScreenState();
}

class _StationDetailScreenState extends State<StationDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Station? _station;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStationDetails();
  }

  Future<void> _fetchStationDetails() async {
    try {
      if (widget.id.isEmpty) {
        print('Error: Station ID is empty. Widget ID: ${widget.id}');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final doc = await _firestore.collection('stations').doc(widget.id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        print('Fetched data: $data'); // Debug log

        List<Scooter> scooters = await _fetchScooterDetails(data['scooters'] ?? []);

        setState(() {
          _station = Station(
            id: doc.id,
            name: data['name'] ?? '',
            location: Location(
              name: data['location']['name'] ?? '',
              latitude: (data['location']['latitude'] ?? 0.0).toDouble(),
              longitude: (data['location']['longitude'] ?? 0.0).toDouble(),
            ),
            scooters: scooters,
          );
          _isLoading = false;
        });
      } else {
        print('Document does not exist for station ID: ${widget.id}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching station details for station ID: ${widget.id}, error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<Scooter>> _fetchScooterDetails(List<dynamic> scooterIds) async {
    List<Scooter> scooters = [];
    try {
      for (String scooterId in scooterIds) {
        final doc = await _firestore.collection('scooters').doc(scooterId).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          scooters.add(Scooter(
            id: doc.id,
            location: data['location'] ?? '',
            status: data['status'] ?? '',
            batteryLevel: data['batteryLevel'] ?? 0,
          ));
        } else {
          print('Scooter document $scooterId does not exist');
        }
      }
    } catch (e) {
      print('Error fetching scooter details: $e');
    }
    return scooters;
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Station Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : _station == null
            ? Center(child: const Text('No data available'))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Station ID: ${_station!.id}'),
            Text('Name: ${_station!.name}'),
            Text('Location: ${_station!.location.name}'),
            Text('Latitude: ${_station!.location.latitude}'),
            Text('Longitude: ${_station!.location.longitude}'),
            const SizedBox(height: kDefaultPadding),
            Text('Scooters:', style: themeData.textTheme.titleMedium),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 3 / 2,
              ),
              itemCount: _station!.scooters.length,
              itemBuilder: (context, index) {
                final scooter = _station!.scooters[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Scooter ID: ${scooter.id}'),
                        Text('Location: ${scooter.location}'),
                        Text('Status: ${scooter.status}'),
                        Text('Battery Level: ${scooter.batteryLevel}%'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Station {
  String id;
  String name;
  Location location;
  final List<Scooter> scooters;

  Station({required this.id, required this.name, required this.location, List<Scooter>? scooters})
      : this.scooters = scooters ?? [];
}

class Location {
  final String name;
  final double latitude;
  final double longitude;

  Location({required this.name, required this.latitude, required this.longitude});
}

class Scooter {
  final String id;
  final String location;
  final String status;
  final int batteryLevel;

  Scooter({
    this.id = '',
    required this.location,
    required this.status,
    required this.batteryLevel,
  });
}