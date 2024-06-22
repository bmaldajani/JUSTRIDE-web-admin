import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';
import 'package:web_admin/app_router.dart';
import 'package:web_admin/constants/dimens.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/theme/theme_extensions/app_button_theme.dart';
import 'package:web_admin/theme/theme_extensions/app_data_table_theme.dart';
import 'package:web_admin/views/screens/user_detail_screen.dart';
import 'package:web_admin/views/widgets/card_elements.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final _scrollController = ScrollController();
  final _formKey = GlobalKey<FormBuilderState>();
  late DataSource _dataSource;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dataSource = DataSource(
      userService: FirebaseUserService(),
      onDetailButtonPressed: (user) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserDetailScreen(id: user['id']),
          ),
        );
      },
      onDeleteButtonPressed: (data) => {}, // Implement delete functionality if needed
    );

    _fetchAndSetUsers();
  }

    Future<void> _fetchAndSetUsers() async {
    await _dataSource.userService.fetchUsers();
    _dataSource.resetFilter(); // Ensure _filteredUsers is initialized with all users
    _dataSource.notifyListeners(); // Notify listeners to refresh the DataTable
    setState(() {}); // Update the UI after data is fetched

    // Debugging prints
    print("User count: ${_dataSource.userService.userCount}");
    print("Filtered users count: ${_dataSource.rowCount}");
    print("Filtered users: ${_dataSource._filteredUsers}");
  }


  void _searchById(String userId) {
    if (userId.isNotEmpty) {
      _dataSource.filter(userId);
    } else {
      _dataSource.resetFilter();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose(); // Dispose the TextEditingController
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
            'Users',
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
                    title: 'Users',
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
                                        controller: _searchController,
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
                                              _searchById(_searchController.text.trim());
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
                                        source: _dataSource,
                                        rowsPerPage: 20,
                                        showCheckboxColumn: false,
                                        showFirstLastButtons: true,
                                        columns: const [
                                          DataColumn(label: Text('User ID')),
                                          DataColumn(label: Text('Email')),
                                          DataColumn(label: Text('Phone Number')),
                                          DataColumn(label: Text('Username')),
                                          DataColumn(label: Text('Balance')),
                                          DataColumn(label: Text('Status')),
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
}

class DataSource extends DataTableSource {
  final FirebaseUserService userService;
  final void Function(Map<String, dynamic>) onDetailButtonPressed;
  final void Function(Map<String, dynamic>) onDeleteButtonPressed;

  List<Map<String, dynamic>> _filteredUsers = [];

  DataSource({
    required this.userService,
    required this.onDetailButtonPressed,
    required this.onDeleteButtonPressed,
  }) {
    _filteredUsers.addAll(userService._users); // Initialize with all users
  }

  void filter(String searchTerm) {
    if (searchTerm.isEmpty) {
      _filteredUsers.clear();
      _filteredUsers.addAll(userService._users); // Reset to all users if searchTerm is empty
    } else {
      _filteredUsers.clear();
      _filteredUsers.addAll(userService._users.where((user) =>
          user['id'].toLowerCase().contains(searchTerm.toLowerCase())));
    }
    notifyListeners();
  }

  void resetFilter() {
    _filteredUsers.clear();
    _filteredUsers.addAll(userService._users);
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    if (index >= _filteredUsers.length) {
      return null;
    }
    final user = _filteredUsers[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(user['id'])),
        DataCell(Text(user['email'] ?? '')),
        DataCell(Text(user['phone_number'] ?? '')),
        DataCell(Text(user['username'] ?? '')),
        DataCell(Text(user['balance']?.toString() ?? '')),
        DataCell(Text(user['status'] ?? '')),
        DataCell(
          Row(
            children: [
              OutlinedButton(
                onPressed: () => onDetailButtonPressed(user),
                child: Text('Details'),
              ),
              OutlinedButton(
                onPressed: () => onDeleteButtonPressed(user),
                child: Text('Delete'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _filteredUsers.length;

  @override
  int get selectedRowCount => 0;
}

class FirebaseUserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _users = [];

  Future<void> fetchUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      _users = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add the document ID to the data
                return data;
      }).toList();
      print("Fetched users: $_users");
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  Map<String, dynamic> getUser(int index) {
    return _users[index];
  }

  int get userCount => _users.length;
}
