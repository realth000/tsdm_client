part of 'models.dart';

/// The latest version number of [EditorDocument]
const _editorDocumentLatestVersion = 1;

/// Additional option of an additional option in thread.
///
/// Each additional option is a check box.
@MappableClass()
final class EditorDocumentAdditionalOption with EditorDocumentAdditionalOptionMappable {
  /// Constructor.
  const EditorDocumentAdditionalOption({required this.name, required this.checked});

  /// Optiona name.
  final String name;

  /// The 'checked' field of additional option.
  final bool checked;
}

/// Metadata of thread content document.
@MappableClass()
final class EditorDocumentMetadata with EditorDocumentMetadataMappable {
  /// Constructor.
  const EditorDocumentMetadata({
    required this.version,
    required this.title,
    required this.typeId,
    required this.additionalOptions,
    required this.price,
    required this.perm,
  });

  /// Empty instance.
  factory EditorDocumentMetadata.empty() => const EditorDocumentMetadata(
    version: _editorDocumentLatestVersion,
    title: null,
    typeId: null,
    additionalOptions: [],
    price: null,
    perm: null,
  );

  /// Check if current metadata is empty or not.
  ///
  /// If all data fields are **invalid**, current metadata is empty.
  bool get isEmpty => !isNotEmpty;

  /// Check if current metadata is empty or not.
  ///
  /// If any data field is **valid**, current metadata is not empty.
  bool get isNotEmpty =>
      title != null || typeId != null || additionalOptions.isNotEmpty || price != null || perm != null;

  /// Document version.
  final int version;

  /// Thread title string.
  final String? title;

  /// Id of thread type.
  ///
  /// Not the readable name, is the key used when submiting form.
  final String? typeId;

  /// A list of check box options of document.
  final List<EditorDocumentAdditionalOption> additionalOptions;

  /// Price of the thread.
  final int? price;

  /// Permission required.
  final String? perm;
}

/// Thread content document.
///
/// Each document holds the content of a thread.
@MappableClass()
final class EditorDocument with EditorDocumentMappable {
  /// Constructor.
  const EditorDocument({required this.metadata, required this.operations});

  /// Build from raw operations and optional metadata.
  factory EditorDocument.build(EditorDocumentMetadata? metadata, List<Map<String, dynamic>> operations) =>
      EditorDocument(metadata: metadata ?? EditorDocumentMetadata.empty(), operations: operations);

  /// Metadata of the document.
  final EditorDocumentMetadata metadata;

  /// Document operations.
  final List<Map<String, dynamic>> operations;
}
