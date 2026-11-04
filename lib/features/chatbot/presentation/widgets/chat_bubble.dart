import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/theme/app_theme.dart';
import 'package:rahhala_app/core/widgets/anis_avatar.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final DateTime? timestamp;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final botBubbleColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    final botTextColor =
        isDark ? Colors.white.withValues(alpha: 0.9) : ThemeColor.charcoalColor;
    const userBubbleColor = ThemeColor.primaryColor;
    final userIconBgColor =
        ThemeColor.primaryColor.withValues(alpha: isDark ? 0.2 : 0.1);

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            const AnisAvatar(size: 50),
            SizedBox(width: 10.w),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: 0.7.sw),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: isUser ? userBubbleColor : botBubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isUser
                      ? Text(
                          message,
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        )
                      : _BotMessageText(
                          message: message,
                          color: botTextColor,
                          accentColor: ThemeColor.primaryColor,
                        ),
                ),
                if (timestamp != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    DateFormat('h:mm a').format(timestamp!),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color:
                          isDark ? Colors.white38 : ThemeColor.neutralGrayColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isUser) ...[
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: userIconBgColor,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Icon(
                Icons.person_outline,
                size: 20.sp,
                color: ThemeColor.primaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BotMessageText extends StatelessWidget {
  const _BotMessageText({
    required this.message,
    required this.color,
    required this.accentColor,
  });

  final String message;
  final Color color;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final blocks = _MessageBlock.parse(message);
    final baseStyle = TextStyle(
      fontSize: 14.5.sp,
      color: color,
      height: 1.48,
      fontWeight: FontWeight.w400,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < blocks.length; index++)
          _MessageBlockWidget(
            block: blocks[index],
            baseStyle: baseStyle,
            accentColor: accentColor,
            isFirst: index == 0,
          ),
      ],
    );
  }
}

class _MessageBlockWidget extends StatelessWidget {
  const _MessageBlockWidget({
    required this.block,
    required this.baseStyle,
    required this.accentColor,
    required this.isFirst,
  });

  final _MessageBlock block;
  final TextStyle baseStyle;
  final Color accentColor;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final topPadding =
        isFirst ? 0.0 : (block.type == _BlockType.bullet ? 7.h : 12.h);

    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: switch (block.type) {
        _BlockType.bullet => _buildBullet(context),
        _BlockType.numbered => _buildNumbered(context),
        _BlockType.heading => _buildRichText(
            baseStyle.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        _BlockType.paragraph => _buildRichText(baseStyle),
      },
    );
  }

  Widget _buildBullet(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6.r,
          height: 6.r,
          margin: EdgeInsets.only(top: 8.h),
          decoration: BoxDecoration(
            color: accentColor,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(child: _buildRichText(baseStyle)),
      ],
    );
  }

  Widget _buildNumbered(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${block.marker}.',
          style: baseStyle.copyWith(
            color: accentColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(child: _buildRichText(baseStyle)),
      ],
    );
  }

  Widget _buildRichText(TextStyle style) {
    return Text.rich(
      TextSpan(children: _inlineSpans(block.text, style)),
      textAlign: TextAlign.start,
      textScaler: TextScaler.noScaling,
    );
  }

  List<InlineSpan> _inlineSpans(String value, TextStyle style) {
    final spans = <InlineSpan>[];
    var cursor = 0;

    while (cursor < value.length) {
      final start = value.indexOf('**', cursor);
      if (start == -1) {
        _addSpan(spans, value.substring(cursor), style);
        break;
      }

      _addSpan(spans, value.substring(cursor, start), style);
      final end = value.indexOf('**', start + 2);
      if (end == -1) {
        _addSpan(spans, value.substring(start), style);
        break;
      }

      _addSpan(
        spans,
        value.substring(start + 2, end),
        style.copyWith(fontWeight: FontWeight.w700),
      );
      cursor = end + 2;
    }

    return spans;
  }

  void _addSpan(List<InlineSpan> spans, String value, TextStyle style) {
    final cleaned = value.replaceAll('__', '').replaceAll('**', '');
    if (cleaned.isEmpty) return;

    spans.add(TextSpan(text: cleaned, style: style));
  }
}

enum _BlockType { paragraph, bullet, numbered, heading }

class _MessageBlock {
  const _MessageBlock({
    required this.type,
    required this.text,
    this.marker,
  });

  final _BlockType type;
  final String text;
  final String? marker;

  static final _bulletPattern = RegExp(r'^[-*]\s+(.+)$');
  static final _numberedPattern = RegExp(r'^(\d+)[.)]\s+(.+)$');
  static final _headingPattern = RegExp(r'^(#{1,3})\s+(.+)$');

  static List<_MessageBlock> parse(String rawMessage) {
    final lines =
        rawMessage.replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n');
    final blocks = <_MessageBlock>[];
    final paragraph = StringBuffer();

    void flushParagraph() {
      final text = paragraph.toString().trim();
      if (text.isNotEmpty) {
        blocks.add(_MessageBlock(type: _BlockType.paragraph, text: text));
        paragraph.clear();
      }
    }

    void appendParagraph(String value) {
      if (paragraph.isNotEmpty) paragraph.write(' ');
      paragraph.write(value.trim());
    }

    for (final line in lines) {
      final trimmed = line.trim();

      if (trimmed.isEmpty) {
        flushParagraph();
        continue;
      }

      final bulletMatch = _bulletPattern.firstMatch(trimmed);
      if (bulletMatch != null) {
        flushParagraph();
        blocks.add(
          _MessageBlock(
            type: _BlockType.bullet,
            text: bulletMatch.group(1)!.trim(),
          ),
        );
        continue;
      }

      final numberedMatch = _numberedPattern.firstMatch(trimmed);
      if (numberedMatch != null) {
        flushParagraph();
        blocks.add(
          _MessageBlock(
            type: _BlockType.numbered,
            marker: numberedMatch.group(1),
            text: numberedMatch.group(2)!.trim(),
          ),
        );
        continue;
      }

      final headingMatch = _headingPattern.firstMatch(trimmed);
      if (headingMatch != null) {
        flushParagraph();
        blocks.add(
          _MessageBlock(
            type: _BlockType.heading,
            text: headingMatch.group(2)!.trim(),
          ),
        );
        continue;
      }

      appendParagraph(trimmed);
    }

    flushParagraph();
    return blocks;
  }
}
