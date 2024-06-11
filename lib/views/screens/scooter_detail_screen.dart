import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:web_admin/app_router.dart';
import 'package:web_admin/constants/dimens.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/theme/theme_extensions/app_button_theme.dart';
import 'package:web_admin/views/widgets/card_elements.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';

class ScooterDetailScreen extends StatefulWidget {
  final String id;

  const ScooterDetailScreen({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  State<ScooterDetailScreen> createState() => _ScooterDetailScreenState();
}

class _ScooterDetailScreenState extends State<ScooterDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Scooter _scooter;
  late List<String> _stations = [];

  Future<bool>? _future;

  Future<bool> _getDataAsync() async {
    if (widget.id.isNotEmpty) {
      final DocumentSnapshot scooterSnapshot = await _firestore.collection('scooters').doc(widget.id).get();
      if (scooterSnapshot.exists) {
        final data = scooterSnapshot.data() as Map<String, dynamic>;
        _scooter = Scooter(
          id: scooterSnapshot.id,
          location: data['location'],
          status: data['status'],
          batteryLevel: data['batteryLevel'],
        );
      }
    }

    final QuerySnapshot stationSnapshot = await _firestore.collection('stations').get();
    _stations = stationSnapshot.docs.map((doc) => doc['name'] as String).toList();

    return true;
  }

  Future<void> _doSubmit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final lang = Lang.of(context);

      final dialog = AwesomeDialog(
        context: context,
        dialogType: DialogType.question,
        title: lang.confirmSubmitRecord,
        width: kDialogWidth,
        btnOkText: lang.yes,
        btnOkOnPress: () async {
          await _firestore.collection('scooters').doc(widget.id).update({
            'status': _scooter.status,
            'location': _scooter.location,
            'batteryLevel': _scooter.batteryLevel,
          });

          final d = AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            title: lang.recordSubmittedSuccessfully,
            width: kDialogWidth,
            btnOkText: 'OK',
            btnOkOnPress: () => GoRouter.of(context).go(RouteUri.scooters),
          );

          d.show();
        },
        btnCancelText: lang.cancel,
        btnCancelOnPress: () {},
      );

      dialog.show();
    }
  }

  Future<void> _doDelete(BuildContext context) async {
    final lang = Lang.of(context);

    final dialog = AwesomeDialog(
      context: context,
      dialogType: DialogType.infoReverse,
      title: lang.confirmDeleteRecord,
      width: kDialogWidth,
      btnOkText: lang.yes,
      btnOkOnPress: () async {
        await _firestore.collection('scooters').doc(widget.id).delete();

        final d = AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          title: lang.recordDeletedSuccessfully,
          width: kDialogWidth,
          btnOkText: 'OK',
          btnOkOnPress: () => GoRouter.of(context).go(RouteUri.scooters),
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
    _scooter = Scooter(id: '', location: '', status: '', batteryLevel: 0);
  }

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    final themeData = Theme.of(context);

    final pageTitle = 'Scooter Detail - ${widget.id.isEmpty ? "newScooter" : "editScooter"}';

    return PortalMasterLayout(
      selectedMenuUri: RouteUri.scooters,
      body: ListView(
        padding: const EdgeInsets.all(kDefaultPadding),
        children: [
          Text(
            pageTitle,
            style: themeData.textTheme.headlineMedium,
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
                      initialData: null,
                      future: (_future ??= _getDataAsync()),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          if (snapshot.hasData && snapshot.data!) {
                            return _content(context);
                          }
                        } else if (snapshot.hasData && snapshot.data!) {
                          return _content(context);
                        }

                        return Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
                          child: SizedBox(
                            height: 40.0,
                            width: 40.0,
                            child: CircularProgressIndicator(
                              backgroundColor: themeData.scaffoldBackgroundColor,
                            ),
                          ),
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

  Widget _content(BuildContext context) {
    final lang = Lang.of(context);
    final themeData = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Status",
                hintText: 'Select scooter status',
              ),
              value: _scooter.status.isNotEmpty ? _scooter.status : null,
              items: ['available', 'unavailable', 'disabled'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _scooter.status = value!;
                });
              },
              validator: (value) => value == null || value.isEmpty ? 'Please select a status' : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Location",
                hintText: 'Select scooter location',
              ),
              value: _scooter.location.isNotEmpty ? _scooter.location : null,
              items: _stations.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _scooter.location = value!;
                });
              },
              validator: (value) => value == null || value.isEmpty ? 'Please select a location' : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: "Battery Level",
                hintText: 'Enter battery level',
              ),
              initialValue: _scooter.batteryLevel.toString(),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a battery level';
                }
                              final int? batteryLevel = int.tryParse(value);
                if (batteryLevel == null || batteryLevel < 0 || batteryLevel > 100) {
                  return 'Please enter a valid battery level between 0 and 100';
                }
                return null;
              },
              onSaved: (value) {
                _scooter.batteryLevel = int.parse(value!);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 40.0,
                  child: ElevatedButton(
                    style: themeData.extension<AppButtonTheme>()!.secondaryElevated,
                    onPressed: () => GoRouter.of(context).go(RouteUri.scooters),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                          child: Icon(
                            Icons.arrow_circle_left_outlined,
                            size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                          ),
                        ),
                        const Text("back"),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Visibility(
                  visible: widget.id.isNotEmpty,
                  child: Padding(
                    padding: const EdgeInsets.only(right: kDefaultPadding),
                    child: SizedBox(
                      height: 40.0,
                      child: ElevatedButton(
                        style: themeData.extension<AppButtonTheme>()!.errorElevated,
                        onPressed: () => _doDelete(context),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                              child: Icon(
                                Icons.delete_rounded,
                                size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                              ),
                            ),
                            Text(lang.crudDelete),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 40.0,
                  child: ElevatedButton(
                    style: themeData.extension<AppButtonTheme>()!.successElevated,
                    onPressed: () => _doSubmit(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                          child: Icon(
                            Icons.check_circle_outline_rounded,
                            size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                          ),
                        ),
                        Text(lang.submit),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class Scooter {
  final String id;
   String location;
   String status;
   int batteryLevel;

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

