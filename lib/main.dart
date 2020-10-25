import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:weather/weather.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

const priColor = Color(0xFF32db7e);
const mediColor = Color(0xFFf2e200);
const worstColor = Color(0xFFff4c30);
const worseColor = Color(0xFFff9f30);
const betterColor = Color(0xFFaaff00);
const bestColor = Color(0xFFF33ff00);
const whiteColor = Colors.white;

var now;
var formatter;

String formattedDate;
var formatterFull;
String formattedDateFull;
int feelLike = null;

String secondFormattedDate;
int secondFeelLike;
String secondControllerText;

String thirdFormattedDate;
int thirdFeelLike;
String thirdControllerText;

int _saveCounter = 0;
final _controller = TextEditingController();

void _loadPrefs() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  formattedDate = prefs.getString('formattedDate');
  feelLike = prefs.getInt('feelLike');
  _controller.text = prefs.getString('controllerText');
  secondFormattedDate = prefs.getString('secondFormattedDate');
  secondFeelLike = prefs.getInt('secondFeelLike');
  secondControllerText = prefs.getString('secondControllerText');
  thirdFormattedDate = prefs.getString('thirdFormattedDate');
  thirdFeelLike = prefs.getInt('thirdFeelLike');
  thirdControllerText = prefs.getString('thirdControllerText');
}

void _newestSave() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('formattedDate', formattedDate);
  await prefs.setInt('feelLike', feelLike);
  await prefs.setString('controllerText', _controller.text);
}

void _secondSave() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  secondFormattedDate = prefs.getString('formattedDate');
  secondFeelLike = prefs.getInt('feelLike');

  secondControllerText = prefs.getString('controllerText');
  await prefs.setString('secondFormattedDate', secondFormattedDate);
  await prefs.setInt('secondFeelLike', secondFeelLike);
  await prefs.setString('secondControllerText', secondControllerText);
}

void _third() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  thirdFormattedDate = prefs.getString('secondFormattedDate');
  thirdFeelLike = prefs.getInt('secondFeelLike');
  thirdControllerText = prefs.getString('secondControllerText');
  await prefs.setString('thirdFormattedDate', thirdFormattedDate);
  await prefs.setInt('thirdFeelLike', thirdFeelLike);
  await prefs.setString('thirdControllerText', thirdControllerText);
}

