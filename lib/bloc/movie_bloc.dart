import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

class MovieBloc {
  final String _apiKey =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI2YTg3ZTY4MDMyODIwMTIzZmQ0Yzg0YjQzNDhjYjc3ZCIsInN1YiI6IjY2Mjg5NDExOTFmMGVhMDE0YjAwOWU1ZSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.6zIM73Giwg5M4wP6MX8KDCpee7IMnpnLTZUyMpETb08';
  final String _baseUrl =
      'https://api.themoviedb.org/3/movie/now_playing?language=en-US';

  final _moviesFetcher = BehaviorSubject<List<dynamic>>();
  Stream<List<dynamic>> get movies => _moviesFetcher.stream;

  int _page = 1;
  bool _hasMore = true;
  bool _loading = false;
  List<dynamic> _cachedMovies = [];

  MovieBloc() {
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    if (!_hasMore || _loading) return;
    _loading = true;
    final response = await http.get(
      Uri.parse('$_baseUrl&page=$_page'),
      headers: {'Authorization': 'Bearer $_apiKey'},
    );

    try{
      if (response.statusCode == 200) {
        List<dynamic> movies = json.decode(response.body)['results'];
        print(movies);
        _cachedMovies.addAll(movies);
        _moviesFetcher.sink.add(UnmodifiableListView(_cachedMovies));
        _page++;
        _hasMore = movies.isNotEmpty;
      } else {
        _loading = false;
        print(response.body);
        throw Exception('Failed to load movies');
      }
    }
    catch(e){
      print(e);
    }

    _loading = false;
  }
  Future<void> searchMovies(String query) async {
    if (_loading) return;
    _loading = true;
    final searchUrl = 'https://api.themoviedb.org/3/search/movie?query=$query&language=en-US&page=$_page';

    final response = await http.get(
      Uri.parse(searchUrl),
      headers: {'Authorization': 'Bearer $_apiKey'},
    );

    if (response.statusCode == 200) {
      List<dynamic> movies = json.decode(response.body)['results'];
      _cachedMovies.clear();  // Clear existing movies for new search results
      _cachedMovies.addAll(movies);
      _moviesFetcher.sink.add(UnmodifiableListView(_cachedMovies));
      _page = 2; // Set page to 2 assuming more results could be loaded on scroll
      _hasMore = movies.isNotEmpty; // Check if there are more movies to load
    } else {
      _moviesFetcher.sink.addError('Failed to load search results');
    }

    _loading = false;
  }
  Future<void> refreshMovies() async {
    _page = 1;
    _hasMore = true;
    _cachedMovies.clear();
    await fetchMovies();
  }

  dispose() {
    _moviesFetcher.close();
  }
}

final movieBloc = MovieBloc();
