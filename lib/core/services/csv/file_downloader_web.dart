import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

Future<void> platformDownloadCsv(String content, String filename) async {
  final bytes = Uint8List.fromList(utf8.encode('﻿$content')); // BOM for Excel
  final jsArray = [bytes.toJS].toJS;
  final blob = web.Blob(jsArray, web.BlobPropertyBag(type: 'text/csv;charset=utf-8;'));
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = url;
  anchor.download = filename;
  anchor.style.display = 'none';
  web.document.body!.appendChild(anchor);
  anchor.click();
  web.document.body!.removeChild(anchor);
  web.URL.revokeObjectURL(url);
}
