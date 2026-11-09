import 'package:flutter/material.dart';
import 'package:get/get.dart';
import "package:testing_boilerplate/core/config/remote_config_service.dart";
import "package:testing_boilerplate/core/network/error_handler.dart";
import "package:testing_boilerplate/app/shared/widgets/screen_state_view.dart";
import "package:testing_boilerplate/app/routes/app_routes.dart";
import "package:testing_boilerplate/app/modules/checkout/data/models/checkout_payload_model.dart";
import "package:testing_boilerplate/app/modules/checkout/data/models/payment_result_model.dart";
import "package:testing_boilerplate/app/modules/checkout/data/repo/checkout_repository.dart";

class CheckoutController extends GetxController {
  final CheckoutRepository _repository;

  CheckoutController(this._repository);

  late final TextEditingController voucherController;

  // Granular Observables
  final viewStatus = ViewStatus.initial.obs;
  final invoice = Rxn<CheckoutInvoiceModel>();
  final paymentChannels = <PaymentChannelModel>[].obs;
  final selectedChannel = Rxn<PaymentChannelModel>();
  final paymentResult = Rxn<PaymentResultModel>();

  // Pessimistic Locking Flag
  final isSubmittingPayment = false.obs;
  final errorMessage = ''.obs;

  late final String itemId;
  late final String variantId;
  int quantity = 1;

  @override
  void onInit() {
    super.onInit();
    voucherController = TextEditingController();

    itemId = Get.arguments?['item_id']?.toString() ?? 'prod-1';
    variantId = Get.arguments?['variant_id']?.toString() ?? '';
    quantity = int.tryParse(Get.arguments?['quantity']?.toString() ?? '1') ?? 1;

    initializeCheckout();
  }

  @override
  void onClose() {
    voucherController.dispose();
    super.onClose();
  }

  Future<void> initializeCheckout() async {
    try {
      viewStatus.value = ViewStatus.loading;
      errorMessage.value = '';

      final payload = CheckoutPayloadModel(
        itemId: itemId,
        variantId: variantId,
        quantity: quantity,
        voucherCode: voucherController.text.trim().isNotEmpty ? voucherController.text.trim() : null,
      );

      final invoiceFuture = _repository.validateCheckout(payload);
      final channelsFuture = _repository.fetchPaymentChannels();

      final results = await Future.wait([invoiceFuture, channelsFuture]);

      invoice.value = results[0] as CheckoutInvoiceModel;
      final allChannels = results[1] as List<PaymentChannelModel>;

      // Filter through RemoteConfig feature flag
      final enabledChannels = allChannels.where((channel) {
        if (Get.isRegistered<RemoteConfigService>()) {
          return RemoteConfigService.to.isPaymentMethodEnabled(channel.category);
        }
        return true;
      }).toList();

      paymentChannels.assignAll(enabledChannels);

      if (paymentChannels.isNotEmpty) {
        selectedChannel.value = paymentChannels.first;
      }

      viewStatus.value = ViewStatus.success;
    } catch (e) {
      final failure = ErrorHandler.handle(e);
      if (failure is NetworkFailure) {
        viewStatus.value = ViewStatus.noConnection;
      } else {
        errorMessage.value = failure.message;
        viewStatus.value = ViewStatus.error;
      }
    }
  }

  void selectPaymentChannel(PaymentChannelModel channel) {
    selectedChannel.value = channel;
  }

  /// Pessimistic Strict Locking Payment Submission
  Future<void> submitPayment() async {
    if (isSubmittingPayment.value) return; // Prevent double submission
    final currentInvoice = invoice.value;
    final currentChannel = selectedChannel.value;

    if (currentInvoice == null || currentChannel == null) {
      errorMessage.value = 'Silakan pilih metode pembayaran yang valid.';
      return;
    }

    try {
      isSubmittingPayment.value = true;
      errorMessage.value = '';

      final result = await _repository.submitPayment(
        checkoutToken: currentInvoice.checkoutToken,
        paymentChannelCode: currentChannel.code,
      );

      paymentResult.value = result;

      // Navigate to order success screen
      Get.offNamed(
        Routes.ORDER_SUCCESS,
        arguments: {'order_id': result.orderId},
      );
    } catch (e) {
      final failure = ErrorHandler.handle(e);
      errorMessage.value = failure.message;
      Get.snackbar(
        'Gagal Memproses Pembayaran',
        failure.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmittingPayment.value = false;
    }
  }
}
