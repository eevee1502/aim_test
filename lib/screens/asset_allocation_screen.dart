import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme/aim_color.dart';
import '../core/models/asset_data.dart';
import '../core/providers/asset_provider.dart';

class AssetAllocationScreen extends ConsumerWidget {
  const AssetAllocationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetListAsync = ref.watch(assetProvider);

    return Scaffold(
      backgroundColor: Colors.black87,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height:16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildPieChart(assetListAsync),
                const SizedBox(width: 32),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "장기투자에 적합한\n적극적인 자산배분",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 24),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "'평생안정 은퇴자금'",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: "에\n최적화된 자산배분입니다.",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ],
            ),
            const SizedBox(height:36),
            _buildAssetList(assetListAsync)
          ],
        ),
      ),
    );
  }

  Color _getAssetColor(String type) {
    switch (type) {
      case "stock": return AimColors.chart_1;
      case "bond": return AimColors.chart_2;
      case "etc": return AimColors.chart_3;
      default: return AimColors.chart_4;
    }
  }

  Widget _buildPieChart(AsyncValue<List<AssetData>> assetListAsync) {
    return assetListAsync.when(
      data: (assetList) => SizedBox(
        width: 200,
        height: 200,
        child: PieChart(
          PieChartData(
            startDegreeOffset: -90,
            sectionsSpace: 1,
            centerSpaceRadius: 40,
            sections: assetList.map((e) => PieChartSectionData(
                color: _getAssetColor(e.type),
                value: e.ratio,
                radius: 50,
                title: ""
            )).toList(),
          ),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text("데이터를 불러오는 중 오류 발생", style: TextStyle(color: Colors.red))),
    );
  }

  Widget _buildAssetList(AsyncValue<List<AssetData>> assetListAsync) {
    return assetListAsync.when(
      data:(assetList) {
        Map<String, List<AssetData>> groupedAssets = _groupAssetsByType(assetListAsync.value!);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAssetCategory("주식형 자산", groupedAssets["stock"] ?? []),
            const SizedBox(height:36),
            _buildAssetCategory("채권형 자산", groupedAssets["bond"] ?? []),
            const SizedBox(height:36),
            _buildAssetCategory("기타 자산", groupedAssets["etc"] ?? []),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Text(
          "보유중인 자산이 없습니다.",
          style: TextStyle(
              color: Colors.white,
              fontSize: 16
          ),
        ),
      ),
    );
  }

  Map<String, List<AssetData>> _groupAssetsByType(List<AssetData> assets) {
    Map<String, List<AssetData>> groupedAssets = {
      "stock": [],  //주식
      "bond": [],   //채권
      "etc": [],    //기타
    };

    for (var asset in assets) {
      if (groupedAssets.containsKey(asset.type)) {
        groupedAssets[asset.type]!.add(asset);
      }
    }

    return groupedAssets;
  }

  Widget _buildAssetCategory(String title, List<AssetData> assets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...assets.map((asset) => _buildAssetItem(asset)).toList(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAssetItem(AssetData asset) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            asset.securityName,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        SizedBox(width: 24),
        Expanded(
          child: LinearProgressIndicator(
            value: asset.ratio / 100,
            backgroundColor: Colors.grey.shade800,
            color: _getAssetColor(asset.type),
          ),
        ),
        SizedBox(width: 24),
        SizedBox(
          width: 60,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              "${asset.ratio.toStringAsFixed(2)}%",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
