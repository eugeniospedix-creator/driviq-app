/// Lifecycle for photo → 3D reconstruction jobs.
enum VehicleModelGenerationStatus {
  notStarted('Not started'),
  collectingPhotos('Collecting photos'),
  processing('Processing 3D model'),
  pendingService('Queued for reconstruction'),
  ready('3D model ready'),
  failed('Reconstruction failed');

  const VehicleModelGenerationStatus(this.label);

  final String label;

  bool get isTerminal => this == ready || this == failed;
  bool get hasUsableModel => this == ready;
}
