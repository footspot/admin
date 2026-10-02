import 'package:fs_sa/data/models/legacy/address.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class AddressEntity {
  @Id()
  int id;

  String? city;
  String? zipCode;
  double? longitude;
  double? latitude;

  // ObjectBox doesn't support List<String> directly, so we store as comma-separated string
  String? streetData;

  AddressEntity({
    this.id = 0,
    this.city,
    this.zipCode,
    this.longitude,
    this.latitude,
    this.streetData,
  });

  // Convert from domain model
  factory AddressEntity.fromDomain(Address domain) {
    return AddressEntity(
      id: domain.id,
      city: domain.city,
      zipCode: domain.zipCode,
      longitude: domain.longitude,
      latitude: domain.latitude,
      streetData: domain.street?.join('|'), // Join list with delimiter
    );
  }

  // Convert to domain model
  Address toDomain() {
    return Address(
      id: id,
      city: city,
      street: streetData?.split('|'), // Split string back to list
      zipCode: zipCode,
      longitude: longitude,
      latitude: latitude,
    );
  }
}
