class LocationDetail {
  String image;
  String name;
  String address;
  int price;
  double rating;
  int temperature;
  int time;
  String description;

  LocationDetail({
    required this.image,
    required this.name,
    required this.address,
    required this.price,
    required this.description,
    required this.rating,
    required this.temperature,
    required this.time,
  });
}

List<LocationDetail> locationItems = [
  LocationDetail(
    image: "img/dhPV01.jpg",
    name: 'Đại hội',
    address: 'PTM',
    price: 1350,
    rating: 5.0,
    temperature: 19,
    time: 11-7-2025 ,
    description:
    "Ngày 11/7/2025, Đảng bộ Phòng Tham mưu đã tổ chức thành công Đại hội lần thứ I, nhiệm kỳ 2025-20230."
        "Đại hội đã thông qua Quyết định của BTV Đảng uỷ Công an tỉnh chỉ định đồng chí Thượng tá Lương Việt Long là Bí thư Đảng uỷ Phòng Tham mưu",
  ),
  LocationDetail(
    image: "img/xoanhatam_PV01.jpg",
    name: 'Nhà tạm',
    address: 'PTM',
    price: 1350,
    rating: 5.0,
    temperature: 22-6-2025,
    time: 22-6-2025,
    description:
        "Phòng Tham mưu chung tay xoá nhà tạm, nhà dột nát. Ngày 25/6/2025, Phòng Tham mưu đã bàn giao nhà"
            " và phối hợp Ngân hàng BIDV chi nhánh Dung Quất hỗ trợ số tiền 60 triệu đồng cho bà Nguyễn Thị Điểu, 72 tuổi, ở thôn Phước Lộc Tây, xã Tịnh Sơn, huyện Sơn Tịnh ",
  ),
  LocationDetail(
    image: "img/pv01ĐHCAT.jpg",
    name: 'Đại hội',
    address: 'CAT',
    price: 1350,
    rating: 5.0,
    temperature: 22-6-2025,
    time: 30-7-2025,
    description:
    "Tham mưu, phục vụ Đảng ủy Công an tỉnh tổ chức thành công Đại hội đại biểu Đảng bộ Công an tỉnh lần thứ I, nhiệm kỳ 2025-2030",
  ),

  LocationDetail(
    image: "img/hienmau_PV01.jpg",
    name: 'Hiến máu',
    address: 'ĐTN',
    price: 1350,
    rating: 5.0,
    temperature: 22-6-2025,
    time: 2025,
    description:
    "Đoàn viên, thanh niên Phòng Tham mưu xung kích trên mọi mặt trận, nổi bật trong phong trào hiến máu tình nguyện"
  ),


  LocationDetail(
    image: "img/mountain.png",
    name: 'Oyo Lakes',
    address: 'Croatia',
    price: 3250,
    rating: 5.0,
    temperature: 22,
    time:9 ,
    description:
    'Oyo Lake, nestled in a picturesque setting, captivates visitors with its tranquil waters and surrounding lush landscapes. It serves as a haven for relaxation and outdoor activities, offering opportunities for boating,and peaceful walks along its shores',
  ),
  LocationDetail(
    image: "img/thebridge.png",
    name: 'Loygavegur',
    address: 'Iceland',
    price: 2350,
      rating: 4.8,
    temperature: 1,
    time:20 ,
    description:
        "Iceland's nature is renowned for its raw and untamed beauty, characterized by dramatic landscapes shaped by volcanic activity, glaciers, geysers, and cascading waterfalls,if you want to enjoy more then you need to visit this all place.",
  ),

  LocationDetail(
    image: "img/sunrises.png",
    name: 'Sun Rise',
    address: 'UK',
    price: 3500,
      rating: 4.0,
    temperature: 12,
    time:6 ,
    description:
        "At dawn, the Eiffel Tower in Paris becomes a spectacle of beauty as the sun rises behind its iconic silhouette, casting a warm glow over the cityscape.If you want to enjoy more then you need to visit this all place.",
  ),
  LocationDetail(
    image: "img/eiffel_tower.png",
    name: 'Effiel Tower',
    address: 'Paris France',
    price: 3350,
    rating: 4.5,
    temperature: 19,
    time:2 ,
    description:
        ' This enchanting moment draws crowds to witness the breathtaking scene and symbolizes the timeless allure and romantic charm of the French capital, making it an unforgettable experience for visitors from around the world.',
  ),
];
