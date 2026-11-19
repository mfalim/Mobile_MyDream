import 'package:w51/core/errors/app_exceptions.dart';
import 'package:w51/core/network/api_client.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/core/utils/json_helpers.dart';
import 'package:w51/features/info/data/datasources/info_datasource.dart';
import 'package:w51/features/info/data/datasources/info_mock_datasource.dart';
import 'package:w51/features/info/domain/entities/info_document.dart';

class InfoRemoteDatasource implements InfoDatasource {
  const InfoRemoteDatasource(this._api);

  final ApiClient _api;

  @override
  Future<InfoDocument> fetch(String slug) async {
    try {
      final json = await _api.getObject('/pages/${Uri.encodeComponent(slug)}');
      final sections = <InfoSection>[];
      final rawSections = json['sections'];
      if (rawSections is List) {
        for (final section in rawSections.whereType<Map>()) {
          final heading = jsonString(section['heading']);
          final body = jsonString(section['body']);
          if (heading != null && body != null) {
            sections.add(InfoSection(heading: heading, body: body));
          }
        }
      }

      final updatedAt = jsonString(json['updated_at']);
      final updatedDate = updatedAt == null ? null : DateTime.tryParse(updatedAt);
      final title = jsonString(json['title']);
      if (title == null) {
        throw const FormatException('Respons halaman tidak memiliki judul.');
      }

      return InfoDocument(
        slug: jsonString(json['slug']) ?? slug,
        title: title,
        updatedLabel: updatedDate == null
            ? updatedAt ?? ''
            : formatDateShortId(updatedDate),
        sections: sections,
      );
    } on NotFoundException {
      // Gunakan konten dari /api/about di Laravel atau fallback dokumen standar
      return InfoMockDatasource().fetch(slug);
    }
  }
}
