import 'package:w51/core/network/api_client.dart';
import 'package:w51/features/inspirations/data/datasources/inspirations_datasource.dart';
import 'package:w51/features/inspirations/data/models/story_model.dart';
import 'package:w51/features/inspirations/domain/entities/inspiration_entities.dart';

class InspirationsRemoteDatasource implements InspirationsDatasource {
  const InspirationsRemoteDatasource(this._api);

  final ApiClient _api;

  @override
  Future<InspirationsData> fetch() async {
    final items = await _api.getList('/content/articles');
    if (items.isEmpty) return const InspirationsData(story: null, more: []);
    return InspirationsData(
      story: StoryModel.story(items.first),
      more: [for (final item in items.skip(1)) StoryModel.teaser(item)],
    );
  }

  @override
  Future<RealWeddingStory> fetchStory(String id) async {
    final json =
        await _api.getObject('/content/articles/${Uri.encodeComponent(id)}');
    return StoryModel.story(json);
  }
}
