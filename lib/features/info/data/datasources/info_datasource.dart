import 'package:w51/features/info/domain/entities/info_document.dart';

abstract interface class InfoDatasource {
  Future<InfoDocument> fetch(String slug);
}
