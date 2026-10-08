import QtQuick
import QtQuick.Controls
import QtCore
import unik.Unik 1.0
import QtMultimedia

//import Qt.labs.calendar
import Qt.labs.folderlistmodel
import Qt.labs.platform
//import Qt.labs.settings

/*
import Qt.WebSockets
import Qt3D.Animation
import Qt3D.Core
import Qt3D.Extras
import Qt3D.Input
import Qt3D.Logic
import Qt3D.Render
import Qt3D.Scene2D
*/

Window {
    id: app
    width: Qt.platform.os==='android'?640:608
    height: Qt.platform.os==='android'?480:1080
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
        //anchors.fill: parent
        width: parent.width-app.fs*4
        height: parent.height-app.fs*6
        anchors.centerIn: parent
        Column{
            spacing: app.fs*0.5
            anchors.centerIn: parent
            Text{
                text: app.title
                font.pixelSize: app.fs*3
                color: apps.fontColor
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Item{width: 1; height: app.fs*3}
            Text{
                id: labelAppId
                text: "Ingresar nombre, url o código de la aplicación:"
                font.pixelSize: app.fs
                color: apps.fontColor
                anchors.left: tiAppId.left
            }
            TextInput{
                id: tiAppId
                text: apps.uIdApp//'https://github.com/nextsigner/semitimes-m1'
                width: app.width-app.fs
                height: app.fs*1.2
                font.pixelSize: app.fs
                color: apps.fontColor
                anchors.horizontalCenter: parent.horizontalCenter
                Rectangle{
                    width: parent.width+app.fs*0.5
                    height: parent.height+app.fs*0.5
                    color: 'transparent'
                    border.width: 1
                    border.color: apps.fontColor
                    anchors.centerIn: parent
                }
            }
            Row{
                spacing: app.fs*0.5
                anchors.horizontalCenter: parent.horizontalCenter
                Button{
                    text: "Historial"
                    font.pixelSize: app.fs
                    onClicked: {
                        getHistorial()
                    }
                }
                Button{
                    id: btnCargar
                    text: "Cargar"
                    font.pixelSize: app.fs
                    onClicked: {
                        let url=tiAppId.text
                        urlZipFile=getGitHubZipUrl(url)
                        let m0=url.split('/')
                        let pn=m0[m0.length-1]
                        unikObj.cProject=pn
                        let msg=""
                        let folder=''
                        if(Qt.platform.os==='android'){
                            folder=unikObj.getPath(3)+'/runik'
                        }else{
                            folder=unikObj.getPath(4)+'/runik'
                        }
                        let folderQml=folder+'/'+unikObj.cProject+'-main'
                        let mainFile=folderQml+'/main.qml'
                        if(unikObj.folderExist(folderQml) && unikObj.fileExist(folderQml+'/main.qml')){
                            if(unikObj.folderExist(folderQml+'/modules')){
                                engine.addImportPath(folderQml+'/modules')
                            }
                            engine.load(mainFile)
                            if(tiAppId.text!=='0' && app.isRunikStart){
                                apps.uIdApp=tiAppId.text
                            }
                            app.close()
                        }else{
                            msg='No se ha podido descargar '+tiAppId.text+'\n'
                            msg='Hay un error en la url o ha fallado la conexión de internet.\n'
                        }
                        console.log(msg);
                        statusText.text=msg
                    }
                }
                Button{
                    id: btnActualizar
                    text: "Actualizar"
                    font.pixelSize: app.fs
                    onClicked: run()
                    function run(){
                        console.log('btnActualizar.run()...')
                        let urlZipFile
                        if(tiAppId.text.indexOf('https:')===0){
                            let url=tiAppId.text
                            urlZipFile=getGitHubZipUrl(url)
                            let m0=url.split('/')
                            let pn=m0[m0.length-1]
                            unikObj.cProject=pn
                            setHistorial(tiAppId.text)
                            unikObj.downloadGitHubZip(urlZipFile, pn+"_main.zip");
                        }else{
                            for(var i=0;i<app.uAppsList.length;i++){
                                let linea=app.uAppsList[i]
                                if(linea.length>3){
                                    let args=linea.split(' ')
                                    if(args[0]===tiAppId.text && tiAppId.text!=='0'){
                                        unikObj.cProject=args[1]
                                        urlZipFile=getGitHubZipUrl(args[2])
                                        statusText.text='Descargando '+urlZipFile
                                        setHistorial(tiAppId.text)
                                        unikObj.downloadGitHubZip(urlZipFile, args[1]+"_main.zip");

                                    }
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
                visible: !app.isRunikStart  && Qt.application.arguments.indexOf('-dev')>=0
            }

        }
        Rectangle{
            id: xHistorial
            color: apps.backgroundColor
            border.width: 2
            border.color: apps.fontColor
            anchors.fill: parent
            visible: false
            ListView{
                id: lv
                spacing: app.fs
                width: parent.width
                height: parent.height*0.9
                //anchors.centerIn: parent
                model: lm
                delegate: compLv
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: app.fs
                ListModel{
                    id: lm
                    function addItem(d){
                        return{
                            dato: d
                        }
                    }
                }
                Component{
                    id: compLv
                    Rectangle{
                        id: xItemLv
                        width: lv.width-app.fs
                        height: app.fs*1.5//*0.65
                        color: 'transparent'
                        border.width: 1
                        border.color: apps.fontColor
                        radius: app.fs*0.25
                        anchors.horizontalCenter: parent.horizontalCenter
                        clip: true
                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                tiAppId.text=dato
                                xHistorial.visible=false

                            }
                        }
                        Rectangle{
                            width: parent.height-4
                            height: parent.height-4
                            color: apps.fontColor
                            anchors.right: parent.right
                            anchors.rightMargin: 2
                            anchors.verticalCenter: parent.verticalCenter
                            MouseArea{
                                anchors.fill: parent
                                onClicked: delHistorial(dato)
                            }
                            Text{
                                text: "X"
                                font.pixelSize: parent.width
                                color: apps.backgroundColor
                                anchors.centerIn: parent
                            }
                        }
                        Text{
                            id: txtDato
                            text: dato
                            font.pixelSize: app.fs
                            color: apps.fontColor
                            opacity: !tSetFS.running?1.0:0.0
                            anchors.centerIn: parent
                            Timer{
                                id: tSetFS
                                running: parent.contentWidth>parent.parent.width-app.fs*4
                                repeat: true
                                interval: 100
                                onTriggered: parent.font.pixelSize-=2
                            }
                        }
                    }
                }
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
                let folder=''
                if(Qt.platform.os==='android'){
                    folder=unikObj.getPath(3)+'/runik'
                }else{
                    folder=unikObj.getPath(4)+'/runik'
                }
                let folderQml=folder+'/'+unikObj.cProject+'-main'
                let mainFile=folderQml+'/main.qml'
                if (success) {
                    console.log("¡Archivo descargado en la ruta temporal!: " + filePath);
                    let descomprimido=unikObj.uncompressZip(filePath, folder)
                    if(descomprimido){
                        msg="Se ha descomprimido el arhivo!\nCarpeta: "+folder
                        //let folderQml=folder+'/'+unikObj.cProject+'-main'
                        msg+="\nCarpeta final: "+folderQml

                        let files=unikObj.getFileList(folderQml, '*.*')
                        msg+='\nArchivos: '+files.toString()
                        //let mainFile=folderQml+'/main.qml'
                        console.log('mainFile: '+mainFile)
                        unikObj.cd(folderQml)
                        //unikObj.mkdir(folderQml+'/modules')
                        if(unikObj.folderExist(folderQml+'/modules')){
                            engine.addImportPath(folderQml+'/modules')
                        }
                        engine.load(mainFile)
                        if(tiAppId.text!=='0' && app.isRunikStart){
                            apps.uIdApp=tiAppId.text
                        }
                        app.close()
                        console.log(msg)
                        statusText.text=msg

                    }else{
                        msg="Error! No se ha descomprimido el arhivo!"
                        statusText.text=msg
                    }
                } else {
                    msg="Error al descargar el archivo ZIP."
                    if(unikObj.folderExist(folderQml) && unikObj.fileExist(folderQml+'/main.qml')){
                        if(unikObj.folderExist(folderQml+'/modules')){
                            engine.addImportPath(folderQml+'/modules')
                        }
                        engine.load(mainFile)
                        if(tiAppId.text!=='0' && app.isRunikStart){
                            apps.uIdApp=tiAppId.text
                        }
                        app.close()
                    }else{
                        msg='No se ha podido descargar '+tiAppId.text+'\n'
                        msg='Hay un error en la url o ha fallado la conexión de internet.\n'
                    }
                    console.log(msg);
                    statusText.text=msg
                }
            }
        }


    }
    Component.onCompleted: {
        //console.log('Ejecutando en: '+unikObj.currentFolderName()
        //app.isRunikStart=unikObj.currentFolderName().indexOf('runik-start')>=0
        if(Qt.application.arguments.toString().indexOf('-folder')>=0){
            let folder=''
            for(var i=0;i<Qt.application.arguments.length;i++){
                let arg=Qt.application.arguments[i]
                if(arg.indexOf('-folder=')===0){
                    let m0=arg.split('-folder=')
                    folder=m0[1]
                    break
                }
            }
            let mainPath=folder+'/main.qml'
            if(unikObj.fileExist(mainPath)){
                engine.load(mainPath)
                app.close()
                return
            }else{
                statusText.text="El archivo "+mainPath+' no existe!'
            }
        }
        if(!app.isRunikStart && Qt.application.arguments.indexOf('-dev')<0){
            tiAppId.text="0"
        }else{
            tiAppId.text=apps.uIdApp
            tiAppId.focus=true
            tiAppId.selectAll()
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
                statusText.text = "Lista de aplicaciones descargada con éxito.";
                statusText.text+='\n'+data
                app.uAppsList=data.split('\n')
                if(!app.isRunikStart && Qt.application.arguments.indexOf('-dev')<0){
                    console.log('Actualizando Runik-Start: ['+tiAppId.text+']')
                    btnActualizar.run()
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
    function setHistorial(dato){
        let s=''
        let fp=unikObj.getPath(4)+'/historial.txt'
        let fd=''//unikObj.getFile(fp)
        if(unikObj.fileExist(fp)){
            fd=unikObj.getFile(fp)
        }else{
            fd=''
        }
        let lines=fd.split('\n')
        for(var i=0;i<lines.length;i++){
            if(lines[i]!==dato){
                s+=lines[i]+'\n'
            }
        }
        s+=dato+'\n'
        unikObj.setFile(fp, s)
        console.log('Se guarda historial: '+fp)
    }
    function delHistorial(dato){
        let s=''
        let fp=unikObj.getPath(4)+'/historial.txt'
        let fd=''//unikObj.getFile(fp)
        if(unikObj.fileExist(fp)){
            fd=unikObj.getFile(fp)
        }else{
            fd=''
        }
        let lines=fd.split('\n')
        for(var i=0;i<lines.length;i++){
            //console.log('l: ['+lines[i]+']')
            //console.log('dato: ['+dato+']')
            if(lines[i]!==dato && lines[i]!==''){
                s+=lines[i]+'\n'
            }
        }
        unikObj.setFile(fp, s)
        console.log('Se eliminó la url: '+dato+' Archvivo: '+fp+':\nContenido:\n '+unikObj.getFile(fp))
        getHistorial()
    }
    function getHistorial(){
        let cant=0
        let fp=unikObj.getPath(4)+'/historial.txt'
        let fd=unikObj.getFile(fp)
        if(fd==='error'){
            return
        }
        lm.clear()
        let lines=fd.split('\n')
        for(var i=0;i<lines.length;i++){
            if(lines[i]!=='\n'&&lines[i].length>1){
                lm.append(lm.addItem(lines[i]))
                cant++
            }
        }
        if(cant>0){
            xHistorial.visible=true
        }

    }
}
