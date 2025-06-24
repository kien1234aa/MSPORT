class NewsItem {
  final String title;
  final String content;
  final String imageUrl;

  NewsItem({
    required this.title,
    required this.content,
    required this.imageUrl,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      title: json['title'] ?? '',
      content: json['description'] ?? '',
      imageUrl: json['urlToImage'] ?? 'https://via.placeholder.com/150',
    );
  }
}
