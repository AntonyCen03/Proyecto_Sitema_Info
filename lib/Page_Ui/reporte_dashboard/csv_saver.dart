// Cross-platform CSV saver.
// IO (mobile/desktop): saves to Downloads/Documents using path_provider.
// Web: triggers a browser download.

import 'csv_saver_io.dart' if (dart.library.html) 'csv_saver_web.dart' as impl;
import 'package:flutter/material.dart';

/// Saves [content] as CSV with [fileName] and returns a human-friendly message
/// or saved file path when available. On web, returns null after triggering download.
Future<String?> saveCsv(BuildContext context, String fileName, String content) {
  return impl.saveCsv(context, fileName, content);
}
