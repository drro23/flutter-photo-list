import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:photo_list/Constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:photo_list/Pexels.dart';

class PhotoList extends StatefulWidget {
  @override
  _PhotoListState createState() => _PhotoListState();
}

class _PhotoListState extends State<PhotoList> {
  var dio = Dio();
  PageController _pageViewController = new PageController();
  ScrollController miniPhotoListController = new ScrollController();
  int currentPageViewIndex;
  Pexels data;

  @override
  initState() {
    super.initState();
    _getPhotos();
    currentPageViewIndex = _pageViewController.initialPage;
  }

  updateCurrentPageViewIndex(int pageIndex, var screenWidth) async {
    double newOffset;
    if (pageIndex * (90 + 10) - 90 / 2 > screenWidth / 2) {
      newOffset = pageIndex * (90 + 10) - screenWidth / 2 + 90 / 2;
      miniPhotoListController.animateTo(newOffset,
          duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      miniPhotoListController.animateTo(0,
          duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
    setState(() {
      currentPageViewIndex = pageIndex;
    });
  }

  Future<void> _getPhotos() async {
    var res;
    try {
      // res = await dio.get("${Constants.PICSUM_BASE_URL}?limit=10",
      //     options: Options(headers: Constants.simpleHeaders()));
      res = await dio.get("${Constants.PEXELS_BASE_URL}/curated?per_page=15",
          options: Options(headers: Constants.headers(env['API_TOKEN'])));
      if (res.statusCode != 200) throw Exception("Error fetching photos");
    } catch (e) {
      print(e);
    }
    setState(() {
      // data = res.data;
      data = Pexels.fromJson(res.data);
    });
  }

  Widget _photoMiniList(String url, int index) {
    return GestureDetector(
      onTap: () {
        _pageViewController.animateToPage(index,
            duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      },
      child: Container(
        width: 90,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: (index == currentPageViewIndex)
                ? Border.all(color: Colors.white, width: 2)
                : Border.all(color: Colors.transparent),
            image:
                DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)),
      ),
    );
  }

  Widget _photoList(var screenWidth) {
    List<Widget> pageViews = [];
    List<Widget> photoMiniList = [];
    for (var i = 0; i < data.photos.length; i++) {
      pageViews.add(Image.network(
        data.photos[i].src.portrait,
        fit: BoxFit.cover,
      ));
    }
    for (var i = 0; i < data.photos.length; i++) {
      if (i == 0) photoMiniList.add(SizedBox(width: 10));
      photoMiniList.add(_photoMiniList(data.photos[i].src.portrait, i));
      photoMiniList.add(SizedBox(
        width: 10,
      ));
    }
    return Stack(
      children: [
        PageView(
          controller: _pageViewController,
          onPageChanged: (value) =>
              updateCurrentPageViewIndex(value, screenWidth),
          scrollDirection: Axis.horizontal,
          children: pageViews,
        ),
        Positioned(
            bottom: 25,
            child: SizedBox(
              height: 75,
              width: screenWidth,
              child: ListView(
                controller: miniPhotoListController,
                scrollDirection: Axis.horizontal,
                children: photoMiniList,
              ),
            ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: SizedBox(
            width: screenWidth,
            height: screenHeight,
            child: data != null
                ? _photoList(screenWidth)
                : Center(
                    child: CircularProgressIndicator(),
                  )),
      ),
    );
  }
}
