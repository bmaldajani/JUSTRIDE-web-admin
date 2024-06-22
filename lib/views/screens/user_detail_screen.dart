import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:web_admin/app_router.dart';
import 'package:web_admin/constants/dimens.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/theme/theme_extensions/app_button_theme.dart';
import 'package:web_admin/utils/app_focus_helper.dart';
import 'package:web_admin/views/classes/Ride.dart';
import 'package:web_admin/views/widgets/card_elements.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';

class UserDetailScreen extends StatefulWidget {
  final String id;

  const UserDetailScreen({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  late User _user;
  late Future<bool> _future;

  Future<bool> _getDataAsync() async {
    if (widget.id.isNotEmpty) {
      try {
        DocumentSnapshot<Map<String, dynamic>> userDoc =
            await FirebaseFirestore.instance.collection('users').doc(widget.id).get();
        Map<String, dynamic>? userData = userDoc.data();

        if (userData != null) {
          List<Ride> rides = [];

          // Fetch rides associated with the user
          QuerySnapshot rideSnapshot = await FirebaseFirestore.instance
              .collection('rides')
              .where('userId', isEqualTo: widget.id)
              .get();

          rideSnapshot.docs.forEach((rideDoc) {
            rides.add(Ride.fromJson(rideDoc.data() as Map<String, dynamic>));
          });

          setState(() {
            _user = User(
              id: widget.id,
              name: userData['username'] ?? '',
              email: userData['email'] ?? '',
              phone: userData['phone_number'] ?? '',
              balance: userData['balance']?.toString() ?? '',
              status: userData['status'] ?? '',
              rides: rides,
            );
          });

          return true;
        }
      } catch (e) {
        print('Error fetching user data: $e');
        return false;
      }
    }
    return false;
  }

  void _doDisableUser(BuildContext context) async {
    AppFocusHelper.instance.requestUnfocus();

    final lang = Lang.of(context);

    if (_user.status == 'active') {
      final dialog = AwesomeDialog(
        context: context,
        dialogType: DialogType.question,
        title: "confirmDisableUser",
        width: kDialogWidth,
        btnOkText: lang.yes,
        btnOkOnPress: () async {
          await FirebaseFirestore.instance.collection('users').doc(_user.id).update({
            'status': 'disabled',
          });

          setState(() {
            _user.status = 'disabled';
          });

          Navigator.pop(context); // Close the dialog after updating
        },
        btnCancelText: lang.cancel,
        btnCancelOnPress: () {},
      );

      dialog.show();
    }
  }

  void _doEnableUser(BuildContext context) async {
    AppFocusHelper.instance.requestUnfocus();

    final lang = Lang.of(context);

    if (_user.status == 'disabled') {
      final dialog = AwesomeDialog(
        context: context,
        dialogType: DialogType.question,
        title: "confirmEnableUser",
        width: kDialogWidth,
        btnOkText: lang.yes,
        btnOkOnPress: () async {
          await FirebaseFirestore.instance.collection('users').doc(_user.id).update({
            'status': 'active',
          });

          setState(() {
            _user.status = 'active';
          });

          Navigator.pop(context); // Close the dialog after updating
        },
        btnCancelText: lang.cancel,
        btnCancelOnPress: () {},
      );

      dialog.show();
    }
  }

  void _doSubmit(BuildContext context) async {
    AppFocusHelper.instance.requestUnfocus();

    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();

      final lang = Lang.of(context);

      final dialog = AwesomeDialog(
        context: context,
        dialogType: DialogType.question,
        title: lang.confirmSubmitRecord,
        width: kDialogWidth,
        btnOkText: lang.yes,
        btnOkOnPress: () async {
          await FirebaseFirestore.instance.collection('users').doc(_user.id).update({
            'balance': double.parse(_user.balance),
          });

          final d = AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            title: lang.recordSubmittedSuccessfully,
            width: kDialogWidth,
            btnOkText: 'OK',
            btnOkOnPress: () => GoRouter.of(context).go(RouteUri.users),
          );

          d.show();
        },
        btnCancelText: lang.cancel,
        btnCancelOnPress: () {},
      );

      dialog.show();
    }
  }

  void _doDelete(BuildContext context) {
    AppFocusHelper.instance.requestUnfocus();

    final lang = Lang.of(context);

    final dialog = AwesomeDialog(
      context: context,
      dialogType: DialogType.infoReverse,
      title: lang.confirmDeleteRecord,
      width: kDialogWidth,
      btnOkText: lang.yes,
      btnOkOnPress: () async {
        await FirebaseFirestore.instance.collection('users').doc(_user.id).delete();

        final d = AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          title: lang.recordDeletedSuccessfully,
          width: kDialogWidth,
          btnOkText: 'OK',
          btnOkOnPress: () => GoRouter.of(context).go(RouteUri.users),
        );

        d.show();
      },
      btnCancelText: lang.cancel,
      btnCancelOnPress: () {},
    );

