import 'package:flutter/material.dart';

Widget buildAvatar(String imageUrl) {
  return Padding(
    padding: const EdgeInsets.only(right: 2),
    child: CircleAvatar(
      radius: 10,
      backgroundImage: NetworkImage(imageUrl),
    ),
  );
}

Widget buildExtraMembers(String count) {
  return Padding(
    padding: const EdgeInsets.only(left: 2),
    child: CircleAvatar(
      radius: 8,
      backgroundColor: Colors.grey[300],
      child: Text(count, style: const TextStyle(fontSize: 10, color: Colors.black)),
    ),
  );
}
