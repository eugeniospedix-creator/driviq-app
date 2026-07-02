/// View modes for the vehicle renderer — supports future 3D and AR pipelines.
enum VehicleViewMode {
  exterior,
  interior,
  engine,
  suspension,
  dashboard,
  ar;

  String get label => switch (this) {
        VehicleViewMode.exterior => 'Exterior',
        VehicleViewMode.interior => 'Interior',
        VehicleViewMode.engine => 'Engine',
        VehicleViewMode.suspension => 'Suspension',
        VehicleViewMode.dashboard => 'Dashboard',
        VehicleViewMode.ar => 'AR',
      };
}
