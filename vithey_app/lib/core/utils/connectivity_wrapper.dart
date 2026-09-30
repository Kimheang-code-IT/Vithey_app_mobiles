import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/widgets/offline_banner.dart';

class ConnectivityWrapper extends StatefulWidget {
  const ConnectivityWrapper({super.key, required this.child});

  final Widget child;

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    Connectivity().checkConnectivity().then(_updateStatus);
    Connectivity().onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(dynamic results) {
    final list = results is List<ConnectivityResult> ? results : <ConnectivityResult>[results as ConnectivityResult];
    final offline = list.every((r) => r == ConnectivityResult.none);
    if (mounted) setState(() => _isOffline = offline);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OfflineBanner(isOffline: _isOffline),
        Expanded(child: widget.child),
      ],
    );
  }
}
