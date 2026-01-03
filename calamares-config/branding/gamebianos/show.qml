// config/includes.chroot/usr/share/calamares/branding/gamebianos/show.qml
import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

Item {
    width: 800
    height: 440
    
    Rectangle {
        anchors.fill: parent
        color: "#1a1a1a"
        
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#1a1a1a" }
            GradientStop { position: 1.0; color: "#2d2d2d" }
        }
        
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 25
            
            // Logo
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 120
                height: 120
                radius: 60
                color: "#00ff00"
                
                Text {
                    anchors.centerIn: parent
                    text: "🎮"
                    font.pixelSize: 64
                }
            }
            
            // Title
            Text {
                text: "GamebianOS Gaming Edition"
                color: "#ffffff"
                font.pixelSize: 28
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }
            
            // Subtitle
            Text {
                text: "Steam-First Gaming System"
                color: "#00ff00"
                font.pixelSize: 18
                Layout.alignment: Qt.AlignHCenter
            }
            
            // Progress bar
            ProgressBar {
                id: progressBar
                Layout.preferredWidth: 400
                Layout.alignment: Qt.AlignHCenter
                value: calamares.slideshowProgress
                visible: calamares.slideshowProgress > 0
                
                background: Rectangle {
                    implicitWidth: 400
                    implicitHeight: 6
                    color: "#3a3a3a"
                    radius: 3
                }
                
                contentItem: Item {
                    implicitWidth: 400
                    implicitHeight: 6
                    
                    Rectangle {
                        width: progressBar.visualPosition * parent.width
                        height: parent.height
                        radius: 3
                        color: "#00ff00"
                    }
                }
            }
            
            // Status message
            Text {
                id: statusText
                color: "#cccccc"
                font.pixelSize: 14
                Layout.alignment: Qt.AlignHCenter
                
                text: {
                    var progress = calamares.slideshowProgress
                    if (progress < 0.2) return "Partitioning disk..."
                    else if (progress < 0.4) return "Installing system..."
                    else if (progress < 0.6) return "Setting up gaming environment..."
                    else if (progress < 0.8) return "Configuring Steam..."
                    else return "Finalizing installation..."
                }
            }
            
            // Features list
            ColumnLayout {
                spacing: 8
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 20
                
                Row {
                    spacing: 10
                    Image {
                        source: "qrc:/images/check.svg"
                        sourceSize.width: 16
                        sourceSize.height: 16
                    }
                    Text {
                        text: "Steam Big Picture autostart"
                        color: "#00ff00"
                        font.pixelSize: 12
                    }
                }
                
                Row {
                    spacing: 10
                    Image {
                        source: "qrc:/images/check.svg"
                        sourceSize.width: 16
                        sourceSize.height: 16
                    }
                    Text {
                        text: "MangoHud & Gamemode pre-configured"
                        color: "#00ff00"
                        font.pixelSize: 12
                    }
                }
                
                Row {
                    spacing: 10
                    Image {
                        source: "qrc:/images/check.svg"
                        sourceSize.width: 16
                        sourceSize.height: 16
                    }
                    Text {
                        text: "LXQt desktop with Ctrl+Alt+D shortcut"
                        color: "#00ff00"
                        font.pixelSize: 12
                    }
                }
                
                Row {
                    spacing: 10
                    Image {
                        source: "qrc:/images/check.svg"
                        sourceSize.width: 16
                        sourceSize.height: 16
                    }
                    Text {
                        text: "NVIDIA/AMD graphics drivers included"
                        color: "#00ff00"
                        font.pixelSize: 12
                    }
                }
            }
        }
    }
}
