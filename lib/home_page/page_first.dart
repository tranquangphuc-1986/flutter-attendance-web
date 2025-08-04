import 'package:app_02/models/model.dart';
import 'package:app_02/travel/more_detail.dart';
import 'package:app_02/travel/popular_cate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PageFirst extends StatefulWidget {
  const PageFirst({super.key});
  @override
  State<PageFirst> createState() => _MyPageFirstState();
}

int selectedIndex = 0;
// List<String> categoryList = ["Lời dặn", "Lịch sử", "Di tích","Kiến thức","Hoạt động",];
Future<void> _launchURL() async {
  final url = Uri.parse('https://congan.quangngai.gov.vn');
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw 'Không thể mở URL: $url';
  }
}
Future<void> _launchFb() async {
  final url = Uri.parse('https://facebook.com/thongtinXanh.QNg');
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw 'Không thể mở URL: $url';
  }
}
Future<void> _map() async {
  final url = Uri.parse('https://sapnhap.bando.com.vn/?zarsrc=31&utm_source=zalo&utm_medium=zalo&utm_campaign=zalo');
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw 'Không thể mở URL: $url';
  }
}

class _MyPageFirstState extends State<PageFirst> {
  String currentName = '';
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }
  Future<void> fetchUserInfo() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc =
      await FirebaseFirestore.instance
          .collection('userLogin')
          .doc(uid)
          .get();
      setState(() {
        currentName = doc['name'];
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi lấy dữ liệu: $e");
      setState(() {
        isLoading = false;
      }); // Cập nhật giao diện
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        child: SingleChildScrollView(
          child: Column(
            children: [
              //1.phần hình ảnh
              // SizedBox(//CÓ THỂ THAY BẰNG CONTAINER
              //height: MediaQuery.of(context).size.height,
              // width: MediaQuery.of(context).size.width,
              Container(
                child: Stack(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height / 2.7,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.yellowAccent,
                    ),
                    Container(
                      //chứa phần lời dặn, ảnh, tìm kiếm
                      height: MediaQuery.of(context).size.height / 2.72,
                      width: MediaQuery.of(context).size.width,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.blue,
                            Colors.blue,
                          ], //[Color(0xFFFFFBFB), Color(0XFFF3ECEE)],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(00),
                          bottomRight: Radius.circular(00),
                        ), //Bo góc phần container màu xanh chứa hình ảnh, chuông..
                      ),
                      child: Stack(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.2, //260,
                            width: double.infinity,
                            child: SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.only(top:10, left: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 20),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                            const Icon(
                                            Icons.person,
                                            color: Colors.yellowAccent,
                                            size: 30,
                                          ),
                                          Text(
                                            "Xin chào! ${currentName.isNotEmpty ? currentName: "..."}",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.yellowAccent),
                                          ),
                                          const Icon(
                                            Icons.add_alert_outlined,
                                            color: Colors.yellowAccent,
                                            size: 30,
                                          ),
                                        ],
                                      ),
                                    ),
                                    //const SizedBox(height: 20,),
                                    // nature selection parts
                                    //natureSelection(),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            top: MediaQuery.of(context).size.height * 0.11,
                            //150, //khoảng cách giữa dòng các ảnh và với dòng Lời dặn, di tích
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.25, //220, //chiều cao của sizedBox chứa các ảnh
                              width: MediaQuery.of(context).size.width,
                              child: ListView.builder(
                                itemCount: locationItems.length,
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  LocationDetail location =
                                      locationItems[index];
                                  return GestureDetector(
                                    // For navigating to second screen.
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => MoreDetail(
                                                location: location,
                                              ),
                                        ),
                                      );
                                    },
                                    child: Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 10,
                                            left: 8,
                                          ), // khoảng cách giữa các ảnh
                                          child: Hero(
                                            tag: location.image,
                                            child: Container(
                                              height: //170,
                                              MediaQuery.of(
                                                context,
                                              ).size.height * 0.24, //chiều cao của ảnh, không được cao hơn SizedBox 0.25
                                              width: 120,
                                              // MediaQuery.of(
                                              //   context,
                                              // ).size.width *
                                              // 0.40,  //chiều rộng từng dòng ảnh
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                image: DecorationImage(
                                                  image: AssetImage(
                                                    location.image,
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // slider for image ,name and location
                                        bestNatureSlider(location),
                                        //Vị trí, kích thước Hình ảnh lá cờ trắng trong ảnh
                                        Positioned(
                                          top: 30,
                                          left: 70,
                                          child: Container(
                                            height: 45,
                                            width: 45,
                                            decoration: BoxDecoration(
                                              color: Colors.white38,
                                              borderRadius:
                                                  BorderRadius.circular(200),
                                            ),
                                            child: const Icon(
                                              Icons.bookmark,
                                              size: 28,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              //..........Kết thúc phần hình ảnh
              // 2. Phần Banner
              SizedBox(height: 2),
              GestureDetector(
                onTap: _launchFb,
                child: Container(
                  height: 70,
                 // height: MediaQuery.of(context).size.height* 0.08,
                  margin: EdgeInsets.all(12),
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.yellow[700], // Màu vàng đặc trưng
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shield,
                        color: Colors.blue,
                      ), // Biểu tượng tùy chọn
                      SizedBox(width: 8),
                      Text(
                        'Phòng Tham mưu',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 2),
              InkWell(
                onTap: _launchURL,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: Image.asset(
                    "img/BN.jpg",
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width * 0.93, //380,
                    height: MediaQuery.of(context).size.width * 0.4,
                  ),
                ),
              ),
              //...Kết thúc Banner
              //3. Tạo các icon
              SizedBox(height: 4),
              Container(child: const PopularCategories()),
            ],
          ),
        ),
      ),
    );
  }

  Positioned bestNatureSlider(LocationDetail location) {
    return Positioned(
      top: 120, //vị trí chữ trong dòng hình
      left: 30,
      child: Column(
        children: [
          Text(
            location.name,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              const Icon(Icons.location_on, size: 30, color: Colors.white),
              Text(
                location.address,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Stack natureSelection() {
  //   return Stack(
  //     children: [
  //       const Positioned(
  //         bottom: -6, //vị trí dấu '-' dưới lời dặn
  //         left: 45,
  //         child: Text(
  //           "_",
  //           style: TextStyle(
  //             fontWeight: FontWeight.bold,
  //             fontSize: 40,
  //             color: Color(0xFFA36C88),
  //           ),
  //         ),
  //       ),
  //       SizedBox(
  //         height: 40, //lên, xuống dấu '-' dưới Lời dặn
  //         child: ListView.builder(
  //           itemCount: categoryList.length,
  //           shrinkWrap: true,
  //           physics: const BouncingScrollPhysics(),
  //           scrollDirection: Axis.horizontal,
  //           itemBuilder: (context, index) {
  //             return Padding(
  //               padding: const EdgeInsets.only(right: 20),
  //               child: Text(
  //                 categoryList[index],
  //                 style: TextStyle(
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 20,
  //                   color:
  //                       selectedIndex == index
  //                           ? const Color(0xFFA36C88)
  //                           : const Color(0xFFE2CBD4),
  //                 ),
  //               ),
  //             );
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }
}

