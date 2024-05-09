import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wework_movie_app/custom.dart';
import 'package:wework_movie_app/widgets/top_rated_widget.dart';
import '../bloc/movie_bloc.dart';
import '../bloc/top_rated_bloc.dart';
import 'default_screen.dart';

class MainScreen extends StatefulWidget {
  final String? mainAddress;
  final String? secondaryAddress;

  MainScreen({this.mainAddress, this.secondaryAddress});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  int total = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void setTotal(int newTotal) {
    setState(() {
      total = newTotal;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onSearchChanged() {
    if (_searchController.text.isNotEmpty) {
      movieBloc.searchMovies(_searchController.text);
      topRatedBloc.searchTopRated(_searchController.text);
    } else {
      movieBloc.refreshMovies();
      topRatedBloc.refreshTopRated(); // Refresh to default list when search is cleared
    }
  }

  Future<void> _refresh() async {
    await movieBloc.refreshMovies();
    await topRatedBloc.refreshTopRated();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[200],
      body: _selectedIndex != 0 ? DefaultScreen():SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.purple[200]!,
                Colors.purple[100]!,
                Colors.purple[100]!,
                Colors.grey.shade300,
                Colors.grey.shade200,
                Colors.grey.shade100,
              ],
            ),
          ),
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildHeader(),
                    buildSearchBar(),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(getFormattedDate(),style: TextStyle(fontSize: 12),),
                    ),
                    SizedBox(height: 8),
                    buildInfoPanel(),
                    SizedBox(height: 16),
                    headerRow('NOW PLAYING'),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.4, child: MovieList(updateTotal: setTotal)),
                    SizedBox(height: 16),
                    headerRow('TOP RATED'),
                    SizedBox(height: 16),
                    TopRatedList(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  Widget buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 18),
                Text(widget.mainAddress ?? '', style: TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
            Text(widget.secondaryAddress ?? ''),
          ],
        ),
        Container(
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Image.asset('assets/images/logo.png', fit: BoxFit.fill, height: 50),
        )
      ],
    );
  }

  Widget buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: Colors.white),
      padding: EdgeInsets.only(left: 10.0),
      child: TextFormField(
        controller: _searchController,
        decoration: InputDecoration(
          isDense: false,
          prefixIcon: Icon(Icons.search),
          hintText: 'Search Movies by name',
          border: InputBorder.none,
        ),
        onChanged: (val) {
          if (val == '') {
            _refresh();
          }
        },
      ),
    );
  }

  Widget buildInfoPanel() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Colors.grey, Colors.grey, Colors.black],
        ),
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('We Movies', style: TextStyle(fontSize: 20)),
          Text('$total movies are loaded in now playing'),
        ],
      ),
    );
  }

  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: ClipRRect(borderRadius: BorderRadius.circular(50), child: Image.asset('assets/images/black_logo.png', height: 30, width: 30)),
          label: 'We Movies',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.map),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_sharp),
          label: 'Upcoming',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.black,
      onTap: _onItemTapped,
    );
  }

  headerRow(header) {
    return Row(
      children: [
        Text(header,style: TextStyle(fontSize: 12)),
        SizedBox(width: 10),
        Container(
          width: MediaQuery.of(context).size.width * 0.4,
          height: 1.0,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.transparent],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ],
    );
  }

  String getFormattedDate() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('d').format(now);
    String daySuffix = _getDaySuffix(int.parse(formattedDate));
    return formattedDate += daySuffix + ' ' + DateFormat('MMM yyyy').format(now).toUpperCase();
  }

  String _getDaySuffix(int dayNum) {
    if (!(dayNum >= 1 && dayNum <= 31)) throw Exception('Invalid day number');
    if (dayNum >= 11 && dayNum <= 13) return "TH";
    switch (dayNum % 10) {
      case 1: return "ST";
      case 2: return "ND";
      case 3: return "RD";
      default: return "TH";
    }
  }
}

class MovieList extends StatefulWidget {
  final Function(int) updateTotal;

  MovieList({required this.updateTotal});

  @override
  _MovieListState createState() => _MovieListState();
}

class _MovieListState extends State<MovieList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    movieBloc.fetchMovies();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      movieBloc.fetchMovies();
    }
  }
  Widget buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 10, // Number of shimmer items
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              width: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 8,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 5),
                          Container(
                            width: 160,
                            height: 8,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 5),
                          Container(
                            width: 100,
                            height: 8,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<dynamic>>(
      stream: movieBloc.movies,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return buildShimmerEffect();
        }

        final movies = snapshot.data!;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.updateTotal(snapshot.data!.length); // Update after the build
        }); // Update total here

        return ListView.builder(
          controller: _scrollController,
          itemCount: movies.length,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8, right: 16),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      width: 250,
                      'https://image.tmdb.org/t/p/w500${movies[index]['poster_path']}',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                      top: 8,
                      right: 16,
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.only(
                              left: 4,
                              right: 4,
                            ),
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(30)),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.remove_red_eye_outlined,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  movies[index]['vote_count'].toString(),
                                  style: TextStyle(color: Colors.white),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Container(
                              padding: EdgeInsets.all(
                                2,
                              ),
                              decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.4),
                                  shape: BoxShape.circle),
                              child: Icon(
                                Icons.favorite_border,
                                color: Colors.white,
                                size: 15,
                              )),
                        ],
                      )),
                  Positioned(
                    bottom: 1,
                    child: ClipRRect(
                      // Apply the same borderRadius to ClipRRect for BackdropFilter
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                        child: Container(
                          width: 250,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movies[index]['title'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 12),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_month_outlined,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 3,
                                    ),
                                    Expanded(
                                      // Changed to Expanded from SizedBox to handle overflow better
                                      child: Text(
                                        movies[index]['overview'],
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 10),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${movies[index]['vote_count']} Votes',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class TopRatedList extends StatefulWidget {
  @override
  _TopRatedState createState() => _TopRatedState();
}

class _TopRatedState extends State<TopRatedList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    topRatedBloc.fetchTopRated();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      topRatedBloc.fetchTopRated();
    }
  }




  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<dynamic>>(
      stream: topRatedBloc.topRated,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final topRated = snapshot.data!;
        return ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          controller: _scrollController,
          itemCount: topRated.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return TopRatedWidget(
              imgUrl:
                  'https://image.tmdb.org/t/p/original${topRated[index]['backdrop_path']}',
              title: topRated[index]['original_title'],
              desc: topRated[index]['overview'],
              votes: topRated[index]['vote_count'],
              score: topRated[index]['vote_average'],
            );
          },
        );
      },
    );
  }
}
