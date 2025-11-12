import 'package:chat_bottom_container/chat_bottom_container.dart';
import 'package:dart_bbcode_parser/dart_bbcode_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbcode_editor/flutter_bbcode_editor.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/constants.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/fp.dart';
import 'package:tsdm_client/features/editor/widgets/rich_editor.dart';
import 'package:tsdm_client/features/editor/widgets/toolbar.dart';
import 'package:tsdm_client/features/settings/repositories/settings_repository.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/providers/storage_provider/storage_provider.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/utils/platform.dart';
import 'package:tsdm_client/utils/show_toast.dart';
import 'package:tsdm_client/widgets/indicator.dart';

/// Type of editing the fast reply template.
enum FastReplyTemplateEditType {
  /// Create a new one.
  create,

  /// Edit one we already have.
  edit,
}

enum _BottomPanelType { none, keyboard, toolbar }

/// Page to edit template.
class FastReplyTemplateEditPage extends StatefulWidget {
  /// Constructor.
  const FastReplyTemplateEditPage(this.editType, this.initialValue, {super.key});

  /// Type of the edit.
  final FastReplyTemplateEditType editType;

  /// Optional initial template value.
  final FastReplyTemplateModel? initialValue;

  @override
  State<FastReplyTemplateEditPage> createState() => _FastReplyTemplateEditPageState();
}

