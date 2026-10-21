import { useState, useEffect } from "react";

function WidgetPreview({ playing, compact = false }: { playing: boolean; compact?: boolean }) {
  const trackTitle = "Shade";
  const trackArtist = "dryhope";
  const station = "lofi hip hop";

  if (compact) {
    return (
      <div className="w-[34px] h-[34px] flex items-center justify-center rounded-md bg-white/5 border border-white/10">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor" className={playing ? "text-white" : "text-white/50"}>
          {playing ? (
            <path d="M6 4h4v16H6V4zm8 0h4v16h-4V4z"/>
          ) : (
            <path d="M8 5v14l11-7z"/>
          )}
        </svg>
      </div>
    );
  }

  return (
    <div className="w-[260px] bg-[#2a2a2e] rounded-xl border border-white/10 p-4 flex flex-col gap-3 shadow-2xl">
      {/* Header */}
      <div className="flex items-center gap-2">
        <div className={`w-[6px] h-[6px] rounded-full ${playing ? 'bg-green-400 animate-pulse' : 'bg-gray-600'}`} />
        <span className="text-[10px] tracking-widest text-white/50 uppercase font-medium">lofi radio</span>
        <span className="text-[10px] text-white/30 ml-auto">{station}</span>
      </div>

      {/* Track Info */}
      <div className="flex flex-col gap-0.5">
        <div className="overflow-hidden">
          <p className="text-[13px] font-medium text-white truncate">{trackTitle}</p>
        </div>
        <p className="text-[11px] text-white/40 truncate">{trackArtist}</p>
      </div>

      {/* Controls */}
      <div className="flex items-center justify-center gap-3 py-1">
        <button className="w-8 h-8 rounded-full flex items-center justify-center hover:bg-white/10 transition-colors">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor" className="text-white/60">
            <path d="M6 6h2v12H6zm3.5 6l8.5 6V6z"/>
          </svg>
        </button>

        <button className="w-10 h-10 rounded-full bg-blue-500/15 hover:bg-blue-500/25 flex items-center justify-center transition-colors">
          {playing ? (
            <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor" className="text-white">
              <path d="M6 4h4v16H6V4zm8 0h4v16h-4V4z"/>
            </svg>
          ) : (
            <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor" className="text-white">
              <path d="M8 5v14l11-7z"/>
            </svg>
          )}
        </button>

        <button className="w-8 h-8 rounded-full flex items-center justify-center hover:bg-white/10 transition-colors">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor" className="text-white/60">
            <path d="M6 18l8.5-6L6 6v12zM16 6v12h2V6h-2z"/>
          </svg>
        </button>
      </div>

      {/* Volume */}
      <div className="flex items-center gap-2">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor" className="text-white/40">
          <path d="M3 9v6h4l5 5V4L7 9H3zm13.5 3c0-1.77-1.02-3.29-2.5-4.03v8.05c1.48-.73 2.5-2.25 2.5-4.02z"/>
        </svg>
        <div className="flex-1 h-[3px] bg-white/10 rounded-full overflow-hidden">
          <div className="h-full bg-blue-400/80 rounded-full" style={{ width: '75%' }} />
        </div>
      </div>
    </div>
  );
}

function DesktopPreview() {
  const [playing, setPlaying] = useState(true);

  useEffect(() => {
    const interval = setInterval(() => setPlaying(p => !p), 5000);
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="relative w-full max-w-[640px] mx-auto">
      <div className="relative rounded-2xl overflow-hidden border border-white/10 shadow-2xl">
        <div className="aspect-[16/10] bg-gradient-to-br from-[#1a1b26] via-[#24283b] to-[#1a1b26] relative">
          <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_30%_20%,rgba(100,108,255,0.12),transparent_50%)]" />
          <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_70%_80%,rgba(255,100,150,0.06),transparent_50%)]" />
          
          {/* Fake taskbar */}
          <div className="absolute bottom-0 left-0 right-0 h-10 bg-black/40 backdrop-blur-md border-t border-white/5 flex items-center px-3 gap-2">
            <div className="w-6 h-6 rounded bg-white/10" />
            <div className="w-6 h-6 rounded bg-white/10" />
            <div className="w-6 h-6 rounded bg-blue-500/30 flex items-center justify-center">
              <svg width="10" height="10" viewBox="0 0 24 24" fill="currentColor" className="text-white/70">
                {playing ? <path d="M6 4h4v16H6V4zm8 0h4v16h-4V4z"/> : <path d="M8 5v14l11-7z"/>}
              </svg>
            </div>
            <div className="ml-auto text-[10px] text-white/40 font-mono">14:32</div>
          </div>

          {/* Widget on desktop */}
          <div className="absolute top-8 right-8">
            <WidgetPreview playing={playing} />
          </div>

          {/* Label */}
          <div className="absolute top-4 left-4 text-white/20 text-xs font-mono">
            KDE Plasma 6 — Desktop
          </div>
        </div>
      </div>
    </div>
  );
}

