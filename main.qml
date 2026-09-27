import QtQuick
import QtQuick.Controls
import QtCore
import unik.Unik 1.0
Window {
    id: app
    width: 640
    height: 480
    visible: true
    title: !isRunikStart?"Runik":"Runik!"
    color: apps.backgroundColor
    property int fs: width*0.035
    property var uAppsList: []
    property bool isRunikStart: true
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
                text: "Ingresar nombre, url o código de la aplicación:"
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
                    width: parent.width+app.fs*0.5
                    height: parent.height+app.fs*0.5
                    color: 'transparent'
                    border.width: 1
                    border.color: apps.fontColor
                    anchors.centerIn: parent
                }
            }
            Button{
                id: btnCargar
                text: "Cargar"
                font.pixelSize: app.fs
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    let urlZipFile
                    if(tiAppId.text.indexOf('https:')===0){
                        let url=tiAppId.text
                        urlZipFile=getGitHubZipUrl(url)
                        let m0=url.split('/')
                        let pn=m0[m0.length-1]
                        unikObj.downloadGitHubZip(urlZipFile, pn+"_main.zip");
                    }else{
                        for(var i=0;i<app.uAppsList.length;i++){
                            let linea=app.uAppsList[i]
                            if(linea.length>3){
                                let args=linea.split(' ')
                                if(args[0]===tiAppId.text){
                                    unikObj.cProject=args[1]
                                    urlZipFile=getGitHubZipUrl(args[2])
                                    statusText.text='Descargando '+urlZipFile
                                    unikObj.downloadGitHubZip(urlZipFile, args[1]+"_main.zip");
                                }
                            }
                        }

                    }

                }
            }
            ProgressBar {
                id: progressBar
                width: app.width-app.fs
                anchors.horizontalCenter: parent.horizontalCenter
                from: 0
                to: 1
                value: 0
                Rectangle{
                    color: 'transparent'
                    border.width: 2
                    border.color: apps.fontColor
                    anchors.fill: parent
                    Text{
                        text:  '%'+progressBar.value
                        font.pixelSize: app.fs*0.5
                        color: apps.fontColor
                        anchors.centerIn: parent
                        Rectangle{
                            width: parent.contentWidth+4
                            height: parent.contentHeight
                            color: apps.backgroundColor
                            anchors.centerIn: parent
                            z: parent.z-1
                        }
                    }
                }
            }
            Text{
                id: statusText
                text: ""
                width: app.width-app.fs
                wrapMode: Text.WordWrap
                font.pixelSize: app.fs
                color: apps.fontColor
                visible: !app.isRunikStart
            }

        }
    }


    Item {
        Unik {
            id: unikObj
            property string cProject: ''

            onDownloadProgress: function(bytesReceived, bytesTotal) {
                let msg=""
                if (bytesTotal > 0) {
                    let percent = (bytesReceived / bytesTotal) * 100;
                    msg="Progreso: " + percent.toFixed(2) + "% (" + bytesReceived + " / " + bytesTotal + " bytes)"
                    console.log(msg);
                    statusText.text=msg
                    progressBar.value = bytesReceived / bytesTotal;
                } else {
                    msg="Descargando... Bytes recibidos: " + bytesReceived
                    console.log(msg);
                    statusText.text=msg
                }
            }
            onDownloadFinished: function(success, filePath) {
                let msg=""
                if (success) {
                    console.log("¡Archivo descargado en la ruta temporal!: " + filePath);
                    let folder=''
                    if(Qt.platform.os==='android'){
                        folder=unikObj.getPath(3)+'/runik'
                    }else{
                        folder=unikObj.getPath(4)+'/runik'
                    }
                    let descomprimido=unikObj.uncompressZip(filePath, folder)
                    if(descomprimido){
                        msg="Se ha descomprimido el arhivo!\nCarpeta: "+folder
                        let folderQml=folder+'/'+unikObj.cProject+'-main'
                        msg+="\nCarpeta final: "+folderQml

                        let files=unikObj.getFileList(folderQml, '*.*')
                        msg+='\nArchivos: '+files.toString()
                        let mainFile=folderQml+'/main.qml'
                        engine.load(mainFile)
                        app.close()
                        console.log(msg)
                        statusText.text=msg

                    }else{
                        msg="Error! No se ha descomprimido el arhivo!"
                        statusText.text=msg
                    }
                } else {
                    msg="Error al descargar el archivo ZIP."
                    console.log(msg);
                    statusText.text=msg
                }
            }
        }


    }
    Component.onCompleted: {
        if(!app.isRunikStart){
            tiAppId.text="0"
        }
        getAppsList()
    }

    /*Component.onCompleted: {
        // Retardamos la llamada 1.5 segundos
        timer.restart()
    }

    Timer {
        id: timer
        interval: 5000
        repeat: false
        onTriggered: getAppsList()
    }*/

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
                if(!app.isRunikStart){
                    btnCargar.clicked()
                }
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
