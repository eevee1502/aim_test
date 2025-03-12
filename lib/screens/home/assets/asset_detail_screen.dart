import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/asset_data.dart';
import '../../../core/providers/asset_provider.dart';
import '../../../core/theme/aim_color.dart';

class AssetDetailScreen extends ConsumerWidget {
  final String securityName;

  const AssetDetailScreen({super.key, required this.securityName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetListAsync = ref.watch(assetProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AimColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          ActionChip(
            onPressed: () {},
            backgroundColor: AimColors.primary,
            labelPadding: EdgeInsets.zero,
            padding: EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.white, width: 1.5),
            ),
            label: const Text("ETF란?", style: TextStyle(color: Colors.white, fontSize: 10)),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: assetListAsync.when(
        data: (assetList) {
          bool isTotal = securityName == "all";
          List<AssetData> filteredAssets;

          if (isTotal) {
            filteredAssets = assetList;
          } else {
            filteredAssets = assetList.where((a) => a.securityName == securityName).toList();
          }

          return Stack(
            children: [
              Container(
                color: AimColors.primary,
                height: 180
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(isTotal? "전체 자산개요":filteredAssets.first.securityName, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AimColors.background),),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        isTotal
                            ? "전체 보유 자산 및 개별 종목의 상세 정보를 확인할 수 있습니다."
                            : "각 ETF 종목별 기본 정보, 보유 수량,\n최근 1일 수익률 정보입니다.",
                        style: TextStyle(color: AimColors.background, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.only(bottom: 36),
                        itemCount: filteredAssets.length,
                        itemBuilder: (context, index) => _buildETFCard(filteredAssets[index]),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text("데이터를 불러올 수 없습니다. ($err)", style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }

  Widget _buildETFCard(AssetData asset) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "iShares.",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    asset.securityName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    asset.securityDescription,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  "전일대비 수익률",
                  style: TextStyle(fontSize: 12, color: Colors.black45),
                ),
                Text(
                  "${asset.ratio >= 0 ? "+":"-"}${asset.ratio.toStringAsFixed(2)}%",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: asset.ratio >= 0 ? Colors.blue : Colors.red,
                  ),
                ),
                Text(
                  "${asset.quantity}주",
                  style: const TextStyle(fontSize: 30, color: AimColors.primary),
                ),
              ],
            ),
          ],
        )
      ),
    );
  }
}
