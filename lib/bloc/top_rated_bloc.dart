import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

class TopRatedBloc {
  final String _apiKey =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI2YTg3ZTY4MDMyODIwMTIzZmQ0Yzg0YjQzNDhjYjc3ZCIsInN1YiI6IjY2Mjg5NDExOTFmMGVhMDE0YjAwOWU1ZSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.6zIM73Giwg5M4wP6MX8KDCpee7IMnpnLTZUyMpETb08';
  final String _baseUrl = 'https://api.themoviedb.org/3/movie/top_rated?language=en-US';
  final String _searchUrl = 'https://api.themoviedb.org/3/search/movie';

  final _topRatedFetcher = BehaviorSubject<List<dynamic>>();
  Stream<List<dynamic>> get topRated => _topRatedFetcher.stream;

  int _page = 1;
  bool _hasMore = true;
  bool _loading = false;
  List<dynamic> _cachedTopRated = [];

  TopRatedBloc() {
    fetchTopRated();
  }

  Future<void> fetchTopRated() async {
    if (!_hasMore || _loading) return;
    _loading = true;
    final response = await http.get(
      Uri.parse('$_baseUrl&page=$_page'),
      headers: {'Authorization': 'Bearer $_apiKey'},
    );

    if (response.statusCode == 200) {
      List<dynamic> topRated = json.decode(response.body)['results'];
      if (_page == 1) _cachedTopRated.clear();
      _cachedTopRated.addAll(topRated);
      _topRatedFetcher.sink.add(UnmodifiableListView(_cachedTopRated));
      _page++;
      _hasMore = topRated.isNotEmpty;
    } else {
      _topRatedFetcher.sink.addError('Failed to load top-rated movies: ${response.body}');
    }
    _loading = false;
  }

  Future<void> searchTopRated(String query) async {
    if (_loading) return;
    _loading = true;
    final searchResponse = await http.get(
      Uri.parse('$_searchUrl?query=$query&language=en-US&page=1'),
      headers: {'Authorization': 'Bearer $_apiKey'},
    );

    if (searchResponse.statusCode == 200) {
      List<dynamic> searchResults = json.decode(searchResponse.body)['results'];
      _cachedTopRated.clear();
      _cachedTopRated.addAll(searchResults);
      _topRatedFetcher.sink.add(UnmodifiableListView(_cachedTopRated));
      _hasMore = searchResults.isNotEmpty;  // Adjust depending on whether more results are expected
    } else {
      _topRatedFetcher.sink.addError('Failed to load search results: ${searchResponse.body}');
    }
    _loading = false;
  }

  Future<void> refreshTopRated() async {
    _page = 1;
    _hasMore = true;
    await fetchTopRated();
  }

  dispose() {
    _topRatedFetcher.close();
  }
}

final topRatedBloc = TopRatedBloc();
