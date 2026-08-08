pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "."

Item {
    id: root

    required property var notification
    property int size: 36

    readonly property string source: {
        if (!root.notification)
            return "";
        if (root.notification.image !== "")
            return root.notification.image;

        const icon = root.notification.appIcon;
        if (icon === "")
            return "";

        // O app_icon aceita caminho além de nome de tema, e o rofi-script manda
        // o arquivo do wallpaper assim.
        if (icon.startsWith("/") || icon.startsWith("file:"))
            return icon;

        // Sem a checagem explícita, nome que o tema não tem devolve o marcador de
        // ícone ausente do quickshell, um xadrez magenta. Ele carrega como imagem
        // válida e fica Ready, então o fallback abaixo nunca pegaria.
        return Quickshell.hasThemeIcon(icon) ? Quickshell.iconPath(icon) : "";
    }

    implicitWidth: root.size
    implicitHeight: root.size

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: Theme.surface
        visible: icon.status !== Image.Ready

        Text {
            anchors.centerIn: parent
            text: {
                const name = root.notification ? root.notification.appName : "";
                return name !== "" ? name.charAt(0).toUpperCase() : "󰂚";
            }
            color: Theme.cyan
            font.family: "Hack Nerd Font"
            font.pixelSize: Math.round(root.size * 0.45)
            font.weight: Font.Bold
        }
    }

    Image {
        id: icon
        anchors.fill: parent
        source: root.source
        fillMode: Image.PreserveAspectFit
        mipmap: true
        visible: status === Image.Ready
    }
}
