import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './HomePage.dart';
import"Dmeo.dart";
import 'package:google_fonts/google_fonts.dart';


class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;


  const OtpVerificationScreen({
    Key? key,
    required this.phoneNumber
  }) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
        (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
        (index) => FocusNode(),
  );

  int _remainingSeconds = 30;
  Timer? _timer;
  bool isLoading=false;

  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String otp) async {
    final String baseUrl = 'http://3.111.39.222/auth';
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-otp'), // Adjust the endpoint to match your backend route
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone_number': phoneNumber,
          'otp': otp,
        }),
      );

      final responseData = jsonDecode(response.body);
print(responseData);
      if (response.statusCode == 200) {
        // Existing user login
        return {
          'success': true,
          'message': responseData['message'],
          'user': responseData['user'],
          'isNewUser': false,
        };
      } else if (response.statusCode == 201) {
        // New user registration
        return {
          'success': true,
          'message': responseData['message'],
          'user_id': responseData['user_id'],
          'isNewUser': true,
        };
      } else {
        return {
          'success': false,
          'message': responseData['error'] ?? 'Failed to verify OTP',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error verifying OTP: $e',
      };
    }
  }


  @override
  void initState() {
    super.initState();
    _startTimer();

    // Setup focus listeners for OTP fields
    for (int i = 0; i < 6; i++) {
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus && _otpControllers[i].text.isNotEmpty) {
          _otpControllers[i].selection = TextSelection(
            baseOffset: 0,
            extentOffset: _otpControllers[i].text.length,
          );
        }
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _onOtpDigitChanged(String value, int index) {
    if (value.isNotEmpty) {
      // If digit entered, move to next field
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Last field, hide keyboard
        FocusScope.of(context).unfocus();
      }
    } else if (value.isEmpty && index > 0) {
      // If backspace pressed and field is empty, move to previous field
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Modified app bar to include back button and title
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black,size: 30,),
          onPressed: () => Navigator.pop(context),
        ),
        title:  Text(
          'OTP verification',
          style: GoogleFonts.leagueSpartan(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Phone number text
              Center( child:  Text(
                'Enter OTP sent to +91${widget.phoneNumber}',
                style: GoogleFonts.leagueSpartan(
                  fontSize: 24,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ),

              const SizedBox(height: 30),

              // OTP input fields
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // Center the boxes and reduce space
                children: List.generate(
                  6,
                      (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3), // Adjust horizontal spacing
                    child: SizedBox(
                      width: 50, // Decreased width
                      height: 80, // Increased height (optional, for overall container sizing)
                      child: TextField(
                        controller: _otpControllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        onChanged: (value) => _onOtpDigitChanged(value, index),
                        decoration: InputDecoration(
                          counterText: '',
                          isDense: true, // Reduces internal padding
                          contentPadding: EdgeInsets.symmetric(vertical: 20), // Adjust vertical padding
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.grey, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.grey, width: 1),
                          ),
                          hintText: '—',
                          hintStyle: const TextStyle(
                            fontSize: 24,
                            color: Colors.grey,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Auto verifying and resend text
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Auto verifying OTP',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Resend OTP in $_formattedTime',
                      style: GoogleFonts.leagueSpartan(
                        color: Colors.black,
                        fontSize: 19,
                        fontWeight:FontWeight.w500
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Verify button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    setState(() {
                      isLoading = true;
                    });

                    // Handle OTP verification
                    String otp = _otpControllers.map((controller) => controller.text).join();
                    if (otp.length == 6) {
                      // Process verification

                      final result = await verifyOtp(widget.phoneNumber, otp);

                      // Show message in SnackBar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result['message'])),
                      );

                      // Navigate if verification was successful
                      if (result['success']) {
                        if (result['isNewUser']) {
                          print('navigated to new page');
                          // New user - navigate to profile setup
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Dmeo (),
                            ),
                                (route) => false,
                          );
                        } else {
                          // print('error');
                          // Existing user - navigate to home
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Dmeo(),
                            ),
                                (route) => false,
                          );
                        }
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter a complete OTP')),
                      );
                    }

                    setState(() {
                      isLoading = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF49C71F), // Green color
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                    // Dim the button when loading
                    disabledBackgroundColor: const Color(0xFF49C71F).withOpacity(0.6),
                    disabledForegroundColor: Colors.white.withOpacity(0.7),
                  ),
                  child: isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      :  Text(
                    'Verify',
                    style: GoogleFonts.leagueSpartan(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
