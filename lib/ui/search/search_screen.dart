import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import '../../state/search_state.dart';
import '../../services/search_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _controller = TextEditingController();
  final SearchService _searchService = SearchService();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onSubmit(String value) async {
    final ids = await _searchService.searchPhotos(value);
    if (!mounted) return;
    context.read<SearchState>().setQuery(value);
    context.read<SearchState>().setResults(ids);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final results = context.watch<SearchState>().resultPhotoIds;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search photos or #tags',
              border: OutlineInputBorder(),
            ),
            onSubmitted: _onSubmit,
          ),
        ),
        Expanded(
          child: results.isEmpty
              ? const Center(child: Text('No results'))
              : FutureBuilder<List<AssetEntity>>(
                  future: _resolveIds(results),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final assets = snapshot.data!;
                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 1,
                        crossAxisSpacing: 1,
                      ),
                      itemCount: assets.length,
                      itemBuilder: (context, index) {
                        return FutureBuilder<Uint8List?>(
                          future: assets[index].thumbnailDataWithSize(const ThumbnailSize(200, 200)),
                          builder: (context, snap) {
                            if (!snap.hasData) {
                              return const ColoredBox(color: Colors.black12);
                            }
                            return Image.memory(snap.data!, fit: BoxFit.cover);
                          },
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<List<AssetEntity>> _resolveIds(List<String> ids) async {
    // Placeholder: In a real app, you'd map DB photo ids to AssetEntity using URI/path
    // For now, return recent images regardless; TODO: implement id->asset resolution using photo_manager
    final paths = await PhotoManager.getAssetPathList(type: RequestType.image);
    if (paths.isEmpty) return <AssetEntity>[];
    return paths.first.getAssetListPaged(page: 0, size: ids.length);
  }
}


