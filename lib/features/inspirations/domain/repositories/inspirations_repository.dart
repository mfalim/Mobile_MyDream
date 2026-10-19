import 'package:w51/features/inspirations/domain/entities/inspiration_entities.dart';

abstract interface class InspirationsRepository {
  Future<InspirationsData> load();
}
