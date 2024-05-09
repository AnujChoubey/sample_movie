import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class TopRatedWidget extends StatefulWidget{
  final String? imgUrl;
  final String? title;
  final String? desc;
  final int? votes;
  final double? score;

  TopRatedWidget({this.imgUrl, this.title, this.desc, this.votes, this.score});

  @override
  State<TopRatedWidget> createState() => _TopRatedWidgetState();
}

class _TopRatedWidgetState extends State<TopRatedWidget> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  Container(
      padding: EdgeInsets.all(6),
      margin: EdgeInsets.only(bottom: 32,left: 16,right: 16),
      height: 280,
      width: MediaQuery.of(context).size.width-64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  widget.imgUrl??'',
                  fit: BoxFit.fill,
                  height: 160,
                  width: MediaQuery.of(context).size.width-32,

                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade600,
                    shape:BoxShape.circle
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.remove_red_eye_outlined,color: Colors.white,size: 16,),
                      Text(
                        '71K',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(

            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  widget.title??'',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_month_outlined,size: 12,color: Colors.grey,),
                    SizedBox(width: 3,),
                    SizedBox(
                      width: MediaQuery.of(context).size.width*0.7,
                      child: Text(
                        widget.desc??"",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle( fontSize: 12),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      formatNumber(widget.votes??1),
                      style: TextStyle( fontSize: 16),
                    ),
                    SizedBox(width: 8),
                    Text('|',style: TextStyle(color: Colors.grey,fontSize: 16),),
                    SizedBox(width: 8),

                    Text(
                      '${widget.score}',
                      style: TextStyle( fontSize: 16),
                    ),
                    Icon(Icons.star, color: Colors.yellow, size: 20),

                  ],
                ),
              ],
            ),
          ),
        ],
      ),

    );
  }
  String formatNumber(int num) {
    if (num < 1000) {
      return num.toString();
    } else if (num < 1000000) {
      return (num / 1000).toStringAsFixed(1) + 'K Votes';
    } else if (num < 1000000000) {
      return (num / 1000000).toStringAsFixed(1) + 'M Votes';
    } else {
      return (num / 1000000000).toStringAsFixed(1) + 'B Votes';
    }
  }

}
