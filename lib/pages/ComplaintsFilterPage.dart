import 'dart:developer';

import 'package:cacmp_app/constants/appConstants/AppConstants.dart';
import 'package:cacmp_app/constants/widgets/AppSnackbar.dart';
import 'package:cacmp_app/pages/LoginPage.dart';
import 'package:cacmp_app/stateUtil/ComplaintController.dart';
import 'package:cacmp_app/util/SecureStorage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../constants/themes/AppTheme.dart';
import '../constants/themes/ColorConstants.dart';
import '../constants/widgets/CustomLoadingIndicator.dart';

class ComplaintsFilterPage extends StatefulWidget {
  const ComplaintsFilterPage({super.key});

  @override
  State<ComplaintsFilterPage> createState() => _ComplaintsFilterPageState();
}

class _ComplaintsFilterPageState extends State<ComplaintsFilterPage> {
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _wardNoController = TextEditingController();
  ComplaintPriority? _complaintPriority;
  ComplaintStatus? _complaintStatus;
  final ComplaintController _complaintController = Get.find();
  final SecureStorage _secureStorage = SecureStorage();
  final AppBar _appBar = AppBar(
    title: const Text('Complaints'),
  );
  String _sortBy="createdAt";

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: kPrimaryColor,
      statusBarIconBrightness: Brightness.light,
      systemStatusBarContrastEnforced: true,
      systemNavigationBarColor: kPrimaryColor,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.white,
    ));
    return Scaffold(
        appBar: _appBar,
        body: SingleChildScrollView(
            child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: width * 0.05, vertical: height * 0.01),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 2.0.h),
              TextFormField(
                controller: _wardNoController,
                keyboardType: TextInputType.text,
                decoration: inputFormFieldBoxDecoration.copyWith(
                  labelText: 'Ward No.',
                  hintText: 'Enter your ward no.',
                  prefixIcon: const Icon(Icons.home),
                ),
              ),
              SizedBox(height: 2.0.h),
              TextFormField(
                controller: _pinCodeController,
                keyboardType: TextInputType.number,
                decoration: inputFormFieldBoxDecoration.copyWith(
                  labelText: 'PinCode',
                  hintText: 'Your pincode',
                  prefixIcon: const Icon(Icons.home),
                ),
              ),
              SizedBox(height: 2.0.h),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DropdownButton<ComplaintPriority>(
                      value: _complaintPriority,
                      onChanged: (newValue) {
                        setState(() {
                          _complaintPriority = newValue;
                        });
                      },
                      items: [
                        DropdownMenuItem<ComplaintPriority>(
                          value: ComplaintPriority.low,
                          child: Text(ComplaintPriority.low.value),
                        ),
                        DropdownMenuItem<ComplaintPriority>(
                          value: ComplaintPriority.medium,
                          child: Text(ComplaintPriority.medium.value),
                        ),
                        DropdownMenuItem<ComplaintPriority>(
                          value: ComplaintPriority.high,
                          child: Text(ComplaintPriority.high.value),
                        ),
                      ],
                      hint: Text(
                        'Priority',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      underline: Container(
                        color: Colors.black,
                        height: 1,
                      ),
                      icon: Icon(
                        FontAwesomeIcons.arrowDown,
                        color: kPrimaryColor,
                        size: 15,
                      ),
                    ),
                    DropdownButton<ComplaintStatus>(
                      value: _complaintStatus,
                      onChanged: (newValue) {
                        setState(() {
                          _complaintStatus = newValue;
                        });
                      },
                      items: [
                        DropdownMenuItem<ComplaintStatus>(
                          value: ComplaintStatus.open,
                          child: Text(ComplaintStatus.open.value),
                        ),
                        DropdownMenuItem<ComplaintStatus>(
                          value: ComplaintStatus.reviewed,
                          child: Text(ComplaintStatus.reviewed.value),
                        ),
                        DropdownMenuItem<ComplaintStatus>(
                          value: ComplaintStatus.closed,
                          child: Text(ComplaintStatus.closed.value),
                        ),
                      ],
                      hint: Text(
                        'Status',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      underline: Container(
                        color: Colors.black,
                        height: 1,
                      ),
                      icon: Icon(
                        FontAwesomeIcons.arrowDown,
                        color: kPrimaryColor,
                        size: 15,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.0.h),
             Row(
               mainAxisAlignment: MainAxisAlignment.start,
               crossAxisAlignment: CrossAxisAlignment.center,
               children: [
                 Text("Sort by: ",style: Theme.of(context).textTheme.bodyMedium,),
                 const SizedBox(width: 5,),
                 DropdownButton<String>(
                   items: const [
                     DropdownMenuItem(
                       value: 'createdAt',
                       child: Text('Created recently'),
                     ),
                     DropdownMenuItem(
                       value: 'updatedAt',
                       child: Text('Updated Recently'),
                     ),
                   ],
                   onChanged: (value) async{
                     log('before setting... $_sortBy $value');
                    setState(() {
                      _sortBy = value ?? 'createdAt';
                    });
                     log('after setting... $_sortBy $value');

                   },
                   value: _sortBy,

                   underline: Container(
                     color: Colors.black,
                     height: 1,
                   ),
                   icon: Icon(
                     FontAwesomeIcons.arrowDown,
                     color: kPrimaryColor,
                     size: 15,
                   ),
                 ),
               ],
             ),
              SizedBox(height: 2.0.h),
              Container(
                width: width,
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: (_complaintController.isLoadingComplaints.value)
                      ? null
                      : () async {
                         _complaintController.loadComplaints(
                                  pinCode: _pinCodeController.text,
                                  wardNo: _wardNoController.text,
                                  status: _complaintStatus?.value,
                                  priority: _complaintPriority?.value,
                                  sortBy: _sortBy);
                        Get.back();
                        },
                  child: (_complaintController.isLoadingComplaints.value)
                      ? const CustomLoadingIndicator(
                          color: Colors.white,
                        )
                      : Text(
                          'Search',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        )));
  }
}
