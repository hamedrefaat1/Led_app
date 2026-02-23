// ignore_for_file: prefer_const_constructors, unused_field

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:led/core/app_colors.dart';
import 'package:led/screens/add_text_for_reel.dart';
import 'package:photo_manager/photo_manager.dart';

class Addreelsscreen extends StatefulWidget {
  const Addreelsscreen({super.key});

  @override
  State<Addreelsscreen> createState() => _AddreelsscreenState();
}

class _AddreelsscreenState extends State<Addreelsscreen> {
  final List<Widget> _mediaList = [];
  final List<File> path = [];
  File? _file;
  int currentPage = 0;
  int? lastPage;
  int _selectedIndex = -1;

  _fetchNewMedia() async {
    lastPage = currentPage;
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      List<AssetPathEntity> album =
          await PhotoManager.getAssetPathList(type: RequestType.video);

      if (album.isEmpty) return;

      List<AssetEntity> media =
          await album[0].getAssetListPaged(page: currentPage, size: 60);

      if (media.isEmpty) return;

      for (var asset in media) {
        if (asset.type == AssetType.video) {
          final file = await asset.file;
          if (file != null) path.add(File(file.path));
        }
      }

      if (path.isNotEmpty) _file = path[0];

      List<Widget> temp = [];
      for (var asset in media) {
        temp.add(
          FutureBuilder(
            future: asset.thumbnailDataWithSize(const ThumbnailSize(300, 300)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.data != null) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(snapshot.data!, fit: BoxFit.cover),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: EdgeInsets.all(6.r),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_circle_fill,
                                size: 12.sp, color: Colors.white),
                            SizedBox(width: 3.w),
                            Text(
                              _formatDuration(asset.videoDuration),
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                      color: Colors.black54, blurRadius: 4)
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
              return Container(color: AppColors.surfaceElevated);
            },
          ),
        );
      }

      setState(() {
        _mediaList.addAll(temp);
        currentPage++;
      });
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString();
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void initState() {
    super.initState();
    _fetchNewMedia();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
  
        title: Text(
          'New Reel',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: _mediaList.isEmpty
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                _buildGalleryHeader(),
                Expanded(child: _buildGrid()),
              ],
            ),
    );
  }

  Widget _buildGalleryHeader() {
    return Container(
      height: 44.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.videocam_outlined, size: 16.sp, color: AppColors.primary),
          SizedBox(width: 6.w),
          Text(
            'Recents',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Icon(Icons.expand_more, size: 20.sp, color: AppColors.icon),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(2.r),
      itemCount: _mediaList.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisExtent: 180.h,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemBuilder: (context, index) {
        final bool isSelected = _selectedIndex == index;
        return GestureDetector(
          onTap: () {
            setState(() => _selectedIndex = index);
            if (index < path.length) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ReelsEditeScreen(path[index]),
              ));
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              border: isSelected
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _mediaList[index],
                if (isSelected)
                  Container(
                    color: AppColors.primaryGlow,
                    alignment: Alignment.topRight,
                    padding: EdgeInsets.all(4.r),
                    child: Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                      child: Icon(Icons.check, size: 12.sp, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}