class DownloadModel {
  String? name;
  double? progress;
  String? url;
  String? mimeType;
  String? status;
  int? fileSize;
  dynamic taskId;

  DownloadModel({required this.name, required this.progress, required this.url, required this.mimeType, this.status, required this.fileSize, required this.taskId});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'progress': progress,
      'url': url,
      'mimeType': mimeType,
      'status': status ?? 'Downloading',
      'fileSize': fileSize,
      'taskTd': taskId
    };
  }

  factory DownloadModel.fromJson(Map<String, dynamic> json) {
    return DownloadModel(
      name: json['name'],
      progress: json['progress'],
      url: json['url'],
      mimeType: json['mimeType'],
      status: json['status'] ?? 'Downloading',
      fileSize: json['fileSize'],
      taskId: json['taskId']
    );
  }
}