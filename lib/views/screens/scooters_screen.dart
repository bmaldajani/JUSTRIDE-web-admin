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
import 'package:web_admin/views/screens/scooter_detail_screen.dart';

class ScooterScreen extends StatefulWidget {
  const ScooterScreen({Key? key}) : super(key: key);

  @override
  _ScootersScreenState createState() => _ScootersScreenState();
}

class _ScootersScreenState extends State<ScooterScreen> {
  final _scrollController = ScrollController();
  final _formKey = GlobalKey<FormBuilderState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Scooter> _scooters = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchScooters();
  }

  Future<void> _fetchScooters() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final QuerySnapshot scooterSnapshot = await _firestore.collection('scooters').get();

      final List<Scooter> scooters = scooterSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Scooter(
          id: doc.id,
          location: data['location'],
          status: data['status'],
          batteryLevel: data['batteryLevel'],
        );
      }).toList();

      setState(() {
        _scooters.clear();
        _scooters.addAll(scooters);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load scooters. Please try again later.';
      });
    }
  }

  Future<void> _addScooter(Scooter scooter) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final docRef = await _firestore.collection('scooters').add({
        'location': scooter.location,
        'status': scooter.status,
        'batteryLevel': scooter.batteryLevel,
      });

      final newScooter = Scooter(
        id: docRef.id,
        location: scooter.location,
        status: scooter.status,
        batteryLevel: scooter.batteryLevel,
      );

      setState(() {
        _scooters.add(newScooter);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to add scooter. Please try again later.';
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
            'Scooters',
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
                                          source: ScooterDataSource(
                                            scooters: _scooters,
                                            onDetailButtonPressed: (scooter) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => ScooterDetailScreen(id: scooter.id),
                                                ),
                                              );
                                            },
                                            onDeleteButtonPressed: (scooter) => _deleteScooter(scooter),
                                          ),
                                          rowsPerPage: 20,
                                          showCheckboxColumn: false,
                                          showFirstLastButtons: true,
                                          columns: const [
                                            DataColumn(label: Text('Scooter ID')),
                                            DataColumn(label: Text('Location')),
                                            DataColumn(label: Text('Status')),
                                            DataColumn(label: Text('Battery Level')),
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

  Future<void> _deleteScooter(Scooter scooter) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _firestore.collection('scooters').doc(scooter.id).delete();
      setState(() {
        _scooters.remove(scooter);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to delete scooter. Please try again later.';
      });
    }
  }

  void _showAddScooterDialog(BuildContext context) {
    final TextEditingController locationController = TextEditingController();
    final TextEditingController statusController = TextEditingController();
    final TextEditingController batteryLevelController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Scooter'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: statusController,
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              TextField(
                controller: batteryLevelController,
                decoration: const InputDecoration(labelText: 'Battery Level'),
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
                final scooter = Scooter(
                  location: locationController.text,
                  status: statusController.text,
                  batteryLevel: int.tryParse(batteryLevelController.text) ?? 0,
                );
                _addScooter(scooter);
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

class ScooterDataSource extends DataTableSource {
  final List<Scooter> scooters;
  final void Function(Scooter) onDetailButtonPressed;
  final void Function(Scooter) onDeleteButtonPressed;

  ScooterDataSource({
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
