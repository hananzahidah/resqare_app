String timeAgo(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);

  if (diff.inSeconds < 60) {
    return "Sekarang";
  } else if (diff.inMinutes < 60) {
    return "${diff.inMinutes} mnt";
  } else if (diff.inHours < 24) {
    return "${diff.inHours} jam";
  } else if (diff.inDays < 7) {
    return "${diff.inDays} hr";
  } else {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();

    return "$day/$month/$year";
  }
}
