// autoMarkNotChecked.js
const { Firestore, Timestamp } = require("@google-cloud/firestore");

// Đọc Service Account từ biến môi trường (GitHub Secret)
if (!process.env.FIREBASE_TOKEN_PHUC) {
  console.error("❌ Missing FIREBASE_TOKEN_PHUC env variable");
  process.exit(1);
}

// Parse JSON từ secret
let serviceAccount;
try {
  serviceAccount = JSON.parse(process.env.FIREBASE_TOKEN_PHUC);
} catch (err) {
  console.error("❌ Invalid FIREBASE_TOKEN_PHUC JSON");
  process.exit(1);
}

// Khởi tạo Firestore client
const firestore = new Firestore({
  projectId: serviceAccount.project_id,
  credentials: {
    client_email: serviceAccount.client_email,
    private_key: serviceAccount.private_key.replace(/\\n/g, '\n'),
  },
});

async function autoMarkNotChecked() {
  const today = new Date();
  const startOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate(), 18, 0, 0);
  const endOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate(), 20, 15, 0);

  const startTs = Timestamp.fromDate(startOfDay);
  const endTs = Timestamp.fromDate(endOfDay);

  const usersSnap = await firestore.collection("userLogin").get();
  let updatedCount = 0;

  for (const userDoc of usersSnap.docs) {
    const userData = userDoc.data();

    // Kiểm tra phone
    if (!userData.phone) {
      console.warn(`⚠️ User ${userDoc.id} không có phone, bỏ qua.`);
      continue;
    }

    // Kiểm tra xem user này đã có bản ghi điểm danh hôm nay chưa (theo phone)
    const attendanceSnap = await firestore
      .collection("attendanceqr")
      .where("phone", "==", userData.phone)
      .where("timestamp", ">=", startTs)
      .where("timestamp", "<=", endTs)
      .limit(1)
      .get();

    if (attendanceSnap.empty) {
      // Chưa có điểm danh hôm nay -> thêm bản ghi NOT_CHECKED
      await firestore.collection("attendanceqr").add({
        phone: userData.phone,
        name: userData.name || null,
        status: "Chưa điểm danh",
        note: "Quá giờ điểm danh",
        method: "Tự động",
        timestamp: Timestamp.now(),
      });
      updatedCount++;
    }
  }

  console.log(`✅ Đã cập nhật ${updatedCount} sinh viên chưa điểm danh thành NOT_CHECKED`);
}

// Chạy hàm
autoMarkNotChecked().catch((err) => {
  console.error("❌ Lỗi khi chạy autoMarkNotChecked:", err);
  process.exit(1);
});
