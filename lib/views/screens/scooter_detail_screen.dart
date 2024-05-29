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

import '../classes/scooter.dart';

class ScooterDetailScreen extends StatefulWidget {
  final String id;

  const ScooterDetailScreen({
    super.key,
    required this.id,
  });

  @override
  State<ScooterDetailScreen> createState() => _ScooterDetailScreenState();
}

class _ScooterDetailScreenState extends State<ScooterDetailScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  late Scooter _scooter;

  Future<bool>? _future;

  Future<bool> _getDataAsync() async {
    if (widget.id.isNotEmpty) {
      await Future.delayed(const Duration(seconds: 1), () {
        _scooter = Scooter(
          id: widget.id,
          status: 'available',
          location: 'M4',
        );
      });
    }

    return true;
  }

  void _doSubmit(BuildContext context) {
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
        btnOkOnPress: () {
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

  void _doDelete(BuildContext context) {
    AppFocusHelper.instance.requestUnfocus();

    final lang = Lang.of(context);

    final dialog = AwesomeDialog(
      context: context,
      dialogType: DialogType.infoReverse,
      title: lang.confirmDeleteRecord,
      width: kDialogWidth,
      btnOkText: lang.yes,
      btnOkOnPress: () {
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
    _scooter = Scooter(id: '');
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
            child: TextFormField(
              decoration: InputDecoration(
                labelText: "Scooter name",
                hintText: 'Enter scooter\'s name',
              ),
              controller: _scooterNameController,
              validator: FormBuilderValidators.required(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Status",
                hintText: 'Select scooter status',
              ),
              value: _scooter.status,
              items: ['available', 'booked', 'unavailable'].map((String value) {
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
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Location",
                hintText: 'Select scooter location',
              ),
              value: _scooter.location,
              items: ['M4', 'PH2', 'A2'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {_scooter.location = value!;
                });
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
                        Text("Back"),
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


final _scooterNameController = TextEditingController();