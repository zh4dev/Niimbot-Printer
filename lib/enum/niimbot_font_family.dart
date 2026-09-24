/// Font families understood by the native Niimbot renderer.
///
/// Availability is ultimately controlled by the printer SDK. Generic system
/// families fall back to the platform default when no exact face is present.
enum NiimbotFontFamily {
  defaultFont('宋体', 'Default'),
  sansSerif('sans-serif', 'Sans Serif'),
  serif('serif', 'Serif'),
  monospace('monospace', 'Monospace');

  const NiimbotFontFamily(this.nativeName, this.displayName);

  final String nativeName;
  final String displayName;
}
