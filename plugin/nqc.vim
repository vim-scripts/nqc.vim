"###############################################################################################
"
"       Filename:  nqc.vim
"  
"    Description:  gvim-menus for NQC (Not Quite C),  Version 2.3r1 or higher.
"  
"                  NQC stands for Not Quite C, and is a C-like language for programmimg
"                  several LEGO MINDSTORMS products:  RCX, CyberMaster, Scout and RCX2.
"                  The language is described in:
"                    NQC Programmers's Guide, Version 2.3r1 (or higher), by Dave Baum
"                    ( http://www.baumfamily.org/nqc/ )
"  
"                  nqc.vim turns gvim into an IDE for NQC programming:
"  
"      Features:   - insert various types of comments
"                  - insert complete but empty statements (e.g. 'if {} else {}' )
"                  - insert often used code snippets (e.g. function definition, 
"                    #ifndef #def #endif, ... )
"                  - download and start programs
"                  - download firmware
"                  - upload the RCX datalog into a new buffer
"                  - show or print datalog plot (gnuplot)
"                  - erase programs and datalogs
"                  - configurable for RCX, RCX2, CyberMaster, Scout
"
"  Configuration:  There are some personal details which should be configured 
"                   (see the files README and nqcsupport.txt).
"  
let s:NQC_Version = "3.0"              " version number of this script; do not change
"
"         Author:  Dr.-Ing. Fritz Mehner
"          Email:  mehner@fh-swh.de
"
"       Revision:  27.12.2003
"        Created:  23.10.2002
"      Copyright:  Copyright (C) 2002-2003 Dr.-Ing. Fritz Mehner  (mehner@fh-swf.de)
"
"                  This program is free software; you can redistribute it
"                  and/or modify it under the terms of the GNU General Public
"                  License as published by the Free Software Foundation;
"                  either version 2 of the License, or (at your option) any
"                  later version.
"
"###############################################################################################
"               
"  Global variables (with default values) which can be overridden.
"  ---------------------------------------------------------------
"
"  Personalization  (full name, email, ... ; used in comments) :
"
let s:NQC_AuthorName     = ''
let s:NQC_AuthorRef      = ''
let s:NQC_Email          = ''
let s:NQC_Project        = ''
let s:NQC_CopyrightHolder= ''
"
let s:NQC_RCX_Firmware   = $HOME.'/bin/firm0328.lgo'  " RCX-Firmware: full path and filename
"
let s:NQC_Target         = 'RCX2'                     " targets are: RCX2, RCX, Scout, CM
"
"  Specify serial port, case matters (file permission 777) :
"  /dev/ttyS0  =  COM1
"  /dev/ttyS1  =  COM2
"
let s:NQC_Portname       = '/dev/ttyS0'
let s:NQC_ShowMenues     = 'yes'            " show menues immediately after loading (yes/no)
let s:NQC_Printer        = 'lpr'            " printer command
"                                           
let s:NQC_CodeSnippets   = $HOME.'/.vim/codesnippets-nqc'   " NQC code snippet directory
let s:NQC_Root           = '&NQC.'                          " the name of the root menu of this plugin
"
"   ----- template files ---------------------------------------------
let s:NQC_Template_Directory       = $HOME.'/.vim/plugin/templates/'
let s:NQC_Template_Frame           = 'nqc-frame'
let s:NQC_Template_C_File          = 'nqc-file-header'
let s:NQC_Template_Task            = 'nqc-task-description'
"
" 
"###############################################################################################
"
"
"------------------------------------------------------------------------------
"
"  Look for global variables (if any), to override the defaults.
"  
function! NQC_CheckGlobal ( name )
  if exists('g:'.a:name)
    exe 'let s:'.a:name.'  = g:'.a:name
  endif
endfunction
"
call NQC_CheckGlobal("NQC_AuthorName        ")
call NQC_CheckGlobal("NQC_AuthorRef         ")
call NQC_CheckGlobal("NQC_Email             ") 
call NQC_CheckGlobal("NQC_Project           ") 
call NQC_CheckGlobal("NQC_CopyrightHolder   ") 
call NQC_CheckGlobal("NQC_RCX_Firmware      ")
call NQC_CheckGlobal("NQC_Target            ")
call NQC_CheckGlobal("NQC_Portname          ")
call NQC_CheckGlobal("NQC_ShowMenues        ")
call NQC_CheckGlobal("NQC_Printer           ")
call NQC_CheckGlobal("NQC_CodeSnippets      ")
call NQC_CheckGlobal("NQC_Root              ")
call NQC_CheckGlobal("NQC_Template_Directory")
call NQC_CheckGlobal("NQC_Template_C_File   ")
call NQC_CheckGlobal("NQC_Template_Frame    ")
call NQC_CheckGlobal("NQC_Template_Task     ")

