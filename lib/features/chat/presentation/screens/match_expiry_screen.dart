import 'dart:async';
import 'package:flutter/material.dart';
import 'package:blindly_dating_app/l10n/app_localizations.dart';
import 'package:blindly_dating_app/features/chat/presentation/screens/chat_detail_screen.dart';

class MatchExpiryScreen extends StatefulWidget {
  final String userName;
  final String userImage;
  final String matchId;
  final String myProfileId;
  final String otherProfileId;
  final Duration remainingTime;

  const MatchExpiryScreen({
    super.key,
    required this.userName,
    required this.userImage,
    required this.matchId,
    required this.myProfileId,
    required this.otherProfileId,
    required this.remainingTime,
  });

  @override
  State<MatchExpiryScreen> createState() => _MatchExpiryScreenState();
}

class _MatchExpiryScreenState extends State<MatchExpiryScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context);


  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.remainingTime;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds <= 0) {
        timer.cancel();
        setState(() {
          _remaining = Duration.zero;
        });
      } else {
        setState(() {
          _remaining -= const Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hours = _remaining.inHours;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              right: 16,
              top: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.black,
                  child: Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5C067),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l10n.expiringSoon,
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),

                  const SizedBox(height: 20),

                  CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(widget.userImage),
                  ),

                  const SizedBox(height: 25),

                  Text(
                    l10n.dontLetThemGetAway(widget.userName),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    l10n.limitedTimeBody,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _timeBox(hours, l10n.hoursLabel),
                      _timeBox(minutes, l10n.minutesLabel),
                      _timeBox(seconds, l10n.secondsLabel),
                    ],
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _remaining.inSeconds == 0
                          ? null
                          : () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatDetailScreen(
                                    name: widget.userName,
                                    imageUrl: widget.userImage,
                                    matchId: widget.matchId,
                                    myProfileId: widget.myProfileId,
                                    otherProfileId: widget.otherProfileId,
                                  ),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4B5335),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _remaining.inSeconds == 0
                            ? l10n.matchExpiredTitle
                            : l10n.messagePerson(widget.userName),
                        style: const TextStyle(
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      l10n.letThemGo,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeBox(int value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFE5C067),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}