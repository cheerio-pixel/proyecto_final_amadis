class Noticia {
  final String id;
  final String title;
  final String img;
  final String url;
  final String date;
  final DateTime parsedDate; // Add this field

  Noticia({
    required this.id,
    required this.title,
    required this.img,
    required this.url,
    required this.date,
    DateTime? parsedDate,
  }) : parsedDate = parsedDate ?? _parseDate(date);

  // Parse the Spanish format date
  static DateTime _parseDate(String date) {
    try {
      // Split the date string: "noviembre 29, 2024"
      final parts = date.split(' ');
      if (parts.length != 3) return DateTime.now();

      final month = _spanishMonthToNumber(parts[0]);
      final day = int.parse(parts[1].replaceAll(',', ''));
      final year = int.parse(parts[2]);

      return DateTime(year, month, day);
    } catch (e) {
      print('Error parsing date: $e');
      return DateTime.now();
    }
  }

  static int _spanishMonthToNumber(String month) {
    const months = {
      'enero': 1,
      'febrero': 2,
      'marzo': 3,
      'abril': 4,
      'mayo': 5,
      'junio': 6,
      'julio': 7,
      'agosto': 8,
      'septiembre': 9,
      'octubre': 10,
      'noviembre': 11,
      'diciembre': 12,
    };
    return months[month.toLowerCase()] ?? 1;
  }

  factory Noticia.fromJson(Map<String, dynamic> json) {
    return Noticia(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      img: json['img'] ?? '',
      url: json['url'] ?? '',
      date: json['date'] ?? '',
    );
  }
}
