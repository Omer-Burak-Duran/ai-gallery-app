import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../services/indexing_service.dart';

/// Displays a grid of recent photo thumbnails from the device library.
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> with AutomaticKeepAliveClientMixin {
  List<AssetEntity> _assets = <AssetEntity>[];
  bool _loading = true;
  bool _denied = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    final result = await PhotoManager.requestPermissionExtend();
    if (!result.isAuth) {
      setState(() {
        _denied = true;
        _loading = false;
      });
      return;
    }
    // Schedule background indexing once permission is granted.
    await IndexingService().scheduleIndexingOnce();
    final paths = await PhotoManager.getAssetPathList(type: RequestType.image);
    if (paths.isEmpty) {
      setState(() {
        _assets = <AssetEntity>[];
        _loading = false;
      });
      return;
    }
    final recent = paths.first;
    final items = await recent.getAssetListPaged(page: 0, size: 200);
    setState(() {
      _assets = items;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_denied) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Permission required to show your gallery.'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await PhotoManager.openSetting();
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
    }
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
      ),
      itemCount: _assets.length,
      itemBuilder: (context, index) {
        final asset = _assets[index];
        return FutureBuilder<Uint8List?>(
          future: asset.thumbnailDataWithSize(const ThumbnailSize(200, 200)),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const ColoredBox(color: Colors.black12);
            }
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
              gaplessPlayback: true,
            );
          },
        );
      },
    );
  }
}


