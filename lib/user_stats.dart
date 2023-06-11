library user_stats;

class UserStats {
  late String sourceUuid;
  late int totalImages;
  late int totalClassified;
  

  UserStats(
    this.sourceUuid,
    this.totalImages,
    this.totalClassified,
  );

  void increaseTotalImages () {
    totalImages++;
  }

  void increaseTotalClassified () {
    totalClassified++;
  }
}