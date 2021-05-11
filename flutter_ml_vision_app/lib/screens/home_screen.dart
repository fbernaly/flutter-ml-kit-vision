import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../main.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

enum HomeScreenMode { liveFeed, gallery }

class _HomeScreenState extends State<HomeScreen> {
  HomeScreenMode _mode = HomeScreenMode.liveFeed;
  File _image;
  ImagePicker _imagePicker;
  CameraController _controller;
  int _cameraIndex = 0;

  @override
  void initState() {
    super.initState();

    _imagePicker = ImagePicker();
    if (cameras.length > 1) _cameraIndex = 1;
    _startLiveFeed();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: Platform.isIOS,
        title: Text(widget.title),
        actions: _actions(),
      ),
      body: _body(),
      floatingActionButton: _floatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  List<Widget> _actions() {
    return <Widget>[
      Padding(
          padding: EdgeInsets.only(right: 20.0),
          child: GestureDetector(
            onTap: _switchHomeMode,
            child: Icon(
              _mode == HomeScreenMode.liveFeed
                  ? Icons.photo_library_outlined
                  : (Platform.isIOS ? Icons.camera_alt_outlined : Icons.camera),
            ),
          )),
      Padding(
          padding: EdgeInsets.only(right: 20.0),
          child: GestureDetector(
            onTap: () {},
            child: Icon(Icons.more_vert),
          )),
    ];
  }

  Widget _floatingActionButton() {
    if (_mode == HomeScreenMode.gallery) return null;
    if (cameras.length == 1) return null;
    return Container(
        height: 80.0,
        width: 80.0,
        child: FloatingActionButton(
          child: Icon(
            Platform.isIOS
                ? Icons.flip_camera_ios_outlined
                : Icons.flip_camera_android_outlined,
            size: 50,
          ),
          onPressed: _switchLiveCamera,
        ));
  }

  Widget _body() {
    Widget body;
    if (_mode == HomeScreenMode.liveFeed)
      body = _liveFeedBody();
    else
      body = _galleryBody();
    return body;
  }

  Widget _liveFeedBody() {
    if (!_controller.value.isInitialized) {
      return Container();
    }
    return Container(
      color: Colors.black,
      child: Center(
        child: CameraPreview(_controller),
      ),
    );
  }

  Widget _galleryBody() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _image != null ? Image.file(_image) : Icon(Icons.image, size: 200),
          ElevatedButton(
            child: Text('Choose/capture'),
            onPressed: () => _getImage(ImageSource.gallery),
            onLongPress: () => _getImage(ImageSource.camera),
          )
        ],
      ),
    );
  }

  Future _getImage(ImageSource source) async {
    final pickedFile = await _imagePicker.getImage(source: source);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  void _switchHomeMode() {
    if (_mode == HomeScreenMode.liveFeed) {
      _mode = HomeScreenMode.gallery;
      _controller?.dispose();
    } else {
      _mode = HomeScreenMode.liveFeed;
      _startLiveFeed();
    }
    setState(() {});
  }

  void _startLiveFeed() {
    _controller = CameraController(
      cameras[_cameraIndex],
      ResolutionPreset.medium,
    );
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller.startImageStream((image) => {});
      setState(() {});
    });
  }

  void _switchLiveCamera() async {
    if (_cameraIndex == 0)
      _cameraIndex = 1;
    else
      _cameraIndex = 0;
    if (_controller != null) {
      await _controller?.dispose();
    }
    _startLiveFeed();
    setState(() {});
  }
}
