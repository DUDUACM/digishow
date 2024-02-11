import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.0

import DigiShow 1.0

import "components"

Item {
    id: itemArtnet

    property bool forMedia: menuType.selectedItemValue === DigishowEnvironment.EndpointArtnetMedia

    COptionButton {
        id: buttonArtnetType
        width: 100
        height: 28
        anchors.left: parent.left
        anchors.top: parent.top
        text: menuType.selectedItemText
        onClicked: menuType.showOptions()

        COptionMenu {
            id: menuType

            onOptionSelected: refreshMoreOptions()
        }
    }

    COptionButton {
        id: buttonUnit
        width: 100
        height: 28
        anchors.left: buttonArtnetType.right
        anchors.leftMargin: 10
        anchors.top: parent.top
        text: qsTr("Universe") + " " + spinUnit.value
        visible: !forMedia
        onClicked: spinUnit.visible = true

        COptionSpinBox {
            id: spinUnit
        }
    }

    COptionButton {
        id: buttonChannel
        width: 100
        height: 28
        anchors.left: buttonUnit.right
        anchors.leftMargin: 10
        anchors.top: parent.top
        text: qsTr("Channel") + " " + spinChannel.value
        visible: !forMedia
        onClicked: spinChannel.visible = true

        COptionSpinBox {
            id: spinChannel
        }
    }

    COptionButton {
        id: buttonMediaControl
        width: 100
        height: 28
        anchors.left: buttonArtnetType.right
        anchors.leftMargin: 10
        anchors.top: parent.top
        text: menuMediaControl.selectedItemText
        visible: forMedia
        onClicked: menuMediaControl.showOptions()

        COptionMenu {
            id: menuMediaControl

            onOptionSelected: refreshMoreOptions()
        }
    }

    CButton {
        id: buttonMediaSelect
        width: 70
        height: 28
        anchors.left: buttonMediaControl.right
        anchors.leftMargin: 20
        anchors.top: parent.top
        label.font.bold: false
        label.font.pixelSize: 11
        label.text: qsTr("File ...")
        box.radius: 3
        visible: textMediaUrl.visible

        onClicked: {
            dialogSelectFile.setDefaultFileUrl(textMediaUrl.text)
            dialogSelectFile.open()
        }
    }

    CButton {
        id: buttonMediaOptions
        width: 70
        height: 28
        anchors.left: buttonMediaSelect.right
        anchors.leftMargin: 10
        anchors.top: parent.top
        label.font.bold: false
        label.font.pixelSize: 11
        label.text: qsTr("Options ...")
        box.radius: 3
        visible: textMediaUrl.visible &&
                 menuMediaControl.selectedItemValue === DigishowEnvironment.ControlMediaStart

        onClicked: popupMediaOptions.open()
    }

    CTextInputBox {

        id: textMediaUrl

        anchors.bottom: parent.top
        anchors.bottomMargin: 10
        anchors.left: buttonMediaSelect.left
        anchors.right: parent.right
        anchors.rightMargin: 38
        text: "file://"
        //input.anchors.rightMargin: 30
        visible: forMedia &&
                 menuMediaControl.selectedItemValue !== DigishowEnvironment.ControlMediaStopAll

        onTextEdited: isModified = true
        onEditingFinished: if (text === "") text = "file://"
    }

    MwFileDialog {
        id: dialogSelectFile
        title: qsTr("Select Video File")
        folder: shortcuts.home
        selectExisting: true
        nameFilters: [ qsTr("Video files") + " (*.avi *.mp4 *.mov)",
                       qsTr("Image files") + " (*.bmp *.png *.jpg)",
                       qsTr("Image Sequence") + " (*.ini)",
                       qsTr("All files") + " (*)" ]
        onAccepted: {
            console.log("select video file: ", fileUrl)
            textMediaUrl.text = fileUrl
            isModified = true
        }
    }

    Popup {
        id: popupMediaOptions

        width: 380
        height: 660
        x: 0
        y: -height-10
        transformOrigin: Popup.BottomRight
        modal: true
        focus: true

        //onVisibleChanged: if (!visible) isModified = true

        background: Rectangle {
            anchors.fill: parent
            color: "#333333"
            radius: 5
            border.width: 1
            border.color: "#999999"
        }

        // @disable-check M16
        Overlay.modal: Item {}

        Column {
            anchors.fill: parent
            anchors.leftMargin: 16
            spacing: 10

            Text {
                height: 30
                verticalAlignment: Text.AlignBottom
                color: "#cccccc"
                font.pixelSize: 12
                font.bold: true
                text: qsTr("Pixel Mapping")
            }

            COptionButton {
                id: buttonMediaPixelMode
                width: 85
                height: 28
                anchors.left: parent.left
                anchors.leftMargin: 145
                text: menuMediaPixelMode.selectedItemText
                focus: true
                onClicked: {
                    menuMediaPixelMode.showOptions()
                    isModified = true
                }

                COptionMenu {
                    id: menuMediaPixelMode

                    onOptionClicked: {
                    }
                }

                Text {
                    anchors.right: parent.left
                    anchors.rightMargin: 15
                    anchors.verticalCenter: parent.verticalCenter
                    color: "#cccccc"
                    font.pixelSize: 12
                    text: qsTr("Pixel Mode")
                }
            }

            Item {
                width: 180
                height: 28
                anchors.left: parent.left
                anchors.leftMargin: 145

                CSpinBox {
                    id: spinMediaPixelCountX

                    width: 85
                    anchors.left: parent.left
                    from: 1
                    to: 9999
                    value: 170
                    stepSize: 1

                    onValueModified: isModified = true
                }

                CSpinBox {
                    id: spinMediaPixelCountY

                    width: 85
                    anchors.right: parent.right
                    from: 1
                    to: 9999
                    value: 1
                    stepSize: 1

                    onValueModified: isModified = true
                }

                Text {
                    anchors.right: parent.left
                    anchors.rightMargin: 15
                    anchors.verticalCenter: parent.verticalCenter
                    color: "#cccccc"
                    font.pixelSize: 12
                    text: qsTr("Pixel Count X | Y")
                }

            }

            Item {
                width: 180
                height: 28
                anchors.left: parent.left
                anchors.leftMargin: 145

                CSpinBox {
                    id: spinMediaPixelOffsetX

                    width: 85
                    anchors.left: parent.left
                    from: 0
                    to: 9999
                    value: 0
                    stepSize: 1

                    onValueModified: isModified = true
                }

                CSpinBox {
                    id: spinMediaPixelOffsetY

                    width: 85
                    anchors.right: parent.right
                    from: 0
                    to: 9999
                    value: 0
                    stepSize: 1

                    onValueModified: isModified = true
                }

                Text {
                    anchors.right: parent.left
                    anchors.rightMargin: 15
                    anchors.verticalCenter: parent.verticalCenter
                    color: "#cccccc"
                    font.pixelSize: 12
                    text: qsTr("Pixel Offset X | Y")
                }
            }

            Item {
                width: 180
                height: 28
                anchors.left: parent.left
                anchors.leftMargin: 145

                CSpinBox {
                    id: spinMediaPixelSpacingX

                    width: 85
                    anchors.left: parent.left
                    from: 0
                    to: 9999
                    value: 0
                    stepSize: 1

                    onValueModified: isModified = true
                }

                CSpinBox {
                    id: spinMediaPixelSpacingY

                    width: 85
                    anchors.right: parent.right
                    from: 0
                    to: 9999
                    value: 0
                    stepSize: 1

                    onValueModified: isModified = true
                }

                Text {
                    anchors.right: parent.left
                    anchors.rightMargin: 15
                    anchors.verticalCenter: parent.verticalCenter
                    color: "#cccccc"
                    font.pixelSize: 12
                    text: qsTr("Pixel Spacing X | Y")
                }
            }

            Item {

                id: itemMediaMappingMode

                property int value: 0

                width: 180
                height: 28
                anchors.left: parent.left
                anchors.leftMargin: 145

                CButton {
                    property int value: DigishowPixelPlayer.MappingByRowL2R

                    width: 28
                    height: 28
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    anchors.verticalCenter: parent.verticalCenter
                    icon.width: 26
                    icon.height: 26
                    icon.source: "qrc:///images/icon_lines_l2r.png"
                    box.radius: 3
                    box.border.width: mouseOver || parent.value !== this.value ? 1 : 0
                    colorNormal: parent.value === this.value ? "#666666" : "transparent"
                    onClicked: {
                        parent.value = this.value
                        isModified = true
                    }
                }

                CButton {
                    property int value: DigishowPixelPlayer.MappingByRowR2L

                    width: 28
                    height: 28
                    anchors.left: parent.left
                    anchors.leftMargin: 40
                    anchors.verticalCenter: parent.verticalCenter
                    icon.width: 26
                    icon.height: 26
                    icon.source: "qrc:///images/icon_lines_r2l.png"
                    box.radius: 3
                    box.border.width: mouseOver || parent.value !== this.value ? 1 : 0
                    colorNormal: parent.value === this.value ? "#666666" : "transparent"
                    onClicked: {
                        parent.value = this.value
                        isModified = true
                    }
                }

                CButton {
                    property int value: DigishowPixelPlayer.MappingByRowL2Z

                    width: 28
                    height: 28
                    anchors.left: parent.left
                    anchors.leftMargin: 80
                    anchors.verticalCenter: parent.verticalCenter
                    icon.width: 26
                    icon.height: 26
                    icon.source: "qrc:///images/icon_lines_l2z.png"
                    box.radius: 3
                    box.border.width: mouseOver || parent.value !== this.value ? 1 : 0
                    colorNormal: parent.value === this.value ? "#666666" : "transparent"
                    onClicked: {
                        parent.value = this.value
                        isModified = true
                    }
                }

                CButton {
                    property int value: DigishowPixelPlayer.MappingByRowR2Z

                    width: 28
                    height: 28
                    anchors.left: parent.left
                    anchors.leftMargin: 120
                    anchors.verticalCenter: parent.verticalCenter
                    icon.width: 26
                    icon.height: 26
                    icon.source: "qrc:///images/icon_lines_r2z.png"
                    box.radius: 3
                    box.border.width: mouseOver || parent.value !== this.value ? 1 : 0
                    colorNormal: parent.value === this.value ? "#666666" : "transparent"
                    onClicked: {
                        parent.value = this.value
                        isModified = true
                    }
                }

                Text {
                    anchors.right: parent.left
                    anchors.rightMargin: 15
                    anchors.verticalCenter: parent.verticalCenter
                    color: "#cccccc"
                    font.pixelSize: 12
                    text: qsTr("Address Mapping")
                }
            }

            Item {
                width: 180
                height: 28
                anchors.left: parent.left
                anchors.leftMargin: 145

                CSpinBox {
                    id: spinMediaUnit

                    width: 85
                    anchors.left: parent.left
                    from: spinUnit.from
                    to: spinUnit.to
                    value: spinUnit.value
                    stepSize: spinUnit.stepSize

                    onValueModified: spinUnit.value = spinMediaUnit.value
                }

                CSpinBox {
                    id: spinMediaChannel

                    width: 85
                    anchors.right: parent.right
                    from: spinChannel.from
                    to: spinChannel.to
                    value: spinChannel.value
                    stepSize: spinChannel.stepSize

                    onValueModified: spinChannel.value = spinMediaChannel.value
                }

                Text {
                    anchors.right: parent.left
                    anchors.rightMargin: 15
                    anchors.verticalCenter: parent.verticalCenter
                    color: "#cccccc"
                    font.pixelSize: 12
                    text: qsTr("To Universe | Channel")
                }
            }

            Text {
                height: 30
                verticalAlignment: Text.AlignBottom
                color: "#cccccc"
                font.pixelSize: 12
                font.bold: true
                text: qsTr("Playback Options")
            }

            CheckBox {
                id: checkMediaAlone

                height: 28
                anchors.left: parent.left
                anchors.leftMargin: 145
                padding: 0
                checked: true

                onClicked: isModified = true

                Text {
                    anchors.right: parent.left
                    anchors.rightMargin: 15
                    anchors.verticalCenter: parent.verticalCenter
                    color: "#cccccc"
                    font.pixelSize: 12
                    text: qsTr("Play Alone")
                }
            }

            CSpinBox {
                id: spinMediaFadeIn

                width: 120
                anchors.left: parent.left
                anchors.leftMargin: 145
                from: 0
                to: 5000
                value: 300
                stepSize: 10
                unit: "ms"

                onValueModified: isModified = true

                Text {
                    anchors.right: parent.left
                    anchors.rightMargin: 15
                    anchors.verticalCenter: parent.verticalCenter
                    color: "#cccccc"
                    font.pixelSize: 12
                    text: qsTr("Fade In")
                }
            }

            CSpinBox {
                id: spinMediaVolume

                width: 120
                anchors.left: parent.left
                anchors.leftMargin: 145
                from: 0
                to: 100
                value: 100
                stepSize: 5
                unit: "%"

                onValueModified: isModified = true

                Text {
                    anchors.right: parent.left
                    anchors.rightMargin: 15
                    anchors.verticalCenter: parent.verticalCenter
                    color: "#cccccc"
                    font.pixelSize: 12
                    text: qsTr("Volume")
                }
            }

            CSpinBox {
                id: spinMediaSpeed

                width: 120
                anchors.left: parent.left
                anchors.leftMargin: 145
                from: 10
                to: 400
                value: 100
                stepSize: 5
                unit: qsTr("%")

                onValueModified: isModified = true

                Text {
                    anchors.right: parent.left
                    anchors.rightMargin: 15
                    anchors.verticalCenter: parent.verticalCenter
                    color: "#cccccc"
                    font.pixelSize: 12
                    text: qsTr("Speed")
                }
            }

            CSpinBox {
                id: spinMediaPosition

                width: 120
                anchors.left: parent.left
                anchors.leftMargin: 145
                from: 0
                to: 99999000
                value: 0
                stepSize: 1000
                unit: qsTr("ms")

                onValueModified: isModified = true

                Text {
                    anchors.right: parent.left
                    anchors.rightMargin: 15
                    anchors.verticalCenter: parent.verticalCenter
                    color: "#cccccc"
                    font.pixelSize: 12
                    text: qsTr("Position")
                }
            }

            CSpinBox {
                id: spinMediaDuration

                width: 120
                anchors.left: parent.left
                anchors.leftMargin: 145
                from: 0
                to: 99999999
                value: 0
                stepSize: 1000
                unit: qsTr("ms")

                onValueModified: isModified = true

                Text {
                    anchors.right: parent.left
                    anchors.rightMargin: 15
                    anchors.verticalCenter: parent.verticalCenter
                    color: "#cccccc"
                    font.pixelSize: 12
                    text: qsTr("Duration")
                }
            }

            CheckBox {
                id: checkMediaRepeat

                height: 28
                anchors.left: parent.left
                anchors.leftMargin: 145
                padding: 0
                checked: false

                onClicked: isModified = true

                Text {
                    anchors.right: parent.left
                    anchors.rightMargin: 15
                    anchors.verticalCenter: parent.verticalCenter
                    color: "#cccccc"
                    font.pixelSize: 12
                    text: qsTr("Repeat")
                }
            }

            Item {
                width: 5
                height: 5
            }

            CButton {
                width: 100
                height: 28
                anchors.left: parent.left
                anchors.leftMargin: 145
                label.font.bold: false
                label.font.pixelSize: 11
                label.text: qsTr("Defaults")
                box.radius: 3

                onClicked: {

                    spinUnit.value = 0
                    spinChannel.value = 1

                    setEndpointMediaOptions({})
                    isModified = true
                }
            }
        }
    }


    function refresh() {

        var items
        var n
        var v

        // init artnet universe option spinbox
        spinUnit.from = 0
        spinUnit.to = 32767
        spinUnit.visible = false

        // init artnet channel option spinbox
        spinChannel.from = 1
        spinChannel.to = 512
        spinChannel.visible = false

        // init artnet type option menu
        if (menuType.count === 0) {
            items = []
            items.push({ text: qsTr("Dimmer"       ), value: DigishowEnvironment.EndpointArtnetDimmer,  tag: "dimmer"   })
            items.push({ text: qsTr("Dimmer 16-bit"), value: DigishowEnvironment.EndpointArtnetDimmer2, tag: "dimmer2x" })

            if (forOutput)
            items.push({ text: qsTr("Pixels"       ), value: DigishowEnvironment.EndpointArtnetMedia,   tag: "media"    })

            menuType.optionItems = items
            menuType.selectedIndex = 0
        }

        // init media control option menu
        if (menuMediaControl.count === 0) {
            items = []

            v = DigishowEnvironment.ControlMediaStart;   items.push({ text: digishow.getMediaControlName(v), value: v })
            v = DigishowEnvironment.ControlMediaStop;    items.push({ text: digishow.getMediaControlName(v), value: v })
            v = DigishowEnvironment.ControlMediaStopAll; items.push({ text: digishow.getMediaControlName(v), value: v })

            menuMediaControl.optionItems = items
            menuMediaControl.selectedIndex = 0
        }

        // init media pixel mode option menu
        if (menuMediaPixelMode.count === 0) {
            items = []

            items.push({ text: qsTr("Mono"), value: 1,  tag: "mono" })
            items.push({ text: qsTr("RGB"),  value: 2,  tag: "rgb" })
            items.push({ text: qsTr("RBG"),  value: 3,  tag: "rbg" })
            items.push({ text: qsTr("GRB"),  value: 4,  tag: "grb" })
            items.push({ text: qsTr("GBR"),  value: 5,  tag: "gbr" })
            items.push({ text: qsTr("BRG"),  value: 6,  tag: "brg" })
            items.push({ text: qsTr("BGR"),  value: 7,  tag: "bgr" })

            menuMediaPixelMode.optionItems = items
            menuMediaPixelMode.selectedIndex = 1
        }

        // init more options
        refreshMoreOptions()
    }

    function refreshMoreOptions() {

        var endpointType = menuType.selectedItemValue
        var enables = {}

        if (endpointType === DigishowEnvironment.EndpointArtnetDimmer) {

            enables["optInitialDmx"] = true

        } else if (endpointType === DigishowEnvironment.EndpointArtnetDimmer2) {

            enables["optInitialA"] = true

        } else if (endpointType === DigishowEnvironment.EndpointArtnetMedia) {

            enables["optInitialB"] = true
        }

        popupMoreOptions.resetOptions()
        popupMoreOptions.enableOptions(enables)
        buttonMoreOptions.visible = (Object.keys(enables).length > 0)
    }

    function setEndpointMediaOptions(options) {

        var v
        v = options["mediaAlone"];    checkMediaAlone.checked  = (v === undefined ? true  : v )
        v = options["mediaFadeIn"];   spinMediaFadeIn.value    = (v === undefined ? 300   : v )
        v = options["mediaVolume"];   spinMediaVolume.value    = (v === undefined ? 100   : v / 100)
        v = options["mediaSpeed"];    spinMediaSpeed.value     = (v === undefined ? 100   : v / 100)
        v = options["mediaPosition"]; spinMediaPosition.value  = (v === undefined ? 0     : v )
        v = options["mediaDuration"]; spinMediaDuration.value  = (v === undefined ? 0     : v )
        v = options["mediaRepeat"];   checkMediaRepeat.checked = (v === undefined ? false : v )

        v = options["mediaPixelMode"];     menuMediaPixelMode.selectOptionWithTag(v === undefined ? "rgb" : v )
        v = options["mediaPixelCountX"];   spinMediaPixelCountX.value  = (v === undefined ? 170 : v )
        v = options["mediaPixelCountY"];   spinMediaPixelCountY.value  = (v === undefined ? 1 : v )
        v = options["mediaPixelOffsetX"];  spinMediaPixelOffsetX.value = (v === undefined ? 0 : v )
        v = options["mediaPixelOffsetY"];  spinMediaPixelOffsetY.value = (v === undefined ? 0 : v )
        v = options["mediaPixelSpacingX"]; spinMediaPixelSpacingX.value = (v === undefined ? 0 : v )
        v = options["mediaPixelSpacingY"]; spinMediaPixelSpacingY.value = (v === undefined ? 0 : v )
        v = options["mediaMappingMode"];   itemMediaMappingMode.value = (v === undefined ? 0 : v )
    }

    function getEndpointMediaOptions() {

        var options = {
            mediaAlone:    checkMediaAlone.checked,
            mediaFadeIn:   spinMediaFadeIn.value,
            mediaVolume:   spinMediaVolume.value * 100,
            mediaSpeed:    spinMediaSpeed.value * 100,
            mediaPosition: spinMediaPosition.value,
            mediaDuration: spinMediaDuration.value,
            mediaRepeat:   checkMediaRepeat.checked,

            mediaPixelMode:     menuMediaPixelMode.selectedItemTag,
            mediaPixelCountX:   spinMediaPixelCountX.value,
            mediaPixelCountY:   spinMediaPixelCountY.value,
            mediaPixelOffsetX:  spinMediaPixelOffsetX.value,
            mediaPixelOffsetY:  spinMediaPixelOffsetY.value,
            mediaPixelSpacingX: spinMediaPixelSpacingX.value,
            mediaPixelSpacingY: spinMediaPixelSpacingY.value,
            mediaMappingMode:   itemMediaMappingMode.value
        }

        return options
    }

    function setEndpointOptions(endpointInfo, endpointOptions) {

        menuType.selectOption(endpointInfo["type"])
        spinUnit.value = endpointInfo["unit"]
        spinChannel.value = endpointInfo["channel"] + 1

        switch (endpointInfo["type"]) {
        case DigishowEnvironment.EndpointArtnetMedia:
            menuMediaControl.selectOption(endpointInfo["control"])

            var mediaName = endpointOptions["media"]
            var mediaIndex = digishow.findMediaWithName(interfaceIndex, mediaName)
            var mediaOptions = digishow.getMediaOptions(interfaceIndex, mediaIndex)
            var mediaUrl = "file://"
            if (mediaOptions["url"] !== undefined) mediaUrl = mediaOptions["url"]
            textMediaUrl.text = mediaUrl

            setEndpointMediaOptions(endpointOptions)

            break
        }
    }

    function getEndpointOptions() {

        var options = {}
        options["type"] = menuType.selectedItemTag
        options["unit"] = spinUnit.value
        options["channel"] = spinChannel.value - 1

        switch (menuType.selectedItemValue) {
        case DigishowEnvironment.EndpointArtnetMedia:
            options["control"] = menuMediaControl.selectedItemValue

            if (textMediaUrl.visible) {
                var interfaceIndex = menuInterface.selectedItemValue
                var mediaUrl = textMediaUrl.text
                var mediaType = digishow.getMediaType(mediaUrl)
                var mediaIndex = digishow.makeMedia(interfaceIndex, mediaUrl, mediaType)

                if (mediaIndex !== -1) {
                    options["media"] = digishow.getMediaName(interfaceIndex, mediaIndex)
                    if (menuMediaControl.selectedItemValue === DigishowEnvironment.ControlMediaStart)
                        options = utilities.merge(options, getEndpointMediaOptions())
                } else {
                    messageBox.show(qsTr("Please select a video clip file exists on your computer disks or enter a valid url of the video clip."), qsTr("OK"))
                }
            }
            break
        }

        return options
    }
}

