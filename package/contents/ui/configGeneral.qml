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

    // Кнопка проверки обновления: запускает update.sh через helper-скрипт
    QQC2.Button {
        Kirigami.FormData.label: i18n("Обновления:")
        text: page.updating ? i18n("Установка...") : i18n("Проверить обновление")
        enabled: !page.updating
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

    function runUpdate() {
        page.updating = true;
        setStatus(i18n("Запуск update.sh... Это может занять несколько минут."), false);

        var xhr = new XMLHttpRequest();
        xhr.open("POST", "http://127.0.0.1:8731/update", true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.timeout = 200000; // 200 секунд

        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return;
            page.updating = false;

            if (xhr.status === 200) {
                // helper отвечает JSON'ом; если его нет или ответ не разобран —
                // считаем обновление успешным только по коду 200
                try {
                    var response = JSON.parse(xhr.responseText);
                    if (response.status === "ok") {
                        setStatus(i18n("Обновление установлено! Plasma перезапускается..."), false);
                    } else {
                        setStatus(i18n("Ошибка установки обновления: %1").arg(response.message || i18n("неизвестная ошибка")), true);
                    }
                } catch (e) {
                    setStatus(i18n("Обновление установлено! Plasma перезапускается..."), false);
                }
            } else {
                setStatus(i18n("Ошибка запуска update.sh (код %1). Попробуйте вручную:\ncd ~/plasma-lofi-radio-mini && ./update.sh").arg(xhr.status), true);
            }
        };

        xhr.onerror = function() {
            page.updating = false;
            setStatus(i18n("Не удалось подключиться к helper-скрипту. Убедитесь что сервис запущен:\nsystemctl --user status lofi-nowplaying"), true);
        };

        xhr.ontimeout = function() {
            page.updating = false;
            setStatus(i18n("Превышено время ожидания. Попробуйте вручную:\ncd ~/plasma-lofi-radio-mini && ./update.sh"), true);
        };

        xhr.send(JSON.stringify({}));
    }
}
