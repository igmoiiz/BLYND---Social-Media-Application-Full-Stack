class PostModel {
  final String? postId;
  final String? userEmail;
  final String? userId;
  final String? userName;
  final String? userProfileImage;
  final String? caption;
  final String? postImage;
  final int? likeCount;
  final List<String>? likedBy;
  final List<Map<String, dynamic>>? comments;
  final DateTime? createdAt;

  PostModel({
    this.postId,
    this.userEmail,
    this.userId,
    this.userName,
    this.userProfileImage,
    this.caption,
    this.postImage,
    this.likeCount = 0,
    this.likedBy = const [],
    this.comments = const [],
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'userEmail': userEmail,
      'userId': userId,
      'userName': userName,
      'userProfileImage': userProfileImage,
      'caption': caption,
      'postImage': postImage,
      'likeCount': likeCount ?? 0,
      'likedBy': likedBy ?? [],
      'comments': comments ?? [],
      'createdAt': createdAt?.toUtc().toIso8601String(),
    };
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDateTime(String? dateStr) {
      if (dateStr == null) return null;
      try {
        return DateTime.parse(dateStr).toUtc();
      } catch (e) {
        return null;
      }
    }

    return PostModel(
      postId: json['postId'],
      userEmail: json['userEmail'],
      userId: json['userId'],
      userName: json['userName'],
      userProfileImage: json['userProfileImage'],
      caption: json['caption'],
      postImage: json['postImage'],
      likeCount: json['likeCount'] ?? 0,
      likedBy: List<String>.from(json['likedBy'] ?? []),
      comments: List<Map<String, dynamic>>.from(json['comments'] ?? []),
      createdAt: parseDateTime(json['createdAt']) ?? DateTime.now().toUtc(),
    );
  }
}
