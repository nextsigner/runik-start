import QtQuick
import QtQuick.Controls
//import Qt.labs.settings
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
    property bool dev: false
    property int fs: width*0.035
    property var uAppsList: []
    property bool isRunikStart: true
    Settings{
        id: apps
        //fileName: unikObj.getPath(4)+'/runik.cfg'
        property color backgroundColor: 'black'
        property color fontColor: 'white'
        property string uIdApp: ''
        property bool autoUpdateRunikGUI: true
        property bool autoLoad: true
    }
    Connections{
        target: qmlErrorLogger
        onMessagesChanged:{
            //if(Qt.platform.os==='linux' && app.enableQmlErrorLog && apps.dev && ap){
            //app.flags=Qt.Window
            //app.visibility="Maximized"
            let msg=qmlErrorLogger.messages[qmlErrorLogger.messages.length-1]
            if(msg.indexOf('Failed to start frame')<0){
                l(msg)
            }

            //}
        }
    }

    Rectangle{
        id: xApp
        color: 'transparent'
        //anchors.fill: parent
        width: parent.width-app.fs*4
        height: parent.height-app.fs*6
        anchors.centerIn: parent
        MouseArea{
            id: maFondo
            anchors.fill: parent
            property int v: 0
            onClicked: {
                if(maFondo.v>=3){
                    app.dev=true
                    maFondo.v=0
                    return
                }
                app.dev=false
                maFondo.v++

            }
            onDoubleClicked: app.isRunikStart=!app.isRunikStart
        }
        Column{
            spacing: app.fs*0.5
            width: xApp.width*0.5
            anchors.centerIn: parent
            Image{
                id: iconApp
                width: app.fs*6
                height: width
                //source: 'assets:/imgs/logo.png'
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text{
                id: tit
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
                width: xApp.width-app.fs*4
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
                spacing: app.fs
                visible: !app.isRunikStart
                Text{
                    text: 'Auto actualizar Runik:'
                    color: apps.fontColor
                    font.pixelSize: app.fs
                    anchors.verticalCenter: parent.verticalCenter
                }
                CheckBox{
                    checked: apps.autoUpdateRunikGUI
                    onCheckedChanged: apps.autoUpdateRunikGUI=checked
                    anchors.verticalCenter: parent.verticalCenter
                    Rectangle{
                        color: 'transparent'
                        border.width: 1
                        border.color: 'white'
                        anchors.fill: parent
                    }
                }
            }
            Row{
                spacing: app.fs
                visible: !app.isRunikStart
                Text{
                    text: 'Auto cargar ultima app:'
                    color: apps.fontColor
                    font.pixelSize: app.fs
                    anchors.verticalCenter: parent.verticalCenter
                }
                CheckBox{
                    checked: apps.autoLoad
                    onCheckedChanged: apps.autoLoad=checked
                    anchors.verticalCenter: parent.verticalCenter
                    Rectangle{
                        color: 'transparent'
                        border.width: 1
                        border.color: 'white'
                        anchors.fill: parent
                    }
                }
            }
            Row{
                spacing: app.fs*0.5
                anchors.horizontalCenter: parent.horizontalCenter
                Button{
                    id: btnCargar
                    text: 'Cargar'
                    font.pixelSize: app.fs
                    onClicked: {
                        let url=tiAppId.text
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

                        /*
                        let folder='???'
                        let url='???'
                        let m0
                        */

                        let folderQml=folder+'/'+unikObj.cProject+'-main'
                        if(tiAppId.text.indexOf('https')===0){
                            m0=tiAppId.text.split('/')
                            folder=unikObj.getPath(3)+'/runik/'+m0[m0.length-1]+'-main'
                        }
                        let mainFile=folderQml+'/main.qml'
                        if(unikObj.folderExist(folderQml) && unikObj.fileExist(folderQml+'/main.qml')){
                            if(unikObj.folderExist(folderQml+'/modules')){
                                unik.addImportPath(folderQml+'/modules')
                            }
                            unikObj.cd(folderQml)
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
                        if(tiAppId.text.indexOf('https:')===0 || tiAppId.text==='0'){
                            let url=tiAppId.text
                            if(tiAppId.text==='0'){
                                url="https://github.com/nextsigner/runik-start"
                            }
                            urlZipFile=getGitHubZipUrl(url)
                            let m0=url.split('/')
                            let pn=m0[m0.length-1]
                            unikObj.cProject=pn
                            setHistorial(tiAppId.text)
                            unikObj.uUrl=url
                            let descargado=unikObj.downloadGitHubZip(urlZipFile, pn+"_main.zip");
                            if(descargado){
                                apps.uIdApp=url
                            }
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
                                        unikObj.uUrl=args[2]
                                        let descargado = unikObj.downloadGitHubZip(urlZipFile, args[1]+"_main.zip");
                                        if(descargado){
                                            apps.uIdApp=url
                                        }
                                    }
                                }
                            }
                        }
                    }
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
                    text: "Eliminar Cache"
                    font.pixelSize: app.fs
                    onClicked: {
                        let folder='???'
                        let url='???'
                        let m0
                        if(tiAppId.text.indexOf('https')===0){
                            m0=tiAppId.text.split('/')
                            folder=unikObj.getPath(3)+'/runik/'+m0[m0.length-1]+'-main'
                        }
                        l('Existe carpeta: '+(unikObj.folderExist(folder)?'SI':'NO'))
                        l('Eliminando carpeta: '+folder)
                        let archivos=unikObj.getFileList(folder, '*')
                        l('Archivos pre existentes: '+(''+archivos).split(',').join('\n'))
                        l('Carpeta eliminada: '+(unikObj.deleteFolder(folder)?'SI':'NO'))
                        l('Archivos existentes: '+unikObj.getFileList(folder, '*'))
                    }
                }
            }
            Row{
                spacing: app.fs*0.5
                anchors.horizontalCenter: parent.horizontalCenter
                Button{
                    text: "Crear Icono"
                    font.pixelSize: app.fs
                    onClicked: {
                        if(tiAppId.text===''){
                            l('No se ha creado el ícono porque no hay ningúna app en el campo de texto.')
                            return
                        }
                        let m0=tiAppId.text.split('/')
                        let idSubApp=''+m0[m0.length-1]

                        let pathIcon1=unikObj.getPath(3)+'/runik/'+idSubApp+'-main/logo.png'
                        let pathIcon2=unikObj.getPath(4)+'/logo.png'
                        let iconoCopiado=unikObj.cpFile(pathIcon1, pathIcon2)
                        if(iconoCopiado){
                            //iconApp.source='file://'+pathIcon2
                            //l('Icono copiado!\n'+pathIcon2)
                            //console.log('Icono copiado!\n'+pathIcon2)
                        }
                        let iconPath
                        if(unikObj.fileExist(pathIcon2)){
                            iconPath=pathIcon2
                        }else{
                            iconPath=unikObj.getPath(3)+'/runik/logo.png'
                        }


                        let idIcon='runik_'+idSubApp
                        let label=idSubApp
                        let label2 = label.charAt(0).toUpperCase() + label.slice(1);
                        let params='folder='+unikObj.getPath(3)+'/runik/'+label+'-main'
                        unikObj.createRunikDesktopShortcut(idIcon, label2, params, iconPath)
                    }
                }
                /*Button{
                    text: "Modo Desarrollador"
                    font.pixelSize: app.fs
                    onClicked: {
                        app.dev=!app.dev
                        //unikObj.restart(["-dev"], unikObj.currentFolderPath())
                        //unikObj.restartApp()
                    }
                }*/

            }

            Row{
                spacing: app.fs
                visible: app.dev
                Button{
                    text: 'Probar Log'
                    onClicked: {
                        l('Probando')
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
                visible: value>0
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
                width: xApp.width-app.fs
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
            //anchors.fill: parent
            width: xApp.width-app.fs
            height: xApp.height-app.fs*4
            anchors.centerIn: parent
            visible: false
            ListView{
                id: lv
                spacing: app.fs
                width: parent.width
                height: parent.height//*0.9
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
                Button{
                    text: 'Cerrar'
                    anchors.right: parent.right
                    anchors.rightMargin: app.fs*0.5
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: app.fs
                    onClicked: xHistorial.visible=false
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
                        anchors.horizontalCenter: parent?parent.horizontalCenter:undefined
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
                                width: parent.width*1.5
                                height: parent.height+lv.spacing
                                anchors.verticalCenter: parent.verticalCenter
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
            property string uUrl: ''

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
                apps.uIdApp=unikObj.uUrl
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
                            //engine.addImportPath(folderQml+'/modules')
                            unik.addImportPath(folderQml+'/modules')
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
                            unik.addImportPath(folderQml+'/modules')
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
    Rectangle{
        id: xLog
        color: apps.backgroundColor
        //anchors.fill: parent
        width: parent.width-app.fs*4
        height: parent.height-app.fs*6
        anchors.centerIn: parent
        visible: false
        onVisibleChanged: {
            if(!xLog.visible){
                log.text=''
            }
        }
        Flickable{
            width: parent.width
            height: parent.height
            contentWidth: width
            contentHeight: log.contentHeight
            anchors.top: parent.top
            Text{
                id: log
                width: xLog.width-app.fs
                color: apps.fontColor
                wrapMode: Text.WordWrap
                font.pixelSize: app.fs*1.5
                onTextChanged: {
                    //if(text!=='')xLog.visible=true
                }
            }
        }
        Row{
            spacing: app.fs
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: app.fs*4
            Button{
                text: 'Cerrar'
                onClicked: xLog.visible=false
            }
        }
    }
    // Timer{
    //     running: true
    //     repeat: true
    //     interval: 5000
    //     onTriggered: unik.speak('Hola. Aplicación runik iniciada.')
    // }
    /*Timer {
        id: shortcutTimer
        interval: 5000
        repeat: false
        onTriggered: {
            //unikObj.createRunikShortcut('runik1', 'ShortCut1', 'param1=2')
            //unikObj.createRunikDesktopShortcut('runik1', 'runik111', 'param2=3')
            //console.log("Acceso directo solicitado desde QML de forma segura.")
        }
    }*/
    Component.onCompleted: {
        let version=1
        let nVersionRunikStart=version
        let versionFp=unikObj.getPath(3)+'/runik/runik-start/version'
        if(unikObj.fileExist(versionFp)){
            nVersionRunikStart=parseInt(unik.getFile(versionFp).replace(/\n/g, ''))
        }
        if(version>nVersionRunikStart){
            tiAppId.text="0"
            btnActualizar.run()
            return
        }
        if(!unikObj.fileExist(unikObj.getPath(3)+'/runik/logo.png')){
            let iconoCopiado=unikObj.cpFile(unikObj.getPath(3)+'/runik-start/logo.png', unikObj.getPath(3)+'/runik/logo.png')
        }

        let folder
        let mainPath

        let param = unikObj.getRunikLaunchParameter();
        if (param !== "") {
            console.log(">>> La app se abrió desde un acceso directo con el parámetro:", param);

            //tit.text='Parámetros:\n'+param
            //tit.font.pixelSize=app.fs*0.5
            let m00=param.split('|')
            for(var i0=0; i0 < m00.length; i0++){
                let arg=m00[i0]
                if(arg.indexOf('folder=')>=0){
                    let mArg=arg.split('folder=')
                    folder=mArg=mArg[1]
                    mainPath=folder+'/main.qml'
                    unikObj.cd(folder)
                    engine.load(mainPath)
                    app.close()
                }
            }

            //txtDato.visible=true
            return
        } else {
            console.log(">>> La app se abrió de forma normal (sin parámetros de shortcut).");
        }
        let pathIcon1=unikObj.getPath(3)+'/runik/logo.png'
        let pathIcon2=unikObj.getPath(4)+'/logo.png'
        let iconoCopiado=unikObj.cpFile(pathIcon1, pathIcon2)
        if(iconoCopiado){
            iconApp.source='file://'+pathIcon2
            //l('Icono copiado!\n'+pathIcon2)
            console.log('Icono copiado!\n'+pathIcon2)
        }

        //apps.autoLoad=false


        let currentUrl = Qt.resolvedUrl("").toString();

        // Extraemos únicamente el nombre del archivo al final de la URL
        /*let fileName = currentUrl.substring(currentUrl.lastIndexOf("/") + 1);

        console.log("Nombre del archivo actual:", fileName);

        if (fileName === "Main.qml") {
            console.log("El archivo se llama exactamente con la 'M' en mayúscula.");
            app.isRunikStart=false
        } else if (fileName === "main.qml") {
            console.log("El archivo está en minúsculas.");
            app.isRunikStart=true
        }*/
        //console.log('Ejecutando en: '+unikObj.currentFolderName()
        //app.isRunikStart=unikObj.currentFolderName().indexOf('runik-start')>=0
        if(Qt.application.arguments.toString().indexOf('-folder')>=0){
            folder=''
            for(var i=0;i<Qt.application.arguments.length;i++){
                let arg=Qt.application.arguments[i]
                if(arg.indexOf('-folder=')===0){
                    let m0=arg.split('-folder=')
                    folder=m0[1]
                    break
                }
            }
            mainPath=folder+'/main.qml'
            if(unikObj.fileExist(mainPath)){
                unikObj.cd(folder)
                engine.load(mainPath)
                app.close()
                return
            }else{
                statusText.text="El archivo "+mainPath+' no existe!'
            }
        }
        if(!apps.autoLoad && apps.autoUpdateRunikGUI && !app.isRunikStart && Qt.application.arguments.indexOf('-dev')<0){
            tiAppId.text="0"
        }else{
            if(apps.autoLoad){
                tiAppId.text=apps.uIdApp
                tiAppId.focus=true
                tiAppId.selectAll()
            }
        }
        getAppsList()

        //let c='import QtQuickff'
        //let obj=Qt.createQmlObject(c, xApp, 'pruebaErrorQml-code')
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
        onActivated: {
            if(xLog.visible){
                xLog.visible=false
                return
            }
            if(xHistorial.visible){
                xHistorial.visible=false
                return
            }
            Qt.quit()
        }
    }


    function l(t){
        log.text+=t+'\n'
        xLog.visible=true
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
                if(!app.isRunikStart && Qt.application.arguments.indexOf('-dev')<0 && tiAppId.text!=='https://github.com/nextsigner/runik-start'){
                    console.log('Actualizando Runik-Start: ['+tiAppId.text+']')
                    if(apps.autoLoad){
                        btnActualizar.run()
                    }
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


