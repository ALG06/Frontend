import 'package:flutter/material.dart';
import '../components/main_title.dart';

class CampaignView extends StatelessWidget {
  const CampaignView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GeneralTitle(title: 'Campaña'),
          // Add your campaign content here
        ],
      ),
    );
  }
}
