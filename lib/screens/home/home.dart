import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:walking_app/models/userData.dart';
import 'package:walking_app/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:walking_app/services/database.dart';
import 'package:provider/provider.dart';
import 'package:walking_app/models/user.dart';
import 'package:walking_app/screens/home/userData_list.dart';

class Main extends StatefulWidget {
  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {

  GoogleMapController _mapController;

  AuthService auth = AuthService();
  User user;
  DatabaseService dbase;
  dynamic data;

  int seconds = 0; // timer

  bool started = false; // start button
  String startStop = "Start"; // label of start button

  double speed = 0; // velocity

  double lng = 0; // longitude
  double ltd = 0; // latitude
  double firstLng = 0; // start longitude
  double firstLtd = 0; // start latitude
  double lng2 = 0; // longitude before
  double ltd2 = 0; // latitude before

  Timer timer; // delete
  int displayDistance = 0; // label of distance
  double distance2 = 0; // real distance
  double score = 0; // score

  double calories = 0; // calories burned
  /*
      https://www.verywellfit.com/walking-calories-burned-by-miles-3887154#:~:text=Your%20weight%20and%20the%20distance,for%20a%20120%2Dpound%20person.
      I used this table for calculating calories
  */

  int minutes = 0; // needed to display time
  int secs = 0; // same as above


  Set<Marker> _markers = {}; // marker
  Set<Polyline> _polylines = {}; // polyline set
  List<LatLng> polylineCoordinates = []; // coordinate set
  PolylinePoints polylinePoints = PolylinePoints(); // polylines


  /*
    function for start button
    starts or stops the process
  */
  void function(){
    setState(() {
      if(!started){

        started = true;

        startStop = "Stop";

        speed = 0;
        displayDistance = 0;
        seconds = 0;
        distance2 = 0;
        calories = 0;
        score = 0;

        _markers.clear();
        _polylines.clear();
        polylineCoordinates.clear();

        _markers.add(Marker(
          markerId: MarkerId("başlangıç"),
          position: LatLng(ltd2, lng2),
        ));

        setPolylines();

      } else if(started){

        started = false;

        startStop = "Start";

        speed = double.parse((distance2 / seconds).toStringAsFixed(3));
        score = double.parse(((3 * distance2 / 100) + ( 2 * speed / 10)).toStringAsFixed(2));
        calories = double.parse((distance2 * 0.046).toStringAsFixed(3));

        _markers.add(Marker(
          markerId: MarkerId("son"),
          position: LatLng(ltd, lng),
        ));

        print(user.uid);
        dbase = DatabaseService(uid: user.uid);
        getData();
        print(data["score"]);
        if(score > data["score"]) {
          dbase.updateUserData(score, data["name"]);
        }
        getData();
      }

    });

  }

  /*
  * Gets the location
  * */
  Future getLocation() async{

    try {
      Position position = await Geolocator().getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      lng2 = lng;
      ltd2 = ltd;

      lng = position.longitude;
      ltd = position.latitude;

      if (!started) {
        firstLng = lng;
        firstLtd = ltd;
      }

//      print("longtitude is $lng latitude is $ltd");
    } catch (e) {
      print("error in getLocation function: $e");
    }
  }

  getUser() async{
    user = await auth.getUser();
    print(user.uid);
  }

  /*
  * Measures the distance between 2 points
  * */
  int x = 1;
  void measureDistance() async{


    await getLocation();
    if(x == 1){
      await cameraUpdate();
      x++;
    }

    if(started){
      double distance = await Geolocator().distanceBetween(ltd2, lng2, ltd, lng);
      await cameraUpdate();
      distance2 += distance;
      displayDistance = distance2.toInt();
      speed = double.parse((distance2 / seconds).toStringAsFixed(3));
      score = double.parse(((3 * distance2 / 100) + ( 2 * speed / 10)).toStringAsFixed(2));
      calories = double.parse((distance2 * 0.046).toStringAsFixed(3));

      setPolylines();

      print("distance is $displayDistance");
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  /*
  * Updates the camera
  * */
  void cameraUpdate() async{
//    await getLocation();
    setState(() {
      _mapController.moveCamera(CameraUpdate.newLatLng(LatLng(ltd,lng)));
    });
    print("camera updated");
  }

  /*
  * Creates polylines
  * */
  void setPolylines() async {

    try {
      List<PointLatLng> result = new List(2);
      result[0] = PointLatLng(ltd2, lng2);
      result[1] = PointLatLng(ltd, lng);

      if (result.isNotEmpty) {
        // loop through all PointLatLng points and convert them
        // to a list of LatLng, required by the Polyline
        result.forEach((PointLatLng point) {
          polylineCoordinates.add(
              LatLng(point.latitude, point.longitude));
        });
      }
      setState(() {
        // create a Polyline instance
        // with an id, an RGB color and the list of LatLng pairs
        Polyline polyline = Polyline(

            polylineId: PolylineId("poly"),
            color: Colors.lightGreen,
            width: 5,
            points: polylineCoordinates
        );

        // add the constructed polyline as a set of points
        // to the polyline set, which will eventually
        // end up showing up on the map
        _polylines.add(polyline);
      });
    }
    catch (e) {
      print("error is $e");
    }
  }



  Future<dynamic> getData() async {
    await getUser();

    final DocumentReference document =   Firestore.instance.collection("userData").document(user.uid);

    await document.get().then<dynamic>(( DocumentSnapshot snapshot) async{
      setState(() {
        data =snapshot.data;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
    measureDistance();

    Timer.periodic(Duration(seconds: 1), (Timer t) {
      measureDistance();
//      cameraUpdate();
      if(started) {
        setState(() {
          seconds++;
          if(seconds >= 60){
            minutes = seconds ~/ 60;
            secs = seconds % 60;
          }
          else{
            minutes = 00;
            secs = seconds;
          }
        });
      }
    });

  }

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {

    return StreamProvider<List<UserData>>.value(
      value: DatabaseService().userData,
      child: PageView(
        children: [
          Scaffold(
            backgroundColor: Colors.amberAccent,
            appBar: AppBar(
              title: Text(
                  "Walking App"
              ),

              elevation: 0,
              backgroundColor: Colors.lightGreen,
              actions: <Widget>[
                FlatButton.icon(
                  icon: Icon(Icons.person),
                  onPressed: () async {
                    await _auth.signOut();
                    await FirebaseAuth.instance.signOut();
                  },
                  label: Text("logout"),
                ),
              ],
            ),

            body: Column(
              children: [
                Expanded(
                  flex: 9,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(ltd, lng),
                        zoom: 16,
                      ),
                      myLocationEnabled: true,
                      onMapCreated: _onMapCreated,
                      compassEnabled: true,
                      markers: _markers,
                      polylines: _polylines,
                      mapType: MapType.normal,
                    ),
                  ),
                ),


                Divider(height: 10, thickness: 4, color: Colors.grey[400],),

                // bottom part starts here
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [

                      Expanded(
                        flex: 3,

                        child:Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.only(left: 60, right: 60),
                                child: RaisedButton(
                                  onPressed: function,
                                  elevation: 0,
                                  child: Text(
                                    "$startStop",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            SizedBox(height: 10,),
                          ],
                        ),
                      ),

                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "Time",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),

                                  Divider(height: 10, thickness: 2, color: Colors.black,),

                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.indigo,
                                      border: Border.all(
                                        color: Colors.indigo,
                                        width: 8,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "$minutes:$secs",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  Text(
                                    "Distance",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),

                                  Divider(height: 10, thickness: 2, color: Colors.black,),

                                  Text(
                                    "$displayDistance meters",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                ],
                              ),
                            ),

                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  Text(
                                    "Velocity",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),

                                  Divider(height: 10, thickness: 2, color: Colors.black,),


                                  Text(
                                    "$speed m/s",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // FOR SCORE AND CALORIES
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    "Score",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Divider(height: 10, thickness: 2, color: Colors.black,),
                                  Text(
                                    "$score",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    "Calories",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),

                                  ),
                                  Divider(height: 10, thickness: 2, color: Colors.black,),
                                  Text(
                                    "$calories cal",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

              ],
            ),
          ),
          UserDataList(),
      ],
      ),
    );
  }
}