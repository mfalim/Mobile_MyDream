import 'package:w51/features/inspirations/domain/entities/inspiration_entities.dart';

abstract interface class InspirationsDatasource {
  Future<InspirationsData> fetch();
  Future<RealWeddingStory> fetchStory(String id);
}