"------------------------------------------------------------------------------
"  Initialization of NQC support menus
"------------------------------------------------------------------------------
"
function! NQC_InitMenu ()
	"
	"----- Key Mappings ---------------------------------------------------------------------
	"----- for developement only ------------------------------------------------------------
	noremap  <F12>  <Esc><Esc>:write<CR><Esc>:so %<CR><Esc>:call NQC_Handle()<CR><Esc>:call NQC_Handle()<CR><Esc>:call NQC_Handle()<CR>
	"
	"===============================================================================================
	"----- Menu : NQC-Comments ---------------------------------------------------------------------
	"===============================================================================================
	"
	exe "amenu  ".s:NQC_Root.'&Comments.&Line\ End\ Comment               <Esc><Esc>A<Tab><Tab><Tab>// '

	exe "amenu <silent> ".s:NQC_Root.'&Comments.&Frame\ Comment         <Esc><Esc>:call NQC_CommentTemplates("frame")<CR>'
	exe "amenu <silent> ".s:NQC_Root.'&Comments.task\/function\/sub\ &Descr\.        <Esc><Esc>:call NQC_CommentTemplates("task")<CR>'
	exe "amenu <silent> ".s:NQC_Root.'&Comments.File\ &Prologue         <Esc><Esc>:call NQC_CommentTemplates("cheader")<CR>'
	exe "amenu  ".s:NQC_Root.'&Comments.-SEP1-                            :'
	exe "amenu  ".s:NQC_Root.'&Comments.\/\/\ Date\ Time\ &Author         <Esc><Esc>$<Esc>:call NQC_CommentDateTimeAuthor() <CR>kJA'
	
	exe "vmenu  ".s:NQC_Root."&Comments.&code->comment                    <Esc><Esc>:'<,'>s#^#\/\/#<CR><Esc>:nohlsearch<CR>"
	exe "vmenu  ".s:NQC_Root."&Comments.c&omment->code                    <Esc><Esc>:'<,'>s#^\/\/##<CR><Esc>:nohlsearch<CR>"
	
	exe "amenu  ".s:NQC_Root.'&Comments.-SEP2-                            :'
	exe " menu  ".s:NQC_Root.'&Comments.&Date                      i<C-R>=strftime("%x")<CR>'
	exe "imenu  ".s:NQC_Root.'&Comments.&Date                       <C-R>=strftime("%x")<CR>'
	exe " menu  ".s:NQC_Root.'&Comments.Date\ &Time                i<C-R>=strftime("%x %X %Z")<CR>'
	exe "imenu  ".s:NQC_Root.'&Comments.Date\ &Time                 <C-R>=strftime("%x %X %Z")<CR>'
	"
	"===============================================================================================
	"----- Menu : NQC-Statements -------------------------------------------------------------------
	"===============================================================================================
	"
	exe "amenu           ".s:NQC_Root.'St&atements.&if                         <Esc><Esc>oif (  )<Esc>==f(la'
	exe "amenu           ".s:NQC_Root.'St&atements.if\ &else                   <Esc><Esc>oif (  )<CR>else<Esc>1k2==f)hi'
	exe "amenu           ".s:NQC_Root.'St&atements.i&f\ \{\ \}                 <Esc><Esc>oif (  )<CR>{<CR>}<Esc>2k3==f(la'
	exe "amenu           ".s:NQC_Root.'St&atements.if\ \{\ \}\ e&lse\ \{\ \}   <Esc><Esc>oif (  )<CR>{<CR>}<CR>else<CR>{<CR>}<Esc>5k6==f(la'
	exe "amenu           ".s:NQC_Root.'St&atements.f&or                        <Esc><Esc>ofor ( ; ;  )<Esc>==f;i'
	exe "amenu           ".s:NQC_Root.'St&atements.fo&r\ \{\ \}                <Esc><Esc>ofor ( ; ;  )<CR>{<CR>}<Esc>2k3==f;i'
	exe "amenu           ".s:NQC_Root.'St&atements.&while\ \{\ \}              <Esc><Esc>owhile (  )<CR>{<CR>}<Esc>2k3==f(la'
	exe "amenu           ".s:NQC_Root.'St&atements.&do\ \{\ \}\ while          <Esc><Esc>:call NQC_DoWhile()<CR><Esc>3jf(la'
	exe "amenu           ".s:NQC_Root.'St&atements.re&peat\ \{\ \}             <Esc><Esc>orepeat (  )<CR>{<CR>}<CR><Esc>3k3==f(la'
	exe "amenu           ".s:NQC_Root.'St&atements.&until                      <Esc><Esc>ountil (  );<Esc>==f(la'
	exe "amenu           ".s:NQC_Root.'St&atements.un&til\ \{\ \}              <Esc><Esc>ountil (  )<CR>{<CR>}<Esc>2k3==f(la'
	exe " menu           ".s:NQC_Root.'St&atements.&switch                     <Esc><Esc>:call NQC_CodeSwitch()<Esc>f(la'
	exe "amenu           ".s:NQC_Root.'St&atements.&case                       <Esc><Esc>ocase 0:<Tab><CR>break;<CR><Esc>2k3==f0s'
	exe "amenu           ".s:NQC_Root.'St&atements.&\{\ \}                     <Esc><Esc>o{<CR>}<Esc>1k2==o'
	exe "amenu           ".s:NQC_Root.'St&atements.brea&k                      <Esc><Esc>obreak;<Esc>==A'
	exe "amenu           ".s:NQC_Root.'St&atements.continue                    <Esc><Esc>ocontinue;<Esc>==A'
	exe "amenu           ".s:NQC_Root.'St&atements.st&art                      <Esc><Esc>ostart<Tab>;<CR><Esc>k==f;i'
	exe "amenu           ".s:NQC_Root.'St&atements.-SEP1-                      :'
	exe "amenu  <silent> ".s:NQC_Root.'St&atements.&task              <Esc><Esc>:call NQC_CodeTask()<CR>3jA'
	exe "amenu  <silent> ".s:NQC_Root.'St&atements.function           <Esc><Esc>:call NQC_CodeInlineFunction()<CR>3jA'
	exe "amenu  <silent> ".s:NQC_Root.'St&atements.su&broutine        <Esc><Esc>:call NQC_CodeSubroutine()<CR>3jA'
	"	
	exe "vmenu  ".s:NQC_Root."St&atements.&if                             DOif (  )<Esc>pk:exe \"normal =\".(line(\"'>\")-line(\".\")-1).\"+\"<CR>f(la"
	exe "vmenu  ".s:NQC_Root."St&atements.if\\ &else                      DOif (  )<CR>else<Esc>Pk:exe \"normal =\".(line(\"'>\")-line(\".\")-1).\"+\"<CR>f(la"
	exe "vmenu  ".s:NQC_Root."St&atements.i&f\\ \{\\ \}                   DOif (  )<CR>{<CR>}<Esc>P2k:exe \"normal =\".(line(\"'>\")-line(\".\")-1).\"+\"<CR>f(la"
	exe "vmenu  ".s:NQC_Root."St&atements.if\\ \{\\ \}\\ e&lse\\ \{\\ \}  DOif (  )<CR>{<CR>}<CR>else<CR>{<CR>}<Esc>3kP2k:exe \"normal =\".(line(\"'>\")-line(\".\")-1).\"+\"<CR>f(la"
	exe "vmenu  ".s:NQC_Root."St&atements.f&or                            DOfor ( ; ;  )<Esc>pk:exe \"normal =\".(line(\"'>\")-line(\".\")-1).\"+\"<CR>f(la"
	exe "vmenu  ".s:NQC_Root."St&atements.fo&r\\ \{\\ \}                  DOfor ( ; ;  )<CR>{<CR>}<Esc>P2k:exe \"normal =\".(line(\"'>\")-line(\".\")-1).\"+\"<CR>f;i"
	exe "vmenu  ".s:NQC_Root."St&atements.&while\\ \{\\ \}                DOwhile (  )<CR>{<CR>}<Esc>P2k:exe \"normal =\".(line(\"'>\")-line(\".\")-1).\"+\"<CR>f(la"
	exe "vmenu  ".s:NQC_Root.'St&atements.&do\ \{\ \}\ while              <Esc><Esc>:call C_DoWhile("v")<CR><Esc>f(la'
	exe "vmenu  ".s:NQC_Root."St&atements.re&peat\\ \{\\ \}               DOrepeat (  )<CR>{<CR>}<Esc>P2k:exe \"normal =\".(line(\"'>\")-line(\".\")-1).\"+\"<CR>f(la"
	exe "vmenu  ".s:NQC_Root."St&atements.un&til\\ \{\\ \}                DOuntil (  )<CR>{<CR>}<Esc>P2k:exe \"normal =\".(line(\"'>\")-line(\".\")-1).\"+\"<CR>f(la"
	exe "vmenu  ".s:NQC_Root."St&atements.&case                           DOcase 0:<Tab><CR>break;<CR><Esc>kPk<Esc>:exe \"normal =\".(line(\"'>\")-line(\".\")-1).\"+\"<CR>f0s"
	exe "vmenu  ".s:NQC_Root."St&atements.&\{\\ \}                  	    DO{<CR>}<Esc>Pk:exe \"normal =\".(line(\"'>\")-line(\".\")-1).\"+\"<CR>"
	"
	exe "amenu  ".s:NQC_Root.'St&atements.-SEP2-                      :'
	exe "amenu  ".s:NQC_Root.'St&atements.#include\ \"\.\.\.\"        <Esc><Esc>o#include<Tab>".nqh"<Esc>F.i'
	exe "amenu  ".s:NQC_Root.'St&atements.&#define                    <Esc><Esc>o#define<Tab><Tab><Tab><Tab>//<Space><Esc>4F<Tab>a'
	exe "amenu  ".s:NQC_Root.'St&atements.#if\ #else\ #endif\ \ (&1)      <Esc><Esc>:call NQC_PPIfElse("if"    ,"a") <CR>ji'
	exe "amenu  ".s:NQC_Root.'St&atements.#ifdef\ #else\ #endif\ \ (&2)   <Esc><Esc>:call NQC_PPIfElse("ifdef" ,"a") <CR>ji'
	exe "amenu  ".s:NQC_Root.'St&atements.#ifndef\ #else\ #endif\ \ (&3)  <Esc><Esc>:call NQC_PPIfElse("ifndef","a") <CR>ji'
	exe "amenu  ".s:NQC_Root.'St&atements.#ifndef\ #def\ #endif\ \ (&4)   <Esc><Esc>:call NQC_PPIfDef (         "a") <CR>2ji'
	"
	exe "vmenu  ".s:NQC_Root.'St&atements.#if\ #else\ #endif\ \ (&1)      <Esc><Esc>:call NQC_PPIfElse("if"    ,"v") <CR>'
	exe "vmenu  ".s:NQC_Root.'St&atements.#ifdef\ #else\ #endif\ \ (&2)   <Esc><Esc>:call NQC_PPIfElse("ifdef" ,"v") <CR>'
	exe "vmenu  ".s:NQC_Root.'St&atements.#ifndef\ #else\ #endif\ \ (&3)  <Esc><Esc>:call NQC_PPIfElse("ifndef","v") <CR>'
	exe "vmenu  ".s:NQC_Root.'St&atements.#ifndef\ #def\ #endif\ \ (&4)   <Esc><Esc>:call NQC_PPIfDef (         "v") <CR>'


	"	
	if s:NQC_Target=="RCX2" || s:NQC_Target=="Scout"
		exe "amenu  ".s:NQC_Root.'St&atements.-SEP3-                      :'
		exe "amenu  ".s:NQC_Root.'St&atements.ac&quire                    <Esc><Esc>:call NQC_Acquire()<CR>f(a'
		exe "amenu  ".s:NQC_Root.'St&atements.&monitor                    <Esc><Esc>:call NQC_Monitor()<CR>f(a'
		exe "amenu  ".s:NQC_Root.'St&atements.catc&h\ \(\ \)              <Esc><Esc>:call NQC_Catch()<CR>f(a'
	endif
	"
	"===============================================================================================
	"----- Menu : API-Functions --------------------------------------------------------------------
	"===============================================================================================
	"
	"----- outputs ----------------------------------------------------------------------------
	exe " menu ".s:NQC_Root.'API-&Functions.outputs.Float\ (outputs)                     aFloat();<Esc>F(a'
	exe " menu ".s:NQC_Root.'API-&Functions.outputs.Fwd\ (outputs)                       aFwd();<Esc>F(a'
	exe " menu ".s:NQC_Root.'API-&Functions.outputs.Off\ (outputs)                       aOff();<Esc>F(a'
	exe " menu ".s:NQC_Root.'API-&Functions.outputs.On\ (outputs)                        aOn();<Esc>F(a'
	exe " menu ".s:NQC_Root.'API-&Functions.outputs.OnFor\ (outputs,time)                aOnFor(,);<Esc>F(a'
	exe " menu ".s:NQC_Root.'API-&Functions.outputs.OnFwd\ (outputs)                     aOnFwd();<Esc>F(a'
	exe " menu ".s:NQC_Root.'API-&Functions.outputs.OnRev\ (outputs)                     aOnRev();<Esc>F(a'
	exe " menu ".s:NQC_Root.'API-&Functions.outputs.OutputStatus\ (n)                    aOutputStatus()<Esc>F(a'
	exe " menu ".s:NQC_Root.'API-&Functions.outputs.Rev\ (outputs)                       aRev();<Esc>F(a'
	exe " menu ".s:NQC_Root.'API-&Functions.outputs.SetDirection\ (outputs,dir)          aSetDirection(,);<Esc>F(a'
	exe " menu ".s:NQC_Root.'API-&Functions.outputs.SetOutput\ (outputs,mode)            aSetOutput(,);<Esc>F(a'
	exe " menu ".s:NQC_Root.'API-&Functions.outputs.SetPower\ (outputs,power)            aSetPower(,);<Esc>F(a'
	exe " menu ".s:NQC_Root.'API-&Functions.outputs.Toggle\ (outputs)                    aToggle();<Esc>F(a'
	"
	exe "imenu ".s:NQC_Root.'API-&Functions.outputs.Float\ (outputs)                     Float();<Esc>F(a'
	exe "imenu ".s:NQC_Root.'API-&Functions.outputs.Fwd\ (outputs)                       Fwd();<Esc>F(a'
	exe "imenu ".s:NQC_Root.'API-&Functions.outputs.Off\ (outputs)                       Off();<Esc>F(a'
	exe "imenu ".s:NQC_Root.'API-&Functions.outputs.On\ (outputs)                        On();<Esc>F(a'
	exe "imenu ".s:NQC_Root.'API-&Functions.outputs.OnFor\ (outputs,time)                OnFor(,);<Esc>F(a'
	exe "imenu ".s:NQC_Root.'API-&Functions.outputs.OnFwd\ (outputs)                     OnFwd();<Esc>F(a'
	exe "imenu ".s:NQC_Root.'API-&Functions.outputs.OnRev\ (outputs)                     OnRev();<Esc>F(a'
	exe "imenu ".s:NQC_Root.'API-&Functions.outputs.OutputStatus\ (n)                    OutputStatus()<Esc>F(a'
	exe "imenu ".s:NQC_Root.'API-&Functions.outputs.Rev\ (outputs)                       Rev();<Esc>F(a'
	exe "imenu ".s:NQC_Root.'API-&Functions.outputs.SetDirection\ (outputs,dir)          SetDirection(,);<Esc>F(a'
	exe "imenu ".s:NQC_Root.'API-&Functions.outputs.SetOutput\ (outputs,mode)            SetOutput(,);<Esc>F(a'
	exe "imenu ".s:NQC_Root.'API-&Functions.outputs.SetPower\ (outputs,power)            SetPower(,);<Esc>F(a'
	exe "imenu ".s:NQC_Root.'API-&Functions.outputs.Toggle\ (outputs)                    Toggle();<Esc>F(a'
	"
	"----- sensor types, modes, information ---------------------------------------------------
	exe "imenu ".s:NQC_Root.'API-&Functions.sensors.ClearSensor\ (sensor)                ClearSensor();<Esc>F(a'
	if s:NQC_Target=="RCX" || s:NQC_Target=="RCX2" || s:NQC_Target=="CM"
		exe " menu ".s:NQC_Root.'API-&Functions.sensors.SensorMode\ (n)                    aSensorMode();<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.sensors.SensorMode\ (n)                     SensorMode();<Esc>F(a'
	endif
	exe " menu ".s:NQC_Root.'API-&Functions.sensors.SensorType\ (n)                      aSensorType();<Esc>F(a'
	exe "imenu ".s:NQC_Root.'API-&Functions.sensors.SensorType\ (n)                       SensorType();<Esc>F(a'
	if s:NQC_Target=="RCX" || s:NQC_Target=="RCX2"
		exe " menu ".s:NQC_Root.'API-&Functions.sensors.SensorValueBool\ (n)               aSensorValueBool()<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.sensors.SensorValueBool\ (n)                SensorValueBool()<Esc>F(a'
	endif
	if s:NQC_Target=="RCX" || s:NQC_Target=="RCX2" || s:NQC_Target=="Scout"
		exe " menu ".s:NQC_Root.'API-&Functions.sensors.SensorValueRaw\ (n)                aSensorValueRaw()<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.sensors.SensorValueRaw\ (n)                 SensorValueRaw()<Esc>F(a'
	endif
	exe " menu ".s:NQC_Root.'API-&Functions.sensors.SensorValue\ (n)                     aSensorValue()<Esc>F(a'
	exe "imenu ".s:NQC_Root.'API-&Functions.sensors.SensorValue\ (n)                      SensorValue()<Esc>F(a'
	if s:NQC_Target=="Scout"
		exe " menu ".s:NQC_Root.'API-&Functions.sensors.SetSensorLowerLimit\ (value)       aSetSensorLowerLimit();<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.sensors.SetSensorUpperLimit\ (value)       aSetSensorUpperLimit();<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.sensors.SetSensorHysteresis\ (value)       aSetSensorHysteresis();<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.sensors.CalibrateSensor\ (\ )              aCalibrateSensor();'
		exe "imenu ".s:NQC_Root.'API-&Functions.sensors.SetSensorLowerLimit\ (value)        SetSensorLowerLimit();<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.sensors.SetSensorUpperLimit\ (value)        SetSensorUpperLimit();<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.sensors.SetSensorHysteresis\ (value)        SetSensorHysteresis();<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.sensors.CalibrateSensor\ (\ )               CalibrateSensor();'
	endif
	if s:NQC_Target=="RCX" || s:NQC_Target=="RCX2"
		exe " menu ".s:NQC_Root.'API-&Functions.sensors.SetSensor\ (sensor,config)         aSetSensor(,);<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.sensors.SetSensor\ (sensor,config)          SetSensor(,);<Esc>F(a'
	endif
	if s:NQC_Target=="RCX" || s:NQC_Target=="RCX2" || s:NQC_Target=="CM"
		exe " menu ".s:NQC_Root.'API-&Functions.sensors.SetSensorMode\ (sensor,mode)      aSetSensorMode(,);<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.sensors.SetSensorMode\ (sensor,mode)       SetSensorMode(,);<Esc>F(a'
	endif
	if s:NQC_Target=="RCX" || s:NQC_Target=="RCX2"
		exe " menu ".s:NQC_Root.'API-&Functions.sensors.SetSensorType\ (sensor,type)      aSetSensorType(,)<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.sensors.SetSensorType\ (sensor,type)       SetSensorType(,)<Esc>F(a'
	endif
	"----- timers and counters ----------------------------------------------------------------
	exe " menu ".s:NQC_Root.'API-&Functions.timers\ counters.ClearTimer\ (n)            aClearTimer();<Esc>F(a'
	exe " menu ".s:NQC_Root.'API-&Functions.timers\ counters.Timer\ (n)                 aTimer()<Esc>F(a'
	exe "imenu ".s:NQC_Root.'API-&Functions.timers\ counters.ClearTimer\ (n)             ClearTimer();<Esc>F(a'
	exe "imenu ".s:NQC_Root.'API-&Functions.timers\ counters.Timer\ (n)                  Timer()<Esc>F(a'
	if s:NQC_Target=="RCX2"
		exe " menu ".s:NQC_Root.'API-&Functions.timers\ counters.FastTimer\ (n)           aFastTimer()<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.timers\ counters.SetTimer\ (n,value)      aSetTimer(,);<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.timers\ counters.FastTimer\ (n)            FastTimer()<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.timers\ counters.SetTimer\ (n,value)       SetTimer(,);<Esc>F(a'
	endif
	if s:NQC_Target=="RCX2" || s:NQC_Target=="Scout"
		exe " menu ".s:NQC_Root.'API-&Functions.timers\ counters.Counter\ (n)             aCounter()<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.timers\ counters.ClearCounter\ (n)        aClearCounter();<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.timers\ counters.DecCounter\ (n)          aDecCounter();<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.timers\ counters.IncCounter\ (n)          aIncCounter();<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.timers\ counters.Counter\ (n)              Counter()<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.timers\ counters.ClearCounter\ (n)         ClearCounter();<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.timers\ counters.DecCounter\ (n)           DecCounter();<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.timers\ counters.IncCounter\ (n)           IncCounter();<Esc>F(a'
	endif
	"----- sounds -----------------------------------------------------------------------------
	if s:NQC_Target=="RCX2"
		exe " menu ".s:NQC_Root.'API-&Functions.sounds.ClearSound\ (\n)                   aClearSound();'
		exe "imenu ".s:NQC_Root.'API-&Functions.sounds.ClearSound\ (\n)                    ClearSound();'
	endif
	exe " menu ".s:NQC_Root.'API-&Functions.sounds.PlaySound\ (sound)                   aPlaySound();<Esc>F(a'
	exe " menu ".s:NQC_Root.'API-&Functions.sounds.PlayTone\ (freq,duration)            aPlayTone(,);<Esc>F(a'
	exe "imenu ".s:NQC_Root.'API-&Functions.sounds.PlaySound\ (sound)                    PlaySound();<Esc>F(a'
	exe "imenu ".s:NQC_Root.'API-&Functions.sounds.PlayTone\ (freq,duration)             PlayTone(,);<Esc>F(a'
	if s:NQC_Target=="RCX2" || s:NQC_Target=="Scout"
		exe " menu ".s:NQC_Root.'API-&Functions.sounds.MuteSound\ (\n)                    aMuteSound();'
		exe " menu ".s:NQC_Root.'API-&Functions.sounds.UnmuteSound\ (\n)                  aUnmuteSound();'
		exe "imenu ".s:NQC_Root.'API-&Functions.sounds.MuteSound\ (\n)                     MuteSound();'
		exe "imenu ".s:NQC_Root.'API-&Functions.sounds.UnmuteSound\ (\n)                   UnmuteSound();'
	endif
	if s:NQC_Target=="Scout"
		exe " menu ".s:NQC_Root.'API-&Functions.sounds.SelectSound\ (group)               aSelectSound();<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.sounds.SelectSound\ (group)                SelectSound();<Esc>F(a'
	endif
	"----- LCD display ------------------------------------------------------------------------
	if s:NQC_Target=="RCX" ||  s:NQC_Target=="RCX2"
		exe " menu ".s:NQC_Root.'API-&Functions.display.SelectDisplay\ (mode)             aSelectDisplay();<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.display.SelectDisplay\ (mode)              SelectDisplay();<Esc>F(a'
	endif
	if s:NQC_Target=="RCX2"
		exe " menu ".s:NQC_Root.'API-&Functions.display.SetUserDisplay\ (value,precision) aSetUserDisplay(,);<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.display.SetUserDisplay\ (value,precision)  SetUserDisplay(,);<Esc>F(a'
	endif
	"----- messages ---------------------------------------------------------------------------
	if s:NQC_Target=="RCX" ||  s:NQC_Target=="RCX2" || s:NQC_Target=="Scout"
		exe " menu ".s:NQC_Root.'API-&Functions.messages.ClearMessage\ (\ )               aClearMessage();'
		exe " menu ".s:NQC_Root.'API-&Functions.messages.Message\ (\ )                    aMessage()'
		exe " menu ".s:NQC_Root.'API-&Functions.messages.SendMessage\ (message)           aSendMessage();<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.messages.SetTxPower\ (power)              aSetTxPower();<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.messages.ClearMessage\ (\ )                ClearMessage();'
		exe "imenu ".s:NQC_Root.'API-&Functions.messages.Message\ (\ )                     Message()'
		exe "imenu ".s:NQC_Root.'API-&Functions.messages.SendMessage\ (message)            SendMessage();<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.messages.SetTxPower\ (power)               SetTxPower();<Esc>F(a'
	endif
	"----- general ----------------------------------------------------------------------------
	exe " menu ".s:NQC_Root.'API-&Functions.general.Random\ (n)                         aRandom()<Esc>F(a'
	exe " menu ".s:NQC_Root.'API-&Functions.general.SetSleepTime\ (minutes)             aSetSleepTime();<Esc>F(a'
	exe "imenu ".s:NQC_Root.'API-&Functions.general.Random\ (n)                          Random()<Esc>F(a'
	exe "imenu ".s:NQC_Root.'API-&Functions.general.SetSleepTime\ (minutes)              SetSleepTime();<Esc>F(a'
	if s:NQC_Target=="RCX2"
		exe " menu ".s:NQC_Root.'API-&Functions.general.SetRandomSeed\ (n)                aSetRandomSeed();<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.general.SetRandomSeed\ (n)                 SetRandomSeed();<Esc>F(a'
	endif
	exe " menu ".s:NQC_Root.'API-&Functions.general.SleepNow\ (\ )                      aSleepNow();'
	exe " menu ".s:NQC_Root.'API-&Functions.general.StopAllTasks\ (\ )                  aStopAllTasks();'
	exe " menu ".s:NQC_Root.'API-&Functions.general.Wait\ (time)                        aWait();<Esc>F(a'
	exe "imenu ".s:NQC_Root.'API-&Functions.general.SleepNow\ (\ )                       SleepNow();'
	exe "imenu ".s:NQC_Root.'API-&Functions.general.StopAllTasks\ (\ )                   StopAllTasks();'
	exe "imenu ".s:NQC_Root.'API-&Functions.general.Wait\ (time)                         Wait();<Esc>F(a'

	"----- RCX features -----------------------------------------------------------------------
	if s:NQC_Target=="RCX" ||  s:NQC_Target=="RCX2"
		exe " menu ".s:NQC_Root.'API-&Functions.RCX\ features.Program\ (\ )               aProgram()'
		exe " menu ".s:NQC_Root.'API-&Functions.RCX\ features.SetWatch\ (hours,minutes)   aSetWatch(,);<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.RCX\ features.Watch\ (\n)                 aWatch()'
		exe "imenu ".s:NQC_Root.'API-&Functions.RCX\ features.Program\ (\ )                Program()'
		exe "imenu ".s:NQC_Root.'API-&Functions.RCX\ features.SetWatch\ (hours,minutes)    SetWatch(,);<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.RCX\ features.Watch\ (\n)                  Watch()'
	endif
	if s:NQC_Target=="RCX2"
		exe " menu ".s:NQC_Root.'API-&Functions.RCX\ features.BatteryLevel\ (\ )          aBatteryLevel()'
		exe " menu ".s:NQC_Root.'API-&Functions.RCX\ features.FirmwareVersion\ (\ )       aFirmwareVersion()'
		exe " menu ".s:NQC_Root.'API-&Functions.RCX\ features.SelectProgram\ (n)          aSelectProgram();<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.RCX\ features.BatteryLevel\ (\ )           BatteryLevel()'
		exe "imenu ".s:NQC_Root.'API-&Functions.RCX\ features.FirmwareVersion\ (\ )        FirmwareVersion()'
		exe "imenu ".s:NQC_Root.'API-&Functions.RCX\ features.SelectProgram\ (n)           SelectProgram();<Esc>F(a'
	endif
	"----- SCOUT features -----------------------------------------------------------------------
	if s:NQC_Target=="Scout"
		exe " menu ".s:NQC_Root.'API-&Functions.Scout\ features.EventFeedback\ (\ )                           aEventFeedback()'
		exe " menu ".s:NQC_Root.'API-&Functions.Scout\ features.ScoutRules\ (n)                               aScoutRules()<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.Scout\ features.SetEventFeedback\ (events)                    aSetEventFeedback();<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.Scout\ features.SetLight\ (mode)                              aSetLight();<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.Scout\ features.SetScoutRules\ (motion,touch,light,time,fx)   aSetScoutRules(,,,,);<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.Scout\ features.SetScoutMode\ (mode)                          aSetScoutMode();<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.Scout\ features.EventFeedback\ (\ )                            EventFeedback()'
		exe "imenu ".s:NQC_Root.'API-&Functions.Scout\ features.ScoutRules\ (n)                                ScoutRules()<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.Scout\ features.SetEventFeedback\ (events)                     SetEventFeedback();<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.Scout\ features.SetLight\ (mode)                               SetLight();<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.Scout\ features.SetScoutRules\ (motion,touch,light,time,fx)    SetScoutRules(,,,,);<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.Scout\ features.SetScoutMode\ (mode)                           SetScoutMode();<Esc>F(a'
	endif
	"----- CYBERMASTER features -----------------------------------------------------------------------
	if s:NQC_Target=="CM"
		exe " menu ".s:NQC_Root.'API-&Functions.cybermaster\ features.Drive\ (motor0,motor1)                  aDrive(,);<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.cybermaster\ features.OnWait\ (motors,time)                   aOnWait(,);<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.cybermaster\ features.OnWaitDifferent\ (motors,n0,n1,n2,time) aOnWaitDifferent(,,,,);<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.cybermaster\ features.ClearTachoCounter\ (motors)             aClearTachoCounter();<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.cybermaster\ features.TachoCount\ (n)                         aTachoCount()<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.cybermaster\ features.TachoSpeed\ (n)                         aTachoSpeed()<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.cybermaster\ features.ExternalMotorRunning\ (\n)              aExternalMotorRunning()'
		exe " menu ".s:NQC_Root.'API-&Functions.cybermaster\ features.AGC\ (\ )                               aAGC()'
		exe "imenu ".s:NQC_Root.'API-&Functions.cybermaster\ features.Drive\ (motor0,motor1)                   Drive(,);<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.cybermaster\ features.OnWait\ (motors,time)                    OnWait(,);<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.cybermaster\ features.OnWaitDifferent\ (motors,n0,n1,n2,time)  OnWaitDifferent(,,,,);<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.cybermaster\ features.ClearTachoCounter\ (motors)              ClearTachoCounter();<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.cybermaster\ features.TachoCount\ (n)                          TachoCount()<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.cybermaster\ features.TachoSpeed\ (n)                          TachoSpeed()<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.cybermaster\ features.ExternalMotorRunning\ (\n)               ExternalMotorRunning()'
		exe "imenu ".s:NQC_Root.'API-&Functions.cybermaster\ features.AGC\ (\ )                                AGC()'
	endif
	"----- datalog ----------------------------------------------------------------------------
	if s:NQC_Target=="RCX" || s:NQC_Target=="RCX2"
		exe " menu ".s:NQC_Root.'API-&Functions.datalog.AddToDatalog\ (value)              aAddToDatalog();<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.datalog.CreateDatalog\ (size)              aCreateDatalog();<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.datalog.UploadDatalog\ (start,count)       aUploadDatalog(,);<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.datalog.AddToDatalog\ (value)               AddToDatalog();<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.datalog.CreateDatalog\ (size)               CreateDatalog();<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.datalog.UploadDatalog\ (start,count)        UploadDatalog(,);<Esc>F(a'
	endif
	"----- global control  --------------------------------------------------------------------
	if s:NQC_Target=="RCX2" || s:NQC_Target=="Scout"
		exe " menu ".s:NQC_Root.'API-&Functions.global\ control.SetGlobalOutput\ (outputs,mode)            aSetGlobalOutput(,);<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.global\ control.SetGlobalDirection\ (outputs,mode)         aSetGlobalDirection(,);<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.global\ control.SetMaxPower\ (outputs,power)               aSetMaxPower(,);<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.global\ control.GlobalOutputStatus\ (n)                    aGlobalOutputStatus()<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.global\ control.SetGlobalOutput\ (outputs,mode)             SetGlobalOutput(,);<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.global\ control.SetGlobalDirection\ (outputs,mode)          SetGlobalDirection(,);<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.global\ control.SetMaxPower\ (outputs,power)                SetMaxPower(,);<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.global\ control.GlobalOutputStatus\ (n)                     GlobalOutputStatus()<Esc>F(a'
	endif
	"----- serial  ----------------------------------------------------------------------------
	if s:NQC_Target=="RCX2"
		exe " menu ".s:NQC_Root.'API-&Functions.serial.InternalMessage\ (message)          aInternalMessage();<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.serial.SetSerialComm\ (settings)           aSetSerialComm();<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.serial.SetSerialPacket\ (settings)         aSetSerialPacket();<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.serial.SetSerialData\ (n,value)            aSetSerialData(,);<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.serial.SerialComm\ (\ )                    aSerialComm()'
		exe " menu ".s:NQC_Root.'API-&Functions.serial.SerialData\ (n)                     aSerialData()<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.serial.SerialPacket\ (\ )                  aSerialPacket()'
		exe " menu ".s:NQC_Root.'API-&Functions.serial.SendSerial\ (start,count)           aSendSerial(,);<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.serial.InternalMessage\ (message)           InternalMessage();<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.serial.SetSerialComm\ (settings)            SetSerialComm();<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.serial.SetSerialPacket\ (settings)          SetSerialPacket();<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.serial.SetSerialData\ (n,value)             SetSerialData(,);<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.serial.SerialComm\ (\ )                     SerialComm()'
		exe "imenu ".s:NQC_Root.'API-&Functions.serial.SerialData\ (n)                      SerialData()<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.serial.SerialPacket\ (\ )                   SerialPacket()'
		exe "imenu ".s:NQC_Root.'API-&Functions.serial.SendSerial\ (start,count)            SendSerial(,);<Esc>F(a'
	endif
	"----- VLL  --------------------------------------------------------------------------------
	if s:NQC_Target=="Scout"
		exe " menu ".s:NQC_Root.'API-&Functions.VLL.SendVLL\ (value)                      aSendVLL();<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.VLL.SendVLL\ (value)                       SendVLL();<Esc>F(a'
	endif
	"----- access control ----------------------------------------------------------------------
	if s:NQC_Target=="RCX2" || s:NQC_Target=="Scout"
		exe " menu ".s:NQC_Root.'API-&Functions.access\ control.SetPriority\ (p)          aSetPriority();<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.access\ control.SetPriority\ (p)           SetPriority();<Esc>F(a'
	endif
	"----- RCX2 events -------------------------------------------------------------------------
	if s:NQC_Target=="RCX2"
		exe " menu ".s:NQC_Root.'API-&Functions.RCX2\ events.CalibrateEvent\ (event,lower,upper,hyst)    aCalibrateEvent(,,,);<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.RCX2\ events.ClearAllEvents\ (\ )                        aClearAllEvents()'
		exe " menu ".s:NQC_Root.'API-&Functions.RCX2\ events.ClearEvent\ (event)                         aClearEvent()<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.RCX2\ events.ClickCounter\ (event)                       aClickCounter()<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.RCX2\ events.ClickTime\ (event)                          aClickTime()<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.RCX2\ events.Event\ (event)                              aEvent();<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.RCX2\ events.EventState\ (event)                         aEventState()<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.RCX2\ events.Hysteresis\ (event)                         aHysteresis()<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.RCX2\ events.LowerLimit\ (event)                         aLowerLimit()<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.RCX2\ events.SetClickCounter\ (event,value)              aSetClickCounter();<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.RCX2\ events.SetClickTime\ (event,value)                 aSetClickTime();<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.RCX2\ events.SetEvent\ (event,source,type)               aSetEvent();<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.RCX2\ events.SetHysteresis\ (event,value)                aSetHysteresis();<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.RCX2\ events.SetLowerLimit\ (event,limit)                aSetLowerLimit();<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.RCX2\ events.SetUpperLimit\ (event,limit)                aSetUpperLimit();<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.RCX2\ events.UpperLimit\ (event)                         aUpperLimit()<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.RCX2\ events.ActiveEvents\ (task)                        aActiveEvents()<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.RCX2\ events.CurrentEvents\ (\ )                         aCurrentEvents();'
		exe " menu ".s:NQC_Root.'API-&Functions.RCX2\ events.Events\ (events)                            aEvents()<Esc>F(a'
		"
		exe "imenu ".s:NQC_Root.'API-&Functions.RCX2\ events.CalibrateEvent\ (event,lower,upper,hyst)    CalibrateEvent(,,,);<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.RCX2\ events.ClearAllEvents\ (\ )                        ClearAllEvents()'
		exe "imenu ".s:NQC_Root.'API-&Functions.RCX2\ events.ClearEvent\ (event)                         ClearEvent()<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.RCX2\ events.ClickCounter\ (event)                       ClickCounter()<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.RCX2\ events.ClickTime\ (event)                          ClickTime()<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.RCX2\ events.Event\ (event)                              Event();<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.RCX2\ events.EventState\ (event)                         EventState()<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.RCX2\ events.Hysteresis\ (event)                         Hysteresis()<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.RCX2\ events.LowerLimit\ (event)                         LowerLimit()<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.RCX2\ events.SetClickCounter\ (event,value)              SetClickCounter();<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.RCX2\ events.SetClickTime\ (event,value)                 SetClickTime();<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.RCX2\ events.SetEvent\ (event,source,type)               SetEvent();<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.RCX2\ events.SetHysteresis\ (event,value)                SetHysteresis();<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.RCX2\ events.SetLowerLimit\ (event,limit)                SetLowerLimit();<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.RCX2\ events.SetUpperLimit\ (event,limit)                SetUpperLimit();<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.RCX2\ events.UpperLimit\ (event)                         UpperLimit()<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.RCX2\ events.ActiveEvents\ (task)                        ActiveEvents()<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.RCX2\ events.CurrentEvents\ (\ )                         CurrentEvents();'
		exe "imenu ".s:NQC_Root.'API-&Functions.RCX2\ events.Events\ (events)                            Events()<Esc>F(a'
	endif
	"----- Scout events ------------------------------------------------------------------------
	if s:NQC_Target=="Scout"
		exe " menu ".s:NQC_Root.'API-&Functions.Scout\ events.ActiveEvents\ (task)                aActiveEvents();<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.Scout\ events.CounterLimit\ (n)                   aCounterLimit()<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.Scout\ events.Events\ (events)                    aEvents();<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.Scout\ events.SetSensorClickTime\ (time)          aSetSensorClickTime();<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.Scout\ events.SetCounterLimit\ (n,value)          aSetCounterLimit(,);<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.Scout\ events.SetTimerLimit\ (n,value)            aSetTimerLimit(,);<Esc>F(a'
		exe " menu ".s:NQC_Root.'API-&Functions.Scout\ events.TimerLimit\ (n)                     aTimerLimit()<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.Scout\ events.ActiveEvents\ (task)                 ActiveEvents();<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.Scout\ events.CounterLimit\ (n)                    CounterLimit()<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.Scout\ events.Events\ (events)                     Events();<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.Scout\ events.SetSensorClickTime\ (time)           SetSensorClickTime();<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.Scout\ events.SetCounterLimit\ (n,value)           SetCounterLimit(,);<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.Scout\ events.SetTimerLimit\ (n,value)             SetTimerLimit(,);<Esc>F(a'
		exe "imenu ".s:NQC_Root.'API-&Functions.Scout\ events.TimerLimit\ (n)                      TimerLimit()<Esc>F(a'
	endif
	"
	"
	"===============================================================================================
	"----- Menu : API-Constants --------------------------------------------------------------------
	"===============================================================================================
	"
	"----- access control ---------------------------------------------------------------------
	if s:NQC_Target=="RCX2" || s:NQC_Target=="Scout"
		exe " menu ".s:NQC_Root.'API-C&onstants.access\ control.ACQUIRE_OUT_A   aACQUIRE_OUT_A'
		exe " menu ".s:NQC_Root.'API-C&onstants.access\ control.ACQUIRE_OUT_B   aACQUIRE_OUT_B'
		exe " menu ".s:NQC_Root.'API-C&onstants.access\ control.ACQUIRE_OUT_C   aACQUIRE_OUT_C'
		exe " menu ".s:NQC_Root.'API-C&onstants.access\ control.ACQUIRE_SOUND   aACQUIRE_SOUND'
		exe "imenu ".s:NQC_Root.'API-C&onstants.access\ control.ACQUIRE_OUT_A    ACQUIRE_OUT_A'
		exe "imenu ".s:NQC_Root.'API-C&onstants.access\ control.ACQUIRE_OUT_B    ACQUIRE_OUT_B'
		exe "imenu ".s:NQC_Root.'API-C&onstants.access\ control.ACQUIRE_OUT_C    ACQUIRE_OUT_C'
		exe "imenu ".s:NQC_Root.'API-C&onstants.access\ control.ACQUIRE_SOUND    ACQUIRE_SOUND'
	endif
	if s:NQC_Target=="RCX2"
		exe " menu ".s:NQC_Root.'API-C&onstants.access\ control.ACQUIRE_USER_1  aACQUIRE_USER_1'
		exe " menu ".s:NQC_Root.'API-C&onstants.access\ control.ACQUIRE_USER_2  aACQUIRE_USER_2'
		exe " menu ".s:NQC_Root.'API-C&onstants.access\ control.ACQUIRE_USER_3  aACQUIRE_USER_3'
		exe " menu ".s:NQC_Root.'API-C&onstants.access\ control.ACQUIRE_USER_4  aACQUIRE_USER_4'
		exe "imenu ".s:NQC_Root.'API-C&onstants.access\ control.ACQUIRE_USER_1   ACQUIRE_USER_1'
		exe "imenu ".s:NQC_Root.'API-C&onstants.access\ control.ACQUIRE_USER_2   ACQUIRE_USER_2'
		exe "imenu ".s:NQC_Root.'API-C&onstants.access\ control.ACQUIRE_USER_3   ACQUIRE_USER_3'
		exe "imenu ".s:NQC_Root.'API-C&onstants.access\ control.ACQUIRE_USER_4   ACQUIRE_USER_4'
	endif
	"----- display ----------------------------------------------------------------------------
	if s:NQC_Target=="RCX" || s:NQC_Target=="RCX2"
		exe " menu ".s:NQC_Root.'API-C&onstants.display.DISPLAY_OUT_A           aDISPLAY_OUT_A'
		exe " menu ".s:NQC_Root.'API-C&onstants.display.DISPLAY_OUT_B           aDISPLAY_OUT_B'
		exe " menu ".s:NQC_Root.'API-C&onstants.display.DISPLAY_OUT_C           aDISPLAY_OUT_C'
		exe " menu ".s:NQC_Root.'API-C&onstants.display.DISPLAY_SENSOR_1        aDISPLAY_SENSOR_1'
		exe " menu ".s:NQC_Root.'API-C&onstants.display.DISPLAY_SENSOR_2        aDISPLAY_SENSOR_2'
		exe " menu ".s:NQC_Root.'API-C&onstants.display.DISPLAY_SENSOR_3        aDISPLAY_SENSOR_3'
		exe " menu ".s:NQC_Root.'API-C&onstants.display.DISPLAY_WATCH           aDISPLAY_WATCH'
		exe "imenu ".s:NQC_Root.'API-C&onstants.display.DISPLAY_OUT_A            DISPLAY_OUT_A'
		exe "imenu ".s:NQC_Root.'API-C&onstants.display.DISPLAY_OUT_B            DISPLAY_OUT_B'
		exe "imenu ".s:NQC_Root.'API-C&onstants.display.DISPLAY_OUT_C            DISPLAY_OUT_C'
		exe "imenu ".s:NQC_Root.'API-C&onstants.display.DISPLAY_SENSOR_1         DISPLAY_SENSOR_1'
		exe "imenu ".s:NQC_Root.'API-C&onstants.display.DISPLAY_SENSOR_2         DISPLAY_SENSOR_2'
		exe "imenu ".s:NQC_Root.'API-C&onstants.display.DISPLAY_SENSOR_3         DISPLAY_SENSOR_3'
		exe "imenu ".s:NQC_Root.'API-C&onstants.display.DISPLAY_WATCH            DISPLAY_WATCH'
	endif
	if s:NQC_Target=="RCX2"
		exe " menu ".s:NQC_Root.'API-C&onstants.display.DISPLAY_USER            aDISPLAY_USER'
		exe "imenu ".s:NQC_Root.'API-C&onstants.display.DISPLAY_USER             DISPLAY_USER'
	endif
	"----- output  ----------------------------------------------------------------------------
	exe " menu ".s:NQC_Root.'API-C&onstants.output.OUT_A                      aOUT_A'
	exe " menu ".s:NQC_Root.'API-C&onstants.output.OUT_B                      aOUT_B'
	exe " menu ".s:NQC_Root.'API-C&onstants.output.OUT_C                      aOUT_C'
	exe " menu ".s:NQC_Root.'API-C&onstants.output.OUT_FLOAT                  aOUT_FLOAT'
	exe " menu ".s:NQC_Root.'API-C&onstants.output.OUT_FULL                   aOUT_FULL'
	exe " menu ".s:NQC_Root.'API-C&onstants.output.OUT_FWD                    aOUT_FWD'
	exe " menu ".s:NQC_Root.'API-C&onstants.output.OUT_HALF                   aOUT_HALF'
	exe " menu ".s:NQC_Root.'API-C&onstants.output.OUT_LOW                    aOUT_LOW'
	exe " menu ".s:NQC_Root.'API-C&onstants.output.OUT_OFF                    aOUT_OFF'
	exe " menu ".s:NQC_Root.'API-C&onstants.output.OUT_ON                     aOUT_ON'
	exe " menu ".s:NQC_Root.'API-C&onstants.output.OUT_REV                    aOUT_REV'
	exe " menu ".s:NQC_Root.'API-C&onstants.output.OUT_TOGGLE                 aOUT_TOGGLE'
	exe "imenu ".s:NQC_Root.'API-C&onstants.output.OUT_A                       OUT_A'
	exe "imenu ".s:NQC_Root.'API-C&onstants.output.OUT_B                       OUT_B'
	exe "imenu ".s:NQC_Root.'API-C&onstants.output.OUT_C                       OUT_C'
	exe "imenu ".s:NQC_Root.'API-C&onstants.output.OUT_FLOAT                   OUT_FLOAT'
	exe "imenu ".s:NQC_Root.'API-C&onstants.output.OUT_FULL                    OUT_FULL'
	exe "imenu ".s:NQC_Root.'API-C&onstants.output.OUT_FWD                     OUT_FWD'
	exe "imenu ".s:NQC_Root.'API-C&onstants.output.OUT_HALF                    OUT_HALF'
	exe "imenu ".s:NQC_Root.'API-C&onstants.output.OUT_LOW                     OUT_LOW'
	exe "imenu ".s:NQC_Root.'API-C&onstants.output.OUT_OFF                     OUT_OFF'
	exe "imenu ".s:NQC_Root.'API-C&onstants.output.OUT_ON                      OUT_ON'
	exe "imenu ".s:NQC_Root.'API-C&onstants.output.OUT_REV                     OUT_REV'
	exe "imenu ".s:NQC_Root.'API-C&onstants.output.OUT_TOGGLE                  OUT_TOGGLE'
	if s:NQC_Target=="CM"
		exe " menu ".s:NQC_Root.'API-C&onstants.output.OUT_L                    aOUT_L'
		exe " menu ".s:NQC_Root.'API-C&onstants.output.OUT_R                    aOUT_R'
		exe " menu ".s:NQC_Root.'API-C&onstants.output.OUT_X                    aOUT_X'
		exe "imenu ".s:NQC_Root.'API-C&onstants.output.OUT_L                     OUT_L'
		exe "imenu ".s:NQC_Root.'API-C&onstants.output.OUT_R                     OUT_R'
		exe "imenu ".s:NQC_Root.'API-C&onstants.output.OUT_X                     OUT_X'
	endif
	"----- sensor  ----------------------------------------------------------------------------
	if s:NQC_Target=="RCX2"
		exe " menu ".s:NQC_Root.'API-C&onstants.serial.SERIAL_COMM_DEFAULT      aSERIAL_COMM_DEFAULT'
		exe " menu ".s:NQC_Root.'API-C&onstants.serial.SERIAL_COMM_4800         aSERIAL_COMM_4800'
		exe " menu ".s:NQC_Root.'API-C&onstants.serial.SERIAL_COMM_DUTY25       aSERIAL_COMM_DUTY25'
		exe " menu ".s:NQC_Root.'API-C&onstants.serial.SERIAL_COMM_76KHZ        aSERIAL_COMM_76KHZ'
		exe " menu ".s:NQC_Root.'API-C&onstants.serial.SERIAL_PACKET_DEFAULT    aSERIAL_PACKET_DEFAULT'
		exe " menu ".s:NQC_Root.'API-C&onstants.serial.SERIAL_PACKET_PREAMBLE   aSERIAL_PACKET_PREAMBLE'
		exe " menu ".s:NQC_Root.'API-C&onstants.serial.SERIAL_PACKET_NEGATED    aSERIAL_PACKET_NEGATED'
		exe " menu ".s:NQC_Root.'API-C&onstants.serial.SERIAL_PACKET_CHECKSUM   aSERIAL_PACKET_CHECKSUM'
		exe " menu ".s:NQC_Root.'API-C&onstants.serial.SERIAL_PACKET_RCX        aSERIAL_PACKET_RCX'
		exe "imenu ".s:NQC_Root.'API-C&onstants.serial.SERIAL_COMM_DEFAULT       SERIAL_COMM_DEFAULT'
		exe "imenu ".s:NQC_Root.'API-C&onstants.serial.SERIAL_COMM_4800          SERIAL_COMM_4800'
		exe "imenu ".s:NQC_Root.'API-C&onstants.serial.SERIAL_COMM_DUTY25        SERIAL_COMM_DUTY25'
		exe "imenu ".s:NQC_Root.'API-C&onstants.serial.SERIAL_COMM_76KHZ         SERIAL_COMM_76KHZ'
		exe "imenu ".s:NQC_Root.'API-C&onstants.serial.SERIAL_PACKET_DEFAULT     SERIAL_PACKET_DEFAULT'
		exe "imenu ".s:NQC_Root.'API-C&onstants.serial.SERIAL_PACKET_PREAMBLE    SERIAL_PACKET_PREAMBLE'
		exe "imenu ".s:NQC_Root.'API-C&onstants.serial.SERIAL_PACKET_NEGATED     SERIAL_PACKET_NEGATED'
		exe "imenu ".s:NQC_Root.'API-C&onstants.serial.SERIAL_PACKET_CHECKSUM    SERIAL_PACKET_CHECKSUM'
		exe "imenu ".s:NQC_Root.'API-C&onstants.serial.SERIAL_PACKET_RCX         SERIAL_PACKET_RCX'
	endif
	"----- sensor  ----------------------------------------------------------------------------
	exe " menu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_1                 aSENSOR_1'
	exe " menu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_2                 aSENSOR_2'
	exe " menu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_3                 aSENSOR_3'
	exe "imenu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_1                  SENSOR_1'
	exe "imenu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_2                  SENSOR_2'
	exe "imenu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_3                  SENSOR_3'
	if s:NQC_Target=="RCX" || s:NQC_Target=="RCX2"
		exe " menu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_CELSIUS           aSENSOR_CELSIUS'
		exe " menu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_EDGE              aSENSOR_EDGE'
		exe " menu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_FAHRENHEIT        aSENSOR_FAHRENHEIT'
		exe " menu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_LIGHT             aSENSOR_LIGHT'
		exe " menu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_PULSE             aSENSOR_PULSE'
		exe " menu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_ROTATION          aSENSOR_ROTATION'
		exe " menu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_TOUCH             aSENSOR_TOUCH'
		exe " menu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_MODE_CELSIUS      aSENSOR_MODE_CELSIUS'
		exe " menu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_MODE_FAHRENHEIT   aSENSOR_MODE_FAHRENHEIT'
		exe " menu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_MODE_ROTATION     aSENSOR_MODE_ROTATION'
		exe "imenu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_CELSIUS            SENSOR_CELSIUS'
		exe "imenu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_EDGE               SENSOR_EDGE'
		exe "imenu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_FAHRENHEIT         SENSOR_FAHRENHEIT'
		exe "imenu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_LIGHT              SENSOR_LIGHT'
		exe "imenu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_PULSE              SENSOR_PULSE'
		exe "imenu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_ROTATION           SENSOR_ROTATION'
		exe "imenu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_TOUCH              SENSOR_TOUCH'
		exe "imenu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_MODE_CELSIUS       SENSOR_MODE_CELSIUS'
		exe "imenu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_MODE_FAHRENHEIT    SENSOR_MODE_FAHRENHEIT'
		exe "imenu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_MODE_ROTATION      SENSOR_MODE_ROTATION'
	endif
	if s:NQC_Target=="RCX" || s:NQC_Target=="RCX2" ||  s:NQC_Target=="CM"
		exe " menu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_MODE_BOOL         aSENSOR_MODE_BOOL'
		exe " menu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_MODE_EDGE         aSENSOR_MODE_EDGE'
		exe " menu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_MODE_PERCENT      aSENSOR_MODE_PERCENT'
		exe " menu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_MODE_PULSE        aSENSOR_MODE_PULSE'
		exe " menu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_MODE_RAW          aSENSOR_MODE_RAW'
		exe "imenu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_MODE_BOOL          SENSOR_MODE_BOOL'
		exe "imenu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_MODE_EDGE          SENSOR_MODE_EDGE'
		exe "imenu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_MODE_PERCENT       SENSOR_MODE_PERCENT'
		exe "imenu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_MODE_PULSE         SENSOR_MODE_PULSE'
		exe "imenu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_MODE_RAW           SENSOR_MODE_RAW'
	endif
	if s:NQC_Target=="RCX" || s:NQC_Target=="RCX2"
		exe " menu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_TYPE_LIGHT        aSENSOR_TYPE_LIGHT'
		exe " menu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_TYPE_NONE         aSENSOR_TYPE_NONE'
		exe " menu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_TYPE_ROTATION     aSENSOR_TYPE_ROTATION'
		exe " menu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_TYPE_TEMPERATURE  aSENSOR_TYPE_TEMPERATURE'
		exe " menu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_TYPE_TOUCH        aSENSOR_TYPE_TOUCH'
		exe "imenu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_TYPE_LIGHT         SENSOR_TYPE_LIGHT'
		exe "imenu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_TYPE_NONE          SENSOR_TYPE_NONE'
		exe "imenu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_TYPE_ROTATION      SENSOR_TYPE_ROTATION'
		exe "imenu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_TYPE_TEMPERATURE   SENSOR_TYPE_TEMPERATURE'
		exe "imenu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_TYPE_TOUCH         SENSOR_TYPE_TOUCH'
	endif
	if s:NQC_Target=="CM"
		exe " menu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_L                 aSENSOR_L'
		exe " menu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_M                 aSENSOR_M'
		exe " menu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_R                 aSENSOR_R'
		exe "imenu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_L                  SENSOR_L'
		exe "imenu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_M                  SENSOR_M'
		exe "imenu ".s:NQC_Root.'API-C&onstants.sensor.SENSOR_R                  SENSOR_R'
	endif
	"----- sound   ----------------------------------------------------------------------------
	exe " menu ".s:NQC_Root.'API-C&onstants.sound.SOUND_CLICK                 aSOUND_CLICK'
	exe " menu ".s:NQC_Root.'API-C&onstants.sound.SOUND_DOUBLE_BEEP           aSOUND_DOUBLE_BEEP'
	exe " menu ".s:NQC_Root.'API-C&onstants.sound.SOUND_DOWN                  aSOUND_DOWN'
	exe " menu ".s:NQC_Root.'API-C&onstants.sound.SOUND_FAST_UP               aSOUND_FAST_UP'
	exe " menu ".s:NQC_Root.'API-C&onstants.sound.SOUND_LOW_BEEP              aSOUND_LOW_BEEP'
	exe " menu ".s:NQC_Root.'API-C&onstants.sound.SOUND_UP                    aSOUND_UP'
	exe "imenu ".s:NQC_Root.'API-C&onstants.sound.SOUND_CLICK                  SOUND_CLICK'
	exe "imenu ".s:NQC_Root.'API-C&onstants.sound.SOUND_DOUBLE_BEEP            SOUND_DOUBLE_BEEP'
	exe "imenu ".s:NQC_Root.'API-C&onstants.sound.SOUND_DOWN                   SOUND_DOWN'
	exe "imenu ".s:NQC_Root.'API-C&onstants.sound.SOUND_FAST_UP                SOUND_FAST_UP'
	exe "imenu ".s:NQC_Root.'API-C&onstants.sound.SOUND_LOW_BEEP               SOUND_LOW_BEEP'
	exe "imenu ".s:NQC_Root.'API-C&onstants.sound.SOUND_UP                     SOUND_UP'
	"----- RCX2 events ------------------------------------------------------------------------
	if s:NQC_Target=="RCX2"
		exe " menu ".s:NQC_Root.'API-C&onstants.RCX2\ events.EVENT_TYPE_PRESSED       aEVENT_TYPE_PRESSED'
		exe " menu ".s:NQC_Root.'API-C&onstants.RCX2\ events.EVENT_TYPE_RELEASED      aEVENT_TYPE_RELEASED'
		exe " menu ".s:NQC_Root.'API-C&onstants.RCX2\ events.EVENT_TYPE_PULSE         aEVENT_TYPE_PULSE'
		exe " menu ".s:NQC_Root.'API-C&onstants.RCX2\ events.EVENT_TYPE_EDGE          aEVENT_TYPE_EDGE'
		exe " menu ".s:NQC_Root.'API-C&onstants.RCX2\ events.EVENT_TYPE_FASTCHANGE    aEVENT_TYPE_FASTCHANGE'
		exe " menu ".s:NQC_Root.'API-C&onstants.RCX2\ events.EVENT_TYPE_LOW           aEVENT_TYPE_LOW'
		exe " menu ".s:NQC_Root.'API-C&onstants.RCX2\ events.EVENT_TYPE_NORMAL        aEVENT_TYPE_NORMAL'
		exe " menu ".s:NQC_Root.'API-C&onstants.RCX2\ events.EVENT_TYPE_HIGH          aEVENT_TYPE_HIGH'
		exe " menu ".s:NQC_Root.'API-C&onstants.RCX2\ events.EVENT_TYPE_CLICK         aEVENT_TYPE_CLICK'
		exe " menu ".s:NQC_Root.'API-C&onstants.RCX2\ events.EVENT_TYPE_DOUBLECLICK   aEVENT_TYPE_DOUBLECLICK'
		exe " menu ".s:NQC_Root.'API-C&onstants.RCX2\ events.EVENT_TYPE_MESSAGE       aEVENT_TYPE_MESSAGE'
		exe "imenu ".s:NQC_Root.'API-C&onstants.RCX2\ events.EVENT_TYPE_PRESSED        EVENT_TYPE_PRESSED'
		exe "imenu ".s:NQC_Root.'API-C&onstants.RCX2\ events.EVENT_TYPE_RELEASED       EVENT_TYPE_RELEASED'
		exe "imenu ".s:NQC_Root.'API-C&onstants.RCX2\ events.EVENT_TYPE_PULSE          EVENT_TYPE_PULSE'
		exe "imenu ".s:NQC_Root.'API-C&onstants.RCX2\ events.EVENT_TYPE_EDGE           EVENT_TYPE_EDGE'
		exe "imenu ".s:NQC_Root.'API-C&onstants.RCX2\ events.EVENT_TYPE_FASTCHANGE     EVENT_TYPE_FASTCHANGE'
		exe "imenu ".s:NQC_Root.'API-C&onstants.RCX2\ events.EVENT_TYPE_LOW            EVENT_TYPE_LOW'
		exe "imenu ".s:NQC_Root.'API-C&onstants.RCX2\ events.EVENT_TYPE_NORMAL         EVENT_TYPE_NORMAL'
		exe "imenu ".s:NQC_Root.'API-C&onstants.RCX2\ events.EVENT_TYPE_HIGH           EVENT_TYPE_HIGH'
		exe "imenu ".s:NQC_Root.'API-C&onstants.RCX2\ events.EVENT_TYPE_CLICK          EVENT_TYPE_CLICK'
		exe "imenu ".s:NQC_Root.'API-C&onstants.RCX2\ events.EVENT_TYPE_DOUBLECLICK    EVENT_TYPE_DOUBLECLICK'
		exe "imenu ".s:NQC_Root.'API-C&onstants.RCX2\ events.EVENT_TYPE_MESSAGE        EVENT_TYPE_MESSAGE'
	endif
	"----- Scout events -----------------------------------------------------------------------
	if s:NQC_Target=="Scout"
		exe " menu ".s:NQC_Root.'API-C&onstants.Scout\ events.EVENT_1_PRESSED         aEVENT_1_PRESSED'
		exe " menu ".s:NQC_Root.'API-C&onstants.Scout\ events.EVENT_2_PRESSED         aEVENT_2_PRESSED'
		exe " menu ".s:NQC_Root.'API-C&onstants.Scout\ events.EVENT_1_RELEASED        aEVENT_1_RELEASED'
		exe " menu ".s:NQC_Root.'API-C&onstants.Scout\ events.EVENT_2_RELEASED        aEVENT_2_RELEASED'
		exe " menu ".s:NQC_Root.'API-C&onstants.Scout\ events.EVENT_LIGHT_HIGH        aEVENT_LIGHT_HIGH'
		exe " menu ".s:NQC_Root.'API-C&onstants.Scout\ events.EVENT_LIGHT_NORMAL      aEVENT_LIGHT_NORMAL'
		exe " menu ".s:NQC_Root.'API-C&onstants.Scout\ events.EVENT_LIGHT_LOW         aEVENT_LIGHT_LOW'
		exe " menu ".s:NQC_Root.'API-C&onstants.Scout\ events.EVENT_LIGHT_CLICK       aEVENT_LIGHT_CLICK'
		exe " menu ".s:NQC_Root.'API-C&onstants.Scout\ events.EVENT_LIGHT_DOUBLECLICK aEVENT_LIGHT_DOUBLECLICK'
		exe " menu ".s:NQC_Root.'API-C&onstants.Scout\ events.EVENT_COUNTER_0         aEVENT_COUNTER_0'
		exe " menu ".s:NQC_Root.'API-C&onstants.Scout\ events.EVENT_COUNTER_1         aEVENT_COUNTER_1'
		exe " menu ".s:NQC_Root.'API-C&onstants.Scout\ events.EVENT_TIMER_0           aEVENT_TIMER_0'
		exe " menu ".s:NQC_Root.'API-C&onstants.Scout\ events.EVENT_TIMER_1           aEVENT_TIMER_1'
		exe " menu ".s:NQC_Root.'API-C&onstants.Scout\ events.EVENT_TIMER_2           aEVENT_TIMER_2'
		exe " menu ".s:NQC_Root.'API-C&onstants.Scout\ events.EVENT_MESSAGE           aEVENT_MESSAGE'
		exe "imenu ".s:NQC_Root.'API-C&onstants.Scout\ events.EVENT_1_PRESSED          EVENT_1_PRESSED'
		exe "imenu ".s:NQC_Root.'API-C&onstants.Scout\ events.EVENT_2_PRESSED          EVENT_2_PRESSED'
		exe "imenu ".s:NQC_Root.'API-C&onstants.Scout\ events.EVENT_1_RELEASED         EVENT_1_RELEASED'
		exe "imenu ".s:NQC_Root.'API-C&onstants.Scout\ events.EVENT_2_RELEASED         EVENT_2_RELEASED'
		exe "imenu ".s:NQC_Root.'API-C&onstants.Scout\ events.EVENT_LIGHT_HIGH         EVENT_LIGHT_HIGH'
		exe "imenu ".s:NQC_Root.'API-C&onstants.Scout\ events.EVENT_LIGHT_NORMAL       EVENT_LIGHT_NORMAL'
		exe "imenu ".s:NQC_Root.'API-C&onstants.Scout\ events.EVENT_LIGHT_LOW          EVENT_LIGHT_LOW'
		exe "imenu ".s:NQC_Root.'API-C&onstants.Scout\ events.EVENT_LIGHT_CLICK        EVENT_LIGHT_CLICK'
		exe "imenu ".s:NQC_Root.'API-C&onstants.Scout\ events.EVENT_LIGHT_DOUBLECLICK  EVENT_LIGHT_DOUBLECLICK'
		exe "imenu ".s:NQC_Root.'API-C&onstants.Scout\ events.EVENT_COUNTER_0          EVENT_COUNTER_0'
		exe "imenu ".s:NQC_Root.'API-C&onstants.Scout\ events.EVENT_COUNTER_1          EVENT_COUNTER_1'
		exe "imenu ".s:NQC_Root.'API-C&onstants.Scout\ events.EVENT_TIMER_0            EVENT_TIMER_0'
		exe "imenu ".s:NQC_Root.'API-C&onstants.Scout\ events.EVENT_TIMER_1            EVENT_TIMER_1'
		exe "imenu ".s:NQC_Root.'API-C&onstants.Scout\ events.EVENT_TIMER_2            EVENT_TIMER_2'
		exe "imenu ".s:NQC_Root.'API-C&onstants.Scout\ events.EVENT_MESSAGE            EVENT_MESSAGE'
		"
		exe " menu ".s:NQC_Root.'API-C&onstants.LIGHT_ON                              aLIGHT_ON'
		exe " menu ".s:NQC_Root.'API-C&onstants.LIGHT_OFF                             aLIGHT_OFF'
		exe " menu ".s:NQC_Root.'API-C&onstants.SCOUT_MODE_POWER                      aSCOUT_MODE_POWER'
		exe " menu ".s:NQC_Root.'API-C&onstants.SCOUT_MODE_STANDALONE                 aSCOUT_MODE_STANDALONE'
		exe "imenu ".s:NQC_Root.'API-C&onstants.LIGHT_ON                               LIGHT_ON'
		exe "imenu ".s:NQC_Root.'API-C&onstants.LIGHT_OFF                              LIGHT_OFF'
		exe "imenu ".s:NQC_Root.'API-C&onstants.SCOUT_MODE_POWER                       SCOUT_MODE_POWER'
		exe "imenu ".s:NQC_Root.'API-C&onstants.SCOUT_MODE_STANDALONE                  SCOUT_MODE_STANDALONE'
	endif
	"----- misc    ----------------------------------------------------------------------------
	if s:NQC_Target=="RCX" || s:NQC_Target=="RCX2" ||  s:NQC_Target=="Scout"
		exe " menu ".s:NQC_Root.'API-C&onstants.TX_POWER_HI                           aTX_POWER_HI'
		exe " menu ".s:NQC_Root.'API-C&onstants.TX_POWER_LO                           aTX_POWER_LO'
		exe "imenu ".s:NQC_Root.'API-C&onstants.TX_POWER_HI                            TX_POWER_HI'
		exe "imenu ".s:NQC_Root.'API-C&onstants.TX_POWER_LO                            TX_POWER_LO'
	endif
	"
	"
	"===============================================================================================
	"----- Menu : Snippets -------------------------------------------------------------------------
	"===============================================================================================
	"
	if s:NQC_CodeSnippets != ""
		"	
		exe "amenu  <silent> ".s:NQC_Root.'S&nippets.&read\ code\ snippet        <C-C>:call NQC_CodeSnippet("r")<CR>'
		exe "amenu  <silent> ".s:NQC_Root.'S&nippets.&write\ code\ snippet       <C-C>:call NQC_CodeSnippet("w")<CR>'
		exe "vmenu  <silent> ".s:NQC_Root.'S&nippets.&write\ code\ snippet       <C-C>:call NQC_CodeSnippet("wv")<CR>'
		exe "amenu  <silent> ".s:NQC_Root.'S&nippets.&edit\ code\ snippet        <C-C>:call NQC_CodeSnippet("e")<CR>'
	endif
	"
	"===============================================================================================
	"----- Menu : Datalog  -------------------------------------------------------------------------
	"===============================================================================================
	"
	exe "amenu  <silent> ".s:NQC_Root.'&Datalog.&upload\ datalog\ into\ buffer             <C-C>:call NQC_DatalogUpload()<CR>'
	exe "amenu  <silent> ".s:NQC_Root.'&Datalog.-SEP1-                                     :'
	exe "amenu  <silent> ".s:NQC_Root.'&Datalog.show\ y-&plot\                             <C-C>:call NQC_DatalogPlot(1)<CR>'
	exe "amenu  <silent> ".s:NQC_Root.'&Datalog.show\ &x-y-plot\                           <C-C>:call NQC_DatalogPlot(2)<CR>'
	exe "amenu  <silent> ".s:NQC_Root.'&Datalog.&save\ plot\ (<filenam>\.ps)               <C-C>:call NQC_DatalogPlot(10)<CR>'
	exe "amenu  <silent> ".s:NQC_Root.'&Datalog.p&rint\ plot\                              <C-C>:call NQC_DatalogPlot(11)<CR>'
	exe "amenu  <silent> ".s:NQC_Root.'&Datalog.plot\ &type.&impulses                      <C-C>:call NQC_DatalogPlotType("impulses")<CR>'
	exe "amenu  <silent> ".s:NQC_Root.'&Datalog.plot\ &type.&lines                         <C-C>:call NQC_DatalogPlotType("lines")<CR>'
	exe "amenu  <silent> ".s:NQC_Root.'&Datalog.plot\ &type.l&ines+points                  <C-C>:call NQC_DatalogPlotType("linespoints")<CR>'
	exe "amenu  <silent> ".s:NQC_Root.'&Datalog.plot\ &type.&points                        <C-C>:call NQC_DatalogPlotType("points")<CR>'
	exe "amenu  <silent> ".s:NQC_Root.'&Datalog.plot\ &type.&steps                         <C-C>:call NQC_DatalogPlotType("steps")<CR>'
	exe "amenu  <silent> ".s:NQC_Root.'&Datalog.plot\ t&itle                               <C-C>:call NQC_DatalogPlotTitle()<CR>'
	exe "amenu  <silent> ".s:NQC_Root.'&Datalog.-SEP2-                                     :'
	exe "amenu  <silent> ".s:NQC_Root.'&Datalog.&erase\ programs\ and\ datalogs\ from\ RCX <C-C>:call NQC_DatalogClear()<CR>'
	"
	"===============================================================================================
	"----- Menu : NQC-Run  -------------------------------------------------------------------------
	"===============================================================================================
	"
	exe "amenu  ".s:NQC_Root.'&Run.save\ and\ &compile\ \<F9\>                 <C-C>:call NQC_SaveCompile ()<CR>'
	exe "amenu  ".s:NQC_Root.'&Run.-SEP1-                                      :'
	if s:NQC_Target=="RCX" ||  s:NQC_Target=="RCX2"
		exe "amenu  ".s:NQC_Root.'&Run.download\ program\ &1\ to\ RCX            <C-C>:call NQC_CompDown (1)<CR>'
		exe "amenu  ".s:NQC_Root.'&Run.download\ program\ &2\ to\ RCX            <C-C>:call NQC_CompDown (2)<CR>'
		exe "amenu  ".s:NQC_Root.'&Run.download\ program\ &3\ to\ RCX            <C-C>:call NQC_CompDown (3)<CR>'
		exe "amenu  ".s:NQC_Root.'&Run.download\ program\ &4\ to\ RCX            <C-C>:call NQC_CompDown (4)<CR>'
		exe "amenu  ".s:NQC_Root.'&Run.download\ program\ &5\ to\ RCX            <C-C>:call NQC_CompDown (5)<CR>'
		exe "amenu  ".s:NQC_Root.'&Run.-SEP2-                                    :'
		exe "amenu  ".s:NQC_Root.'&Run.download\ program\ 1\ to\ RCX\ and\ Run   <C-C>:call NQC_CompDownRun (1)<CR>'
		exe "amenu  ".s:NQC_Root.'&Run.download\ program\ 2\ to\ RCX\ and\ Run   <C-C>:call NQC_CompDownRun (2)<CR>'
		exe "amenu  ".s:NQC_Root.'&Run.download\ program\ 3\ to\ RCX\ and\ Run   <C-C>:call NQC_CompDownRun (3)<CR>'
		exe "amenu  ".s:NQC_Root.'&Run.download\ program\ 4\ to\ RCX\ and\ Run   <C-C>:call NQC_CompDownRun (4)<CR>'
		exe "amenu  ".s:NQC_Root.'&Run.download\ program\ 5\ to\ RCX\ and\ Run   <C-C>:call NQC_CompDownRun (5)<CR>'
		exe "amenu  ".s:NQC_Root.'&Run.-SEP3-                                    :'
		exe "amenu  ".s:NQC_Root.'&Run.&run\ current\ program                    <C-C>:call NQC_RunCurrent ()<CR>'
		exe "imenu  ".s:NQC_Root.'&Run.-SEP4-                                    :'
		exe "amenu  <silent> ".s:NQC_Root.'&Run.&hardcopy\ buffer\ to\ FILENAME\.ps       <C-C>:call Hardcopy("n")<CR>'
		exe "vmenu  <silent> ".s:NQC_Root.'&Run.hard&copy\ highlighted\ part\ to\ FILENAME\.part\.ps   <C-C>:call Hardcopy("v")<CR>'
		exe "amenu  ".s:NQC_Root.'&Run.-SEP5-                                    :'
		exe "amenu  ".s:NQC_Root.'&Run.&erase\ programs\ and\ datalogs\ from\ RCX <C-C>:call NQC_DatalogClear()<CR>'
		exe "amenu  ".s:NQC_Root.'&Run.download\ &firmware\ to\ RCX               <C-C>:call NQC_DLoadFirmware("normal")<CR>'
	endif
	if s:NQC_Target=="Scout"
		exe "amenu  ".s:NQC_Root.'NQC-&Run.&download\ program\ to\ Scout              <C-C>call NQC_CompDownRun(0)<CR>'
	endif
	if s:NQC_Target=="CM"
		exe "amenu  ".s:NQC_Root.'&Run.&download\ program\ to\ CyberMaster        <C-C>call NQC_CompDownRun(0)<CR>'
	endif
	exe "imenu  ".s:NQC_Root.'&Run.-SEP6-                                :'
	exe "amenu  <silent> ".s:NQC_Root.'&Run.&settings                         <C-C>:call NQC_Settings()<CR>'

