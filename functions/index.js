const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
const db = admin.firestore();

exports.autoMarkNotChecked = functions.pubsub
  .schedule("1 11 * * 1-5") // 11:01 từ thứ 2 đến thứ 6
  .timeZone("Asia/Ho_Chi_Minh")
  .onRun(async (context) => {
    const today = new Date();
    const startOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate(), 0, 0, 0);
    const endOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate(), 23, 59, 59);

    const startTs = admin.firestore.Timestamp.fromDate(startOfDay);
    const endTs = admin.firestore.Timestamp.fromDate(endOfDay);

    const usersSnap = await db.collection("userLogin").get();

    for (const userDoc of usersSnap.docs) {
      const userData = userDoc.data();

      // Kiểm tra sinh viên này đã có điểm danh hôm nay chưa
      const attendanceSnap = await db.collection("attendanceqr")
        .where("uid", "==", userDoc.id)
        .where("timestamp", ">=", startTs)
        .where("timestamp", "<=", endTs)
        .limit(1)
        .get();

      if (attendanceSnap.empty) {
        // Nếu chưa có, ghi "NOT_CHECKED"
        await db.collection("attendanceqr").add({
          uid: userDoc.id,
          name: userData.name || "",
          phone: userData.phone || "",
          status: "NOT_CHECKED",
          note: "Quá giờ điểm danh",
          method: "AUTO",
          timestamp: admin.firestore.Timestamp.now(),
        });
      }

    }

    console.log("✅ Đã cập nhật trạng thái NOT_CHECKED cho các sinh viên chưa điểm danh");
    return null;
  });