import 'dart:math';

import 'package:flutter/material.dart';

import 'package:dot_cast/dot_cast.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart' show radians;

import 'package:elastic_dashboard/services/nt4_client.dart';
import 'package:elastic_dashboard/widgets/dialog_widgets/dialog_toggle_switch.dart';
import 'package:elastic_dashboard/widgets/nt_widgets/nt_widget.dart';

class EncoderdSwerveModel extends MultiTopicNTWidgetModel {
  @override
  String type = EncoderdSwerveDriveWidget.widgetType;

  String get frontLeftAngleTopic => '$topic/Module 0/Rotation';

  String get frontLeftEncoderAngleTopic => '$topic/Module 0/Encoder';

  String get frontRightAngleTopic => '$topic/Module 1/Rotation';

  String get frontRightEncoderAngleTopic => '$topic/Module 1/Encoder';

  String get backLeftAngleTopic => '$topic/Module 2/Rotation';

  String get backLeftEncoderAngleTopic => '$topic/Module 2/Encoder';

  String get backRightAngleTopic => '$topic/Module 3/Rotation';

  String get backRightEncoderAngleTopic => '$topic/Module 3/Encoder';

  String get robotAngleTopic => '$topic/Robot Angle';

  late NT4Subscription frontLeftAngleSubscription;
  late NT4Subscription frontLeftEncoderSubscription;
  late NT4Subscription frontRightAngleSubscription;
  late NT4Subscription frontRightEncoderSubscription;
  late NT4Subscription backLeftAngleSubscription;
  late NT4Subscription backLeftEncoderSubscription;
  late NT4Subscription backRightAngleSubscription;
  late NT4Subscription backRightEncoderSubscription;

  late NT4Subscription robotAngleSubscription;

  @override
  List<NT4Subscription> get subscriptions => [
    frontLeftAngleSubscription,
    frontLeftEncoderSubscription,
    frontRightAngleSubscription,
    frontRightEncoderSubscription,
    backLeftAngleSubscription,
    backLeftEncoderSubscription,
    backRightAngleSubscription,
    backRightEncoderSubscription,
    robotAngleSubscription,
  ];

  bool _showRobotRotation = true;

  String _rotationUnit = 'Radians';

  EncoderdSwerveModel({
    required super.ntConnection,
    required super.preferences,
    required super.topic,
    bool showRobotRotation = true,
    String rotationUnit = 'Radians',
    super.period,
  }) : _rotationUnit = rotationUnit,
       _showRobotRotation = showRobotRotation,
       super();

  EncoderdSwerveModel.fromJson({
    required super.ntConnection,
    required super.preferences,
    required Map<String, dynamic> jsonData,
  }) : super.fromJson(jsonData: jsonData) {
    _showRobotRotation = tryCast(jsonData['show_robot_rotation']) ?? true;
    _rotationUnit = tryCast(jsonData['rotation_unit']) ?? 'Degrees';
  }

  @override
  void init() {
    initSubscriptions();

    super.init();
  }

  void initSubscriptions() {
    frontLeftAngleSubscription = ntConnection.subscribe(
      frontLeftAngleTopic,
      super.period,
    );
    frontLeftEncoderSubscription = ntConnection.subscribe(
      frontLeftEncoderAngleTopic,
      super.period,
    );
    frontRightAngleSubscription = ntConnection.subscribe(
      frontRightAngleTopic,
      super.period,
    );
    frontRightEncoderSubscription = ntConnection.subscribe(
      frontRightEncoderAngleTopic,
      super.period,
    );
    backLeftAngleSubscription = ntConnection.subscribe(
      backLeftAngleTopic,
      super.period,
    );
    backLeftEncoderSubscription = ntConnection.subscribe(
      backLeftEncoderAngleTopic,
      super.period,
    );
    backRightAngleSubscription = ntConnection.subscribe(
      backRightAngleTopic,
      super.period,
    );
    backRightEncoderSubscription = ntConnection.subscribe(
      backRightEncoderAngleTopic,
      super.period,
    );

    robotAngleSubscription = ntConnection.subscribe(
      robotAngleTopic,
      super.period,
    );
  }

