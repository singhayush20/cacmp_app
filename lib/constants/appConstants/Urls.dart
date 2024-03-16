import 'AppConstants.dart';

//authentication
const String loginUrl="$requestUrl/consumer/login";
const String signUpUrl="$requestUrl/consumer/register";
const String logoutUrl="$requestUrl/consumer/logout";


//complaint
const String listComplaintsUrl="$requestUrl/complaints/all";
const String complaintDetailsUrl="$requestUrl/complaints/details";
const String complaintImagesUrl="$requestUrl/complaints/details/images";
const String saveComplaintUrl="$requestUrl/complaints/save";
const String saveComplaintImagesUrl="$requestUrl/complaints/images/save";
const String saveFeedbackUrl="$requestUrl/complaints/feedback";
//category
const String categoriesListUrl="$requestUrl/category";


//user data
const String userDataUrl="$requestUrl/consumer";

//poll
const String pollListUrl="$requestUrl/poll/poll-list";
const String pollDetailsUrl="$requestUrl/poll/details";
const String castVoteUrl="$requestUrl/poll/cast-vote";
