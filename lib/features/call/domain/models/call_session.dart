class CallSession {
  final String callId;
  final String channelName;
  final bool isVideo;
  final bool isCaller;
  final String myProfileId;
  final String otherProfileId;
  final String otherUserName;
  final String otherUserImage;
  final String status;

  CallSession({
    required this.callId,
    required this.channelName,
    required this.isVideo,
    required this.isCaller,
    required this.myProfileId,
    required this.otherProfileId,
    required this.otherUserName,
    required this.otherUserImage,
    required this.status,
  });
}