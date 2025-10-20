// Test data script for DramaBook app
// This file contains sample data that can be used to populate the Firestore database

import 'package:cloud_firestore/cloud_firestore.dart';

class TestData {
  static final List<Map<String, dynamic>> sampleDramas = [
    {
      'title': 'Romeo and Juliet',
      'genre': 'Tragedy',
      'description': 'A timeless tale of forbidden love between two young people from feuding families.',
      'poster': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=600&fit=crop',
      'showTimes': ['7:00 PM', '9:00 PM'],
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'title': 'Hamlet',
      'genre': 'Tragedy',
      'description': 'The story of a young prince who seeks revenge for his father\'s murder.',
      'poster': 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=400&h=600&fit=crop',
      'showTimes': ['6:30 PM', '8:30 PM'],
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'title': 'A Midsummer Night\'s Dream',
      'genre': 'Comedy',
      'description': 'A magical comedy about love, mistaken identity, and fairy mischief.',
      'poster': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=600&fit=crop',
      'showTimes': ['7:30 PM', '9:30 PM'],
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'title': 'Macbeth',
      'genre': 'Tragedy',
      'description': 'A dark tale of ambition, power, and the consequences of unchecked desire.',
      'poster': 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=400&h=600&fit=crop',
      'showTimes': ['8:00 PM'],
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'title': 'The Tempest',
      'genre': 'Romance',
      'description': 'A magical island tale of forgiveness, love, and the power of art.',
      'poster': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=600&fit=crop',
      'showTimes': ['6:00 PM', '8:00 PM', '10:00 PM'],
      'createdAt': FieldValue.serverTimestamp(),
    },
  ];

  // Function to populate database with test data
  static Future<void> populateTestData() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    
    try {
      for (var drama in sampleDramas) {
        await firestore.collection('dramas').add(drama);
        print('Added drama: ${drama['title']}');
      }
      print('Test data populated successfully!');
    } catch (e) {
      print('Error populating test data: $e');
    }
  }

  // Function to create admin user
  static Future<void> createAdminUser(String email, String password) async {
    // This would typically be done through Firebase Auth and Firestore
    // For now, this is just a placeholder
    print('To create an admin user:');
    print('1. Sign up with the email: $email');
    print('2. Go to Firebase Console > Firestore Database');
    print('3. Navigate to users collection');
    print('4. Find the user document and change role to "admin"');
  }
}

// Usage instructions:
// 1. Import this file in your main.dart or create a separate admin function
// 2. Call TestData.populateTestData() to add sample dramas
// 3. Use TestData.createAdminUser() to get instructions for creating admin users
