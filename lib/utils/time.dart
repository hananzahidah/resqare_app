String timeAgo(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);

  if (diff.inSeconds < 60) {
    return "baru saja";
  } else if (diff.inMinutes < 60) {
    return "${diff.inMinutes} mnt lalu";
  } else if (diff.inHours < 24) {
    return "${diff.inHours} jam lalu";
  } else if (diff.inDays < 7) {
    return "${diff.inDays} hr lalu";
  } else {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();

    return "$day/$month/$year";
  }
}

String getGreeting() {
  final hour = DateTime.now().hour;
  if (hour >= 5 && hour < 11) {
    return "Selamat Pagi,";
  } else if (hour >= 11 && hour < 15) {
    return "Selamat Siang,";
  } else if (hour >= 15 && hour < 19) {
    return "Selamat Sore,";
  } else {
    return "Selamat Malam,";
  }
}
