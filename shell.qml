import Quickshell; import QtQuick; import Quickshell.Io; import Quickshell.Wayland;
import QtQuick.Layouts; import QtQuick.Effects;import QtQuick.Controls

pragma ComponentBehavior: Bound

PanelWindow{
    id: quickLunch;
 
    color: "#00FF0000"
    exclusionMode: ExclusionMode.Ignore
    // WlrLayerShell.layer : WlrLayer.Top;
    WlrLayershell.keyboardFocus : WlrKeyboardFocus.OnDemand

    // anchors.top: true; anchors.right: true;
    anchors.bottom: true; anchors.left: true;

    //clamp sizes? TODO listview wont give implicitHeight an update
    implicitWidth:  Math.min(Screen.width/2, Math.max( input.implicitWidth, toppyBar.implicitWidth ) )
    implicitHeight: Math.min( Screen.height/2, longBoi.implicitHeight )

    SystemPalette{ id: theme; }


    BackgroundEffect.blurRegion : Region{
        item: quickLunch.contentItem
    }

    HoverHandler{
        enabled: true
        onHoveredChanged:{
            if(!this.hovered) //hovers out from in
                Qt.quit()
        }
    }

    readonly property var signal : ({
           SIGHUP :  1,  // Hangup: terminal disconnected; often used to request reload
           SIGINT :  2,  // Interrupt from keyboard (Ctrl+C)
          SIGQUIT :  3,  // Quit from keyboard; typically produces a core dump
           SIGILL :  4,  // Illegal instruction
          SIGTRAP :  5,  // Trace or breakpoint trap
          SIGABRT :  6,  // Abort; typically indicates a fatal program error
           SIGBUS :  7,  // Bus error: invalid memory access
           SIGFPE :  8,  // Erroneous arithmetic operation, such as division by zero
          SIGKILL :  9,  // Force termination; cannot be caught or ignored
          SIGUSR1 : 10, // Application-defined signal 1
          SIGSEGV : 11, // Invalid memory reference (segmentation fault)
          SIGUSR2 : 12, // Application-defined signal 2
          SIGPIPE : 13, // Write to a pipe or socket with no reader
          SIGALRM : 14, // Timer alarm expired
          SIGTERM : 15, // Request graceful termination
        SIGSTKFLT : 16, // Stack fault (Linux-specific; rarely used)
          SIGCHLD : 17, // Child process stopped or exited
          SIGCONT : 18, // Continue a stopped process
          SIGSTOP : 19, // Stop process; cannot be caught or ignored
          SIGTSTP : 20, // Terminal stop request (usually Ctrl+Z)
          SIGTTIN : 21, // Background process attempted terminal input
          SIGTTOU : 22, // Background process attempted terminal output
           SIGURG : 23, // Urgent/out-of-band socket data available
          SIGXCPU : 24, // CPU time limit exceeded
          SIGXFSZ : 25, // File size limit exceeded
        SIGVTALRM : 26, // Virtual timer expired
          SIGPROF : 27, // Profiling timer expired
         SIGWINCH : 28, // Terminal window size changed
            SIGIO : 29, // I/O event or asynchronous I/O available
           SIGPWR : 30, // Power failure or power event (Linux-specific)
           SIGSYS : 31,  // Invalid system call
    })


    //super special theme test!!!! maybe integrate??
    /* FloatingWindow{
        required property SystemPalette
    ScrollView {
        anchors.fill: parent
        clip: true

        Grid {
            id: gridContainer
            columns: 3 //
            spacing: 10
        
            Repeater {
                model: [
                 //22 colors but 1 is normally not visible
                  { name: "WindowText", col: palette.windowText },
                  { name: "Button", col: palette.button },
                  { name: "Light", col: palette.light },
                  { name: "Midlight", col: palette.midlight },
                  { name: "Mid", col: palette.mid },
                  { name: "Dark", col: palette.dark },
                  { name: "Text", col: palette.text },
                  { name: "BrightText", col: palette.brightText },
                  { name: "ButtonText", col: palette.buttonText },
                  { name: "Base", col: palette.base },
                  { name: "Window", col: palette.window },
                  { name: "Shadow", col: palette.shadow },
                  { name: "Highlight", col: palette.highlight },
                  { name: "HighlightedText", col: palette.highlightedText },
                  { name: "Link", col: palette.link },
                  { name: "LinkVisited", col: palette.linkVisited },
                  { name: "AltBase", col: palette.alternateBase },
                  { name: "NoRole", col: null }, 
                  { name: "ToolTipBase", col: palette.toolTipBase },
                  { name: "ToolTipText", col: palette.toolTipText },
                  { name: "Placeholder", col: palette.placeholderText },
                  { name: "Accent", col: palette.accent },
                ]

                Rectangle {
                    width: 150; height: 80
                    color: modelData.col
                    border.color: "black"
                
                    Text { 
                        anchors.centerIn: parent 
                        text: modelData.name 
                        color: "white" 
                        style: Text.Outline
                        styleColor: "black"
                    }
                }
            }
        }
     }
     } */
 

	//Auto-complete style x 'find' style.. ongoing stream? cancel and re-run on update | run after x seconds to save on cpu search

	//Try to format it into units with hint of format on textInput
	//Hint for TZ too (auto-complete style)
	// else normally export areas.. or user directory search..
	// special (button/selection) -> units mode... <num> <u1> to <u2> to <u3> etc.. one to another and show all results from left to right
	// units --terse "\d \unit \unit"
	// TZ=X dat
	// Calc via Python or something simple shell -- preview in 'app' section
	// Calc needs its 'own' symbols to accept before translating
	// Python -c calc
	// temp save 'app' search and swap out for blank TZ/Calc/Units/Apps-per thingy string holder

	/* -- TAB/shiftTAB to move between top 3.. normal arrows reserved for input field
	[TZ] [Calc] [UNITS]
	[ entry 1 ]
	[ entry 2 ]
	---
	[Input field]
	----

	L/R goes to TZ/Units and switches between them, UP/Down afterwards reverts to original selection. else normal up-down selection. Enter to select. start search after ~1s delay/no input
	*/


    component Blocks : Rectangle {
        //alias to pass-through
        required property string text ;
        required property bool isSelected; //Set based on per index 

        id : bBg
        implicitWidth: bFg.width; implicitHeight: bFg.height;
        color: isSelected ? theme.base : theme.highlight
        //normal = base, highlighted=altBase

        Text{
            id: bFg
            text: bBg.text
            color: !isSelected ? theme.base : theme.highlight
        }

    }

    property int selected : 0
    onSelectedChanged : {
        //Toggle existing proc if running (ignored if not running)
        let s = (selected >= 0 ) ? 0 : selected * -1;

        // console.log(`s:${s} vs ss:${sselected}`)

        if(s != quickLunch.sselected){
            // console.log("change ss")
            //new section
            // signals ignored if not running so only affects procs that were stopped mid-prog
            quickLunch.getProc().signal(quickLunch.signal.SIGSTOP)
            quickLunch.sselected = s;
            // console.log("changed ss : "+quickLunch.sselected)
            quickLunch.getProc().signal(quickLunch.signal.SIGSTART)
        }
     }
     //special selected to avoid spamming ternary crap
     property int sselected : 0
     //top row = negs -n to -1
     //default/none = undefined
     //0+ = list item

    //name, descHints, cmds
     readonly property var topBar: [
         [
            "Calc",
            " uses python (expo == **) and auto imports math; i.e. `math.floor()` `round(d,n)` `math.sqrt()` or bin( 0b11 ^ 0b01 )  ",
            ()=>{
                let i = input.inpGet();

                // i.find(/\w+\(.*?\)/, (match) => "math." + match);

                return ["python","-c",`import math; print( ${i} )`]
            }
         ],
         [
            "TZ",
            "put in TZ to display that current TZ, anything after space is args for 'date' to interpret i.e.  [ yourCity '%Z' '+900 seconds' ] first '%' using arg will replace the default formatter' ! invalid TZ will default to UTC",
            ()=>{
                let i = input.inpGet().split(" ");

                let format = i.find(m=>m.includes('%')) ?? "(%a/%b/w%U) %d/%m/%Y %T (%Z) Q%q"

                let tz = ``;



                return ["sh","-c", `
                TZ=$(timedatectl list-timezones | grep --ignore-case "${i[0]}" | head -n 1);
                TZ=$TZ date +"${format}" ${[... i.slice(1)].join(" ")} ;
                echo $TZ ;
                #echo out TZ as well for cleanliness
                ` ]
            }
         ],
         [
            "Units",
            "\\d+ <fromUnit? to <Unit2> to <Unit3> - ` to ` seperated and will append each conversion based on prior quantity conversion",
            ()=>{
                let i = input.inpGet();

                // get pos of first regex, that goes in var, grab substring of rest.. do split etc..  easy peasy
                let digit = i.split('').splice(0,i.indexOf(' ')).join('');
                let units = i.substring(digit.length).split(" to ")

                //units --terse "\d \u" "\u2"
                // <cmd> | tee /dev/tty | <cmd2>
                // use pwsh for easier access

                //dont run if not enough args (no point)
                if ( units.length<2 ){
                    return ["echo", "need more args i.e. <number> UNIT1 to UNIT2 "]
                }

                // echo $i | %{ $a = "$_+1"; Write-Host $a; echo $a } | %{ echo "$_+2"}
                let cmd = ` echo "${digit}" `
                for (let i = 0; i < units.length ; i++){
                    cmd += ` | % { 
                        $v = $(units --terse "$_ ${units[i]}" "${units[1 + i] ?? "noUNIT" }"); 
                        [Console]::Out.WriteLine( "$_ ${units[i]}" ); 
                        ${ (i!=units.length-1) ? "echo $v" : ""};  #conditional for no more pipe
                     }`
                }

                // console.log("myCmd:" + cmd )

                return ["pwsh", "-Command" , ` ${cmd.trim()}  ` ]
            }
         ],
         [
            "ThemeViewer",
            "shows all 21-22 possible visual colors (unlike qt6ct)",
            ()=>{
                let i = input.inpGet();
                //grabs name / find based on ~/.config/qt6ct/colors/*
                return ["echo", "not implemented!"] //TODO parse input
            }
         ]
    ];

    ColumnLayout{
        id : longBoi

        // height : 500;
        
        RowLayout{
            id: toppyBar
            Repeater{
                model: quickLunch.topBar.length;

                delegate : Blocks{
                    required property int modelData;
                    text: quickLunch.topBar[modelData][0];
                    isSelected : (modelData +1) * -1 == quickLunch.selected;
                }
            }
        }

       //ListView - lazy col
        ListView {
            id: contnt

            // model: Array(100).fill(["qml", "height", "bad"]);
            // model: ["test1"]
            // model: ["t1","t2"]
            model: quickLunch.outputs[quickLunch.sselected]

            Layout.fillWidth: true //lets it be visible as height is calc later
            // Layout.minimumHeight: 10;

            clip: true //doesnt let it overlap outside
            flickableDirection: Flickable.VerticalFlick //can flick outside of delegates
    
            //content - container of all delegates || failing || content.contentHeight, 
            Layout.preferredHeight: quickLunch.height - input.height - toppyBar.height -5 //bit of spacing for textField

            delegate: Blocks {
                required property int index;
                required property string modelData
                text: modelData;
                isSelected : index == quickLunch.selected;

                /* Component.onCompleted : {
                    if(isSelected){
                        contnt.positionViewAtIndex(index, ListView.Center)
                    }
                } */
            }

        }


        //input handler
        TextField{
            id: input

            Layout.minimumHeight: implicitHeight;

            //>0 0 | -n n   []
            property var myInputs : []
            Component.onCompleted :{
                for(let i=0;i<=quickLunch.topBar.length;i++)
                    myInputs.push("")
                // console.log("MIL: "+myInputs.length)
            }

            function inpGet(){
                return myInputs[ quickLunch.sselected];
            }
            function inpSet(){
                myInputs[ quickLunch.sselected ] = input.text;
            }

            //only fires from userInput - not from any change

            
            onTextEdited : {
                inpSet(input.text);

                searchTimer.restart() //re-does interval if changed within x seconds

                // if selection >=0 is find else is special topBar
                quickLunch.getProc().command = ( quickLunch.sselected == 0 ) ?
                    [
                    "sh","-c",
                        `find "/usr/bin" ${(()=>{
                        let i = input.inpGet().split(/\s+/)
                        let paths = i.length < 2 ? "" : i.slice(0, -1);
                        let searchTerm = i.length < 2 ? i[0] : i.slice(-1)
                        let findFlags = ["-executable","-iname"]

                        return [
                            ...paths,
                            ...findFlags,
                            `"${searchTerm}"`,
                        ].join(" ");
                    })()} |
                        sort --ignore-leading-blanks --ignore-case --reverse
                    `,
                    ]
                    : quickLunch.topBar[quickLunch.sselected -1][2]() //no invoke method
                ;
            }

            Keys.onPressed : (keyEnv) => {
                let s = quickLunch.selected;
                console.log(keyEnv)
                switch(keyEnv.key){
                //maybe adjust to loop around whole thing?

                    case Qt.Key_Enter: //numpad
                    case Qt.Key_Return:
                        console.log("Enter");
                        //only for s
                        if(s>=0){
                            let p = quickLunch.getProc();
                            p.command = [
                                //Default to input text if it wasnt selected
                            "sh","-c",`
                                ${contnt.itemAtIndex(s)?.text ?? input.text} & disown`
                            ]
                            p.exited.connect( (xC,eS) => {
                                Qt.quit();
                            })
                            
                            p.running=true;
                        }
                        break;
                    case Qt.Key_Up: 
                        quickLunch.selected = (--s<0) ? quickLunch.outputs[quickLunch.sselected].length-1 : s 
                        break;
                    case Qt.Key_Down:
                        quickLunch.selected = (++s> quickLunch.outputs[quickLunch.sselected].length-1) ? 0 : s 
                        break;

                                  //Tab wont edit inputTxt so wont fire Edit func
                    case Qt.Key_Tab :
                    case Qt.Key_Backtab :

                    let isTab = keyEnv.key == Qt.Key_Tab;

                    //if shift tab (+1 to selected to go to 0) and its already 0, flip back down else normal +- 1
                    s += (!isTab) ? (s==0) ? quickLunch.topBar.length *-1 : 1 : -1;

                    //update selected
                    // console.log("newLunch "+s)

                    if (s>quickLunch.topBar.length || s< (quickLunch.topBar.length) *-1){
                        // console.log("s reset")
                        s=0;
                    }
                    // console.log("newLunch "+s)


                    quickLunch.selected = (s>0) ? s*-1 : s;

                    break;
                }

                // keyEnv.accepted=true; //wont fire onTxtEdited then
            }

            color: theme.text
            background : Rectangle{ color:theme.alternateBase }

            Timer{
                id: searchTimer;
                repeat: false;
                interval: 1000 * 1
                onTriggered : {
                    //Merge diff search spots for find? let it implicit via imports?
                    quickLunch.getProc().running = true
                }
            }

            //placeholder
            placeholderTextColor : theme.placeholderText
            placeholderText : (quickLunch.sselected==0) ? "TAB for extras or search via /optional/Path1 /path2 *targetFileExtension"
                : quickLunch.topBar[quickLunch.sselected-1][1]
        
        }


    }

    property var outputs : []
    function setOutput(string){
        outputs[quickLunch.sselected].push( string )
        //qml gotta re-assign for ref - only detects val changes
        let o = outputs; outputs = []; outputs = o;
    }

    property var procs : [];
    function getProc(){
        //objects = ref | -1 cus ssel never hits 0
        return procs[quickLunch.sselected];
    }
    //on Sselected change.. then toggle prior


    Component.onCompleted : {
        for(let i=0; i<=this.topBar.length; i++){
            outputs.push([]);
            
            procs.push(
               Qt.createQmlObject(`import Quickshell.Io;
                Process{

                    onStarted : {
                        //clear/wipe on new search/process
                        // length can truncate ?? weird js
                        quickLunch.outputs[quickLunch.sselected].length = 0 ;
                    }

                    onExited : (exC, esX) => {
                        //redo outputs on exit/done?
                        // console.log("CM: "+ JSON.stringify( quickLunch.outputs) )
                    }

                    stdout: SplitParser{
                        onRead: (line) => {
                        console.log("P : "+line)
                            if(line.trim().length>0) {
                                quickLunch.setOutput( line.trim() )
                            }
                        }
                    }

                    stderr : StdioCollector{
                        onStreamFinished : {
                            if(this.text.trim().length>0){
                                console.log("Err: "+this.text)
                            }
                        }
                    }

                }
                `, this)
            );
        }
    }
}
