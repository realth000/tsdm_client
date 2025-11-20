import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter, TextInputFormatter;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/features/profile/bloc/edit_user_profile_bloc.dart';
import 'package:tsdm_client/features/profile/models/birthday_info.dart';
import 'package:tsdm_client/features/profile/models/editable_user_profile.dart' as eup;
import 'package:tsdm_client/features/profile/repository/edit_user_profile_repository.dart';
import 'package:tsdm_client/features/profile/widgets/select_birthday_dialog.dart';
import 'package:tsdm_client/features/root/view/root_page.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/utils/retry_button.dart';
import 'package:tsdm_client/utils/show_toast.dart';
import 'package:tsdm_client/widgets/custom_alert_dialog.dart';
import 'package:tsdm_client/widgets/indicator.dart';
import 'package:tsdm_client/widgets/selectable_list_tile.dart';
import 'package:tsdm_client/widgets/single_line_text.dart';

const _profileFieldTextMaxLines = 15;
const _profileFieldTextMinLines = 3;

/// Page allow showing and editing current user's profile.
class EditUserProfilePage extends StatefulWidget {
  /// Constructor.
  const EditUserProfilePage({super.key});

  @override
  State<EditUserProfilePage> createState() => _EditUserProfilePageState();
}

class _EditUserProfilePageState extends State<EditUserProfilePage> {
  final formKey = GlobalKey<FormState>();

  /// Callback called when a profile list tile with limited selectable choices is pressed.
  ///
  /// 1. Show a dialog for user to update profile value.
  /// 2. Save new value, if any.
  Future<void> _spawnSelectionDialog<Value>({
    required BuildContext context,
    required eup.UserProfile profile,
    required String title,
    required List<(Value, String)> valueNamePairs,
    required eup.UserProfile Function(eup.UserProfile, Value) onValueUpdated,
    Value? currentValue,
  }) async {
    final newValue = await _showSelectionDialog<Value>(
      context: context,
      title: title,
      currentValue: currentValue,
      valueNamePairs: valueNamePairs,
    );

    if (newValue == null || !context.mounted) {
      return;
    }
    context.read<EditUserProfileBloc>().add(
      EditUserProfileSaveProfileRequested(onValueUpdated(profile, newValue)),
    );
  }

  Future<void> _spawnTextFieldDialog({
    required BuildContext context,
    required eup.UserProfile profile,
    required String title,
    required String currentValue,
    required eup.UserProfile Function(eup.UserProfile, String) onValueUpdated,
    FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    InputDecoration? inputDecoration,
    int? maxLines = 1,
    int? minLines,
  }) async {
    final newValue = await _showTextFieldDialog(
      context: context,
      title: title,
      profile: profile,
      initialText: currentValue,
      onValueUpdated: onValueUpdated,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      inputDecoration: inputDecoration,
      maxLines: maxLines,
      minLines: minLines,
    );

    if (newValue == null || !context.mounted) {
      return;
    }
    context.read<EditUserProfileBloc>().add(
      EditUserProfileSaveProfileRequested(onValueUpdated(profile, newValue)),
    );
  }

