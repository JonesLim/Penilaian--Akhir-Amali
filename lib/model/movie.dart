class Movie {
  final int id;
  final String title;
  final String director;
  final String overview;
  final int length;
  final double rating;
  final String release_date;

  Movie({
    required this.id,
    required this.title,
    required this.director,
    required this.overview,
    required this.length,
    required this.rating,
    required this.release_date,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      director: json['director'] ?? '',
      overview: json['overview'] ?? '',
      length: json['length'] ?? 0,
      rating: json['rating'] ?? 0.0,
      release_date: json['release_date'] ?? '',
    );
  }
}
