import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ShareUtil {
  static Future<void> shareImageFromUrl(String imageUrl, String text) async {
    try {
      if (kIsWeb) {
        await Share.share(text);
        return;
      }
      final res = await http.get(Uri.parse(imageUrl));
      final bytes = res.bodyBytes;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/shared_chart.jpg');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)], text: text);
    } catch (e) {
      await Share.share(text);
    }
  }
}
