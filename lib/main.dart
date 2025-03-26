import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learnflame/models/armas.dart';
import 'package:learnflame/models/book.dart';
import 'package:learnflame/models/charactercard.dart';
import 'package:learnflame/models/damagemsg.dart';
import 'package:learnflame/models/energy.dart';
import 'package:learnflame/models/gameover.dart';
import 'package:learnflame/models/kalaban.dart';
import 'package:learnflame/models/kalabanList.dart';
import 'package:learnflame/models/lavel.dart';
import 'package:learnflame/models/lifebar.dart';

void main() {
  runApp(GameWidget(game: MyGame()));
}

class MyGame extends FlameGame {
  double damage = 25;
  double kalabanDef = 1;
  late int kalabanIdex;
  int energy = 30;
  int sandata = 0;

  SpriteComponent b1 = SpriteComponent();
  Kalaban kalaban = Kalaban();
  SpriteComponent scroll = SpriteComponent();

  PositionComponent pc = PositionComponent();
  PositionComponent life = PositionComponent();
  LifeBar lifeBar = LifeBar();

  var over;

  Level level = Level();

  Book book = Book();

  Energy energyComp = Energy(30);

  Armas armas1 = Armas("${ARMAS[0]}.png", 0);
  Armas armas2 = Armas("${ARMAS[1]}.png", 1);
  Armas armas3 = Armas("${ARMAS[2]}.png", 2);
  Armas armas4 = Armas("${ARMAS[3]}.png", 3);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    await FlameAudio.audioCache.loadAll([
      'bg_music.MP3',
      'death.mp3',
      'gameover.mp3',
    ]);

    FlameAudio.bgm.play('bg_music.MP3', volume: 0.5);

    int randI = Random().nextInt(KALABAN.length - 1);
    kalaban.kalabanIndex = randI;
    kalabanIdex = randI;
    kalaban.sprite =
        await Sprite.load("characters/${KALABAN[randI]["name"]}.png");

    b1
      ..sprite = await Sprite.load('backgrounds/bg4.jpg')
      ..size = Vector2(size[0], size[1]);

    scroll
      ..sprite = await Sprite.load("backgrounds/scroll.png")
      ..size = Vector2(size[0] * 1.1, 250)
      ..anchor = Anchor.bottomCenter
      ..position = Vector2(size[0] / 2 + 5, size[1] + 30)
      ..priority = 105;

    pc
      ..position = Vector2(size[0] / 2, size[1])
      ..size = Vector2(4 * 50 + 2 * 20, 150)
      ..priority = 110
      ..anchor = Anchor.bottomCenter;

    pc.add(TextComponent(
      anchor: Anchor.center,
      text: "Mga Sandata",
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(pc.size[0] / 2, 0),
    ));

    pc.add(armas1);
    pc.add(armas2);
    pc.add(armas3);
    pc.add(armas4);

    life
      ..position = Vector2(10, size[0] + 50)
      ..size = Vector2(size[0] - 20, 5)
      ..priority = 115;

    life.add(
      RectangleComponent(
        size: Vector2(size[0] - 20, 5),
        paint: Paint()..color = Colors.white,
      ),
    );

    life.add(lifeBar);

    add(energyComp);
    add(book);
    add(level);
    add(life);
    add(pc);
    add(scroll);
    add(b1);
    add(kalaban);
  }

  void setWeapon(int index) async {
    sandata = index;
    List<Armas> armas = [
      armas1,
      armas2,
      armas3,
      armas4,
    ];

    for (int i = 0; i < armas.length; i++) {
      if (index == i) {
        armas[i].size = Vector2(50, 70);
        armas[i].armasImg.size = armas[i].size;
      } else {
        armas[i].size = Vector2(40, 60);
        armas[i].armasImg.size = armas[i].size;
      }
    }
  }

  void showDamage(Vector2 pos) {
    DamageMsg msg = DamageMsg(pos, damage);
    add(msg);

    Future.delayed(const Duration(milliseconds: 500), () {
      remove(msg);
    });
  }

  void updateLifeBar() async {
    if (energy <= 0) {
      FlameAudio.play('gameover.mp3');
      FlameAudio.bgm.stop();
      energy--;
      over = GameOver(level.level);
      add(over);
    } else {
      energy--;
      if (lifeBar.size[0] < size[0] - 20 && energy > 0) {
        double truedmg = 20;
        double truedef = 1;

        List<int> weakness = KALABAN[kalabanIdex]["weakness"];
        weakness.forEach((w) {
          if (w == sandata) {
            truedmg = 40;
          }
        });

        List<int> strength = KALABAN[kalabanIdex]["strength"];
        strength.forEach((s) {
          if (s == sandata) {
            truedef = 10;
          }
        });

        lifeBar.size = Vector2(lifeBar.size[0] + truedmg / truedef, 5);
      } else if (energy > 0) {
        FlameAudio.play('death.mp3');

        int randI = Random().nextInt(KALABAN.length - 1);
        kalaban.kalabanIndex = randI;
        kalabanIdex = randI;
        kalaban.sprite =
            await Sprite.load("characters/${KALABAN[randI]["name"]}.png");
        level.updateLevel();
        lifeBar.size = Vector2(0, 5);
        energy += 20;
      }
    }

    energyComp.updateEnergy(energy);
  }

  void restartGame() async {
    FlameAudio.bgm.stop();

    damage = 25;
    kalabanDef = 1;
    kalabanIdex;
    energy = 30;
    sandata = 0;
    level.level = 1;
    energyComp.updateEnergy(energy);
    lifeBar.size = Vector2(0, 5);

    remove(over);

    FlameAudio.bgm.play('bg_music.MP3', volume: 0.5);
  }

  void showCard() {
    PositionComponent cardModal = PositionComponent(
      priority: 120,
    );
    ModalBg mBg = ModalBg(size, cardModal);
    cardModal.add(mBg);

    CharacterCard card = CharacterCard(kalabanIdex);
    cardModal.add(card);
    add(cardModal);
  }
}

class ModalBg extends RectangleComponent with TapCallbacks, HasGameRef<MyGame> {
  late PositionComponent modal;
  late Vector2 s;
  ModalBg(this.s, this.modal);
  @override
  Future<void> onLoad() async {
    size = s;
    paint = Paint()..color = Colors.black54;
    position = Vector2(0, 0);
    priority = 9;
  }

  @override
  void onTapDown(TapDownEvent event) async {
    gameRef.remove(modal);
  }
}