  @override
  void resetSubscription() {
    for (NT4Subscription subscription in subscriptions) {
      ntConnection.unSubscribe(subscription);
    }

    initSubscriptions();

    super.resetSubscription();
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'show_robot_rotation': _showRobotRotation,
    'rotation_unit': _rotationUnit,
  };

  @override
  List<Widget> getEditProperties(BuildContext context) => [
    Center(
      child: DialogToggleSwitch(
        initialValue: _showRobotRotation,
        label: 'Show Robot Rotation',
        onToggle: (value) {
          showRobotRotation = value;
        },
      ),
    ),
    const SizedBox(height: 5),
    const Text('Rotation Unit'),
    StatefulBuilder(
      builder: (context, setState) => RadioGroup<String>(
        groupValue: _rotationUnit,
        onChanged: (value) {
          if (value != null) {
            rotationUnit = value;
          }
          setState(() {});
        },
        child: Column(
          children: [
            ListTile(
              title: const Text('Radians'),
              dense: true,
              leading: Radio<String>(value: 'Radians'),
            ),
            ListTile(
              title: const Text('Degrees'),
              dense: true,
              leading: Radio<String>(value: 'Degrees'),
            ),
            ListTile(
              title: const Text('Rotations'),
              dense: true,
              leading: Radio<String>(value: 'Rotations'),
            ),
          ],
        ),
      ),
    ),
  ];

  bool get showRobotRotation => _showRobotRotation;

  set showRobotRotation(bool value) {
    _showRobotRotation = value;
    refresh();
  }

  String get rotationUnit => _rotationUnit;

  set rotationUnit(String value) {
    _rotationUnit = value;
    refresh();
  }
}

class EncoderdSwerveDriveWidget extends NTWidget {
  static const String widgetType = 'EncoderdSwerveDrive';

  const EncoderdSwerveDriveWidget({super.key}) : super();

