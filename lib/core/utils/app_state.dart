class AppState {
  static bool isChatScreenOpen = false;
  static bool isCallScreenOpen = false;

  // Which chat is currently open
  static String? currentChatProfileId;

  // Global caller information
  static String? callerId;
  static String? callerName;
  static String? callerImage;
  static String? callId;

  static void setCurrentChat(String? profileId) {
    currentChatProfileId = profileId;
    isChatScreenOpen = profileId != null;
  }
}