endfunction			" function NQC_InitMenu
"
"===============================================================================================
"----- vim Functions ---------------------------------------------------------------------------
"===============================================================================================
"
"
"------------------------------------------------------------------------------
"  Statements : #if .. #else .. #endif 
"  Statements : #ifdef .. #else .. #endif 
"  Statements : #ifndef .. #else .. #endif 
"------------------------------------------------------------------------------
function! NQC_PPIfElse (keyword,mode)
	let identifier = "CONDITION"
	let	identifier = inputdialog("(uppercase) condition for #".a:keyword, identifier )

	if identifier != ""
		if a:mode=='a'
			let zz=    "#".a:keyword."  ".identifier."\n\n"
			let zz= zz."#else      // ----- #".a:keyword." ".identifier."  ----- \n\n"
			let zz= zz."#endif     // ----- #".a:keyword." ".identifier."  ----- \n"
			put =zz
		endif

		if a:mode=='v'
			let zz=    "#".a:keyword."  ".identifier."\n"
			:'<put! =zz
			let zz=    "#else      // ----- #".a:keyword." ".identifier."  ----- \n\n"
			let zz= zz."#endif     // ----- #".a:keyword." ".identifier."  ----- \n"
			:'>put  =zz
			:normal '<
		endif
	endif

endfunction
"
"------------------------------------------------------------------------------
"  Statements : #ifndef .. #define .. #endif 
"------------------------------------------------------------------------------
function! NQC_PPIfDef (arg)
	" use filename without path (:t) and extension (:r) :
	let identifier = toupper(expand("%:t:r"))."_INC"
	let identifier = inputdialog("(uppercase) condition for #ifndef", identifier )
	if identifier != ""
		
		if a:arg=='a'
			let zz=    "#ifndef  ".identifier."\n"
			let zz= zz."#define  ".identifier."\n\n"
			let zz= zz."#endif   // ----- #ifndef ".identifier."  ----- \n"
			put =zz
		endif

		if a:arg=='v'
			let zz=    "#ifndef  ".identifier."\n"
			let zz= zz."#define  ".identifier."\n"
			:'<put! =zz
			let zz=    "#endif   // ----- #ifndef ".identifier."  ----- \n"
			:'>put  =zz
			:normal '<
		endif

	endif
