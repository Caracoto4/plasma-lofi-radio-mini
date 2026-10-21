import QtQuick 2.0
import QtQuick.Controls 2.5 as QQC2
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.4 as Kirigami

Kirigami.FormLayout {
    id: page

    property string currentVersion: "1.3.3"
    property string currentCommitDate: "2026-01-26T00:00:00Z"
    property string latestCommitDate: ""
    property string latestCommitMessage: ""
    property string latestCommitSha: ""
    property bool checking: false
    property bool updateAvailable: false
    property string statusMessage: ""

    QQC2.Label {
        Kirigami.FormData.label: i18n("Версия:")
        text: page.currentVersion
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

    // Кнопка установки обновления
    QQC2.Button {
        visible: page.updateAvailable
        text: i18n("Установить обновление")
        icon.name: "download"
        onClicked: installUpdate()
        Layout.fillWidth: true
    }

    // Блок с командами для обновления (альтернативный способ)
    ColumnLayout {
        visible: page.updateAvailable
        spacing: Kirigami.Units.smallSpacing
        Layout.fillWidth: true

        QQC2.Label {
            text: i18n("Или выполните вручную:")
            opacity: 0.7
            font.italic: true
        }

        QQC2.Label {
            text: "cd ~/plasma-lofi-radio-mini && git pull && ./update.sh"
            font.family: "monospace"
            font.pixelSize: theme.defaultFont.pointSize - 1
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            background: Rectangle {
                color: Kirigami.Theme.backgroundColor
                radius: 4
            }
            padding: Kirigami.Units.smallSpacing
        }
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
        page.updateAvailable = false;
        page.statusMessage = i18n("Проверка обновлений...");

        var xhr = new XMLHttpRequest();
        xhr.open("GET", "https://api.github.com/repos/Caracoto4/plasma-lofi-radio-mini/commits?sha=main&per_page=1", true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                page.checking = false;
                if (xhr.status === 200) {
                    try {
                        var data = JSON.parse(xhr.responseText);
                        if (data.length > 0) {
                            var commit = data[0];
                            page.latestCommitSha = commit.sha.substring(0, 7);
                            page.latestCommitDate = commit.commit.committer.date;
                            page.latestCommitMessage = commit.commit.message.split("\n")[0];
                            
                            // Сравниваем по дате последнего коммита
                            var latestDate = new Date(page.latestCommitDate);
                            var currentDate = new Date(page.currentCommitDate);
                            
                            if (page.currentCommitDate === "" || latestDate > currentDate) {
                                page.updateAvailable = true;
                                page.statusMessage = i18n("Доступно обновление! Последний коммит: %1 (%2)").arg(page.latestCommitMessage).arg(page.latestCommitSha);
                            } else {
                                page.statusMessage = i18n("У вас установлена последняя версия");
                            }
                        } else {
                            page.statusMessage = i18n("Не удалось получить информацию о коммитах");
                        }
                    } catch (e) {
                        page.statusMessage = i18n("Ошибка при проверке обновлений");
                        console.log("Failed to parse update info:", e);
                    }
                } else {
                    page.statusMessage = i18n("Не удалось проверить обновления (ошибка %1)").arg(xhr.status);
                    console.log("Failed to check for updates, status:", xhr.status);
                }
            }
        };
        xhr.send();
    }

    function installUpdate() {
        page.statusMessage = i18n("Установка обновления... Это может занять несколько минут.");
        page.updateAvailable = false;
        
        var xhr = new XMLHttpRequest();
        xhr.open("POST", "http://127.0.0.1:8731/update", true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.timeout = 200000; // 200 секунд
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        if (response.status === "ok") {
                            page.statusMessage = i18n("Обновление установлено! Plasma перезапускается...");
                        } else {
                            page.statusMessage = i18n("Ошибка установки обновления: %1").arg(response.message || "неизвестная ошибка");
                            page.updateAvailable = true;
                        }
                    } catch (e) {
                        page.statusMessage = i18n("Обновление установлено! Plasma перезапускается...");
                    }
                } else {
                    page.statusMessage = i18n("Ошибка установки обновления (код %1). Попробуйте вручную:\ncd ~/plasma-lofi-radio-mini && git pull && ./update.sh").arg(xhr.status);
                    page.updateAvailable = true;
                    console.log("Update failed:", xhr.status, xhr.responseText);
                }
            }
        };
        
        xhr.onerror = function() {
            page.statusMessage = i18n("Не удалось подключиться к helper-скрипту. Убедитесь что сервис запущен:\nsystemctl --user status lofi-nowplaying");
            page.updateAvailable = true;
        };
        
        xhr.ontimeout = function() {
            page.statusMessage = i18n("Превышено время ожидания обновления. Попробуйте вручную:\ncd ~/plasma-lofi-radio-mini && git pull && ./update.sh");
            page.updateAvailable = true;
        };
        
        xhr.send(JSON.stringify({}));
    }
}
