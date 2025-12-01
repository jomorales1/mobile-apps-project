import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import '../../data/models/species_node.dart';
import '../../data/services/tree_loader.dart';
// import 'detalle_expo_view.dart';

class ArbolVidaView extends StatefulWidget {
    final Function(String)? onNavigate;
  const ArbolVidaView({super.key, this.onNavigate});

  @override
  State<ArbolVidaView> createState() => _ArbolVidaViewState();
}

class _ArbolVidaViewState extends State<ArbolVidaView> {
  final Graph graph = Graph()..isTree = true;
  final builder = BuchheimWalkerConfiguration();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    builder
      ..siblingSeparation = (30)
      ..levelSeparation = (50)
      ..subtreeSeparation = (50)
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;
    _buildTree();
  }

  Future<void> _buildTree() async {
    final rootNode = await TreeLoader.loadTree();
    _addNodesRecursive(rootNode, null);
    setState(() {
      isLoading = false;
    });
  }

  void _addNodesRecursive(SpeciesNode node, Node? parent) {
    final current = Node.Id(node);
    if (parent != null) {
      graph.addEdge(parent, current);
    } else {
      // Add the root node to the graph
      graph.addNode(current);
    }
    for (final child in node.children) {
      _addNodesRecursive(child, current);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tree of Life')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : InteractiveViewer(
              constrained: false,
              boundaryMargin: const EdgeInsets.all(100),
              minScale: 0.01,
              maxScale: 5.0,
              child: GraphView(
                graph: graph,
                algorithm: BuchheimWalkerAlgorithm(
                  builder,
                  TreeEdgeRenderer(builder),
                ),
                builder: (Node node) {
                  final species = node.key!.value as SpeciesNode;
                  return GestureDetector(
                    onTap: () {
                      if (species.id != null) {
                        print(
                          'Clicked on species: ${species.name} with ID: ${species.id}',
                        );
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => DetalleExpoView(exposicion_model: species),
                        //   ),
                        // );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: species.id == null
                            ? Colors.green.shade200
                            : Colors.lightBlue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        species.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
