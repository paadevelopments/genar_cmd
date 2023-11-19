import 'package:flutter/material.dart';
import 'constants.dart';

// Splash Widget
Widget splashWidget(bool showSplash, bool isRefreshingPg, String errorMessage, double screenW, double screenH, Function callback) {
  return !showSplash ? const SizedBox(width: 0,height: 0,) : Container(
    decoration: const BoxDecoration(color: colorPrimary),
    child: GestureDetector(
      onTap: () => callback(),
      child: Stack(children: [
        Center(child: SizedBox(
          width: screenW * 0.2, height: screenW * 0.2,
          child: Image.asset(splashIcon, fit: BoxFit.fitWidth,),
        ),),
        Column(children: [
          Expanded(child: Container(),),
          isRefreshingPg
          ? SizedBox(
            height: screenW * 0.065, width: screenW * 0.065,
            child: const CircularProgressIndicator(color: Colors.white,),
          )
          : Text(
            errorMessage,
            style: TextStyle(color: Colors.white, fontSize: screenW * 0.03), textAlign: TextAlign.center,
          ),
          SizedBox(height: screenH * 0.05,),
          Text(
            'Made With 💜 By Genar',
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: screenW * 0.03),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenH * 0.05,),
        ],),
      ],),
    ),
  );
}

// Progress Widget
Widget progressWidget(bool showProgress, double progress, double screenW, double screenH) {
  return !showProgress ? const SizedBox(width: 0,height: 0,) : Column(children: [
    LinearProgressIndicator(
      value: progress, color: colorAccent, backgroundColor: colorAccent.withOpacity(0.5),
      minHeight: screenH * 0.003,
    ),
    Expanded(child: Container())
  ],);
}
