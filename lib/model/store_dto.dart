class StoreDto {
  final int? id;
  final String? name;
  final String? chainName;
  final String? region;
  final String? address;
  final double? latitude;
  final double? longitude;
  final double? complianceScore;
  final String? status;

  StoreDto({
    this.id,
    this.name,
    this.chainName,
    this.region,
    this.address,
    this.latitude,
    this.longitude,
    this.complianceScore,
    this.status,
  });

  factory StoreDto.fromJson(Map<String, dynamic> json) {
    return StoreDto(
      id: json['id'] as int?,
      name: json['name'] as String?,
      chainName: json['chainName'] as String?,
      region: json['region'] as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      complianceScore: (json['complianceScore'] as num?)?.toDouble(),
      status: json['status'] as String?,
    );
  }
}