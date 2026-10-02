import 'package:flutter/material.dart';
import 'package:fs_sa/presentation/widgets/square_close_button.dart';

class ShowPaymentInfos extends StatefulWidget {
  const ShowPaymentInfos({
    super.key,
    this.stripeId,
    this.paypalEmail,
    required this.close,
  });

  final VoidCallback close;
  final int? stripeId;
  final String? paypalEmail;

  @override
  State<ShowPaymentInfos> createState() => _ShowPaymentInfosState();
}

class _ShowPaymentInfosState extends State<ShowPaymentInfos> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [Text('Stripe Id'), Text(widget.stripeId.toString())],
          ),
          Column(children: [Text('Paypal'), Text(widget.paypalEmail ?? 'n/c')]),
          SquareCloseButton(onPressed: widget.close),
        ],
      ),
    );
  }
}
