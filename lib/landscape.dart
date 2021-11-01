import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:marquee/marquee.dart';
import 'package:masjid/FlutterAnalogClock.dart';
import 'package:masjid/SizeConfig.dart';
import 'package:masjid/Values/WebConfig.dart';
import 'package:sizer/sizer.dart';

import 'Values/constants.dart';

class LandscapeScreen extends StatefulWidget {
  const LandscapeScreen({Key? key}) : super(key: key);

  @override
  _LandscapeScreenState createState() => _LandscapeScreenState();
}

class _LandscapeScreenState extends State<LandscapeScreen>
    with WidgetsBindingObserver {
  DateTime? currentBackPressTime;
  bool isLoading = true;
  String prayerDateFormat = "", prayerDateYear = "";
  String _jFajar = "00:00",
      _jZohar = "00:00",
      _jAsar = "00:00",
      _jMagharib = "00:00",
      _jIsha = "00:00";

  String jFajar = "00:00",
      jZohar = "00:00",
      jAsar = "00:00",
      jMagharib = "00:00",
      jIsha = "00:00";

  String bFajar = '', bZohar = '', bAsar = '', bMagharib = '', bIsha = '';
  String sehriString = "",
      sunriseString = "",
      noonString = "",
      jumuahString = "";
  String? islamicDayString = "",
      islamicMonthString = "",
      islamicYearString = "",
      islamicWeekDayString = "";

  Duration fajarDifference = Duration();
  Duration zoharDifference = Duration();
  Duration asarDifference = Duration();
  Duration magharibDifference = Duration();
  Duration ishaDifference = Duration();
  String namazName = '';
  String topTitle = 'Loading';
  String bottomTitle = 'Loading';
  Timer _timers = Timer(Duration(seconds: 0), () {});
  Timer _timerss = Timer(Duration(seconds: 0), () {});
  String imageString = '';
  String silentPhoneImageString = '';
  int timeDiff = 10;
  int silentPhoneSeconds = 0;
  late String _timeString;
  AppLifecycleState _notification = AppLifecycleState.resumed;
  int endTimes = DateTime.now().millisecondsSinceEpoch +
      Duration(days: 0, hours: 0, seconds: 10).inMilliseconds;
  Timer _timerForInter = Timer(Duration(seconds: 0),
      () {}); // <- Put this line on top of _MyAppState class

  final Shader linearGradient = LinearGradient(
    colors: <Color>[Color(0xffb77b2d), Color(0xfff1c572)],
  ).createShader(Rect.fromLTWH(30.0, 20.0, 200.0, 70.0));

  @override
  void initState() {
    super.initState();
    _timeString = _formatDateTime(DateTime.now());
    WidgetsBinding.instance!.addObserver(this);
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    setState(() {
      callMethod();
    });
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    _notification = state;
    if (state == AppLifecycleState.resumed) {
      //do your stuff
      print('Resumed');
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return LandscapeScreen();
      }));
      // callMethod();
    } else if (state == AppLifecycleState.paused) {
      print('Pause');
    } else if (state == AppLifecycleState.inactive) {
      print('Inactive');
      _timerForInter.cancel();
      _timers.cancel();
      _timerss.cancel();
    } else if (state == AppLifecycleState.detached) {
      print('Detached');
    }
  }

  @override
  void dispose() {
    print('GetResponse--->Dispose Call');
    _timerForInter.cancel();
    _timers.cancel();
    _timerss.cancel();
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  showDialogs(BuildContext context) {
    showDialog(
        barrierColor: Colors.transparent,
        context: context,
        builder: (BuildContext builderContext) {
          _timers = Timer(Duration(seconds: 10), () {
            Navigator.of(context).pop();
          });

          return Container(
            alignment: Alignment.center,
            width: double.infinity,
            height: double.infinity,
            color: Colors.transparent,
            child: SingleChildScrollView(
              child: Image.network(
                imageString,
                fit: BoxFit.cover,
                headers: {
                  "Access-Control-Allow-Origin": "*",
                  "Access-Control-Allow-Headers": "*",
                  "Access-Control-Allow-Methods":
                      "POST, GET, OPTIONS, PUT, DELETE, HEAD",
                },
              ),
            ),
          );
        }).then((val) {
      if (_timers.isActive) {
        _timers.cancel();
      }
    });
  }

  showSilent(BuildContext context) {
    showDialog(
        barrierColor: Colors.transparent,
        context: context,
        builder: (BuildContext builderContext) {
          _timerss = Timer(Duration(minutes: 3), () {
            _timerForInter.cancel();
            _timers.cancel();
            Navigator.of(context).pop();
            setState(() {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return LandscapeScreen();
              }));
            });
          });
          if (silentPhoneImageString != '') {
            return Container(
              alignment: Alignment.center,
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
              child: SingleChildScrollView(
                child: Image.network(
                  silentPhoneImageString,
                  fit: BoxFit.cover,
                ),
              ),
            );
          } else {
            return Container();
          }
        }).then((val) {
      if (_timerss.isActive) {
        _timerss.cancel();
      }
    });
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _dateChangeFormat(now);
    print('GetResponse--->$formattedDateTime');
    final String formattedDateTimes = _formatDateTime(now);

    if (this.mounted) {
      setState(() {
        _timeString = formattedDateTimes;
        if (formattedDateTime == '00:00:00') {
          _timers.cancel();
          _timerss.cancel();
          _timerForInter.cancel();
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return LandscapeScreen();
          }));
        }
      });
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  String _dateChangeFormat(DateTime dateTime) {
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  callMethod() async {
    _timerForInter.cancel();
    var responseData = await WebConfig.timeURL();
    var getData = json.decode(responseData);
    setState(() {
      islamicDayString = getData['islamic_date'];
      prayerDateFormat = getData['prayer_date_format'];
      prayerDateYear = getData['prayer_date_year'];
      _jFajar = getData['jammat_fajar'];
      _jZohar = getData['jammat_zohar'];
      _jAsar = getData['jammat_asar'];
      _jMagharib = getData['jammat_maghrib'];
      _jIsha = getData['jammat_isha'];

      jFajar = getData['jammat_fajar'];
      jZohar = getData['jammat_zohar'];
      jAsar = getData['jammat_asar'];
      jMagharib = getData['jammat_maghrib'];
      jIsha = getData['jammat_isha'];

      bFajar = getData['beginning_fajar'];
      bZohar = getData['beginning_zohar'];
      bAsar = getData['beginning_asar'];
      bMagharib = getData['beginning_maghrib'];
      bIsha = getData['beginning_isha'];

      sehriString = getData['sehri_ends'];
      sunriseString = getData['sun_rise'];
      jumuahString = getData['jammat_jummah'];
      noonString = getData['jammat_noon'];

      topTitle = getData['farooq_app']['title'];
      bottomTitle = getData['farooq_app']['bottom'];
      imageString = getData['farooq_app']['popup_image'];
      print('ImageString---->$imageString');
      silentPhoneImageString = getData['farooq_app']['silent_phone_image'];
      String timeDiffString = getData['farooq_app']['popup_second'] == ''
          ? '0'
          : getData['farooq_app']['popup_second'].toString();
      timeDiff = int.parse(timeDiffString);
      silentPhoneSeconds =
          int.parse(getData['farooq_app']['mobile_silent_seconds'].toString());

      if (imageString != '') {
        _timerForInter = Timer.periodic(Duration(seconds: timeDiff), (result) {
          showDialogs(context);
        });
      }

      var currentTime = new DateTime.now();
      var berlinWallFell = new DateFormat("HH:mm").format(currentTime);
      var nowTime = new DateFormat("HH:mm", "en_US").parse(berlinWallFell);

      var jFajarD = new DateFormat("HH:mm", "en_US").parse(jFajar);
      var jZoharD = new DateFormat("HH:mm", "en_US").parse(jZohar);
      var jAsarD = new DateFormat("HH:mm", "en_US").parse(jAsar);
      var jMagharibD = new DateFormat("HH:mm", "en_US").parse(jMagharib);
      var jIshaD = new DateFormat("HH:mm", "en_US").parse(jIsha);

      fajarDifference = jFajarD.difference(nowTime);
      zoharDifference = jZoharD.difference(nowTime);
      asarDifference = jAsarD.difference(nowTime);
      magharibDifference = jMagharibD.difference(nowTime);
      ishaDifference = jIshaD.difference(nowTime);

      if (!fajarDifference.toString().contains('-')) {
        endTimes = endTimes +
            Duration(milliseconds: fajarDifference.inMilliseconds)
                .inMilliseconds;
        namazName = 'FAJR';
      } else if (!zoharDifference.toString().contains('-')) {
        endTimes = endTimes +
            Duration(milliseconds: zoharDifference.inMilliseconds)
                .inMilliseconds;
        namazName = 'ZOHAR';
      } else if (!asarDifference.toString().contains('-')) {
        endTimes = endTimes +
            Duration(milliseconds: asarDifference.inMilliseconds)
                .inMilliseconds;
        namazName = 'ASAR';
      } else if (!magharibDifference.toString().contains('-')) {
        endTimes = endTimes +
            Duration(milliseconds: magharibDifference.inMilliseconds)
                .inMilliseconds;
        namazName = 'MAGHRIB';
      } else if (!ishaDifference.toString().contains('-')) {
        endTimes = endTimes +
            Duration(milliseconds: ishaDifference.inMilliseconds)
                .inMilliseconds;
        namazName = 'ISHA';
      } else {
        namazName = '----';
      }
    });
  }

  callMethodWithTime() async {
    var currentTime = new DateTime.now();
    final tomorrow =
        DateTime(currentTime.year, currentTime.month, currentTime.day + 1);
    var berlinWallFell = new DateFormat("yyyy-MM-dd").format(tomorrow);
    var responseData = await WebConfig.timeWithDateURL(berlinWallFell);
    var getData = json.decode(responseData);
    setState(() {
      jFajar = getData['jammat_fajar'];
      var currentTime = new DateTime.now();

      var jFajarForTomorrow = new DateFormat("HH:mm", "en_US").parse(jFajar);
      final tomorrow = DateTime(
          currentTime.year,
          currentTime.month,
          currentTime.day + 1,
          jFajarForTomorrow.hour,
          jFajarForTomorrow.minute);

      var berlinWallFell =
          new DateFormat("yyyy-MM-dd HH:mm").format(currentTime);
      var nowTime =
          new DateFormat("yyyy-MM-dd HH:mm", "en_US").parse(berlinWallFell);

      fajarDifference = tomorrow.difference(nowTime);
      if (!fajarDifference.toString().contains('-')) {
        endTimes = endTimes +
            Duration(milliseconds: fajarDifference.inMilliseconds)
                .inMilliseconds;
        namazName = 'FAJR';
      } else {
        print('Something Went Wrong');
      }
    });
  }

  String format(int num) {
    if (num < 10) {
      return '0$num';
    }
    return num.toString();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xfffdfbf4),
        body: Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: [
            Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                image: AssetImage("assets/background.png"),
                repeat: ImageRepeat.repeat,
              )),
              child: Stack(children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 3.0.h,
                          width: MediaQuery.of(context).size.width,
                          child: Marquee(
                            text: topTitle,
                            textScaleFactor: kTextSCaleFactor,
                            style: TextStyle(
                                fontSize: 14.0.sp,
                                color: kColorJummah.withOpacity(0.9),
                                fontFamily: kFontPalitino),
                            scrollAxis: Axis.horizontal,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            blankSpace: 20.0,
                            velocity: 100.0,
                            pauseAfterRound: Duration.zero,
                            startPadding: 10.0,
                            accelerationDuration: Duration.zero,
                            accelerationCurve: Curves.linear,
                            decelerationDuration: Duration.zero,
                            decelerationCurve: Curves.easeOut,
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildExpandedTopLeft(),
                        Container(
                          height: 3.0.h,
                          width: MediaQuery.of(context).size.width * 0.30,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              kDividerColorBehindClock.withOpacity(0.3),
                              kDividerColorBehindClock.withOpacity(0.9),
                              kDividerColorBehindClock.withOpacity(0.9),
                              kDividerColorBehindClock,
                            ],
                            // stops: [0.0, 1],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          )),
                          child: Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: EdgeInsets.only(right: 60.0, top: 5.0),
                              child: Text(
                                "$prayerDateFormat, $prayerDateYear",
                                textAlign: TextAlign.center,
                                textScaleFactor: kTextSCaleFactor,
                                style: TextStyle(
                                  color: kWhiteColor,
                                  fontFamily: 'palitino',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 3.0.h,
                          width: MediaQuery.of(context).size.width * 0.30,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              kDividerColorBehindClock.withOpacity(0.3),
                              kDividerColorBehindClock.withOpacity(0.6),
                              kDividerColorBehindClock.withOpacity(0.9),
                              kDividerColorBehindClock,
                            ],
                            // stops: [0.0, 1],
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                          )),
                          child: Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: EdgeInsets.only(left: 60.0, top: 5.0),
                              child: Text(
                                "$islamicDayString",
                                textAlign: TextAlign.center,
                                textScaleFactor: kTextSCaleFactor,
                                style: TextStyle(
                                  color: kWhiteColor,
                                  fontFamily: 'palitino',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                        buildExpandedTopRight(),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                        colors: [
                          kColorJummah,
                          kDividerColorBehindClock,
                          kColorJummah,
                          kDividerColorBehindClock,
                          kColorJummah,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )),
                      height: 1.0.h,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 7.0.h),
                      child: Row(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Column(
                                children: [
                                  SizedBox(height:MediaQuery.of(context).size.height *
                                      0.02),
                                  Row(
                                    children: [
                                      Container(
                                        width:
                                        MediaQuery.of(context).size.width *
                                            0.2,
                                      ),
                                      Container(
                                        width:
                                        MediaQuery.of(context).size.width *
                                            0.25,
                                      ),
                                      buildPositionedJamaatTime(),
                                      Container(
                                        width:
                                        MediaQuery.of(context).size.width *
                                            0.1,
                                      ),
                                      buildPositionedBeginningTime(),
                                    ],
                                  ),
                                  buildRow(sehriString, 'SEHRI', 'فجر',
                                      kFAJRText, _jFajar, bFajar),
                                  buildRowDivider(context),
                                  buildRow(sunriseString, 'SUNRISE', 'ظهر',
                                      kZOHARText, _jZohar, bZohar),
                                  buildRowDivider(context),
                                  buildRow(noonString, 'NOON', 'عصر', kASARText,
                                      _jAsar, bAsar),
                                  buildRowDivider(context),
                                  buildRow(jumuahString, 'JUMUAH', 'مغرب',
                                      kMAGHRIBText, _jMagharib, bMagharib),
                                  buildRowDivider(context),
                                  buildRowForMadniText(
                                      'عشاء', kISHAText, _jIsha, bIsha),

                                  Container(
                                    padding: EdgeInsets.only(left: 6.0.w),
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    child: Text(
                                      '',
                                      textScaleFactor: kTextSCaleFactor,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontFamily: kFontPalitino,
                                          fontSize: 14.0.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: buildColumnUpComing(),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.050),
                    child: Image(
                      image: AssetImage("assets/clock.png"),
                      height: MediaQuery.of(context).size.height * 0.24,
                    ),
                  ),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.468,
                  top: MediaQuery.of(context).size.height * 0.097,
                  child: Align(
                      alignment: Alignment.topCenter,
                      child: FlutterAnalogClock(
                        dateTime: DateTime.now(),
                        dialPlateColor: clockColor,
                        hourHandColor: Colors.white,
                        minuteHandColor: Colors.white,
                        centerPointColor: Colors.white,
                        showMinuteHand: true,
                        numberColor: Colors.brown,
                        showNumber: true,
                        showBorder: false,
                        showTicks: false,
                        showSecondHand: false,
                        isLive: true,
                        hourNumberScale: 1.0,
                        width: MediaQuery.of(context).size.width * 0.065,
                        height: MediaQuery.of(context).size.width * 0.065,
                      )),
                ),
              ]),
            ),
            Positioned.fill(
              top: 8.0.h,
              right: 145.0.w,
              child: Container(
                height: 145.0.h,
                decoration: BoxDecoration(
                  color:kDividerColorBehindClock.withOpacity(0.08),
                  border: Border(
                    right: BorderSide( //                   <--- left side
                      color: kDividerColorBehindClock,
                      width: 3.0,
                    ),
                  ),
                ),
              ),
            ),
            // Positioned.fill(
            //   top: 48.5.h,
            //   left: 150.0.w,
            //   child: Container(
            //     decoration: BoxDecoration(
            //         image: DecorationImage(
            //       image: AssetImage("assets/bottomdesign.png"),
            //     )),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Row buildRowDivider(BuildContext context) {
    return Row(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.2,
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.6,
          height: 0.1.h,
          child: Divider(
            height: 1.0.h,
            color: Colors.brown,
          ),
        )
      ],
    );
  }

  Widget buildPositionedBeginningTime() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white,
        ),
        child: Text(
          'Beginning Time',
          textAlign: TextAlign.center,
          textScaleFactor: kTextSCaleFactor,
          style: TextStyle(
              fontFamily: kFontsOpensansBold,
              fontSize: 10.0.sp,
              color: kCBrownColor),
        ),
      ),
    );
  }

  Widget buildPositionedJamaatTime() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white,
        ),
        child: Text(
          'Jamaat Time',
          textAlign: TextAlign.center,
          textScaleFactor: kTextSCaleFactor,
          style: TextStyle(
              fontFamily: kFontsOpensansBold,
              fontSize: 10.0.sp,
              color: kCBrownColor),
        ),
      ),
    );
  }

  Widget buildColumnUpComing() {
    return Column(
      children: [
        Text(
          namazName == 'FAJR'
              ? 'فجر'
              : namazName == 'ZOHAR'
                  ? 'ظهر'
                  : namazName == 'ASAR'
                      ? 'عصر'
                      : namazName == 'MAGHRIB'
                          ? 'مغرب'
                          : 'عشاء',
          textScaleFactor: kTextSCaleFactor,
          style: TextStyle(
              fontSize: kValue24.sp,
              foreground: Paint()..shader = linearGradient,
              fontWeight: FontWeight.bold),
        ),
        Text(
          // 'ASAR',
          namazName,
          textScaleFactor: kTextSCaleFactor,
          style: TextStyle(
            fontSize: kValue16.sp,
            color: Color(0XFFa6855e),
            fontWeight: FontWeight.bold,
            fontFamily: kFontPalitino,
          ),
        ),
        CountdownTimer(
          onEnd: () {
            if (namazName == '----') {
              callMethodWithTime();
              _timerForInter.cancel();
            } else {
              showSilent(context);
              _timers.cancel();
              _timerForInter.cancel();
            }
          },
          endTime: endTimes,
          widgetBuilder: (_, CurrentRemainingTime? time) {
            if (time == null) {
              return Text(
                '00:00:00',
                style: TextStyle(
                  color: Colors.green,
                  fontFamily: 'bwmodellica',
                  fontSize: kValue16.sp,
                  fontWeight: FontWeight.bold,
                ),
              );
            }
            return Text(
              'in ${time.hours == null ? '0' : format(time.hours!)} : ${time.min == null ? '0' : format(time.min!)} : ${time.sec == null ? '00' : format(time.sec!)} ',
              style: TextStyle(
                fontSize: 14.0.sp,
                fontFamily: 'bwmodellica',
                color: (time.hours == 0 && time.min! < 03)
                    ? Colors.red
                    : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            );
          },
          textStyle: TextStyle(
            fontSize: 14.0.sp,
            fontFamily: kFontOpensans,
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget buildRowForMadniText(
      String symbol, String text, String endTime, String startTime) {
    return Row(
      children: [
        // buildCenter(),
        buildExpandedTopRight(),
        Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.2,
              child: Column(
                children: [
                  LinearGradientMask(
                    child:
                  Text(
                    symbol,
                    textScaleFactor: kTextSCaleFactor,
                    style: TextStyle(
                        fontSize: 16.0.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    ),
                  ),
                  // Icon(iconData),
                  Text(
                    text,
                    textScaleFactor: kTextSCaleFactor,
                    style: TextStyle(
                      fontSize: 14.0.sp,
                      fontFamily: kFontOpensans,
                      color: kColorJummah,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.2,
              alignment: Alignment.center,
              // height: 8.0.h,
              // padding: EdgeInsets.all(1.0.w),
              child: LinearGradientMask(
              child: Text(endTime,
                  textScaleFactor: kTextSCaleFactor,
                  textAlign: TextAlign.center,
                  // style: kEndTime,
                  style: TextStyle(
                      fontSize: 20.0.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'palitino')),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.2,
              child: Text(
                startTime,
                textScaleFactor: kTextSCaleFactor,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.0.sp,
                  fontFamily: 'opensansbold',
                  color: kCBrownColor,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget buildRow(String timeGapOfDay, String type, String symbol, String text,
      String endTime, String startTime) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.only(top: 1.0.h),

          width: MediaQuery.of(context).size.width * 0.2,
          // padding: EdgeInsets.all(1.0.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                timeGapOfDay,
                textScaleFactor: kTextSCaleFactor,
                style: TextStyle(
                    fontSize: kValue14.sp,
                    color: kDividerColorBehindClock,
                    fontFamily: kFontPalitino),
              ),
              Text(
                type,
                textScaleFactor: kTextSCaleFactor,
                style: TextStyle(
                    fontSize: 14.0.sp,
                    color: Color(0XFF25225c),
                    fontFamily: kFontsOpensansBold),
              ),
              // Spacer(),
              Container(
                color: kCBrownColor,
                height: 1.0,
                width: 27.0.w,
              )
            ],
          ),
        ),
        Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.2,
              child: Column(
                children: [
                  LinearGradientMask(
                    child:
                  Text(
                    symbol,
                    textScaleFactor: kTextSCaleFactor,
                    style: TextStyle(
                        fontSize: 16.0.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    ),
                  ),
                  Text(
                    text,
                    textScaleFactor: kTextSCaleFactor,
                    style: TextStyle(
                        fontSize: 14.0.sp,
                        color: kColorJummah,
                        fontFamily: 'opensansbold'),
                  )
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.2,
              alignment: Alignment.center,
              // height: 8.0.h,
              // padding: EdgeInsets.all(1.0.w),
              child: LinearGradientMask(
              child: Text(endTime,
                  textScaleFactor: kTextSCaleFactor,
                  textAlign: TextAlign.center,
                  // style: kEndTime,
                  style: TextStyle(
                    fontSize: 20.0.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'palitino',
                  )),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.2,
              child: Text(
                startTime,
                textAlign: TextAlign.center,
                textScaleFactor: kTextSCaleFactor,
                style: TextStyle(
                  fontSize: 14.0.sp,
                  fontFamily: 'opensansbold',
                  color: kCBrownColor,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget buildExpandedTopLeft() {
    return Expanded(
      child: Container(
          padding: EdgeInsets.only(left: 4.5.w),
          width: 20.0.w,
          height: 5.0.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SvgPicture.asset(
                'assets/madnimasjid.svg',
                width: 15.0.w,
                height: 3.5.h,
              )
            ],
          )),
    );
  }

  Widget buildExpandedTopRight() {
    return Expanded(
      child: Container(
          padding: EdgeInsets.only(left: 4.5.w),
          width: 20.0.w,
          height: 5.0.h,
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SvgPicture.asset(
                'assets/madnimasjid.svg',
                width: 20.0.w,
                height: 3.5.h,
              )
            ],
          )),
    );
  }
}

class LinearGradientMask extends StatelessWidget {
  LinearGradientMask({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return RadialGradient(
          center: Alignment.topLeft,
          radius: 1,
          colors: [Color(0XFFd18b38), Color(0XFFffc658)],
          tileMode: TileMode.mirror,
        ).createShader(bounds);
      },
      child: child,
    );
  }
}
