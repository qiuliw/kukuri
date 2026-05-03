import 'package:flutter/material.dart';

class HomeChatMock {
  const HomeChatMock({
    required this.name,
    required this.message,
    required this.time,
    required this.color,
  });

  final String name;
  final String message;
  final String time;
  final Color color;
}

const homeChatMocks = [
  HomeChatMock(
    name: '产品讨论组',
    message: '搜索框现在像内容段落一样滚走，松手会自动吸附。',
    time: '09:42',
    color: Color(0xFF16A085),
  ),
  HomeChatMock(
    name: '阿宁',
    message: '我看了下动效，顶栏里搜索图标出现得挺自然。',
    time: '09:18',
    color: Color(0xFF4A90E2),
  ),
  HomeChatMock(
    name: '设计评审',
    message: 'header 的 0.1 透明感可以保留，别太玻璃化。',
    time: '昨天',
    color: Color(0xFFE67E22),
  ),
  HomeChatMock(
    name: 'Flutter 小分队',
    message: 'SliverPersistentHeader + ScrollEndNotification 就够用了。',
    time: '周二',
    color: Color(0xFF9B59B6),
  ),
  HomeChatMock(
    name: '运营通知',
    message: '下午三点同步本周活跃会话数据。',
    time: '周一',
    color: Color(0xFFE74C3C),
  ),
  HomeChatMock(
    name: 'Lynn',
    message: '你这个聊天首页可以继续加未读徽标和侧滑操作。',
    time: '4/25',
    color: Color(0xFF2C3E50),
  ),
  HomeChatMock(
    name: '前端协作',
    message: '中间态吸附阈值现在是 52%，可以按手感调。',
    time: '4/23',
    color: Color(0xFF27AE60),
  ),
  HomeChatMock(
    name: '家庭群',
    message: '晚上记得带水果。',
    time: '4/20',
    color: Color(0xFFD35400),
  ),
  HomeChatMock(
    name: '系统消息',
    message: '你有 2 条新的好友申请。',
    time: '4/18',
    color: Color(0xFF7F8C8D),
  ),
  HomeChatMock(
    name: '项目日报',
    message: '今天完成了滚动吸附 demo 和列表样式。',
    time: '4/16',
    color: Color(0xFF1ABC9C),
  ),
  HomeChatMock(
    name: 'Mia',
    message: '这个版本已经能表达你的交互想法了。',
    time: '4/12',
    color: Color(0xFF3498DB),
  ),
  HomeChatMock(
    name: '读书会',
    message: '本周章节是第七章，周五晚上聊。',
    time: '4/08',
    color: Color(0xFF8E44AD),
  ),
];