  Widget _buildBody(BuildContext context, eup.UserProfile profile) {
    final tr = context.t.editUserProfilePage;

    return Form(
      key: formKey,
      child: ListView(
        padding: context.safePadding(),
        children: [
          _buildProfileListTile(
            context: context,
            title: tr.username,
            value: tr.username,
            subtitle: profile.usernameReadonly,
          ),
          _buildProfileListTile(
            context: context,
            title: tr.gender.title,
            subtitle: switch (profile.gender) {
              eup.Gender.private => tr.gender.hide,
              eup.Gender.male => tr.gender.male,
              eup.Gender.female => tr.gender.female,
            },
            value: profile.gender,
            visibility: profile.genderVisibility,
            onVisibilityChanged: (visibility) => context.read<EditUserProfileBloc>().add(
              EditUserProfileSaveProfileRequested(profile.copyWith(genderVisibility: visibility)),
            ),
            onTap: (gender) async => _spawnSelectionDialog<eup.Gender>(
              context: context,
              profile: profile,
              title: tr.gender.title,
              currentValue: profile.gender,
              valueNamePairs: [
                (eup.Gender.private, tr.gender.hide),
                (eup.Gender.male, tr.gender.male),
                (eup.Gender.female, tr.gender.female),
              ],
              onValueUpdated: (p, v) => p.copyWith(gender: v),
            ),
          ),
          _buildProfileListTile(
            context: context,
            title: tr.birthday.title,
            subtitle:
                '${profile.birthdayYear ?? "-"} ${tr.birthday.year} '
                '${profile.birthdayMonth ?? "-"} ${tr.birthday.month} '
                '${profile.birthdayDay ?? "-"} ${tr.birthday.day}',
            value: _BirthdayInfo(
              year: profile.birthdayYear,
              month: profile.birthdayMonth,
              day: profile.birthdayDay,
              availableYears: profile.birthdayAvailableYears,
            ),
            visibility: profile.birthdayVisibility,
            onVisibilityChanged: (visibility) => context.read<EditUserProfileBloc>().add(
              EditUserProfileSaveProfileRequested(profile.copyWith(birthdayVisibility: visibility)),
            ),
            onTap: (_) async {
              final birthday = await showSelectBirthdayDialog(
                context,
                BirthdayInfo(
                  year: profile.birthdayYear,
                  month: profile.birthdayMonth,
                  day: profile.birthdayDay,
                ),
                profile.birthdayAvailableYears,
              );
              if (birthday == null || !context.mounted) {
                return;
              }
              context.read<EditUserProfileBloc>().add(
                EditUserProfileSaveProfileRequested(
                  profile.copyWith(
                    birthdayYear: birthday.year,
                    birthdayMonth: birthday.month,
                    birthdayDay: birthday.day,
                  ),
                ),
              );
            },
          ),
          _buildProfileListTile(
            context: context,
            title: tr.qq.title,
            subtitle: '${profile.qq ?? ""}',
            value: profile.qq,
            visibility: profile.qqVisibility,
            onVisibilityChanged: (visibility) => context.read<EditUserProfileBloc>().add(
              EditUserProfileSaveProfileRequested(profile.copyWith(qqVisibility: visibility)),
            ),
            onTap: (v) async => _spawnTextFieldDialog(
              context: context,
              profile: profile,
              title: tr.qq.title,
              currentValue: v == null ? '' : v.toString(),
              onValueUpdated: (p, v) => p.copyWith(qq: v.parseToInt()),
              validator: (v) {
                if (v == null) {
                  return tr.qq.invalidQQ;
                }

                if (v.isEmpty) {
                  return null;
                }

                if (v.startsWith('0') || !RegExp('[0-9]{6,}').hasMatch(v)) {
                  return tr.qq.invalidQQ;
                }

                final vv = v.parseToInt();
                if (vv == null || vv < 0) {
                  return tr.qq.invalidQQ;
                }

                return null;
              },
              keyboardType: .number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9]+'))],
            ),
          ),
          _buildProfileListTile(
            context: context,
            title: tr.msn,
            subtitle: profile.msn ?? '',
            value: profile.msn,
            visibility: profile.msnVisibility,
            onVisibilityChanged: (visibility) => context.read<EditUserProfileBloc>().add(
              EditUserProfileSaveProfileRequested(profile.copyWith(msnVisibility: visibility)),
            ),
            onTap: (v) async => _spawnTextFieldDialog(
              context: context,
              profile: profile,
              title: tr.msn,
              currentValue: v ?? '',
              onValueUpdated: (p, v) => p.copyWith(msn: v),
            ),
          ),
          _buildProfileListTile(
            context: context,
            title: tr.homepage,
            subtitle: profile.homepage ?? '',
            value: profile.homepage,
            visibility: profile.homepageVisibility,
            onVisibilityChanged: (visibility) => context.read<EditUserProfileBloc>().add(
              EditUserProfileSaveProfileRequested(profile.copyWith(homepageVisibility: visibility)),
            ),
            onTap: (v) async => _spawnTextFieldDialog(
              context: context,
              profile: profile,
              title: tr.homepage,
              currentValue: v ?? '',
              onValueUpdated: (p, v) => p.copyWith(homepage: v),
            ),
          ),
          _buildProfileListTile(
            context: context,
            title: tr.bio,
            subtitle: profile.bio,
            value: profile.bio,
            visibility: profile.bioVisibility,
            onVisibilityChanged: (visibility) => context.read<EditUserProfileBloc>().add(
              EditUserProfileSaveProfileRequested(profile.copyWith(bioVisibility: visibility)),
            ),
            onTap: (v) async => _spawnTextFieldDialog(
              context: context,
              profile: profile,
              title: tr.bio,
              currentValue: v,
              onValueUpdated: (p, v) => p.copyWith(bio: v),
              maxLines: _profileFieldTextMaxLines,
              minLines: _profileFieldTextMinLines,
            ),
          ),
          _buildProfileListTile(
            context: context,
            title: tr.hobby,
            subtitle: profile.hobby ?? '',
            value: profile.hobby,
            visibility: profile.hobbyVisibility,
            onVisibilityChanged: (visibility) => context.read<EditUserProfileBloc>().add(
              EditUserProfileSaveProfileRequested(profile.copyWith(hobbyVisibility: visibility)),
            ),
            onTap: (v) async => _spawnTextFieldDialog(
              context: context,
              profile: profile,
              title: tr.hobby,
              currentValue: v ?? '',
              onValueUpdated: (p, v) => p.copyWith(hobby: v),
              maxLines: _profileFieldTextMaxLines,
              minLines: _profileFieldTextMinLines,
            ),
          ),
          _buildProfileListTile(
            context: context,
            title: tr.location,
            subtitle: profile.location ?? '',
            value: profile.location,
            visibility: profile.locationVisibility,
            onVisibilityChanged: (visibility) => context.read<EditUserProfileBloc>().add(
              EditUserProfileSaveProfileRequested(profile.copyWith(locationVisibility: visibility)),
            ),
            onTap: (v) async => _spawnTextFieldDialog(
              context: context,
              profile: profile,
              title: tr.location,
              currentValue: v ?? '',
              onValueUpdated: (p, v) => p.copyWith(location: v),
            ),
          ),
          _buildProfileListTile(
            context: context,
            title: tr.nickname,
            subtitle: profile.nickname ?? '',
            value: profile.nickname,
            visibility: profile.nicknameVisibility,
            onVisibilityChanged: (visibility) => context.read<EditUserProfileBloc>().add(
              EditUserProfileSaveProfileRequested(profile.copyWith(nicknameVisibility: visibility)),
            ),
            onTap: (v) async => _spawnTextFieldDialog(
              context: context,
              profile: profile,
              title: tr.nickname,
              currentValue: v ?? '',
              onValueUpdated: (p, v) => p.copyWith(nickname: v),
            ),
          ),
          _buildProfileListTile(
            context: context,
            title: tr.wordsToSay,
            subtitle: profile.wordsToSay ?? '',
            value: profile.wordsToSay,
            visibility: profile.wordsToSayVisibility,
            onVisibilityChanged: (visibility) => context.read<EditUserProfileBloc>().add(
              EditUserProfileSaveProfileRequested(profile.copyWith(wordsToSayVisibility: visibility)),
            ),
            onTap: (v) async => _spawnTextFieldDialog(
              context: context,
              profile: profile,
              title: tr.wordsToSay,
              currentValue: v ?? '',
              onValueUpdated: (p, v) => p.copyWith(wordsToSay: v),
            ),
          ),
          _buildProfileListTile(
            context: context,
            title: tr.skills,
            subtitle: profile.skill ?? '',
            value: profile.skill,
            visibility: profile.skillVisibility,
            onVisibilityChanged: (visibility) => context.read<EditUserProfileBloc>().add(
              EditUserProfileSaveProfileRequested(profile.copyWith(skillVisibility: visibility)),
            ),
            onTap: (v) async => _spawnTextFieldDialog(
              context: context,
              profile: profile,
              title: tr.skills,
              currentValue: v ?? '',
              onValueUpdated: (p, v) => p.copyWith(skill: v),
            ),
          ),
          _buildProfileListTile(
            context: context,
            title: tr.favoriteBangumi,
            subtitle: profile.favoriteBangumi ?? '',
            value: profile.favoriteBangumi,
            visibility: profile.favoriteBangumiVisibility,
            onVisibilityChanged: (visibility) => context.read<EditUserProfileBloc>().add(
              EditUserProfileSaveProfileRequested(profile.copyWith(favoriteBangumiVisibility: visibility)),
            ),
            onTap: (v) async => _spawnTextFieldDialog(
              context: context,
              profile: profile,
              title: tr.favoriteBangumi,
              currentValue: v ?? '',
              onValueUpdated: (p, v) => p.copyWith(favoriteBangumi: v),
            ),
          ),
          _buildProfileListTile(
            context: context,
            title: tr.pageStyle.title,
            value: _PageStyleInfo(profile.pageStyle, profile.availablePageStyles),
            subtitle: profile.pageStyle?.name ?? '-',
            onTap: (gender) async => _spawnSelectionDialog<int>(
              context: context,
              profile: profile,
              title: tr.gender.title,
              currentValue: profile.pageStyle?.value ?? 0,
              valueNamePairs: profile.availablePageStyles.map((v) => (v.value, v.name)).toList(),
              onValueUpdated: (p, v) => p.copyWith(
                pageStyle: profile.availablePageStyles.firstWhereOrNull((e) => e.value == v),
              ),
            ),
            onVisibilityChanged: (visibility) => context.read<EditUserProfileBloc>().add(
              EditUserProfileSaveProfileRequested(profile.copyWith(genderVisibility: visibility)),
            ),
          ),
          _buildProfileListTile(
            context: context,
            title: tr.customTitle,
            value: profile.customTitle,
            subtitle: profile.customTitle ?? '',
            onTap: (v) async => _spawnTextFieldDialog(
              context: context,
              profile: profile,
              title: tr.customTitle,
              currentValue: v ?? '',
              onValueUpdated: (p, v) => p.copyWith(customTitle: v),
            ),
          ),
          _buildProfileListTile(
            context: context,
            title: tr.signature,
            value: profile.signature,
            subtitle: profile.signature ?? '',
            onTap: (v) async => _spawnTextFieldDialog(
              context: context,
              profile: profile,
              title: tr.signature,
              currentValue: v ?? '',
              onValueUpdated: (p, v) => p.copyWith(signature: v),
              maxLines: _profileFieldTextMaxLines,
              minLines: _profileFieldTextMinLines,
            ),
          ),
          _buildProfileListTile(
            context: context,
            title: tr.timezone,
            value: _TimeZoneInfo(profile.timeZone, profile.availableTimeZones),
            subtitle: profile.timeZone?.name ?? '-',
            onTap: (gender) async => _spawnSelectionDialog<String>(
              context: context,
              profile: profile,
              title: tr.timezone,
              currentValue: profile.timeZone?.value,
              valueNamePairs: profile.availableTimeZones.map((v) => (v.value, v.name)).toList(),
              onValueUpdated: (p, v) => p.copyWith(
                timeZone: profile.availableTimeZones.firstWhereOrNull((e) => e.value == v),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (_) => EditUserProfileRepository(),
        ),
        BlocProvider(
          create: (context) => EditUserProfileBloc(context.repo())..add(const EditUserProfileLoadProfileRequested()),
        ),
      ],
      child: BlocConsumer<EditUserProfileBloc, EditUserProfileState>(
        listenWhen: (prev, curr) => prev.status == .submitting && curr.status != .submitting,
        listener: (context, state) {
          if (state.status == .success) {
            showSnackBar(context: context, message: context.t.editUserProfilePage.saveSuccess);
          } else if (state.status == .failure) {
            showSnackBar(context: context, message: context.t.editUserProfilePage.saveFailed);
          }
        },
        builder: (context, state) {
          final body = switch (state.status) {
            EditUserProfileStatus.initial || EditUserProfileStatus.loading => const CenteredCircularIndicator(),
            EditUserProfileStatus.failure when state.profile == null => buildRetryButton(
              context,
              () => context.read<EditUserProfileBloc>().add(const EditUserProfileLoadProfileRequested()),
            ),
            _ => _buildBody(context, state.profile!),
          };

          return Scaffold(
            appBar: AppBar(
              title: Text(context.t.editUserProfilePage.title),
              actions: [
                IconButton(
                  icon: <EditUserProfileStatus>[.initial, .loading, .submitting].contains(state.status)
                      ? sizedCircularProgressIndicator
                      : const Icon(Icons.cloud_upload_outlined),
                  onPressed: state.status != .submitting && state.status != .loading
                      ? () => context.read<EditUserProfileBloc>().add(
                          EditUserProfileUploadProfileRequested(state.profile!),
                        )
                      : null,
                  tooltip: context.t.editUserProfilePage.save,
                ),
              ],
            ),
            body: body,
          );
        },
      ),
    );
  }
}

Widget _buildProfileListTile<T>({
  required BuildContext context,
  required String title,
  required String subtitle,
  required T value,
  eup.Visibility? visibility,
  FutureOr<void> Function(eup.Visibility)? onVisibilityChanged,
  FutureOr<void> Function(T)? onTap,
}) => ListTile(
  title: Text(title),
  subtitle: SingleLineText(subtitle),
  titleTextStyle: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.secondary),
  subtitleTextStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface),
  onTap: onTap == null || context.read<EditUserProfileBloc>().state.status == .submitting
      ? null
      : () async => onTap.call(value),
  contentPadding: edgeInsetsL16R16,
  trailing: visibility == null
      ? null
      : Row(
          mainAxisSize: .min,
          children: [
            const Column(
              mainAxisSize: .min,
              children: [
                sizedBoxW8H8,
                Expanded(child: VerticalDivider()),
                sizedBoxW8H8,
              ],
            ),
            sizedBoxW4H4,
            IconButton(
              icon: Icon(switch (visibility) {
                eup.Visibility.public => Symbols.visibility,
                eup.Visibility.friendsOnly => Symbols.visibility_lock,
                eup.Visibility.private => Symbols.visibility_off,
              }),
              onPressed: context.read<EditUserProfileBloc>().state.status == .submitting
                  ? null
                  : () async {
                      final tr = context.t.editUserProfilePage.visibility;
                      final v = await _showSelectionDialog(
                        context: context,
                        title: '${tr.title} - $title',
                        currentValue: visibility,
                        valueNamePairs: [
                          (eup.Visibility.public, tr.public),
                          (eup.Visibility.friendsOnly, tr.friendsOnly),
                          (eup.Visibility.private, tr.private),
                        ],
                      );
                      if (v == null || !context.mounted) {
                        return;
                      }
                      await onVisibilityChanged?.call(v);
                    },
              tooltip: switch (visibility) {
                eup.Visibility.public => context.t.editUserProfilePage.visibility.public,
                eup.Visibility.friendsOnly => context.t.editUserProfilePage.visibility.friendsOnly,
                eup.Visibility.private => context.t.editUserProfilePage.visibility.private,
              },
            ),
          ],
        ),
);

