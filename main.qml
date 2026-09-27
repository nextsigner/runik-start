import QtQuick
import QtQuick.Controls
import QtCore

Window {
    id: app
    width: 640
    height: 480
    visible: true
    title: "Runik-Start"
    color: apps.backgroundColor
    property int fs: width*0.035
    property var uAppsList: []
    Settings{
        id: apps
        property color backgroundColor: 'black'
        property color fontColor: 'white'
        property string uIdApp: ''
    }
    Rectangle{
        id: xApp
        color: 'transparent'
        anchors.fill: parent
        Column{
            spacing: app.fs*0.5
            anchors.centerIn: parent
            Text{
                id: labelAppId
                text: "RUNIK-START"
                font.pixelSize: app.fs
                color: apps.fontColor
            }
            Item{width: 1; height: app.fs*2}
            Text{
                id: labelAppId
                text: "App ID:"
                font.pixelSize: app.fs
                color: apps.fontColor
            }
            TextInput{
                id: tiAppId
                width: app.width-app.fs
                height: app.fs*1.2
                font.pixelSize: app.fs
                color: apps.fontColor
                Rectangle{
                    width: parent.width+app.fs*0.1
                    height: parent.height+app.fs*0.1
                    color: 'transparent'
                    border.width: 1
                    border.color: apps.fontColor
                    anchors.centerIn: parent
                }
            }
            Button{
                text: "Cargar"
                font.pixelSize: app.fs
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    for(var i=0;i<app.uAppsList.length;i++){
                        let linea=app.uAppsList[i]
                        if(linea.length>3){
                            let args=linea.split(' ')
                            if(args[0]===tiAppId.text){
                                statusText.text=getGitHubZipUrl(args[2])
                            }
                        }
                    }

                }
            }
            Text{
                id: statusText
                text: "App ID:"
                font.pixelSize: app.fs
                color: apps.fontColor
            }

        }
    }

    // Component.onCompleted: {
    //     getAppsList()
    // }

    Component.onCompleted: {
        // Retardamos la llamada 1.5 segundos
        timer.restart()
    }

    Timer {
        id: timer
        interval: 5000
        repeat: false
        onTriggered: getAppsList()
    }

    Shortcut{
        sequence: 'Esc'
        onActivated: Qt.quit()
    }

    function getAppsList(){
        let d = new Date(Date.now())
        var targetUrl='https://raw.githubusercontent.com/nextsigner/nextsigner.github.io/main/runik/apps.txt?r='+d.getTime()

        statusText.text = "Cargando...";

        // Llamada a la función JS
        fetchAppsList(targetUrl, function(success, data) {
            if (success) {
                //textArea.text = data;
                statusText.text = "¡Archivo cargado con éxito!";
                statusText.text+='\n'+data
                app.uAppsList=data.split('\n')
            } else {
                statusText.text = data; // Muestra el mensaje de error
            }
        });
    }


    function fetchAppsList(url, callback) {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", url);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    // Éxito: pasamos el texto al callback
                    callback(true, xhr.responseText);
                } else {
                    // Error en la petición (ej. 404, 500)
                    callback(false, "Error al cargar el archivo. Código: " + xhr.status);
                }
            }
        }
        xhr.send();
    }
    function getGitHubZipUrl(repoUrl) {
        if (!repoUrl || typeof repoUrl !== "string") {
            return "";
        }

        // Limpiamos espacios y removemos una barra diagonal al final si existe
        let cleanUrl = repoUrl.trim();
        if (cleanUrl.endsWith("/")) {
            cleanUrl = cleanUrl.slice(0, -1);
        }

        // Si la URL ya termina en .git, se lo removemos
        if (cleanUrl.endsWith(".git")) {
            cleanUrl = cleanUrl.slice(0, -4);
        }

        // Verificamos si es una URL válida de GitHub (ej: https://github.com/usuario/repositorio)
        const regex = /^https?:\/\/github\.com\/([^\/]+)\/([^\/]+)$/i;
        const match = cleanUrl.match(regex);

        if (match) {
            const owner = match[1];
            const repo = match[2];
            // Retorna la URL estándar del zip de la rama principal (main)
            return "https://github.com/" + owner + "/" + repo + "/archive/refs/heads/main.zip";
        }

        // Si la URL ya es más específica (ej. incluye /tree/main o /blob/main), la adaptamos
        // O si no coincide con el formato básico, devolvemos cadena vacía o intentamos parsear
        return "";
    }
}
