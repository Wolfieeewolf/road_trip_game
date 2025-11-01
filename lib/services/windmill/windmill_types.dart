import 'package:flutter/material.dart';

class WindmillTypeDefinition {
  final String key;
  final String label;
  final IconData icon;
  final double defaultPoints;
  final String description;

  const WindmillTypeDefinition({
    required this.key,
    required this.label,
    required this.icon,
    required this.defaultPoints,
    required this.description,
  });
}

const Map<String, WindmillTypeDefinition> windmillTypeDefinitions = {
  'pump': WindmillTypeDefinition(
    key: 'pump',
    label: 'Windmill (farm water pump)',
    icon: Icons.water,
    defaultPoints: 1.0,
    description: 'Classic Australian farm windmill used for pumping water.',
  ),
  'pump_broken': WindmillTypeDefinition(
    key: 'pump_broken',
    label: 'Windmill – Broken/ruin',
    icon: Icons.handyman_outlined,
    defaultPoints: 0.5,
    description: 'Damaged or missing blades/vanes on a traditional windmill.',
  ),
  'pump_double': WindmillTypeDefinition(
    key: 'pump_double',
    label: 'Windmill – Double/cluster',
    icon: Icons.blur_on,
    defaultPoints: 1.5,
    description: 'Two classic windmills side-by-side or a small cluster.',
  ),
  'turbine': WindmillTypeDefinition(
    key: 'turbine',
    label: 'Wind turbine',
    icon: Icons.wind_power,
    defaultPoints: 2.0,
    description: 'Large electricity-generating wind turbine.',
  ),
  'garden': WindmillTypeDefinition(
    key: 'garden',
    label: 'Pinwheel / garden spinner',
    icon: Icons.toys_outlined,
    defaultPoints: 1.5,
    description: 'Decorative garden windmill or pinwheel.',
  ),
  'other': WindmillTypeDefinition(
    key: 'other',
    label: 'Other / historic',
    icon: Icons.museum_outlined,
    defaultPoints: 1.0,
    description: 'Anything unusual: sculpture, historic feature, etc.',
  ),
};

