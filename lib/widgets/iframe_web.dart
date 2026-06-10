import 'dart:ui_web' as ui_web;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';

Widget buildIFrame(String url) {
  final String viewId = 'iframe-${url.hashCode}-${DateTime.now().microsecondsSinceEpoch}';
  
  // Register the element factory
  ui_web.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
    final element = html.IFrameElement()
      ..src = url
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..setAttribute('sandbox', 'allow-scripts allow-same-origin allow-forms allow-popups');
    return element;
  });

  return HtmlElementView(viewType: viewId);
}
