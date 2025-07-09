import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'models/push_up_model.dart';

Future<String> getAssetPath(String asset) async {
  final path = await getLocalPath(asset);
  await Directory(dirname(path)).create(recursive: true);
  final file = File(path);
  if (!await file.exists()) {
    final byteData = await rootBundle.load(asset);
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  }
  return file.path;
}

Future<String> getLocalPath(String path) async {
  return '${(await getApplicationSupportDirectory()).path}/$path';
}

double angle(
  PoseLandmark firstLandmark,
  PoseLandmark midLandmark,
  PoseLandmark lastLandmark,
) {
  final radians = math.atan2(
          lastLandmark.y - midLandmark.y, lastLandmark.x - midLandmark.x) -
      math.atan2(
          firstLandmark.y - midLandmark.y, firstLandmark.x - midLandmark.x);
  double degrees = radians * 180.0 / math.pi;
  degrees = degrees.abs(); // Angle should never be negative
  if (degrees > 180.0) {
    degrees =
        360.0 - degrees; // Always get the acute representation of the angle
  }
  return degrees;
}

PushUpState? isPushUp(double angleElbow, PushUpState current) {
  const thresholdDown = 75.0; // codo muy doblado (abajo)
  const thresholdUp = 160.0; // codo extendido (arriba)

  print('[DEBUG isPushUp] Angle: $angleElbow | Current: $current');

  if (current == PushUpState.neutral && angleElbow < thresholdDown) {
    print('[DEBUG isPushUp] -> init');
    return PushUpState.init;
  }

  if (current == PushUpState.init && angleElbow > thresholdUp) {
    print('[DEBUG isPushUp] -> complete');
    return PushUpState.complete;
  }

  return null;
}

class FeedbackResult {
  final List<String> messages;
  final List<List<PoseLandmarkType>> badLines;

  FeedbackResult({required this.messages, required this.badLines});
}

FeedbackResult getPushUpFeedback(Pose pose) {
  List<String> feedback = [];
  List<List<PoseLandmarkType>> badLines = [];

  final rs = pose.landmarks[PoseLandmarkType.rightShoulder];
  final re = pose.landmarks[PoseLandmarkType.rightElbow];
  final rw = pose.landmarks[PoseLandmarkType.rightWrist];
  final rh = pose.landmarks[PoseLandmarkType.rightHip];
  final rk = pose.landmarks[PoseLandmarkType.rightKnee];
  final ra = pose.landmarks[PoseLandmarkType.rightAnkle];

  if (rs == null || re == null || rw == null) {
    return FeedbackResult(messages: feedback, badLines: []);
  }

  final elbowAngle = angle(rs, re, rw);
  if (elbowAngle > 165) {
    feedback.add("Baja más");
    badLines.add([PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow]);
    badLines.add([PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist]);
  } else if (elbowAngle < 50) {
    feedback.add("Extiende más los brazos");
    badLines.add([PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow]);
    badLines.add([PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist]);
  }

  if (rs != null && rh != null && ra != null) {
    final bodyAngle = angle(rs, rh, ra);
    if (bodyAngle < 165) {
      feedback.add("Evita arquear la espalda");
      badLines.add([PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip]);
      badLines.add([PoseLandmarkType.rightHip, PoseLandmarkType.rightAnkle]);
    }
  }

  return FeedbackResult(messages: feedback, badLines: badLines);
}
