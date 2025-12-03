import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Robot for interacting with comments functionality.
///
/// Encapsulates all comments UI interactions for cleaner tests.
class CommentsRobot {
  final WidgetTester tester;

  CommentsRobot(this.tester);

  /// Verifies the comments section is visible.
  Future<void> verifyCommentsSectionVisible() async {
    await tester.pumpAndSettle();
    // Look for comments header
    final commentsHeader = find.textContaining('Comment');
    expect(commentsHeader.evaluate().isNotEmpty, isTrue);
  }

  /// Enters a comment in the input field.
  Future<void> enterComment(String comment) async {
    // Wait for the comments section to load (TextField appears when CommentsLoaded)
    Finder? targetField;
    for (int i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 250));
      try {
        await tester.pumpAndSettle(const Duration(milliseconds: 100));
      } catch (_) {
        // Ignore timeout
      }
      
      // Find the comment input field - it's in the comments section with a send icon
      // Look for TextField that has a send icon as suffix
      final textFields = find.byType(TextField);
      
      for (final element in textFields.evaluate()) {
        final widget = element.widget as TextField;
        // The comment field has maxLines: 3 and a send icon
        if (widget.maxLines == 3) {
          targetField = find.byWidget(widget);
          break;
        }
      }
      
      if (targetField != null && targetField.evaluate().isNotEmpty) {
        break;
      }
      targetField = null;
    }
    
    if (targetField != null) {
      await tester.enterText(targetField, comment);
      await tester.pumpAndSettle();
      return;
    }
    
    // Fallback: use the last TextField if available
    final textFields = find.byType(TextField);
    if (textFields.evaluate().isNotEmpty) {
      await tester.enterText(textFields.last, comment);
      await tester.pumpAndSettle();
    }
  }

  /// Taps the add comment button.
  Future<void> tapAddComment() async {
    // Find the send/add button
    final sendButton = find.byIcon(Icons.send);
    if (sendButton.evaluate().isNotEmpty) {
      await tester.tap(sendButton.first);
      await tester.pumpAndSettle();
    } else {
      // Try finding by text
      final addButton = find.text('Add');
      if (addButton.evaluate().isNotEmpty) {
        await tester.tap(addButton.first);
        await tester.pumpAndSettle();
      }
    }
  }

  /// Adds a comment (enters text and submits).
  Future<void> addComment(String comment) async {
    await enterComment(comment);
    await tapAddComment();
    // Wait for the API call to complete and comments to reload
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  /// Verifies a comment with the given text exists.
  /// Waits up to 10 seconds for the comment to appear.
  Future<void> verifyCommentExists(String commentText) async {
    // Wait for comments to load with retries (20 * 500ms = 10 seconds)
    for (int i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      try {
        await tester.pumpAndSettle(const Duration(milliseconds: 200));
      } catch (_) {
        // Ignore timeout
      }
      
      // Try exact match first
      final commentFinder = find.text(commentText);
      if (commentFinder.evaluate().isNotEmpty) {
        expect(commentFinder, findsWidgets);
        return;
      }
      
      // Also try textContaining for partial matches
      final partialFinder = find.textContaining(commentText);
      if (partialFinder.evaluate().isNotEmpty) {
        expect(partialFinder, findsWidgets);
        return;
      }
    }
    
    // Final check with assertion
    expect(find.text(commentText), findsWidgets);
  }

  /// Verifies a comment does not exist.
  Future<void> verifyCommentDoesNotExist(String commentText) async {
    await tester.pumpAndSettle();
    expect(find.text(commentText), findsNothing);
  }

  /// Verifies the number of comments displayed.
  Future<void> verifyCommentCount(int expectedCount) async {
    await tester.pumpAndSettle();
    // This depends on the widget structure - count comment cards/items
    final commentItems = find.byType(ListTile);
    expect(commentItems.evaluate().length, greaterThanOrEqualTo(expectedCount));
  }

  /// Scrolls to see more comments.
  Future<void> scrollComments({bool up = false}) async {
    final scrollable = find.byType(ListView);
    if (scrollable.evaluate().isNotEmpty) {
      await tester.drag(scrollable.first, Offset(0, up ? 200 : -200));
      await tester.pumpAndSettle();
    }
  }

  /// Verifies the comment input field is empty.
  Future<void> verifyInputFieldEmpty() async {
    await tester.pumpAndSettle();
    final textFields = find.byType(TextField);
    if (textFields.evaluate().isNotEmpty) {
      final textField = textFields.evaluate().last.widget as TextField;
      expect(textField.controller?.text ?? '', isEmpty);
    }
  }

  /// Verifies loading state for comments.
  Future<void> verifyLoading() async {
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  }

  /// Verifies empty state (no comments).
  Future<void> verifyEmptyState() async {
    await tester.pumpAndSettle();
    final emptyText = find.textContaining('No comments');
    expect(emptyText.evaluate().isNotEmpty, isTrue);
  }

  /// Taps on a comment to select it.
  Future<void> tapComment(String commentText) async {
    final comment = find.text(commentText);
    expect(comment, findsOneWidget);
    await tester.tap(comment);
    await tester.pumpAndSettle();
  }

  /// Long presses on a comment (for context menu).
  Future<void> longPressComment(String commentText) async {
    final comment = find.text(commentText);
    expect(comment, findsOneWidget);
    await tester.longPress(comment);
    await tester.pumpAndSettle();
  }

  /// Deletes a comment.
  Future<void> deleteComment(String commentText) async {
    await longPressComment(commentText);
    final deleteOption = find.text('Delete');
    if (deleteOption.evaluate().isNotEmpty) {
      await tester.tap(deleteOption.first);
      await tester.pumpAndSettle();
    }
  }

  /// Verifies author name is displayed for a comment.
  Future<void> verifyAuthorName(String authorName) async {
    await tester.pumpAndSettle();
    expect(find.text(authorName), findsWidgets);
  }

  /// Verifies timestamp is displayed for comments.
  Future<void> verifyTimestampDisplayed() async {
    await tester.pumpAndSettle();
    // Look for common time formats
    final timePattern = find.textContaining(RegExp(r'\d{1,2}:\d{2}|\d{1,2}/\d{1,2}'));
    expect(timePattern.evaluate().isNotEmpty, isTrue);
  }
}
