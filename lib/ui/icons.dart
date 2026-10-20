import 'package:flutter/widgets.dart';
import 'package:solar_icons/solar_icons.dart';

/// Semua ikon aplikasi lewat sini. Kalau ada nama Solar yang beda di versi
/// package-nya, cukup ganti di file ini saja.
class Ic {
  // navigasi (nonaktif = outline, aktif = bold)
  static const IconData home = SolarIconsOutline.home;
  static const IconData homeOn = SolarIconsBold.home;
  static const IconData box = SolarIconsOutline.box;
  static const IconData boxOn = SolarIconsBold.box;
  static const IconData chart = SolarIconsOutline.chart;
  static const IconData chartOn = SolarIconsBold.chart;
  static const IconData user = SolarIconsOutline.userCircle;
  static const IconData userOn = SolarIconsBold.userCircle;

  // umum
  static const IconData search = SolarIconsOutline.magnifier;
  static const IconData bell = SolarIconsOutline.bell;
  static const IconData eye = SolarIconsOutline.eye;
  static const IconData eyeOff = SolarIconsOutline.eyeClosed;
  static const IconData close = SolarIconsOutline.closeCircle;
  static const IconData check = SolarIconsBold.checkCircle;
  static const IconData checkLine = SolarIconsOutline.checkCircle;
  static const IconData arrowRight = SolarIconsOutline.arrowRight;
  static const IconData arrowDown = SolarIconsOutline.arrowDown;
  static const IconData info = SolarIconsOutline.infoCircle;
  static const IconData cloud = SolarIconsOutline.cloud;

  // alur usaha bata
  static const IconData add = SolarIconsOutline.addCircle;
  static const IconData fire = SolarIconsOutline.fire;
  static const IconData play = SolarIconsOutline.play;
  static const IconData stock = SolarIconsOutline.boxMinimalistic;
  static const IconData truck = SolarIconsOutline.delivery;
  static const IconData wallet = SolarIconsOutline.wallet;
  static const IconData money = SolarIconsOutline.moneyBag;
  static const IconData hand = SolarIconsOutline.handMoney;
  static const IconData send = SolarIconsOutline.plain;
  static const IconData tune = SolarIconsOutline.tuning;
  static const IconData incoming = SolarIconsOutline.arrowLeftDown;
  static const IconData outgoing = SolarIconsOutline.arrowRightUp;
}