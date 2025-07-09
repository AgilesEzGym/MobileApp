import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'coordinates_translator.dart';

class PosePainter extends CustomPainter {
  PosePainter(
    this.poses,
    this.imageSize,
    this.rotation,
    this.cameraLensDirection,
    this.badLines,
  );

  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;
  final List<List<PoseLandmarkType>> badLines;

  @override
  void paint(Canvas canvas, Size size) {
    final pointPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.green;

    final leftPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.yellow;

    final rightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.blueAccent;

    final errorPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.red;

    for (final pose in poses) {
      // Dibuja los puntos articulares
      pose.landmarks.forEach((_, landmark) {
        canvas.drawCircle(
            Offset(
              translateX(
                landmark.x,
                size,
                imageSize,
                rotation,
                cameraLensDirection,
              ),
              translateY(
                landmark.y,
                size,
                imageSize,
                rotation,
                cameraLensDirection,
              ),
            ),
            1,
            pointPaint);
      });

      void paintLine(
        PoseLandmarkType type1,
        PoseLandmarkType type2,
        Paint defaultPaint,
      ) {
        final PoseLandmark? joint1 = pose.landmarks[type1];
        final PoseLandmark? joint2 = pose.landmarks[type2];

        if (joint1 == null || joint2 == null) return;

        final lineKey = [type1, type2];
        final lineKeyAlt = [type2, type1];

        final isBad = badLines.any((bad) =>
            (bad[0] == lineKey[0] && bad[1] == lineKey[1]) ||
            (bad[0] == lineKeyAlt[0] && bad[1] == lineKeyAlt[1]));

        final paintToUse = isBad ? errorPaint : defaultPaint;

        canvas.drawLine(
            Offset(
              translateX(
                  joint1.x, size, imageSize, rotation, cameraLensDirection),
              translateY(
                  joint1.y, size, imageSize, rotation, cameraLensDirection),
            ),
            Offset(
              translateX(
                  joint2.x, size, imageSize, rotation, cameraLensDirection),
              translateY(
                  joint2.y, size, imageSize, rotation, cameraLensDirection),
            ),
            paintToUse);
      }

      // Brazo izquierdo
      paintLine(
          PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, leftPaint);
      paintLine(
          PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, leftPaint);

      // Brazo derecho
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow,
          rightPaint);
      paintLine(
          PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, rightPaint);

      // Tronco
      paintLine(
          PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, leftPaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip,
          rightPaint);

      // Pierna izquierda
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, leftPaint);
      paintLine(
          PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, leftPaint);

      // Pierna derecha
      paintLine(
          PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, rightPaint);
      paintLine(
          PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, rightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    if (oldDelegate.imageSize != imageSize) return true;
    if (oldDelegate.poses.length != poses.length) return true;
    for (int i = 0; i < poses.length; i++) {
      if (oldDelegate.poses[i] != poses[i]) return true;
    }
    return false;
  }
}
