import 'package:flutter/material.dart';
import '../core/theme.dart';

class ComponentStatus {
  final String id;
  final String name;
  final String zone;
  final int confidence;
  final int signalQuality;
  final String state;
  final String finding;
  final String recommendation;
  final Color color;
  final Offset anchor;

  const ComponentStatus({
    required this.id,
    required this.name,
    required this.zone,
    required this.confidence,
    required this.signalQuality,
    required this.state,
    required this.finding,
    required this.recommendation,
    required this.color,
    required this.anchor,
  });
}

const demoComponents = <ComponentStatus>[
  ComponentStatus(
    id: 'engine', name: 'Engine Bay', zone: 'Powertrain', confidence: 94, signalQuality: 96, state: 'Normal',
    finding: 'Combustion and belt frequency within expected range.',
    recommendation: 'No immediate action. Repeat scan after 500 km.', color: DQ.emerald, anchor: Offset(.62, .42),
  ),
  ComponentStatus(
    id: 'front_right', name: 'Front Right Bearing', zone: 'Wheel Assembly', confidence: 82, signalQuality: 97, state: 'Attention',
    finding: 'Rotational acoustic pattern detected near front wheel frequency band.',
    recommendation: 'Inspect bearing, brake disc and suspension linkage within 7 days.', color: DQ.amber, anchor: Offset(.28, .68),
  ),
  ComponentStatus(
    id: 'brakes', name: 'Brake System', zone: 'Friction System', confidence: 76, signalQuality: 90, state: 'Monitor',
    finding: 'Short high-frequency peaks during simulated braking profile.',
    recommendation: 'Monitor. Check pads/discs if noise continues.', color: DQ.cyan, anchor: Offset(.38, .69),
  ),
  ComponentStatus(
    id: 'suspension', name: 'Rear Suspension', zone: 'Chassis', confidence: 88, signalQuality: 93, state: 'Normal',
    finding: 'Vertical vibration within baseline range.',
    recommendation: 'No urgent action.', color: DQ.emerald, anchor: Offset(.73, .69),
  ),
  ComponentStatus(
    id: 'exhaust', name: 'Exhaust Resonance', zone: 'Exhaust', confidence: 69, signalQuality: 84, state: 'Monitor',
    finding: 'Low-frequency resonance slightly above expected idle profile.',
    recommendation: 'Repeat scan with cold engine and warm engine.', color: DQ.cyan, anchor: Offset(.83, .50),
  ),
];
