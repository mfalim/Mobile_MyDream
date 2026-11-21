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
    List<PublicEventItem> events = const [];
    try {
      final rawEvents = await _api.getList('/content/events');
      events = [for (final e in rawEvents) StoryModel.publicEvent(e)];
    } catch (_) {
      events = const [];
    }
    if (items.isEmpty) {
      return InspirationsData(story: null, more: const [], events: events);
    }
    return InspirationsData(
      story: StoryModel.story(items.first),
      more: [for (final item in items.skip(1)) StoryModel.teaser(item)],
      events: events,
    );
  }

  @override
  Future<RealWeddingStory> fetchStory(String id) async {
    final json =
        await _api.getObject('/content/articles/${Uri.encodeComponent(id)}');
    return StoryModel.story(json);
  }
}
