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
import 'package:data_table_2/data_table_2.dart'; // Add this line


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
  late Station _station;
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();

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
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _station == null
                ? const Center(child: Text('No data available'))
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildStationDetails(themeData),
                        const SizedBox(height: 16.0),
                        const Divider(thickness: 2.0),
                        const SizedBox(height: 16.0),
                        _buildScooterTable(),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildStationDetails(ThemeData themeData) {
    

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Station ID: ${_station.id}', style: themeData.textTheme.bodyMedium),
              const SizedBox(height: 8.0),
              TextFormField(
                initialValue: _station.name,
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) {
                  setState(() {
                    _station.name = value;
                  });
                },
              ),
             
              TextFormField(
                initialValue: _station.location.latitude.toString(),
                decoration: InputDecoration(labelText: 'Latitude'),
                onChanged: (value) {
                  setState(() {
                    _station.location.latitude = double.parse(value);
                  });
                },
              ),
              TextFormField(
                initialValue: _station.location.longitude.toString(),
                decoration: InputDecoration(labelText: 'Longitude'),
                onChanged: (value) {
                  setState(() {
                    _station.location.longitude = double.parse(value);
                  });
                },
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _editStationDetails(context);
                    },
                    child: Text("edit"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

 Future<void> _editStationDetails(BuildContext context) async {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Edit Station Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: _station.name,
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) {
                  setState(() {
                    _station.name = value;
                  });
                },
              ),
              
              TextFormField(
                initialValue: _station.location.latitude.toString(),
                decoration: InputDecoration(labelText: 'Latitude'),
                onChanged: (value) {
                  setState(() {
                    _station.location.latitude = double.parse(value);
                  });
                },
              ),
              TextFormField(
                initialValue: _station.location.longitude.toString(),
                decoration: InputDecoration(labelText: 'Longitude'),
                onChanged: (value) {
                  setState(() {
                    _station.location.longitude = double.parse(value);
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Save edited details to Firestore
                await _firestore.collection('stations').doc(_station.id).update({
                  'name': _station.name,
                  'location': {
                    
                    'latitude': _station.location.latitude,
                    'longitude': _station.location.longitude,
                  },
                });
                // Optionally, you can show a success message
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Station details updated successfully'),
                ));
              } catch (e) {
                // Handle errors
                print('Error updating station details: $e');
                // Optionally, you can show an error message
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Failed to update station details'),
                  backgroundColor: Colors.red,
                ));
              }
            },
            child: Text('Save'),
          ),
        ],
      );
    },
  );
}


Widget _buildScooterTable() {
return ConstrainedBox(
constraints: BoxConstraints(maxHeight: 400),
child: DataTable2(
columnSpacing: 12,
horizontalMargin: 12,
minWidth: 600,
columns: const [
DataColumn(
label: Row(
children: [
Icon(Icons.directions_bike),
SizedBox(width: 8.0),
Text('Scooter ID'),
],
),
),
DataColumn(
label: Row(
children: [
Icon(Icons.location_on),
SizedBox(width: 8.0),
Text('Location'),
],
),
),
DataColumn(
label: Row(
children: [
Icon(Icons.info),
SizedBox(width: 8.0),
Text('Status'),
],
),
),
DataColumn(
label: Row(
children: [
Icon(Icons.battery_full),
SizedBox(width: 8.0),
Text('Battery Level'),
],
),
),
],
rows: _station.scooters.map((scooter) {
return DataRow(cells: [
DataCell(Text(scooter.id)),
DataCell(Text(scooter.location)),
DataCell(Text(scooter.status)),
DataCell(Text(
'${scooter.batteryLevel}%',
style: TextStyle(color: scooter.batteryLevel < 20 ? Colors.red : Colors.green),
)),
]);
}).toList(),
),
);
}
}

class Scooter {
final String id;
final String location;
final String status;
final int batteryLevel;

Scooter({
required this.id,
required this.location,
required this.status,
required this.batteryLevel,
});
}

class Station {
final String id;
String name;
final Location location;
final List<Scooter> scooters;

Station({
required this.id,
required this.name,
required this.location,
required this.scooters,
});
}

class Location {

double latitude;
double longitude;

Location({
required this.latitude,
required this.longitude,
});
}