import 'location.dart';

class Address {
  final Country country;
  final Department department;
  final Municipality municipality;
  final String line1;

  const Address({
    required this.country,
    required this.department,
    required this.municipality,
    required this.line1,
  });
}
