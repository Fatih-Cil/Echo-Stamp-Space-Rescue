# ECHO STAMP - Game Guide (Living Document)

Bu dosya, oyunun mevcut davranisini ve gelistirme kurallarini tek yerde toplar.
Her yeni ozellik degisimi sonrasinda bu dosya da guncellenmelidir.

## 1) Oyun Ozeti

- Tur: Portrait mobil, refleks + zamanlama.
- Oyuncu roketi otomatik sag tarafa ilerliyormus hissi veren akista sinus hareketiyle yukari-asagi salinir.
- Oyuncu dokunarak `ARMOR` (eski stamp) kullanir.
- Donemsel gelen sweep (scan hatti) olumcul duruma gecince roketi vurursa oyun biter (koruma yoksa).
- Amac: skor artirmak, astronaut toplamak, rozet/kart koleksiyonu tamamlamak.

## 2) Temel Oynanis

1. Oyun `Tap to Start` ile baslar.
2. Roket otomatik hareket eder; oyuncu sadece dogru zamanda dokunur.
3. Dokunma, bir armor charge tuketir ve kisa bir koruma penceresi acar.
4. Sweep warning asamasinda cok gec zamanda basilarak `Perfect` alinabilir.
5. Kapilardan/gezegenlerden gecerek skor kazanilir.
6. Astronaut pickup'lari ek faydalar verir.
7. Olunce `DEAD` karti gelir; tekrar dokunarak run yeniden baslar.

## 3) Sweep ve Hayatta Kalma Kurali

- Sweep iki asamali:
  - Warning (gorsel uyari)
  - Lethal (vurursa oldurur)
- Armor aktifse sweep isabeti olumu engeller.
- Extra Life varsa, sweep darbesi bir kez can harcayarak atlatilir.
- Normal armor koruma suresi: `0.25s`.
- Armor Boost aktifken koruma suresi: `1.5s`.
- Perfect penceresi: `0.10s`.
- Perfect, sadece hem `0.10s` penceresinde hem de aktif shield suresi sweep'i kurtaracak noktadaysa verilir.

## 4) Pickup Turleri

- Mavi astronaut: `+1 Armor`
- Yesil astronaut: `+Score`
- Kirmizi astronaut: `+1 Extra Life`
- Mor astronaut: `Armor Boost` (kisa sure daha uzun shield etkisi)
- Fuel kapsulu: `+Fuel` (yakit tankini doldurur)

Ek:
- Rescue Combo sistemi var.
- Kaçirilan pickup combo'yu resetler.

## 5) Seviye ve Loop

- Oyun 4 level yapisinda akar, sonra loop devam eder.
- Level suresi: `30s`.
- Level gecisinde zorluk artisina gidilir (sweep, spawn, regen carpani vb).
- Loop arttikca roket salinim frekansi artar:
  - Loop 1: `0.45 Hz`
  - Loop 2: `0.50 Hz`
  - Loop 3: `0.55 Hz`
  - Loop 4+: `0.60 Hz` (cap)
- Biome akisi:
  - L1: Nebula
  - L2: Asteroid
  - L3: Plasma
  - L4: Solar
- L4 bitince Loop artar ve tekrar L1'e doner (daha zor parametrelerle).

## 5.1) Fuel Sistemi

- Fuel baslangici: `100`
- Fuel zamanla azalir: `4.2/s` (daha affedici denge)
- Level gecisinde fuel otomatik `100` olur.
- Fuel kapsulu toplama:
  - L1: `+40`
  - L2: `+38`
  - L3: `+36`
  - L4: `+34`
- Fuel kapsul araligi:
  - normal: `6-9s`
  - fuel <= 50%: `3.6-5.8s`
  - fuel <= 25%: `2.2-3.6s`
- Fuel kapsulu cekim yardimi level bazlidir (L1 en kolay, L4 en zor/baseline):
  - L1: cok guclu cekim (erken yakalama yardimi)
  - L2: guclu cekim
  - L3: orta cekim
  - L4: temel/orijinal cekim davranisi
- Fuel `0` olursa lazer carpmamissa bile oyun biter (`OUT OF FUEL`).

## 6) Skor, Best ve Kutlama

- Best score `save.cfg` icinde tutulur.
- New best gecildiginde oyun ici kutlama ve ses tetiklenir.
- Run best ile biterse dead sonrasi kutlama gosterilir.

## 7) Audio

- SFX ve Music ayri toggle ile acilip kapanir.
- Voice callout dosyalari:
  - `res://assets/voice/perfect.ogg`
  - `res://assets/voice/streak.ogg`
  - `res://assets/voice/new-best.ogg`

## 8) Koleksiyon / Rozet Sistemi (Faz 2)

Iki ayri rozet grubu vardir:

1. Trail Rozetleri (Pack ile)
- Neon Wake (Rare)
- Solar Ember (Epic)
- Void Prism (Legend)

2. Score Rozetleri (Skor kilometre tasi ile)
- Score Ace I (20+)
- Score Ace II (45+)
- Score Ace III (70+)

3. Loop Rozetleri (Loop basarisi ile)
- Loop Runner I (Loop 2)
- Loop Runner II (Loop 4)
- Loop Runner III (Loop 6)

Not:
- Trail rozetleri score sistemiyle verilmez.
- Score rozetleri pack drop havuzuna dahil degildir.
- Kazanilan kart/rozetler otomatik olarak unlock popup'inda gosterilir.
- Trail kart kazanilirsa otomatik equip edilir (manuel equip gerekmez).

## 9) Pack Sistemi

- Run sonunda skor kadar pack progress kazanilir.
- Pack esigi, sahip olunan trail rozet sayisina gore artar:
  - 0 trail rozet: 500
  - 1 trail rozet: 2500
  - 2+ trail rozet: 10000
- Duplicate trail kartta progress bonusu verilir.
- Score rozeti duplicate olursa ek pack progress verilir.
- Run sonunda kazanilan pack'ler otomatik claim edilir.
- `Open Pack` butonu sadece elde acilmamis pack varsa gorunur.

## 10) UI Panelleri

- `SET`: ses/muzik ayarlari
- `HOW`: oynanis ve kurallar
- `ALB`: koleksiyon paneli
- DEAD karti ve album cakismasi engellenmistir (album acikken dead kart gizlenir).
- Rozet/kart odulu DEAD oncesi ekranda buyuk popup olarak gelir ve `CONTINUE` ile kapatilir.
- Fuel bitisinde death kartinda `DEAD` basliginin altinda `OUT OF FUEL` alt-basligi gosterilir.
- Ghost marker: bir onceki run'da olunen konum, sonraki runlarda "LAST CRASH" isaretiyle gorunur.
- Album rozet gorseli yalnizca PNG ile cizilir:
  - kaynak: `res://assets/badges/<card_id>.png`
  - daire/ribbon/ek cizim yoktur (PNG-only)
  - kilitli rozetlerde `LOCKED` yazisi gorselin ortasinda gosterilir.

## 11) Save Dosyasi

Konum:
- macOS: `~/Library/Application Support/Godot/app_userdata/ECHO STAMP/save.cfg`

Onemli alanlar:
- `[scores]`
  - `best`
- `[meta]`
  - `pack_progress`
  - `packs_unopened`
  - `owned_cards`
  - `equipped_trail_card`
  - `last_death_distance`
  - `last_death_y`
- `[audio]`
  - `music_enabled`, `sfx_enabled`
  - `music_volume_db`, `sfx_volume_db`

## 12) Kodda Ana Dosyalar

- `scenes/Main.tscn`: Ana sahne ve UI hiyerarsisi
- `scripts/main.gd`: Oyun dongusu, skor, seviyeler, panel akislari, save/load
- `scripts/player.gd`: Roket cizimi, hareket, patlama
- `scripts/trail.gd`: trail cizimi, locked/unlocked kisimlar
- `scripts/sweep.gd`: warning/lethal sweep mantigi
- `scripts/heart_pickup.gd`: pickup davranisi/cizimi
- `scripts/fuel_pickup.gd`: fuel kapsulu davranisi/cizimi
- `scripts/card_badge.gd`: rozet gorsel komponenti
- `scripts/ghost_marker.gd`: son run olus konumu gostergesi (`LAST CRASH`)

## 13) Degisiklik Sonrasi Guncelleme Checklist

Her gameplay/UI degisikliginden sonra:

1. Bu dosyada ilgili bolumu guncelle.
2. Esik/deger degisti ise:
   - Bu dosyada yeni degeri yaz.
   - `HOW TO PLAY` metnini guncelle.
3. Save formatina yeni alan eklendiyse:
   - Bu dosyanin `Save Dosyasi` bolumune ekle.
4. Yeni ses/gorsel dosya eklendiyse:
   - Konumunu ve dosya adini bu dosyaya ekle.
5. UI panel davranisi degistiyse:
   - `UI Panelleri` bolumunu guncelle.

## 14) Kisa Test Senaryolari

- Baslangic -> run -> death -> retry akisi bozulmadan calisiyor mu?
- Sweep warning/lethal zamanlamasi ve armor korunmasi dogru mu?
- Level/Loop gecisleri net gorunuyor mu?
- Pack progress/esik degerleri beklenen sekilde artiyor mu?
- Album acilisinda panel cakismasi var mi?
- Yeni rozet unlock banner + ses tetikleniyor mu?

---

Bu dosya "tek kaynak dokuman" olarak kullanilmali.
Yeni ozellik eklenince burada mutlaka kayit altina alinmali.