/// Show a dialog provides a list of choices.
///
/// Each choice is a value of type [Value], corresponding human readable description saved in tuple list
/// [valueNamePairs].
///
/// [title] is the title of dialog.
///
/// [currentValue] is the current selected value.
Future<Value?> _showSelectionDialog<Value>({
  required BuildContext context,
  required String title,
  required List<(Value, String)> valueNamePairs,
  Value? currentValue,
}) async => showDialog<Value>(
  context: context,
  builder: (context) => RootPage(
    DialogPaths.editUserProfile,
    CustomAlertDialog.sync(
      clipBehavior: Clip.hardEdge,
      contentPadding: .zero,
      title: Text(title),
      content: Column(
        children: valueNamePairs
            .map(
              (v) => SelectableListTile(
                selected: currentValue == v.$1,
                title: Text(v.$2),
                onTap: () => context.pop(v.$1),
              ),
            )
            .toList(),
      ),
    ),
  ),
);

/// Show a dialog provides a text field waiting for input.
///
/// * [title] is the title of dialog.
/// * [initialText] is the initial text of text field.
/// * [onValueUpdated] is the callback invoked when dialog is saved (value updated).
/// * [validator] is an optional validator of the text input.
Future<String?> _showTextFieldDialog({
  required BuildContext context,
  required eup.UserProfile profile,
  required String title,
  required String initialText,
  required eup.UserProfile Function(eup.UserProfile, String) onValueUpdated,
  FormFieldValidator<String>? validator,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
  InputDecoration? inputDecoration,
  int? maxLines,
  int? minLines,
}) async => showDialog<String>(
  context: context,
  builder: (context) => RootPage(
    DialogPaths.editUserProfile,
    _TextFieldDialog(
      profile: profile,
      title: title,
      initialText: initialText,
      onValueUpdated: onValueUpdated,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      inputDecoration: inputDecoration,
      maxLines: maxLines,
      minLines: minLines,
    ),
  ),
);

