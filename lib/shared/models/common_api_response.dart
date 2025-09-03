class CommonApiResponse {
  final String message;
  final int status;

  CommonApiResponse({
    required this.message,
    required this.status,
  });

  factory CommonApiResponse.fromJson(Map<String, dynamic> json) {
    return CommonApiResponse(
      message: json['message'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'status': status,
    };
  }
}
