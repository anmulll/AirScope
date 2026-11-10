enum AqiCategory {
  good(
    label: 'Baik',
    description: 'Kualitas udara memuaskan dan risiko kesehatan rendah.',
  ),
  moderate(
    label: 'Sedang',
    description: 'Kualitas udara dapat diterima, tetapi beberapa individu sensitif mungkin mengalami dampak.',
  ),
  unhealthyForSensitiveGroups(
    label: 'Tidak Sehat untuk Kelompok Sensitif',
    description: 'Kelompok sensitif dapat mengalami dampak kesehatan.',
  ),
  unhealthy(
    label: 'Tidak Sehat',
    description: 'Sebagian masyarakat dapat mengalami dampak kesehatan.',
  ),
  veryUnhealthy(
    label: 'Sangat Tidak Sehat',
    description: 'Risiko dampak kesehatan meningkat bagi seluruh masyarakat.',
  ),
  hazardous(
    label: 'Berbahaya',
    description: 'Kondisi kualitas udara berbahaya bagi kesehatan.',
  ),
  unavailable(
    label: 'Tidak Tersedia',
    description: 'Informasi kualitas udara belum tersedia.',
  );

  final String label;
  final String description;

  const AqiCategory({required this.label, required this.description});

  static AqiCategory fromUsAqi(double? value) {
    if (value == null || !value.isFinite || value < 0) {
      return AqiCategory.unavailable;
    }

    if (value <= 50) {
      return AqiCategory.good;
    }

    if (value <= 100) {
      return AqiCategory.moderate;
    }

    if (value <= 150) {
      return AqiCategory.unhealthyForSensitiveGroups;
    }

    if (value <= 200) {
      return AqiCategory.unhealthy;
    }

    if (value <= 300) {
      return AqiCategory.veryUnhealthy;
    }

    return AqiCategory.hazardous;
  }
}
