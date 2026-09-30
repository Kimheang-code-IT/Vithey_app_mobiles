class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.role,
    this.isStudentVerified = false,
    this.isEmailVerified = false,
  });

  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String? role;
  final bool isStudentVerified;
  final bool isEmailVerified;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user_id']?.toString() ?? json['id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String?,
      isStudentVerified: json['is_student_verified'] as bool? ?? false,
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? role,
    bool? isStudentVerified,
    bool? isEmailVerified,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isStudentVerified: isStudentVerified ?? this.isStudentVerified,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }
}
