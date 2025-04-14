import 'dart:convert';

import 'package:web_socket_channel/io.dart';

class ProjectProgressTracker {
  final int projectId;
  late IOWebSocketChannel channel;

  ProjectProgressTracker(this.projectId) {
    channel = IOWebSocketChannel.connect('ws://127.0.0.1:8000/ws/progress/$projectId');

    channel.stream.listen((message) {
      Map<String, dynamic> data = jsonDecode(message);
      print("Project ${data['project_id']} progress updated: ${data['progress']}");
    });
  }
}
