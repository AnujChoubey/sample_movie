import 'package:flutter/material.dart';
import 'package:flutter_geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:video_player/video_player.dart';
import 'package:wework_movie_app/screens/home_screen.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  String mainAddress = '';
  String secondaryAddress = '';

  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
    _getLocation();
  }
  void _initializeVideoPlayer() {
    _controller = VideoPlayerController.asset(
        'assets/video/loader.mp4'  // Make sure your video file is in your assets folder
    );

    // Initialize the controller and store the Future for later use.
    _initializeVideoPlayerFuture = _controller!.initialize().then((_) {
      // Ensure the first frame is shown after the video is initialized, even before play.
      setState(() {});
    });

    _controller!.setLooping(true);
    _controller!.play(); // Automatically play the video when initialized.
  }
  Future<void> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location service is enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      return;
    }

    // Request location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permission denied
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permission permanently denied
      return;
    }

    // Fetch current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Reverse geocoding
    final coordinates = new Coordinates(position.latitude, position.longitude);
    var addresses =
    await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;

    setState(() {
      mainAddress = '${first.featureName}';
      secondaryAddress = '${first.subLocality},${first.locality}, ${first.adminArea}';
    });
    print(mainAddress);
    print(secondaryAddress);

    // Navigate to MainScreen with fetched addresses
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            MainScreen(mainAddress: mainAddress,secondaryAddress: secondaryAddress,)
      ),
    );
  }

  @override
  void dispose() {
    // Ensure disposing of the Video Player Controller to free up resources.
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(60.0),
        child: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // If the Future is complete, display the video player.
              return Center(
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  // Use the VideoPlayer widget to display the video.
                  child: VideoPlayer(_controller!),
                ),
              );
            } else {
              // Otherwise, display a loading spinner.
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}