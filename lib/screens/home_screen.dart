import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:penilaian_akhir_amali/model/movie.dart';
import 'package:penilaian_akhir_amali/screens/detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Movie>> _movie;
  String _searchQuery = "";
  String _sortBy = "title";
  String _sortOrder = "asc";
  final List<Movie> _movies = [];

  @override
  void initState() {
    super.initState();
    _movie = fetchMovies();
  }

  Future<List<Movie>> fetchMovies() async {
    final response = await http.get(
      Uri.parse('https://fcapi-1y70.onrender.com/movies'),
    );
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to load movies');
    }
  }

  List<Movie> _filterAndSortMovies() {
    List<Movie> filteredMovies =
        _movies.where((movie) {
          return movie.title.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

    filteredMovies.sort((a, b) {
      int compare;
      if (_sortBy == 'title') {
        compare = a.title.compareTo(b.title);
      } else {
        compare = a.rating.compareTo(b.rating);
      }
      return _sortOrder == 'asc' ? compare : -compare;
    });

    return filteredMovies;
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: const InputDecoration(
              hintText: 'Search by title',
              prefixIcon: Icon(Icons.search),
              isDense: true,
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _sortBy,
                onChanged: (value) {
                  if (value != null) setState(() => _sortBy = value);
                },
                items:
                    ['title', 'rating'].map((option) {
                      return DropdownMenuItem(
                        value: option,
                        child: Text(
                          'Sort by ${option[0].toUpperCase()}${option.substring(1)}',
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(width: 150),
              DropdownButton<String>(
                value: _sortOrder,
                onChanged: (value) {
                  if (value != null) setState(() => _sortOrder = value);
                },
                items:
                    ['asc', 'desc'].map((option) {
                      return DropdownMenuItem(
                        value: option,
                        child: Text(option.toUpperCase()),
                      );
                    }).toList(),
              ),
            ],
          ),
        ],
      ),
      toolbarHeight: 120,
      backgroundColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        color: const Color(0xFFE9ECF4),
        child: FutureBuilder<List<Movie>>(
          future: _movie,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No movies found.'));
            }

            _movies.clear();
            _movies.addAll(snapshot.data!);
            final moviesList = _filterAndSortMovies();

            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: moviesList.length,
              itemBuilder: (context, index) {
                final movie = moviesList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Card(
                    child: ListTile(
                      title: Text(
                        movie.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rating: ${movie.rating}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Director: ${movie.director}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Release Date: ${movie.release_date}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(id: movie.id),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
