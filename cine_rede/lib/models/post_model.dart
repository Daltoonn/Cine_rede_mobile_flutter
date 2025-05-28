class PostModel {
  String id;
  String authorId;
  String imageUrl;
  String description;
  double movieNote;
  String movieTitle;
  String genres;
  String timestamp;

  PostModel({
    required this.id,
    required this.authorId,
    required this.imageUrl,
    required this.description,
    required this.movieNote,
    required this.movieTitle,
    required this.genres,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorId': authorId,
      'imageUrl': imageUrl,
      'description': description,
      'movieNote': movieNote,
      'movieTitle': movieTitle,
      'genres': genres,
      'timestamp': timestamp,
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'],
      authorId: map['authorId'],
      imageUrl: map['imageUrl'],
      description: map['description'],
      movieNote: map['movieNote'],
      movieTitle: map['movieTitle'],
      genres: map['genres'],
      timestamp: map['timestamp'],
    );
  }
}
