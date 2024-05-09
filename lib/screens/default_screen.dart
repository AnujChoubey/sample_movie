import 'package:flutter/material.dart';

class DefaultScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
   return Scaffold(
     body: Column(
       crossAxisAlignment: CrossAxisAlignment.center,
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
         Row(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Text('Coming Soon'),
           ],
         )
       ],
     ),
   );
  }

}