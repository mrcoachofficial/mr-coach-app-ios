import 'package:flutter/material.dart';
import 'iframe_stub.dart'
    if (dart.library.js_util) 'iframe_web.dart'
    if (dart.library.io) 'iframe_mobile.dart';

Widget getIFrameWidget(String url) {
  return buildIFrame(url);
}