function FileTree() {
  return (
    <div className="font-mono text-sm text-gray-300 bg-[#1e1e2e] rounded-xl p-5 border border-white/10 overflow-x-auto">
      <div className="text-blue-400 mb-2 font-semibold">plasma-lofi-radio-mini/</div>
      <div className="ml-4 space-y-0.5">
        <div className="text-yellow-300">├── package/</div>
        <div className="ml-8">
          <div className="text-green-300">├── metadata.json</div>
          <div className="text-gray-500">│   id: org.koda.lofiradio.mini</div>
          <div className="text-yellow-300">└── contents/ui/</div>
          <div className="ml-8">
            <div className="text-green-300">├── main.qml</div>
            <div className="text-gray-500">│   PlasmoidItem (260×180)</div>
            <div className="text-yellow-300">└── components/</div>
            <div className="ml-8">
              <div className="text-green-300">├── qmldir</div>
              <div className="text-green-300">├── StreamPlayer.qml</div>
              <div className="text-gray-500">│   MediaPlayer singleton</div>
              <div className="text-green-300">└── PlayerCard.qml</div>
              <div className="text-gray-500">    minimal UI (Kirigami)</div>
            </div>
          </div>
        </div>
        <div className="text-yellow-300 mt-2">├── helper/</div>
        <div className="ml-8">
          <div className="text-green-300">├── lofi-nowplaying.py</div>
          <div className="text-gray-500">│   Icecast → JSON (stdlib)</div>
          <div className="text-green-300">└── lofi-nowplaying.service</div>
          <div className="text-gray-500">    systemd user unit</div>
        </div>
        <div className="text-green-300 mt-2">├── install.sh</div>
        <div className="text-green-300">├── uninstall.sh</div>
        <div className="text-green-300">├── README.md</div>
        <div className="text-green-300">└── LICENSE</div>
      </div>
    </div>
  );
}

function CodeBlock({ code, filename }: { code: string; filename?: string }) {
  const [copied, setCopied] = useState(false);

  const handleCopy = () => {
    navigator.clipboard.writeText(code);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="relative group">
      {filename && (
        <div className="flex items-center gap-2 px-4 py-2 bg-[#1a1a2a] rounded-t-xl border border-white/10 border-b-0">
          <div className="w-2 h-2 rounded-full bg-blue-400/50" />
          <span className="text-xs text-white/40 font-mono">{filename}</span>
        </div>
      )}
      <pre className={`bg-[#1e1e2e] ${filename ? 'rounded-b-xl' : 'rounded-xl'} p-4 border border-white/10 overflow-x-auto text-sm text-gray-300 font-mono`}>
        <code>{code}</code>
      </pre>
      <button
        onClick={handleCopy}
        className="absolute top-2 right-2 px-2 py-1 rounded bg-white/10 text-xs text-white/60 hover:text-white hover:bg-white/20 transition-all opacity-0 group-hover:opacity-100"
      >
        {copied ? "✓ скопировано" : "copy"}
      </button>
    </div>
  );
}

function StatusBadge({ ok, text }: { ok: boolean; text: string }) {
  return (
    <span className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium ${
      ok ? 'bg-green-500/10 border border-green-500/20 text-green-300' : 'bg-red-500/10 border border-red-500/20 text-red-300'
    }`}>
      <span className={`w-1.5 h-1.5 rounded-full ${ok ? 'bg-green-400' : 'bg-red-400'}`} />
      {text}
    </span>
  );
}

export default function App() {
  return (
    <div className="min-h-screen bg-[#0f0f14] text-white">
      {/* Hero */}
      <section className="relative overflow-hidden">
        <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_50%_0%,rgba(59,130,246,0.08),transparent_60%)]" />
        <div className="max-w-5xl mx-auto px-6 pt-16 pb-12 relative">
          <div className="flex items-center gap-3 mb-6">
            <div className="w-10 h-10 rounded-xl bg-blue-500/20 flex items-center justify-center">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="text-blue-400">
                <path d="M9 18V5l12-2v13"/>
                <circle cx="6" cy="18" r="3"/>
                <circle cx="18" cy="16" r="3"/>
              </svg>
            </div>
            <div>
              <h1 className="text-2xl font-bold tracking-tight">Lofi Radio Mini</h1>
              <p className="text-sm text-white/40">виджет для KDE Plasma 6</p>
            </div>
          </div>
          
          <p className="text-lg text-white/70 max-w-2xl mb-6">
            Минималистичный клон <a href="https://github.com/Caracoto4/plasma-lofi-radio" className="text-blue-400 hover:text-blue-300 underline underline-offset-2">plasma-lofi-radio</a> — 
            без винила, тонарма и эквалайзера. Чистый дизайн в стиле системных виджетов Plasma 6.
          </p>

          <div className="flex flex-wrap gap-2 mb-10">
            <span className="px-3 py-1 rounded-full bg-blue-500/10 border border-blue-500/20 text-blue-300 text-xs">KDE Plasma 6</span>
            <span className="px-3 py-1 rounded-full bg-green-500/10 border border-green-500/20 text-green-300 text-xs">Qt 6</span>
            <span className="px-3 py-1 rounded-full bg-purple-500/10 border border-purple-500/20 text-purple-300 text-xs">QML</span>
            <span className="px-3 py-1 rounded-full bg-yellow-500/10 border border-yellow-500/20 text-yellow-300 text-xs">MIT</span>
          </div>

          <DesktopPreview />
        </div>
      </section>

      {/* File status */}
      <section className="max-w-5xl mx-auto px-6 py-12">
        <h2 className="text-xl font-bold mb-4 text-white/90">Статус файлов</h2>
        <p className="text-sm text-white/50 mb-6">
          Все файлы виджета созданы в корне проекта. Скопируйте их в репозиторий{" "}
          <a href="https://github.com/Caracoto4/plasma-lofi-radio-mini" className="text-blue-400 hover:text-blue-300">
            Caracoto4/plasma-lofi-radio-mini
          </a>
        </p>
        
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3 mb-8">
          {[
            { path: "package/metadata.json", ok: true },
            { path: "package/contents/ui/main.qml", ok: true },
            { path: "package/contents/ui/components/qmldir", ok: true },
            { path: "package/contents/ui/components/StreamPlayer.qml", ok: true },
            { path: "package/contents/ui/components/PlayerCard.qml", ok: true },
            { path: "helper/lofi-nowplaying.py", ok: true },
            { path: "helper/lofi-nowplaying.service", ok: true },
            { path: "install.sh", ok: true },
            { path: "uninstall.sh", ok: true },
            { path: "README.md", ok: true },
            { path: "LICENSE", ok: true },
          ].map((f) => (
            <div key={f.path} className="flex items-center gap-2 px-3 py-2 rounded-lg bg-white/[0.03] border border-white/[0.06]">
              <StatusBadge ok={f.ok} text={f.ok ? "готов" : "отсутствует"} />
              <span className="text-xs font-mono text-white/60 truncate">{f.path}</span>
            </div>
          ))}
        </div>

        <div className="p-4 rounded-xl bg-yellow-500/5 border border-yellow-500/20">
          <div className="flex items-start gap-3">
            <span className="text-yellow-400 text-lg">⚠</span>
            <div>
              <p className="text-sm text-yellow-200 font-medium mb-1">Важно: файлы не деплоятся автоматически</p>
              <p className="text-xs text-yellow-200/60">
                Эта среда создаёт файлы только для веб-превью. Чтобы добавить виджет в репозиторий, 
                скопируйте содержимое файлов ниже (или скачайте их) и запушьте в{" "}
                <code className="bg-white/10 px-1 rounded">github.com/Caracoto4/plasma-lofi-radio-mini</code>.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Structure */}
      <section className="max-w-5xl mx-auto px-6 py-12">
        <h2 className="text-xl font-bold mb-6 text-white/90">Структура проекта</h2>
        <FileTree />
      </section>

      {/* Installation */}
      <section className="max-w-5xl mx-auto px-6 py-12">
        <h2 className="text-xl font-bold mb-6 text-white/90">Установка</h2>
        
        <div className="space-y-6">
          <div>
            <h3 className="text-sm font-medium text-white/70 mb-3">Клонирование и установка</h3>
            <CodeBlock 
              filename="terminal"
              code={`git clone https://github.com/Caracoto4/plasma-lofi-radio-mini.git
cd plasma-lofi-radio-mini
chmod +x install.sh
./install.sh`} 
            />
          </div>

          <div>
            <h3 className="text-sm font-medium text-white/70 mb-3">Ручная установка</h3>
            <CodeBlock 
              filename="terminal"
              code={`# Установка виджета
kpackagetool6 --type Plasma/Applet --install ./package

# Установка helper-скрипта
install -Dm755 helper/lofi-nowplaying.py ~/.local/share/lofi-radio-mini/lofi-nowplaying.py
install -Dm644 helper/lofi-nowplaying.service ~/.config/systemd/user/lofi-nowplaying.service
systemctl --user daemon-reload
systemctl --user enable --now lofi-nowplaying.service`} 
            />
          </div>

          <div>
            <h3 className="text-sm font-medium text-white/70 mb-3">После установки</h3>
            <CodeBlock 
              filename="terminal"
              code={`# Добавить виджет:
# Правый клик → «Добавить виджеты…» → «Lofi Radio Mini»

# Если виджет не появился:
systemctl --user restart plasma-plasmashell.service

# Проверить helper:
curl http://127.0.0.1:8731/nowplaying.json`} 
            />
          </div>
        </div>
      </section>

      {/* Key files content */}
      <section className="max-w-5xl mx-auto px-6 py-12">
        <h2 className="text-xl font-bold mb-6 text-white/90">Содержимое ключевых файлов</h2>
        <p className="text-sm text-white/50 mb-6">Скопируйте эти файлы в свой репозиторий:</p>

        <div className="space-y-6">
          <details className="group rounded-xl bg-white/[0.02] border border-white/[0.06] overflow-hidden">
            <summary className="p-4 cursor-pointer text-sm font-medium text-white/80 hover:text-white transition-colors list-none flex items-center justify-between">
              <span className="flex items-center gap-2">
                <span className="text-green-400">●</span>
                <code className="text-xs">package/metadata.json</code>
              </span>
              <svg className="w-4 h-4 text-white/40 group-open:rotate-180 transition-transform" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <path d="M6 9l6 6 6-6"/>
              </svg>
            </summary>
            <div className="px-4 pb-4">
              <CodeBlock code={`{
    "KPackageStructure": "Plasma/Applet",
    "KPlugin": {
        "Authors": [{"Name": "Caracoto4"}],
        "Category": "Multimedia",
        "Description": "Minimalist lofi radio player widget for KDE Plasma 6",
        "Description[ru]": "Минималистичный виджет lofi-радио для KDE Plasma 6",
        "Icon": "media-playback-start",
        "Id": "org.koda.lofiradio.mini",
        "License": "MIT",
        "Name": "Lofi Radio Mini",
        "Name[ru]": "Lofi-радио (мини)",
        "Version": "1.0.0",
        "Website": "https://lofiradio.ru"
    },
    "X-Plasma-API-Minimum-Version": "6.0"
}`} />
            </div>
          </details>

          <details className="group rounded-xl bg-white/[0.02] border border-white/[0.06] overflow-hidden">
            <summary className="p-4 cursor-pointer text-sm font-medium text-white/80 hover:text-white transition-colors list-none flex items-center justify-between">
              <span className="flex items-center gap-2">
                <span className="text-green-400">●</span>
                <code className="text-xs">package/contents/ui/components/qmldir</code>
              </span>
              <svg className="w-4 h-4 text-white/40 group-open:rotate-180 transition-transform" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <path d="M6 9l6 6 6-6"/>
              </svg>
            </summary>
            <div className="px-4 pb-4">
              <CodeBlock code={`module org.koda.lofiradio.mini

singleton StreamPlayer 1.0 StreamPlayer.qml
PlayerCard 1.0 PlayerCard.qml`} />
            </div>
          </details>

          <details className="group rounded-xl bg-white/[0.02] border border-white/[0.06] overflow-hidden">
            <summary className="p-4 cursor-pointer text-sm font-medium text-white/80 hover:text-white transition-colors list-none flex items-center justify-between">
              <span className="flex items-center gap-2">
                <span className="text-green-400">●</span>
                <code className="text-xs">package/contents/ui/main.qml</code>
              </span>
              <svg className="w-4 h-4 text-white/40 group-open:rotate-180 transition-transform" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <path d="M6 9l6 6 6-6"/>
              </svg>
            </summary>
            <div className="px-4 pb-4">
              <CodeBlock code={`import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

import "components" as Components

PlasmoidItem {
    id: root

    preferredRepresentation: fullRepresentation

    readonly property Components.StreamPlayer engine: Components.StreamPlayer

    readonly property bool inPanel: plasmoid.location === PlasmaCore.Types.TopEdge
                                    || plasmoid.location === PlasmaCore.Types.LeftEdge
                                    || plasmoid.location === PlasmaCore.Types.RightEdge
                                    || plasmoid.location === PlasmaCore.Types.BottomEdge

    fullRepresentation: Item {
        implicitWidth: 260
        implicitHeight: 180
        Layout.preferredWidth: implicitWidth
        Layout.preferredHeight: implicitHeight
        Layout.minimumWidth: 220
        Layout.minimumHeight: 160

        Components.PlayerCard {
            anchors.fill: parent
            engine: root.engine
            drawBackground: !root.inPanel
        }
    }

    compactRepresentation: Item {
        implicitWidth: 34
        implicitHeight: 34

        Components.PlayerCard {
            anchors.fill: parent
            compact: true
            drawBackground: false
            previewActive: true
            previewPlaying: root.engine.playing
            previewTitle: root.engine.title
            previewArtist: root.engine.artist
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: root.expanded = !root.expanded
        }
    }
}`} />
            </div>
          </details>
        </div>
      </section>

      {/* Comparison */}
      <section className="max-w-5xl mx-auto px-6 py-12">
        <h2 className="text-xl font-bold mb-6 text-white/90">Сравнение с оригиналом</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="p-5 rounded-xl bg-white/[0.03] border border-white/[0.06]">
            <h3 className="text-sm font-medium text-white/60 mb-3">plasma-lofi-radio (оригинал)</h3>
            <ul className="space-y-2 text-xs text-white/50">
              <li>• Виниловая пластинка с вращением</li>
              <li>• Тонарм с анимацией</li>
              <li>• Анимированный эквалайзер (8 баров)</li>
              <li>• Градиентный фон (фиолетовый)</li>
              <li>• Размер: 296×452 px</li>
              <li>• Сложные Canvas-рисунки</li>
            </ul>
          </div>
          <div className="p-5 rounded-xl bg-blue-500/[0.05] border border-blue-500/20">
            <h3 className="text-sm font-medium text-blue-300 mb-3">lofi-radio-mini (этот)</h3>
            <ul className="space-y-2 text-xs text-white/70">
              <li className="flex items-center gap-2"><span className="text-green-400">✓</span> Без декоративных элементов</li>
              <li className="flex items-center gap-2"><span className="text-green-400">✓</span> Системные цвета Plasma</li>
              <li className="flex items-center gap-2"><span className="text-green-400">✓</span> Нативные Kirigami-компоненты</li>
              <li className="flex items-center gap-2"><span className="text-green-400">✓</span> Компактный: 260×180 px</li>
              <li className="flex items-center gap-2"><span className="text-green-400">✓</span> Бегущая строка трека</li>
              <li className="flex items-center gap-2"><span className="text-green-400">✓</span> Тот же helper для метаданных</li>
            </ul>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="max-w-5xl mx-auto px-6 py-10 border-t border-white/[0.06]">
        <div className="flex flex-col sm:flex-row items-center justify-between gap-4">
          <div className="text-sm text-white/30">
            Lofi Radio Mini · MIT License · KDE Plasma 6
          </div>
          <div className="text-sm text-white/30">
            Поток: <a href="https://lofiradio.ru" className="text-blue-400/70 hover:text-blue-400 transition-colors">lofiradio.ru</a>
          </div>
        </div>
      </footer>
    </div>
  );
}
