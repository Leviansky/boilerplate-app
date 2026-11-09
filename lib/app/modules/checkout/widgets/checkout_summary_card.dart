import 'package:flutter/material.dart';
import "package:testing_boilerplate/core/theme/app_colors.dart";
import "package:testing_boilerplate/core/theme/spacing.dart";
import "package:testing_boilerplate/core/theme/typography.dart";
import "package:testing_boilerplate/core/utils/currency_formatter.dart";
import "package:testing_boilerplate/app/modules/checkout/data/models/checkout_payload_model.dart";

class CheckoutSummaryCard extends StatelessWidget {
  final CheckoutInvoiceModel invoice;

  const CheckoutSummaryCard({
    super.key,
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.p16,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.circular12,
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rincian Pembayaran',
            style: AppTypography.headingSmall,
          ),
          AppGaps.vGap16,

          // Subtotal
          _buildRow('Subtotal Produk', CurrencyFormatter.formatRupiah(invoice.subtotalAmount)),
          AppGaps.vGap8,

          // Discount if any
          if (invoice.discountAmount > 0) ...[
            _buildRow(
              'Diskon Promo',
              '-${CurrencyFormatter.formatRupiah(invoice.discountAmount)}',
              isDiscount: true,
            ),
            AppGaps.vGap8,
          ],

          // Shipping
          _buildRow('Ongkos Kirim', CurrencyFormatter.formatRupiah(invoice.shippingFee)),
          AppGaps.vGap8,

          // Admin Fee
          _buildRow('Biaya Layanan & Admin', CurrencyFormatter.formatRupiah(invoice.adminFee)),
          AppGaps.vGap12,
          const Divider(),
          AppGaps.vGap12,

          // Total Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Tagihan',
                style: AppTypography.headingMedium,
              ),
              Text(
                CurrencyFormatter.formatRupiah(invoice.totalAmount),
                style: AppTypography.headingMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            color: isDiscount ? AppColors.success : AppColors.textPrimary,
            fontWeight: isDiscount ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
