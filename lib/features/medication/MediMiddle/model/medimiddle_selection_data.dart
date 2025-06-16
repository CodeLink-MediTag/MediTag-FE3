class MediMiddleSelectionData {
  final String? name;
  final String? characteristic;
  final String? imageUrl;

  const MediMiddleSelectionData({
    this.name,
    this.characteristic,
    this.imageUrl,
  });

  MediMiddleSelectionData copyWith({
    String? name,
    String? characteristic,
    String? imageUrl,
  }) {
    return MediMiddleSelectionData(
      name:           name ?? this.name,
      characteristic: characteristic ?? this.characteristic,
      imageUrl:       imageUrl ?? this.imageUrl,
    );
  }
}
