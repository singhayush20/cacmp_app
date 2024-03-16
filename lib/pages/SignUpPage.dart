import 'package:cacmp_app/constants/widgets/AppSnackbar.dart';
import 'package:cacmp_app/stateUtil/AuthController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../constants/appConstants/AppConstants.dart';
import '../constants/themes/AppTheme.dart';
import '../constants/themes/ColorConstants.dart';
import '../constants/widgets/CustomLoadingIndicator2.dart';

class SignUp extends StatefulWidget {
  final String email;

  const SignUp({Key? key, required this.email}) : super(key: key);


  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _houseNoController = TextEditingController();
  final TextEditingController _localityController = TextEditingController();
  final TextEditingController _wardNoController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  Gender _gender=Gender.male;
  final _formKey = GlobalKey<FormState>();
  bool _isResident = false;

  final _appBar=AppBar(
    title: const Text('Sign Up'),
  );

  final AuthController _authController=Get.find();


  @override
  void initState() {
    _emailController.text=widget.email;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: kPrimaryColor,
      statusBarIconBrightness: Brightness.light,
      systemStatusBarContrastEnforced: true,
      systemNavigationBarColor: kPrimaryColor,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.white,
    ));
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height- _appBar.preferredSize.height;

    return Scaffold(
      appBar: _appBar,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(4.0.w),
          child: Column(
            children: [
              Container(
                height: height*0.15,
                alignment: Alignment.center,
                width: width,
                child: Text('if you are a resident, please provide your address. It will help us to provide better services.',
                style: Theme.of(context).textTheme.bodyMedium,)
              ),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      decoration: inputFormFieldBoxDecoration.copyWith(
                        labelText: 'Name',
                        prefixIcon: const Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 2.0.h),
                    TextFormField(
                      enabled: false,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: inputFormFieldBoxDecoration.copyWith(
                        labelText: 'Email',
                        hintText: 'Email',
                        prefixIcon: const Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Invalid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 2.0.h),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: inputFormFieldBoxDecoration.copyWith(
                        labelText: 'Password',
                        hintText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 2.0.h),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: inputFormFieldBoxDecoration.copyWith(
                        labelText: 'Phone',
                        hintText: 'Phone',
                        prefixIcon: const Icon(Icons.phone),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 2.0.h),
                    Row(
                      children: [
                        const Text('Account Type:'),
                        SizedBox(width: 5.0.w),
                        DropdownButton<bool>(
                          value: _isResident,
                          onChanged: (newValue) {
                            setState(() {
                              _isResident = newValue!;
                            });
                          },
                          items: const [
                            DropdownMenuItem<bool>(
                              value: true,
                              child: Text('Resident'),
                            ),
                            DropdownMenuItem<bool>(
                              value: false,
                              child: Text('Non-Resident'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Gender:'),
                        SizedBox(width: 5.0.w),
                        DropdownButton<Gender>(
                          value: _gender,
                          onChanged: (newValue) {
                            setState(() {
                              _gender=newValue!;
                            });
                          },
                          items:  [
                            DropdownMenuItem<Gender>(
                              value: Gender.female,
                              child: Text(Gender.female.value),
                            ),
                            DropdownMenuItem<Gender>(
                              value: Gender.male,
                              child: Text(Gender.male.value),
                            ),
                            DropdownMenuItem<Gender>(
                              value: Gender.other,
                              child: Text(Gender.other.value),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        SizedBox(height: 2.0.h),
                        TextFormField(
                          controller: _houseNoController,
                          keyboardType: TextInputType.text,
                          decoration: inputFormFieldBoxDecoration.copyWith(
                            labelText: 'House No',
                            hintText: 'House No',
                            prefixIcon: const Icon(Icons.home),
                          ),
                          validator: (value){
                            if(_isResident && (value==null|| value.trim().isEmpty)){
                              return "Please enter your house no.";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 2.0.h),
                        TextFormField(
                          controller: _localityController,
                          keyboardType: TextInputType.text,
                          decoration: inputFormFieldBoxDecoration.copyWith(
                            labelText: 'Locality',
                            hintText: 'Locality',
                            prefixIcon: const Icon(Icons.location_city),
                          ),
                          validator: (value){
                            if(_isResident && (value==null|| value.trim().isEmpty)){
                              return "Please enter your locality";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 2.0.h),
                        TextFormField(
                          controller: _wardNoController,
                          keyboardType: TextInputType.number,
                          decoration: inputFormFieldBoxDecoration.copyWith(
                            labelText: 'Ward No',
                            hintText: 'Ward No',
                            prefixIcon: const Icon(Icons.location_on),
                          ),
                          validator: (value){
                            if(_isResident && (value==null|| value.trim().isEmpty)){
                              return "Please enter your ward no.";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 2.0.h),
                        TextFormField(
                          controller: _pinCodeController,
                          keyboardType: TextInputType.number,
                          decoration: inputFormFieldBoxDecoration.copyWith(
                            labelText: 'Pincode',
                            hintText: 'Pincode',
                            prefixIcon: const Icon(Icons.pin),
                          ),
                          validator: (value){
                           if(_isResident){
                             if( (value==null|| value.trim().isEmpty)){
                               return "Please enter your pin code";
                             }
                             if (value.length != 6) {
                               return 'Pincode must be 6 digits long';
                             }
                             if (!isNumeric(value)) {
                               return 'Pincode must contain only numbers';
                             }
                           }
                            return null;
                          },
                        ),
                        SizedBox(height: 2.0.h),
                        TextFormField(
                          controller: _cityController,
                          keyboardType: TextInputType.text,
                          decoration: inputFormFieldBoxDecoration.copyWith(
                            labelText: 'City',
                            hintText: 'City',
                            prefixIcon: const Icon(Icons.location_city),
                          ),
                          validator: (value){
                            if(_isResident && (value==null|| value.trim().isEmpty)){
                              return "Please enter your city";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 2.0.h),
                        TextFormField(
                          controller: _stateController,
                          keyboardType: TextInputType.text,
                          decoration: inputFormFieldBoxDecoration.copyWith(
                            labelText: 'State',
                            hintText: 'State',
                            prefixIcon: const Icon(Icons.location_city),
                          ),
                          validator: (value){
                            if(_isResident && (value==null|| value.trim().isEmpty)){
                              return "Please enter your state";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 4.0.h),
                    ElevatedButton(
                      onPressed: () async{
                        FocusScope.of(context).unfocus();
                        if (_formKey.currentState!.validate()) {
                          int code=await _authController.signUp(
                              name: _nameController.text,
                              email: _emailController.text,
                              password: _passwordController.text,
                              phone: int.parse(_phoneController.text),
                              houseNo: _houseNoController.text,
                              locality: _localityController.text,
                              wardNo: _wardNoController.text,
                              pinCode: _pinCodeController.text,
                              city: _cityController.text,
                              state: _stateController.text,
                              isResident: _isResident,
                              gender: _gender.value);

                          if(code==2000){
                            AppSnackbar.showSnackbar(title: "Registration successful", description: "Your account is created successfully!");
                            Get.back();
                          }
                          else if(code==2002){
                            AppSnackbar.showSnackbar(title: "Cannot register with these details", description: "Please check the data!");
                          }
                          else {
                            AppSnackbar.showSnackbar(title: "Some error occurred!", description: "Please try again!");
                          }
                        }
                      },
                      child: (_authController.isSigningUp.value) ?
                      const CustomLoadingIndicator2(
                        color: Colors.white,
                      ): const Text('Sign Up'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isNumeric(String? s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }
}
