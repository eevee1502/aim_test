import 'package:flutter/material.dart';
import '../../../core/models/asset_data.dart';

class AssetDetailScreen extends StatelessWidget {
  final AssetData asset;

  const AssetDetailScreen({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(asset.securityName),
        backgroundColor: Colors.black87,
      ),
      backgroundColor: Colors.black87,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "자산 상세 정보",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            _buildDetailRow("자산명", asset.securityName),
            _buildDetailRow("유형", asset.type),
            _buildDetailRow("심볼", asset.securitySymbol),
            _buildDetailRow("설명", asset.securityDescription),
            _buildDetailRow("보유 수량", "${asset.quantity}"),
            _buildDetailRow("비율", "${asset.ratio.toStringAsFixed(2)}%"),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(title, style: TextStyle(color: Colors.white70, fontSize: 16))),
          Expanded(child: Text(value, style: TextStyle(color: Colors.white, fontSize: 16))),
        ],
      ),
    );
  }
}
