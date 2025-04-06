class Post {
  final String author;
  final String time;
  final String title;
  final String detail;
  final String imageUrl;

  /// Dữ liệu mẫu: 5 lưu ý khi lần đầu nuôi thú cưng
  static final List<Post> sampleData = [
    Post(
      author: 'Alice',
      time: '2025-04-01 09:00',
      title: 'Chuẩn bị không gian sống',
      detail:
          'Trước khi đưa thú cưng về, hãy chuẩn bị không gian an toàn: lồng/chuồng phù hợp, ổ nằm ấm áp, tránh nơi gió lùa và xa tầm với trẻ nhỏ.',
      imageUrl: 'https://example.com/images/pet_space.jpg',
    ),
    Post(
      author: 'Bob',
      time: '2025-04-02 10:30',
      title: 'Chế độ dinh dưỡng cơ bản',
      detail:
          'Lần đầu nuôi, chọn thức ăn phù hợp với độ tuổi và giống: đảm bảo đủ protein, vitamin và khoáng chất. Không đổi khẩu phần đột ngột để tránh rối loạn tiêu hóa.',
      imageUrl: 'https://example.com/images/pet_food.jpg',
    ),
    Post(
      author: 'Carol',
      time: '2025-04-03 14:15',
      title: 'Thói quen vệ sinh',
      detail:
          'Tắm rửa và chải lông định kỳ, vệ sinh chuồng/lồng sạch sẽ. Với chó/mèo, tập sử dụng khay vệ sinh sớm để giảm stress và giữ nhà cửa sạch sẽ.',
      imageUrl: 'https://example.com/images/pet_hygiene.jpg',
    ),
    Post(
      author: 'David',
      time: '2025-04-04 16:45',
      title: 'Khám sức khỏe định kỳ',
      detail:
          'Lên lịch khám thú y lần đầu ngay sau khi đón về, tiêm phòng đầy đủ. Theo dõi cân nặng và tiêm nhắc phòng bệnh đúng hạn.',
      imageUrl: 'https://example.com/images/vet_checkup.jpg',
    ),
    Post(
      author: 'Emma',
      time: '2025-04-05 18:00',
      title: 'Xây dựng mối liên kết',
      detail:
          'Dành thời gian chơi đùa, vuốt ve để thú cưng cảm thấy an toàn. Sử dụng lời khen và phần thưởng để huấn luyện các thói quen tốt ngay từ đầu.',
      imageUrl: 'https://example.com/images/pet_bonding.jpg',
    ),
  ];

  Post({
    required this.author,
    required this.time,
    required this.title,
    required this.detail,
    required this.imageUrl,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        author: json['author'] as String,
        time: json['time'] as String,
        title: json['title'] as String,
        detail: json['detail'] as String,
        imageUrl: json['imageUrl'] as String,
      );
}
