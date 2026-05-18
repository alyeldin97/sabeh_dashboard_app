import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class InternetConnectivityWrapper extends StatefulWidget {
  const InternetConnectivityWrapper({super.key, required this.child});
  final Widget child;

  @override
  State<InternetConnectivityWrapper> createState() => _InternetConnectivityWrapperState();
}

class _InternetConnectivityWrapperState extends State<InternetConnectivityWrapper> {
  late final Stream<InternetStatus> _stream;

  @override
  void initState() {
    super.initState();
    _stream = InternetConnection().onStatusChange;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<InternetStatus>(
      stream: _stream,
      builder: (context, snapshot) {
        final status = snapshot.data;
        if (status == InternetStatus.disconnected) {
          return Material(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, size: 64, color: Color(0xFF888888)),
                const SizedBox(height: 16),
                const Text('No Internet Connection', style: TextStyle(fontSize: 18)),
              ],
            ),
          );
        }
        return widget.child;
      },
    );
  }
}
