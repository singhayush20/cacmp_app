import 'dart:developer';

import 'package:cacmp_app/constants/widgets/AppSnackbar.dart';
import 'package:cacmp_app/constants/widgets/CustomLoadingIndicator2.dart';
import 'package:cacmp_app/pages/LoginPage.dart';
import 'package:cacmp_app/stateUtil/PollController.dart';
import 'package:cacmp_app/util/SecureStorage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../constants/themes/ColorConstants.dart';

class PollDetailsPage extends StatefulWidget {
  final String token;

  const PollDetailsPage({Key? key, required this.token}) : super(key: key);

  @override
  State<PollDetailsPage> createState() => _PollDetailsPageState();
}

class _PollDetailsPageState extends State<PollDetailsPage> {
  late TooltipBehavior _tooltipBehavior;
  final PollController _pollController = Get.find();
  final SecureStorage _secureStorage= SecureStorage();

  late Map<String, dynamic> _pollData;
  int _selectedChoiceIndex = -1;
  bool _errorVisible = false;


  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(enable: true);
  }



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
      appBar: AppBar(
        title: const Text('Details'),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.squarePollVertical,),
            onPressed: ()  {
              _showPieChartDialog();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _pollController.getPollDetails(pollToken: widget.token),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if(snapshot.data!['code'] == 2003){
                _secureStorage.deleteOnLogOut();
                Get.offAll(()=>const LoginPage());
                AppSnackbar.showSnackbar(title: "Login Again", description: "Please login again!");
              }
              else if(snapshot.data!['code'] != 2000){
                return _errorUI();
              }
              log("${snapshot.data}");
              _pollData = snapshot.data!['data'];
              return _buildPollUI(height: height, width: width);
            }
            return _buildShimmerLoading(height: height, width: width);
          },
        ),
      ),
    );
  }

  Widget _buildPollUI({required double height, required double width}) {
    final List<dynamic> pollChoices = _pollData['pollChoiceDetails'];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _pollData['subject'],
            style:Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _pollData['description'],
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: pollChoices.length,
            itemBuilder: (context, index) {
              final choice = pollChoices[index];
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedChoiceIndex = index;
                    _errorVisible = false; // Reset error visibility
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _selectedChoiceIndex == index ? const Color(0xFF00BAA9).withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      width:2 ,
                      color: _selectedChoiceIndex == index ? const Color(0xFF00BAA9) : Colors.grey,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(choice['choiceName']),
                      if (_selectedChoiceIndex == index)
                        const Icon(Icons.check, color: Color(0xFF00BAA9)),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          if (_errorVisible)
            const Text(
              'Please select an option',
              style: TextStyle(color: Colors.red),
            ),
          const SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: width * 0.1),
            width: width,
            child: ElevatedButton(
              onPressed: _pollController.isSavingVote.value ? null: _selectedChoiceIndex == -1 ? () {
                setState(() {
                  _errorVisible = true;
                });
              } : ()async {
               final int code=await  _pollController.castVote(
                  pollToken: widget.token,
                  choiceToken: _pollData['pollChoiceDetails'][_selectedChoiceIndex]['choiceToken'],
                );
               if(code==2000){
                 Get.back();
                 AppSnackbar.showSnackbar(title: "Success", description: "Vote casted successfully!");
               }
               else if(code==2003){
                 _secureStorage.deleteOnLogOut();
                 Get.offAll(()=>const LoginPage());
                 AppSnackbar.showSnackbar(title: "Login Again", description: "Please login again!");
               }
               else if(code==2005){
                 AppSnackbar.showSnackbar(title: "Not allowed!", description: "Already voted!");
               }
               else{
                 AppSnackbar.showSnackbar(title: "Error", description: "Something went wrong!");
               }
              },
              child: _pollController.isSavingVote.value ? const CustomLoadingIndicator2(color: Colors.black54):const Text('Save Vote'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading({required double height, required double width}) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: height * 0.2,
              width: width,
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.05,
                vertical: height * 0.01,
              ),
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildPollUIShimmer(height: height, width: width),
        ],
      ),
    );
  }

  Widget _buildPollUIShimmer({required double height, required double width}) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 10, // Number of shimmering items
      itemBuilder: (BuildContext context, int index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(width: 2, color: Colors.grey),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: width * 0.7,
                  height: 16,
                  color: Colors.white,
                ),
                const Icon(Icons.check, color: Colors.transparent),
              ],
            ),
          ),
        );
      },
    );
  }


  void _showPieChartDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Poll Results'),
        content: Container(
          height: 300,
          width: 300,
          child: createResultChart(),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Get.back(); // Close the dialog
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }


  Widget _errorUI () {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      alignment: Alignment.bottomCenter,
      child: Center(
        child: Text(
          "Failed to load data",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget createResultChart(){
    List<ChoiceCount> choiceCountList=[];
    for(int i=0;i<_pollData['pollChoiceDetails'].length;i++){
      choiceCountList.add(ChoiceCount(choiceName: _pollData['pollChoiceDetails'][i]['choiceName'],count: _pollData['pollChoiceDetails'][i]['voteCount']));
    }
    return ResultChart(choiceCountList: choiceCountList);
  }

  Widget ResultChart({required List<ChoiceCount> choiceCountList}){
//Doughnut Chart, RadiobarSeries,
    return SfCircularChart(
      title: const ChartTitle(text:'Poll results'),
      legend: const Legend(isVisible: true,overflowMode: LegendItemOverflowMode.wrap),
      tooltipBehavior: _tooltipBehavior,
      series: <CircularSeries>[
        PieSeries<ChoiceCount, String>(
          dataSource: choiceCountList,
          xValueMapper: (ChoiceCount data, _) => data.choiceName,
          yValueMapper: (ChoiceCount data, _) => data.count,
          dataLabelSettings: const DataLabelSettings(
            isVisible: true
          ),
          enableTooltip: true,
        ),
      ],
    );
  }

}

class ChoiceCount{
  String choiceName;
  int count;
  ChoiceCount({required this.choiceName,required this.count});
}
