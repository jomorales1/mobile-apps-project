import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../repositories/detail_repository.dart';
import '../../model/detail_model.dart';

class ArbolVidaView extends StatefulWidget {
  const ArbolVidaView({super.key});

  @override
  State<ArbolVidaView> createState() => _ArbolVidaViewState();
}

class _ArbolVidaViewState extends State<ArbolVidaView> {
  final Graph graph = Graph()..isTree = true;
  final builder = BuchheimWalkerConfiguration();
  bool isLoading = true;
  final DetailRepository _repo = DetailRepository();
  final Map<String, Detail> _speciesMap = {};
  final TransformationController _tc = TransformationController();
  bool _initialCentered = false;

  @override
  void initState() {
    super.initState();
    builder
      ..siblingSeparation = 30
      ..levelSeparation = 50
      ..subtreeSeparation = 50
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;
    _buildTree();
  }

  Future<void> _buildTree() async {
    final species = await _repo.fetchAllSpecies();
    final root = Node.Id('Life');
    graph.addNode(root);
    final taxNodes = <String, Node>{'Life': root};
    for (final detail in species) {
      var parent = root;
      for (final levelRaw in detail.taxonomyPath) {
        final level = levelRaw.trim();
        if (level.isEmpty) continue;
        taxNodes.putIfAbsent(level, () {
          final n = Node.Id(level);
          graph.addEdge(parent, n);
          return n;
        });
        final current = taxNodes[level]!;
        final exists = graph.edges.any(
          (e) => e.source == parent && e.destination == current,
        );
        if (!exists && parent != current) {
          graph.addEdge(parent, current);
        }
        parent = current;
      }
      final speciesId = 'species:${detail.id}';
      _speciesMap[speciesId] = detail;
      graph.addEdge(parent, Node.Id(speciesId));
    }
    setState(() => isLoading = false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerOnce();
      _precacheSpeciesImages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tree of Life')),
      body: () {
        if (isLoading) return const Center(child: CircularProgressIndicator());
        if (graph.nodeCount() == 0) return const Center(child: Text('No data'));
        return Stack(
          children: [
            Container(
              color: Colors.white,
              child: InteractiveViewer(
                constrained: false,
                boundaryMargin: const EdgeInsets.all(200),
                minScale: 0.2,
                maxScale: 3.0,
                transformationController: _tc,
                child: GraphView(
                  graph: graph,
                  algorithm: BuchheimWalkerAlgorithm(
                    builder,
                    TreeEdgeRenderer(builder),
                  ),
                  builder: (node) {
                    final raw = node.key?.value;
                    if (raw == null) return _placeholderNode('N/A');
                    final id = raw.toString();
                    if (id.startsWith('species:')) {
                      final detail = _speciesMap[id];
                      if (detail == null) return _placeholderNode('Missing');
                      return GestureDetector(
                        onTap: () =>
                            debugPrint('Clicked ${detail.nombre} ${detail.id}'),
                        child: _buildSpeciesNode(detail),
                      );
                    }
                    return _buildTaxonomyNode(id);
                  },
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DefaultTextStyle(
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Nodes: ${graph.nodeCount()}'),
                          Text('Edges: ${graph.edges.length}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  FloatingActionButton.small(
                    heroTag: 'recenterTree',
                    onPressed: _centerView,
                    child: const Icon(Icons.center_focus_strong),
                  ),
                ],
              ),
            ),
          ],
        );
      }(),
    );
  }

  Widget _placeholderNode(String text) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.grey.shade300,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(text, style: const TextStyle(fontSize: 12)),
  );

  Widget _buildTaxonomyNode(String label) {
    final isRoot = label == 'Life';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isRoot ? Colors.green.shade400 : Colors.green.shade200,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSpeciesNode(Detail detail) {
    final imageUrl = _resolveImage(detail.imagen);
    return Container(
      width: 160,
      constraints: const BoxConstraints(minHeight: 130),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.lightBlue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 70,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl.isEmpty
                  ? _nameFallback(detail)
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                      frameBuilder: (ctx, child, frame, wasSync) {
                        if (frame == null) {
                          return _nameFallback(detail);
                        }
                        return child;
                      },
                      loadingBuilder: (ctx, child, progress) {
                        if (progress == null) return child;
                        return _nameFallback(detail);
                      },
                      errorBuilder: (ctx, err, stack) => _nameFallback(detail),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            detail.nombre,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            detail.nombreCientifico,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _nameFallback(Detail detail) => Container(
    color: Colors.blueGrey.shade100,
    alignment: Alignment.center,
    child: Text(
      detail.nombre,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    ),
  );

  String _resolveImage(String raw) {
    if (raw.isEmpty) return '';
    if (raw.startsWith('http')) return raw.trim();
    try {
      return Supabase.instance.client.storage
          .from('MuseoAPP')
          .getPublicUrl(raw.trim());
    } catch (_) {
      return '';
    }
  }

  void _centerOnce() {
    if (_initialCentered) return;
    _initialCentered = true;
    _centerView();
  }

  void _centerView() {
    final count = graph.nodeCount();
    double scale = 1.0;
    if (count > 60)
      scale = 0.5;
    else if (count > 40)
      scale = 0.6;
    else if (count > 25)
      scale = 0.7;
    else if (count > 15)
      scale = 0.85;
    _tc.value = Matrix4.identity()..scale(scale);
    debugPrint('Center scale applied: $scale (nodes=$count)');
  }

  void _precacheSpeciesImages() {
    if (!mounted) return;
    int queued = 0;
    for (final detail in _speciesMap.values) {
      final url = _resolveImage(detail.imagen);
      if (url.isEmpty || !url.startsWith('http')) continue;
      queued++;
      precacheImage(NetworkImage(url), context).catchError((_) {
        debugPrint('Precache failed for ${detail.id}');
      });
    }
    debugPrint('Precached images: $queued');
  }
}
