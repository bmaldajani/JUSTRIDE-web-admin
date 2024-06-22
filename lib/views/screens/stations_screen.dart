import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:web_admin/constants/dimens.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/theme/theme_extensions/app_button_theme.dart';
import 'package:web_admin/theme/theme_extensions/app_data_table_theme.dart';
import 'package:web_admin/views/widgets/card_elements.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';
import 'package:web_admin/views/screens/station_detail_screen.dart';

class StationsScreen extends StatefulWidget {
  const StationsScreen({Key? key});

  @override
  State<StationsScreen> createState() => _StationsScreenState();
}

class _StationsScreenState extends State<StationsScreen> {
  final _scrollController = ScrollController();
  final _formKey = GlobalKey<FormBuilderState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Station> _stations = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchStations();
  }

Future<void> _fetchStations({String? searchTerm}) async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    Query query = _firestore.collection('stations');
    List<Station> stations = [];

    if (searchTerm != null && searchTerm.isNotEmpty) {
      String searchLower = searchTerm.toLowerCase();

      QuerySnapshot nameQuerySnapshot = await query
          .where('name', isGreaterThanOrEqualTo: searchLower)
          .where('name', isLessThan: searchLower + 'z')
          .get();

      QuerySnapshot idQuerySnapshot = await query
          .where(FieldPath.documentId, isEqualTo: searchTerm)
          .get();

      List<QueryDocumentSnapshot> combinedResults = [
        ...nameQuerySnapshot.docs,
        ...idQuerySnapshot.docs,
      ];

      stations = await Future.wait(combinedResults.map((stationDoc) async {
        final stationData = stationDoc.data() as Map<String, dynamic>;
        final List<String> scooterIds = List<String>.from(stationData['scooters']);

        final List<Scooter> scooters = [];
        for (String scooterId in scooterIds) {
          final scooterDoc = await _firestore.collection('scooters').doc(scooterId).get();
          if (scooterDoc.exists) {
            final scooterData = scooterDoc.data() as Map<String, dynamic>;
            scooters.add(Scooter(
              id: scooterDoc.id,
              location: scooterData['location'],
              status: scooterData['status'],
              batteryLevel: scooterData['batteryLevel'],
            ));
          }
        }

        return Station(
          id: stationDoc.id, // Use document ID as station ID
          name: stationData['name'],
          location: Location(
            latitude: stationData['location']['latitude'].toDouble(),
            longitude: stationData['location']['longitude'].toDouble(),
          ),
          scooters: scooters,
        );
      }).toList());
    } else {
      final QuerySnapshot stationSnapshot = await query.get();
      stations = await Future.wait(stationSnapshot.docs.map((stationDoc) async {
        final stationData = stationDoc.data() as Map<String, dynamic>;
        final List<String> scooterIds = List<String>.from(stationData['scooters']);

        final List<Scooter> scooters = [];
        for (String scooterId in scooterIds) {
          final scooterDoc = await _firestore.collection('scooters').doc(scooterId).get();
          if (scooterDoc.exists) {
            final scooterData = scooterDoc.data() as Map<String, dynamic>;
            scooters.add(Scooter(
              id: scooterDoc.id,
              location: scooterData['location'],
              status: scooterData['status'],
              batteryLevel: scooterData['batteryLevel'],
            ));
          }
        }

        return Station(
          id: stationDoc.id, // Use document ID as station ID
          name: stationData['name'],
          location: Location(
            latitude: stationData['location']['latitude'].toDouble(),
            longitude: stationData['location']['longitude'].toDouble(),
          ),
          scooters: scooters,
        );
      }).toList());
    }

    setState(() {
      _stations.clear();
      _stations.addAll(stations);
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _isLoading = false;
      _errorMessage = 'Failed to load stations. Please try again later.';
    });
  }
}



  Future<void> _addStation(Station station) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final docRef = await _firestore.collection('stations').add({
        'name': station.name,
        'location': {
          'latitude': station.location.latitude,
          'longitude': station.location.longitude,
        },
        'scooters': station.scooters.map((scooter) => scooter.id).toList(),
      });

      final newStation = Station(
        id: docRef.id,
        name: station.name,
        location: station.location,
        scooters: station.scooters,
      );

      setState(() {
        _stations.add(newStation);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to add station. Please try again later.';
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    final themeData = Theme.of(context);
    final appDataTableTheme = themeData.extension<AppDataTableTheme>()!;

    return PortalMasterLayout(
      body: ListView(
        padding: const EdgeInsets.all(kDefaultPadding),
        children: [
          Text(
            'Stations',
            style: themeData.textTheme.headlineMedium,
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
          if (_errorMessage != null)
            Center(child: Text(_errorMessage!, style: TextStyle(color: Colors.red))),
          if (!_isLoading && _errorMessage == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CardHeader(
                      title: 'Stations',
                    ),
                    CardBody(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: FormBuilder(
                              key: _formKey,
                              autovalidateMode: AutovalidateMode.disabled,
                              child: SizedBox(
                                width: double.infinity,
                                child: Wrap(
                                  direction: Axis.horizontal,
                                  spacing: kDefaultPadding,
                                  runSpacing: kDefaultPadding,
                                  alignment: WrapAlignment.spaceBetween,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 300.0,
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: kDefaultPadding * 1.5),
                                        child: FormBuilderTextField(
                                          name: 'search',
                                          decoration: InputDecoration(
                                            labelText: lang.search,
                                            hintText: lang.search,
                                            border: const OutlineInputBorder(),
                                            floatingLabelBehavior: FloatingLabelBehavior.always,
                                            isDense: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: kDefaultPadding),
                                          child: SizedBox(
                                            height: 40.0,
                                            child: ElevatedButton(
  style: themeData.extension<AppButtonTheme>()!.infoElevated,
  onPressed: () {
    _formKey.currentState?.save(); // Ensure the form state is saved
    final searchValue = _formKey.currentState?.fields['search']?.value as String?;
    _fetchStations(searchTerm: searchValue);
  },
  child: Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
        child: Icon(
          Icons.search,
          size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
        ),
      ),
      Text(lang.search),
    ],
  ),
),


                                          ),
                                        ),
                                        SizedBox(
                                          height: 40.0,
                                          child: ElevatedButton(
                                            style: themeData.extension<AppButtonTheme>()!.successElevated,
                                            onPressed: () => _showAddStationDialog(context),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                                  child: Icon(
                                                    Icons.add,
                                                    size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                  ),
                                                ),
                                                Text(lang.crudNew),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final double dataTableWidth = max(kScreenWidthMd, constraints.maxWidth);

                                return Scrollbar(
                                  controller: _scrollController,
                                  thumbVisibility: true,
                                  trackVisibility: true,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    controller: _scrollController,
                                    child: SizedBox(
                                      width: dataTableWidth,
                                      child: Theme(
                                        data: themeData.copyWith(
                                          cardTheme: appDataTableTheme.cardTheme,
                                          dataTableTheme: appDataTableTheme.dataTableThemeData,
                                        ),
                                        child: PaginatedDataTable(
                                          source: DataSource(
                                            stations: _stations,
                                            onDetailButtonPressed: (station) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => StationDetailScreen(id: station.id),
                                                ),
                                              );
                                            },
                                            onDeleteButtonPressed: (station) => _deleteStation(station),
                                          ),
                                          rowsPerPage: 20,
                                          showCheckboxColumn: false,
                                          showFirstLastButtons: true,
                                          columns: const [
                                            DataColumn(label: Text('Station ID')),
                                            DataColumn(label: Text('Name')),
                                            DataColumn(label: Text('Latitude')),
                                            DataColumn(label: Text('Longitude')),
                                            DataColumn(label: Text('Actions')),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _deleteStation(Station station) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if the station has scooters
      if (station.scooters.isNotEmpty) {
        final selectedStation = await showDialog<Station>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Select Destination Station for Scooters'),
              content: DropdownButtonFormField<Station>(
                value: null,
                onChanged: (value) => Navigator.pop(context, value),
                items: _stations
                    .where((s) => s.id != station.id) // Exclude the station being deleted
                    .map((s) {
                      return DropdownMenuItem<Station>(
                        value: s,
                        child: Text(s.name),
                      );
                    })
                    .toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context), // Cancel
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Confirm
                  },
                  child: Text('Confirm'),
                ),
              ],
            );
          },
        );

        if (selectedStation != null) {
          await _moveScootersToStation(station, selectedStation);
        } else {
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      await _firestore.collection('stations').doc(station.id).delete();
      setState(() {
        _stations.remove(station);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to delete station. Please try again later.';
      });
    }
  }

  Future<void> _moveScootersToStation(Station sourceStation, Station destinationStation) async {
    final WriteBatch batch = _firestore.batch();

    for (final scooter in sourceStation.scooters) {
      final scooterDocRef = _firestore.collection('scooters').doc(scooter.id);
      batch.update(scooterDocRef, {'location': destinationStation.name});
    }

    final destinationStationDocRef = _firestore.collection('stations').doc(destinationStation.id);
    final List<String> scooterIds = sourceStation.scooters.map((s) => s.id).toList();
    batch.update(destinationStationDocRef, {
      'scooters': FieldValue.arrayUnion(scooterIds),
    });

    await batch.commit();
  }

  void _showAddStationDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController latitudeController = TextEditingController();
    final TextEditingController longitudeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Station'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Station Name'),
              ),
             
              TextField(
                controller: latitudeController,
                decoration: const InputDecoration(labelText: 'Latitude'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: longitudeController,
                decoration: const InputDecoration(labelText: 'Longitude'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final station = Station(
                  id: '', // Firestore will generate this
                  name: nameController.text,
                  location: Location(
                    latitude: double.tryParse(latitudeController.text) ?? 0.0,
                    longitude: double.tryParse(longitudeController.text) ?? 0.0,
                  ),
                  scooters: [],
                );
                _addStation(station);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class DataSource extends DataTableSource {
  final List<Station> stations;
  final void Function(Station) onDetailButtonPressed;
  final void Function(Station) onDeleteButtonPressed;

  DataSource({
    required this.stations,
    required this.onDetailButtonPressed,
    required this.onDeleteButtonPressed,
  });

  @override
  DataRow? getRow(int index) {
    final station = stations[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(station.id)),
        DataCell(Text(station.name)),
        DataCell(Text(station.location.latitude.toString())),
        DataCell(Text(station.location.longitude.toString())),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: kDefaultPadding),
                child: OutlinedButton(
                  onPressed: () => onDetailButtonPressed.call(station),
                  child: const Text('Detail'),
                ),
              ),
              OutlinedButton(
                onPressed: () => onDeleteButtonPressed.call(station),
                child: const Text('Delete'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => stations.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}

class Station {
  String id;
  String name;
  Location location;
  final List<Scooter> scooters;

  Station({List<Scooter>? scooters, required this.id, required this.name, required this.location})
      : scooters = scooters ?? [];
}

class Location {
  final double latitude;
  final double longitude;

  Location({required this.latitude, required this.longitude});
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
