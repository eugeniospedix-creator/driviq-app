/// How closely the resolved pack matches the user's vehicle identity.
enum VehicleAssetResolutionKind {
  exact,
  model,
  generation,
  bodyFallback,
  universal,
}
