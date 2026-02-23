// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:led/core/app_colors.dart';
import 'package:led/screens/add_text_for_post.dart';

import 'package:photo_manager/photo_manager.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final List<Widget> _mediaList = [];
  final List<File> path = [];
  File? _file;
  int currentPage = 0;
  int? lastPage;
  int _selectedIndex = 0;

  _fetchNewMedia() async {
    lastPage = currentPage;
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      List<AssetPathEntity> album =
          await PhotoManager.getAssetPathList(type: RequestType.image);

      if (album.isEmpty) return;

      List<AssetEntity> media =
          await album[0].getAssetListPaged(page: currentPage, size: 60);

      if (media.isEmpty) return;

      for (var asset in media) {
        if (asset.type == AssetType.image) {
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
                return Image.memory(snapshot.data!, fit: BoxFit.cover);
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
          'New Post',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              if (_file != null) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Add_Text_For_Post(_file!),
                ));
              }
            },
            child: Container(
              margin: EdgeInsets.only(right: 14.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                ),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'Next',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _mediaList.isEmpty
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                _buildPreview(),
                _buildGalleryHeader(),
                Expanded(child: _buildGalleryGrid()),
              ],
            ),
    );
  }

  Widget _buildPreview() {
    return Container(
      height: 340.h,
      width: double.infinity,
      color: AppColors.surfaceCard,
      child: _file != null
          ? Image.file(_file!, fit: BoxFit.cover)
          : _mediaList.isNotEmpty
              ? _mediaList[0]
              : Container(color: AppColors.surfaceCard),
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
          Icon(Icons.photo_library_outlined, size: 16.sp, color: AppColors.primary),
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

  Widget _buildGalleryGrid() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      itemCount: _mediaList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemBuilder: (context, index) {
        final bool isSelected = _selectedIndex == index;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedIndex = index;
              if (index < path.length) _file = path[index];
            });
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