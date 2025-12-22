import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine_core/src/model/question_type.dart';

void main() {
  group('QuestionType', () {
    test('TextQuestion should serialize and deserialize correctly', () {
      final textQuestion = TextQuestion("What is 2 + 2?");
      final jsonMap = textQuestion.toJson();
      final jsonString = jsonEncode(jsonMap);
      final parsedJson = jsonDecode(jsonString);

      final reconstructed = QuestionType.fromJson(parsedJson);

      expect(reconstructed, isA<TextQuestion>());
      expect((reconstructed as TextQuestion).text, "What is 2 + 2?");
    });

    test('ImageQuestion should serialize and deserialize correctly', () {
      final imageQuestion = ImageQuestion("assets/images/question.png");
      final jsonMap = imageQuestion.toJson();
      final jsonString = jsonEncode(jsonMap);
      final parsedJson = jsonDecode(jsonString);

      final reconstructed = QuestionType.fromJson(parsedJson);

      expect(reconstructed, isA<ImageQuestion>());
      expect(
        (reconstructed as ImageQuestion).imagePath,
        "assets/images/question.png",
      );
    });

    test('Invalid QuestionType should throw ArgumentError', () {
      final invalidJson = jsonDecode('{"type": "unknown", "value": "random"}');

      expect(() => QuestionType.fromJson(invalidJson), throwsArgumentError);
    });

    test(
      'toJson should correctly output a JSON representation for TextQuestion',
      () {
        final textQuestion = TextQuestion("Example Question");
        final expectedJson = {'type': 'text', 'text': "Example Question"};

        expect(textQuestion.toJson(), expectedJson);
      },
    );

    test(
      'toJson should correctly output a JSON representation for ImageQuestion',
      () {
        final imageQuestion = ImageQuestion("assets/example.png");
        final expectedJson = {
          'type': 'image',
          'imagePath': "assets/example.png",
        };

        expect(imageQuestion.toJson(), expectedJson);
      },
    );

    test('asJson should return correct JSON string for TextQuestion', () {
      final textQuestion = TextQuestion("What is 2 + 2?");
      final expectedJson = '{"type":"text","text":"What is 2 + 2?"}';

      expect(textQuestion.asJson, expectedJson);
    });

    test('asJson should return correct JSON string for ImageQuestion', () {
      final imageQuestion = ImageQuestion("assets/images/sample.png");
      final expectedJson =
          '{"type":"image","imagePath":"assets/images/sample.png"}';

      expect(imageQuestion.asJson, expectedJson);
    });

    test('AudioQuestion should serialize and deserialize correctly', () {
      final audioQuestion = AudioQuestion("assets/audio/question.mp3");
      final jsonMap = audioQuestion.toJson();
      final jsonString = jsonEncode(jsonMap);
      final parsedJson = jsonDecode(jsonString);

      final reconstructed = QuestionType.fromJson(parsedJson);

      expect(reconstructed, isA<AudioQuestion>());
      expect(
        (reconstructed as AudioQuestion).audioPath,
        "assets/audio/question.mp3",
      );
    });

    test(
      'toJson should correctly output a JSON representation for AudioQuestion',
      () {
        final audioQuestion = AudioQuestion("assets/sounds/example.mp3");
        final expectedJson = {
          'type': 'audio',
          'audioPath': "assets/sounds/example.mp3",
        };

        expect(audioQuestion.toJson(), expectedJson);
      },
    );

    test('asJson should return correct JSON string for AudioQuestion', () {
      final audioQuestion = AudioQuestion("assets/audio/sample.mp3");
      final expectedJson =
          '{"type":"audio","audioPath":"assets/audio/sample.mp3"}';

      expect(audioQuestion.asJson, expectedJson);
    });

    test('VideoQuestion should serialize and deserialize correctly', () {
      final videoQuestion = VideoQuestion(
        "https://example.com/video.mp4",
        thumbnailPath: "assets/thumb.jpg",
      );
      final jsonMap = videoQuestion.toJson();
      final jsonString = jsonEncode(jsonMap);
      final parsedJson = jsonDecode(jsonString);

      final reconstructed = QuestionType.fromJson(parsedJson);

      expect(reconstructed, isA<VideoQuestion>());
      expect(
        (reconstructed as VideoQuestion).videoUrl,
        "https://example.com/video.mp4",
      );
      expect(reconstructed.thumbnailPath, "assets/thumb.jpg");
    });

    test(
      'VideoQuestion without thumbnail should serialize and deserialize correctly',
      () {
        final videoQuestion = VideoQuestion("https://example.com/video.mp4");
        final jsonMap = videoQuestion.toJson();
        final jsonString = jsonEncode(jsonMap);
        final parsedJson = jsonDecode(jsonString);

        final reconstructed = QuestionType.fromJson(parsedJson);

        expect(reconstructed, isA<VideoQuestion>());
        expect(
          (reconstructed as VideoQuestion).videoUrl,
          "https://example.com/video.mp4",
        );
        expect(reconstructed.thumbnailPath, isNull);
      },
    );

    test(
      'toJson should correctly output a JSON representation for VideoQuestion with thumbnail',
      () {
        final videoQuestion = VideoQuestion(
          "https://example.com/quiz.mp4",
          thumbnailPath: "assets/thumbnail.png",
        );
        final expectedJson = {
          'type': 'video',
          'videoUrl': "https://example.com/quiz.mp4",
          'thumbnailPath': "assets/thumbnail.png",
        };

        expect(videoQuestion.toJson(), expectedJson);
      },
    );

    test(
      'toJson should correctly output a JSON representation for VideoQuestion without thumbnail',
      () {
        final videoQuestion = VideoQuestion("https://example.com/quiz.mp4");
        final expectedJson = {
          'type': 'video',
          'videoUrl': "https://example.com/quiz.mp4",
        };

        expect(videoQuestion.toJson(), expectedJson);
      },
    );

    test(
      'asJson should return correct JSON string for VideoQuestion with thumbnail',
      () {
        final videoQuestion = VideoQuestion(
          "https://example.com/video.mp4",
          thumbnailPath: "thumb.jpg",
        );
        final expectedJson =
            '{"type":"video","videoUrl":"https://example.com/video.mp4","thumbnailPath":"thumb.jpg"}';

        expect(videoQuestion.asJson, expectedJson);
      },
    );

    test(
      'asJson should return correct JSON string for VideoQuestion without thumbnail',
      () {
        final videoQuestion = VideoQuestion("https://example.com/video.mp4");
        final expectedJson =
            '{"type":"video","videoUrl":"https://example.com/video.mp4"}';

        expect(videoQuestion.asJson, expectedJson);
      },
    );

    test('Factory constructor for audio should work correctly', () {
      final audioQuestion = QuestionType.audio("assets/audio/test.mp3");

      expect(audioQuestion, isA<AudioQuestion>());
      expect(
        (audioQuestion as AudioQuestion).audioPath,
        "assets/audio/test.mp3",
      );
    });

    test(
      'Factory constructor for video should work correctly with thumbnail',
      () {
        final videoQuestion = QuestionType.video(
          "https://example.com/video.mp4",
          thumbnailPath: "thumb.jpg",
        );

        expect(videoQuestion, isA<VideoQuestion>());
        expect(
          (videoQuestion as VideoQuestion).videoUrl,
          "https://example.com/video.mp4",
        );
        expect(videoQuestion.thumbnailPath, "thumb.jpg");
      },
    );

    test(
      'Factory constructor for video should work correctly without thumbnail',
      () {
        final videoQuestion = QuestionType.video(
          "https://example.com/video.mp4",
        );

        expect(videoQuestion, isA<VideoQuestion>());
        expect(
          (videoQuestion as VideoQuestion).videoUrl,
          "https://example.com/video.mp4",
        );
        expect(videoQuestion.thumbnailPath, isNull);
      },
    );
  });
}
