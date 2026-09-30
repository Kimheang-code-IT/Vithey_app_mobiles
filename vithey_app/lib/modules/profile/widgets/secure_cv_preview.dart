import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SecureCvPreview extends StatefulWidget {
  const SecureCvPreview({
    super.key,
    required this.previewUrl,
    this.mimeType = 'application/pdf',
  });

  final String previewUrl;
  final String mimeType;

  @override
  State<SecureCvPreview> createState() => _SecureCvPreviewState();
}

class _SecureCvPreviewState extends State<SecureCvPreview> {
  late final WebViewController _controller;
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (error) {
            setState(() {
              _isLoading = false;
              _error = error.description;
            });
          },
        ),
      );

    final uri = Uri.parse(widget.previewUrl);
    if (widget.mimeType.contains('pdf')) {
      final viewer = Uri.parse(
        'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(widget.previewUrl)}',
      );
      _controller.loadRequest(viewer);
    } else {
      _controller.loadRequest(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(child: Text('Could not preview CV: $_error'));
    }
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
