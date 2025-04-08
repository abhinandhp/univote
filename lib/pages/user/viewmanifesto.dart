import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ViewManifestoPage extends StatelessWidget {
  final String url;

  const ViewManifestoPage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Manifesto"),
      ),
      body: SfPdfViewer.network(
        url,
        canShowScrollHead: true,
        canShowScrollStatus: true,
        onDocumentLoadFailed: (details) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load PDF: ${details.description}'),
            ),
          );
        },
      ),
    );
  }
}
