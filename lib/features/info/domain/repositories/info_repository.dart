import 'package:w51/features/info/domain/entities/info_document.dart';

abstract interface class InfoRepository {
  Future<InfoDocument> load(String slug);
}
