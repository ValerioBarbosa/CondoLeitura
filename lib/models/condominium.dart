enum CondominiumStatus { active, inactive, archived }

class Condominium {
  final int? id;
  final String localId;
  final String? remoteId;
  final String name;
  final String? code;
  final String? document;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? phone;
  final String? email;
  final String? administrator;
  final String? contactName;
  final String? notes;
  final String? photoPath;
  final CondominiumStatus status;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Condominium({
    this.id,
    required this.localId,
    this.remoteId,
    required this.name,
    this.code,
    this.document,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.phone,
    this.email,
    this.administrator,
    this.contactName,
    this.notes,
    this.photoPath,
    this.status = CondominiumStatus.active,
    this.syncStatus = 'pending',
    required this.createdAt,
    this.updatedAt,
  });

  Condominium copyWith({
    int? id,
    String? localId,
    String? remoteId,
    String? name,
    String? code,
    String? document,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? phone,
    String? email,
    String? administrator,
    String? contactName,
    String? notes,
    String? photoPath,
    CondominiumStatus? status,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Condominium(
      id: id ?? this.id,
      localId: localId ?? this.localId,
      remoteId: remoteId ?? this.remoteId,
      name: name ?? this.name,
      code: code ?? this.code,
      document: document ?? this.document,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      administrator: administrator ?? this.administrator,
      contactName: contactName ?? this.contactName,
      notes: notes ?? this.notes,
      photoPath: photoPath ?? this.photoPath,
      status: status ?? this.status,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'local_id': localId,
        'remote_id': remoteId,
        'name': name,
        'code': code,
        'document': document,
        'address': address,
        'city': city,
        'state': state,
        'zip_code': zipCode,
        'phone': phone,
        'email': email,
        'administrator': administrator,
        'contact_name': contactName,
        'notes': notes,
        'photo_path': photoPath,
        'status': status.name,
        'sync_status': syncStatus,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  factory Condominium.fromMap(Map<String, dynamic> map) => Condominium(
        id: map['id'] as int?,
        localId: map['local_id'] as String,
        remoteId: map['remote_id'] as String?,
        name: map['name'] as String,
        code: map['code'] as String?,
        document: map['document'] as String?,
        address: map['address'] as String?,
        city: map['city'] as String?,
        state: map['state'] as String?,
        zipCode: map['zip_code'] as String?,
        phone: map['phone'] as String?,
        email: map['email'] as String?,
        administrator: map['administrator'] as String?,
        contactName: map['contact_name'] as String?,
        notes: map['notes'] as String?,
        photoPath: map['photo_path'] as String?,
        status: CondominiumStatus.values.firstWhere(
          (value) => value.name == map['status'],
          orElse: () => CondominiumStatus.active,
        ),
        syncStatus: map['sync_status'] as String? ?? 'pending',
        createdAt: DateTime.parse(map['created_at'] as String),
        updatedAt: map['updated_at'] != null
            ? DateTime.parse(map['updated_at'] as String)
            : null,
      );
}
