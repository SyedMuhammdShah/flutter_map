import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_example/pages/auth/auth_server.dart';
import 'package:flutter_map_example/pages/auth/login.dart';
import 'package:flutter_map_example/pages/home.dart';
import 'package:flutter_map_example/pages/screen_point_to_latlng.dart';

import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = AuthService();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullName = TextEditingController();
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

                    Text("Register yourself",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30, color: Colors.green),),
                  TextFormField(
                    controller: _fullName,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      labelText: 'Full Name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
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
                        String fullName = _fullName.text;
                        String email = _email.text;
                        String password = _password.text;
                
                      } else {
                        print('Form validation failed');
                      }
                    },
                    child: const Text('Submit'),
                  ),
                  Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Already have accout!"),
                      SizedBox(width: 5,),
                       TextButton(onPressed: (){
                        Get.to(LoginScreen());
                       }, child: Text("Login",style: TextStyle(color: Colors.green)))
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
    // User? userId = FirebaseAuth.instance.currentUser;

final user = await _auth.registerUser(_email.text, _password.text, _fullName.text);

if (user != null) {
  print('User registered successfully!');
  Get.to(ScreenPointToLatLngPage());
  // Handle successful registration (e.g., navigate to next screen)
} else {
  print('Error registering user.');
  // Handle registration errors (e.g., display an error message)
}
}

}

