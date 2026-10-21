import QtQuick 2.0
import QtQuick.Controls 2.5 as QQC2
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.4 as Kirigami

Kirigami.FormLayout {
    id: page

    property int currentVersion: 10100
    property string currentVersionString: "1.1.0"
    property string latestVersionString: ""
    property bool checking: false
    property bool updateAvailable: false
    property string statusMessage: ""

    QQC2.Label {
        Kirigami.FormData.label: i18n("Версия:")
        text: page.currentVersionString
    }

    QQC2.Button {
        Kirigami.FormData.label: i18n("Обновления:")
        text: page.checking ? i18n("Проверка...") : i18n("Проверить обновления")
        enabled: !page.checking
        onClicked: checkForUpdates()
    }

    QQC2.Label {
        visible: page.statusMessage.length > 0
        text: page.statusMessage
        color: page.updateAvailable ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.textColor
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
    }

    QQC2.Button {
        visible: page.updateAvailable
        text: i18n("Скачать обновление")
        onClicked: Qt.openUrlExternally("https://github.com/Caracoto4/plasma-lofi-radio-mini/releases/latest")
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

    function checkForUpdates() {
        page.checking = true;
        page.latestVersionString = "";
        page.updateAvailable = false;
        page.statusMessage = i18n("Проверка обновлений...");

        var xhr = new XMLHttpRequest();
        xhr.open("GET", "https://api.github.com/repos/Caracoto4/plasma-lofi-radio-mini/releases/latest", true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                page.checking = false;
                if (xhr.status === 200) {
                    try {
                        var data = JSON.parse(xhr.responseText);
                        var tagName = data.tag_name || "";
                        page.latestVersionString = tagName.replace(/^v/, "");
                        
                        var current = parseVersion(page.currentVersionString);
                        var latest = parseVersion(page.latestVersionString);
                        
                        if (latest > current) {
                            page.updateAvailable = true;
                            page.statusMessage = i18n("Доступна новая версия: %1", page.latestVersionString);
                        } else {
                            page.statusMessage = i18n("У вас установлена последняя версия");
                        }
                    } catch (e) {
                        page.statusMessage = i18n("Ошибка при проверке обновлений");
                        console.log("Failed to parse update info:", e);
                    }
                } else {
                    page.statusMessage = i18n("Не удалось проверить обновления (ошибка %1)", xhr.status);
                    console.log("Failed to check for updates, status:", xhr.status);
                }
            }
        };
        xhr.send();
    }

    function parseVersion(versionString) {
        var parts = versionString.split(".");
        if (parts.length < 3) return 0;
        return parseInt(parts[0]) * 10000 + parseInt(parts[1]) * 100 + parseInt(parts[2]);
    }
}
