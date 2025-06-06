import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/extensions/fp.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/providers/storage_provider/storage_provider.dart';
import 'package:tsdm_client/utils/logger.dart';

/// Type of editing the fast rate template.
enum FastRateTemplateEditType {
  /// Create a new one.
  create,

  /// Edit one we already have.
  edit,
}

/// Page to edit template.
class FastRateTemplateEditPage extends StatefulWidget {
  /// Constructor.
  const FastRateTemplateEditPage(this.editType, this.initialValue, {super.key});

  /// Type of the edit.
  final FastRateTemplateEditType editType;

  /// Optional initial template value.
  final FastRateTemplateModel? initialValue;

  @override
  State<FastRateTemplateEditPage> createState() => _FastRateTemplateEditPageState();
}

class _FastRateTemplateEditPageState extends State<FastRateTemplateEditPage> with LoggerMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController editingControllerName;
  late final TextEditingController editingControllerWw;
  late final TextEditingController editingControllerTsb;
  late final TextEditingController editingControllerXc;
  late final TextEditingController editingControllerJl;
  late final TextEditingController editingControllerTr;
  late final TextEditingController editingControllerFh;
  late final TextEditingController editingControllerSpecial;

  /// All current templates, for duplicate check.
  final List<FastRateTemplateModel> allTemplates = [];

  final numberInputFormatter = FilteringTextInputFormatter.allow(RegExp(r'^(-)?[0-9]*$'));

  /// Allow override same name template.
  bool allowOverride = false;

  String? attributeValidator(String? v, BuildContext context) {
    if (v == null || int.tryParse(v) == null) {
      return context.t.fastRateTemplate.editPage.invalidValue;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    editingControllerName = TextEditingController(text: widget.initialValue?.name);
    editingControllerWw = TextEditingController(text: '${widget.initialValue?.ww ?? "0"}');
    editingControllerTsb = TextEditingController(text: '${widget.initialValue?.tsb ?? "0"}');
    editingControllerXc = TextEditingController(text: '${widget.initialValue?.xc ?? "0"}');
    editingControllerTr = TextEditingController(text: '${widget.initialValue?.tr ?? "0"}');
    editingControllerFh = TextEditingController(text: '${widget.initialValue?.fh ?? "0"}');
    editingControllerJl = TextEditingController(text: '${widget.initialValue?.jl ?? "0"}');
    editingControllerSpecial = TextEditingController(text: '${widget.initialValue?.special ?? "0"}');
  }

  @override
  void dispose() {
    editingControllerName.dispose();
    editingControllerWw.dispose();
    editingControllerTsb.dispose();
    editingControllerXc.dispose();
    editingControllerJl.dispose();
    editingControllerTr.dispose();
    editingControllerFh.dispose();
    editingControllerSpecial.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.fastRateTemplate;

    final body = FutureBuilder(
      future: getIt.get<StorageProvider>().getAllFastRateTemplate().run(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          error('failed to load all fast rate templates: ${snapshot.error}');
          return Center(child: Text(context.t.general.failedToLoad));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final result = snapshot.data!;
        if (result.isLeft()) {
          error('failed to unpack fast rate all templates result: ${result.unwrapErr()}');
          return Center(child: Text(context.t.general.failedToLoad));
        }

        final allTemplates = result.unwrap();

        return Form(
          key: _formKey,
          child: ListView(
            padding: edgeInsetsL12T4R12.add(context.safePadding()),
            children: [
              TextFormField(
                controller: editingControllerName,
                autofocus: widget.editType == FastRateTemplateEditType.create,
                decoration: InputDecoration(labelText: tr.name),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return tr.editPage.nameNotEmpty;
                  }

                  // Duplicate check.
                  if (widget.editType == FastRateTemplateEditType.create && !allowOverride) {
                    // Uid equality is ignored here.
                    if (allTemplates.any((e) => e.name == v)) {
                      return tr.editPageAlreadyExists;
                    }
                  }

                  return null;
                },
              ),
              sizedBoxW8H8,
              TextFormField(
                controller: editingControllerWw,
                decoration: InputDecoration(labelText: tr.ww),
                keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                inputFormatters: [numberInputFormatter],
                validator: (v) => attributeValidator(v, context),
              ),
              sizedBoxW8H8,
              TextFormField(
                controller: editingControllerTsb,
                decoration: InputDecoration(labelText: tr.tsb),
                keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                inputFormatters: [numberInputFormatter],
                validator: (v) => attributeValidator(v, context),
              ),
              sizedBoxW8H8,
              TextFormField(
                controller: editingControllerXc,
                decoration: InputDecoration(labelText: tr.xc),
                keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                inputFormatters: [numberInputFormatter],
                validator: (v) => attributeValidator(v, context),
              ),
              sizedBoxW8H8,
              TextFormField(
                controller: editingControllerTr,
                decoration: InputDecoration(labelText: tr.tr),
                keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                inputFormatters: [numberInputFormatter],
                validator: (v) => attributeValidator(v, context),
              ),
              sizedBoxW8H8,
              TextFormField(
                controller: editingControllerFh,
                decoration: InputDecoration(labelText: tr.fh),
                keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                inputFormatters: [numberInputFormatter],
                validator: (v) => attributeValidator(v, context),
              ),
              sizedBoxW8H8,
              TextFormField(
                controller: editingControllerJl,
                decoration: InputDecoration(labelText: tr.jl),
                keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                inputFormatters: [numberInputFormatter],
                validator: (v) => attributeValidator(v, context),
              ),
              sizedBoxW8H8,
              TextFormField(
                controller: editingControllerSpecial,
                decoration: InputDecoration(labelText: tr.special),
                keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                inputFormatters: [numberInputFormatter],
                validator: (v) => attributeValidator(v, context),
              ),
              if (widget.editType == FastRateTemplateEditType.create) ...[
                // Only show override option if drafting new templates.
                sizedBoxW8H8,
                SwitchListTile(
                  title: Text(tr.editPageOverride),
                  value: allowOverride,
                  onChanged: (v) => setState(() => allowOverride = v),
                ),
              ],
              sizedBoxW8H8,
              FilledButton(
                child: Text(context.t.general.ok),
                onPressed: () {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }

                  context.pop(
                    FastRateTemplateModel(
                      name: editingControllerName.text,
                      ww: int.parse(editingControllerWw.text),
                      tsb: int.parse(editingControllerTsb.text),
                      xc: int.parse(editingControllerXc.text),
                      tr: int.parse(editingControllerTr.text),
                      fh: int.parse(editingControllerFh.text),
                      jl: int.parse(editingControllerJl.text),
                      special: int.parse(editingControllerSpecial.text),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(switch (widget.editType) {
          FastRateTemplateEditType.create => tr.editPageTitle,
          FastRateTemplateEditType.edit => tr.edit,
        }),
      ),
      body: body,
    );
  }
}
