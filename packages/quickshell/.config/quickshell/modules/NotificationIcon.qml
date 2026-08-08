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

        // O app_icon aceita caminho além de nome de tema.
        if (icon.startsWith("/") || icon.startsWith("file:"))
            return icon;

        // O marcador de ícone ausente do quickshell carrega como imagem válida,
        // então sem esta checagem o fallback abaixo nunca pegaria.
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

        // O app manda o ícone no tamanho que quiser, e isto é desenhado a 28 ou
        // 36px.
        sourceSize.width: root.size * 2
        sourceSize.height: root.size * 2
        asynchronous: true
    }
}
