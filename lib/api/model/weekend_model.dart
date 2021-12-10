class Weekend {
  String? title;
  String? html_file;
  bool? success;
  String? data;
  int? code;

  Weekend({
    required this.title,
    required this.html_file,
    required this.success,
    required this.data,
    required this.code
  });

  Weekend.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    html_file = json['html_file'];
    success = json['success'];
    data = json['data'];
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['html_file'] = this.html_file;
    data['data'] = this.data;
    data['code'] = this.code;
    return data;
  }
}
