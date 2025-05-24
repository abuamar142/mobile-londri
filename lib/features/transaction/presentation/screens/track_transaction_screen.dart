import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/textstyle/app_textstyle.dart';

void pushTrackTransactionsScreen(BuildContext context) {
  context.pushNamed(RouteNames.trackTransactions);
}

class TrackTransactionsScreen extends StatelessWidget {
  const TrackTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Track Transactions Screen',
        style: AppTextStyle.heading3,
      ),
    );
  }
}
