import QtQuick 2.12
import QtQuick.Controls 2.12
 
import DigiShow 1.0

import "components"

Item {
    id: itemOsc

    CTextInputBox {
        id: textAddress
        anchors.bottom: parent.top
        anchors.bottomMargin: 10
        anchors.left: buttonType.right
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 38
        text: "/osc/address"
        onTextEdited: isModified = true
        onEditingFinished: if (text === "") text = "/osc/address"
    }

    COptionButton {
        id: buttonChannel
        width: 70
        height: 28
        anchors.left: parent.left
        anchors.top: parent.top
        text: qsTr("Value") + " " + spinChannel.value
        onClicked: spinChannel.visible = true

        COptionSpinBox {
            id: spinChannel
        }
    }

    COptionButton {
        id: buttonType
        width: 130
        height: 28
        anchors.left: buttonChannel.right
        anchors.leftMargin: 10
        anchors.top: parent.top
        text: menuType.selectedItemText
        onClicked: menuType.showOptions()

        COptionMenu {
            id: menuType
            onOptionSelected: refreshMoreOptions()
        }
    }

    function refresh() {

        var items
        var n

        // init osc channel option spinbox
        spinChannel.from = 1
        spinChannel.to = 999
        spinChannel.visible = false

        // init osc type option menu
        if (menuType.count === 0) {
            items = []
            items.push({ text: qsTr("Integer"),                   value: DigishowEnvironment.EndpointOscInt,   tag:"int"  })
            items.push({ text: qsTr("Float") + " ( 0 ~ 1.0000 )", value: DigishowEnvironment.EndpointOscFloat, tag:"float"})
            items.push({ text: qsTr("Boolean"),                   value: DigishowEnvironment.EndpointOscBool,  tag:"bool" })
            menuType.optionItems = items
            menuType.selectedIndex = 1
        }

        // init more options
        refreshMoreOptions()
    }

    function refreshMoreOptions() {

        var endpointType = menuType.selectedItemValue
        var enables = {}

        if (endpointType === DigishowEnvironment.EndpointOscInt) {

            enables["optInitialA"] = true
            enables["optRangeInt"] = true

        } else if (endpointType === DigishowEnvironment.EndpointOscFloat) {

            enables["optInitialA"] = true

        } else if (endpointType === DigishowEnvironment.EndpointOscBool) {

            enables["optInitialB"] = true
        }


        moreOptions.resetOptions()
        moreOptions.enableOptions(enables)
        buttonMoreOptions.visible = (Object.keys(enables).length > 0)
    }

    function setEndpointOptions(endpointInfo, endpointOptions) {

        spinChannel.value = endpointInfo["channel"] + 1
        menuType.selectOption(endpointInfo["type"])

        var oscAddress = endpointInfo["address"]
        if (oscAddress === undefined || oscAddress === "") oscAddress = "/osc/address"
        textAddress.text = oscAddress
    }

    function getEndpointOptions() {

        var options = {}
        options["channel"] = spinChannel.value - 1
        options["type"] = menuType.selectedItemTag
        options["address"] = textAddress.text.trim()

        return options
    }

    function learn(rawData) {

        textAddress.text = rawData["address"]

        var numValues = rawData["values"].length
        if (numValues > 0) {

            var typeTag = rawData["values"][numValues-1]["tag"]
            var typeName
            if      (typeTag === "i") typeName = "int"
            else if (typeTag === "f") typeName = "float"
            else if (typeTag === "T" ||
                     typeTag === "F") typeName = "bool"

            spinChannel.value = numValues
            menuType.selectOptionWithTag(typeName)
        }

    }
}
