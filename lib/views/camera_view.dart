import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:ezgym/models/exercise.dart';
import 'package:ezgym/models/squat_counter.dart';
import 'package:ezgym/models/workoutSessionModel.dart';
import 'package:ezgym/screens/workout_history_screen.dart';
import 'package:ezgym/util/n21_convertor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/push_up_model.dart';
import '../painters/pose_painter.dart';
import '../utils.dart' as utils;

class CameraView extends StatefulWidget {
  const CameraView(
      {super.key,
      required this.posePainter,
      required this.customPaint,
      required this.onImage,
      this.onCameraFeedReady,
      this.onDetectorViewModeChanged,
      this.onCameraLensDirectionChanged,
      this.exercise,
      this.initialCameraLensDirection = CameraLensDirection.back});
  final PosePainter? posePainter;
  final CustomPaint? customPaint;
  final Function(InputImage inputImage) onImage;
  final VoidCallback? onCameraFeedReady;
  final VoidCallback? onDetectorViewModeChanged;
  final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;
  final CameraLensDirection initialCameraLensDirection;
  final Exercise? exercise;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  String? _feedbackMessage;
  Timer? _feedbackTimer;

  DateTime? _startTime;
  final int staticReps = 2;
  bool _sessionCompleted = false;
  bool _canProcess = true;
  final AudioPlayer _audioPlayer = AudioPlayer();
  static List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _cameraIndex = -1;
  double _currentZoomLevel = 1.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;
  bool _changingCameraLens = false;

