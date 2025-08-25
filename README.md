# Ứng dụng Sổ Chi Tiêu Flutter

Ứng dụng quản lý tài chính cá nhân với kiến trúc offline-first, được phát triển bằng Flutter và tích hợp với backend C# API.

## 🚀 Tính năng chính

### 1. Chế độ Offline-First
- **Sử dụng ngay không cần đăng nhập**: Dữ liệu được lưu trữ cục bộ bằng SQLite
- **Hoạt động offline hoàn toàn**: Thêm/sửa/xóa giao dịch, xem thống kê
- **Đồng bộ hai chiều**: Khi có mạng và đăng nhập, dữ liệu được đồng bộ với server

### 2. Quản lý giao dịch
- Thêm mới giao dịch thu/chi
- Sửa/xóa giao dịch
- Phân loại theo danh mục
- Ghi chú và mô tả
- Hỗ trợ nhiều đơn vị tiền tệ

### 3. Danh mục (Categories)
- Quản lý danh mục thu/chi
- Icon và màu sắc tùy chỉnh
- Sắp xếp theo thứ tự

### 4. Dashboard & Báo cáo
- Tổng quan thu chi
- Số dư hiện tại
- Biểu đồ thống kê
- Báo cáo theo thời gian

### 5. Cài đặt & Tùy chỉnh
- Dark mode
- Quản lý tài khoản
- Đăng nhập/đăng xuất
- Đồng bộ dữ liệu

## 🏗️ Kiến trúc

### Clean Architecture
```
lib/
├── core/                    # Core functionality
│   ├── constants/          # App constants
│   ├── errors/             # Error handling
│   ├── network/            # Network utilities
│   └── utils/              # Utility functions
├── features/               # Feature modules
│   ├── auth/              # Authentication
│   ├── home/              # Home & Dashboard
│   ├── income_expense/    # Transaction management
│   ├── category/          # Category management
│   ├── report/            # Reports & Analytics
│   └── settings/          # App settings
└── shared/                # Shared components
    ├── models/            # Data models
    ├── providers/         # State management (Riverpod)
    ├── services/          # Business logic services
    └── widgets/           # Reusable widgets
```

### State Management
- **Riverpod**: Quản lý state và dependency injection
- **Hive**: Local storage cho models
- **SQLite**: Database offline

### Services
- **DatabaseService**: Quản lý SQLite database
- **ApiService**: Giao tiếp với backend API
- **SyncService**: Đồng bộ dữ liệu offline/online

## 🛠️ Cài đặt & Chạy

### Yêu cầu hệ thống
- Flutter SDK 3.9.0+
- Dart 3.0.0+
- Android Studio / VS Code
- Android 10+ / iOS 14+

### Cài đặt dependencies
```bash
flutter pub get
```

### Chạy ứng dụng
```bash
# Android
flutter run

# iOS
flutter run -d ios

# Web
flutter run -d chrome
```

### Build ứng dụng
```bash
# Android APK
flutter build apk

# Android App Bundle
flutter build appbundle

# iOS
flutter build ios
```

## 📱 Màn hình chính

### 1. Welcome Page
- Chọn "Dùng ngay không cần đăng nhập"
- Đăng nhập tài khoản
- Đăng ký tài khoản mới

### 2. Home Page (Dashboard)
- Tổng quan thu chi
- Số dư hiện tại
- Hành động nhanh
- Giao dịch gần đây

### 3. Giao dịch
- Danh sách tất cả giao dịch
- Tìm kiếm và lọc
- Thêm giao dịch mới

### 4. Báo cáo
- Biểu đồ thu chi
- Thống kê theo thời gian
- Phân tích theo danh mục

### 5. Cài đặt
- Quản lý tài khoản
- Chủ đề (Dark/Light mode)
- Đồng bộ dữ liệu
- Đăng xuất

## 🔄 Đồng bộ dữ liệu

### Chế độ Offline
- Dữ liệu được lưu trữ cục bộ trong SQLite
- Ứng dụng hoạt động bình thường
- Dữ liệu được đánh dấu "chưa đồng bộ"

### Chế độ Online
- Khi có mạng, hiển thị gợi ý đăng nhập
- Sau khi đăng nhập, đồng bộ hai chiều
- Dữ liệu offline được gửi lên server
- Dữ liệu server được tải về local

### Quy trình đồng bộ
1. Kiểm tra kết nối mạng
2. Đồng bộ dữ liệu local lên server
3. Tải dữ liệu mới từ server
4. Cập nhật trạng thái đồng bộ

## 🗄️ Database Schema

### Bảng Users
- id, userName, email, fullName, phone, avatar
- createdAt, updatedAt, isOnline
- accessToken, refreshToken

### Bảng Categories
- id, name, text, icon, color, order
- type (income/expense), createdAt, updatedAt
- isSynced, userId

### Bảng IncomeExpenses
- id, amount, currency, date, description
- type, categoryId, createdAt, updatedAt
- isSynced, userId

## 🔌 API Integration

### Endpoints
- `POST /api/account/login` - Đăng nhập
- `POST /api/account/register` - Đăng ký
- `GET /api/income-expense` - Lấy danh sách giao dịch
- `POST /api/income-expense` - Tạo giao dịch mới
- `PUT /api/income-expense/{id}` - Cập nhật giao dịch
- `DELETE /api/income-expense/{id}` - Xóa giao dịch
- `GET /api/category` - Lấy danh sách danh mục
- `POST /api/income-expense/sync` - Đồng bộ dữ liệu

### Authentication
- JWT token-based authentication
- Auto-refresh token
- Offline mode support

## 🎨 UI/UX Features

### Material Design 3
- Modern UI components
- Responsive design
- Smooth animations

### Dark Mode Support
- Tự động theo hệ thống
- Chuyển đổi thủ công
- Theme persistence

### Localization
- Hỗ trợ tiếng Việt
- Có thể mở rộng cho ngôn ngữ khác

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Widget Tests
```bash
flutter test test/widget_test.dart
```

### Integration Tests
```bash
flutter test integration_test/
```

## 📦 Dependencies

### Core
- `flutter_riverpod`: State management
- `sqflite`: SQLite database
- `hive`: Local storage
- `dio`: HTTP client

### UI
- `fl_chart`: Charts and graphs
- `intl`: Internationalization
- `flutter_svg`: SVG support

### Utilities
- `uuid`: Unique ID generation
- `connectivity_plus`: Network connectivity
- `shared_preferences`: Preferences storage

## 🚀 Deployment

### Android
1. Cập nhật `android/app/build.gradle`
2. Cấu hình signing
3. Build APK hoặc App Bundle

### iOS
1. Cập nhật `ios/Runner/Info.plist`
2. Cấu hình signing
3. Build và archive

## 🤝 Đóng góp

1. Fork repository
2. Tạo feature branch
3. Commit changes
4. Push to branch
5. Tạo Pull Request

## 📄 License

Dự án này được phát triển cho mục đích học tập và nghiên cứu.

## 📞 Liên hệ

- **Tác giả**: [Tên của bạn]
- **Email**: [email@example.com]
- **GitHub**: [github.com/username]

## 🙏 Cảm ơn

Cảm ơn bạn đã quan tâm đến dự án Sổ Chi Tiêu Flutter! Hãy đóng góp ý kiến và cải tiến để ứng dụng ngày càng hoàn thiện hơn.
