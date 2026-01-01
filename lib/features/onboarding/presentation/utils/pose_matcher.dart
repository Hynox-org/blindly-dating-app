import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Defines a target pose with specific angle and proximity constraints.
class PoseTarget {
  final String name;
  final String description;
  final String assetPath; // Placeholder for now, useful for UI
  final List<AngleConstraint> angleConstraints;
  final List<ProximityConstraint> proximityConstraints;

  PoseTarget({
    required this.name,
    required this.description,
    required this.assetPath,
    this.angleConstraints = const [],
    this.proximityConstraints = const [],
  });
}

/// Defines a constraint for an angle formed by 3 landmarks.
class AngleConstraint {
  final PoseLandmarkType start;
  final PoseLandmarkType middle;
  final PoseLandmarkType end;
  final double minAngle;
  final double maxAngle;

  AngleConstraint({
    required this.start,
    required this.middle,
    required this.end,
    required this.minAngle,
    required this.maxAngle,
  });
}

/// Defines a constraint for the specific distance between two landmarks.
/// The distance is normalized by the distance between ears (face width)
/// to account for the user's distance from the camera.
class ProximityConstraint {
  final PoseLandmarkType first;
  final PoseLandmarkType second;
  final double maxNormalizedDistance; // Multiplier of face width

  ProximityConstraint({
    required this.first,
    required this.second,
    this.maxNormalizedDistance = 2.0, // Default generous tolerance
  });
}

class MatchResult {
  final bool isMatch;
  final String feedback;

  MatchResult(this.isMatch, this.feedback);
}

class PoseMatcher {
  /// Calculates the angle (in degrees) at point B formed by points A, B, and C.
  static double calculateAngle(
    PoseLandmark first,
    PoseLandmark middle,
    PoseLandmark last,
  ) {
    double radians =
        math.atan2(last.y - middle.y, last.x - middle.x) -
        math.atan2(first.y - middle.y, first.x - middle.x);
    double degrees = radians * 180.0 / math.pi;
    degrees = degrees.abs(); // Angle should be positive
    if (degrees > 180.0) {
      degrees = 360.0 - degrees; // Always get the smaller angle
    }
    return degrees;
  }

  static double calculateDistance(PoseLandmark a, PoseLandmark b) {
    return math.sqrt(math.pow(a.x - b.x, 2) + math.pow(a.y - b.y, 2));
  }

  /// Checks if the detected [pose] matches the [target] within the constraints.
  static MatchResult isPoseMatching(Pose pose, PoseTarget target) {
    if (pose.landmarks.isEmpty) return MatchResult(false, "No body detected");

    // 1. Check Angle Constraints
    for (var constraint in target.angleConstraints) {
      final first = pose.landmarks[constraint.start];
      final middle = pose.landmarks[constraint.middle];
      final last = pose.landmarks[constraint.end];

      if (first == null || middle == null || last == null) {
        return MatchResult(false, "Partially off-screen");
      }
      if (first.likelihood < 0.5 ||
          middle.likelihood < 0.5 ||
          last.likelihood < 0.5) {
        return MatchResult(false, "Lighting/Visibility poor");
      }

      final double angle = calculateAngle(first, middle, last);
      if (angle < constraint.minAngle || angle > constraint.maxAngle) {
        debugPrint(
          'Angle Mismatch: ${constraint.middle} is ${angle.toStringAsFixed(1)} (Target: ${constraint.minAngle}-${constraint.maxAngle})',
        );
        return MatchResult(false, "Adjust arm angle");
      }
    }

    // 2. Check Proximity Constraints
    if (target.proximityConstraints.isNotEmpty) {
      // Need reference distance (Face Width: Ear to Ear)
      final leftEar = pose.landmarks[PoseLandmarkType.leftEar];
      final rightEar = pose.landmarks[PoseLandmarkType.rightEar];

      if (leftEar == null || rightEar == null)
        return MatchResult(false, "Face not fully visible");

      final double faceWidth = calculateDistance(leftEar, rightEar);
      if (faceWidth == 0) return MatchResult(false, "Face not visible");

      for (var constraint in target.proximityConstraints) {
        final first = pose.landmarks[constraint.first];
        final second = pose.landmarks[constraint.second];

        if (first == null || second == null)
          return MatchResult(false, "Hand/Face off-screen");

        if (first.likelihood < 0.5 || second.likelihood < 0.5) {
          return MatchResult(false, "Low visibility of hand/face");
        }

        final double distance = calculateDistance(first, second);
        final double maxDist = faceWidth * constraint.maxNormalizedDistance;

        if (distance > maxDist) {
          debugPrint(
            'Proximity Mismatch: ${constraint.first} to ${constraint.second} is ${distance.toStringAsFixed(1)} (Max: ${maxDist.toStringAsFixed(1)} [${constraint.maxNormalizedDistance}x Face])',
          );
          return MatchResult(false, "Move hand closer to target");
        }
      }
    }

    return MatchResult(true, "Perfect! Hold it...");
  }
}

/// A collection of predefined poses.
class PoseLibrary {
  static final List<PoseTarget> poses = [
    // 1. Salute (Right hand to Right Eye area)
    PoseTarget(
      name: 'The Salute',
      description: 'Bring your right hand to your forehead.',
      assetPath: 'assets/poses/salute_right.png',
      proximityConstraints: [
        ProximityConstraint(
          first: PoseLandmarkType.rightWrist,
          second: PoseLandmarkType.rightEye,
          maxNormalizedDistance: 3.0, // Minimal constraint
        ),
      ],
      angleConstraints: [
        // Elbow bent - almost any bend accepted
        AngleConstraint(
          start: PoseLandmarkType.rightShoulder,
          middle: PoseLandmarkType.rightElbow,
          end: PoseLandmarkType.rightWrist,
          minAngle: 5,
          maxAngle: 175,
        ),
      ],
    ),

    // 2. The Thinker (Hand to Chin)
    PoseTarget(
      name: 'The Thinker',
      description: 'Place your hand on your chin.',
      assetPath: 'assets/poses/thinker.png',
      proximityConstraints: [
        ProximityConstraint(
          first: PoseLandmarkType.rightWrist,
          second: PoseLandmarkType.rightMouth,
          maxNormalizedDistance: 3.0, // Minimal constraint
        ),
      ],
      angleConstraints: [
        AngleConstraint(
          start: PoseLandmarkType.rightShoulder,
          middle: PoseLandmarkType.rightElbow,
          end: PoseLandmarkType.rightWrist,
          minAngle: 5,
          maxAngle: 175,
        ),
      ],
    ),

    // 3. Listen Up (Hand to Ear)
    PoseTarget(
      name: 'Listen Up',
      description: 'Cup your left hand to your left ear.',
      assetPath: 'assets/poses/listen_left.png',
      proximityConstraints: [
        ProximityConstraint(
          first: PoseLandmarkType.leftWrist,
          second: PoseLandmarkType.leftEar,
          maxNormalizedDistance: 3.0, // Minimal constraint
        ),
      ],
      angleConstraints: [
        AngleConstraint(
          start: PoseLandmarkType.leftShoulder,
          middle: PoseLandmarkType.leftElbow,
          end: PoseLandmarkType.leftWrist,
          minAngle: 5,
          maxAngle: 175,
        ),
      ],
    ),
  ];

  static PoseTarget getRandomPose() {
    return poses[math.Random().nextInt(poses.length)];
  }
}
