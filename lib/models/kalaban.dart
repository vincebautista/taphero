import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:learnflame/main.dart';
import 'package:learnflame/models/kalabanList.dart';

class Kalaban extends SpriteComponent with TapCallbacks, HasGameRef<MyGame> {
  late double mPosY;
  bool movingDown = true;
  int kalabanIndex = 0;

  @override
  Future<void> onLoad() async {
    mPosY = gameRef.size[1] / 2 - 50;

    sprite =
        await Sprite.load('characters/${KALABAN[kalabanIndex]["name"]}.png');
    size = Vector2(size[0], size[0] * 1.5);
    position = Vector2(size[0] / 2, mPosY);
    anchor = Anchor.center;

    await FlameAudio.audioCache.load('attack.mp3');
  }

  @override
  void onTapDown(TapDownEvent event) async {
    FlameAudio.play('attack.mp3');

    gameRef.updateLifeBar();
    sprite = await Sprite.load(
        'characters/${KALABAN[kalabanIndex]["name"]} dmg.png');

    gameRef.showDamage(event.localPosition);

    Future.delayed(const Duration(milliseconds: 100), () async {
      sprite =
          await Sprite.load('characters/${KALABAN[kalabanIndex]["name"]}.png');
    });
  }

  @override
  void update(double dt) {
    super.update(dt);

    double speed = 5 * dt;
    double distance = 2;

    if (movingDown) {
      y += speed;
      if (y >= mPosY + distance) {
        movingDown = false;
      }
    } else {
      y -= speed;
      if (y <= mPosY) {
        movingDown = true;
      }
    }
  }
}
