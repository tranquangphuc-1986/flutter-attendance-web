class StatisticsExcel {
  final String ten;
  final String donVi;
  final int co_Mat;
  final int cong_Tac;
  final int bi_Om;
  final int nghi_Phep;
  final int di_Hoc;
  final int viec_Rieng;
  final int khong_Lydo;
  final int di_Tre;

  StatisticsExcel({
    required this.ten,
    required this.donVi,
    required this.co_Mat,
    required this.cong_Tac,
    required this.bi_Om,
    required this.nghi_Phep,
    required this.di_Hoc,
    required this.viec_Rieng,
    required this.khong_Lydo,
    required this.di_Tre,
  });
  // factory StatisticsExcel.fromMap(Map<String, String> map) {
  //   return StatisticsExcel(
  //       ten: map['ten'] ?? '',
  //       donVi: map['donVi'] ?? '',
  //       co_Mat: map['co_Mat'],
  //       cong_Tac: map['cong_Tac'] ?? '',
  //       bi_Om: map['bi_Om'] ?? '',
  //       nghi_Phep: map['nghi_Phep'] ?? '',
  //       di_Hoc: map['di_Hoc'] ?? '',
  //       viec_Rieng: map['viec_Rieng'] ?? '',
  //       khong_Lydo: map['khong_Lydo'] ?? '',
  //       di_Tre: map['di_Tre'] ?? '',
  //   );
  // }
}
