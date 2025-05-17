class PostModel {
  String? postId;
  String? userEmail;
  String? userId;
  String? userProfileImage;
  String? userName;
  String? postImage;
  String? caption;
  int? likeCount;

  PostModel({
    this.postId,
    this.userEmail,
    this.postImage,
    this.caption,
    this.likeCount,
    this.userId,
    this.userName,
    this.userProfileImage,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      postId: json['postId'] as String,
      userEmail: json['userEmail'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userProfileImage: json['userProfileImage'] as String,
      postImage: json['postImage'] as String,
      caption: json['caption'] as String,
      likeCount: json['likeCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'userEmail': userEmail,
      'userId': userId,
      'userName': userName,
      'userProfileImage': userProfileImage,
      'postImage': postImage,
      'caption': caption,
      'likeCount': likeCount,
    };
  }
}