endfunction
"
"------------------------------------------------------------------------------
"  Substitute tags
"------------------------------------------------------------------------------
function! NQC_SubstituteTag( pos1, pos2, tag, replacement )
	" 
	" loop over marked block
	" 
	let linenumber=a:pos1
	while linenumber <= a:pos2
		let line=getline(linenumber)
		" 
		" loop for multiple tags in one line
		" 
		let	start=0
		while match(line,a:tag,start)>=0				" do we have a tag ?
			let frst=match(line,a:tag,start)
			let last=matchend(line,a:tag,start)
			if frst!=-1
				let part1=strpart(line,0,frst)
				let part2=strpart(line,last)
				let line=part1.a:replacement.part2
				"
				" next search starts after the replacement to suppress recursion
				" 
				let start=strlen(part1)+strlen(a:replacement)
			endif
		endwhile
		call setline( linenumber, line )
		let	linenumber=linenumber+1
	endwhile

endfunction    " ----------  end of function  NQC_SubstituteTag  ----------
"
"------------------------------------------------------------------------------
"  C-Comments : Insert a template files
"------------------------------------------------------------------------------
function! NQC_CommentTemplates (arg)

	"----------------------------------------------------------------------
	"  C templates
	"----------------------------------------------------------------------
	if a:arg=='frame'
		let templatefile=s:NQC_Template_Directory.s:NQC_Template_Frame
	endif

	if a:arg=='task'
		let templatefile=s:NQC_Template_Directory.s:NQC_Template_Task
	endif

	if a:arg=='cheader'
		let templatefile=s:NQC_Template_Directory.s:NQC_Template_C_File
	endif


	if filereadable(templatefile)
		let	length= line("$")
		let	pos1  = line(".")+1
		if  a:arg=='cheader' || a:arg=='hheader'
			:goto 1
			let	pos1  = 1
			silent exe '0read '.templatefile
		else
			silent exe 'read '.templatefile
		endif
		let	length= line("$")-length
		let	pos2  = pos1+length-1
		"----------------------------------------------------------------------
		"  frame blocks will be indented
		"----------------------------------------------------------------------
		if a:arg=='frame'
			let	length	= length-1
			silent exe "normal =".length."+"
			let	length	= length+1
		endif
		"----------------------------------------------------------------------
		"  substitute keywords
		"----------------------------------------------------------------------

		call  NQC_SubstituteTag( pos1, pos2, '|FILENAME|',        expand("%:t")        )
		call  NQC_SubstituteTag( pos1, pos2, '|DATE|',            strftime("%x %X %Z") )
		call  NQC_SubstituteTag( pos1, pos2, '|TIME|',            strftime("%X")       )
		call  NQC_SubstituteTag( pos1, pos2, '|YEAR|',            strftime("%Y")       )
		call  NQC_SubstituteTag( pos1, pos2, '|AUTHOR|',          s:NQC_AuthorName     )
		call  NQC_SubstituteTag( pos1, pos2, '|AUTHORREF|',       s:NQC_AuthorRef      )
		call  NQC_SubstituteTag( pos1, pos2, '|PROJECT|',         s:NQC_Project        )
		call  NQC_SubstituteTag( pos1, pos2, '|COPYRIGHTHOLDER|', s:NQC_CopyrightHolder)
		" 

		"----------------------------------------------------------------------
		"  Position the cursor
		"----------------------------------------------------------------------
		exe ':'.pos1
		normal 0
		let linenumber=search('|CURSOR|')
		if linenumber >=pos1 && linenumber<=pos2
			let pos1=match( getline(linenumber) ,"|CURSOR|")
			if  matchend( getline(linenumber) ,"|CURSOR|") == match( getline(linenumber) ,"$" )
				silent! s/|CURSOR|//
				" this is an append like A
				:startinsert!
			else
				silent  s/|CURSOR|//
				call cursor(linenumber,pos1+1)
				" this is an insert like i
				:startinsert
			endif
		endif

	else
		echohl WarningMsg | echo 'template file '.templatefile.' does not exist or is not readable'| echohl None
	endif
	return
