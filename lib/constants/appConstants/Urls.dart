import 'AppConstants.dart';

//authentication
const String loginUrl = "$requestUrl/consumer/login";
const String signUpUrl = "$requestUrl/consumer/register";
const String logoutUrl = "$requestUrl/consumer/logout";
const String tokenValidityUrl = "$requestUrl/consumer/check-token";
const String emailVerificationUrl="$requestUrl/consumer/email/otp";
const String emailVerificationOtpUrl="$requestUrl/consumer/email/verify";
const String phoneVerificationOtoUrl="$requestUrl/consumer/phone/otp";
const String phoneVerificationOtpUrl="$requestUrl/consumer/phone/verify";
const String changeOldPasswordUrl="$requestUrl/consumer/password/old/change";
const String passwordForgetUrl="$requestUrl/consumer/password/forget";
const String passwordChangeUrl="$requestUrl/consumer/password/change";

//complaint
const String listComplaintsUrl = "$requestUrl/complaints/all";
const String complaintDetailsUrl = "$requestUrl/complaints/details";
const String complaintImagesUrl = "$requestUrl/complaints/details/images";
const String saveComplaintUrl = "$requestUrl/complaints/save";
const String saveComplaintImagesUrl = "$requestUrl/complaints/images/save";
const String saveFeedbackUrl = "$requestUrl/complaints/feedback";
//category
const String categoriesListUrl = "$requestUrl/category";

//user data
const String userDataUrl = "$requestUrl/consumer";

//poll
const String pollListUrl = "$requestUrl/poll/poll-list";
const String pollDetailsUrl = "$requestUrl/poll/details";
const String castVoteUrl = "$requestUrl/poll/cast-vote";

//alerts
const String alertsUrl = "$requestUrl/alert/feed";
const String alertDetailsUrl = "$requestUrl/alert";


//article feed
const String articleFeedUrl="$requestUrl/article/feed";