class _FastReplyTemplateEditPageState extends State<FastReplyTemplateEditPage> with LoggerMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final BBCodeEditorController dataController;

  /// Allow override same name template.
  bool allowOverride = false;

  final panelController = ChatBottomPanelContainerController<_BottomPanelType>();

  final disabledFeatures = Set<EditorFeatures>.from(defaultFullScreenDisabledEditorFeatures)
    ..remove(EditorFeatures.free);

  _BottomPanelType panelType = _BottomPanelType.none;

  late final FocusNode focusNode;

  /// Allow reply bar full screen.
  ///
  /// Will not restrict reply bar height when set to true.
  late bool fullScreen;

  // TODO: Fix duplicate with same logic in post edit page.
  Widget _buildMobileToolbar(BuildContext context) {
    return ChatBottomPanelContainer<_BottomPanelType>(
      controller: panelController,
      inputFocusNode: focusNode,
      otherPanelWidget: (type) {
        return switch (type) {
          null => sizedBoxEmpty,
          _BottomPanelType.none => sizedBoxEmpty,
          _BottomPanelType.keyboard => sizedBoxEmpty,
          _BottomPanelType.toolbar => Align(
            child: EditorToolbar(
              bbcodeController: dataController,
              disabledFeatures: disabledFeatures,
              editorFocusNode: focusNode,
            ),
          ),
        };
      },
      onPanelTypeChange: (p, data) {
        switch (p) {
          case ChatBottomPanelType.none:
            panelType = _BottomPanelType.none;
          case ChatBottomPanelType.keyboard:
            panelType = _BottomPanelType.keyboard;
            // TODO: Remove the setState after tricky removed.
            // Some button in editor that use a popup menu does not reset
            // fullScreen flag as we are doing some tricky thing in toolbar.
            //
            // Font size button overridden with an empty font size button
            // option is so:
            //
            // QuillToolbarFontSizeButtonOptions(afterButtonPressed: () {}),
            //
            // Manually set to false.
            if (fullScreen) {
              setState(() {
                fullScreen = false;
              });
            }
          case ChatBottomPanelType.other:
            switch (data) {
              case null:
                panelType = _BottomPanelType.none;
              case _BottomPanelType.none:
                panelType = _BottomPanelType.none;
              case _BottomPanelType.keyboard:
                panelType = _BottomPanelType.keyboard;
              case _BottomPanelType.toolbar:
                panelType = _BottomPanelType.toolbar;
            }
        }
      },
      panelBgColor: Theme.of(context).colorScheme.surfaceContainerLow,
    );
  }

  /// Build the row to control a
  Widget _buildControlRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                sizedBoxW4H4,
                // Only control expand or collapse on mobile platforms.
                // For desktop, always expand the toolbar.
                if (isMobile)
                  IconButton(
                    icon: const Icon(Icons.expand),
                    tooltip: context.t.bbcodeEditor.toolbar,
                    selectedIcon: Icon(Icons.expand_outlined, color: Theme.of(context).primaryColor),
                    isSelected: fullScreen,
                    onPressed: () {
                      setState(() {
                        fullScreen = !fullScreen;
                      });
                      if (fullScreen) {
                        panelController.updatePanelType(ChatBottomPanelType.other, data: _BottomPanelType.toolbar);
                      } else {
                        panelController.updatePanelType(ChatBottomPanelType.keyboard);
                      }
                    },
                  ),
                sizedBoxW4H4,
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialValue?.name ?? '');
    final parserEnabled = getIt.get<SettingsRepository>().currentSettings.enableEditorBBCodeParser;
    if (parserEnabled) {
      dataController = buildBBCodeEditorController(
        initialDelta: parseBBCodeTextToDelta(widget.initialValue?.data ?? '\n'),
      );
    } else {
      dataController = buildBBCodeEditorController(initialText: widget.initialValue?.data);
    }
    focusNode = FocusNode();
    fullScreen = isDesktop;
  }

  @override
  void dispose() {
    nameController.dispose();
    dataController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.fastReplyTemplate;

    final body = FutureBuilder(
      future: getIt.get<StorageProvider>().getAllFastReplyTemplate().run(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          error('failed to load all fast reply templates: ${snapshot.error}');
          return Center(child: Text(context.t.general.failedToLoad));
        }

        if (!snapshot.hasData) {
          return const CenteredCircularIndicator();
        }

        final result = snapshot.data!;
        if (result.isLeft()) {
          error('failed to unpack fast reply all templates result: ${result.unwrapErr()}');
          return Center(child: Text(context.t.general.failedToLoad));
        }

        final allTemplates = result.unwrap();

        return Form(
          key: _formKey,
          child: Column(
            children: [
              if (widget.editType == FastReplyTemplateEditType.create)
                Align(
                  child: SwitchListTile(
                    title: Text(tr.editPageOverride),
                    value: allowOverride,
                    onChanged: (v) => setState(() => allowOverride = v),
                  ),
                ),
              // Template name.
              Padding(
                padding: edgeInsetsL8R8.add(edgeInsetsT8),
                child: TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: tr.name),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return tr.editPageNameNotEmpty;
                    }

                    // Duplicate check.
                    if (widget.editType == FastReplyTemplateEditType.create && !allowOverride) {
                      // Uid equality is ignored here.
                      if (allTemplates.any((e) => e.name == v)) {
                        return tr.editPageAlreadyExists;
                      }
                    }

                    return null;
                  },
                ),
              ),
              sizedBoxW4H4,
              Expanded(
                child: Padding(
                  padding: isMobile ? edgeInsetsL16R16 : edgeInsetsL4R4,
                  child: RichEditor(autoFocus: true, controller: dataController, editorFocusNode: focusNode),
                ),
              ),
              if (isDesktop)
                // Expand and can not replace with Align.
                Row(
                  children: [
                    Expanded(
                      child: ColoredBox(
                        color: Theme.of(context).colorScheme.surfaceContainerLow,
                        child: Padding(
                          padding: edgeInsetsL4R4.add(edgeInsetsT4),
                          child: EditorToolbar(
                            bbcodeController: dataController,
                            disabledFeatures: disabledFeatures,
                            editorFocusNode: focusNode,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                child: Padding(padding: edgeInsetsR4.add(edgeInsetsB4), child: _buildControlRow(context)),
              ),
              if (isMobile) _buildMobileToolbar(context),
            ],
          ),
        );
      },
    );

    return Scaffold(
      // Required by chat_bottom_container in the reply bar.
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(switch (widget.editType) {
          FastReplyTemplateEditType.create => tr.editPageTitle,
          FastReplyTemplateEditType.edit => tr.edit,
        }),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: tr.editPageSaveTemplate,
            onPressed: () async {
              if (!_formKey.currentState!.validate()) {
                return;
              }

              if (!context.mounted) {
                return;
              }

              context.pop(FastReplyTemplateModel(name: nameController.text, data: dataController.toBBCode()));
              showSnackBar(context: context, message: tr.editPageTemplateAdded);
            },
          ),
        ],
      ),
      body: SafeArea(bottom: false, child: body),
    );
  }
}
