import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:thingsboard_app/core/context/tb_context.dart';
import 'package:thingsboard_app/core/context/tb_context_widget.dart';
import 'package:thingsboard_app/modules/profile/change_password_page.dart';
import 'package:thingsboard_app/thingsboard_client.dart';
import 'package:thingsboard_app/widgets/tb_app_bar.dart';
import 'package:thingsboard_app/widgets/tb_progress_indicator.dart';

class ProfilePage extends TbPageWidget {
  final bool _fullscreen;

  ProfilePage(TbContext tbContext, {super.key, bool fullscreen = false})
      : _fullscreen = fullscreen,
        super(tbContext);

  @override
  State<StatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends TbPageState<ProfilePage> {
  final _isLoadingNotifier = ValueNotifier<bool>(true);

  final _profileFormKey = GlobalKey<FormBuilderState>();

  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TbAppBar(
        tbContext,
        title: const Text('Update Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              _saveProfile();
            },
          ),
          if (widget._fullscreen)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                tbContext.logout();
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: FormBuilder(
                  key: _profileFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: 'email',
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            errorText: S.of(context).emailRequireText,
                          ),
                          FormBuilderValidators.email(
                            errorText: S.of(context).emailInvalidText,
                          ),
                        ]),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10), // Make it round
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Theme.of(context).primaryColor),
                          ),
                          labelText: S.of(context).emailStar,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                      ),

                      const SizedBox(height: 24),
                      FormBuilderTextField(
                        name: 'firstName',
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10), // Make it round
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Theme.of(context).primaryColor),
                          ),
                          labelText: S.of(context).firstNameUpper,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FormBuilderTextField(
                        name: 'lastName',
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10), // Make it round
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Theme.of(context).primaryColor),
                          ),
                          labelText: S.of(context).lastNameUpper,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          alignment: Alignment.center,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50), // Makes it pill-like
                          ),
                        ),
                        onPressed: () {
                          _changePassword();
                        },
                        child: Text(S.of(context).changePassword),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _isLoadingNotifier,
            builder: (BuildContext context, bool loading, child) {
              if (loading) {
                return SizedBox.expand(
                  child: Container(
                    color: const Color(0x99FFFFFF),
                    child: Center(
                      child: TbProgressIndicator(tbContext, size: 50.0),
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _loadUser() async {
    _isLoadingNotifier.value = true;
    _currentUser = await tbClient.getUserService().getUser();
    _setUser();
    _isLoadingNotifier.value = false;
  }

  _setUser() {
    _profileFormKey.currentState?.patchValue({
      'email': _currentUser!.email,
      'firstName': _currentUser!.firstName ?? '',
      'lastName': _currentUser!.lastName ?? '',
    });
  }

  Future<void> _saveProfile() async {
    if (_currentUser != null) {
      FocusScope.of(context).unfocus();
      if (_profileFormKey.currentState?.saveAndValidate() ?? false) {
        final formValue = _profileFormKey.currentState!.value;
        _currentUser!.email = formValue['email'];
        _currentUser!.firstName = formValue['firstName'];
        _currentUser!.lastName = formValue['lastName'];
        _isLoadingNotifier.value = true;
        try {
          _currentUser =
              await tbClient.getUserService().saveUser(_currentUser!);
          tbContext.userDetails = _currentUser;
          _setUser();
          await Future.delayed(const Duration(milliseconds: 300));
          _isLoadingNotifier.value = false;
          showSuccessNotification(
            S.of(context).profileSuccessNotification,
            duration: const Duration(milliseconds: 1500),
          );
          showSuccessNotification(
            S.of(context).profileSuccessNotification,
            duration: const Duration(milliseconds: 1500),
          );
        } catch (_) {
          _isLoadingNotifier.value = false;
        }
      }
    }
  }

  _changePassword() async {
    var res = await tbContext
        .showFullScreenDialog<bool>(ChangePasswordPage(tbContext));
    if (res == true) {
      showSuccessNotification(
        S.of(context).passwordSuccessNotification,
        duration: const Duration(milliseconds: 1500),
      );
    }
  }
}
