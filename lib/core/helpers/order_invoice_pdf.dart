import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../features/orders/data/model/order_model.dart';

class OrderInvoicePdf {
  OrderInvoicePdf._();

  static Future<void> printInvoice(OrderModel order) async {
    final doc = await _build(order);
    await Printing.layoutPdf(onLayout: (_) => doc.save());
  }

  static Future<pw.Document> _build(OrderModel order) async {
    final doc = pw.Document();
    final font      = await PdfGoogleFonts.nunitoRegular();
    final fontBold  = await PdfGoogleFonts.nunitoBold();
    final green     = PdfColor.fromHex('1B5E20');
    final gold      = PdfColor.fromHex('C8A96E');
    final lightGrey = PdfColor.fromHex('F5F5F5');
    final textGrey  = PdfColor.fromHex('757575');
    final shortId   = '#${order.orderNumber}';
    final dateFmt   = DateFormat('dd MMM yyyy, hh:mm a');

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(24),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('SABEH', style: pw.TextStyle(font: fontBold, fontSize: 22, color: green)),
                    pw.Text('Fresh · Quality · Delivered', style: pw.TextStyle(font: font, fontSize: 9, color: textGrey)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('INVOICE', style: pw.TextStyle(font: fontBold, fontSize: 14, color: green)),
                    pw.Text(shortId, style: pw.TextStyle(font: fontBold, fontSize: 11)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Divider(color: gold, thickness: 1.5),
            pw.SizedBox(height: 8),

            // ── Order meta ───────────────────────────────────────────────────
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _metaCell(font, fontBold, 'Date', dateFmt.format(order.createdAt.toLocal())),
                _metaCell(font, fontBold, 'Status', order.status.label),
                _metaCell(font, fontBold, 'Payment', order.paymentLabel),
              ],
            ),
            if (order.deliveryAddress?.isNotEmpty == true) ...[
              pw.SizedBox(height: 6),
              pw.Text('Address: ${order.deliveryAddress}',
                  style: pw.TextStyle(font: font, fontSize: 9, color: textGrey)),
            ],
            if (order.driverName?.isNotEmpty == true) ...[
              pw.SizedBox(height: 2),
              pw.Text('Driver: ${order.driverName}',
                  style: pw.TextStyle(font: font, fontSize: 9, color: textGrey)),
            ],
            if (order.notes?.isNotEmpty == true) ...[
              pw.SizedBox(height: 2),
              pw.Text('Notes: ${order.notes}',
                  style: pw.TextStyle(font: font, fontSize: 9, color: textGrey)),
            ],
            pw.SizedBox(height: 10),

            // ── Items table ──────────────────────────────────────────────────
            pw.Table(
              border: pw.TableBorder(
                top:    pw.BorderSide(color: green, width: 0.5),
                bottom: pw.BorderSide(color: green, width: 0.5),
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(4),
                1: const pw.FixedColumnWidth(40),
                2: const pw.FixedColumnWidth(55),
                3: const pw.FixedColumnWidth(60),
              },
              children: [
                // Header row
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: green),
                  children: [
                    _th('Item', fontBold),
                    _th('Qty', fontBold, align: pw.TextAlign.center),
                    _th('Unit Price', fontBold, align: pw.TextAlign.right),
                    _th('Subtotal', fontBold, align: pw.TextAlign.right),
                  ],
                ),
                // Item rows
                ...order.items.asMap().entries.map((e) {
                  final item = e.value;
                  final even = e.key.isEven;
                  return pw.TableRow(
                    decoration: even ? pw.BoxDecoration(color: lightGrey) : null,
                    children: [
                      _td(item.productName, font),
                      _td('${item.quantity}', font, align: pw.TextAlign.center),
                      _td('EGP ${item.unitPrice.toStringAsFixed(2)}', font, align: pw.TextAlign.right),
                      _td(
                        item.unitPrice == 0 ? 'FREE' : 'EGP ${item.subtotal.toStringAsFixed(2)}',
                        fontBold,
                        align: pw.TextAlign.right,
                        color: item.unitPrice == 0 ? PdfColor.fromHex('2E7D32') : null,
                      ),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 10),

            // ── Summary ───────────────────────────────────────────────────────
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Container(
                width: 180,
                child: pw.Column(
                  children: [
                    if (order.userPaidDeliveryFees > 0)
                      _summaryRow(font, 'Delivery Fee', 'EGP ${order.userPaidDeliveryFees.toStringAsFixed(2)}'),
                    if (order.serviceFee > 0)
                      _summaryRow(font, 'Service Fee', 'EGP ${order.serviceFee.toStringAsFixed(2)}'),
                    if (order.loyaltyDiscount > 0)
                      _summaryRow(font, 'Points Discount', '- EGP ${order.loyaltyDiscount.toStringAsFixed(2)}',
                          color: PdfColor.fromHex('E6A817')),
                    if (order.promoDiscount > 0)
                      _summaryRow(font, 'Promo Discount', '- EGP ${order.promoDiscount.toStringAsFixed(2)}',
                          color: PdfColor.fromHex('1565C0')),
                    pw.Divider(thickness: 0.5),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('TOTAL', style: pw.TextStyle(font: fontBold, fontSize: 12)),
                        pw.Text('EGP ${order.totalPrice.toStringAsFixed(2)}',
                            style: pw.TextStyle(font: fontBold, fontSize: 14, color: green)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            pw.Spacer(),
            pw.Divider(color: gold, thickness: 0.5),
            pw.Center(
              child: pw.Text('Thank you for your order!',
                  style: pw.TextStyle(font: font, fontSize: 9, color: textGrey)),
            ),
          ],
        ),
      ),
    );
    return doc;
  }

  static pw.Widget _metaCell(pw.Font font, pw.Font bold, String label, String value) =>
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: pw.TextStyle(font: font, fontSize: 8, color: PdfColor.fromHex('9E9E9E'))),
          pw.Text(value, style: pw.TextStyle(font: bold, fontSize: 10)),
        ],
      );

  static pw.Widget _th(String text, pw.Font font, {pw.TextAlign align = pw.TextAlign.left}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: pw.Text(text,
            style: pw.TextStyle(font: font, fontSize: 9, color: PdfColors.white),
            textAlign: align),
      );

  static pw.Widget _td(String text, pw.Font font,
          {pw.TextAlign align = pw.TextAlign.left, PdfColor? color}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: pw.Text(text,
            style: pw.TextStyle(font: font, fontSize: 9, color: color),
            textAlign: align),
      );

  static pw.Widget _summaryRow(pw.Font font, String label, String value, {PdfColor? color}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label, style: pw.TextStyle(font: font, fontSize: 9)),
            pw.Text(value, style: pw.TextStyle(font: font, fontSize: 9, color: color)),
          ],
        ),
      );
}