    dialog.show();
  }

  @override
  void initState() {
    super.initState();
    _user = User(id: '');
    _future = _getDataAsync();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    final themeData = Theme.of(context);

    final pageTitle = 'User Detail - ${widget.id.isEmpty ? lang.newUser : lang.editUser}';

    return PortalMasterLayout(
      selectedMenuUri: RouteUri.users,
      body: ListView(
        padding: const EdgeInsets.all(kDefaultPadding),
        children: [
          Text(
            pageTitle,
            style: themeData.textTheme.bodyLarge,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CardHeader(
                    title: pageTitle,
                  ),
                  CardBody(
                    child: FutureBuilder<bool>(
                      future: _future,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
                            child: CircularProgressIndicator(
                              backgroundColor: themeData.scaffoldBackgroundColor,
                            ),
                          );
                        } else if (snapshot.hasData && snapshot.data!) {
                          return _buildUserDetails(context);
                        } else {
                          return Center(child: Text('Failed to load user data.'));
                        }
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

  Widget _buildUserDetails(BuildContext context) {
    final themeData = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text('Name'),
          subtitle: Text(_user.name),
          dense: true,
        ),
        ListTile(
          title: Text('Email'),
          subtitle: Text(_user.email),
          dense: true,
        ),
        ListTile(
          title: Text('Phone'),
          subtitle: Text(_user.phone),
          dense: true,
        ),
        ListTile(
          title: Text('Balance'),
          subtitle: Text(_user.balance),
          dense: true,
        ),
        if (_user.rides.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '   Rides',
                  style: themeData.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: kDefaultPadding / 2),
                _buildRidesTable(),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
          child: Row(
            children: [
              Visibility(
                visible: _user.status == 'active',
                child: ElevatedButton(
                  onPressed: () => _doDisableUser(context),
                  style: themeData.extension<AppButtonTheme>()!.errorElevated,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.block_rounded),
                      SizedBox(width: 8),
                      Text('Disable User'),
                    ],
                  ),
                ),
              ),
              SizedBox(width: kDefaultPadding),
              Visibility(
                visible: _user.status == 'disabled',
                child: ElevatedButton(
                  onPressed: () => _doEnableUser(context),
                  style: themeData.extension<AppButtonTheme>()!.successElevated,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline_rounded),
                      SizedBox(width: 8.0),
                    ],
                  ),
                ),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () => _showModifyBalanceDialog(context),
                style: themeData.extension<AppButtonTheme>()!.successElevated,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.attach_money_rounded),
                    SizedBox(width: 8),
                    Text('Modify Balance'),
                  ],
                ),
              ),
              SizedBox(width: kDefaultPadding),
              ElevatedButton(
                onPressed: () => _doDelete(context),
                style: themeData.extension<AppButtonTheme>()!.errorElevated,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_outline_rounded),
                    SizedBox(width: 8),
                    Text('Delete User'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRidesTable() {
    return SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: DataTable(
    columns: [
      DataColumn(label: Text('Start Station')),
      DataColumn(label: Text('End Station')),
      DataColumn(label: Text('Start Date')),
      DataColumn(label: Text('End Date')),
      DataColumn(label: Text('Final Cost')),
      DataColumn(label: Text('Duration')),
      DataColumn(label: Text('Rating')),
    ],
    rows: _user.rides.map((ride) {
      return DataRow(
        cells: [
          DataCell(Text(ride.startStation)),
          DataCell(Text(ride.endStation)),
          DataCell(Text(ride.startDate.toString())),
          DataCell(Text(ride.endDate.toString())),
          DataCell(Text(ride.finalCost.toString())),
          DataCell(Text(ride.duration.toString())),
          DataCell(Text(ride.rating.toString())),
        ],
      );
    }).toList(),
  ),
);
  }

  void _showModifyBalanceDialog(BuildContext context) {
    final lang = Lang.of(context);
    final TextEditingController newBalanceController = TextEditingController();

    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      title: "Modify Balance",
      width: kDialogWidth,
      body: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: FormBuilder(
          key: _formKey,
          initialValue: {
            'new_balance': _user.balance,
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormBuilderTextField(
                name: 'new_balance',
                controller: newBalanceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: FormBuilderValidators.required(),
                decoration: InputDecoration(
                  labelText: 'New Balance',
                ),
              ),
            ],
          ),
        ),
      ),
      btnOkText: lang.yes,
      btnOkOnPress: () async {
        if (_formKey.currentState?.saveAndValidate() ?? false) {
          final newBalance = double.parse(newBalanceController.text);

          await FirebaseFirestore.instance.collection('users').doc(_user.id).update({
            'balance': newBalance,
          });

          setState(() {
            _user.balance = newBalance.toString();
          });

          Navigator.pop(context); // Close the dialog after updating
        }
      },
      btnCancelText: lang.cancel,
      btnCancelOnPress: () {},
    ).show();
  }
}

class User {
  String id;
  String name;
  String email;
  String phone;
  String balance;
  String status;
  List<Ride> rides;

  User({
    required this.id,
    this.name = '',
    this.email = '',
    this.phone = '',
    this.balance = '',
    this.status = '',
    List<Ride>? rides,
  }) : rides = rides ?? [];
}

void main() {
  runApp(MaterialApp(
    title: 'User Detail Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: UserDetailScreen(id: 'user_id_here'),
  ));
}
