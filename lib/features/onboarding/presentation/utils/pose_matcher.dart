import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Defines a target pose with specific angle and proximity constraints.
/// Defines a target pose with specific angle and proximity constraints.
class PoseTarget {
  final String name;
  final String emoji; // The symbol to display
  final IconData icon; // The icon to display
  final String description; // Short instruction
  final List<AngleConstraint> angleConstraints;
  final List<ProximityConstraint> proximityConstraints;

  PoseTarget({
    required this.name,
    required this.emoji,
    required this.icon,
    required this.description,
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
        return MatchResult(false, "Adjust your pose");
      }
    }

    // 2. Check Proximity Constraints
    if (target.proximityConstraints.isNotEmpty) {
      // Need reference distance (Face Width: Ear to Ear)
      final leftEar = pose.landmarks[PoseLandmarkType.leftEar];
      final rightEar = pose.landmarks[PoseLandmarkType.rightEar];

      if (leftEar == null || rightEar == null) {
        return MatchResult(false, "Face not fully visible");
      }

      final double faceWidth = calculateDistance(leftEar, rightEar);
      if (faceWidth == 0) return MatchResult(false, "Face not visible");

      for (var constraint in target.proximityConstraints) {
        final first = pose.landmarks[constraint.first];
        final second = pose.landmarks[constraint.second];

        if (first == null || second == null) {
          return MatchResult(false, "Hand/Face off-screen");
        }

        if (first.likelihood < 0.5 || second.likelihood < 0.5) {
          return MatchResult(false, "Low visibility of hand/face");
        }

        final double distance = calculateDistance(first, second);
        final double maxDist = faceWidth * constraint.maxNormalizedDistance;

        if (distance > maxDist) {
          debugPrint(
            'Proximity Mismatch: ${constraint.first} to ${constraint.second} is ${distance.toStringAsFixed(1)} (Max: ${maxDist.toStringAsFixed(1)} [${constraint.maxNormalizedDistance}x Face])',
          );
          return MatchResult(false, "Bring hand closer to target");
        }
      }
    }

    return MatchResult(true, "Perfect! Hold it...");
  }
}

/// A collection of predefined poses.
class PoseLibrary {
  static final List<PoseTarget> poses = [
    // 1. The Salute (🫡)
    PoseTarget(
      name: 'Salute',
      emoji: '🫡',
      icon: Icons.boy_rounded,
      description: 'Salute with your right hand',
      proximityConstraints: [
        ProximityConstraint(
          first: PoseLandmarkType.rightWrist,
          second: PoseLandmarkType.rightEye,
          maxNormalizedDistance: 3.5,
        ),
      ],
      angleConstraints: [
        AngleConstraint(
          start: PoseLandmarkType.rightShoulder,
          middle: PoseLandmarkType.rightElbow,
          end: PoseLandmarkType.rightWrist,
          minAngle: 10,
          maxAngle: 170, // Bent elbow
        ),
      ],
    ),

    // 2. Namaste / Praying (🙏)
    PoseTarget(
      name: 'Namaste',
      emoji: '🙏',
      icon: Icons.sign_language_rounded,
      description: 'Put your hands together',
      proximityConstraints: [
        // Wrists close to each other
        ProximityConstraint(
          first: PoseLandmarkType.leftWrist,
          second: PoseLandmarkType.rightWrist,
          maxNormalizedDistance: 2.0, // Close together
        ),
        // Hands near mouth/chin level
        ProximityConstraint(
          first: PoseLandmarkType.leftWrist,
          second: PoseLandmarkType.leftMouth, // Using left mouth as anchor
          maxNormalizedDistance: 4.5, // Fairly loose area near face/neck
        ),
      ],
      // No strict angle constraints, just hands together
    ),

    // 3. The Halo / Hands on Head (🙆)
    PoseTarget(
      name: 'Halo',
      emoji: '🙆',
      icon: Icons.emoji_people_rounded,
      description: 'Hands on your head',
      proximityConstraints: [
        ProximityConstraint(
          first: PoseLandmarkType.rightWrist,
          second: PoseLandmarkType.rightEar,
          maxNormalizedDistance: 3.0,
        ),
        ProximityConstraint(
          first: PoseLandmarkType.leftWrist,
          second: PoseLandmarkType.leftEar,
          maxNormalizedDistance: 3.0,
        ),
      ],
      // Elbows usually point out, but let's be lenient
    ),

    // 4. The Thinker (🤔)
    PoseTarget(
      name: 'Thinker',
      emoji: '🤔',
      icon: Icons.psychology_rounded,
      description: 'Hand on chin',
      proximityConstraints: [
        ProximityConstraint(
          first: PoseLandmarkType.rightWrist,
          second: PoseLandmarkType.rightMouth,
          maxNormalizedDistance: 3.0,
        ),
      ],
    ),

    // 5. The Flex (💪)
    PoseTarget(
      name: 'Flex',
      emoji: '💪',
      icon: Icons.fitness_center_rounded,
      description: 'Flex your right bicep',
      proximityConstraints: [
        // Wrist near Shoulder
        ProximityConstraint(
          first: PoseLandmarkType.rightWrist,
          second: PoseLandmarkType.rightShoulder,
          maxNormalizedDistance: 3.0,
        ),
      ],
      angleConstraints: [
        // Acute angle at elbow
        AngleConstraint(
          start: PoseLandmarkType.rightShoulder,
          middle: PoseLandmarkType.rightElbow,
          end: PoseLandmarkType.rightWrist,
          minAngle: 10,
          maxAngle: 90,
        ),
      ],
    ),

    // 6. The X (🙅)
    PoseTarget(
      name: 'The X',
      emoji: '🙅',
      icon: Icons.close_rounded,
      description: 'Cross your arms on your chest',
      proximityConstraints: [
        // Wrists near opposite shoulders (loosely)
        ProximityConstraint(
          first: PoseLandmarkType.leftWrist,
          second: PoseLandmarkType.rightShoulder,
          maxNormalizedDistance: 5.0, // Very lenient as forearms cross
        ),
        ProximityConstraint(
          first: PoseLandmarkType.rightWrist,
          second: PoseLandmarkType.leftShoulder,
          maxNormalizedDistance: 5.0,
        ),
        // Wrists close to each other (crossed)
        ProximityConstraint(
          first: PoseLandmarkType.leftWrist,
          second: PoseLandmarkType.rightWrist,
          maxNormalizedDistance: 4.0,
        ),
      ],
    ),
  ];

  static PoseTarget getRandomPose() {
    return poses[math.Random().nextInt(poses.length)];
  }
}
