enum OrderPaymentStatus {
  pending,
  awaitingVerification,
  paid,
  expired,
  failed,
}

class PaymentChannelModel {
  final String code;
  final String name;
  final String category; // VIRTUAL_ACCOUNT, E_WALLET, CREDIT_CARD
  final String iconUrl;
  final int fee; // Minor integer Rupiah

  const PaymentChannelModel({
    required this.code,
    required this.name,
    required this.category,
    required this.iconUrl,
    required this.fee,
  });

  factory PaymentChannelModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PaymentChannelModel(
        code: '',
        name: '',
        category: '',
        iconUrl: '',
        fee: 0,
      );
    }
    return PaymentChannelModel(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      iconUrl: json['icon_url']?.toString() ?? '',
      fee: int.tryParse(json['fee']?.toString() ?? '0') ?? 0,
    );
  }
}

class PaymentResultModel {
  final String orderId;
  final String transactionId;
  final OrderPaymentStatus status;
  final int totalPaid; // Zero-Float integer Rupiah
  final String paymentChannel;
  final String? vaNumber;
  final String? qrCodeUrl;
  final String paidAt;

  const PaymentResultModel({
    required this.orderId,
    required this.transactionId,
    required this.status,
    required this.totalPaid,
    required this.paymentChannel,
    this.vaNumber,
    this.qrCodeUrl,
    required this.paidAt,
  });

  factory PaymentResultModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PaymentResultModel(
        orderId: '',
        transactionId: '',
        status: OrderPaymentStatus.failed,
        totalPaid: 0,
        paymentChannel: '',
        paidAt: '',
      );
    }

    final rawStatus = json['status']?.toString().toLowerCase() ?? '';
    OrderPaymentStatus paymentStatus;
    switch (rawStatus) {
      case 'paid':
      case 'success':
        paymentStatus = OrderPaymentStatus.paid;
        break;
      case 'awaiting_verification':
        paymentStatus = OrderPaymentStatus.awaitingVerification;
        break;
      case 'expired':
        paymentStatus = OrderPaymentStatus.expired;
        break;
      case 'failed':
        paymentStatus = OrderPaymentStatus.failed;
        break;
      case 'pending':
      default:
        paymentStatus = OrderPaymentStatus.pending;
        break;
    }

    return PaymentResultModel(
      orderId: json['order_id']?.toString() ?? '',
      transactionId: json['transaction_id']?.toString() ?? '',
      status: paymentStatus,
      totalPaid: int.tryParse(json['total_paid']?.toString() ?? '0') ?? 0,
      paymentChannel: json['payment_channel']?.toString() ?? '',
      vaNumber: json['va_number']?.toString(),
      qrCodeUrl: json['qr_code_url']?.toString(),
      paidAt: json['paid_at']?.toString() ?? '',
    );
  }
}
