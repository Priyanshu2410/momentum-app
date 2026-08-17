import '../../domain/entities/app_notification.dart';

/// Everything a rich notification says. Pure Dart — the workmanager isolate
/// and the tests both build these without Flutter.
///
/// [bigText] and [title] are rendered as HTML by the Android big-text style,
/// so anything interpolated into them goes through [escape] first.
class NotificationCopy {
  const NotificationCopy({
    required this.title,
    required this.body,
    required this.bigText,
    required this.summary,
    required this.ticker,
  });

  /// Collapsed headline.
  final String title;

  /// Collapsed single line — what shows before the shade is expanded.
  final String body;

  /// Expanded body, HTML. Carries the quote.
  final String bigText;

  /// Small grey line beside the app name.
  final String summary;

  /// Read out by accessibility services as the notification lands.
  final String ticker;

  static NotificationCopy forKind(
    NotificationKind kind,
    String taskTitle,
    int taskId,
  ) {
    final t = escape(taskTitle);
    final quote = quoteFor(taskId, kind);

    return switch (kind) {
      NotificationKind.started => NotificationCopy(
          title: '⚡ Go time — $taskTitle',
          body: 'Started just now. Give it your next focused stretch.',
          bigText: '<b>“$t”</b> just started.<br>'
              'Give it one focused stretch — that is all it takes to keep the '
              'streak alive.<br><br><i>$quote</i>',
          summary: 'In progress',
          ticker: '$taskTitle just started',
        ),
      NotificationKind.dueSoon => NotificationCopy(
          title: '⏳ 30 minutes left — $taskTitle',
          body: 'Due soon. Time to land it.',
          bigText: '<b>“$t”</b> is due in 30 minutes.<br>'
              'Close it out while it is still yours to win.<br><br>'
              '<i>$quote</i>',
          summary: 'Due soon',
          ticker: '$taskTitle is due in 30 minutes',
        ),
      NotificationKind.overdue => NotificationCopy(
          title: '🔥 Overdue — $taskTitle',
          body: 'It slipped past due. One small step gets it moving.',
          bigText: '<b>“$t”</b> is past its due time.<br>'
              'Do not restart tomorrow — restart now, with the smallest '
              'possible step.<br><br><i>$quote</i>',
          summary: 'Overdue',
          ticker: '$taskTitle is overdue',
        ),
    };
  }

  /// Deterministic pick, so re-scheduling the same reminder does not reshuffle
  /// the line and the tests can assert on it.
  static String quoteFor(int taskId, NotificationKind kind) =>
      quotes[(taskId * 3 + kind.index) % quotes.length];

  /// Escapes the five XML entities. Task titles are user input and the big-text
  /// style parses them as markup.
  static String escape(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');

  /// Short enough to survive the two-line collapse on most launchers.
  static const quotes = <String>[
    '“Motivation gets you going. Momentum keeps you there.”',
    '“You do not have to be great to start. You have to start to be great.”',
    '“A little progress each day adds up to big results.”',
    '“The secret of getting ahead is getting started.”',
    '“Done is better than perfect.”',
    '“Discipline is choosing what you want most over what you want now.”',
    '“Small steps, every day, beat big steps someday.”',
    '“The best time was yesterday. The second best is right now.”',
    '“Action is the antidote to hesitation.”',
    '“Momentum is built, never found.”',
    '“Focus on the next five minutes, not the whole mountain.”',
    '“You will never regret finishing this one.”',
  ];
}
