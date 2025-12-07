// lib/models/profile.dart
class Profile {
  final String id;
  final String displayName;
  final String? email;
  final String? role;
  final int points;
  final List<dynamic> badges;

  Profile({
    required this.id,
    required this.displayName,
    this.email,
    this.role,
    this.points = 0,
    this.badges = const [],
  });

  factory Profile.fromMap(Map<String, dynamic> m) => Profile(
        id: m['id'],
        displayName: m['display_name'] ?? '',
        email: m['email'],
        role: m['role'],
        points: m['points'] ?? 0,
        badges: m['badges'] ?? [],
      );
}
