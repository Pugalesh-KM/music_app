enum SuccessCardType {
  passwordSuccess,
  accountCreated,
  smartSubmitted,
  smartRequest,
  creditRequest,
}

class SuccessCardModel {
  final SuccessCardType cardType;
  final String successTitleText;
  final String successSubText;
  final String buttonText;

  SuccessCardModel({
    required this.cardType,
    required this.buttonText,
    required this.successSubText,
    required this.successTitleText,
  });
}
