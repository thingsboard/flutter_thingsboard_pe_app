import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:thingsboard_app/core/context/tb_context.dart';
import 'package:thingsboard_app/core/context/tb_context_widget.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';
import 'package:thingsboard_app/widgets/tb_app_bar.dart';
import 'package:thingsboard_app/widgets/tb_progress_indicator.dart';

class ChangePasswordPage extends TbContextWidget {
  ChangePasswordPage(TbContext tbContext, {super.key}) : super(tbContext);

  @override
  State<StatefulWidget> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends TbContextState<ChangePasswordPage> {
  final _isLoadingNotifier = ValueNotifier<bool>(false);

  final _showCurrentPasswordNotifier = ValueNotifier<bool>(false);
  final _showNewPasswordNotifier = ValueNotifier<bool>(false);
  final _showNewPassword2Notifier = ValueNotifier<bool>(false);

  final _changePasswordFormKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TbAppBar(
        tbContext,
        title: Text(S.of(context).changePassword),
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: FormBuilder(
                  key: _changePasswordFormKey,
                  autovalidateMode: AutovalidateMode.disabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      ValueListenableBuilder(
                        valueListenable: _showCurrentPasswordNotifier,
                        builder: (
                          BuildContext context,
                          bool showPassword,
                          child,
                        ) {
                          return FormBuilderTextField(
                            name: 'currentPassword',
                            obscureText: !showPassword,
                            autofocus: true,
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(
                                errorText:
                                    S.of(context).currentPasswordRequireText,
                              ),
                            ]),
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  showPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  _showCurrentPasswordNotifier.value =
                                      !_showCurrentPasswordNotifier.value;
                                },
                              ),
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
                              labelText: S.of(context).currentPasswordStar,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      ValueListenableBuilder(
                        valueListenable: _showNewPasswordNotifier,
                        builder: (
                          BuildContext context,
                          bool showPassword,
                          child,
                        ) {
                          return FormBuilderTextField(
                            name: 'newPassword',
                            obscureText: !showPassword,
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(
                                errorText: S.of(context).newPasswordRequireText,
                              ),
                            ]),
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  showPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  _showNewPasswordNotifier.value =
                                      !_showNewPasswordNotifier.value;
                                },
                              ),
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
                              labelText: S.of(context).newPasswordStar,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      ValueListenableBuilder(
                        valueListenable: _showNewPassword2Notifier,
                        builder: (
                          BuildContext context,
                          bool showPassword,
                          child,
                        ) {
                          return FormBuilderTextField(
                            name: 'newPassword2',
                            obscureText: !showPassword,
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(
                                errorText:
                                    S.of(context).newPassword2RequireText,
                              ),
                            ]),
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  showPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  _showNewPassword2Notifier.value =
                                      !_showNewPassword2Notifier.value;
                                },
                              ),
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
                              labelText: S.of(context).newPassword2Star,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            ),
                          );
                        },
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

  Future<void> _changePassword() async {
    FocusScope.of(context).unfocus();
    if (_changePasswordFormKey.currentState?.saveAndValidate() ?? false) {
      var formValue = _changePasswordFormKey.currentState!.value;
      String currentPassword = formValue['currentPassword'];
      String newPassword = formValue['newPassword'];
      String newPassword2 = formValue['newPassword2'];
      if (newPassword != newPassword2) {
        showErrorNotification(S.of(context).passwordErrorNotification);
      } else {
        _isLoadingNotifier.value = true;
        try {
          await Future.delayed(const Duration(milliseconds: 300));
          await tbClient.changePassword(currentPassword, newPassword);
          pop(true);
        } catch (e) {
          _isLoadingNotifier.value = false;
        }
      }
    }
  }
}
