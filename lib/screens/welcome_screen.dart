import 'package:chat_app/screens/login_screen.dart';
import 'package:chat_app/screens/registration_screen.dart';
import 'package:chat_app/screens/components/roundedButtonW.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class WelcomeScreen extends StatefulWidget {
  static const id = "welcome_screen";
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation animation;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));

    animation = ColorTween(begin: Colors.blueGrey, end: Colors.white)
        .animate(controller);

    controller.forward();

    controller.addListener(() {
      setState(() {
        print(controller.value);
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Flexible(
                  child: Hero(
                    tag: 'icon',
                    child: Container(
                      child: Image.asset('images/logo.png'),
                      height: 60.0,
                    ),
                  ),
                ),
                AnimatedTextKit(
                  totalRepeatCount: 1,
                  animatedTexts: [
                    TypewriterAnimatedText('Flash Chat',
                        speed: Duration(milliseconds: 150),
                        textStyle: TextStyle(
                          fontSize: 45.0,
                          fontWeight: FontWeight.w900,
                        )),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundedButton(
                color: Colors.lightBlueAccent,
                title: 'Log In',
                onPressed: () => Navigator.pushNamed(context, LoginScreen.id)),
            RoundedButton(
                color: Colors.blueAccent,
                title: 'Register',
                onPressed: () =>
                    Navigator.pushNamed(context, RegistrationScreen.id)),
          ],
        ),
      ),
    );
  }
}
