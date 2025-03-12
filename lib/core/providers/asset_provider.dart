import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../models/asset_data.dart';

final assetProvider = FutureProvider<List<AssetData>>((ref) async {
  final String jsonString = await rootBundle.loadString('assets/data/api_response.json');
  final Map<String, dynamic> jsonData = json.decode(jsonString);

  return (jsonData['data']['asset_list'] as List)
      .map((e) => AssetData.fromJson(e))
      .toList();
});
