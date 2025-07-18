import 'package:app_02/models/model.dart';
import 'package:app_02/travel/more_detail.dart';
import 'package:app_02/travel/popular_cate.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

int seletedIndex = 0;
List<String> categoryList = [
  "Lời dặn",
  "Lịch sử",
  "Di tích",
  "Kiến thức",
  "Hoạt động",
];
final String url = 'https://www.google.com.vn'; // Trang web Bộ Công an

Future<void> _launchURL() async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Không thể mở URL: $url';
  }
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        child: SingleChildScrollView(
          child:
          //..................
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            //***********
            child: Stack(
              children: [
                Stack(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height / 0.2,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.blueAccent,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height / 1.75,
                      width: MediaQuery.of(context).size.width,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFFFFBFB), Color(0XFFF3ECEE)],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(00),
                          bottomRight: Radius.circular(00),
                        ), //Bo góc trên chữ Tiện ích
                      ),
                      child: Stack(
                        children: [
                          Container(
                            height: 260,
                            width: double.infinity,
                            child: SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 20),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Image.asset(
                                            "img/grid.png",
                                            height: 30,
                                          ),
                                          Image.asset(
                                            "img/search.png",
                                            height: 30,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    // const Text(
                                    //   "Tư liệu",
                                    //   style: TextStyle(
                                    //     fontSize: 25,
                                    //     fontWeight: FontWeight.bold,
                                    //   ),
                                    // ),
                                    //const SizedBox(height: 40),
                                    // nature selection parts
                                    natureSelection(),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            top:
                                150, //khoảng cách giữa dòng các ảnh và với dòng Lời dặn, di tích
                            child: SizedBox(
                              height: 350, //chiều cao của dòng các ảnh
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
                                            top: 20,
                                            left: 30,
                                          ), // khoảng cách giữa các ảnh
                                          child: Hero(
                                            tag: location.image,
                                            child: Container(
                                              height: 320,
                                              width:
                                                  250, //chiều rộng từng dòng ảnh
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30),
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
                                          top: 40,
                                          left: 220,
                                          child: Container(
                                            height: 50,
                                            width: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.white38,
                                              borderRadius:
                                                  BorderRadius.circular(200),
                                            ),
                                            child: const Icon(
                                              Icons.bookmark,
                                              size: 30,
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


                //Gọi phần tiện ích
                Align(
                 alignment: Alignment.bottomCenter,
                  //alignment: Alignment.topCenter,
                  child: Container(
                    //Kích thước của Container
                    height:
                        MediaQuery.of(context).size.height /2.33,   //kéo lên, xuống container chứa Tiện ích
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      //Độ trog suốt màu nền
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        //colors: [Colors.yellow, Colors.red, Colors.blue]
                        colors: [Color(0XFFF3ECEE), Color(0xFFFFFBFB)],
                      ),
                    ),
                    child:
                        const PopularCategories(), //gọi icon phần Tiện ích từ popular_cate.dart
                  ),
                ),
                //..........................
                //Phần tiện ích
                //   Align(
                //     alignment: Alignment.bottomCenter,
                //     child: Container(
                //       height:
                //           MediaQuery.of(context).size.height /
                //           2.45, //kéo lên, xuống container chứa Tiện ích
                //       width: MediaQuery.of(context).size.width,
                //       decoration: const BoxDecoration(
                //         color: Colors.white,
                //         borderRadius: BorderRadius.only(
                //           topRight: Radius.circular(90), //bo tròn chỗ 'Mở rộng'
                //         ),
                //       ),
                //       // For bottom parts
                //       child: const PopularCategories(),
                //     ),
                //   ),
              ],
            ),
            //***********
          ),

          //..........................................................
        ),
      ),
    );
  }

  Positioned bestNatureSlider(LocationDetail location) {
    return Positioned(
      top: 260, //vị trí chữ trong dòng hình
      left: 100,
      child: Column(
        children: [
          Text(
            location.name,
            style: const TextStyle(
              fontSize: 20,
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
                  fontSize: 18,
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

  Stack natureSelection() {
    return Stack(
      children: [
        const Positioned(
          bottom: -12, //vị trí dấu '-' dưới lời dặn
          left: 45,
          child: Text(
            "_",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 40,
              color: Color(0xFFA36C88),
            ),
          ),
        ),
        SizedBox(
          height: 40, //lên, xuống dấu '-' dưới Lời dặn
          child: ListView.builder(
            itemCount: categoryList.length,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Text(
                  categoryList[index],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color:
                        seletedIndex == index
                            ? const Color(0xFFA36C88)
                            : const Color(0xFFE2CBD4),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
