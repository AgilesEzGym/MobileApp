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

PushUpState? isPushUp(
  double rightElbowAngle,
  double leftElbowAngle,
  PushUpState current,
) {
  const thresholdDown = 100.0; // codo muy doblado (posición abajo)
  const thresholdUp = 150.0; // codo extendido (posición arriba)

  final avgElbow = (rightElbowAngle + leftElbowAngle) / 2;

  print(
      '[DEBUG isPushUp] Right: $rightElbowAngle | Left: $leftElbowAngle | Avg: $avgElbow | State: $current');

  if (current == PushUpState.neutral && avgElbow < thresholdDown) {
    return PushUpState.init;
  }

  if (current == PushUpState.init && avgElbow > thresholdUp) {
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
  final ra = pose.landmarks[PoseLandmarkType.rightAnkle];

  final ls = pose.landmarks[PoseLandmarkType.leftShoulder];
  final le = pose.landmarks[PoseLandmarkType.leftElbow];
  final lw = pose.landmarks[PoseLandmarkType.leftWrist];
  final lh = pose.landmarks[PoseLandmarkType.leftHip];
  final la = pose.landmarks[PoseLandmarkType.leftAnkle];

  if (rs == null ||
      re == null ||
      rw == null ||
      ls == null ||
      le == null ||
      lw == null) {
    return FeedbackResult(messages: feedback, badLines: []);
  }

  final rightElbowAngle = angle(rs, re, rw);
  final leftElbowAngle = angle(ls, le, lw);
  final diff = (rightElbowAngle - leftElbowAngle).abs();

  // 1. Elbow angles feedback
  if (rightElbowAngle > 165 && leftElbowAngle > 165) {
    feedback.add("Baja más");
    badLines.add([PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow]);
    badLines.add([PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist]);
    badLines.add([PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow]);
    badLines.add([PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist]);
  } else if (rightElbowAngle < 50 && leftElbowAngle < 50) {
    feedback.add("Extiende más los brazos");
    badLines.add([PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow]);
    badLines.add([PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist]);
    badLines.add([PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow]);
    badLines.add([PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist]);
  }

  // 2. Simetría
  if (diff > 20) {
    feedback.add("Mantén ambos brazos simétricos");
    badLines.add([PoseLandmarkType.rightElbow, PoseLandmarkType.leftElbow]);
  }

  // 3. Postura de cuerpo (evitar arco)
  if (rs != null &&
      rh != null &&
      ra != null &&
      ls != null &&
      lh != null &&
      la != null) {
    final rightBodyAngle = angle(rs, rh, ra);
    final leftBodyAngle = angle(ls, lh, la);

    final avgBodyAngle = (rightBodyAngle + leftBodyAngle) / 2;
    if (avgBodyAngle < 165) {
      feedback.add("Evita arquear la espalda");
      badLines.add([PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip]);
      badLines.add([PoseLandmarkType.rightHip, PoseLandmarkType.rightAnkle]);
      badLines.add([PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip]);
      badLines.add([PoseLandmarkType.leftHip, PoseLandmarkType.leftAnkle]);
    }
  }

  return FeedbackResult(messages: feedback, badLines: badLines);
}
