/// Real-time diagnosis analysis state machine — drives premium AI status UI.
enum DiagnosisAnalysisPhase {
  idle,
  requestingPermission,
  calibratingMicrophone,
  analyzingHarmonics,
  comparingVibration,
  detectingFrequencies,
  estimatingConfidence,
  buildingRecommendations,
  complete,
  failed;

  String get label => switch (this) {
        DiagnosisAnalysisPhase.idle => 'Ready',
        DiagnosisAnalysisPhase.requestingPermission => 'Requesting microphone access…',
        DiagnosisAnalysisPhase.calibratingMicrophone => 'Calibrating acoustic sensors…',
        DiagnosisAnalysisPhase.analyzingHarmonics => 'Analyzing engine harmonics…',
        DiagnosisAnalysisPhase.comparingVibration => 'Comparing vibration signatures…',
        DiagnosisAnalysisPhase.detectingFrequencies => 'Detecting abnormal frequencies…',
        DiagnosisAnalysisPhase.estimatingConfidence => 'Estimating mechanical confidence…',
        DiagnosisAnalysisPhase.buildingRecommendations => 'Building repair recommendations…',
        DiagnosisAnalysisPhase.complete => 'Analysis complete',
        DiagnosisAnalysisPhase.failed => 'Analysis failed',
      };

  double get progress => switch (this) {
        DiagnosisAnalysisPhase.idle => 0,
        DiagnosisAnalysisPhase.requestingPermission => 0.05,
        DiagnosisAnalysisPhase.calibratingMicrophone => 0.15,
        DiagnosisAnalysisPhase.analyzingHarmonics => 0.35,
        DiagnosisAnalysisPhase.comparingVibration => 0.55,
        DiagnosisAnalysisPhase.detectingFrequencies => 0.72,
        DiagnosisAnalysisPhase.estimatingConfidence => 0.88,
        DiagnosisAnalysisPhase.buildingRecommendations => 0.96,
        DiagnosisAnalysisPhase.complete => 1,
        DiagnosisAnalysisPhase.failed => 0,
      };

  static const analysisSequence = [
    DiagnosisAnalysisPhase.calibratingMicrophone,
    DiagnosisAnalysisPhase.analyzingHarmonics,
    DiagnosisAnalysisPhase.comparingVibration,
    DiagnosisAnalysisPhase.detectingFrequencies,
    DiagnosisAnalysisPhase.estimatingConfidence,
    DiagnosisAnalysisPhase.buildingRecommendations,
  ];
}
