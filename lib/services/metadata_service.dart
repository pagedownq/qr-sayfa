import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:flutter/foundation.dart';

class LinkMetadata {
  final String? title;
  final String? description;
  final String? image;
  final String? favicon;

  LinkMetadata({this.title, this.description, this.image, this.favicon});
}

class MetadataService {
  static Future<LinkMetadata?> fetchMetadata(String url) async {
    if (!url.startsWith('http')) {
      url = 'https://$url';
    }

    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final document = parse(response.body);
        
        String? title = document.querySelector('title')?.text;
        String? description;
        String? image;
        String? favicon;

        // Try OpenGraph tags
        final metaTags = document.getElementsByTagName('meta');
        for (var tag in metaTags) {
          final property = tag.attributes['property'];
          final name = tag.attributes['name'];
          final content = tag.attributes['content'];

          if (property == 'og:title' || name == 'title') {
            title = content ?? title;
          } else if (property == 'og:description' || name == 'description') {
            description = content;
          } else if (property == 'og:image') {
            image = content;
          }
        }

        // Try favicon
        final linkTags = document.getElementsByTagName('link');
        for (var tag in linkTags) {
          final rel = tag.attributes['rel'];
          if (rel != null && rel.contains('icon')) {
            favicon = tag.attributes['href'];
            if (favicon != null && !favicon.startsWith('http')) {
              final uri = Uri.parse(url);
              favicon = '${uri.scheme}://${uri.host}$favicon';
            }
            break;
          }
        }

        // Truncate title if too long
        if (title != null && title.length > 40) {
          title = '${title.substring(0, 37)}...';
        }

        return LinkMetadata(
          title: title?.trim(),
          description: description?.trim(),
          image: image,
          favicon: favicon,
        );
      }
    } catch (e) {
      debugPrint('Metadata fetch error: $e');
    }
    return null;
  }

  static String? detectPlatform(String url) {
    final lowerUrl = url.toLowerCase();
    if (lowerUrl.contains('instagram.com')) return 'instagram';
    if (lowerUrl.contains('twitter.com') || lowerUrl.contains('x.com')) return 'x-twitter';
    if (lowerUrl.contains('tiktok.com')) return 'tiktok';
    if (lowerUrl.contains('youtube.com') || lowerUrl.contains('youtu.be')) return 'youtube';
    if (lowerUrl.contains('facebook.com') || lowerUrl.contains('fb.com')) return 'facebook';
    if (lowerUrl.contains('linkedin.com')) return 'linkedin';
    if (lowerUrl.contains('github.com')) return 'github';
    if (lowerUrl.contains('spotify.com')) return 'spotify';
    if (lowerUrl.contains('telegram.me') || lowerUrl.contains('t.me')) return 'telegram';
    if (lowerUrl.contains('discord.gg') || lowerUrl.contains('discord.com')) return 'discord';
    if (lowerUrl.contains('wa.me') || lowerUrl.contains('whatsapp.com')) return 'whatsapp';
    return null;
  }
}
