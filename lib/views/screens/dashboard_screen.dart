import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:web_admin/constants/dimens.dart';
import 'package:web_admin/theme/theme_extensions/app_color_scheme.dart';
import 'package:web_admin/theme/theme_extensions/app_data_table_theme.dart';
import 'package:web_admin/views/widgets/card_elements.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardReportScreen extends StatefulWidget {
  const DashboardReportScreen({Key? key}) : super(key: key);

  @override
  State<DashboardReportScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardReportScreen> {
  final _dataTableHorizontalScrollController = ScrollController();
  final _firestore = FirebaseFirestore.instance;
  final formatter = DateFormat.yMd();

  String selectedCategory = 'All'; // Default category filter

  @override
  void dispose() {
    _dataTableHorizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final appColorScheme = Theme.of(context).extension<AppColorScheme>()!;
    final appDataTableTheme = Theme.of(context).extension<AppDataTableTheme>()!;
    final size = MediaQuery.of(context).size;

    final summaryCardCrossAxisCount = (size.width >= kScreenWidthLg ? 4 : 2);

    return PortalMasterLayout(
      body: ListView(
        padding: const EdgeInsets.all(kDefaultPadding),
        children: [
          Text(
            'Dashboard', // Replace with your actual dashboard title
            style: themeData.textTheme.bodyLarge,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final summaryCardWidth = ((constraints.maxWidth - (kDefaultPadding * (summaryCardCrossAxisCount - 1))) / summaryCardCrossAxisCount);

                return Wrap(
                  direction: Axis.horizontal,
                  spacing: kDefaultPadding,
                  runSpacing: kDefaultPadding,
                  children: [
                    FutureBuilder<int>(
                      future: _fetchReportCount(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return SummaryCard(
                            title: "Number of Reports",
                            value: 'Loading...',
                            icon: Icons.assignment,
                            backgroundColor: appColorScheme.info,
                            textColor: themeData.colorScheme.onPrimary,
                            iconColor: Colors.black12,
                            width: summaryCardWidth * 2,
                          );
                        }
                        final reportCount = snapshot.data ?? 0;
                        return SummaryCard(
                          title: "Number of Reports",
                          value: reportCount.toString(),
                          icon: Icons.assignment,
                          backgroundColor: appColorScheme.info,
                          textColor: themeData.colorScheme.onPrimary,
                          iconColor: Colors.black12,
                          width: summaryCardWidth * 2,
                        );
                      },
                    ),
                    FutureBuilder<int>(
                      future: _fetchUserCount(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return SummaryCard(
                            title: "Number of Users",
                            value: 'Loading...',
                            icon: Icons.people,
                            backgroundColor: appColorScheme.success,
                            textColor: themeData.colorScheme.onPrimary,
                            iconColor: Colors.black12,
                            width: summaryCardWidth * 2,
                          );
                        }
                        final userCount = snapshot.data ?? 0;
                        return SummaryCard(
                          title: "Number of Users",
                          value: userCount.toString(),
                          icon: Icons.people,
                          backgroundColor: appColorScheme.success,
                          textColor: themeData.colorScheme.onPrimary,
                          iconColor: Colors.black12,
                          width: summaryCardWidth * 2,
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(kDefaultPadding),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Recent Reports', // Replace with your header title
                            style: themeData.textTheme.bodyLarge,
                          ),
                        ),
                        DropdownButton<String>(
                          value: selectedCategory,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedCategory = newValue!;
                            });
                          },
                          items: <String>[
                            'All',
                            'BatteryCharging',
                            'Mechanical',
                            'PhysicalDamage',
                            'Safety',
                            'Navigation',
                            'PaymentTransaction',
                            'UnlockingLocking',
                            'AppSoftware',
                            'CustomerService'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double dataTableWidth = max(kScreenWidthMd, constraints.maxWidth);

                        return StreamBuilder<QuerySnapshot>(
                          stream: _firestore.collection('reports').snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final reports = snapshot.data?.docs.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              return {
                                'id': doc.id,
                                'title': data['title'],
                                'problem': data['problem'],
                                'date': data['date'] != null ? DateTime.parse(data['date']) : null,
                                'category': data['category'],
                                'userEmail': data['userEmail'],
                                'response': data['response'],
                              };
                            }).toList();

                            if (reports == null || reports.isEmpty) {
                              return Center(child: Text("No reports available."));
                            }

                            final filteredReports = selectedCategory == 'All'
                                ? reports
                                : reports.where((report) => report['category'] == selectedCategory).toList();

                            return Scrollbar(
                              controller: _dataTableHorizontalScrollController,
                              thumbVisibility: true,
                              trackVisibility: true,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                controller: _dataTableHorizontalScrollController,
                                child: SizedBox(
                                  width: dataTableWidth,
                                  child: Theme(
                                    data: themeData.copyWith(
                                      cardTheme: appDataTableTheme.cardTheme,
                                      dataTableTheme: appDataTableTheme.dataTableThemeData,
                                    ),
                                    child: DataTable(
                                      showCheckboxColumn: false,
                                      columns: const [
                                        DataColumn(
                                          label: Text('Category'),
                                        ),
                                        DataColumn(
                                          label: Text('No.'),
                                          numeric: true,
                                        ),
                                        DataColumn(
                                          label: Text('Date'),
                                        ),
                                        DataColumn(
                                          label: Text('Report'),
                                        ),
                                        DataColumn(
                                          label: Text('Username'),
                                        ),
                                        DataColumn(
                                          label: Text('Actions'),
                                        ),
                                      ],
                                      rows: List.generate(filteredReports.length, (index) {
                                        final report = filteredReports[index];
                                        return DataRow(
                                          cells: [
                                            DataCell(
                                              Icon(_getCategoryIcon(report['category'])),
                                            ),
                                            DataCell(
                                              Text('#${index + 1}'),
                                            ),
                                            DataCell(
                                              Text(report['date'] != null ? formatter.format(report['date']) : ''),
                                            ),
                                            DataCell(
                                              Text(report['title'] ?? ''),
                                            ),
                                            DataCell(
                                              Text(report['userEmail'] ?? ''),
                                            ),
                                            DataCell(
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon: Icon(Icons.info),
                                                    onPressed: () => _showReportDetails(context, report),
                                                  ),
                                                  IconButton(
                                                    icon: Icon(Icons.check),
                                                    onPressed: () => _showResponseDialog(context, report),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
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

  Future<int> _fetchReportCount() async {
    final snapshot = await _firestore.collection('reports').get();
    return snapshot.size;
  }

  Future<int> _fetchUserCount() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.size;
  }

  void _showReportDetails(BuildContext context, Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Report Details'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Title: ${report['title']}'),
                Text('Date: ${report['date'] != null ? formatter.format(report['date']) : ''}'),
                Text('Category: ${report['category']}'),
                Text('User Email: ${report['userEmail']}'),
                Text('Problem: ${report['problem']}'),
                Text('Response: ${report['response'] ?? 'No response yet.'}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showResponseDialog(BuildContext context, Map<String, dynamic> report) {
    final TextEditingController _responseController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Respond to Report'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Title: ${report['title']}'),
                Text('Date: ${report['date'] != null ? formatter.format(report['date']) : ''}'),
                Text('Category: ${report['category']}'),
                Text('User Email: ${report['userEmail']}'),
                TextField(
                  controller: _responseController,
                  decoration: InputDecoration(
                    labelText: 'Response',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Submit'),
              onPressed: () {
                _submitResponse(report['id'], _responseController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitResponse(String reportId, String response) async {
    await _firestore.collection('reports').doc(reportId).update({'response': response});
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'BatteryCharging':
        return Icons.battery_charging_full;
      case 'Mechanical':
        return Icons.build;
      case 'PhysicalDamage':
        return Icons.broken_image;
      case 'Safety':
        return Icons.security;
      case 'Navigation':
        return Icons.navigation;
      case 'PaymentTransaction':
        return Icons.payment;
      case 'UnlockingLocking':
        return Icons.lock;
      case 'AppSoftware':
        return Icons.phone_android;
      case 'CustomerService':
        return Icons.headset_mic;
      default:
        return Icons.help; // Default icon for unknown categories
    }
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final double width;

  const SummaryCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 120.0,
      width: width,
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: backgroundColor,
        child: Stack(
          children: [
            Positioned(
              top: kDefaultPadding * 0.5,
              right: kDefaultPadding * 0.5,
              child: Icon(
                icon,
                size: 80.0,
                color: iconColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: kDefaultPadding * 0.5),
                    child: Text(
                      value,
                      style: textTheme.bodyLarge!.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    title,
                    style: textTheme.bodyMedium!.copyWith(
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardHeader extends StatelessWidget {
  final String title;
  final bool showDivider;

  const CardHeader({
    Key? key,
    required this.title,
    this.showDivider = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (showDivider) Divider(),
        ],
      ),
    );
  }
}