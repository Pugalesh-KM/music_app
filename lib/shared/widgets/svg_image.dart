import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

SvgPicture getSvg(
  String iconPath, {
  double? width,
  double? height,
  Color? color,
  BoxFit? boxFit,
  AlignmentGeometry? alignment,
  bool isNetwork = false,
}) {
  List<String> list = iconPath.split(':');

  ColorFilter? colorFilter =
      color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null;

  if (isNetwork) {
    return SvgPicture.network(
      iconPath,
      width: width,
      height: height,
      colorFilter: colorFilter,
      fit: boxFit ?? BoxFit.contain,
    );
  }

  if (list.length > 1) {
    return SvgPicture.asset(
      list[1],
      package: list[0],
      width: width,
      height: height,
      colorFilter: colorFilter,
      alignment: alignment ?? Alignment.center,
      fit: boxFit ?? BoxFit.contain,
    );
  }

  return SvgPicture.asset(
    list.first,
    width: width,
    height: height,
    colorFilter: colorFilter,
    fit: boxFit ?? BoxFit.contain,
  );
}
