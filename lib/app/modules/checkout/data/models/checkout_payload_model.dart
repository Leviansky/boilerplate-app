class CheckoutPayloadModel {
  final String itemId;
  final String variantId;
  final int quantity;
  final String? voucherCode;

  const CheckoutPayloadModel({
    required this.itemId,
    required this.variantId,
    required this.quantity,
    this.voucherCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'variant_id': variantId,
      'quantity': quantity,
      if (voucherCode != null && voucherCode!.isNotEmpty) 'voucher_code': voucherCode,
    };
  }

  factory CheckoutPayloadModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const CheckoutPayloadModel(
        itemId: '',
        variantId: '',
        quantity: 1,
      );
    }
    return CheckoutPayloadModel(
      itemId: json['item_id']?.toString() ?? '',
      variantId: json['variant_id']?.toString() ?? '',
      quantity: int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      voucherCode: json['voucher_code']?.toString(),
    );
  }
}

/// Server-Calculated Checkout Invoice
class CheckoutInvoiceModel {
  final String checkoutToken;
  final int subtotalAmount; // Zero-Float integer Rupiah
  final int discountAmount; // Zero-Float integer Rupiah
  final int shippingFee; // Zero-Float integer Rupiah
  final int adminFee; // Zero-Float integer Rupiah
  final int totalAmount; // Zero-Float integer Rupiah
  final String itemName;
  final String variantName;

  const CheckoutInvoiceModel({
    required this.checkoutToken,
    required this.subtotalAmount,
    required this.discountAmount,
    required this.shippingFee,
    required this.adminFee,
    required this.totalAmount,
    required this.itemName,
    required this.variantName,
  });

  factory CheckoutInvoiceModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const CheckoutInvoiceModel(
        checkoutToken: '',
        subtotalAmount: 0,
        discountAmount: 0,
        shippingFee: 0,
        adminFee: 0,
        totalAmount: 0,
        itemName: '',
        variantName: '',
      );
    }

    return CheckoutInvoiceModel(
      checkoutToken: json['checkout_token']?.toString() ?? '',
      subtotalAmount: int.tryParse(json['subtotal_amount']?.toString() ?? '0') ?? 0,
      discountAmount: int.tryParse(json['discount_amount']?.toString() ?? '0') ?? 0,
      shippingFee: int.tryParse(json['shipping_fee']?.toString() ?? '0') ?? 0,
      adminFee: int.tryParse(json['admin_fee']?.toString() ?? '0') ?? 0,
      totalAmount: int.tryParse(json['total_amount']?.toString() ?? '0') ?? 0,
      itemName: json['item_name']?.toString() ?? '',
      variantName: json['variant_name']?.toString() ?? '',
    );
  }
}
