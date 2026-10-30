import 'package:w51/features/inspirations/domain/entities/inspiration_entities.dart';

abstract interface class InspirationsRepository {
  /// Cerita utama dan daftar cerita lain.
  Future<InspirationsData> load();

  /// Satu cerita lengkap. Melempar `NotFoundException` bila tidak ada.
  Future<RealWeddingStory> loadStory(String id);
}
