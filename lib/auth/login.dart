import 'package:cspc_recog_manage/auth/groupSelect.dart';
import 'package:cspc_recog_manage/face_recog/mainPage.dart';
//import 'package:cspc_recog/auth/groupSelect.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../urls.dart';
import 'package:cspc_recog_manage/auth/models/loginUser.dart';

import 'package:flutter/services.dart';
import 'package:cspc_recog_manage/auth/register.dart';

import 'models/user.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  LoginUser myLogin;
  User myUser;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarColor: Colors.transparent));
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.blue, Colors.white70],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: <Widget>[
                  headerSection(),
                  textSection(),
                  buttonSection(),
                ],
              ),
      ),
    );
  }

  signIn(String id, pass) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    final response = await http.post(
      Uri.parse(UrlPrefix.urls + "users/auth/login/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "username": id,
        "password": pass,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data != null) {
        setState(() {
          _isLoading = false;
        });
        myLogin = LoginUser.fromJson(data);

        userGet(myLogin.token);

        /*
        print(myUser.userId);
        print(myUser.userName);
        */
        final user = Provider.of<LoginUserProvier>(context, listen: false);
        user.getUserData(data);

        //logOut(myLogin.token);

        sharedPreferences.setString("token", myLogin.token);
        //print(sharedPreferences.getString("token"));

        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => MainPage()),
            (Route<dynamic> route) => false);
      }
    } else {
      print("login false");
      setState(() {
        _isLoading = false;
      });
      print(response.body);
    }
  }

  userGet(String token) async {
    String knoxToken = 'Token ' + token;
    final response = await http.get(
      Uri.parse(UrlPrefix.urls + "users/auth/user/"),
      headers: <String, String>{
        'Authorization': knoxToken,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data != null) {
        myUser = User.fromJson(data);
        print(myUser.userId);
        print(myUser.userName);

        /*
        setState(() {
          _isLoading = false;
        });*/

      }
    } else {
      /*
      setState(() {
        _isLoading = false;
      });*/
    }
  }

  /*
    토큰 넣어주면 해당 토큰 사라짐
   */
  logOut(String token) async {
    String knoxToken = 'Token ' + token;

    final response = await http.post(
      Uri.parse(UrlPrefix.urls + "users/auth/logout/"),
      headers: <String, String>{
        'Authorization': knoxToken,
      },
    );

    print("logout");
    print(response.statusCode);

    if (response.statusCode == 204) {
      print("logout!");
    } else {
      print("logout false");
    }
  }

  Container buttonSection() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 15.0,
      ),
      margin: EdgeInsets.only(top: 25.0),
      child: Column(children: <Widget>[
        ElevatedButton(
          child: Text(
            "Sign In",
            style: TextStyle(color: Colors.white70, fontSize: 20),
          ),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            primary: Colors.indigoAccent,
            onPrimary: Colors.black,
            minimumSize: Size(MediaQuery.of(context).size.width, 40),
          ),
          onPressed: () {
            setState(() {
              _isLoading = true;
            });
            signIn(idController.text, passwordController.text);
          },
        ),
        SizedBox(height: 20.0),
        TextButton(
          child: Text(
            "Don't have an account yet? Sign Up",
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            setState(() {
              _isLoading = true;
            });

            Navigator.of(context).push(
                //MaterialPageRoute(builder: (BuildContext context) => RegisterPage()));
                MaterialPageRoute(
                    builder: (BuildContext context) => MainPage()));
          },
        )
      ]),
    );
  }

  final TextEditingController idController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  Container textSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: idController,
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.email, color: Colors.white70),
              hintText: "ID",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
          SizedBox(height: 30.0),
          TextFormField(
            controller: passwordController,
            cursorColor: Colors.white,
            obscureText: true,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.lock, color: Colors.white70),
              hintText: "Password",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Container headerSection() {
    return Container(
      margin: EdgeInsets.only(top: 50.0),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: Text("Login",
          style: TextStyle(
              color: Colors.white70,
              fontSize: 40.0,
              fontWeight: FontWeight.bold)),
    );
  }
}
