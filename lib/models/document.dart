class Document {
  final String id;
  final String firstName;
  final String lastName;
  final String? notes;

  Document({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.notes,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    final items = json['items'] as List<dynamic>;
    String firstName = '';
    String lastName = '';
    String? notes;

    for (final item in items) {
      final slot = item['slot'] as String?;
      final text = item['data']['text'] as String?;
      
      if (slot == 'h1_1') {
        firstName = text ?? '';
      } else if (slot == 'h2_1') {
        lastName = text ?? '';
      } else if (slot == 'b1_1') {
        notes = text;
      }
    }

    return Document(
      id: json['id'] as String,
      firstName: firstName,
      lastName: lastName,
      notes: notes,
    );
  }
} 