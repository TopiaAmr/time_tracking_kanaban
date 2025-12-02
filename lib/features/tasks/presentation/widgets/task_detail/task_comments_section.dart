import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:time_tracking_kanaban/core/l10n/l10n.dart';
import 'package:time_tracking_kanaban/features/tasks/presentation/cubit/comments_cubit.dart';
import 'package:time_tracking_kanaban/features/tasks/presentation/cubit/comments_state.dart';

class TaskCommentsSection extends StatelessWidget {
  final String taskId;
  final TextEditingController commentController;

  const TaskCommentsSection({
    super.key,
    required this.taskId,
    required this.commentController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.comment_outlined,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.taskComments,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Comments list
            BlocBuilder<CommentsCubit, CommentsState>(
              builder: (context, state) {
                if (state is CommentsLoading) {
                  return const SizedBox.shrink(); // Comments will appear when loaded
                }

                if (state is CommentsError) {
                  return Text(
                    context.l10n.errorUnknown,
                    style: TextStyle(color: theme.colorScheme.error),
                  );
                }

                if (state is CommentsLoaded) {
                  return Column(
                    children: [
                      // Comments list
                      if (state.comments.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'No comments yet',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        )
                      else
                        ...state.comments.map((comment) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(
                                comment.authorName ?? 'Unknown',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(comment.content),
                                  const SizedBox(height: 8),
                                  Text(
                                    DateFormat(
                                      'MMM d, yyyy HH:mm',
                                    ).format(comment.createdAt),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

                      // Add comment section
                      const SizedBox(height: 16),
                      TextField(
                        controller: commentController,
                        decoration: InputDecoration(
                          hintText: context.l10n.commentAdd,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () {
                              if (commentController.text.trim().isNotEmpty) {
                                context.read<CommentsCubit>().addComment(
                                      taskId,
                                      commentController.text.trim(),
                                    );
                                commentController.clear();
                              }
                            },
                          ),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
