# Lofi Radio Minimal — виджет для KDE Plasma 6

Минималистичный виджет lofi-радио для рабочего стола KDE Plasma 6.  
Клон [plasma-lofi-radio](https://github.com/Caracoto4/plasma-lofi-radio) с чистым дизайном.

## Отличия от оригинала

| plasma-lofi-radio | lofi-radio-minimal |
|---|---|
| Виниловая пластинка + тонарм | Нет декоративных элементов |
| Анимированный эквалайзер | Нет эквалайзера |
| Градиентный фиолетовый фон | Системные цвета Plasma |
| 296×452 px | 260×200 px |
| Canvas-рисунки | Нативные Kirigami-компоненты |

## Возможности

- Прямая трансляция с `live.lofiradio.ru` (lofi hip hop 128 kbps, lofi chill 96 kbps)
- Живые названия треков через helper-скрипт
- Два режима: виджет на рабочем столе + иконка на панели
- Автопереподключение при обрыве потока
- Регулятор громкости
- Бегущая строка для длинных названий треков

## Требования

| Компонент | Версия |
|---|---|
| KDE Plasma | 6.0+ |
| Qt | 6 с qt6-multimedia |
| Python | 3.8+ (только stdlib) |

## Установка

```bash
git clone <this-repo>
cd plasma-lofi-minimal
chmod +x install.sh
./install.sh
```

После установки: правый клик по рабочему столу → **Добавить виджеты…** → **Lofi Radio Minimal**.

## Удаление

```bash
./uninstall.sh
```

## Структура

```
package/
├── metadata.json
└── contents/ui/
    ├── main.qml
    └── components/
        ├── qmldir
        ├── StreamPlayer.qml
        └── PlayerCard.qml

helper/
├── lofi-nowplaying.py
└── lofi-nowplaying.service

install.sh
uninstall.sh
```

## Лицензия

MIT
