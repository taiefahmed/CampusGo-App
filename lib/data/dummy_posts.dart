import 'package:flutter/material.dart';
import '../theme/app_theme.dart'; // path na mille bolo, thik kore dibo

class FeedPost {
  final String id;
  final String name;
  final String subtitle;
  final String time;
  final String caption;
  final Color? bannerColor;
  final String? bannerTitle;
  final String? bannerSubtitle;
  final int likes;
  final int comments;

  FeedPost({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.time,
    required this.caption,
    this.bannerColor,
    this.bannerTitle,
    this.bannerSubtitle,
    required this.likes,
    required this.comments,
  });
}

// TODO: eita Firestore stream diye replace korte hobe pore
final List<FeedPost> dummyPosts = [
  FeedPost(
    id: 'post1',
    name: 'CampusGo',
    subtitle: '@campusgo',
    time: '2h ago',
    caption: 'BUBT ADMISSION OPEN — Fall 2026. Apply now!',
    bannerColor: AppTheme.primary,
    bannerTitle: 'ADMISSION\nOPEN',
    bannerSubtitle: 'Fall 2026',
    likes: 10,
    comments: 3,
  ),
  FeedPost(
    id: 'post2',
    name: 'Farita Smith',
    subtitle: '@farita9',
    time: '5h ago',
    caption: 'Looking for a Math tutor near Mirpur, anyone available?',
    bannerColor: null,
    likes: 4,
    comments: 1,
  ),
];