import { useState, useEffect } from "react";

function WidgetPreview({ playing, compact = false }: { playing: boolean; compact?: boolean }) {
  const [trackTitle] = useState("Shade");
  const [trackArtist] = useState("dryhope");
  const [station] = useState("lofi hip hop");

  if (compact) {
    return (
      <div className="w-[34px] h-[34px] flex items-center justify-center">
        <div className={`w-5 h-5 rounded-full border-2 flex items-center justify-center ${playing ? 'border-blue-400' : 'border-gray-500'}`}>
          <div className={`w-0 h-0 ${playing ? 'border-l-[5px] border-l-gray-800 border-y-[4px] border-y-transparent' : 'w-[6px] h-[6px] rounded-sm bg-gray-800'}`} 
               style={playing ? {} : {}} />
        </div>
      </div>
    );
  }

  return (
    <div className="w-[260px] bg-[#2a2a2e] rounded-xl border border-white/10 p-4 flex flex-col gap-3 shadow-2xl">
      {/* Header */}
      <div className="flex items-center gap-2">
        <div className={`w-[6px] h-[6px] rounded-full ${playing ? 'bg-green-400 animate-pulse' : 'bg-gray-600'}`} />
        <span className="text-[10px] tracking-widest text-white/50 uppercase">lofi radio</span>
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
      <div className="flex items-center justify-center gap-4 py-1">
        <button className="w-8 h-8 rounded-full flex items-center justify-center hover:bg-white/10 transition-colors">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor" className="text-white/60">
            <path d="M6 6h2v12H6zm3.5 6l8.5 6V6z"/>
          </svg>
        </button>

        <button className="w-10 h-10 rounded-full bg-blue-500/20 hover:bg-blue-500/30 flex items-center justify-center transition-colors">
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
          <div className="h-full bg-blue-400 rounded-full" style={{ width: '75%' }} />
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
    <div className="relative w-full max-w-[600px] mx-auto">
      {/* Desktop background */}
      <div className="relative rounded-2xl overflow-hidden border border-white/10 shadow-2xl">
        <div className="aspect-[16/10] bg-gradient-to-br from-[#1a1b26] via-[#24283b] to-[#1a1b26] relative">
          {/* Fake wallpaper gradient */}
          <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_30%_20%,rgba(100,108,255,0.15),transparent_50%)]" />
          <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_70%_80%,rgba(255,100,150,0.08),transparent_50%)]" />
          
          {/* Fake taskbar */}
          <div className="absolute bottom-0 left-0 right-0 h-10 bg-black/40 backdrop-blur-md border-t border-white/5 flex items-center px-3 gap-2">
            <div className="w-6 h-6 rounded bg-white/10" />
            <div className="w-6 h-6 rounded bg-white/10" />
            <div className="w-6 h-6 rounded bg-blue-500/30" />
            <div className="ml-auto text-[10px] text-white/40">14:32</div>
          </div>

          {/* Widget on desktop */}
          <div className="absolute top-8 right-8">
            <WidgetPreview playing={playing} />
          </div>

          {/* Widget in panel */}
          <div className="absolute bottom-11 left-1/2 -translate-x-1/2">
            <WidgetPreview playing={playing} compact />
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
      <div className="text-blue-400 mb-2">plasma-lofi-minimal/</div>
      <div className="ml-4">
        <div className="text-yellow-300">├── package/</div>
        <div className="ml-8">
          <div className="text-green-300">├── metadata.json</div>
          <div className="text-gray-400">│   <span className="text-gray-500">← id, name, version</span></div>
          <div className="text-yellow-300">└── contents/ui/</div>
          <div className="ml-8">
            <div className="text-green-300">├── main.qml</div>
            <div className="text-gray-400">│   <span className="text-gray-500">← PlasmoidItem entry</span></div>
            <div className="text-yellow-300">└── components/</div>
            <div className="ml-8">
              <div className="text-green-300">├── qmldir</div>
              <div className="text-green-300">├── StreamPlayer.qml</div>
              <div className="text-gray-400">│   <span className="text-gray-500">← MediaPlayer singleton</span></div>
              <div className="text-green-300">└── PlayerCard.qml</div>
              <div className="text-gray-400">    <span className="text-gray-500">← minimal UI card</span></div>
            </div>
          </div>
        </div>
        <div className="text-yellow-300 mt-2">├── helper/</div>
        <div className="ml-8">
          <div className="text-green-300">├── lofi-nowplaying.py</div>
          <div className="text-gray-400">│   <span className="text-gray-500">← Icecast metadata → JSON</span></div>
          <div className="text-green-300">└── lofi-nowplaying.service</div>
          <div className="text-gray-400">    <span className="text-gray-500">← systemd user unit</span></div>
        </div>
        <div className="text-green-300 mt-2">├── install.sh</div>
        <div className="text-green-300">└── uninstall.sh</div>
      </div>
    </div>
  );
}

function CodeBlock({ code, lang = "bash" }: { code: string; lang?: string }) {
  const [copied, setCopied] = useState(false);

  const handleCopy = () => {
    navigator.clipboard.writeText(code);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="relative group">
      <pre className="bg-[#1e1e2e] rounded-xl p-4 border border-white/10 overflow-x-auto text-sm text-gray-300 font-mono">
        <code>{code}</code>
      </pre>
      <button
        onClick={handleCopy}
        className="absolute top-2 right-2 px-2 py-1 rounded bg-white/10 text-xs text-white/60 hover:text-white hover:bg-white/20 transition-all opacity-0 group-hover:opacity-100"
      >
        {copied ? "✓" : "copy"}
      </button>
    </div>
  );
}

export default function App() {
  return (
    <div className="min-h-screen bg-[#0f0f14] text-white">
      {/* Hero */}
      <section className="relative overflow-hidden">
        <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_50%_0%,rgba(59,130,246,0.1),transparent_60%)]" />
        <div className="max-w-5xl mx-auto px-6 pt-20 pb-16 relative">
          <div className="flex items-center gap-3 mb-6">
            <div className="w-10 h-10 rounded-xl bg-blue-500/20 flex items-center justify-center">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="text-blue-400">
                <path d="M9 18V5l12-2v13"/>
                <circle cx="6" cy="18" r="3"/>
                <circle cx="18" cy="16" r="3"/>
              </svg>
            </div>
            <div>
              <h1 className="text-2xl font-bold tracking-tight">Lofi Radio Minimal</h1>
              <p className="text-sm text-white/40">виджет для KDE Plasma 6</p>
            </div>
          </div>
          
          <p className="text-lg text-white/70 max-w-2xl mb-8">
            Минималистичный виджет lofi-радио для рабочего стола KDE Plasma 6. 
            Чистый дизайн без лишних элементов — только управление потоком, 
            название трека и громкость.
          </p>

          <div className="flex flex-wrap gap-3 mb-12">
            <span className="px-3 py-1 rounded-full bg-blue-500/10 border border-blue-500/20 text-blue-300 text-xs">KDE Plasma 6</span>
            <span className="px-3 py-1 rounded-full bg-green-500/10 border border-green-500/20 text-green-300 text-xs">Qt 6</span>
            <span className="px-3 py-1 rounded-full bg-purple-500/10 border border-purple-500/20 text-purple-300 text-xs">QML</span>
            <span className="px-3 py-1 rounded-full bg-yellow-500/10 border border-yellow-500/20 text-yellow-300 text-xs">MIT</span>
          </div>

          <DesktopPreview />
        </div>
      </section>

      {/* Features */}
      <section className="max-w-5xl mx-auto px-6 py-16">
        <h2 className="text-xl font-bold mb-8 text-white/90">Возможности</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {[
            { icon: "📻", title: "Прямой стрим", desc: "Воспроизведение потока с live.lofiradio.ru через QtMultimedia. Две станции: lofi hip hop (128 kbps) и lofi chill (96 kbps)." },
            { icon: "🎵", title: "Названия треков", desc: "Живое отображение текущего трека через helper-скрипт, который читает Icecast StreamTitle метаданные." },
            { icon: "🎨", title: "Минимализм", desc: "Чистый дизайн в стиле Plasma 6. Системные цвета Kirigami, без лишних градиентов и анимаций." },
            { icon: "📐", title: "Два режима", desc: "Полный виджет на рабочем столе (260×200) и компактная иконка на панели (34×34)." },
            { icon: "🔄", title: "Автопереподключение", desc: "Автоматическое восстановление соединения при обрыве потока." },
            { icon: "🔊", title: "Регулятор громкости", desc: "Встроенный слайдер громкости с визуальной индикацией уровня." },
          ].map((f, i) => (
            <div key={i} className="p-4 rounded-xl bg-white/[0.03] border border-white/[0.06] hover:border-white/10 transition-colors">
              <div className="text-2xl mb-2">{f.icon}</div>
              <h3 className="font-medium text-sm mb-1">{f.title}</h3>
              <p className="text-xs text-white/50 leading-relaxed">{f.desc}</p>
            </div>
          ))}
        </div>
      </section>

      {/* Comparison */}
      <section className="max-w-5xl mx-auto px-6 py-16">
        <h2 className="text-xl font-bold mb-8 text-white/90">Сравнение с оригиналом</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="p-5 rounded-xl bg-white/[0.03] border border-white/[0.06]">
            <h3 className="text-sm font-medium text-white/60 mb-3">plasma-lofi-radio (оригинал)</h3>
            <ul className="space-y-2 text-xs text-white/50">
              <li>• Виниловая пластинка с вращением</li>
              <li>• Тонарм с анимацией</li>
              <li>• Анимированный эквалайзер</li>
              <li>• Градиентный фон (фиолетовый)</li>
              <li>• Размер: 296×452 px</li>
              <li>• Сложные Canvas-рисунки</li>
            </ul>
          </div>
          <div className="p-5 rounded-xl bg-blue-500/[0.05] border border-blue-500/20">
            <h3 className="text-sm font-medium text-blue-300 mb-3">lofi-radio-minimal (этот)</h3>
            <ul className="space-y-2 text-xs text-white/70">
              <li className="flex items-center gap-2"><span className="text-green-400">✓</span> Без декоративных элементов</li>
              <li className="flex items-center gap-2"><span className="text-green-400">✓</span> Системные цвета Plasma</li>
              <li className="flex items-center gap-2"><span className="text-green-400">✓</span> Нативные Kirigami-компоненты</li>
              <li className="flex items-center gap-2"><span className="text-green-400">✓</span> Компактный: 260×200 px</li>
              <li className="flex items-center gap-2"><span className="text-green-400">✓</span> Бегущая строка трека</li>
              <li className="flex items-center gap-2"><span className="text-green-400">✓</span> Такой же helper для метаданных</li>
            </ul>
          </div>
        </div>
      </section>

      {/* Structure */}
      <section className="max-w-5xl mx-auto px-6 py-16">
        <h2 className="text-xl font-bold mb-8 text-white/90">Структура проекта</h2>
        <FileTree />
      </section>

      {/* Installation */}
      <section className="max-w-5xl mx-auto px-6 py-16">
        <h2 className="text-xl font-bold mb-8 text-white/90">Установка</h2>
        
        <div className="space-y-8">
          <div>
            <h3 className="text-sm font-medium text-white/70 mb-3">Требования</h3>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              {[
                ["KDE Plasma", "6.0+"],
                ["Qt", "6 с qt6-multimedia"],
                ["Kirigami", "QML-модуль (с plasma-workspace)"],
                ["Python", "3.8+ (только stdlib)"],
              ].map(([name, ver]) => (
                <div key={name} className="flex items-center justify-between p-3 rounded-lg bg-white/[0.03] border border-white/[0.06]">
                  <span className="text-sm text-white/80">{name}</span>
                  <span className="text-xs text-white/40">{ver}</span>
                </div>
              ))}
            </div>
          </div>

          <div>
            <h3 className="text-sm font-medium text-white/70 mb-3">Автоматическая установка</h3>
            <CodeBlock code={`git clone https://github.com/your-repo/plasma-lofi-minimal.git
cd plasma-lofi-minimal
chmod +x install.sh
./install.sh`} />
          </div>

          <div>
            <h3 className="text-sm font-medium text-white/70 mb-3">Ручная установка</h3>
            <CodeBlock code={`# Установка виджета
kpackagetool6 --type Plasma/Applet --install ./package

# Установка helper-скрипта
install -Dm755 helper/lofi-nowplaying.py ~/.local/share/lofi-minimal/lofi-nowplaying.py
install -Dm644 helper/lofi-nowplaying.service ~/.config/systemd/user/lofi-nowplaying.service
systemctl --user daemon-reload
systemctl --user enable --now lofi-nowplaying.service`} />
          </div>

          <div>
            <h3 className="text-sm font-medium text-white/70 mb-3">После установки</h3>
            <CodeBlock code={`# Добавить виджет:
# Правый клик по рабочему столу → «Добавить виджеты…» → «Lofi Radio Minimal»

# Если виджет не появился:
systemctl --user restart plasma-plasmashell.service

# Проверить helper:
curl http://127.0.0.1:8731/nowplaying.json`} />
          </div>

          <div>
            <h3 className="text-sm font-medium text-white/70 mb-3">Удаление</h3>
            <CodeBlock code={`./uninstall.sh`} />
          </div>
        </div>
      </section>

      {/* Troubleshooting */}
      <section className="max-w-5xl mx-auto px-6 py-16">
        <h2 className="text-xl font-bold mb-8 text-white/90">Решение проблем</h2>
        <div className="space-y-4">
          {[
            { q: "Нет названий треков, но музыка играет", a: "Helper-скрипт недоступен. Проверьте: systemctl --user status lofi-nowplaying и curl http://127.0.0.1:8731/nowplaying.json" },
            { q: "Ничего не воспроизводится", a: "Убедитесь, что установлен qt6-multimedia и бэкенд FFmpeg. Проверьте: journalctl --user -u plasma-plasmashell -f" },
            { q: "Виджет не виден в списке", a: "Выполните: kpackagetool6 --type Plasma/Applet --list | grep minimal. Если показывает — перезапустите plasmashell." },
          ].map((item, i) => (
            <details key={i} className="group rounded-xl bg-white/[0.03] border border-white/[0.06] overflow-hidden">
              <summary className="p-4 cursor-pointer text-sm font-medium text-white/80 hover:text-white transition-colors list-none flex items-center justify-between">
                {item.q}
                <svg className="w-4 h-4 text-white/40 group-open:rotate-180 transition-transform" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                  <path d="M6 9l6 6 6-6"/>
                </svg>
              </summary>
              <div className="px-4 pb-4 text-sm text-white/50">{item.a}</div>
            </details>
          ))}
        </div>
      </section>

      {/* Footer */}
      <footer className="max-w-5xl mx-auto px-6 py-12 border-t border-white/[0.06]">
        <div className="flex flex-col sm:flex-row items-center justify-between gap-4">
          <div className="text-sm text-white/30">
            Lofi Radio Minimal · MIT License · KDE Plasma 6
          </div>
          <div className="text-sm text-white/30">
            Поток: <a href="https://lofiradio.ru" className="text-blue-400/70 hover:text-blue-400 transition-colors">lofiradio.ru</a>
          </div>
        </div>
      </footer>
    </div>
  );
}
