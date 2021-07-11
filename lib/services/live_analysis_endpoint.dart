import 'dart:io';

import 'package:flutter/foundation.dart';

Uri getLiveAnalysisEndpoint(final queryParameters) {
  if (kDebugMode) {
    if (Platform.isAndroid) {
      return Uri.http('10.0.2.2:5000', 'analyse', queryParameters);
    } else {
      return Uri.http('127.0.0.1:5000', 'analyse', queryParameters);
    }
  }
  return Uri.https('guessthemove.sengerts.de', 'analyse', queryParameters);
}