void _getSaveCounter() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('_saveCounterShared', _saveCounter);
  _saveCounter = prefs.getInt('_saveCounterShared');
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VibeTracker',
      theme: ThemeData(
        primaryColor: priColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadPrefs();

    if (!_locationCheceked) {
      _getLocation();
    }

    _calendarController = CalendarController();
    _getDay();
  }

  @override
  void dispose() {
    _controller.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  String _location = "BRAK";
  String _locationLatStr = "BRAK";
  String _locationLongStr = "BRAK";
  double _locationLat = 0;
  double _locationLong = 0;
  String _weatherFeel = "BRAK";
  String _weatherTemp = "BRAK";
  String _weatherCloud = "BRAK";
  String _weatherPress = "BRAK";
  bool _locationCheceked = false;

  CalendarController _calendarController;
  var _decodedCoords;
  String address;

  _showAbout() {
    return showAboutDialog(
        context: context,
        applicationVersion: 'Wersja prototypowa',
        applicationIcon: Image.asset(
          'assets/VIBETRACKER.png',
          width: 45,
          height: 45,
        ),
        children: [
          Text(
              "Podstawowym celem VibeTrackera, jest świadomość zrowia psychicznego użytkownika. W aplikacji możesz opisać swój dzień za pomocą emotek. Człowiek w zależności od pogody może mieć inny nastrój. Dlatego w aplikacji jest wbudowana prognoza pogdody.\n\n\n Aplikacja została stworzona podzczas konkursu Hack Heroes 2020 przez 2 uczniów szkoły średniej")
        ]);
  }

  Future<void> _showMyDialogLocation() async {
    var addressDialog = address;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Lokalizacja'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Obecna lokalizajca to:'),
                Text(
                  '$addressDialog',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Odśiweż'),
              onPressed: () {
                _getLocation();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showMyDialogSave() async {
    var addressDialog = address;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Center(
                    child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: Text(
                    'Zapisano',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                )),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _getLocation() async {
    Position position =
        await getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
    setState(() {
      _location = "${position.latitude}, ${position.longitude}";
      _locationLatStr = "${position.latitude}";
      _locationLongStr = "${position.longitude}";
      _locationLat = double.parse(_locationLatStr);
      _locationLong = double.parse(_locationLongStr);
    });
    _getAdress();
  }

  Future sleep1() {
    return new Future.delayed(const Duration(seconds: 4), () => "4");
  }

  void _getAdress() async {
    final coordinates = new Coordinates(_locationLat, _locationLong);
    _decodedCoords =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = _decodedCoords.first;
    print("${first.featureName} : ${first.addressLine}");
    setState(() {
      address = "${first.addressLine}";
    });
  }

  void _getWeather() async {
    WeatherFactory wf = new WeatherFactory("045cc58f70b079bf695858508c7ea0ba",
        language: Language.POLISH);
    Weather w = await wf.currentWeatherByLocation(_locationLat, _locationLong);
    setState(() {
      _weatherFeel = "${w.tempFeelsLike}";
      _weatherTemp = "${w.temperature}";
      _weatherCloud = "${w.cloudiness}";
      _weatherPress = "${w.pressure}";
    });
  }

  void _getDay() {
    setState(() {
      now = new DateTime.now();
      formatter = new DateFormat('dd');
      formatterFull = new DateFormat('dd' + '.' + 'MM');
      formattedDateFull = formatterFull.format(now);
      formattedDate = formatter.format(now);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            IconButton(
                icon: Icon(Icons.calendar_today),
                color: priColor,
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => CalendarPage()));
                }),
            IconButton(
                icon: Icon(Icons.location_on, color: priColor),
                onPressed: () {
                  _showMyDialogLocation();
                }),
            Spacer(),
            IconButton(
                icon: Icon(Icons.wb_sunny_rounded, color: priColor),
                onPressed: () {
                  _getWeather();
                }),
            IconButton(
                icon: Icon(Icons.help),
                color: priColor,
                onPressed: () {
                  _showAbout();
                }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save_sharp),
        onPressed: () {
          _getDay();
          _showMyDialogSave();
          _newestSave();
          _getSaveCounter();
          print(_saveCounter);
          if (_saveCounter == 1) {
            _secondSave();
            print("xd");
            print(secondControllerText);
          }
          if (_saveCounter <= 2) {
            _secondSave();
            _third();
          }
          _saveCounter++;
        },
        backgroundColor: priColor,
        elevation: 0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      appBar: AppBar(
        automaticallyImplyLeading: false, // ukrycie Hamburgera u góry
        actions: <Widget>[Container()],
        title: Text(
          "Vibe Tracker",
          style: TextStyle(color: whiteColor),
        ),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Spacer(
              flex: 1,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
              child: Text(
                "Jak sie dzisaj czujesz?",
                style: TextStyle(
                    color: priColor, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ClipOval(
                  child: Container(
                    width: 65,
                    height: 65,
                    color: whiteColor,
                    child: RaisedButton(
                      onPressed: () {
                        setState(() {
                          feelLike = 1;
                        });
                      },
                      color: whiteColor,
                      padding: EdgeInsets.all(0.0),
                      child: Image.asset(
                        'assets/5.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                ClipOval(
                  child: Container(
                    width: 65,
                    height: 65,
                    color: whiteColor,
                    child: RaisedButton(
                      onPressed: () {
                        setState(() {
                          feelLike = 2;
                        });
                      },
                      color: whiteColor,
                      padding: EdgeInsets.all(0.0),
                      child: Image.asset(
                        'assets/4.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                ClipOval(
                  child: Container(
                    width: 65,
                    height: 65,
                    color: whiteColor,
                    child: RaisedButton(
                      onPressed: () {
                        setState(() {
                          feelLike = 3;
                        });
                      },
                      color: whiteColor,
                      padding: EdgeInsets.all(0.0),
                      child: Image.asset(
                        'assets/3.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                ClipOval(
                  child: Container(
                    width: 65,
                    height: 65,
                    color: whiteColor,
                    child: RaisedButton(
                      onPressed: () {
                        setState(() {
                          feelLike = 4;
                        });
                      },
                      color: whiteColor,
                      padding: EdgeInsets.all(0.0),
                      child: Image.asset(
                        'assets/2.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                ClipOval(
                  child: Container(
                    width: 65,
                    height: 65,
                    color: whiteColor,
                    child: RaisedButton(
                      onPressed: () {
                        setState(() {
                          feelLike = 5;
                        });
                      },
                      color: whiteColor,
                      padding: EdgeInsets.all(0.0),
                      child: Image.asset(
                        'assets/1.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Spacer(
              flex: 2,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
              child: Text(
                "Co cie dzisiaj spotkało?",
                style: TextStyle(
                    color: priColor, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: TextFormField(
                controller: _controller,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    focusColor: priColor,
                    hoverColor: priColor),
              ),
            ),
            Spacer(
              flex: 2,
            ),
            Row(
              children: [
                Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: Row(
                      children: [
                        Text(
                          "Pogda dzisiaj ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        Text(
                          "($formattedDateFull): ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ],
                    )),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: RichText(
                text: TextSpan(
                  text: "Temp. Odzczuwalna: ",
                  style: TextStyle(fontSize: 20, color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(
                        text: '$_weatherFeel\n',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: priColor)),
                    TextSpan(
                      text: 'Temperatura: ',
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                    TextSpan(
                        text: '$_weatherTemp\n',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: priColor)),
                    TextSpan(
                      text: 'Zachmurzenie: ',
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                    TextSpan(
                        text: '$_weatherCloud%\n',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: priColor)),
                    TextSpan(
                      text: 'Ciśnienie: ',
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                    TextSpan(
                        text: '$_weatherPress hPa\n',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: priColor)),
                  ],
                ),
              ),
            ),
            Spacer(
              flex: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationsPage extends StatefulWidget {
  NotificationsPage({Key key}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: priColor,
        ),
      ),
    );
  }
}

class CalendarPage extends StatefulWidget {
  CalendarPage({Key key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  void initState() {
    super.initState();
    switch (feelLike) {
      case 1:
        {
          setState(() {
            newestImg = 'assets/5.png';
          });
        }
        break;
      case 2:
        {
          setState(() {
            newestImg = 'assets/4.png';
          });
        }
        break;
      case 3:
        {
          setState(() {
            newestImg = 'assets/3.png';
          });
        }
        break;
      case 4:
        {
          setState(() {
            newestImg = 'assets/2.png';
          });
        }
        break;
      case 5:
        {
          setState(() {
            newestImg = 'assets/1.png';
          });
        }
        break;
    }

    switch (secondFeelLike) {
      case 1:
        {
          setState(() {
            secImg = 'assets/5.png';
          });
        }
        break;
      case 2:
        {
          setState(() {
            secImg = 'assets/4.png';
          });
        }
        break;
      case 3:
        {
          setState(() {
            secImg = 'assets/3.png';
          });
        }
        break;
      case 4:
        {
          setState(() {
            secImg = 'assets/2.png';
          });
        }
        break;
      case 5:
        {
          setState(() {
            secImg = 'assets/1.png';
          });
        }
        break;
    }

    switch (thirdFeelLike) {
      case 1:
        {
          setState(() {
            thiImg = 'assets/5.png';
          });
        }
        break;
      case 2:
        {
          setState(() {
            thiImg = 'assets/4.png';
          });
        }
        break;
      case 3:
        {
          setState(() {
            thiImg = 'assets/3.png';
          });
        }
        break;
      case 4:
        {
          setState(() {
            thiImg = 'assets/2.png';
          });
        }
        break;
      case 5:
        {
          setState(() {
            thiImg = 'assets/1.png';
          });
        }

        break;
    }
  }

  String newestImg = "brak";
  String secImg = "brak";
  String thiImg = "brak";
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              "Vibe Tracker",
              style: TextStyle(color: whiteColor),
            ),
            elevation: 0,
          ),
          body: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Spacer(
                    flex: 1,
                  ),
                  RichText(
                    text: TextSpan(
                      text: "Ostatni Zapis:\n",
                      style: TextStyle(fontSize: 20, color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(text: 'Data: ', style: TextStyle()),
                        TextSpan(
                            text: '$formattedDate\n',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text("Samopoczucie:  ",
                          style: TextStyle(fontSize: 20, color: Colors.black)),
                      ClipOval(
                        child: Container(
                          width: 50,
                          height: 50,
                          child: Image.asset(newestImg),
                        ),
                      )
                    ],
                  ),
                  RichText(
                    text: TextSpan(
                      text: "Wpisany Tekst: ",
                      style: TextStyle(fontSize: 20, color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                            text: '${_controller.text}\n',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                  ),
                  Spacer(
                    flex: 1,
                  ),
                  RichText(
                    text: TextSpan(
                      text: "Drugi Zapis:\n",
                      style: TextStyle(fontSize: 20, color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(text: 'Data: ', style: TextStyle()),
                        TextSpan(
                            text: '$secondFormattedDate\n',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text("Samopoczucie:  ",
                          style: TextStyle(fontSize: 20, color: Colors.black)),
                      ClipOval(
                        child: Container(
                          width: 50,
                          height: 50,
                          child: Image.asset(secImg),
                        ),
                      )
                    ],
                  ),
                  RichText(
                    text: TextSpan(
                      text: "Wpisany tekst: ",
                      style: TextStyle(fontSize: 20, color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                            text: '$secondControllerText\n',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                  ),
                  Spacer(
                    flex: 1,
                  ),
                  RichText(
                    text: TextSpan(
                      text: "Trzeci Zapis:\n",
                      style: TextStyle(fontSize: 20, color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(text: 'Data: ', style: TextStyle()),
                        TextSpan(
                            text: '$thirdFormattedDate\n',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text("Samopoczucie:  ",
                          style: TextStyle(fontSize: 20, color: Colors.black)),
                      ClipOval(
                        child: Container(
                          width: 50,
                          height: 50,
                          child: Image.asset(thiImg),
                        ),
                      )
                    ],
                  ),
                  RichText(
                    text: TextSpan(
                      text: "Wpisany tekst: ",
                      style: TextStyle(fontSize: 20, color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                            text: '$thirdControllerText\n',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                  ),
                  Spacer(
                    flex: 1,
                  ),
                ],
              ),
            ],
          )),
    );
  }
}
