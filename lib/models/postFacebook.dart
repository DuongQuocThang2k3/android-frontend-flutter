class postFacebook {
  int? id;
  String ten;
  String moTa;
  String hinhAnh;
  String anhDaiDien;
  int soLuotThich;
  int soLuotBinhLuan;
  int soLuotChiaSe;

  postFacebook({
    this.id,
    required this.ten,
    required this.moTa,
    required this.hinhAnh,
    required this.anhDaiDien,
    this.soLuotThich = 0,
    this.soLuotBinhLuan = 0,
    this.soLuotChiaSe = 0,
  });

  factory postFacebook.fromJson(Map<String, dynamic> json) {
    return postFacebook(
      id: json['id'] as int?,
      ten: (json['ten'] ?? '').toString(),
      moTa: (json['moTa'] ?? '').toString(),
      hinhAnh: (json['hinhAnh'] ?? '').toString(),
      anhDaiDien: (json['anhDaiDien'] ?? '').toString(),
      soLuotThich: json['soLuotThich'] as int? ?? 0,
      soLuotBinhLuan: json['soLuotBinhLuan'] as int? ?? 0,
      soLuotChiaSe: json['soLuotChiaSe'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ten': ten,
      'moTa': moTa,
      'hinhAnh': hinhAnh,
      'anhDaiDien': anhDaiDien,
      'soLuotThich': soLuotThich,
      'soLuotBinhLuan': soLuotBinhLuan,
      'soLuotChiaSe': soLuotChiaSe,
    };
  }
}