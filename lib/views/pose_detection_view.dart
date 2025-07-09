import 'package:camera/camera.dart';
import 'package:ezgym/models/exercise.dart';
import 'package:ezgym/models/push_up_model.dart';
import 'package:ezgym/utils.dart' as utils;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../painters/pose_painter.dart';
import 'detector_view.dart';

class PoseDetectorView extends StatefulWidget {
  final Exercise? exercise;
  const PoseDetectorView({super.key, this.exercise});
  @override
  State<StatefulWidget> createState() => _PoseDetectorViewState();
}

class _PoseDetectorViewState extends State<PoseDetectorView> {
  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  PosePainter? _posePainter;

  var _cameraLensDirection = CameraLensDirection.back;
  @override
  void initState() {
    super.initState();
    BlocProvider.of<PushUpCounter>(context).reset(); //  Reinicia el contador
  }

  @override
  void dispose() async {
    _canProcess = false;
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DetectorView(
      posePainter: _posePainter,
      title: 'Pose Detector',
      customPaint: _customPaint,
      text: _text,
      onImage: _processImage,
      initialCameraLensDirection: _cameraLensDirection,
      onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
      exercise: widget.exercise,
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final poses = await _poseDetector.processImage(inputImage);
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      List<List<PoseLandmarkType>> allBadLines = [];
      for (final pose in poses) {
        final result = utils.getPushUpFeedback(pose);
        allBadLines.addAll(result.badLines);
      }

      final painter = PosePainter(
        poses,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
        allBadLines,
      );

      _customPaint = CustomPaint(painter: painter);
      _posePainter = painter;
    } else {
      _text = 'Poses found: ${poses.length}\n\n';
      // TODO: set _customPaint to draw landmarks on top of image
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
