import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Widget customGrid() {
  return Container(
    height: 215,
    decoration: BoxDecoration(
      color: const Color.fromARGB(197, 221, 245, 245),

      borderRadius: BorderRadius.circular(21),
    ),
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: GridView(
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Two columns
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.8, // Adjust as needed
        ),
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: const Color.fromARGB(255, 19, 95, 176),
            ),
            child: Center(
              child: Text('Left Side', style: TextStyle(color: Colors.white)),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),

                  child: Image.asset("assets/result.jpg", fit: BoxFit.cover,),
                ),
              ),
              SizedBox(height: 10), // Space between cells
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),

                  child: Center(
                    child: Text(
                      'Bottom Right',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
