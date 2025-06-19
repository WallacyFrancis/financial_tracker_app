class Asset {
  final String symbol;
  final String name;
  final String description;
  final String currency;
  final String country;

  Asset({
    required this.symbol,
    required this.name,
    required this.description,
    required this.currency,
    required this.country,
  });

  // Factory constructor para criar um Asset a partir do JSON da API
  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      symbol: json['Symbol'] ?? 'N/A',
      name: json['Name'] ?? 'N/A',
      description: json['Description'] ?? 'No description available.',
      currency: json['Currency'] ?? 'N/A',
      country: json['Country'] ?? 'N/A',
    );
  }
}
