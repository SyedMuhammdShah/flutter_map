import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_example/pages/auth/auth_server.dart';
import 'package:flutter_map_example/pages/auth/register.dart';
import 'package:flutter_map_example/pages/screen_point_to_latlng.dart';

import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscurePassword = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                //  Image.asset('assets/images/pic1.png'),

                    Text("Login",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 40, color: Colors.green),),
                  TextFormField(
                    controller: _email,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email_outlined),
                      labelText: 'Email',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _password,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: _togglePasswordVisibility,
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _signup();
                        String email = _email.text;
                        String password = _password.text;
                        print('Full Name: $email');
                        print('Full Name: $password');
                      } else {
                        print('Form validation failed');
                      }
                    },
                    child: const Text('Submit'),
                  ),
                    Row(
                    children: [
                      Text("Create an account!"),
                      SizedBox(width: 5,),
                       TextButton(onPressed: (){
                        Get.to(RegisterScreen());
                       }, child: Text("Register",style: TextStyle(color: Colors.green),))
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  _signup() async {
     User? userId = FirebaseAuth.instance.currentUser;

  final user = await _auth.loginUserWithEmailAndPassword(_email.text, _password.text);


   if(user != null){
      print("something went wrong");
      Get.to(ScreenPointToLatLngPage());
   }
}

}

