import 'media_search_result.dart';
import 'media_type.dart';

abstract class MediaSearchClient {
  Future<List<MediaSearchResult>> search({
    required String query,
    required MediaType mediaType,
  });
}
