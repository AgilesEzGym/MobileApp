import 'dart:io';
import 'dart:math' as math;

import 'package:ezgym/models/jumping_jack_counter.dart';
import 'package:ezgym/models/squat_counter.dart';
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

  // Landmarks necesarios
  final rs = pose.landmarks[PoseLandmarkType.rightShoulder];
  final re = pose.landmarks[PoseLandmarkType.rightElbow];
  final rw = pose.landmarks[PoseLandmarkType.rightWrist];
  final rh = pose.landmarks[PoseLandmarkType.rightHip];
  final rk = pose.landmarks[PoseLandmarkType.rightKnee];
  final ra = pose.landmarks[PoseLandmarkType.rightAnkle];

  final ls = pose.landmarks[PoseLandmarkType.leftShoulder];
  final le = pose.landmarks[PoseLandmarkType.leftElbow];
  final lw = pose.landmarks[PoseLandmarkType.leftWrist];
  final lh = pose.landmarks[PoseLandmarkType.leftHip];
  final lk = pose.landmarks[PoseLandmarkType.leftKnee];
  final la = pose.landmarks[PoseLandmarkType.leftAnkle];

  if ([rs, re, rw, rh, rk, ra, ls, le, lw, lh, lk, la].any((p) => p == null)) {
    return FeedbackResult(messages: feedback, badLines: []);
  }

  // 1. Codos – profundidad y extensión
  final rightElbowAngle = angle(rs!, re!, rw!);
  final leftElbowAngle = angle(ls!, le!, lw!);
  final avgElbow = (rightElbowAngle + leftElbowAngle) / 2;

  if (avgElbow > 160) {
    feedback.add("Baja más los codos");
    badLines.addAll([
      [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
      [PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
      [PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],
    ]);
  } else if (avgElbow < 45) {
    feedback.add("Extiende más los brazos");
    badLines.addAll([
      [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
      [PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
      [PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],
    ]);
  }

  // 2. Simetría de brazos
  final diff = (rightElbowAngle - leftElbowAngle).abs();
  if (diff > 20) {
    feedback.add("Los brazos están desbalanceados");
    badLines.add([PoseLandmarkType.rightElbow, PoseLandmarkType.leftElbow]);
  }

  // 3. Alineación del torso y piernas (evitar arco)
  final rightBodyAngle = angle(rs, rh!, ra!);
  final leftBodyAngle = angle(ls, lh!, la!);
  final avgBodyAngle = (rightBodyAngle + leftBodyAngle) / 2;
  if (avgBodyAngle < 165) {
    feedback.add("No arquees la espalda");
    badLines.addAll([
      [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
      [PoseLandmarkType.rightHip, PoseLandmarkType.rightAnkle],
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip],
      [PoseLandmarkType.leftHip, PoseLandmarkType.leftAnkle],
    ]);
  }

  // 4. Cadera caída
  final hipMidY = (rh.y + lh.y) / 2;
  final shoulderMidY = (rs.y + ls.y) / 2;
  final kneeMidY = (rk!.y + lk!.y) / 2;
  if (hipMidY > shoulderMidY + 20 && hipMidY > kneeMidY + 20) {
    feedback.add("Levanta la cadera");
    badLines.add([PoseLandmarkType.rightHip, PoseLandmarkType.leftHip]);
  }

  return FeedbackResult(messages: feedback, badLines: badLines);
}

SquatState? isSquat(double hipAngle, SquatState current) {
  const thresholdDown = 90.0;
  const thresholdUp = 160.0;

  if (current == SquatState.neutral && hipAngle < thresholdDown) {
    return SquatState.init; // <--- CAMBIO AQUÍ
  }
  if (current == SquatState.init && hipAngle > thresholdUp) {
    return SquatState.complete;
  }
  return null;
}

FeedbackResult getSquatFeedback(Pose pose) {
  List<String> feedback = [];
  List<List<PoseLandmarkType>> badLines = [];

  final lh = pose.landmarks[PoseLandmarkType.leftHip];
  final lk = pose.landmarks[PoseLandmarkType.leftKnee];
  final la = pose.landmarks[PoseLandmarkType.leftAnkle];
  final rh = pose.landmarks[PoseLandmarkType.rightHip];
  final rk = pose.landmarks[PoseLandmarkType.rightKnee];
  final ra = pose.landmarks[PoseLandmarkType.rightAnkle];

  if (lh == null ||
      lk == null ||
      la == null ||
      rh == null ||
      rk == null ||
      ra == null) {
    return FeedbackResult(messages: feedback, badLines: []);
  }

  final leftAngle = angle(lh, lk, la);
  final rightAngle = angle(rh, rk, ra);
  final avgAngle = (leftAngle + rightAngle) / 2;

  if (avgAngle > 140) {
    feedback.add("Baja más al hacer la sentadilla");
    badLines.add([PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee]);
    badLines.add([PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle]);
    badLines.add([PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee]);
    badLines.add([PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle]);
  }

  return FeedbackResult(messages: feedback, badLines: badLines);
}

bool wasOpen = false;

JumpingJackState? isJumpingJack({
  required Pose pose,
  required JumpingJackState currentState,
}) {
  final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
  final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];
  final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
  final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];
  final nose = pose.landmarks[PoseLandmarkType.nose];

  if ([leftAnkle, rightAnkle, leftWrist, rightWrist, nose]
      .any((p) => p == null)) {
    return null;
  }

  final ankleDistance = (leftAnkle!.x - rightAnkle!.x).abs();
  final wristHeight = (leftWrist!.y + rightWrist!.y) / 2;
  final noseY = nose!.y;

  const ankleOpenThreshold = 90.0;
  const wristOpenThreshold = 60.0;

  final isOpen = ankleDistance > ankleOpenThreshold &&
      wristHeight < noseY + wristOpenThreshold;

  if (isOpen) {
    wasOpen = true;
    return JumpingJackState.init;
  } else if (wasOpen) {
    wasOpen = false;
    return JumpingJackState.complete; // ← aquí cuentas 1 jumping jack
  }

  return null;
}

FeedbackResult getJumpingJackFeedback(Pose pose) {
  final List<String> messages = [];
  final List<List<PoseLandmarkType>> badLines = [];

  final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
  final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];
  final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
  final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
  final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
  final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];
  final nose = pose.landmarks[PoseLandmarkType.nose];

  // Validación básica
  if ([
    leftWrist,
    rightWrist,
    leftShoulder,
    rightShoulder,
    leftAnkle,
    rightAnkle,
    nose
  ].any((p) => p == null)) {
    return FeedbackResult(
      messages: ['Cuerpo no detectado correctamente'],
      badLines: [],
    );
  }

  // Coordenadas
  final wristHeight = (leftWrist!.y + rightWrist!.y) / 2;
  final shoulderHeight = (leftShoulder!.y + rightShoulder!.y) / 2;
  final ankleDistance = (leftAnkle!.x - rightAnkle!.x).abs();
  final shoulderWidth = (leftShoulder.x - rightShoulder.x).abs();
  final wristDiff = (leftWrist.y - rightWrist.y).abs();
  final noseY = nose!.y;

  // --------- Feedback 1: Brazos bajos
  final armLiftRatio = (shoulderHeight - wristHeight) /
      (shoulderHeight - noseY + 1); // +1 evita división por 0
  if (armLiftRatio < 0.3) {
    messages.add('Intenta levantar más los brazos');
    badLines.add([
      PoseLandmarkType.leftWrist,
      PoseLandmarkType.leftShoulder,
    ]);
    badLines.add([
      PoseLandmarkType.rightWrist,
      PoseLandmarkType.rightShoulder,
    ]);
  }

  // --------- Feedback 2: Piernas poco abiertas
  final ankleToShoulderRatio = ankleDistance / (shoulderWidth + 1);
  if (ankleToShoulderRatio < 1.2) {
    // 1.2 veces los hombros = abierto decente
    messages.add('Abre un poco más las piernas');
    badLines.add([
      PoseLandmarkType.leftAnkle,
      PoseLandmarkType.rightAnkle,
    ]);
  }

  // --------- Feedback 3: Brazos desbalanceados
  if (wristDiff > 40) {
    messages.add('Levanta ambos brazos por igual');
    badLines.add([
      PoseLandmarkType.leftWrist,
      PoseLandmarkType.rightWrist,
    ]);
  }

  return FeedbackResult(messages: messages, badLines: badLines);
}
