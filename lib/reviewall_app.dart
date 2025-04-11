import 'package:flutter/material.dart';
import 'package:reviewall_mobile/media.dart';


const baseUrlApi = 'https://67e6f0a56530dbd31111f8e2.mockapi.io/reviewall'; 


const Color primaryGray = Color(0xFF333333); 
const Color secondaryGray = Color(0xFF4D4D4D);
const Color accentGray = Color(0xFF666666);
const Color lightGray = Color(0xFFAAAAAA);
const Color backgroundColor = Color(0xFF222222);


const primaryColor = primaryGray;
const primaryColorLight = secondaryGray;
const secondaryColor = accentGray;
const secondaryColorLight = lightGray;
const fontColor = Colors.white;


class MediaTab extends StatelessWidget {
  const MediaTab({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    home: MediaListScaffold(),
  );
  }
}
