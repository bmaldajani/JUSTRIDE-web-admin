import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:web_admin/constants/dimens.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/theme/theme_extensions/app_data_table_theme.dart';
import 'package:web_admin/views/screens/ride_details_screen.dart';
import 'package:web_admin/views/widgets/card_elements.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';

import '../classes/Ride.dart';

class RideScreen extends StatefulWidget {
  const RideScreen({Key? key}) : super(key: key);

  @override
  _RideScreenState createState() => _RideScreenState();
}

class _RideScreenState extends State<RideScreen> {
  final _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Ride> _rides = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRides();
  }

  Future<void> _fetchRides() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final QuerySnapshot rideSnapshot = await _firestore.collection('rides').get();

      final List<Ride> rides = rideSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Ride(
          id: doc.id,
          scooterId: data['scooterId'],
          userId: data['userId'],
          startStation: data['startStation'],
          endStation: data['endStation'],
          startDate: DateTime.parse(data['startDate']),
          endDate: DateTime.parse(data['endDate']),
          finalCost: data['finalCost'].toDouble(),
          duration: Duration(seconds: data['duration']),
          rating: data['rating'],
        );
      }).toList();

      setState(() {
        _rides.clear();
        _rides.addAll(rides);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load rides. Please try again later.';
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
            'Rides',
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
                      title: 'Rides',
                    ),
                    CardBody(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                          source: RideDataSource(
                                            rides: _rides,
                                            onDetailButtonPressed: (ride) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => RideDetailScreen(id: ride.id),
                                                ),
                                              );
                                            },
                                            onDeleteButtonPressed: (ride) => _deleteRide(ride),
                                          ),
                                          rowsPerPage: 20,
                                          showCheckboxColumn: false,
                                          showFirstLastButtons: true,
                                          columns: const [
                                            DataColumn(label: Text('Ride ID')),
                                            DataColumn(label: Text('User ID')),
                                            DataColumn(label: Text('Start Date')),
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

  Future<void> _deleteRide(Ride ride) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _firestore.collection('rides').doc(ride.id).delete();
      setState(() {
        _rides.remove(ride);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to delete ride. Please try again later.';
      });
    }
  }
}

class RideDataSource extends DataTableSource {
  final List<Ride> rides;
  final void Function(Ride) onDetailButtonPressed;
  final void Function(Ride) onDeleteButtonPressed;

  RideDataSource({
    required this.rides,
    required this.onDetailButtonPressed,
    required this.onDeleteButtonPressed,
  });

  @override
  DataRow? getRow(int index) {
    final ride = rides[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(ride.id)),
        DataCell(Text(ride.userId)),
        DataCell(Text(ride.startDate.toIso8601String())),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: kDefaultPadding),
                child: OutlinedButton(
                  onPressed: () => onDetailButtonPressed.call(ride),
                  child: const Text('Detail'),
                ),
              ),
              OutlinedButton(
                onPressed: () => onDeleteButtonPressed.call(ride),
                child: const Text('Delete'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => rides.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
