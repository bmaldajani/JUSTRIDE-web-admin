import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:web_admin/app_router.dart';
import 'package:web_admin/constants/dimens.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/theme/theme_extensions/app_button_theme.dart';
import 'package:web_admin/theme/theme_extensions/app_data_table_theme.dart';
import 'package:web_admin/views/widgets/card_elements.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';

class ScooterScreen extends StatefulWidget {
  const ScooterScreen({super.key});
  
  @override
  State<ScooterScreen> createState() => _ScooterScreenState();
}

class _ScooterScreenState extends State<ScooterScreen> {
  bool _isLoading = true;
  final _scrollController = ScrollController();
  final _formKey = GlobalKey<FormBuilderState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late DataSource _dataSource;
  late List<Station> _stations = [];

  @override
  void initState() {
    super.initState();
    _fetchStations();
    _fetchScooters();
    _fetchData();
  }

  Future<void> _fetchData() async {
    // Simulate fetching data
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchStations() async {
    final QuerySnapshot snapshot = await _firestore.collection('stations').get();
    setState(() {
      _stations = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Station(
          id: doc.id,
          name: data['name'],
          location: Location(
            name: data['location']['name'],
            latitude: data['location']['latitude'],
            longitude: data['location']['longitude'],
          ),
        );
      }).toList();
    });
  }

  Future<void> _fetchScooters() async {
    final QuerySnapshot snapshot = await _firestore.collection('scooters').get();
    final List<Scooter> scooters = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Scooter(
        id: doc.id,
        location: data['location'],
        status: data['status'],
        batteryLevel: data['batteryLevel'],
      );
    }).toList();
    setState(() {
      _dataSource = DataSource(
        scooters: scooters,
        onDetailButtonPressed: (scooter) => GoRouter.of(context).go('${RouteUri.scooterDetail}?id=${scooter.id}'),
        onDeleteButtonPressed: (scooter) => _deleteScooter(scooter),
      );
    });
  }

  Future<void> _addScooter(Scooter scooter, String selectedStation) async {
    final WriteBatch batch = _firestore.batch();

    // Add the scooter data to Firestore and get the document reference
    final DocumentReference scooterDocRef = _firestore.collection('scooters').doc();

    final Map<String, dynamic> scooterData = {
      'location': selectedStation,
      'status': scooter.status,
      'batteryLevel': scooter.batteryLevel,
    };

    batch.set(scooterDocRef, scooterData);

    // Get the station document reference
    final QuerySnapshot stationSnapshot = await _firestore.collection('stations').where('name', isEqualTo: selectedStation).limit(1).get();

    if (stationSnapshot.docs.isNotEmpty) {
      final DocumentReference stationDocRef = stationSnapshot.docs.first.reference;

      // Update the station document to include the new scooter in the scooters array
      batch.update(stationDocRef, {
        'scooters': FieldValue.arrayUnion([scooterDocRef.id]),
      });
    }

    // Commit the batch write
    await batch.commit();

    // Get the ID generated by Firestore
    final String id = scooterDocRef.id;

    // Update the scooter object with the generated ID
    final updatedScooter = Scooter(
      id: id, // Assign the generated ID
      location: selectedStation,
      status: scooter.status,
      batteryLevel: scooter.batteryLevel,
    );

    // Update the DataSource with the updated scooter
    setState(() {
      _dataSource.scooters.add(updatedScooter);
    });

    // Find the index of the selected station
    final index = _stations.indexWhere((station) => station.name == selectedStation);
    if (index != -1) {
      // Add the new scooter to the scooters list of the selected station
      setState(() {
        _stations[index].scooters.add(updatedScooter);
      });
    }
  }

  Future<void> _deleteScooter(Scooter scooter) async {
    await _firestore.collection('scooters').doc(scooter.id).delete();
    setState(() {
      _dataSource.scooters.remove(scooter);
    });
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
    if (_isLoading) {
      // Display a loading indicator
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } 
    return PortalMasterLayout(
      body: ListView(
        padding: const EdgeInsets.all(kDefaultPadding),
        children: [
          Text(
            'Scooters',
            style: themeData.textTheme.headlineMedium,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CardHeader(
                    title: 'Scooters',
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
                                            onPressed: () {},
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
                                          onPressed: () => _showAddScooterDialog(context),
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
                            builder:
                             (context, constraints) {
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
                                      child: _dataSource != null
                                          ? PaginatedDataTable(
                                              source: _dataSource,
                                              rowsPerPage: 20,
                                              showCheckboxColumn: false,
                                              showFirstLastButtons: true,
                                              columns: const [
                                                DataColumn(label: Text('ID'), numeric: true),
                                                DataColumn(label: Text('Location')),
                                                DataColumn(label: Text('Status')),
                                                DataColumn(label: Text('Battery Level')),
                                                DataColumn(label: Text('Actions')),
                                              ],
                                            )
                                          : const CircularProgressIndicator(),
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

  void _showAddScooterDialog(BuildContext context) {
    final TextEditingController locationController = TextEditingController();
    final TextEditingController batteryLevelController = TextEditingController();

    // Define options for the status dropdown
    final List<String> statusOptions = ['available', 'unavailable', 'disabled'];
    String? selectedStatus;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Scooter'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: locationController.text.isEmpty ? null : locationController.text,
                    onChanged: (value) {
                      setState(() {
                        locationController.text = value!;
                      });
                    },
                    items: _stations.map((station) {
                      return DropdownMenuItem<String>(
                        value: station.name,
                        child: Text(station.name),
                      );
                    }).toList(),
                    decoration: const InputDecoration(labelText: 'Station'),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value;
                      });
                    },
                    items: statusOptions.map((option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                    decoration: const InputDecoration(labelText: 'Status'),
                  ),
                  TextField(
                    controller: batteryLevelController,
                    decoration: const InputDecoration(labelText: 'Battery Level'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final scooter = Scooter(
                  location: locationController.text,
                  status: selectedStatus ?? '', 
                  batteryLevel: int.tryParse(batteryLevelController.text) ?? 0,
                );
                await _addScooter(scooter, locationController.text); // Await _addScooter method
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
  final List<Scooter> scooters;
  final void Function(Scooter) onDetailButtonPressed;
  final void Function(Scooter) onDeleteButtonPressed;

  DataSource({
    required this.scooters,
    required this.onDetailButtonPressed,
    required this.onDeleteButtonPressed,
  });

  @override
  DataRow? getRow(int index) {
    final scooter = scooters[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(scooter.id)),
        DataCell(Text(scooter.location)),
        DataCell(Text(scooter.status)),
        DataCell(Text(scooter.batteryLevel.toString())),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: kDefaultPadding),
                child: OutlinedButton(
                  onPressed: () => onDetailButtonPressed.call(scooter),
                  child: const Text('Detail'),
                ),
              ),
              OutlinedButton(
                onPressed: () => onDeleteButtonPressed.call(scooter),
                child: const Text('Delete'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => scooters.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
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

class Station {
  final String id;
  final String name;
  final Location location;
  final List<Scooter> scooters;

  Station({ List<Scooter>? scooters, required this.id, required this.name, required this.location})
   : this.scooters = scooters ?? [];
}

class Location {
  final String name;
  final double latitude;
  final double longitude;

  Location({required this.name, required this.latitude, required this.longitude});
}
