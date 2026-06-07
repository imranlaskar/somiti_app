import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/sheets_service.dart';

class DriveImage extends StatefulWidget {
  final String fileId;
  final double size;
  final String fallbackText;
  final Widget? fallbackWidget;   // ✅ custom fallback

  const DriveImage({
    super.key,
    required this.fileId,
    required this.size,
    required this.fallbackText,
    this.fallbackWidget,          // optional
  });

  @override
  State<DriveImage> createState() => _DriveImageState();
}

class _DriveImageState extends State<DriveImage> {
  String? _base64Image;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    if (widget.fileId.isEmpty) {
      setState(() { _loading = false; _error = true; });
      return;
    }
    final result =
    await SheetsService.getDriveImageBase64(widget.fileId);
    if (mounted) {
      setState(() {
        _base64Image = result;
        _loading = false;
        _error = result == null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.size / 2;

    // লোড হচ্ছে
    if (_loading) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: const Center(
          child: CircularProgressIndicator(
              color: Color(0xFF3F51B5), strokeWidth: 2),
        ),
      );
    }

    // Error হলে — custom fallback অথবা নামের অক্ষর
    if (_error || _base64Image == null) {
      if (widget.fallbackWidget != null) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Center(child: widget.fallbackWidget!),
        );
      }
      return Text(
        widget.fallbackText.isNotEmpty ? widget.fallbackText[0] : '?',
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.7,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    // ✅ base64 থেকে ছবি দেখাও
    final bytes = base64Decode(_base64Image!.split(',').last);
    return Image.memory(
      bytes,
      width: widget.size,
      height: widget.size,
      fit: BoxFit.cover,
    );
  }
}