import 'package:flutter/material.dart';

const host = 'https://itruckdispatch.com';
const apikey = '7c1cbe64-0820-11ed-861d-0242ac120002';
Map<String, String> requestHeaders = {
  'Content-type': 'application/json',
  'Accept': 'application/json',
};

errorSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: Colors.red,
    content: Text(text),
    duration: const Duration(seconds: 2),
  ));
}
