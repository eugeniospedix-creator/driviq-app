/// Guided angles for multi-photo 3D reconstruction.
enum VehiclePhotoAngle {
  front('Front', 'Capture the full front of your vehicle, centered in frame.'),
  rear('Rear', 'Capture the full rear, including lights and bumper.'),
  leftSide('Left side', 'Full left profile — wheels, roof line, and doors visible.'),
  rightSide('Right side', 'Full right profile — wheels, roof line, and doors visible.'),
  threeQuarterFront('3/4 front', 'Front-left or front-right angle showing hood and side.'),
  threeQuarterRear('3/4 rear', 'Rear-left or rear-right angle showing tail and side.');

  const VehiclePhotoAngle(this.title, this.guide);

  final String title;
  final String guide;

  static const captureSequence = [
    VehiclePhotoAngle.threeQuarterFront,
    VehiclePhotoAngle.front,
    VehiclePhotoAngle.leftSide,
    VehiclePhotoAngle.rightSide,
    VehiclePhotoAngle.rear,
    VehiclePhotoAngle.threeQuarterRear,
  ];
}
