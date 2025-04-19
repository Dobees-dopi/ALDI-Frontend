import 'package:flutter/material.dart';
import 'package:get/get.dart';
class PostItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool hasImage;

  const PostItem({
    Key? key,
    required this.title,
    required this.subtitle,
    this.hasImage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
                          onTap: () {
                            Get.toNamed('/detailfeed', arguments: {});
                          },
                          child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasImage)
                Container(
                  width: double.infinity,
                  height: 200,
                  margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
         color: Colors.grey,
          borderRadius: BorderRadius.circular(5),
    
        ),
                ),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                  
                      Icon(Icons.comment_outlined, size: 20, color: Colors.black54),
            
                    ],
                  ),
               
                      Row(
                    children: [
            Text(
                    '2024.01.19',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                      SizedBox(width: 10),
                      Icon(Icons.share_outlined, size: 20, color: Colors.black54),
                    ]
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    );
  
  }
}
