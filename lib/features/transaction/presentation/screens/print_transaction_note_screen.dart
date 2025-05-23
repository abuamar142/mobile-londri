import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/textstyle/app_sizes.dart';
import '../../../../config/textstyle/app_textstyle.dart';

void pushPrintTransactionNoteScreen({
  required BuildContext context,
  String? transactionId,
}) {
  context.pushNamed(
    'print-transaction',
    pathParameters: {
      'id': transactionId.toString(),
    },
  );
}

class PrintTransactionNoteScreen extends StatelessWidget {
  final String? transactionId;

  const PrintTransactionNoteScreen({
    super.key,
    this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Print Transaction Note',
          style: AppTextStyle.heading3,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSizes.paddingAll16,
          child: Center(
            child: Text(
              'Print Transaction Note Screen for ID: $transactionId',
              style: AppTextStyle.body1,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