class _TextFieldDialog extends StatefulWidget {
  const _TextFieldDialog({
    required this.profile,
    required this.title,
    required this.initialText,
    required this.onValueUpdated,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.inputDecoration,
    this.maxLines,
    this.minLines,
  });

  /// The original profile.
  final eup.UserProfile profile;

  /// Dialog title.
  final String title;

  /// Initial text.
  final String initialText;

  /// Callback to invoke when dialog is closed and text updated.
  final eup.UserProfile Function(eup.UserProfile, String) onValueUpdated;

  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final InputDecoration? inputDecoration;
  final int? maxLines;
  final int? minLines;

  /// Optional validator of text.
  final FormFieldValidator<String>? validator;

  @override
  State<_TextFieldDialog> createState() => _TextFieldDialogState();
}

class _TextFieldDialogState extends State<_TextFieldDialog> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog.sync(
      clipBehavior: Clip.hardEdge,
      title: Text(widget.title),
      content: Form(
        key: formKey,
        child: Padding(
          padding: edgeInsetsT4,
          child: TextFormField(
            autofocus: true,
            controller: controller,
            validator: widget.validator,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            decoration: widget.inputDecoration,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
          ),
        ),
      ),
      actions: [
        TextButton(
          child: Text(context.t.general.cancel),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text(context.t.general.ok),
          onPressed: () async {
            // Validate
            if (formKey.currentState == null || !(formKey.currentState!).validate()) {
              return;
            }
            Navigator.of(context).pop(controller.text);
          },
        ),
      ],
    );
  }
}

/// Data class to pass birthday related info for editing.
final class _BirthdayInfo {
  const _BirthdayInfo({
    required this.year,
    required this.month,
    required this.day,
    required this.availableYears,
  });

  final int? year;
  final int? month;
  final int? day;
  final List<int> availableYears;
}

/// Data class to pass web page style info for editing.
final class _PageStyleInfo {
  const _PageStyleInfo(this.style, this.availableStyles);

  final eup.PageStyle? style;
  final List<eup.PageStyle> availableStyles;
}

/// Data class to pass time zone info for editing.
final class _TimeZoneInfo {
  const _TimeZoneInfo(this.timeZone, this.availableTimeZones);

  final eup.TimeZone? timeZone;
  final List<eup.TimeZone> availableTimeZones;
}
