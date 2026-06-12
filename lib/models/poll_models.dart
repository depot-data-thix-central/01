// lib/models/poll_models.dart
class Poll {
  final String id;
  final String conversationId;
  final String question;
  final List<String> options;
  final Map<int, int> votesCount;
  final int totalVotes;
  final bool isAnonymous;
  final bool isMultiple;
  final bool hasVoted;
  final int? userVote;
  final List<int>? userVotes;
  final bool isExpired;
  final DateTime? expiresAt;
  final DateTime createdAt;

  Poll({
    required this.id,
    required this.conversationId,
    required this.question,
    required this.options,
    required this.votesCount,
    required this.totalVotes,
    required this.isAnonymous,
    required this.isMultiple,
    required this.hasVoted,
    this.userVote,
    this.userVotes,
    required this.isExpired,
    this.expiresAt,
    required this.createdAt,
  });

  factory Poll.fromJson(Map<String, dynamic> json, int? userVote) {
    final options = List<String>.from(json['options']);
    final votes = json['votes_count'] as Map<String, dynamic>? ?? {};
    final votesCount = <int, int>{};
    for (var i = 0; i < options.length; i++) {
      votesCount[i] = votes[i.toString()] as int? ?? 0;
    }
    final totalVotes = votesCount.values.fold(0, (sum, v) => sum + v);
    final expiresAt = json['expires_at'] != null
        ? DateTime.parse(json['expires_at'])
        : null;
    final isExpired = expiresAt != null && expiresAt.isBefore(DateTime.now());

    return Poll(
      id: json['id'],
      conversationId: json['conversation_id'],
      question: json['question'],
      options: options,
      votesCount: votesCount,
      totalVotes: totalVotes,
      isAnonymous: json['is_anonymous'] ?? false,
      isMultiple: json['is_multiple'] ?? false,
      hasVoted: userVote != null,
      userVote: userVote,
      userVotes: userVote != null ? [userVote] : null,
      isExpired: isExpired,
      expiresAt: expiresAt,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  int getVotesCount(int index) => votesCount[index] ?? 0;
  
  double getPercentage(int index) {
    if (totalVotes == 0) return 0;
    return (getVotesCount(index) / totalVotes) * 100;
  }
}
