enum OrderStatus {
  pending,      // Status 1
  inProgress,   // Status 0
  completed,    // Status -1
  canceled,     // Status -2
  refunded,     // Status -3
}

extension OrderStatusExtension on OrderStatus {
  static OrderStatus fromInt(int status) {
    switch (status) {
      case 1:
        return OrderStatus.pending;
      case 0:
        return OrderStatus.inProgress;
      case -1:
        return OrderStatus.completed;
      case -2:
        return OrderStatus.canceled;
      case -3:
        return OrderStatus.refunded;
      default:
        throw Exception("Unknown status: $status");
    }
  }

  int toInt() {
    switch (this) {
      case OrderStatus.pending:
        return 1;
      case OrderStatus.inProgress:
        return 0;
      case OrderStatus.completed:
        return -1;
      case OrderStatus.canceled:
        return -2;
      case OrderStatus.refunded:
        return -3;
    }
  }

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return "Pending";
      case OrderStatus.inProgress:
        return "In Progress";
      case OrderStatus.completed:
        return "Completed";
      case OrderStatus.canceled:
        return "Canceled";
      case OrderStatus.refunded:
        return "Refunded";
    }
  }
}
