import 'dart:io';
import 'dart:typed_data';

import 'package:aub_connect_app/data/models/ai_cv_draft.dart';
import 'package:aub_connect_app/data/models/cv_template.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart' show Color;

/// Builds a layout-matched PDF from [AiCvDraft] + [CvTemplate] and shares it.
abstract final class CvPdfBuilder {
  static PdfColor _pdfColor(Color c) => PdfColor(c.r, c.g, c.b);

  static Future<Uint8List> buildBytes({
    required AiCvDraft draft,
    required CvTemplate template,
  }) async {
    final doc = pw.Document();
    final accent = _pdfColor(template.accentColor);
    final labels = template.labels;

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (context) {
          switch (template.layout) {
            case CvTemplateLayout.sidebarLight:
              return _sidebar(
                draft: draft,
                labels: labels,
                accent: accent,
                dark: false,
              );
            case CvTemplateLayout.sidebarDark:
              return _sidebar(
                draft: draft,
                labels: labels,
                accent: accent,
                dark: true,
              );
            case CvTemplateLayout.headerPhoto:
              return _headerPhoto(
                draft: draft,
                labels: labels,
                accent: accent,
              );
            case CvTemplateLayout.headerStrip:
              return _headerStrip(
                draft: draft,
                labels: labels,
                accent: accent,
              );
            case CvTemplateLayout.minimal:
            case CvTemplateLayout.blank:
              return _minimal(
                draft: draft,
                labels: labels,
                accent: accent,
              );
          }
        },
      ),
    );
    return doc.save();
  }

  static Future<File> writeTempFile({
    required AiCvDraft draft,
    required CvTemplate template,
  }) async {
    final bytes = await buildBytes(draft: draft, template: template);
    final dir = await getTemporaryDirectory();
    final safeName = (draft.fullName.isEmpty ? 'Vithey_CV' : draft.fullName)
        .replaceAll(RegExp(r'[^\w\-]+'), '_');
    final file = File(
      '${dir.path}/${safeName}_${template.id}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static Future<void> sharePdf({
    required AiCvDraft draft,
    required CvTemplate template,
  }) async {
    final file = await writeTempFile(draft: draft, template: template);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      subject: '${draft.fullName.isEmpty ? 'CV' : draft.fullName} — Vithey CV',
    );
  }

  static pw.Widget _sectionTitle(String text, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 12, bottom: 4),
      child: pw.Text(
        text.toUpperCase(),
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  static pw.Widget _body(String text, {PdfColor? color}) {
    if (text.trim().isEmpty) return pw.SizedBox();
    return pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 10,
        height: 1.35,
        color: color ?? PdfColors.grey800,
      ),
    );
  }

  static pw.Widget _sidebar({
    required AiCvDraft draft,
    required CvTemplateLabels labels,
    required PdfColor accent,
    required bool dark,
  }) {
    final sideBg = dark
        ? accent
        : PdfColor(accent.red, accent.green, accent.blue, 0.18);
    final sideFg = dark ? PdfColors.white : PdfColors.grey900;
    final sideMuted = dark ? PdfColors.grey300 : PdfColors.grey700;

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Container(
          width: 190,
          color: sideBg,
          padding: const pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 64,
                height: 64,
                decoration: pw.BoxDecoration(
                  color: dark ? PdfColors.white : accent,
                  shape: pw.BoxShape.circle,
                ),
                alignment: pw.Alignment.center,
                child: pw.Text(
                  _initials(draft.fullName),
                  style: pw.TextStyle(
                    color: dark ? accent : PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              pw.SizedBox(height: 14),
              pw.Text(
                draft.fullName.isEmpty ? 'Your Name' : draft.fullName,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: sideFg,
                ),
              ),
              _sectionTitle(labels.contact, sideFg),
              _body(draft.contact, color: sideMuted),
              _sectionTitle(labels.skills, sideFg),
              _body(draft.skills.join(' · '), color: sideMuted),
            ],
          ),
        ),
        pw.Expanded(
          child: pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _sectionTitle(labels.aboutMe, accent),
                _body(draft.summary),
                _sectionTitle(labels.experience, accent),
                _body(draft.experience.join('\n')),
                _sectionTitle(labels.education, accent),
                _body(draft.education.join('\n')),
                if (draft.projects.isNotEmpty) ...[
                  _sectionTitle(labels.projects, accent),
                  _body(draft.projects.join('\n')),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _headerPhoto({
    required AiCvDraft draft,
    required CvTemplateLabels labels,
    required PdfColor accent,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Container(
          height: 90,
          color: accent,
          alignment: pw.Alignment.bottomCenter,
          padding: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Container(
            width: 70,
            height: 70,
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              shape: pw.BoxShape.circle,
              border: pw.Border.all(color: PdfColors.white, width: 3),
            ),
            alignment: pw.Alignment.center,
            child: pw.Text(
              _initials(draft.fullName),
              style: pw.TextStyle(
                color: accent,
                fontWeight: pw.FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(28, 12, 28, 28),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                draft.fullName.isEmpty ? 'Your Name' : draft.fullName,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              _body(draft.contact, color: PdfColors.grey600),
              pw.SizedBox(height: 12),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(labels.aboutMe, accent),
                    _body(draft.summary),
                    _sectionTitle(labels.experience, accent),
                    _body(draft.experience.join('\n')),
                    _sectionTitle(labels.education, accent),
                    _body(draft.education.join('\n')),
                    _sectionTitle(labels.skills, accent),
                    _body(draft.skills.join(' · ')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _headerStrip({
    required AiCvDraft draft,
    required CvTemplateLabels labels,
    required PdfColor accent,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Container(
          color: accent,
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                draft.fullName.isEmpty ? 'Your Name' : draft.fullName,
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.SizedBox(height: 6),
              _body(draft.contact, color: PdfColors.grey300),
            ],
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(28),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _sectionTitle(labels.aboutMe, accent),
              _body(draft.summary),
              _sectionTitle(labels.experience, accent),
              _body(draft.experience.join('\n')),
              _sectionTitle(labels.education, accent),
              _body(draft.education.join('\n')),
              _sectionTitle(labels.skills, accent),
              _body(draft.skills.join(' · ')),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _minimal({
    required AiCvDraft draft,
    required CvTemplateLabels labels,
    required PdfColor accent,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(36),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            draft.fullName.isEmpty ? 'Your Name' : draft.fullName,
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              color: accent,
            ),
          ),
          pw.SizedBox(height: 4),
          _body(draft.contact, color: PdfColors.grey600),
          pw.Divider(color: accent, thickness: 0.8),
          _sectionTitle(labels.aboutMe, accent),
          _body(draft.summary),
          _sectionTitle(labels.experience, accent),
          _body(draft.experience.join('\n')),
          _sectionTitle(labels.education, accent),
          _body(draft.education.join('\n')),
          _sectionTitle(labels.skills, accent),
          _body(draft.skills.join(' · ')),
          if (draft.projects.isNotEmpty) ...[
            _sectionTitle(labels.projects, accent),
            _body(draft.projects.join('\n')),
          ],
        ],
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