  @override
  Widget build(BuildContext context) {
    EncoderdSwerveModel model = cast(context.watch<NTWidgetModel>());

    return ListenableBuilder(
      listenable: Listenable.merge(model.subscriptions),
      builder: (context, child) {
        double frontLeftAngle =
            tryCast(model.frontLeftAngleSubscription.value) ?? 0.0;

        double frontRightAngle =
            tryCast(model.frontRightAngleSubscription.value) ?? 0.0;

        double backLeftAngle =
            tryCast(model.backLeftAngleSubscription.value) ?? 0.0;

        double backRightAngle =
            tryCast(model.backRightAngleSubscription.value) ?? 0.0;

        double encoderdFrontLeftAngle =
            tryCast(model.frontLeftEncoderSubscription.value) ?? 0.0;

        double encoderdFrontRightAngle =
            tryCast(model.frontRightEncoderSubscription.value) ?? 0.0;

        double encoderdBackLeftAngle =
            tryCast(model.backLeftEncoderSubscription.value) ?? 0.0;

        double encoderdBackRightAngle =
            tryCast(model.backRightEncoderSubscription.value) ?? 0.0;

        double robotAngle = tryCast(model.robotAngleSubscription.value) ?? 0.0;

        if (model.rotationUnit == 'Degrees') {
          frontLeftAngle = radians(frontLeftAngle);
          frontRightAngle = radians(frontRightAngle);
          backLeftAngle = radians(backLeftAngle);
          backRightAngle = radians(backRightAngle);

          encoderdFrontLeftAngle = radians(encoderdFrontLeftAngle);
          encoderdFrontRightAngle = radians(encoderdFrontRightAngle);
          encoderdBackLeftAngle = radians(encoderdBackLeftAngle);
          encoderdBackRightAngle = radians(encoderdBackRightAngle);

          robotAngle = radians(robotAngle);
        } else if (model.rotationUnit == 'Rotations') {
          frontLeftAngle *= 2 * pi;
          frontRightAngle *= 2 * pi;
          backLeftAngle *= 2 * pi;
          backRightAngle *= 2 * pi;
          encoderdFrontLeftAngle *= 2 * pi;
          encoderdFrontRightAngle *= 2 * pi;
          encoderdBackLeftAngle *= 2 * pi;
          encoderdBackRightAngle *= 2 * pi;

          robotAngle *= 2 * pi;
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            double sideLength =
                min(constraints.maxWidth, constraints.maxHeight) * 0.9;
            return Transform.rotate(
              angle: (model.showRobotRotation) ? -robotAngle : 0.0,
              child: SizedBox(
                width: sideLength,
                height: sideLength,
                child: CustomPaint(
                  painter: SwerveDrivePainter(
                    frontLeftAngle: frontLeftAngle,
                    frontLeftEncoder: encoderdFrontLeftAngle,
                    frontRightAngle: frontRightAngle,
                    frontRightEncoder: encoderdFrontRightAngle,
                    backLeftAngle: backLeftAngle,
                    backLeftEncoder: encoderdBackLeftAngle,
                    backRightAngle: backRightAngle,
                    backRightEncoder: encoderdBackRightAngle,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class SwerveDrivePainter extends CustomPainter {
  final double frontLeftAngle;
  final double frontLeftEncoder;

  final double frontRightAngle;
  final double frontRightEncoder;

  final double backLeftAngle;
  final double backLeftEncoder;

  final double backRightAngle;
  final double backRightEncoder;

  const SwerveDrivePainter({
    required this.frontLeftAngle,
    required this.frontLeftEncoder,
    required this.frontRightAngle,
    required this.frontRightEncoder,
    required this.backLeftAngle,
    required this.backLeftEncoder,
    required this.backRightAngle,
    required this.backRightEncoder,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double robotFrameScale = 0.75;
    const double arrowScale = robotFrameScale * 0.45;

    drawRobotFrame(
      canvas,
      size * robotFrameScale,
      Offset(
            size.width - size.width * robotFrameScale,
            size.height - size.height * robotFrameScale,
          ) /
          2,
    );

    drawRobotDirectionArrow(
      canvas,
      size * arrowScale,
      Offset(
            size.width - size.width * arrowScale,
            size.height - size.height * arrowScale,
          ) /
          2,
    );

    drawMotionArrows(
      canvas,
      size * robotFrameScale,
      Offset(
            size.width - size.width * robotFrameScale,
            size.height - size.height * robotFrameScale,
          ) /
          2,
    );
  }

  void drawRobotFrame(Canvas canvas, Size size, Offset offset) {
    final double scaleFactor = size.width / 128.95 / 0.9;
    final double circleRadius = min(size.width, size.height) / 8;

    Paint framePainter = Paint()
      ..strokeWidth = 1.75 * scaleFactor
      ..color = Colors.grey
      ..style = PaintingStyle.stroke;

    // Front left circle
    canvas.drawCircle(
      Offset(circleRadius, circleRadius) + offset,
      circleRadius,
      framePainter,
    );

    // Front right circle
    canvas.drawCircle(
      Offset(size.width - circleRadius, circleRadius) + offset,
      circleRadius,
      framePainter,
    );

    // Back left circle
    canvas.drawCircle(
      Offset(circleRadius, size.height - circleRadius) + offset,
      circleRadius,
      framePainter,
    );

    // Back right circle
    canvas.drawCircle(
      Offset(
        offset.dx + size.width - circleRadius,
        offset.dy + size.height - circleRadius,
      ),
      circleRadius,
      framePainter,
    );

    // Top line
    canvas.drawLine(
      Offset(circleRadius * 2, circleRadius) + offset,
      Offset(size.width - circleRadius * 2, circleRadius) + offset,
      framePainter,
    );

    // Right line
    canvas.drawLine(
      Offset(size.width - circleRadius, circleRadius * 2) + offset,
      Offset(size.width - circleRadius, size.height - circleRadius * 2) +
          offset,
      framePainter,
    );

    // Bottom line
    canvas.drawLine(
      Offset(circleRadius * 2, size.height - circleRadius) + offset,
      Offset(size.width - circleRadius * 2, size.height - circleRadius) +
          offset,
      framePainter,
    );

    // Left line
    canvas.drawLine(
      Offset(circleRadius, circleRadius * 2) + offset,
      Offset(circleRadius, size.height - circleRadius * 2) + offset,
      framePainter,
    );
  }

  void drawMotionArrows(Canvas canvas, Size size, Offset offset) {
    final double circleRadius = min(size.width, size.height) / 8;

    final double scaleFactor = size.width / 128.95 / 0.9;

    Paint anglePaint = Paint()
      ..strokeWidth = 3.5 * scaleFactor
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Front left angle indicator thing
    Rect frontLeftWheel = Rect.fromCenter(
      center: Offset(circleRadius, circleRadius) + offset,
      width: circleRadius * 2,
      height: circleRadius * 2,
    );

    canvas.drawArc(
      frontLeftWheel,
      -(frontLeftAngle + radians(22.5)) - pi / 2,
      radians(45),
      false,
      anglePaint,
    );

    // Front right angle indicator thing
    Rect frontRightWheel = Rect.fromCenter(
      center: Offset(size.width - circleRadius, circleRadius) + offset,
      width: circleRadius * 2,
      height: circleRadius * 2,
    );

    canvas.drawArc(
      frontRightWheel,
      -(frontRightAngle + radians(22.5)) - pi / 2,
      radians(45),
      false,
      anglePaint,
    );
    // Back left angle indicator thing
    Rect backLeftWheel = Rect.fromCenter(
      center: Offset(circleRadius, size.height - circleRadius) + offset,
      width: circleRadius * 2,
      height: circleRadius * 2,
    );

    canvas.drawArc(
      backLeftWheel,
      -(backLeftAngle + radians(22.5)) - pi / 2,
      radians(45),
      false,
      anglePaint,
    );

    // Back right angle indicator thing
    Rect backRightWheel = Rect.fromCenter(
      center:
          Offset(size.width - circleRadius, size.height - circleRadius) +
          offset,
      width: circleRadius * 2,
      height: circleRadius * 2,
    );

    canvas.drawArc(
      backRightWheel,
      -(backRightAngle + radians(22.5)) - pi / 2,
      radians(45),
      false,
      anglePaint,
    );
  }

  void drawRobotDirectionArrow(Canvas canvas, Size size, Offset offset) {
    final double scaleFactor = size.width / 58.0 / 0.9;

    const double arrowAngle = 40 * pi / 180;
    final double base = size.width * 0.45;
    const double arrowRotation = -pi / 2;
    const double tipX = 0;
    final double tipY = -size.height / 2;

    Offset center = Offset(size.width, size.height) / 2 + offset;

    Paint arrowPainter = Paint()
      ..strokeWidth = 3.5 * scaleFactor
      ..color = Colors.red
      ..style = PaintingStyle.stroke;

    Path arrowHead = Path()
      ..moveTo(
        center.dx + tipX - base * cos(arrowRotation - arrowAngle),
        center.dy + tipY - base * sin(arrowRotation - arrowAngle),
      )
      ..lineTo(center.dx + tipX, center.dy + tipY)
      ..lineTo(
        center.dx + tipX - base * cos(arrowRotation + arrowAngle),
        center.dy + tipY - base * sin(arrowRotation + arrowAngle),
      );

    canvas.drawPath(arrowHead, arrowPainter);
    canvas.drawLine(
      Offset(tipX, tipY) + center,
      Offset(tipX, -tipY) + center,
      arrowPainter,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
