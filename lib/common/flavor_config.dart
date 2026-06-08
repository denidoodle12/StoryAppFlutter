import 'flavor_type.dart';
import 'flavor_values.dart';

class FlavorConfig {
  final FlavorType flavor;
  final FlavorValues values;

  static FlavorConfig? _instance;

  FlavorConfig._internal({required this.flavor, required this.values});

  factory FlavorConfig({
    required FlavorType flavor,
    required FlavorValues values,
  }) {
    _instance = FlavorConfig._internal(flavor: flavor, values: values);
    return _instance!;
  }

  static FlavorConfig get instance {
    _instance ??= FlavorConfig._internal(
      flavor: FlavorType.free,
      values: const FlavorValues(appName: 'Story App', canPickLocation: false),
    );
    return _instance!;
  }

  static bool get isFree => instance.flavor == FlavorType.free;
  static bool get isPaid => instance.flavor == FlavorType.paid;
}
