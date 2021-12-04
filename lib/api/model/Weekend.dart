class Weekend {
  String? title;
  String? html_file;
  bool? success;

  Weekend({
    required this.title,
    required this.html_file,
    required this.success,
  });

  Weekend.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    html_file = json['html_file'];
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['html_file'] = this.html_file;
    return data;
  }
}
