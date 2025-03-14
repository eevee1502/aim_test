import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/models/asset_data.dart';
import '../../../core/providers/asset_provider.dart';
import '../../../core/theme/aim_color.dart';
import 'asset_detail_screen.dart';

class AssetAllocationScreen extends ConsumerWidget {
  AssetAllocationScreen({super.key});
  final selectedIndexProvider = StateProvider<int?>((ref) => null);

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
                Column(
                  children: [
                    _buildPieChart(context, assetListAsync, ref),
                    const SizedBox(height:12),
                    ActionChip(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AssetDetailScreen(securityName: "all"),
                          ),
                        );
                      },
                      backgroundColor: Colors.black87,
                      labelPadding: EdgeInsets.zero,
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: Colors.white, width: 1.5),
                      ),
                      label: const Text("전체보기", style: TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                    const Text("차트를 클릭하시면\n개별내역을 볼 수 있습니다.",textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 8)),
                  ],
                ),
                const SizedBox(width: 48),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "장기투자에 적합한\n적극적인 자산배분",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 24),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "'평생안정 은퇴자금'",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          TextSpan(
                            text: "에\n최적화된 자산배분입니다.",
                            style: TextStyle(color: Colors.white70, fontSize: 12),
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

  Widget _buildPieChart(BuildContext context, AsyncValue<List<AssetData>> assetListAsync, WidgetRef ref) {
    return assetListAsync.when(
      data: (assetList) => SizedBox(
        width: 100,
        height: 100,
        child: PieChart(
          PieChartData(
            startDegreeOffset: -90,
            sectionsSpace: 1,
            centerSpaceRadius: 20,
            sections: assetList.asMap().entries.map((entry) {
              final index = entry.key;
              final asset = entry.value;
              final isSelected = index == ref.watch(selectedIndexProvider);

              return PieChartSectionData(
                color: _getAssetColor(asset.type),
                value: asset.ratio,
                radius: isSelected ? 50 : 40,
                title: "",
              );
            }).toList(),
            pieTouchData: PieTouchData(
              touchCallback: (FlTouchEvent event, PieTouchResponse? pieTouchResponse) {
                final selectedIndex = ref.read(selectedIndexProvider.notifier);

                if (event is FlTapUpEvent && pieTouchResponse?.touchedSection != null) {
                  final touchedIndex = pieTouchResponse!.touchedSection!.touchedSectionIndex;

                  if (touchedIndex >= 0 && touchedIndex < assetList.length) {
                    final selectedAsset = assetList[touchedIndex];

                    selectedIndex.state = touchedIndex;

                    Future.delayed(Duration(milliseconds: 100), () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AssetDetailScreen(securityName: selectedAsset.securityName),
                        ),
                      ).then((_) {
                        selectedIndex.state = null;
                      });
                    });
                  }
                }
              },
            ),
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
            fontSize: 11,
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
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13
            ),
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
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13
              ),
            ),
          ),
        ),
      ],
    );
  }
}
