import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/compression_provider.dart';
import '../widgets/settings_panel.dart';
import '../widgets/preview_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompressionProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Video Compressor'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Open settings
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            // Desktop layout: side by side
            return Row(
              children: [
                SizedBox(
                  width: 400,
                  child: SettingsPanel(),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: PreviewPanel(),
                ),
              ],
            );
          } else {
            // Mobile layout: stacked
            return Column(
              children: [
                Expanded(
                  flex: 1,
                  child: SettingsPanel(),
                ),
                const Divider(height: 1),
                Expanded(
                  flex: 1,
                  child: PreviewPanel(),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}