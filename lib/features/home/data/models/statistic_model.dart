import '../../domain/entities/statistic.dart';

class StatisticModel extends Statistic {
  const StatisticModel({
    required super.last3DaysRevenue,
    required super.onProgressCount,
    required super.readyForPickupCount,
    required super.pickedUpCount,
  });

  factory StatisticModel.fromRpcData({
    required List<Map<String, dynamic>> statusCounts,
    required int totalIncome,
  }) {
    // Initialize default counts
    int onProgressCount = 0;
    int readyForPickupCount = 0;
    int pickedUpCount = 0;

    // Create status counts map
    Map<String, int> statusCountsMap = {};

    // Process status counts from RPC
    for (var row in statusCounts) {
      final status = row['transaction_status'] as String?;
      final count = row['total'] as int? ?? 0;

      if (status != null) {
        statusCountsMap[status] = count;

        // Map to specific counters
        switch (status) {
          case 'On Progress':
            onProgressCount = count;
            break;
          case 'Ready for Pickup':
            readyForPickupCount = count;
            break;
          case 'Picked Up':
            pickedUpCount = count;
            break;
        }
      }
    }

    return StatisticModel(
      last3DaysRevenue: totalIncome,
      onProgressCount: onProgressCount,
      readyForPickupCount: readyForPickupCount,
      pickedUpCount: pickedUpCount,
    );
  }
}
