import 'package:flutter/material.dart';

void showPasscodeBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Cho phép tùy chỉnh chiều cao
    backgroundColor: Colors.transparent, // Để làm bo góc phía trên
    builder: (context) {
      return const PasscodeWidget();
    },
  );
}

class PasscodeWidget extends StatefulWidget {
  const PasscodeWidget({super.key});

  @override
  State<PasscodeWidget> createState() => _PasscodeWidgetState();
}

class _PasscodeWidgetState extends State<PasscodeWidget> {
  String currentPin = "";
  final int pinLength = 6; // Số lượng ô passcode trong ảnh của bạn là 6

  void onNumberPressed(int number) {
    if (currentPin.length < pinLength) {
      setState(() {
        currentPin += number.toString();
      });
      // Nếu đủ 6 số thì xử lý logic xác thực ở đây
      if (currentPin.length == pinLength) {
        if (currentPin == "797979") {
          debugPrint("Mã PIN đúng!");
          // Thực hiện hành động khi mã PIN đúng, ví dụ: đóng bottom sheet và trả về kết quả
          Navigator.pop(context, true);
        } else {
          debugPrint("Mã PIN sai!");
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Sai mã PIN, vui lòng thử lại!"),
                              backgroundColor: Colors.redAccent,
                              duration: const Duration(seconds: 2),
          ),
          );

          // Hiển thị thông báo lỗi hoặc reset lại currentPin
          setState(() {
            currentPin = "";
          });
        }
        debugPrint("Mã PIN đã nhập: $currentPin");
        // Navigator.pop(context, currentPin);
      }
    }
  }

  void onDelete() {
    if (currentPin.isNotEmpty) {
      setState(() {
        currentPin = currentPin.substring(0, currentPin.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height:
          MediaQuery.of(context).size.height * 0.7, // Chiều cao 70% màn hình
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 1. Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Nhập passcode",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // 2. Các ô hiển thị Passcode (Dấu chấm tròn)
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(pinLength, (index) {
              bool isFilled = index < currentPin.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isFilled
                          ? Colors.grey[400]
                          : Colors.grey[200], // Màu xám khi đã nhập
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                ),
              );
            }),
          ),
          const SizedBox(height: 30),
          TextButton(
            onPressed: () {}, // Logic quên mật khẩu
            child: const Text(
              "Quên passcode",
              style: TextStyle(color: Colors.black54),
            ),
          ),

          const Spacer(),

          // 3. Bàn phím số (Custom Numeric Keypad)
          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Column(
              children: [
                buildNumberRow([1, 2, 3]),
                buildNumberRow([4, 5, 6]),
                buildNumberRow([7, 8, 9]),
                Row(
                  children: [
                    const Expanded(child: SizedBox()), // Ô trống bên trái số 0
                    buildNumberButton(0),
                    Expanded(
                      child: IconButton(
                        icon: const Icon(Icons.backspace_outlined, size: 28),
                        onPressed: onDelete,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget tạo hàng số
  Widget buildNumberRow(List<int> numbers) {
    return Row(children: numbers.map((n) => buildNumberButton(n)).toList());
  }

  // Helper Widget tạo nút bấm số
  Widget buildNumberButton(int number) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: () => onNumberPressed(number),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 55,
              alignment: Alignment.center,
              child: Text(
                "$number",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
