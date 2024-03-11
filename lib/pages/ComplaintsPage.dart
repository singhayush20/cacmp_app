import 'dart:developer';

import 'package:cacmp_app/pages/LoginPage.dart';
import 'package:cacmp_app/stateUtil/NewComplaintController.dart';
import 'package:cacmp_app/util/SecureStorage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/themes/ColorConstants.dart';
import '../constants/widgets/CustomLoadingIndicator.dart';
import '../stateUtil/ComplaintController.dart';
import 'ComplaintDetailsPage.dart';
import 'NewComplaintsPage.dart';

class ComplaintsPage extends StatefulWidget {
  const ComplaintsPage({Key? key}) : super(key: key);

  @override
  State<ComplaintsPage> createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage>
    with AutomaticKeepAliveClientMixin {
  final ComplaintController _complaintController = Get.find();
  final SecureStorage _secureStorage=SecureStorage();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _fetchData(); // Fetch data when the page is first rendered
  }

  void _fetchData() async {
    final  response=await _complaintController.loadComplaints();
    if(response==2003){
      await _secureStorage.deleteOnLogOut();
      Get.off(()=>const LoginPage());
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _onRefresh() async {
    try {
      log('refreshing...');
      final  response=await _complaintController.loadComplaints();
      if(response==2003){
        await _secureStorage.deleteOnLogOut();
        Get.off(()=>const LoginPage());
      }
    } finally {
      if (mounted) {
        setState(() {});
      }
      _refreshController.refreshCompleted();
    }
  }

  void _onLoading() async {
    final  response=await _complaintController.loadComplaints();
    if(response==2003){
      await _secureStorage.deleteOnLogOut();
      Get.off(()=>const LoginPage());
    }
    if (mounted) {
      setState(() {});
    }
    _refreshController.loadComplete();
  }

  final AppBar _appBar = AppBar(
    title: const Text('Complaints'),
  );

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: const WaterDropMaterialHeader(
          color: Colors.white,
          backgroundColor: Colors.teal,
        ),
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus? mode) {
            Widget body;
            if (mode == LoadStatus.idle) {
              body = const Text("pull up load");
            } else if (mode == LoadStatus.loading) {
              body = const CustomLoadingIndicator(
                color: Colors.tealAccent,
              );
            } else if (mode == LoadStatus.failed) {
              body = const Text("Load Failed!Click retry!");
            } else if (mode == LoadStatus.canLoading) {
              body = const Text("release to load more");
            } else {
              body = const Text("No more Data");
            }
            return SizedBox(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: CustomScrollView(
          slivers: <Widget>[
          SliverToBoxAdapter(
            key: const Key('Heading'),
            child: Container(
              alignment: Alignment.center,
              height:height*0.1,
              padding: EdgeInsets.symmetric(horizontal: width*0.05,vertical: height*0.01),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "All Complaints",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(
                    width: width*0.4,
                    child: ElevatedButton(onPressed: (){

                      Get.to(()=>const NewComplaintsPage());
                    }, child:  const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(FontAwesomeIcons.plus),
                        Text("New Complaint")
                      ],
                    )),
                  )
                ],
              )
            ),
          ),
            SliverToBoxAdapter(
              key: const Key('List'),
              child: Obx(
                () => _complaintController.isLoadingComplaints.value
                    ? _buildShimmerLoading()
                    : _buildComplaintsList(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 5, // Number of shimmering items
      itemBuilder: (BuildContext context, int index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.white,
              radius: 30,
            ),
            title: Container(
              height: 16,
              width: 200,
              color: Colors.white,
            ),
            subtitle: Container(
              height: 12,
              width: 100,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildComplaintsList(BuildContext context) {
    return _complaintController.complaints.isEmpty
        ? Container(
            height: MediaQuery.of(context).size.height * 0.5,
            alignment: Alignment.bottomCenter,
            child: Center(
              child: Text(
                "No Complaints Found",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          )
        : ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _complaintController.complaints.length,
            itemBuilder: (BuildContext context, int index) {
              final complaint = _complaintController.complaints[index];
              return GestureDetector(
                onTap: () {
                  Get.to(() => ComplaintDetailsPage(
                      token: _complaintController
                          .complaints[index].complaintToken));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            complaint.complaintSubject,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: Colors.blue,
                                ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          _buildComplaintInfo(
                              "Category", complaint.complaintCategory),
                          _buildComplaintInfo(
                              "Status", complaint.complaintStatus),
                          _buildComplaintInfo(
                              "Comment", complaint.complaintDescription),
                          _buildComplaintInfo(
                              "Priority", complaint.complaintPriority),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
  }

  Widget _buildComplaintInfo(String label, String value) {
    Color textColor = Colors.black;
    if (label == "Priority") {
      if (value == "HIGH") {
        textColor = Colors.red;
      } else if (value == "MEDIUM") {
        textColor = Colors.yellow;
      } else if (value == "LOW") {
        textColor = Colors.green;
      }
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label:  ",
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w800,
                )),
        Expanded(
          // Use Expanded to allow the value to occupy multiple lines
          child: Text(
            value,
            maxLines: 3, // Allow multiple lines
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: textColor,
                ),
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
