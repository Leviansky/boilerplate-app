import "package:testing_boilerplate/core/network/error_handler.dart";
import "package:testing_boilerplate/app/modules/checkout/data/models/checkout_payload_model.dart";
import "package:testing_boilerplate/app/modules/checkout/data/models/payment_result_model.dart";
import "package:testing_boilerplate/app/modules/checkout/data/providers/checkout_provider.dart";

class CheckoutRepository {
  final CheckoutProvider _provider;

  CheckoutRepository(this._provider);

  Future<CheckoutInvoiceModel> validateCheckout(CheckoutPayloadModel payload) async {
    try {
      final response = await _provider.validateAndCalculateCheckout(payload);
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ServerFailure(response.message, response.statusCode);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<List<PaymentChannelModel>> fetchPaymentChannels() async {
    try {
      final response = await _provider.getPaymentChannels();
      if (response.success && response.data != null) {
        return response.data!;
      }
      return <PaymentChannelModel>[];
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<PaymentResultModel> submitPayment({
    required String checkoutToken,
    required String paymentChannelCode,
    String? pinVerificationToken,
  }) async {
    try {
      final response = await _provider.processPayment(
        checkoutToken: checkoutToken,
        paymentChannelCode: paymentChannelCode,
        pinVerificationToken: pinVerificationToken,
      );
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ServerFailure(response.message, response.statusCode);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
