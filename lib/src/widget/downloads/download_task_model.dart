class DownloadTasks {
  final String taskId;
  final String url;
  final String name;
  int status; // You can define enums for different statuses
  int progress;
  int totalSize;
  String dir;
  DateTime createdDate;
  DownloadTasks({
    required this.taskId,
    required this.url,
    required this.name,
    required this.status,
    required this.progress,
    required this.totalSize,
    required this.dir,
    required this.createdDate
  });
}
