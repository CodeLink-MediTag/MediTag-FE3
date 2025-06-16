import 'dart:typed_data';

class MediMiddleSelectionData {
  final String? name;
  final String? characteristic;
  final String? imagePath;     // 모바일에서 쓸 경로
  final Uint8List? imageBytes; // 웹에서 쓸 바이트

  const MediMiddleSelectionData({
    this.name,
    this.characteristic,
    this.imagePath,
    this.imageBytes,
  });

  MediMiddleSelectionData copyWith({
    String? name,
    String? characteristic,
    String? imagePath,
    Uint8List? imageBytes,
  }) {
    return MediMiddleSelectionData(
      name:           name ?? this.name,
      characteristic: characteristic ?? this.characteristic,
      imagePath:      imagePath ?? this.imagePath,
      imageBytes:     imageBytes ?? this.imageBytes,
    );
  }
}
