import '../../features/transaction/domain/entities/payment_status.dart';

DateTime? getPaidAtFromPaymentStatus(PaymentStatus? paymentStatus) {
  if (paymentStatus == PaymentStatus.paid) {
    return DateTime.now();
  }
  return null;
}
