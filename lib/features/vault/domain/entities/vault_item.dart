enum VaultCategory {
  login('Login'),
  apiKey('API Key'),
  pin('PIN'),
  secureNote('Secure Note'),
  other('Other');
  const VaultCategory(this.label);
  final String label;
  static VaultCategory parse(String value) => values.firstWhere(
        (item) => item.name == value || item.label == value,
        orElse: () => other,
      );
}

class VaultItem {
  const VaultItem({
    required this.id,
    required this.title,
    required this.username,
    required this.secret,
    required this.website,
    required this.category,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  final String id;
  final String title;
  final String username;
  final String secret;
  final String website;
  final VaultCategory category;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class VaultItemInput {
  const VaultItemInput({
    required this.title,
    required this.username,
    required this.secret,
    required this.website,
    required this.category,
    required this.notes,
  });
  final String title;
  final String username;
  final String secret;
  final String website;
  final VaultCategory category;
  final String notes;
}