endfunction    " ----------  end of function  NQC_CommentTemplates  ----------
"
"------------------------------------------------------------------------------
"  NQC-Comments : Author+Date+Time
"  NQC-Comments : Date+Time
"  NQC-Comments : Date
"------------------------------------------------------------------------------
function! NQC_CommentDateTimeAuthor ()
  put = '//% '.strftime(\"%x - %X\").' ('.s:NQC_AuthorRef.')'
endfunction
"
"------------------------------------------------------------------------------
"  NQC-Statements : do-while
"------------------------------------------------------------------------------
"
function! NQC_DoWhile ()
  let zz=    "do\n{\n}\nwhile (  );"
  let zz= zz."\t\t\t\t// -----  end do-while  -----\n"
	put =zz
	normal  =3+
endfunction
"
"------------------------------------------------------------------------------
"  NQC-Statements : switch
"------------------------------------------------------------------------------
"
function! NQC_CodeSwitch ()
  let zz= "switch (  )\n{\n"
	let zz= zz."case 0:\t\n\t\tbreak;\n\n"
	let zz= zz."case 0:\t\n\t\tbreak;\n\n"
	let zz= zz."case 0:\t\n\t\tbreak;\n\n"
	let zz= zz."case 0:\t\n\t\tbreak;\n\n"
	let zz= zz."default:\t\n\t\tbreak;\n}"
  let zz= zz."\t\t\t\t//  -----  end switch  -----\n"
	put =zz	
	" indent 
	normal  =16+
	" delete case labels
	exe ":.,+12s/0//"
	-11
endfunction
"
"------------------------------------------------------------------------------
"  NQC-Statements : task
"------------------------------------------------------------------------------
function! NQC_CodeTask ()
  let identifier=inputdialog("task name", "main" )
  if identifier==""
    let identifier = "main"
  endif
  let zz=    "task\n".identifier."\t(  )\n{\n\t\n\treturn ;\n}"
  let zz= zz."\t\t\t\t// ----------  end of task ".identifier."  ----------"
  put =zz
endfunction
"
"------------------------------------------------------------------------------
"  NQC-Statements : function
"------------------------------------------------------------------------------
function! NQC_CodeInlineFunction ()
	let identifier=inputdialog("function name", "func")
	if identifier==""
		let identifier = "func"
	endif
	let zz=    "void\n".identifier."\t(  )\n{\n\t\n\treturn ;\n}"
	let zz= zz."\t\t\t\t// ----------  end of function ".identifier."  ----------"
	put =zz
endfunction
"
"------------------------------------------------------------------------------
"  NQC-Statements : subroutine
"------------------------------------------------------------------------------
function! NQC_CodeSubroutine ()
	let identifier=inputdialog("subroutine name", "subr")
	if identifier==""
		let identifier = "subr"
	endif
	let zz=    "sub\n".identifier."\t(  )\n{\n\t\n\treturn ;\n}"
	let zz= zz."\t\t\t\t// ----------  end of subroutine ".identifier."  ----------"
	put =zz
endfunction
"
"------------------------------------------------------------------------------
"  NQC-Statements : acquire / monitor / catch
"------------------------------------------------------------------------------
function! NQC_Acquire ()
  let zz=    "acquire ()\n{\n}\t\t\t// -----  end acquire  -----\n"
  let zz= zz."catch\n{\n}\t\t\t// -----  end catch  -----\n"
  put =zz
	normal  =5+
endfunction
"
function! NQC_Monitor ()
  let zz=    "monitor ()\n{\n}\t\t\t// -----  end monitor  -----\n"
  let zz= zz."catch\n{\n}\t\t\t// -----  end catch  -----\n"
  put =zz
	normal  =5+
endfunction
"
function! NQC_Catch ()
  let zz=    "catch ()\n{\n}\t\t\t// -----  end catch  -----\n"
  put =zz
	normal  =2+
endfunction
"
"------------------------------------------------------------------------------
"  NQC-Statements : save and compile
"------------------------------------------------------------------------------
function! NQC_SaveCompile ()
  let zz= "update | !nqc -T".s:NQC_Target." %"
  exec zz
endfunction
"
"------------------------------------------------------------------------------
"  NQC-Statements : compile, download
"  NQC-Statements : compile, download and run
"  NQC-Statements : run current program
"------------------------------------------------------------------------------
function! NQC_CompDown (n)
  let zz= "!nqc -T".s:NQC_Target." -S".s:NQC_Portname." -d -pgm ".a:n." %"
  exec zz
endfunction
"
function! NQC_CompDownRun (n)
  if s:NQC_Target=="RCX" || s:NQC_Target=="RCX2"
    let zz= "!nqc -T".s:NQC_Target." -S".s:NQC_Portname." -d -pgm ".a:n." % -run"
  else
    let zz= "!nqc -T".s:NQC_Target." -S".s:NQC_Portname." -d %"
  endif
  exec zz
endfunction
"
function! NQC_RunCurrent ()
  if s:NQC_Target=="RCX" || s:NQC_Target=="RCX2"
    let zz= "!nqc -T".s:NQC_Target." -S".s:NQC_Portname." -run"
  endif
  exec zz
endfunction
"
"------------------------------------------------------------------------------
"  NQC-Statements : download firmware
"------------------------------------------------------------------------------
function! NQC_DLoadFirmware (n)
	if a:n=="fast"
		let zz= "!nqc  -S".s:NQC_Portname." -near -firmfast ".s:NQC_RCX_Firmware
	else
		let zz= "!nqc  -S".s:NQC_Portname." -firmware ".s:NQC_RCX_Firmware
	endif
	exec zz
endfunction
"
"------------------------------------------------------------------------------
"  Datalog : variables
"------------------------------------------------------------------------------
let s:NQC_Plot_Type				= "steps"						" Gnuplot style parameter
let s:NQC_Plot_Dataformat	= "y"								" y-plot / x-y-plot
let s:NQC_Plot_Title			= "RCX-Datalog"			" Gnuplot title

"------------------------------------------------------------------------------
"  Datalog : set plot style
"------------------------------------------------------------------------------
function! NQC_DatalogPlotType(type)
	let s:NQC_Plot_Type=a:type
endfunction
"
"------------------------------------------------------------------------------
"  Datalog : set plot title
"------------------------------------------------------------------------------
function! NQC_DatalogPlotTitle()
	let s:NQC_Plot_Title	= inputdialog("Plot Title",  s:NQC_Plot_Title )
endfunction

"------------------------------------------------------------------------------
"  Datalog : datalog upload 
"  1. line initially empty; will be deleted
"------------------------------------------------------------------------------
function! NQC_DatalogUpload ()

	let	filename=browse(0,"open a new datalaog file", ".", "datalog" )
	if filename != ""

		if filereadable(filename)
			exe ":!rm ".filename."  2>/dev/null"  
		endif

		exe ":25vnew ".filename
		exe ":read !nqc -S".s:NQC_Portname." -datalog 2>/dev/null"
		set noswapfile
		exe ":1,1d"

	endif

endfunction
"
"------------------------------------------------------------------------------
"  Datalog : datalog plot
"  n =  1 : show plot      (gnuplot, terminal X11)
"  n =  2 : show x-y-plot  (gnuplot, terminal X11)
"  n = 10 : make hardcopy  (gnuplot, terminal postscript)
"  n = 11 : print plot     (gnuplot, terminal postscript)
"------------------------------------------------------------------------------
function! NQC_DatalogPlot (n)

	if system("which gnuplot 2>/dev/null")==""
		echo "**  program gnuplot is not available  **"
		return
	endif

	let	Sou				= expand("%:p")					" name of the file in the current buffer
	let	tempfile	= tempname()
	let	timestamp	= Sou.'  *  '.strftime("%x - %X").'  *  '.s:NQC_AuthorName
	:execute  "silent :!echo \"set grid \" > ".tempfile
	if a:n==10 || a:n==11
		:execute  "silent :!echo \"set terminal postscript\" >> ".tempfile
	endif
	:execute  "silent:!echo \"set nokey \" >> ".tempfile
	:execute  "silent:!echo \"set timestamp \'".timestamp."\'\" >> ".tempfile
	:execute  "silent:!echo \"set title \'".s:NQC_Plot_Title."\'\" >> ".tempfile
	:execute  "silent:!echo \"plot '-' with ".s:NQC_Plot_Type."\" >> ".tempfile
	"
	"---------- y-plot ------------------------------------------
	if a:n==1
		let s:NQC_Plot_Dataformat	= "y"
		:execute  "silent:!cat % >> ".tempfile
		:execute  "silent:!gnuplot -persist ".tempfile." &"
		:echo "**  quit gnuplot with 'q'  **"
	endif
	"
	"---------- x-y-plot ----------------------------------------
	if a:n==2
		let s:NQC_Plot_Dataformat	= "xy"
		:%s/\(.\+\)\n\(.\+\)/\1 \2/								 " group 2 lines in a x-y-pair
		:execute  "silent:!cat % >> ".tempfile
		:u
		:execute  "silent:!gnuplot -persist ".tempfile." &"
		:echo "**  quit gnuplot with 'q'  **"
	endif
	"
	"---------- generate postscript -----------------------------
	if a:n==10
		if s:NQC_Plot_Dataformat=="xy"
			:%s/\(.\+\)\n\(.\+\)/\1 \2/								 " group 2 lines in a x-y-pair
		endif
		:execute  "silent:!cat % >> ".tempfile
		:execute  "silent:!gnuplot  ".tempfile." > ".Sou.".ps &"
		if s:NQC_Plot_Dataformat=="xy"
			:u
		endif
	endif
	"
	"---------- print postscript --------------------------------
	if a:n==11
		if s:NQC_Plot_Dataformat=="xy"
			:%s/\(.\+\)\n\(.\+\)/\1 \2/								 " group 2 lines in a x-y-pair
		endif
		:execute  "silent:!cat % >> ".tempfile
		:execute  "silent:!gnuplot  ".tempfile." | ".s:NQC_Printer." &"
		if s:NQC_Plot_Dataformat=="xy"
			:u
		endif
	endif

endfunction
"
"------------------------------------------------------------------------------
"  Datalog : erase programs / clear datalog 
"------------------------------------------------------------------------------
function! NQC_DatalogClear ()
  let zz= "!nqc -S".s:NQC_Portname." -clear"
  exec zz
endfunction
"
"
"------------------------------------------------------------------------------
"  NQC-Statements : read / edit code snippet
"------------------------------------------------------------------------------
function! NQC_CodeSnippet(arg1)
	if isdirectory(s:NQC_CodeSnippets)
		"
		" read snippet file, put content below current line
		if a:arg1 == "r"
			let	l:snippetfile=browse(0,"read a code snippet",s:NQC_CodeSnippets,"")
			if filereadable(l:snippetfile)
				let	length= line("$")
				:execute "read ".l:snippetfile
				let	length= line("$")-length-1
				if length>=0
					silent exe "normal =".length."+"
				endif
			endif
		endif
		"
		"
		" update current buffer / split window / edit snippet file
		" 
		if a:arg1 == "e"
			let	l:snippetfile=browse(0,"edit a code snippet",s:NQC_CodeSnippets,"")
			if l:snippetfile != ""
				:execute "update! | split | edit ".l:snippetfile
			endif
		endif
		"
		" write whole buffer into snippet file 
		" 
		if a:arg1 == "w"
			let	l:snippetfile=browse(0,"write a code snippet",s:NQC_CodeSnippets,"")
			if l:snippetfile != ""
				if filereadable(l:snippetfile)
					if confirm("File exists ! Overwrite ? ", "&Cancel\n&No\n&Yes") != 3
						return
					endif
				endif
				:execute ":write! ".l:snippetfile
			endif
		endif
		"
		" write marked area into snippet file 
		" 
		if a:arg1 == "wv"
			let	l:snippetfile=browse(0,"write a code snippet",s:NQC_CodeSnippets,"")
			if l:snippetfile != ""
				if filereadable(l:snippetfile)
					if confirm("File exists ! Overwrite ? ", "&Cancel\n&No\n&Yes") != 3
						return
					endif
				endif
				:execute ":*write! ".l:snippetfile
			endif
		endif

	else
		echohl ErrorMsg
		echo "code snippet directory ".s:NQC_CodeSnippets." does not exist"
		echohl None
	endif
endfunction
"
"------------------------------------------------------------------------------
"  run : hardcopy
"------------------------------------------------------------------------------
function! Hardcopy (arg1)
	let	Sou		= expand("%")								" name of the file in the current buffer
	" ----- normal mode ----------------
	if a:arg1=="n"
		exe	"hardcopy > ".Sou.".ps"		
	endif
	" ----- visual mode ----------------
	if a:arg1=="v"
		exe	"*hardcopy > ".Sou.".part.ps"		
	endif
endfunction
"
"------------------------------------------------------------------------------
"  run : settings
"------------------------------------------------------------------------------
function! NQC_Settings ()
  let settings =          "nqc.vim settings:\n"
	let settings = settings."author  :  ".s:NQC_AuthorName." (".s:NQC_AuthorRef.") ".s:NQC_Email."\n"
	let settings = settings."project :  ".s:NQC_Project."\n"
	let settings = settings."copyright holder :  ".s:NQC_CopyrightHolder."\n"
  let settings = settings."\n"
  let settings = settings."target :  ".s:NQC_Target."\n"
  let settings = settings."port :  ".s:NQC_Portname."\n"
  let settings = settings."firmware :  ".s:NQC_RCX_Firmware."\n"
	let settings = settings."code snippet directory  :  ".s:NQC_CodeSnippets."\n"
	let settings = settings."template directory  :  ".s:NQC_Template_Directory."\n"
	let settings = settings."printer :  ".s:NQC_Printer."\n"
  let settings = settings."\nhot keys:        \n"
  let settings = settings."F9  :  save and compile buffer\n"
  let settings = settings."----------------------------------------------------------------------------------------\n"
  let settings = settings."NQC-Support, Version ".s:NQC_Version."  /  Dr.-Ing. Fritz Mehner  /  mehner@fh-swf.de\n"
  let dummy=confirm( settings, "ok", 1, "Info" )
endfunction
"
"------------------------------------------------------------------------------
"	 Create the load/unload entry in the GVIM tool menu, depending on 
"	 which script is already loaded
"------------------------------------------------------------------------------
"
let s:NQC_Active = -1														" state variable controlling the NQC-menus
"
function! NQC_CreateUnLoadMenuEntries ()
	"
	" NQC is now active and was former inactive -> 
	" Insert Tools.Unload and remove Tools.Load Menu
	" protect the following submenu names against interpolation by using single qoutes (Mn)
	"
	if  s:NQC_Active == 1
		:aunmenu &Tools.Load\ NQC\ Support
		exe 'amenu <silent> 40.1140   &Tools.Unload\ NQC\ Support  	<C-C>:call NQC_Handle()<CR>'
	else
		" NQC is now inactive and was former active or in initial state -1 
		if s:NQC_Active == 0
			" Remove Tools.Unload if NQC was former inactive
			:aunmenu &Tools.Unload\ NQC\ Support
		else
			" Set initial state NQC_Active=-1 to inactive state NQC_Active=0
			" This protects from removing Tools.Unload during initialization after
			" loading this script
			let s:NQC_Active = 0
			" Insert Tools.Load
		endif
		exe 'amenu <silent> 40.1000 &Tools.-SEP100- : '
		exe 'amenu <silent> 40.1140 &Tools.Load\ NQC\ Support <C-C>:call NQC_Handle()<CR>'
	endif
	"
endfunction
"
"------------------------------------------------------------------------------
"  Loads or unloads NQC extensions menus
"------------------------------------------------------------------------------
function! NQC_Handle ()
	if s:NQC_Active == 0
		:call NQC_InitMenu()
		let s:NQC_Active = 1
	else
		if s:NQC_Root == ""
		aunmenu Comments
		aunmenu Statements
		aunmenu API-Functions
		aunmenu API-Constants
		aunmenu Snippets
		aunmenu Datalog
		aunmenu Run
		else
			exe "aunmenu ".s:NQC_Root
		endif
		let s:NQC_Active = 0
	endif
	
	call NQC_CreateUnLoadMenuEntries ()
endfunction
"
"------------------------------------------------------------------------------
" 
call NQC_CreateUnLoadMenuEntries()			" create the menu entry in the GVIM tool menu
"
if s:NQC_ShowMenues == "yes"
	call NQC_Handle()											" load the menus
endif
"
"=====================================================================================
" vim: set tabstop=2: set shiftwidth=2:
