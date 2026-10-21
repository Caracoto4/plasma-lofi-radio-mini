import QtQuick 2.0
import QtQuick.Controls 2.5 as QQC2
import QtQuick.Layouts 1.0
import org.kde.plasma.plasmoid 2.0
import org.kde.kirigami 2.4 as Kirigami

Kirigami.FormLayout {
    id: page

    property string currentVersion: Plasmoid.metaData.version
    property bool updating: false
    property bool showError: false
    property string statusMessage: ""

    // --- Проверка обновлений -----------------------------------------------
    property string remoteVersion: ""
    property bool checking: false
    property bool hasUpdate: false

    // --- Основные настройки ---------------------------------------------

    QQC2.CheckBox {
        Kirigami.FormData.label: i18n("Воспроизведение:")
        text: i18n("Автозапуск при входе в систему")
        checked: Plasmoid.configuration.autoplay
        onToggled: Plasmoid.configuration.autoplay = checked
    }

    QQC2.CheckBox {
        Kirigami.FormData.label: i18n("Уведомления:")
        text: i18n("Показывать уведомление при смене трека")
        checked: Plasmoid.configuration.notifications
        onToggled: Plasmoid.configuration.notifications = checked
    }

    Item {
        Kirigami.FormData.isSection: true
    }

    // --- Обновление -------------------------------------------------------

    QQC2.Label {
        Kirigami.FormData.label: i18n("Версия:")
        text: page.currentVersion
    }

    // Кнопка проверки обновления
    QQC2.Button {
        Kirigami.FormData.label: i18n("Обновления:")
        text: page.checking ? i18n("Проверка...") : i18n("Проверить обновление")
        enabled: !page.checking && !page.updating
        onClicked: checkForUpdate()
    }

    // Кнопка установки обновления (появляется только при наличии новой версии)
    QQC2.Button {
        visible: page.hasUpdate && !page.updating
        Kirigami.FormData.label: i18n("Обновление:")
        text: i18n("Установить %1").arg(page.remoteVersion)
        onClicked: runUpdate()
    }

    QQC2.Label {
        visible: page.statusMessage.length > 0
        text: page.statusMessage
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
        color: page.showError ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.positiveTextColor
    }

    Item {
        Kirigami.FormData.isSection: true
    }

    QQC2.Label {
        text: i18n("Минималистичный виджет lofi-радио для KDE Plasma 6")
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
    }

    QQC2.Label {
        text: i18n('Поток: <a href="https://lofiradio.ru">lofiradio.ru</a>')
        onLinkActivated: Qt.openUrlExternally(link)
    }

    QQC2.Label {
        text: i18n('Репозиторий: <a href="https://github.com/Caracoto4/plasma-lofi-radio-mini">GitHub</a>')
        onLinkActivated: Qt.openUrlExternally(link)
    }

    function setStatus(message, isError) {
        page.statusMessage = message;
        page.showError = isError === true;
    }

    function compareVersions(a, b) {
        // Сравниваем версии "X.Y.Z" лексикографически по частям
        var partsA = String(a).split(".").map(Number);
        var partsB = String(b).split(".").map(Number);
        var len = Math.max(partsA.length, partsB.length);
        for (var i = 0; i < len; i++) {
            var va = i < partsA.length ? partsA[i] : 0;
            var vb = i < partsB.length ? partsB[i] : 0;
            if (va > vb) return 1;
            if (va < vb) return -1;
        }
        return 0;
    }

    function checkForUpdate() {
        page.checking = true;
        page.hasUpdate = false;
        setStatus(i18n("Проверка обновлений..."), false);

        var xhr = new XMLHttpRequest();
        xhr.open("GET", "https://raw.githubusercontent.com/Caracoto4/plasma-lofi-radio-mini/refs/heads/main/package/metadata.json", true);
        xhr.timeout = 10000;

        xhr.onreadystatechange = function () {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return;

            if (xhr.status === 200) {
                try {
                    var data = JSON.parse(xhr.responseText);
                    page.remoteVersion = data.KPlugin ? String(data.KPlugin.Version) : "";
                    page.checking = false;

                    if (page.remoteVersion.length > 0) {
                        var cmp = compareVersions(page.remoteVersion, page.currentVersion);
                        if (cmp > 0) {
                            page.hasUpdate = true;
                            setStatus(i18n("Доступна версия %1 (у вас %2). Нажмите «Установить» для обновления.")
                                      .arg(page.remoteVersion).arg(page.currentVersion), false);
                        } else if (cmp === 0) {
                            page.hasUpdate = false;
                            setStatus(i18n("У вас последняя версия %1.").arg(page.currentVersion), false);
                        } else {
                            page.hasUpdate = false;
                            setStatus(i18n("У вас версия новее, чем на GitHub (%1 > %2).").arg(page.currentVersion).arg(page.remoteVersion), false);
                        }
                    } else {
                        setStatus(i18n("Не удалось получить версию из metadata.json"), true);
                    }
                } catch (e) {
                    page.checking = false;
                    setStatus(i18n("Ошибка разбора ответа: %1").arg(e.message), true);
                }
            } else if (xhr.status === 404) {
                page.checking = false;
                setStatus(i18n("Файл metadata.json не найден на GitHub. Проверьте ссылку."), true);
            } else {
                page.checking = false;
                setStatus(i18n("Ошибка проверки (код %1).").arg(xhr.status), true);
            }
        };

        xhr.onerror = function () {
            page.checking = false;
            setStatus(i18n("Не удалось подключиться к GitHub. Проверьте интернет."), true);
        };

        xhr.ontimeout = function () {
            page.checking = false;
            setStatus(i18n("Превышено время ожидания ответа от GitHub."), true);
        };

        xhr.send();
    }

    // Фактический порт helper-сервиса виджет запоминает из ответа
    // /nowplaying.json (main.qml пишет его в конфиг). Если порт неизвестен —
    // пробуем 8731 и резервные 8732/8733 по очереди.
    property int knownHelperPort: Plasmoid.configuration.helperPort > 0
                                  ? Plasmoid.configuration.helperPort : 0

    function updateEndpoints() {
        if (knownHelperPort > 0)
            return ["http://127.0.0.1:" + knownHelperPort + "/update"];
        return ["http://127.0.0.1:8731/update",
                "http://127.0.0.1:8732/update",
                "http://127.0.0.1:8733/update"];
    }

    function runUpdate() {
        page.updating = true;
        setStatus(i18n("Запуск update.sh... Это может занять несколько минут."), false);
        tryUpdate(0);
    }

    function tryUpdate(index) {
        var endpoints = updateEndpoints();
        if (index >= endpoints.length) {
            page.updating = false;
            setStatus(i18n("Не удалось подключиться к helper-скрипту. Убедитесь что сервис запущен:\n"
                           + "systemctl --user status lofi-nowplaying"), true);
            return;
        }

        var xhr = new XMLHttpRequest();
        xhr.open("POST", endpoints[index], true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.timeout = 200000; // 200 секунд

        xhr.onreadystatechange = function () {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return;
            page.updating = false;

            if (xhr.status === 200) {
                // helper отвечает JSON'ом; если ответ не разобран —
                // считаем обновление успешным по коду 200
                try {
                    var response = JSON.parse(xhr.responseText);
                    if (response.status === "ok") {
                        setStatus(i18n("Обновление установлено! Plasma перезапускается..."), false);
                    } else {
                        setStatus(i18n("Ошибка установки обновления: %1")
                                  .arg(response.message || i18n("неизвестная ошибка")), true);
                    }
                } catch (e) {
                    setStatus(i18n("Обновление установлено! Plasma перезапускается..."), false);
                }
            } else if (xhr.status === 409) {
                // обновление уже запускается другим запросом
                setStatus(i18n("Обновление уже выполняется, подождите."), false);
            } else if (xhr.status >= 500 || xhr.status === 0) {
                // порт не отвечает или helper вернул ошибку сервера — пробуем следующий
                tryUpdate(index + 1);
            } else {
                setStatus(i18n("Ошибка запуска update.sh (код %1).\n"
                               + "Можно обновить вручную: git clone свежей копией репозитория\n"
                               + "запустите ./install.sh").arg(xhr.status), true);
            }
        };

        xhr.onerror = function () {
            tryUpdate(index + 1);
        };

        xhr.ontimeout = function () {
            page.updating = false;
            setStatus(i18n("Превышено время ожидания ответа от helper-скрипта."), true);
        };

        xhr.send(JSON.stringify({}));
    }
}
