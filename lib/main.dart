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
import 'package:masjid/Values/constants.dart';
import 'package:sizer/sizer.dart';

import 'landscape.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Madni Masjid',
          theme: ThemeData.light(),
          // home: LandscapeScreen(),
          home: orientation == Orientation.portrait
              ? MyHomePage()
              : LandscapeScreen(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
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
  String islamicDayString = "",
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
        return MyHomePage();
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
        barrierColor: Color(0XFFDCCD12),
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
                return MyHomePage();
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
            return MyHomePage();
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
    return Scaffold(
      backgroundColor: Color(0xfffdfbf4),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: kDividerColorBehindClock.withOpacity(0.1),
              image: DecorationImage(
                image: AssetImage("assets/background.png"),
                repeat: ImageRepeat.repeat,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      kDividerColorBehindClock.withOpacity(0.1),
                      kDividerColorBehindClock.withOpacity(0.3),
                      kDividerColorBehindClock.withOpacity(0.6),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )),
                  height: 6.0.h,
                  padding: EdgeInsets.only(left: 10.0, right: 30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildExpandedTop(),
                      buildExpandedTop(),
                    ],
                  ),
                ),
                SizedBox(
                  height: 1.2.h,
                  width: 100.0.w,
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.01,
                  width: 100.0.w,
                  color: kDividerColorBehindClock.withOpacity(0.8),
                ),
                Container(
                  width: 100.0.w,
                  // padding: EdgeInsets.all(1.0.w),
                  child: Row(
                    children: [
                      buildExpandedBottomOfClock(),
                      Spacer(),
                      buildExpandedBottomOfClockOtherSide(),
                    ],
                  ),
                ),
                Container(
                  height: 7.5.h,
                  width: 100.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        Color(0xff280659),
                        Color(0xff341671).withOpacity(0.8),
                        // Color(0xff422680).withOpacity(0.7),
                      ],
                      stops: [0.4, 1],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  // color: kBackColorDivider,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          // "ASAR",
                          namazName,
                          textScaleFactor: kTextSCaleFactor,
                          style: TextStyle(
                            fontSize: kValue24.sp,
                            fontFamily: kFontPalitino,
                            color: kWhiteColor,
                            height: 1.5,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 2.5.w,
                      ),
                      Text(
                        "In",
                        textScaleFactor: kTextSCaleFactor,
                        style: TextStyle(
                          fontSize: kValue14.sp,
                          fontFamily: kFontOpensans,
                          fontWeight: FontWeight.bold,
                          color: kWhiteColor,
                        ),
                      ),
                      SizedBox(
                        width: 1.0.w,
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
                              '$namazName is Started',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'BwModelicaExtraBold',
                                  fontSize: 20.0.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0XFF745d23)),
                            );
                          }
                          return Text(
                            namazName == '----'
                                ? '----'
                                : '${time.hours == null ? '0' : format(time.hours!)} : ${time.min == null ? '0' : format(time.min!)} : ${time.sec == null ? '00' : format(time.sec!)} ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'BwModelicaExtraBold',
                              fontSize: 20.0.sp,
                              fontWeight: FontWeight.w700,
                              color: kWhiteColor,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                      width: 100.w,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 25.0),
                            child: buildSingleListItem(
                                'فجر', kFAJRText, _jFajar, bFajar),
                          ),
                          Divider(color: kCBrownColor.withOpacity(0.5)),
                          buildSingleListItem(
                              'ظهر', kZOHARText, _jZohar, bZohar),
                          Divider(color: kCBrownColor.withOpacity(0.5)),
                          buildSingleListItem('عصر', kASARText, _jAsar, bAsar),
                          Divider(color: kCBrownColor.withOpacity(0.5)),
                          buildSingleListItem(
                              'مغرب', kMAGHRIBText, _jMagharib, bMagharib),
                          Divider(color: kCBrownColor.withOpacity(0.5)),
                          buildSingleListItem('عشاء', kISHAText, _jIsha, bIsha),
                          Stack(
                            children: [
                              Container(
                                margin: EdgeInsets.only(bottom: 1.0.h),
                                width: 100.0.w,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Divider(
                                        color: kCBrownColor.withOpacity(0.5)),
                                    Container(
                                      padding: EdgeInsets.all(1.0.w),
                                      width: 25.0.w,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0)),
                                        color: Colors.white,
                                      ),
                                      child: Text(
                                        'Jamaat Time',
                                        textScaleFactor: kTextSCaleFactor,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: kFontOpensans,
                                            fontSize: 12.0.sp,
                                            color: kCBrownColor),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Positioned(
                                right: 4.0.w,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Divider(
                                          color: kCBrownColor.withOpacity(0.5),
                                        ),
                                        Container(
                                          width: 27.0.w,
                                          padding: EdgeInsets.all(1.0.w),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(4.0)),
                                            color: Colors.white,
                                          ),
                                          child: Text(
                                            'Beginning Time',
                                            textAlign: TextAlign.center,
                                            textScaleFactor: kTextSCaleFactor,
                                            style: TextStyle(
                                              fontFamily: kFontOpensans,
                                              fontSize: 12.0.sp,
                                              color: kCBrownColor,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      )),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.09,
                  width: 100.0.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        Color(0xff280659),
                        Color(0xff341671).withOpacity(0.8),
                        // Color(0xff422680).withOpacity(0.7),
                      ],
                      stops: [0.4, 1],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: Container(
                            child: buildColumnTimeGap(sehriString, "SEHRI")),
                      ),
                      Container(
                        width: 1.2,
                        margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                        decoration: new BoxDecoration(color: Colors.white),
                      ),
                      Expanded(
                        child: Container(
                            child:
                                buildColumnTimeGap(sunriseString, "SUNRISE")),
                      ),
                      Container(
                        width: 1.2,
                        margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                        decoration: new BoxDecoration(color: Colors.white),
                      ),
                      Expanded(
                        child: Container(
                            child: buildColumnTimeGap(noonString, "NOON")),
                      ),
                      Container(
                        width: 1.2,
                        margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                        decoration: new BoxDecoration(color: Colors.white),
                      ),
                      Expanded(
                        child: Container(
                            child: buildColumnTimeGap(jumuahString, "JUMUAH")),
                      ),
                    ],
                  ),
                ),
                Container(
                    width: 100.0.w,
                    height: 5.0.h,
                    child: Marquee(
                      text: topTitle,
                      style: TextStyle(
                          fontSize: 14.0.sp,
                          color: kCBrownColor,
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
                    )),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.topCenter,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Image(
                  image: AssetImage("assets/clock.png"),
                  height: 14.5.h,
                ),
              ),
              Container(
                width: 13.5.w,
                height: 13.5.w,
                margin: EdgeInsets.only(top: 2.4.h),
                child: FlutterAnalogClock(
                  dateTime: DateTime.now(),
                  dialPlateColor: portraitOrientationgradientColor2,
                  hourHandColor: Colors.white,
                  minuteHandColor: Colors.white,
                  centerPointColor: Colors.white,
                  showMinuteHand: true,
                  showNumber: true,
                  showBorder: false,
                  showTicks: false,
                  showSecondHand: false,
                  isLive: true,
                  width: MediaQuery.of(context).size.width * 0.13,
                  height: MediaQuery.of(context).size.width * 0.13,
                  // child: Text('Clock'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Column buildColumnTimeGap(String time, String timeGap) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          time,
          textScaleFactor: kTextSCaleFactor,
          style: TextStyle(
              fontSize: kValue14.sp,
              color: kDividerColorBehindClock,
              fontFamily: kFontPalitino),
        ),
        Text(
          timeGap,
          textScaleFactor: kTextSCaleFactor,
          style: TextStyle(
              fontSize: 14.0.sp,
              color: Colors.white,
              fontFamily: kFontsOpensansBold),
        )
      ],
    );
  }

  Widget buildSingleListItem(
      String image, String firstString, String endString, String startString) {
    return Container(
      width: 100.0.w,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.only(left: 2.0.w),
            width: 33.33.w,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LinearGradientMask(
                  child: Text(
                    image,
                    textScaleFactor: kTextSCaleFactor,
                    style: TextStyle(
                        fontSize: 20.0.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                // Icon(iconData),
                Text(
                  firstString,
                  textScaleFactor: kTextSCaleFactor,
                  style: TextStyle(
                    fontSize: 14.0.sp,
                    fontFamily: kFontOpensans,
                    fontWeight: FontWeight.bold,
                    color: Color(0XFF8a5819),
                  ),
                )
              ],
            ),
          ),
          Container(
            width: 33.33.w,
            alignment: Alignment.center,
            // height: 8.0.h,
            // padding: EdgeInsets.all(1.0.w),
            child: LinearGradientMask(
              child: Text(endString,
                  textScaleFactor: kTextSCaleFactor,
                  textAlign: TextAlign.center,
                  // style: kEndTime,
                  style: TextStyle(
                      fontSize: kValue26.sp,
                      fontFamily: kFontPalitino,
                      height: 1.5,
                      color: Colors.white)),
            ),
          ),
          Container(
            width: 33.33.w,
            child: Text(
              startString,
              textScaleFactor: kTextSCaleFactor,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22.0.sp,
                fontFamily: 'opensansbold',
                fontWeight: FontWeight.bold,
                color: Color(0XFF8a5819),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Expanded buildExpandedBottomOfClock() {
    return Expanded(
      child: Container(
          width: 30.0.w,
          margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
          child: Text(
            prayerDateFormat + "\n" + prayerDateYear,
            textScaleFactor: kTextSCaleFactor,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: kColorJummah,
              fontFamily: kFontPalitino,
              fontSize: 16.0.sp,
            ),
          )),
    );
  }

  Expanded buildExpandedBottomOfClockOtherSide() {
    return Expanded(
      child: Container(
          width: 30.0.w,
          margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
          child: Text(
            // "28 Jamadul\nAkhir",
            islamicDayString,
            textScaleFactor: kTextSCaleFactor,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Colors.deepPurple,
              fontFamily: kFontPalitino,
              fontSize: 16.0.sp,
            ),
          )),
    );
  }

  Widget buildExpandedTop() {
    return Container(
      width: 30.0.w,
      child: SvgPicture.asset(
        'assets/madnimasjid.svg',
        width: 15.0.w,
        height: 3.7.h,
      ),
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
