import 'base_config.dart';

/// Sealed class for image answer size configurations.
///
/// Defines the display size and spacing for image-based answer options.
sealed class ImageAnswerSize extends BaseConfig {
  const ImageAnswerSize();

  /// Maximum size (width/height) of the image in logical pixels.
  double get maxSize;

  /// Spacing between image options in logical pixels.
  double get spacing;

  /// Optional aspect ratio constraint (width/height).
  /// If null, images maintain their natural aspect ratio.
  double? get aspectRatio;

  /// Factory for small image size.
  factory ImageAnswerSize.small() = SmallImageSize;

  /// Factory for medium image size (default).
  factory ImageAnswerSize.medium() = MediumImageSize;

  /// Factory for large image size.
  factory ImageAnswerSize.large() = LargeImageSize;

  /// Factory for custom image size.
  factory ImageAnswerSize.custom({
    required double maxSize,
    double spacing,
    double? aspectRatio,
  }) = CustomImageSize;

  /// Deserialize from map.
  factory ImageAnswerSize.fromMap(Map<String, dynamic> map) {
    final type = map['type'] as String;

    return switch (type) {
      'small' => SmallImageSize.fromMap(map),
      'medium' => MediumImageSize.fromMap(map),
      'large' => LargeImageSize.fromMap(map),
      'custom' => CustomImageSize.fromMap(map),
      _ => throw ArgumentError('Unknown image size type: $type'),
    };
  }

  @override
  int get version => 1;
}

/// Small image size for compact layouts.
///
/// - maxSize: 80 logical pixels
/// - spacing: 8 logical pixels
class SmallImageSize extends ImageAnswerSize {
  const SmallImageSize();

  @override
  double get maxSize => 80;

  @override
  double get spacing => 8;

  @override
  double? get aspectRatio => null;

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'small',
      'version': version,
    };
  }

  factory SmallImageSize.fromMap(Map<String, dynamic> map) {
    return const SmallImageSize();
  }

  @override
  bool operator ==(Object other) {
    return other is SmallImageSize;
  }

  @override
  int get hashCode => 'SmallImageSize'.hashCode;
}

/// Medium image size (default).
///
/// - maxSize: 120 logical pixels
/// - spacing: 12 logical pixels
class MediumImageSize extends ImageAnswerSize {
  const MediumImageSize();

  @override
  double get maxSize => 120;

  @override
  double get spacing => 12;

  @override
  double? get aspectRatio => null;

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'medium',
      'version': version,
    };
  }

  factory MediumImageSize.fromMap(Map<String, dynamic> map) {
    return const MediumImageSize();
  }

  @override
  bool operator ==(Object other) {
    return other is MediumImageSize;
  }

  @override
  int get hashCode => 'MediumImageSize'.hashCode;
}

/// Large image size for prominent display.
///
/// - maxSize: 160 logical pixels
/// - spacing: 16 logical pixels
class LargeImageSize extends ImageAnswerSize {
  const LargeImageSize();

  @override
  double get maxSize => 160;

  @override
  double get spacing => 16;

  @override
  double? get aspectRatio => null;

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'large',
      'version': version,
    };
  }

  factory LargeImageSize.fromMap(Map<String, dynamic> map) {
    return const LargeImageSize();
  }

  @override
  bool operator ==(Object other) {
    return other is LargeImageSize;
  }

  @override
  int get hashCode => 'LargeImageSize'.hashCode;
}

/// Custom image size with configurable parameters.
class CustomImageSize extends ImageAnswerSize {
  @override
  final double maxSize;

  @override
  final double spacing;

  @override
  final double? aspectRatio;

  const CustomImageSize({
    required this.maxSize,
    this.spacing = 12,
    this.aspectRatio,
  }) : assert(maxSize > 0, 'maxSize must be positive'),
       assert(spacing >= 0, 'spacing must be non-negative'),
       assert(
         aspectRatio == null || aspectRatio > 0,
         'aspectRatio must be positive if provided',
       );

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'custom',
      'version': version,
      'maxSize': maxSize,
      'spacing': spacing,
      if (aspectRatio != null) 'aspectRatio': aspectRatio,
    };
  }

  factory CustomImageSize.fromMap(Map<String, dynamic> map) {
    return CustomImageSize(
      maxSize: (map['maxSize'] as num).toDouble(),
      spacing: (map['spacing'] as num?)?.toDouble() ?? 12,
      aspectRatio: (map['aspectRatio'] as num?)?.toDouble(),
    );
  }

  CustomImageSize copyWith({
    double? maxSize,
    double? spacing,
    double? aspectRatio,
  }) {
    return CustomImageSize(
      maxSize: maxSize ?? this.maxSize,
      spacing: spacing ?? this.spacing,
      aspectRatio: aspectRatio ?? this.aspectRatio,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomImageSize &&
        other.maxSize == maxSize &&
        other.spacing == spacing &&
        other.aspectRatio == aspectRatio;
  }

  @override
  int get hashCode => Object.hash(maxSize, spacing, aspectRatio);
}