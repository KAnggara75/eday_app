import 'dart:typed_data';
import 'package:http/http.dart' as http;

class GithubApiService {
  final http.Client _client;

  GithubApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<Uint8List?> fetchGuidelineImage({
    required String owner,
    required String repo,
    required String targetPath,
    required String token,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final url = Uri.parse(
      'https://api.github.com/repos/$owner/$repo/contents/$targetPath?v=$timestamp',
    );

    try {
      final response = await _client.get(
        url,
        headers: {
          'Authorization': 'token $token',
          'Accept': 'application/vnd.github.v3.raw',
        },
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (_) {}
    return null;
  }
}
