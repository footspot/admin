import 'package:flutter/material.dart';

mixin Responsive {
  final double widthScreen =
      WidgetsBinding
          .instance
          .platformDispatcher
          .views
          .first
          .physicalSize
          .width /
      WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

  final double heightScreen =
      WidgetsBinding
          .instance
          .platformDispatcher
          .views
          .first
          .physicalSize
          .height /
      WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
}
