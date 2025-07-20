class DonVi {
  final String ten;
  final String sapNhap;
  final String diaChi;
  final String dienThoai;
  final String tenTCA;
  final String dtTCA;
  final String fb;
  final String hinhAnh;

  DonVi({
    required this.ten,
    required this.sapNhap,
    required this.diaChi,
    required this.dienThoai,
    required this.tenTCA,
    required this.dtTCA,
    required this.fb,
    required this.hinhAnh,
  });
  factory DonVi.fromMap(Map<String, String>map){
    return DonVi(
        ten: map['ten']?? "",
        sapNhap: map['sapNhap']?? "",
        diaChi: map['diaChi']?? "",
        dienThoai: map['dienThoai']?? "",
        tenTCA: map['tenTCA']?? "",
        dtTCA: map['dtTCA']?? "",
        fb: map['fb']?? "",
        hinhAnh: map['hinhAnh']?? "",
    );
  }
}