  PoseLandmark? p1;
  PoseLandmark? p2;
  PoseLandmark? p3;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _initialize();
  }

  void _initialize() async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }
    for (var i = 0; i < _cameras.length; i++) {
      if (_cameras[i].lensDirection == widget.initialCameraLensDirection) {
        _cameraIndex = i;
        break;
      }
    }
    if (_cameraIndex != -1) {
      _startLiveFeed();
    }
  }

  @override
  void didUpdateWidget(covariant CameraView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_sessionCompleted) return;
    if (widget.customPaint != oldWidget.customPaint) {
      print('[DEBUG] CustomPaint changed, checking poses');

      final bloc = BlocProvider.of<PushUpCounter>(context);

      if (widget.posePainter == null || widget.posePainter!.poses.isEmpty) {
        print('[DEBUG] No poses found');
        return;
      }

      for (final pose in widget.posePainter!.poses) {
        print('[DEBUG] Processing pose...');

        try {
          final rs = pose.landmarks[PoseLandmarkType.rightShoulder];
          final re = pose.landmarks[PoseLandmarkType.rightElbow];
          final rw = pose.landmarks[PoseLandmarkType.rightWrist];

          final ls = pose.landmarks[PoseLandmarkType.leftShoulder];
          final le = pose.landmarks[PoseLandmarkType.leftElbow];
          final lw = pose.landmarks[PoseLandmarkType.leftWrist];

          if (rs == null ||
              re == null ||
              rw == null ||
              ls == null ||
              le == null ||
              lw == null) {
            print('[DEBUG] Missing landmarks');
            return;
          }

          final rightAngle = utils.angle(rs, re, rw);
          final leftAngle = utils.angle(ls, le, lw);

          print('[DEBUG] Right elbow angle: ${rightAngle.toStringAsFixed(2)}');
          print('[DEBUG] Left elbow angle: ${leftAngle.toStringAsFixed(2)}');

          final name = widget.exercise?.name?.toLowerCase() ?? '';
          if (name.contains('push up')) {
            final pushBloc = BlocProvider.of<PushUpCounter>(context);
            final newState =
                utils.isPushUp(rightAngle, leftAngle, pushBloc.state.state);

            if (newState != null) {
              if (newState == PushUpState.init &&
                  pushBloc.state.state == PushUpState.neutral) {
                pushBloc.setPushUpState(PushUpState.init);
                print('[DEBUG] -> Estado INIT reconocido');
              } else if (newState == PushUpState.complete &&
                  pushBloc.state.state == PushUpState.init) {
                pushBloc.increment();
                _audioPlayer
                    .play(AssetSource('sounds/counter_up_complete.wav'));
                pushBloc.setPushUpState(PushUpState.neutral);
                print(
                    '[DEBUG] -> Contador incrementado: ${pushBloc.state.counter}');

                final exerciseReps = widget.exercise?.reps ?? staticReps;
                print('[DEBUG] -> REPS: $exerciseReps');
                if (pushBloc.state.counter >= exerciseReps) {
                  guardarYMostrarDialogo(pushBloc.state.counter);
                }
              }
            }

            final utils.FeedbackResult result = utils.getPushUpFeedback(pose);
            final List<String> feedback = result.messages;
            if (feedback.isNotEmpty) {
              final message = feedback.join('\n');

              _feedbackTimer?.cancel();
              _feedbackTimer = Timer(const Duration(seconds: 1), () {
                if (mounted) {
                  setState(() {
                    _feedbackMessage = null;
                  });
                }
              });

              if (_feedbackMessage != message) {
                setState(() {
                  _feedbackMessage = message;
                });
              }
            }
          } else if (name.contains('squat')) {
            final squatBloc = BlocProvider.of<SquatCounter>(context);
            final hip = pose.landmarks[PoseLandmarkType.rightHip];
            final knee = pose.landmarks[PoseLandmarkType.rightKnee];
            final ankle = pose.landmarks[PoseLandmarkType.rightAnkle];

            if (hip != null && knee != null && ankle != null) {
              final squatAngle = utils.angle(hip, knee, ankle);
              final newSquatState =
                  utils.isSquat(squatAngle, squatBloc.state.state);
              if (newSquatState == SquatState.init &&
                  squatBloc.state.state == SquatState.neutral) {
                squatBloc.setSquatState(SquatState.init);
              } else if (newSquatState == SquatState.complete &&
                  squatBloc.state.state == SquatState.init) {
                squatBloc.increment();
                _audioPlayer
                    .play(AssetSource('sounds/counter_up_complete.wav'));
                squatBloc.setSquatState(SquatState.neutral);

                if (squatBloc.state.counter >=
                    (widget.exercise?.reps ?? staticReps)) {
                  guardarYMostrarDialogo(squatBloc.state.counter);
                }
              }
            }

            final utils.FeedbackResult result = utils.getSquatFeedback(pose);
            final List<String> feedback = result.messages;
            if (feedback.isNotEmpty) {
              final message = feedback.join('\n');

              _feedbackTimer?.cancel();
              _feedbackTimer = Timer(const Duration(seconds: 1), () {
                if (mounted) {
                  setState(() {
                    _feedbackMessage = null;
                  });
                }
              });

              if (_feedbackMessage != message) {
                setState(() {
                  _feedbackMessage = message;
                });
              }
            }
          }
        } catch (e) {
          print('[ERROR] Failed to process pose: $e');
        }
      }
    }
  }

  void guardarYMostrarDialogo(int counterFinal) async {
    _sessionCompleted = true;
    final endTime = DateTime.now();
    final duration = endTime.difference(_startTime!);

    final session = WorkoutSession(
      exerciseId: widget.exercise?.sId ?? '',
      exercise: widget.exercise?.name ?? '',
      reps: counterFinal,
      startTime: _startTime!,
      endTime: endTime,
      user: "X",
    );

    final prefs = await SharedPreferences.getInstance();
    final historyString = prefs.getString('history');
    List<dynamic> history =
        historyString != null ? jsonDecode(historyString) : [];
    history.add(session.toJson());
    await prefs.setString('history', jsonEncode(history));

    final minutos = duration.inMinutes.toString().padLeft(2, '0');
    final segundos = (duration.inSeconds % 60).toString().padLeft(2, '0');

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false, // para que no se cierre tocando fuera
      builder: (_) => AlertDialog(
        title: const Text('¡Rutina completada!'),
        content: Text(
          'Completaste $counterFinal repeticiones en $minutos:$segundos minutos.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el diálogo
              Navigator.of(context).pop(); // Regresa a la pantalla anterior
            },
            child: const Text('Volver'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el diálogo
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const WorkoutHistoryScreen()),
              );
            },
            child: const Text('Ver historial'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _stopLiveFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _liveFeedBody());
  }

  Widget _liveFeedBody() {
    if (_cameras.isEmpty) return Container();
    if (_controller == null) return Container();
    if (_controller?.value.isInitialized == false) return Container();
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: _changingCameraLens
                ? Center(
                    child: const Text('Changing camera lens'),
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      CameraPreview(_controller!),
                      if (widget.customPaint != null)
                        RepaintBoundary(
                          child: widget.customPaint!,
                        ),
                    ],
                  ),
          ),
          _counterWidget(),
          _backButton(),
          _switchLiveCameraToggle(),
          _detectionViewModeToggle(),
          _zoomControl(),
          _exposureControl(),
          if (_feedbackMessage != null)
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        _feedbackMessage!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _counterWidget() {
    final name = widget.exercise?.name?.toLowerCase() ?? '';

    if (name.contains('squat')) {
      return BlocBuilder<SquatCounter, SquatStatus>(
        builder: (context, state) {
          return _buildCounterWidget(state.counter);
        },
      );
    } else {
      return BlocBuilder<PushUpCounter, PushUpStatus>(
        builder: (context, state) {
          return _buildCounterWidget(state.counter);
        },
      );
    }
  }

  Widget _buildCounterWidget(int counter) {
    return Positioned(
      top: 50,
      left: 0,
      right: 0,
      child: Column(
        children: [
          const Text(
            'Counter',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: Colors.white.withOpacity(0.4), width: 4),
            ),
            child: Text(
              '$counter',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _backButton() => Positioned(
        top: 40,
        left: 8,
        child: SizedBox(
          height: 50.0,
          width: 50.0,
          child: FloatingActionButton(
            heroTag: Object(),
            onPressed: () {
              BlocProvider.of<PushUpCounter>(context).reset();
              Navigator.of(context).pop();
            },
            backgroundColor: Colors.black54,
            child: Icon(
              Icons.arrow_back_ios_outlined,
              size: 20,
            ),
          ),
        ),
      );

  Widget _detectionViewModeToggle() => Positioned(
        bottom: 8,
        left: 8,
        child: SizedBox(
          height: 50.0,
          width: 50.0,
          child: FloatingActionButton(
            heroTag: Object(),
            onPressed: widget.onDetectorViewModeChanged,
            backgroundColor: Colors.black54,
            child: Icon(
              Icons.photo_library_outlined,
              size: 25,
            ),
          ),
        ),
      );

  Widget _switchLiveCameraToggle() => Positioned(
        bottom: 8,
        right: 8,
        child: SizedBox(
          height: 50.0,
          width: 50.0,
          child: FloatingActionButton(
            heroTag: Object(),
            onPressed: _switchLiveCamera,
            backgroundColor: Colors.black54,
            child: Icon(
              Platform.isIOS
                  ? Icons.flip_camera_ios_outlined
                  : Icons.flip_camera_android_outlined,
              size: 25,
            ),
          ),
        ),
      );

  Widget _zoomControl() => Positioned(
        bottom: 16,
        left: 0,
        right: 0,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: 250,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Slider(
                    value: _currentZoomLevel,
                    min: _minAvailableZoom,
                    max: _maxAvailableZoom,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white30,
                    onChanged: (value) async {
                      setState(() {
                        _currentZoomLevel = value;
                      });
                      await _controller?.setZoomLevel(value);
                    },
                  ),
                ),
                Container(
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        '${_currentZoomLevel.toStringAsFixed(1)}x',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _exposureControl() => Positioned(
        top: 40,
        right: 8,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 250,
          ),
          child: Column(children: [
            Container(
              width: 55,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    '${_currentExposureOffset.toStringAsFixed(1)}x',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            Expanded(
              child: RotatedBox(
                quarterTurns: 3,
                child: SizedBox(
                  height: 30,
                  child: Slider(
                    value: _currentExposureOffset,
                    min: _minAvailableExposureOffset,
                    max: _maxAvailableExposureOffset,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white30,
                    onChanged: (value) async {
                      setState(() {
                        _currentExposureOffset = value;
                      });
                      await _controller?.setExposureOffset(value);
                    },
                  ),
                ),
              ),
            )
          ]),
        ),
      );

  Future _startLiveFeed() async {
    final camera = _cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      // Set to ResolutionPreset.high. Do NOT set it to ResolutionPreset.max because for some phones does NOT work.
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller?.getMinZoomLevel().then((value) {
        _currentZoomLevel = value;
        _minAvailableZoom = value;
      });
      _controller?.getMaxZoomLevel().then((value) {
        _maxAvailableZoom = value;
      });
      _currentExposureOffset = 0.0;
      _controller?.getMinExposureOffset().then((value) {
        _minAvailableExposureOffset = value;
      });
      _controller?.getMaxExposureOffset().then((value) {
        _maxAvailableExposureOffset = value;
      });
      _controller?.startImageStream(_processCameraImage).then((value) {
        if (widget.onCameraFeedReady != null) {
          widget.onCameraFeedReady!();
        }
        if (widget.onCameraLensDirectionChanged != null) {
          widget.onCameraLensDirectionChanged!(camera.lensDirection);
        }
      });
      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  Future _switchLiveCamera() async {
    setState(() => _changingCameraLens = true);
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;

    await _stopLiveFeed();
    await _startLiveFeed();
    setState(() => _changingCameraLens = false);
  }

  void _processCameraImage(CameraImage image) {
    if (!_canProcess) return;
    _canProcess = false;

    Future.delayed(const Duration(milliseconds: 100), () {
      _canProcess = true;
    });

    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;
    widget.onImage(inputImage);
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) {
      print('Controller is null');
      return null;
    }

    final camera = _cameras[_cameraIndex];
    final sensorOrientation = camera.sensorOrientation;
    // print(
    //     'Camera lensDirection: ${camera.lensDirection}, sensorOrientation: $sensorOrientation');

    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
      print('iOS rotation: $rotation');
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) {
        print('rotationCompensation is null');
        return null;
      }

      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
      // print(
      //     'Android rotationCompensation: $rotationCompensation, final rotation: $rotation');
    }

    if (rotation == null) {
      print('Rotation is null');
      return null;
    }

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    //print('Raw format: ${image.format.raw}, interpreted format: $format');

    if (format == null ||
        (Platform.isAndroid &&
            format != InputImageFormat.nv21 &&
            format != InputImageFormat.yuv_420_888) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) {
      print('Unsupported image format: $format');
      return null;
    }

// solo hacer este chequeo para formatos de un solo plano
    if ((format == InputImageFormat.nv21 ||
            format == InputImageFormat.bgra8888) &&
        image.planes.length != 1) {
      print(
          'Expected 1 plane for format $format but got ${image.planes.length}');
      return null;
    }

// Usa el convertidor si es yuv_420_888
    Uint8List bytes;
    if (format == InputImageFormat.yuv_420_888) {
      bytes = image.getNv21Uint8List();
      // print('Converted YUV_420_888 to NV21, byte length: ${bytes.length}');
    } else {
      bytes = image.planes.first.bytes;
    }

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }
}
