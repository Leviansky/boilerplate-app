import 'package:dio/dio.dart';
import "package:testing_boilerplate/core/network/api_client.dart";
import "package:testing_boilerplate/core/network/api_endpoints.dart";
import "package:testing_boilerplate/app/shared/models/base_api_response_model.dart";
import "package:testing_boilerplate/app/modules/checkout/data/models/checkout_payload_model.dart";
import "package:testing_boilerplate/app/modules/checkout/data/models/payment_result_model.dart";

class CheckoutProvider {
  final ApiClient _apiClient;

  CheckoutProvider(this._apiClient);

  Future<BaseApiResponseModel<CheckoutInvoiceModel>> validateAndCalculateCheckout(
    CheckoutPayloadModel payload,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.checkoutValidate,
      data: payload.toJson(),
      options: Options(
        extra: {'encrypt': true}, // Encrypt sensitive order calculation
      ),
    );

    return BaseApiResponseModel<CheckoutInvoiceModel>.fromJson(
      response.data as Map<String, dynamic>?,
      (data) => CheckoutInvoiceModel.fromJson(data as Map<String, dynamic>?),
    );
  }

  Future<BaseApiResponseModel<List<PaymentChannelModel>>> getPaymentChannels() async {
    final response = await _apiClient.get(ApiEndpoints.paymentChannels);

    return BaseApiResponseModel<List<PaymentChannelModel>>.fromJson(
      response.data as Map<String, dynamic>?,
      (data) {
        if (data is List) {
          return data
              .map((e) => PaymentChannelModel.fromJson(e as Map<String, dynamic>?))
              .toList();
        }
        return <PaymentChannelModel>[];
      },
    );
  }

  /// Submits sensitive financial transaction.
  /// Automatically carries Idempotency-Key, HMAC signature, and encrypted payload.
  Future<BaseApiResponseModel<PaymentResultModel>> processPayment({
    required String checkoutToken,
    required String paymentChannelCode,
    String? pinVerificationToken,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.processPayment,
      data: {
        'checkout_token': checkoutToken,
        'payment_channel': paymentChannelCode,
        'pin_token': ?pinVerificationToken,
      },
      options: Options(
        extra: {'encrypt': true},
      ),
    );

    return BaseApiResponseModel<PaymentResultModel>.fromJson(
      response.data as Map<String, dynamic>?,
      (data) => PaymentResultModel.fromJson(data as Map<String, dynamic>?),
    );
  }
}
