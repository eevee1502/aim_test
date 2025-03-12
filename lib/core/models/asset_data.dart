class AssetData {
  final String securityName;
  final String type;
  final String securitySymbol;
  final String securityDescription;
  final int quantity;
  final double ratio;

  AssetData({
    required this.securityName,
    required this.type,
    required this.securitySymbol,
    required this.securityDescription,
    required this.quantity,
    required this.ratio,
  });

  factory AssetData.fromJson(Map<String, dynamic> json) {
    return AssetData(
      securityName: json["security_name"] ?? "",
      type: json["type"] ?? "",
      securitySymbol: json["security_symbol"] ?? "",
      securityDescription: json["security_description"] ?? "",
      quantity: json["quantity"] ?? 0,
      ratio: (json["ratio"] as num).toDouble(),
    );
  }
}
