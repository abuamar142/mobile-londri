enum TransactionStatus {
  onProgress('On Progress'),
  readyForPickup('Ready for Pickup'),
  pickedUp('Picked Up'),
  other('Other');

  final String value;
  const TransactionStatus(this.value);

  factory TransactionStatus.fromString(String value) {
    return TransactionStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => TransactionStatus.onProgress,
    );
  }

  @override
  String toString() => value;
}

enum PaymentStatus {
  notPaidYet('Not Paid Yet'),
  paid('Paid'),
  other('Other');

  final String value;
  const PaymentStatus(this.value);

  factory PaymentStatus.fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PaymentStatus.notPaidYet,
    );
  }

  @override
  String toString() => value;
}
