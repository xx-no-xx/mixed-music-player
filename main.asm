.386
.model flat, stdcall
option casemap:none

include windows.inc
include user32.inc
include kernel32.inc
include masm32.inc
include comctl32.inc
include comdlg32.inc ; 文件操作
include winmm.inc
include gdi32.inc
include shlwapi.inc

; irvine32.inc

includelib masm32.lib
includelib user32.lib
includelib kernel32.lib
includelib comdlg32.lib
includelib Winmm.lib
includelib gdi32.lib
includelib Shlwapi.lib

.const

;---------------- control -------------
IDD_DIALOG 						equ	101 ; 主播放对话框
IDD_DIALOG_ADD_NEW_GROUP		equ 105 ; 加入新歌单的对话框

IDC_FILE_SYSTEM 				equ	1001 ; 导入歌单的按钮
IDC_MAIN_GROUP				    equ 1017 ; 展示当前选择歌单的所有歌曲
IDC_GROUPS						equ 1009 ; 选择当前歌单
IDC_ADD_NEW_GROUP				equ 1023 ; 加入新的歌单
IDC_NEW_GROUP_NAME				equ 1025 ; 输入新歌单的名称
IDC_BUTTON_ADD_NEW_GROUP		equ 1026 ; 确认加入新的歌单
IDC_DELETE_CURRENT_GROUP		equ 1027 ; 删除当前歌单的按钮
IDC_DELETE_CURRENT_SONG			equ 1028 ; 删除当前歌曲的按钮
IDC_DELETE_INVALID_SONGS		equ 1029 ; 删除所有非法的歌曲
IDC_PLAY_BUTTON                 equ 1030 ; 播放/暂停按钮
IDC_PRE_BUTTON                  equ 1031 ; 上一首
IDC_NEXT_BUTTON                 equ 1032 ; 下一首

IDC_SOUND						equ 1038 ; 音量进度条
IDC_FAST_FORWARD				equ 1041 ; 快进按钮
IDC_FAST_BACKWARD				equ 1042 ; 快退按钮
IDC_MUTE_SONG                   equ 1043 ; 完全静音按钮
IDC_CHANGE_MODE                 equ 1044 ; 切换播放顺序按钮
IDC_SONG_LOCATE                 equ 1045 ; 播放进度条
IDC_COMPLETE_TIME_TEXT          equ 1047 ; 一共需要播放多少时间
IDC_PLAY_TIME_TEXT              equ 1048 ; 已经播放了多少时间
IDC_SOUND_TEXT                  equ 1049 ; 声音大小的文字
IDC_CURRENT_STATIC              equ 1050 ; "当前播放的歌曲是"title
IDC_CURRENT_PLAY_SONG_TEXT      equ 1051 ; 当前播放的歌曲的展示
IDC_THEME                       equ 1054 ; 更换主题
IDC_CLOSE                       equ 1055 ; 关闭窗口
IDC_LIST_NAME                   equ 1056 ; 歌单名称
IDC_LYRICS                      equ 1057 ; 歌词窗口

IDC_BACKGROUND					equ 2001 ; 背景图层
IDC_BACKGROUND_ORANGE           equ 2002 ; 橙色背景图层
;--------------- image & icon ----------------
IDB_BACKGROUND_BLUE             equ 3001
IDB_BACKGROUND_ORANGE           equ 3002
IDB_ADD_SONG_BLUE               equ 138
IDB_ADD_SONG_ORANGE             equ 139
IDB_CLEAN_SONG                  equ 140
IDB_NEW_LIST                    equ 141
IDB_REMOVE_LIST                 equ 142
IDB_REMOVE_SONG                 equ 143

IDI_PLAY_BLUE                   equ 146

IDI_BACKWARD_BLUE				equ 147
IDI_BACKWARD_ORANGE             equ 175
IDI_FORWARD_BLUE                equ 149
IDI_FORWARD_ORANGE              equ 150
IDI_LOOP_BLUE                   equ 151
IDI_LOOP_ORANGE                 equ 152
IDI_MUTE_BLUE                   equ 153
IDI_MUTE_ORANGE                 equ 154
IDI_NEXT_BLUE                   equ 155
IDI_NEXT_ORANGE                 equ 156
IDI_PLAY_ORANGE                 equ 158
IDI_PRE_BLUE                    equ 159
IDI_PRE_ORANGE                  equ 160
IDI_RANDOM_BLUE                 equ 161
IDI_RANDOM_ORANGE               equ 162
IDI_SINGLE_BLUE                 equ 163
IDI_SINGLE_ORANGE               equ 164
IDI_SUSPEND_BLUE                equ 165
IDI_SUSPEND_ORANGE              equ 166
IDI_VOLUM_BLUE                  equ 167
IDI_VOLUM_ORANGE                equ 168
IDI_CLEAN_SONG					equ	176
IDI_ADD_SONG_BLUE               equ	177
IDI_ADD_SONG_ORANGE             equ	178
IDI_NEW_LIST                    equ	179
IDI_REMOVE_LIST                 equ	180
IDI_REMOVE_SONG                 equ	181
IDI_CHANGE_BLUE                 equ	182
IDI_CHANGE_ORANGE               equ	183
IDI_CROSS_BLUE                  equ	184
IDI_CROSS_ORANGE                equ	185

WINDOW_WIDTH					equ 1080 ; 窗口宽度
WINDOW_HEIGHT					equ 675  ; 窗口高度
PLAY_WIDTH						equ 40	 ; 播放键宽度
NEXT_WIDTH						equ 30	 ; 下一首键宽度
;---------------- process --------------------
DO_NOTHING			equ 0 ; 特定的返回值标识
DEFAULT_SONG_GROUP  equ 99824 ; 默认组别被分配到的编号 ; todo : change 99824 to 0
DEFAULT_PLAY_SONG   equ 21474 ; 默认的第index首歌 ; todo : change 21474 to a larger num
DEFAULT_PLAY_LYRIC  equ 0 ; 默认的第index句歌词

FILE_DO_EXIST		equ 0 ; 文件存在
FILE_NOT_EXIST		equ 1 ; 文件不存在

STATE_PAUSE equ 0 ; 暂停播放
STATE_PLAY equ 1 ; 正在播放
STATE_STOP equ 2 ; 停止播放

PLAY_PREVIOUS equ 0 ; 播放前一首
PLAY_NEXT equ 1 ; 播放后一首

MODE_LOOP equ 0 ; 歌单循环播放
MODE_ONE equ 1 ; 单曲循环播放
MODE_RANDOM equ 2 ; 随机播放

DELETE_ALL_SONGS_IN_GROUP	equ 0 ;删除songGroup(dword)里的所有歌
DELETE_CURRENT_SELECT_SONG	equ 1 ;删除选中的那首歌（current play song）
DELETE_INVALID				equ 2 ;删除所有不存在的路径对应的歌

MAX_FILE_LEN equ 1000 ; 最长文件长度
MAX_GROUP_DETAIL_LEN equ 32 ; 组别编号的最长长度
MAX_GROUP_NAME_LEN equ 20 ; 歌单名称的最长长度
MAX_GROUP_SONG equ 30 ; 歌单内歌曲的最大数
MAX_GROUP_NUM equ 10 ; 最大的歌单数量
MAX_SONG_NAME_LEN equ 150; 最大歌曲的名字的长度 ;todotodotodo

MAX_SINGLE_LYRIC_LEN equ 100; 每句歌词的字符串的最大长度
MAX_LYRIC_NUM equ 300; 歌词的数量

MAX_ALL_SONG_NUM equ 300 ; 全体歌曲的最大数目（=MAX_GROUP_SONG * MAX_GROUP_NUM）

; 实际最大LEN应该-1， 这是因为str最后需要为0，否则输出时会跨越到别的存储区域。

SAVE_TO_MAIN_DIALOG_GROUP		equ 1 ; 主界面展示用：保存至当前歌单
SAVE_TO_TARGET_GROUP		equ 2 ; 歌曲管理用：保存至管理页的当前歌单
SAVE_TO_DEFAULT_GROUP		equ 3 ; 歌单管理用：保存至管理页的默认歌单

INF							equ 4294967295 ;

LYRIC_DO_EXIST				equ 0 ; 歌词存在
LYRIC_NOT_EXIST				equ 1 ; 歌词不存在


; +++++++++++++++++ function ++++++++++++++++
DialogMain proto, ; 对话框主逻辑
	hWin : dword,
	uMsg : dword,
	wParam : dword,
	lParam : dword

ImportSingleFile proto, ; 导入单个文件到当前歌单
	hWin : dword

AddSingleSongOFN proto,  ; 配合ImportSingleFile，把刚刚读入的文件导入songGroup
	songGroup : dword

GetGroupDetailInStr proto, ; 获取currentPlayGroup的str形式
	songGroup : dword

GetCurrentGroupSong proto ; 从data.txt中读取当前组的歌曲

GetTargetGroupSong proto, ; 读取歌曲：分为1. SAVE_T_MAIN_DIALOG_GROUP ，将属于songGroup的歌曲存入currentGroupSongs
	songGroup : dword,
	saveTo: dword

song struct ; 歌曲信息结构体
	path byte MAX_FILE_LEN dup(0)
	groupid dword DEFAULT_SONG_GROUP ; 歌曲所属的groupid
; TODO : 其他歌曲信息
song ends

songgroup struct ; 歌单信息结构体
	groupid dword DEFAULT_SONG_GROUP
	groupname byte MAX_GROUP_NAME_LEN dup(0)
songgroup ends

CollectSongPath proto, ; 将songPath复制到对应的targetPath中去
	songPath : dword,
	targetPath : dword

CollectSongName proto, ; 将songName复制到targetName中
	songName : dword,
	targetName : dword


ShowMainDialogView proto, ; 刷新主页d的list box
	hWin : dword

SelectGroup proto, ; 选中当前Group
	hWin : dword

GetAllGroups proto, ; 查询所有的group, 并会默认设置第0个歌单为激活歌单
	hWin : dword

AddNewGroup proto, ; 加入一个新的group
	hWin : dword

DeleteCurrentGroup proto, ; 删除当前group
	hWin : dword

SelectSong proto, ; 更新当前选中的歌曲
	hWin : dword

SelectPlaySong proto, ; 更新当前预备播放的歌曲
	hWin : dword
	
DeleteTargetSong proto, ; 删除目标歌曲
	hWin : dword,
	method : dword, 
	songGroup : dword
; 分为三种删除的method: 
; DELETE_ALL_SONGS_IN_GROUP	:删除songGroup(dword)里的所有歌, 需要指定songGroup
; DELETE_CURRENT_SELECT_SONG	:删除选中的那首歌（current play song）
; DELETE_INVALID			:删除所有不存在的路径对应的歌

GetAllSongInData proto ; 将所有的歌曲存储至delAllSongs,

DeleteCurrentPlaySong proto, 
	hWin : dword 

StartAddNewGroup proto ; 开始加入新歌单的程序

NewGroupMain proto, ; 新增歌单的对话框主程序
	hWin: dword,
	uMsg : dword,
	wParam : dword,
	lParam : dword

CheckFileExist proto, ; 读取一个字符串targetPath(pointer)，判断对应的文件是否存在，并返回在eax中
	targetPath : dword


DeleteInvalidSongs proto,
	hWin : dword
	

ChangeTheme proto,	; 更换皮肤
	hWin : dword

; 鼠标左键事件
LButtonDown proto, 
	hWin : dword, 
	wParam : dword, 
	lParam : dword

KeyDown proto, 
	hWin : dword, 
	wParam : dword, 
	lParam : dword

InitUI proto,	; 加载资源
	hWin : dword, 
	wParam : dword,
	lParam : dword

ChangeTheme proto, 
	hWin : dword

PlayMusic proto, ; 播放/暂停音乐	
	hWin : dword

PauseCurrentSong proto ; 暂停当前音乐

PlayCurrentSong proto, ; 从头播放当前音乐
	hWin : dword 

ResumeCurrentSong proto ; 继续当前音乐

StopCurrentSong proto, ; 停止当前音乐
	hWin : dword

FastForward proto, ; 快进5s
	hWin : dword

FastBackward proto, ; 快退5s
	hWin : dword

AlterVolume proto, ; 调整音量大小
	hWin : dword

GetPlayPosition proto, ;获取播放位置
	hWin : dword

CheckPlayCurrentSong proto, ; 试图播放当前的歌曲currentPlaySingleSongPath
	hWin : dword
; eax = 0 代表不能够播放（1.没选中歌曲，2.歌曲不存在）
; eax = 1 代表当前选中了歌曲且歌曲存在

Paint proto, 
	hWin :dword

PlayNextSong proto, ; 播放下一首。如果当前没有选中歌曲，那么弹出message box
	hWin : dword

PlayPreviousSong proto, ; 播放上一首。如果当前没有选中歌曲，那么弹出message box
	hWin : dword

GetPreNxtSong proto, ; 更新选择上一首或者下一首。如果选中的这首歌不存在，那么提示信息。
	hWin : dword,
	method : dword

ChangeMode proto, ; 切换模式
	hWin : dword

lyric struct
	timeStamp dword 0; 歌词对应的毫秒
	lyricStr byte MAX_SINGLE_LYRIC_LEN dup(0)
lyric ends

GetLyricPath proto ; 找到lyric对应的路径

ReadLyric proto ; 读取currentPlaySingleSong对应的lyric文件

FindLyricAtTime proto, ; 找到timestamp时应该播放的歌词
	timeStamp : dword

SetInitLyric proto ; 设置初始歌词

CollectLyricStr proto, ;复制source的lyric str到target
	sourceStr : dword,
	targetStr : dword
	
	

; +++++++++++++++++++ data +++++++++++++++++++++
.data

;--------mci命令--------
cmd_open BYTE 'open "%s" alias mySong type mpegvideo',0
cmd_close BYTE "close mySong",0
cmd_play BYTE "play mySong", 0	
cmd_pause BYTE "pause mySong",0
cmd_resume BYTE "resume mySong",0
cmd_getLen BYTE "status mySong length", 0
cmd_getPos BYTE "status mySong position", 0
cmd_setPos BYTE "seek mySong to %d", 0
cmd_setStart BYTE "seek mySong to start", 0	
cmd_setVol BYTE "setaudio mySong volume to %d",0
;----------------------

rect RECT <0, 0, 1080, 675>
randomTime SYSTEMTIME <>

;--------播放状态-------
mciCommand BYTE 200 DUP(0)
playState BYTE 2
volume DWORD 100
isMuted BYTE 0
isDragging BYTE 0
curPos BYTE 32 DUP(0)
curLen BYTE 32 DUP(0)
;----------------------

;------格式化输出-------
intFormat BYTE "%d", 0
timeFormat BYTE "%02d:%02d", 0
;----------------------

modePlay byte MODE_LOOP

handler HANDLE ? ; 文件句柄
divideLine byte 0ah ; 换行divideLine

currentSelectSingleSongIndex dword DEFAULT_PLAY_SONG ;目前选中的歌曲信息
currentSelectSingleSongPath byte MAX_FILE_LEN dup(0) ;目前选中的歌曲路径

currentPlaySingleSongIndex dword DEFAULT_PLAY_SONG; 目前正在播放的歌曲信息
currentPlaySingleSongPath byte MAX_FILE_LEN dup(0); 目前正在播放歌曲的路径
currentPlaySingleSongLength dword 0               ; 目前正在播放歌曲的长度
currentPlaySingleSongPos dword 0             ; 目前正在播放歌曲播放到的位置

currentPlayGroup dword DEFAULT_SONG_GROUP ; 目前正在播放的歌单编号
groupDetailStr byte MAX_GROUP_DETAIL_LEN dup("a") ; 目前正在播放的歌单编号的str格式。 需要访问GetGroupDetailInStr以更新

; 歌单分为自定义歌单和默认歌单。默认歌单包括全部歌曲。

numCurrentGroupSongs dword 0 ; 当前播放歌单的歌曲数量
currentGroupSongs song MAX_GROUP_SONG dup(<,>) ; 当前播放歌单的所有歌曲信息

maxGroupId dword 0 ; 用于分配新的组别id

hasLyric dword LYRIC_NOT_EXIST ; 歌词是否存在
currentPlayLyricPos dword 0 ; 指针，指向当前index对应的结构体位置
currentPlayLyricIndex dword DEFAULT_PLAY_LYRIC; 目前正在播放的歌词是第几句
currentPlayLyricPath byte MAX_FILE_LEN dup(0) ; 歌词所处的路径
currentPlayLyricStr byte MAX_SINGLE_LYRIC_LEN dup(0); 目前正在播放的歌词的str形式
currentLyricTime dword 0; 现在播放的歌曲的时间戳
nextLyricTime dword INF; 下一句要播放的歌曲的时间戳
lyricSuffix byte "lrc", 0
lyricCounter dword 0

currentLyrics lyric MAX_LYRIC_NUM dup(<,>)

; ++++++++++++++删除功能引入的临时存储变量++++++++++++++
; ++++ 你不应在除了删除功能之外的函数访问这些变量 +++++++
delAllGroups songgroup MAX_GROUP_NUM dup(<,>)
delAllSongs song MAX_ALL_SONG_NUM dup(<,>)

; ++++++++++++++导入文件OPpenFileName结构++++++++++++++
ofn OPENFILENAME <>
ofnTitle BYTE '导入音乐', 0	
ofnFilter byte "Media Files(*.mp3, *.wav, *.mid, *.wmv, *.m4a, *.aac, *.aiff, *.flac)", 0, "*.mp3;*.wav;*.wma;*.mid;*.m4a;*.aac;*.aiff;*.flac", \
0, "All Files(*.*)", 0, "*.*",\
0, 0

; ++++++++++++++Message Box 提示信息++++++++++++++++++
deleteNone byte "您没有选中歌单，不能删除。",0
addNone byte "您没有选中歌单，不能导入歌曲。", 0
deleteSongNone byte "您没有选中歌曲，不能删除。", 0
playSongNone byte "您没有选中歌曲，不能播放。", 0
playSongInvalid byte "您预计播放的歌曲不存在，已自动为您删除不存在的歌曲。", 0
playPreNxtNone byte "您没有选中歌曲，不能播放上一首/下一首", 0
nameNone byte "暂无歌曲", 0
lyricNone byte "当前歌曲没有歌词文件", 0

; +++++++++++++++程序所需部分窗口变量+++++++++++++++
hInstance dword ?
hMainDialog dword ?
hNewGroup dword ?

; +++++++++++++++配置信息+++++++++++(因为测试而注释)
;songData BYTE ".\data.txt", 0
;ofnInitialDir BYTE "C:", 0 ; default open C
;groupData byte ".\groupdata.txt", 0

; +++++++++++++函数辅助变量++++++++++++（可能可以被local替代）

readGroupDetailStr byte MAX_GROUP_DETAIL_LEN   dup(0)
currentSongNameOFN byte MAX_FILE_LEN dup(0)
readFilePathStr byte MAX_FILE_LEN  dup(0)
readSongNameStr byte MAX_SONG_NAME_LEN dup(0)
buffer byte 0,0
readGroupNameStr byte MAX_GROUP_NAME_LEN dup(0)
inputGroupNameStr byte MAX_GROUP_NAME_LEN dup("1")
currentGroupName byte MAX_GROUP_NAME_LEN dup(0)
readTime byte 10 dup(0)
; to change "1" -> 0

; ++++++++++++++测试专用+++++++++++++ 
; ++++++++请根据自己的机器路径修改+++++++++
; TODO-TODO-TODO-TODO-TODO-TODO-TODO
simpleText byte "somethingrighthere", 0ah, 0
;ofnInitialDir BYTE "C:\Users\gassq\Desktop", 0 ; default open C only for test
;songData BYTE "C:\Users\gassq\Desktop\data.txt", 0 
ofnInitialDir BYTE "D:\music", 0 ; default open C only for test
songData BYTE "C:\Users\dell\Desktop\data\data.txt", 0 
testint byte "TEST INT: %d", 0ah, 0dh, 0
;groupData byte "C:\Users\gassq\Desktop\groupdata.txt", 0
groupData byte "C:\Users\dell\Desktop\data\groupdata.txt", 0

; 图像资源数据
bmp_Theme_Blue			dword	?	; 蓝色主题背景
bmp_Theme_Orange		dword	?	; 橙色主题背景
bmp_Add_Song_Blue		dword	?	; 蓝色添加歌曲
bmp_Add_Song_Orange		dword	?	; 橙色添加歌曲
bmp_Clean_Song			dword	?	; 清除无效歌曲
bmp_New_List			dword	?	; 新建歌单
bmp_Remove_List			dword	?	; 删除歌单
bmp_Remove_Song			dword	?	; 删除歌曲
ico_Play_Blue			dword	?	; 蓝色播放图标
ico_Play_Orange         dword	?	; 橙色播放图标
ico_Backward_Blue		dword	?	; 蓝色快退图标
ico_Backward_Orange		dword	?	; 蓝色快退图标
ico_Forward_Blue		dword	?	; 蓝色快进图标
ico_Forward_Orange		dword	?	; 橙色快进图标
ico_Loop_Blue			dword	?	; 蓝色循环图标
ico_Loop_Orange			dword	?	; 橙色循环图标
ico_Mute_Blue			dword	?	; 蓝色静音图标
ico_Mute_Orange			dword	?	; 橙色静音图标
ico_Next_Blue			dword	?	; 蓝色下一首图标
ico_Next_Orange			dword	?	; 橙色下一首图标
ico_Pre_Blue			dword	?	; 蓝色上一首图标
ico_Pre_Orange			dword	?	; 橙色上一首图标
ico_Random_Blue			dword	?	; 蓝色随机播放
ico_Random_Orange		dword	?	; 橙色随机播放
ico_Single_Blue			dword	?	; 蓝色单曲循环
ico_Single_Orange		dword	?	; 橙色单曲循环
ico_Suspend_Blue		dword	?	; 蓝色暂停
ico_Suspend_Orange		dword	?	; 橙色暂停
ico_Volum_Blue			dword	?	; 蓝色音量
ico_Volum_Orange		dword	?	; 橙色音量
ico_Clean_Song			dword	?	; 清除歌曲
ico_Add_Song_Blue		dword	?	; 蓝色添加歌曲
ico_Add_Song_Orange		dword	?	; 橙色添加歌曲
ico_New_List			dword	?	; 新建歌单
ico_Remove_List			dword	?	; 删除歌单
ico_Remove_Song			dword	?	; 删除歌曲
ico_Change_Blue			dword	?	; 蓝色更换主题
ico_Change_Orange		dword	?	; 橙色更换主题
ico_Cross_Blue			dword	?	; 蓝色关闭
ico_Cross_Orange		dword	?	; 橙色关闭
curTheme	word	1	; 当前主题编号
; 字体
fontName			byte	"微软雅黑"
; font				HFONT	?
; 快捷键相关
keyLessDown		dword	0	; <键是否被按下
keyGreatDown	dword	0	; >键是否被按下
keyUpDown		dword	0	; 上键是否被按下
keyDownDown		dword	0	; 下键是否被按下
keyLeftDown		dword	0	; 左键是否被按下
keyRightDown	dword	0	; 右键是否被按下
; +++++++++++++++code++++++++++++++++++
.code

WinMain PROC
	INVOKE GetModuleHandle, NULL
	mov hInstance, eax
	;invoke PreTranslateMessage, hInstance
	invoke DialogBoxParam, hInstance, IDD_DIALOG, 0, addr DialogMain, 0
	;invoke SendMessage, hInstance, WM_SETFOCUS, hInstance, NULL
	invoke ExitProcess, 0
WinMain ENDP

DialogMain proc,
	hWin : dword,
	uMsg : dword,
	wParam : dword,
	lParam : dword

	local loword : word
	local hiword : word
	local currentSlider : dword

	mov	eax, wParam ; WParam = (hiword, lowrd) : 详见notification code
	mov	loword, ax
;	mov	hiword, 
	shrd eax, ebx, 16
	mov	hiword, ax
	; invoke SetFocus, hWin
	.if	uMsg == WM_INITDIALOG
		; 加载图标并显示蓝色背景
		invoke InitUI, hWin, wParam, lParam
		invoke ChangeTheme, hWin

		; 设置初始播放歌曲的名称
		invoke GetDlgItem, hWin, IDC_CURRENT_PLAY_SONG_TEXT 
		invoke SetWindowText, eax, addr nameNone

		; 获取窗口
		push hWin
		pop hMainDialog

		; 获取所有的组别和歌曲
		invoke GetAllGroups, hWin
		invoke ShowMainDialogView, hWin

		;初始化音量条
		invoke SendDlgItemMessage, hWin, IDC_SOUND, TBM_SETRANGEMIN, 0, 0
		invoke SendDlgItemMessage, hWin, IDC_SOUND, TBM_SETRANGEMAX, 0, 1000
		invoke SendDlgItemMessage, hWin, IDC_SOUND, TBM_SETPOS, 1, 1000

		;初始化音量值
		mov volume, 1000
		invoke wsprintf, addr mciCommand, addr intFormat, 100
		invoke SendDlgItemMessage, hWin, IDC_SOUND_TEXT, WM_SETTEXT, 0, addr mciCommand
		
		;初始化Timer, 200ms间隔
		invoke SetTimer, hWin, 1, 200, NULL

		;初始化歌曲进度条
		invoke SendDlgItemMessage, hWin, IDC_SONG_LOCATE, TBM_SETRANGEMIN, 0, 0
		invoke SendDlgItemMessage, hWin, IDC_SONG_LOCATE, TBM_SETRANGEMAX, 0, 0
		invoke SendDlgItemMessage, hWin, IDC_SONG_LOCATE, TBM_SETPOS, 1, 0

		;初始化歌曲时间
		invoke wsprintf, ADDR mciCommand, ADDR timeFormat, 0, 0
		invoke SendDlgItemMessage, hWin, IDC_COMPLETE_TIME_TEXT, WM_SETTEXT, 0, ADDR mciCommand
		invoke SendDlgItemMessage, hWin, IDC_PLAY_TIME_TEXT, WM_SETTEXT, 0, ADDR mciCommand
		
		;注册热键
		invoke RegisterHotKey, hWin, 1, MOD_SHIFT, VK_F8
		; do something
	.elseif uMsg == WM_HOTKEY
		; do something
		; mov eax, eax
		invoke EndDialog, hWin, 0
	.elseif uMsg == WM_KEYDOWN
		; DEBUG: 按下空格后被按钮截获
		invoke KeyDown, hWin, wParam, lParam
	.elseif	uMsg == WM_COMMAND
		.if loword == IDC_FILE_SYSTEM
			invoke ImportSingleFile, hWin
			invoke ShowMainDialogView, hWin
		.elseif loword == IDC_GROUPS
			.if hiword == CBN_SELCHANGE
				invoke SelectGroup, hWin ; TODO
				invoke ShowMainDialogView, hWin
			.endif
		.elseif loword == IDC_ADD_NEW_GROUP
			invoke StartAddNewGroup
			invoke ShowMainDialogView, hWin
		.elseif loword == IDC_DELETE_CURRENT_GROUP	
			.if hiword == BN_CLICKED
				invoke DeleteCurrentGroup, hWin
				invoke ShowMainDialogView, hWin
			.endif
		.elseif loword == IDC_MAIN_GROUP
			.if hiword == LBN_SELCHANGE
				invoke SelectSong, hWin
			.elseif hiword == LBN_DBLCLK
				invoke SelectPlaySong, hWin
				.if curTheme == 0
					invoke SendDlgItemMessage, hWin, IDC_PLAY_BUTTON, BM_SETIMAGE, IMAGE_ICON, ico_Suspend_Blue
				.else
					invoke SendDlgItemMessage, hWin, IDC_PLAY_BUTTON, BM_SETIMAGE, IMAGE_ICON, ico_Suspend_Orange
				.endif
				invoke PlayCurrentSong, hWin
			.endif
		.elseif loword == IDC_DELETE_CURRENT_SONG
			.if hiword == BN_CLICKED
				invoke DeleteCurrentPlaySong, hWin
				invoke ShowMainDialogView, hWin
			.endif
		.elseif loword == IDC_DELETE_INVALID_SONGS
			.if hiword == BN_CLICKED
				invoke DeleteInvalidSongs, hWin
				invoke ShowMainDialogView, hWin
			.endif
		.elseif loword == IDC_PLAY_BUTTON
			.if hiword == BN_CLICKED
				invoke PlayMusic, hWin
			.endif
		.elseif loword == IDC_MUTE_SONG
			.if hiword == BN_CLICKED
				xor isMuted, 1
				.if isMuted == 1
					.if curTheme == 0
						invoke SendDlgItemMessage, hWin, IDC_MUTE_SONG, BM_SETIMAGE, IMAGE_ICON, ico_Mute_Blue
					.else
						invoke SendDlgItemMessage, hWin, IDC_MUTE_SONG, BM_SETIMAGE, IMAGE_ICON, ico_Mute_Orange
					.endif
				.else
					.if curTheme == 0
						invoke SendDlgItemMessage, hWin, IDC_MUTE_SONG, BM_SETIMAGE, IMAGE_ICON, ico_Volum_Blue
					.else
						invoke SendDlgItemMessage, hWin, IDC_MUTE_SONG, BM_SETIMAGE, IMAGE_ICON, ico_Volum_Orange
					.endif
				.endif
				invoke AlterVolume, hWin
			.endif
		.elseif loword == IDC_PRE_BUTTON
			.if hiword == BN_CLICKED
				invoke PlayPreviousSong, hWin
			.endif
		.elseif loword == IDC_NEXT_BUTTON
			.if hiword == BN_CLICKED
				invoke PlayNextSong, hWin
			.endif
		.elseif loword == IDC_CHANGE_MODE
			.if hiword == BN_CLICKED
				invoke ChangeMode, hWin
			.endif
		.elseif loword == IDC_FAST_FORWARD
			.if hiword == BN_CLICKED
				invoke FastForward, hWin
			.endif 
		.elseif loword == IDC_FAST_BACKWARD
			.if hiword == BN_CLICKED
				invoke FastBackward, hWin
			.endif
		.elseif loword == IDC_CLOSE
			.if hiword == BN_CLICKED
				invoke SendMessage, hWin, WM_CLOSE, NULL, NULL
			.endif
		.elseif loword == IDC_THEME
			.if hiword == BN_CLICKED
				invoke ChangeTheme, hWin
			.endif
		.else
			; do something
		.endif
	.elseif uMsg == WM_LBUTTONDOWN	; 左键按下
		invoke LButtonDown, hWin, wParam, lParam
	.elseif	uMsg == WM_CLOSE
		invoke EndDialog,hWin,0
		.if hNewGroup != 0
			invoke EndDialog, hNewGroup, 0
		.endif
	.elseif uMsg == WM_HSCROLL
		invoke GetDlgCtrlID, lParam
		mov currentSlider, eax ; 获取控件ID

		.if currentSlider == IDC_SOUND
			.if loword == SB_THUMBTRACK
				invoke AlterVolume, hWin ;调整音量
			.endif
		.elseif currentSlider == IDC_SONG_LOCATE
			.if loword == SB_THUMBTRACK ;拖动中
				mov isDragging, 1
			.elseif loword == SB_ENDSCROLL ;结束拖动
				mov isDragging, 0
			.endif 
		.endif
	.elseif uMsg == WM_TIMER ;时钟信号
		invoke GetPlayPosition, hWin ;获取播放位置
	.else
		; do sth
	.endif

	xor eax, eax ; eax = 0
	ret
DialogMain endp

ImportSingleFile proc,
	hWin : dword

	.if currentPlayGroup == DEFAULT_SONG_GROUP ; 如果当前未选择歌单，提示错误
		invoke MessageBox, hWin, addr addNone, 0, MB_OK
		ret
	.endif

	invoke  RtlZeroMemory, addr ofn, sizeof ofn ; 将OpenFileName结构体清0

	mov ofn.lStructSize, sizeof OPENFILENAME

	push hWin
	pop ofn.hwndOwner ; hwndOwner = hWin

	mov ofn.lpstrTitle, OFFSET ofnTitle ; 设置打开文件夹的Tirle
	mov ofn.lpstrInitialDir, OFFSET ofnInitialDir ; 设置默认打开文件夹
	mov	ofn.nMaxFile, MAX_FILE_LEN ; 设置文件名的长度
	invoke RtlZeroMemory, addr currentSongNameOFN, sizeof currentSongNameOFN ; 清空文件名指针指向的字符串
	mov	ofn.lpstrFile, OFFSET currentSongNameOFN  ; 设置需要打开的文件的名称的指针
	mov	ofn.lpstrFilter, offset ofnFilter ; 设置打开文件类型限制
	mov ofn.Flags, OFN_HIDEREADONLY ; 隐藏以只读模式打开的按钮

	invoke GetOpenFileName, addr ofn ; 调用打开文件的系统对话框

	.if eax == DO_NOTHING ;  todo: 如果没打开, 直接ret
		jmp EXIT_IMPORT
	.endif

	invoke AddSingleSongOFN, currentPlayGroup ; 如果打开成功，那么将该歌曲加入当前歌单

EXIT_IMPORT:
	xor eax, eax ; eax = 0
	ret
ImportSingleFile endp

AddSingleSongOFN proc,
	songGroup : dword

	LOCAL BytesWritten : dword ; 用于文件写入的指针
	LOCAL handler_saved : dword ; 保存handler
	LOCAL lpstrLength : dword ; 名称长度


	invoke GetGroupDetailInStr, songGroup ; 获取dword songGroup的用于写入文件的str模式

    INVOKE  CreateFile,offset songData,GENERIC_WRITE, 0, 0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0 ; 打开文件
	mov		handler, eax
	mov		handler_saved, eax

	invoke SetFilePointer, handler, 0, 0, FILE_END ; 将指针移动到末尾

	invoke lstrlen, ofn.lpstrFile
	mov	 lpstrLength, eax ; 设置openfilename中文件名称长度
	invoke WriteFile, handler, addr divideLine, length divideLine,  addr BytesWritten, NULL ; 写换行符
	invoke WriteFile, handler, addr groupDetailStr, MAX_GROUP_DETAIL_LEN , addr BytesWritten, NULL ; 写song Group的str模式

	invoke WriteFile, handler, addr divideLine, length divideLine,  addr BytesWritten, NULL ; 写换行符
	invoke WriteFile, handler, ofn.lpstrFile, MAX_FILE_LEN, addr BytesWritten, NULL ;写当前文件的路径

	invoke CloseHandle, handler_saved ; 关闭当前的文件句柄

	ret
AddSingleSongOFN endp

GetGroupDetailInStr proc,
	songGroup : dword
	invoke  RtlZeroMemory, addr groupDetailStr, sizeof groupDetailStr ; clear groupDetailStr
	invoke dw2a, songGroup, addr groupDetailStr ; 将dword songGroup的str形式存储在groupDetailStr中
	ret
GetGroupDetailInStr endp

GetCurrentGroupSong proc
	invoke GetTargetGroupSong, currentPlayGroup, SAVE_TO_MAIN_DIALOG_GROUP ; 获取当前播放的歌单的歌曲信息
	ret
GetCurrentGroupSong endp

GetTargetGroupSong proc,
	songGroup : dword, ; 获取哪一个歌单
	saveTo : dword ; 对应着哪一种获取模式
	; SAVE_TO_MAIN_DIALOG_GROUP : 获取当前播放的歌单

	LOCAL BytesRead : dword ; ---
	LOCAL handler_saved : dword ; ---
	LOCAL lpstrLength : dword

	LOCAL counter : dword

    invoke  CreateFile,offset songData,GENERIC_READ, 0, 0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0 ; 打开歌单歌曲文件
	mov		handler, eax

	.if saveTo == SAVE_TO_MAIN_DIALOG_GROUP ; 如果是要获取当前播放的歌单
		mov	 esi, offset currentGroupSongs
	.endif

	mov	counter, 0
REPEAT_READ:
	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL ; 读换行符
	.if BytesRead == 0 ; 读到文件末尾，跳出
		jmp END_READ
	.endif
	invoke ReadFile, handler, addr readGroupDetailStr, MAX_GROUP_DETAIL_LEN , addr BytesRead, NULL ; 读group信息

	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL ; 读换行符
	invoke ReadFile, handler, addr readFilePathStr, MAX_FILE_LEN, addr BytesRead, NULL ; 读文件路径

	invoke atol, addr readGroupDetailStr ;转换字符串形式的group信息到dword
	.if eax > maxGroupId ; 设置当前最大的maxGroupId
		mov maxGroupId, eax
	.endif
	.if eax == songGroup ; 如果读到的这首歌属于我们需要播放的歌单
		push esi
		invoke CollectSongPath, addr readFilePathStr, addr (song ptr [esi]).path ;将readFilePathStr即歌曲的路径复制到currentGroupSongs的下一个结构体中
		push songGroup
		pop	(song ptr [esi]).groupid ; 存储对应的group id
		pop esi
		add	esi, SIZE song ; 地址移到currentPlaySong的下一个struct
		inc counter ; 计数器+1
	.endif
	

	jmp REPEAT_READ
END_READ:
	invoke CloseHandle, handler

	.if saveTo == SAVE_TO_MAIN_DIALOG_GROUP  
		push counter
		pop numCurrentGroupSongs ; 将计数器的值存储至当前歌单的总数
	.endif

	ret
GetTargetGroupSong endp

CollectSongPath proc,
	songPath : dword,
	targetPath : dword ; 将songPath复制到targetPath，其复制的内容是文件长度-1
	
	mov	esi, songPath
	mov	edi, targetPath
	mov	ecx, MAX_FILE_LEN - 1
	cld
	rep movsb
	ret

CollectSongPath endp

ShowMainDialogView proc,
	hWin : dword
	LOCAL	counter : dword

	invoke SendDlgItemMessage, hWin, IDC_MAIN_GROUP, LB_RESETCONTENT, 0, 0 ; 清理当前歌单的歌曲
	invoke GetCurrentGroupSong ; 获取当前歌单的歌曲

	push numCurrentGroupSongs
	pop	 counter ; 设置计数器

	mov	esi, offset currentGroupSongs ; 设置指针

PRINT_LIST:
	.if counter == 0
		jmp END_PRINT
	.endif

	push esi
	invoke GetFileTitle, addr (song ptr [esi]).path, addr readSongNameStr, MAX_SONG_NAME_LEN - 1
	invoke SendDlgItemMessage, hWin, IDC_MAIN_GROUP, LB_ADDSTRING, 0, addr readSongNameStr  ;将名称加入listbox
	pop esi
	add	esi, size song
	dec counter ; 计数器-1
	jmp PRINT_LIST

END_PRINT:
	ret
ShowMainDialogView endp

SelectGroup proc,
	hWin : dword
	local indexToSet : dword ; 被选择的index
	local BytesRead : dword ; 读入用指针
	local handler_saved : dword ; 保存handler
	local counter : dword ; 计数器

	invoke SendDlgItemMessage, hWin, IDC_GROUPS, CB_GETCURSEL, 0, 0 
	mov	indexToSet, eax ; 获取当前被选中的group index
	invoke SendDlgItemMessage, hWin, IDC_GROUPS, CB_GETLBTEXT, indexToSet, addr currentGroupName
	invoke SendDlgItemMessage, hWin, IDC_LIST_NAME, WM_SETTEXT, 0, addr currentGroupName

	.if eax == CB_ERR ; 如果没有选中group
		mov currentPlayGroup, DEFAULT_SONG_GROUP ; 那么设置现在没有选中歌单
		invoke SelectSong, hWin ; 同时设置现在选择的歌曲
		ret
	.endif

    invoke  CreateFile,offset groupData,GENERIC_READ, 0, 0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0 ; 打开groupdata.txt读取group相关的信息
	mov		handler, eax

	mov		esi, 0 ; 计数器清0

REPEAT_READ:
	push esi ; 保存esi
	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL ; 读换行符
	.if BytesRead == 0 ; 读到文件末尾
		jmp END_READ
	.endif
	invoke ReadFile, handler, addr readGroupDetailStr, MAX_GROUP_DETAIL_LEN , addr BytesRead, NULL ; 读songGroup的str形式

	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL ; 读换行符
	invoke ReadFile, handler, addr readGroupNameStr, MAX_GROUP_NAME_LEN, addr BytesRead, NULL ; 读songGroup的name
	pop esi ; 恢复esi

	.if esi == indexToSet ; 找到了第esi个组别信息
		invoke atol, addr readGroupDetailStr ; 将songGroup的编号从str转换为eax
		mov currentPlayGroup, eax ; 设置currentPlayGroup编号
		jmp END_READ ;结束
	.endif
	inc esi
	jmp REPEAT_READ
END_READ:
	invoke CloseHandle, handler ; 关闭handler
	
	invoke SendDlgItemMessage, hWin, IDC_MAIN_GROUP, LB_SETCURSEL, -1, 0 ;默认选择song0
	invoke SelectPlaySong, hWin ; 选择（清空播放歌曲）
	xor eax, eax ; eax = 0
	ret
SelectGroup endp

AddNewGroup proc,
	hWin : dword

	local handler_saved : dword ; ---
	local BytesWritten : dword ; 用于写的指针

    invoke  CreateFile,offset groupData,GENERIC_WRITE, 0, 0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0 ; 打开groupdata.txt获取组别信息
	mov		handler, eax
	mov		handler_saved, eax

	invoke SetFilePointer, handler, 0, 0, FILE_END ; 将文件指针引用到末尾

	invoke RtlZeroMemory, addr readGroupNameStr, sizeof readGroupNameStr ; 对readGroupNameStr区域清0
	mov	readGroupNameStr, MAX_GROUP_NAME_LEN - 1 ;为了使用EM_GELINE,将readGroupNameStr的第一个位设置为要读取的长度
	invoke SendDlgItemMessage, hWin, IDC_NEW_GROUP_NAME, EM_GETLINE, 0, addr readGroupNameStr ;获取edit control里用户输入的内容

	add		maxGroupId, 1; 增大maxGroupId
	invoke GetGroupDetailInStr, maxGroupId ; 把这个不会重复的maxGroupId分配给新的group

	invoke WriteFile, handler, addr divideLine, length divideLine,  addr BytesWritten, NULL ; 写换行符
	invoke WriteFile, handler, addr groupDetailStr, MAX_GROUP_DETAIL_LEN, addr BytesWritten, NULL ; 写group的id的str形式

	invoke WriteFile, handler, addr divideLine, length divideLine,  addr BytesWritten, NULL ; 写换行符
	invoke WriteFile, handler, addr readGroupNameStr, MAX_GROUP_NAME_LEN, addr BytesWritten, NULL ; 写group的name

	invoke CloseHandle, handler_saved ; 关闭handler

	invoke SendDlgItemMessage, hMainDialog, IDC_GROUPS, CB_ADDSTRING, 0, addr readGroupNameStr ; 增加这个歌单选择到下拉框

	invoke SendDlgItemMessage, hMainDialog, IDC_GROUPS, CB_GETCOUNT, 0, 0 ; 获取现在有多少个歌单
	dec eax
	invoke SendDlgItemMessage, hMainDialog, IDC_GROUPS, CB_SETCURSEL, eax, 0 ; 将当前选择的歌单设置为新加入的这个（index = numGroup - 1）

	invoke SelectGroup, hMainDialog ; 选择当前组
	ret
AddNewGroup endp

GetAllGroups proc,
	hWin : dword

	local BytesRead : dword ; 读入的指针

    invoke  CreateFile,offset groupData,GENERIC_READ, 0, 0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0 ; 打开groupData.txt获取组别信息
	mov		handler, eax

	invoke SendDlgItemMessage, hWin, IDC_GROUPS, CB_RESETCONTENT, 0, 0 ; 清空group下拉框
REPEAT_READ:
	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL ; 读换行符
	.if BytesRead == 0 ; 读到文件末尾，结束
		jmp END_READ
	.endif
	invoke ReadFile, handler, addr readGroupDetailStr, MAX_GROUP_DETAIL_LEN , addr BytesRead, NULL ;读组别的id

	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL ; 读换行符
	invoke ReadFile, handler, addr readGroupNameStr, MAX_GROUP_NAME_LEN, addr BytesRead, NULL; 读group的name

	invoke SendDlgItemMessage, hWin, IDC_GROUPS, CB_ADDSTRING, 0, addr readGroupNameStr ; 将group的name加入下拉框

	jmp REPEAT_READ
END_READ:
	invoke CloseHandle, handler ; 关闭handler

	invoke SendDlgItemMessage, hWin, IDC_GROUPS, CB_SETCURSEL, 0, 0 ;默认选择第0个group
	invoke SelectGroup, hWin; 选择该group

	ret
GetAllGroups endp

StartAddNewGroup proc
	invoke DialogBoxParam, hInstance, IDD_DIALOG_ADD_NEW_GROUP, 0, addr NewGroupMain, 0 ; 打开输入新建歌单名称的对话框
	ret
StartAddNewGroup endp

NewGroupMain proc,
	hWin : dword, 
	uMsg : dword,
	wParam : dword,
	lParam : dword

	.if	uMsg == WM_INITDIALOG
		push hWin
		pop hNewGroup ; 存储当前对话框的句柄，以便在父窗口关闭时关闭
		invoke SendDlgItemMessage, hWin, IDC_NEW_GROUP_NAME, EM_LIMITTEXT, MAX_GROUP_NAME_LEN - 1, 0 ; 设置输入歌单名称的edit control的长度限制
	.elseif	uMsg == WM_COMMAND
		.if wParam == IDC_BUTTON_ADD_NEW_GROUP ; 如果确认加入歌单
			invoke AddNewGroup, hWin ; 加入歌单
			invoke EndDialog, hWin, 0 ; 加入完毕，关闭窗口
		.endif
	.elseif	uMsg == WM_CLOSE
		mov hNewGroup, 0 ; 关闭窗口，并将当前句柄设为0，避免被父窗口重复关闭
		invoke EndDialog,hWin,0
	.else
	.endif

	xor eax, eax ; eax = 0
	ret
NewGroupMain endp

DeleteCurrentGroup proc, ; 删除当前选择的歌单
	hWin : dword

	local BytesRead : dword ; 用于读的指针
	local BytesWritten : dword ; 用于写的指针
	local currentSelect : dword ; 当前选择的需要被删除的group
	local counter : dword ; 计数器

	invoke SelectGroup, hWin ;更新当前选择的group信息
	.if currentPlayGroup == DEFAULT_SONG_GROUP ; 如果当前没有选择歌单，那么提示错误
		invoke MessageBox, hWin, addr deleteNone, 0, MB_OK
		ret
	.endif

	invoke DeleteTargetSong, hWin, DELETE_ALL_SONGS_IN_GROUP, currentPlayGroup 
	; 调用DeleteTargetSong, 指定method，删除在当前组别内的所有歌曲。
	; 调用后，所有属于该组的歌曲在data.txt中被删除。

    invoke  CreateFile,offset groupData,GENERIC_READ, 0, 0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0 ; 打开文件
	mov		handler, eax ; 保存handler
	mov		esi, offset delAllGroups ; 设置esi从delAllGroups开始写

	mov		counter, 0 ; 计数器清0
REPEAT_READ:
	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL ; 读换行符
	.if BytesRead == 0;读到末尾
		jmp END_READ
	.endif
	invoke ReadFile, handler, addr readGroupDetailStr, MAX_GROUP_DETAIL_LEN , addr BytesRead, NULL ; 读groupid的str形式

	invoke atol, addr readGroupDetailStr ;将group id转换为dword
	mov (songgroup ptr [esi]).groupid, eax ;将dword形式的group id存进delAllGroups[]的对应位置

	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL ; 读换行符
	invoke ReadFile, handler, addr (songgroup ptr [esi]).groupname, MAX_GROUP_NAME_LEN, addr BytesRead, NULL ; 读group的name

	add esi, size songgroup ; 移动到下一个songgroup结构体在delAllGroups数组中的位置
	add counter, 1 ; 计数器+1
	jmp REPEAT_READ
END_READ:
	invoke CloseHandle, handler

	mov		esi, offset delAllGroups ;重新设置esi的指针在delAllGroups的开头

	invoke SendDlgItemMessage, hWin, IDC_GROUPS, CB_RESETCONTENT, 0, 0 ; 重置组别选择下拉框的内容
    invoke  CreateFile,offset groupData,GENERIC_WRITE, 0, 0,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0 ; 打开groupdata.txt文件
	; 这里选择create_always打开模式，可以覆盖之前陈旧的groupdata信息
	mov		handler, eax
	invoke SetFilePointer, handler, 0, 0, FILE_BEGIN ; 将文件指针移动到开头

REPEAT_WRITE:
	mov	ebx, (songgroup ptr [esi]).groupid ; 判断当前的结构体是否为我们需要删除的groupid
	.if ebx != currentPlayGroup ; 如果不是我们要删除的, 将它写进groupdata
		invoke WriteFile, handler, addr divideLine, length divideLine,  addr BytesWritten, NULL 

		invoke GetGroupDetailInStr, (songgroup ptr [esi]).groupid
		invoke WriteFile, handler, addr groupDetailStr, MAX_GROUP_DETAIL_LEN, addr BytesWritten, NULL

		invoke WriteFile, handler, addr divideLine, length divideLine,  addr BytesWritten, NULL
		invoke WriteFile, handler, addr (songgroup ptr [esi]).groupname, MAX_GROUP_NAME_LEN, addr BytesWritten, NULL

		invoke SendDlgItemMessage, hWin, IDC_GROUPS, CB_ADDSTRING, 0, addr (songgroup ptr [esi]).groupname ; 将它更新进group的下拉框
	.endif

	sub counter, 1 ; 计数器-1
	add	esi, size songgroup ; 移动esi在delAllGroups中的位置
	.if counter ==  0
		jmp END_WRITE
	.endif
	jmp REPEAT_WRITE
END_WRITE:
	invoke CloseHandle, handler

	invoke SendDlgItemMessage, hWin, IDC_GROUPS, CB_SETCURSEL, 0, 0 ; 默认选择第0个group
	invoke SelectGroup, hWin ; 设置group及其他信息

	ret
DeleteCurrentGroup endp

SelectSong proc, ; 设置当前选中的歌曲
	hWin : dword

	local indexToPlay : dword ; 当前应该播放歌曲的index

	invoke SendDlgItemMessage, hWin, IDC_MAIN_GROUP, LB_GETCURSEL, 0, 0 ; 获取当前选中的歌曲
	.if eax == LB_ERR ; 如果没有选中，那么返回
		mov currentSelectSingleSongIndex, DEFAULT_PLAY_SONG
		ret
	.endif

	mov	currentSelectSingleSongIndex, eax ; 将index记录在currentSelectSingleSongIndex上

	mov	ebx, size song 
	mul	ebx ;计算目标song在currentGroupSongs中的偏移量

	mov	esi, offset currentGroupSongs ; 设置songGroup的指针
	add	esi, eax

	invoke CollectSongPath, addr (song ptr [esi]).path, addr currentSelectSingleSongPath ;复制当前歌曲的路径到currentPlaySingleSongPath
	ret
SelectSong endp

SelectPlaySong proc,; 设置当前正在播放的歌曲
	hWin : dword

	local indexToPlay : dword ; 当前应该播放歌曲的index
	local staticWin : dword

	invoke StopCurrentSong, hWin
	invoke SelectSong, hWin

	push currentSelectSingleSongIndex
	pop currentPlaySingleSongIndex

	invoke CollectSongPath, addr currentSelectSingleSongPath, addr currentPlaySingleSongPath ;复制当前歌曲的路径到currentPlaySingleSongPath

	invoke GetDlgItem, hWin, IDC_CURRENT_PLAY_SONG_TEXT 
	mov	staticWin, eax
	.if currentPlaySingleSongIndex == DEFAULT_PLAY_SONG
		invoke SetWindowText, staticWin, addr nameNone
	.else
		invoke SetInitLyric
		invoke GetFileTitle, addr currentPlaySingleSongPath, addr readSongNameStr, MAX_SONG_NAME_LEN - 1
		invoke SetWindowText, staticWin, addr readSongNameStr
	; readSongNameStr
	.endif
	ret
SelectPlaySong endp

DeleteTargetSong proc,
	hWin : dword, 
	method : dword, ; 支持几种删除的method
	songGroup : dword ; 指定DELETE_ALL_SONGS_IN_GROUP方法中删除哪一个group

	local counter : dword
	local BytesWrite : dword
	local selectIndex : dword
	local playIndex : dword
	local playIndexadd1 : dword
;	index : dword

; 分为三种删除的method: 
; DELETE_ALL_SONGS_IN_GROUP	:删除songGroup(dword)里的所有歌, 需要指定songGroup
; DELETE_CURRENT_SELECT_SONG	:删除选中的那首歌（current play song）
; DELETE_INVALID			:删除所有不存在的路径对应的歌

	invoke SelectSong, hWin ; 先更新当前选中的歌曲
	push currentSelectSingleSongIndex
	pop selectIndex

	.if method == DELETE_CURRENT_SELECT_SONG ; 
		invoke SelectSong, hWin ; 先更新当前选中的歌曲
		push currentSelectSingleSongIndex
		pop selectIndex ; 将这个指存储给selectIndex，以便后续使用
		.if currentSelectSingleSongIndex == DEFAULT_PLAY_SONG
			invoke MessageBox, hWin, addr deleteSongNone, 0, MB_OK ;如果删除当前播放的歌曲，且当前没有播放的歌曲，报错
			ret
		.endif
		mov	eax, currentPlaySingleSongIndex
		.if eax == currentSelectSingleSongIndex ; 如果删除歌曲是播放歌曲，那么停止它，然后清空焦点和播放
			invoke SendDlgItemMessage, hWin, IDC_MAIN_GROUP, LB_SETCURSEL, -1, 0
			invoke SelectPlaySong, hWin
		.elseif eax > currentSelectSingleSongIndex ; 如果删除歌曲，在播放歌曲之前，修改播放歌曲的index
			sub currentPlaySingleSongIndex, 1 
		.endif
	.endif

	.if method == DELETE_ALL_SONGS_IN_GROUP
		.if songGroup == DEFAULT_SONG_GROUP
			ret ; 如果删除一个组，且这个组不存在，返回
		.endif
	.endif

	.if method == DELETE_INVALID
		push currentPlaySingleSongIndex ; 如果是删除无效的方法，需要保留playIndex
		pop playIndex
		push playIndex
		pop playIndexadd1
		add playIndexadd1,  1 ; playIndexadd1 = playIndex + 1
	.endif

	invoke GetAllSongInData ; 获取所有data.txt中的歌曲信息，存储在delAllSongs之中
	mov		counter, eax

    invoke  CreateFile,offset songData,GENERIC_WRITE, 0, 0,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0 ; 读取所有的歌曲
	mov		handler, eax
	mov		esi, offset delAllSongs

	invoke SetFilePointer, handler, 0, 0, FILE_BEGIN ; 将文件指针移动到开头
	mov		ecx, 0 ; ecx记录目前是currentPlayGroup的第ecx首歌 ; 

REPEAT_WRITE:
	.if counter == 0
		jmp END_WRITE
	.endif
	dec counter

	mov edx, (song ptr [esi]).groupid ; 获取当前歌曲的group

	.if edx == currentPlayGroup 
		.if method == DELETE_CURRENT_SELECT_SONG  ; 如果当前歌曲属于currentPlayGroup, 且method时DELETE_CURRENT_SELECT_SONG
			.if ecx == selectIndex ; 如果是当前select的歌曲
				add	esi, size song  ; 删除它
				inc ecx ; 计数器+1
				jmp REPEAT_WRITE
			.endif
		.endif
		inc ecx ; 计数器+1
	.endif

	.if edx == songGroup  
		.if method == DELETE_ALL_SONGS_IN_GROUP ; 如果当前歌曲属于songGroup，且method是DELETE_ALL_SONGS_IN_GROUP
			add esi, size song
			jmp REPEAT_WRITE
		.endif
	.endif

	push eax; 保存eax
	.if method == DELETE_INVALID
		push ecx ; 保存ecx
		invoke CheckFileExist, addr (song ptr [esi]).path
		pop ecx ; 恢复ecx
		.if eax == FILE_NOT_EXIST ; 如果method是DELETE_INVALID且当前文件不存在
			.if ecx <= playIndex
				sub currentPlaySingleSongIndex, 1 ; 如果删除的无效歌曲在playsong之前，给playsong的index - 1
			.elseif ecx == playIndexadd1
				push esi
				push ecx
				invoke SendDlgItemMessage, hWin, IDC_MAIN_GROUP, LB_SETCURSEL, -1, 0
				invoke SelectPlaySong, hWin ; 如果删除当前正在播放的无效歌曲，那么要清理播放相关的参数
				pop ecx
				pop esi
			.endif
			add esi, size song
			pop eax ; 恢复eax
			jmp REPEAT_WRITE
		.endif
	.endif
	pop eax ; 恢复eax

	push ecx
	;如果歌曲不符合上述几种情况，那么保存它到data.txt，也就是不删除它
	invoke WriteFile, handler, addr buffer, length divideLine,  addr BytesWrite, NULL
	invoke GetGroupDetailInStr, (song ptr [esi]).groupid
	invoke WriteFile, handler, addr groupDetailStr, MAX_GROUP_DETAIL_LEN , addr BytesWrite, NULL

	invoke WriteFile, handler, addr buffer, length divideLine,  addr BytesWrite, NULL
	invoke WriteFile, handler, addr (song ptr [esi]).path, MAX_FILE_LEN, addr BytesWrite, NULL
	pop ecx ; 恢复ecx

	add	esi, size song
	jmp REPEAT_WRITE
END_WRITE:
	invoke CloseHandle, handler
	ret
DeleteTargetSong endp

GetAllSongInData proc ; 获取所有的data.txt中的歌曲

	local BytesRead : dword ; 读用的指针
	local counter : dword ; 计数器
    invoke  CreateFile,offset songData,GENERIC_READ, 0, 0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0 ; 打开data.txt文件获取所有歌曲的信息
	mov		handler, eax
	mov		esi, offset delAllSongs ; 设置delAllSongs的偏移量esi

	mov	counter, 0 ; 计数器=0
REPEAT_READ:
	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL  ; 读换行符
	.if BytesRead == 0
		jmp END_READ
	.endif
	invoke ReadFile, handler, addr readGroupDetailStr, MAX_GROUP_DETAIL_LEN , addr BytesRead, NULL ; 读groupid
	invoke atol, addr readGroupDetailStr
	mov	(song ptr [esi]).groupid, eax

	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL ; 读换行符
	invoke ReadFile, handler, addr readFilePathStr, MAX_FILE_LEN, addr BytesRead, NULL ; 读文件的path

	push esi
	invoke CollectSongPath, addr readFilePathStr, addr (song ptr [esi]).path ; 将文件的path复制到delAllSongs中
	pop esi

	add	esi, size song ; 移动到下一个delAllSongs中的结构体
	inc counter ; 计数器+1
	jmp REPEAT_READ
END_READ:
	invoke CloseHandle, handler

	mov	eax, counter ;将counter存入eax，以提示caller有多少个有效的data.txt
	ret
GetAllSongInData endp

DeleteCurrentPlaySong proc,
	hWin : dword
	invoke DeleteTargetSong, hWin, DELETE_CURRENT_SELECT_SONG, 0 ; 删除当前播放的歌曲
	ret
DeleteCurrentPlaySong endp

CheckFileExist proc,
	targetPath : dword

	invoke GetFileAttributes, targetPath ; 判断文件是否存在
	.if eax == INVALID_FILE_ATTRIBUTES
		mov eax, FILE_NOT_EXIST
	.else
		mov eax, FILE_DO_EXIST
	.endif

	ret
CheckFileExist endp

DeleteInvalidSongs proc,
	hWin : dword
	invoke DeleteTargetSong, hWin, DELETE_INVALID, 0 ; 删除所有无效的歌曲
	ret
DeleteInvalidSongs endp

; 鼠标左键按下事件
LButtonDown proc, 
	hWin : dword, 
	wParam : dword, 
	lParam : dword

	local @mouseX : word
	local @mouseY : word
	
	mov eax, lParam
;	mov	hiword, 
	mov @mouseX, ax
	shrd eax, ebx, 16
	mov @mouseY, ax
	; 在上半部分拖动窗口
	.if @mouseY < 50
		invoke SendMessage, hWin, WM_NCLBUTTONDOWN, HTCAPTION, 0
	.endif
	ret
LButtonDown endp

; 键盘按下事件处理
KeyDown proc, 
	hWin : dword, 
	wParam : dword, 
	lParam : dword
	.if wParam == VK_SPACE
		ret
	.endif
	ret
KeyDown endp
;// 键盘按下事件处理函数
;void KeyDown(HWND hWnd, WPARAM wParam, LPARAM lParam) {
; switch (wParam) {
; case VK_UP:
;  keyUpDown = true;
;  break;

; 界面布局函数
InitUI proc, 
	hWin : dword, 
	wParam : dword, 
	lParam : dword
	local @listNameFont
	local @mainGroupFont
	local @currentSongFont
	local @numbersFont
	local @lyricFont
	; 设置static的字体字号
	invoke CreateFont, -28, -14, 0, 0, FW_BOLD, FALSE, FALSE, FALSE, 
		DEFAULT_CHARSET, OUT_CHARACTER_PRECIS, CLIP_CHARACTER_PRECIS, 
		DEFAULT_QUALITY, FF_DONTCARE, addr fontName
	mov	@listNameFont, eax
	invoke CreateFont, -14, -7, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE, 
		DEFAULT_CHARSET, OUT_CHARACTER_PRECIS, CLIP_CHARACTER_PRECIS, 
		DEFAULT_QUALITY, FF_DONTCARE, addr fontName
	mov @mainGroupFont, eax
	invoke CreateFont, -14, -7, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE, 
		DEFAULT_CHARSET, OUT_CHARACTER_PRECIS, CLIP_CHARACTER_PRECIS, 
		DEFAULT_QUALITY, FF_DONTCARE, addr fontName
	mov @currentSongFont, eax
	invoke CreateFont, -10, -5, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE, 
		DEFAULT_CHARSET, OUT_CHARACTER_PRECIS, CLIP_CHARACTER_PRECIS, 
		DEFAULT_QUALITY, FF_DONTCARE, addr fontName
	mov @numbersFont, eax
	invoke CreateFont, -20, -10, 0, 0, FW_SEMIBOLD, TRUE, FALSE, FALSE, 
		DEFAULT_CHARSET, OUT_CHARACTER_PRECIS, CLIP_CHARACTER_PRECIS, 
		DEFAULT_QUALITY, FF_DONTCARE, addr fontName
	mov @lyricFont, eax
	invoke SendDlgItemMessage, hWin, IDC_LIST_NAME, WM_SETFONT, @listNameFont, NULL
	invoke SendDlgItemMessage, hWin, IDC_MAIN_GROUP, WM_SETFONT, @mainGroupFont, NULL
	invoke SendDlgItemMessage, hWin, IDC_CURRENT_PLAY_SONG_TEXT, WM_SETFONT, @currentSongFont, NULL
	invoke SendDlgItemMessage, hWin, IDC_CURRENT_STATIC, WM_SETFONT, @currentSongFont, NULL
	invoke SendDlgItemMessage, hWin, IDC_PLAY_TIME_TEXT, WM_SETFONT, @numbersFont, NULL
	invoke SendDlgItemMessage, hWin, IDC_COMPLETE_TIME_TEXT, WM_SETFONT, @numbersFont, NULL
	invoke SendDlgItemMessage, hWin, IDC_SOUND_TEXT, WM_SETFONT, @numbersFont, NULL
	invoke SendDlgItemMessage, hWin, IDC_LYRICS, WM_SETFONT, @lyricFont, NULL
	; 加载主题背景图片
	invoke LoadBitmap, hInstance, IDB_BACKGROUND_BLUE
	mov bmp_Theme_Blue, eax
	invoke LoadBitmap, hInstance, IDB_BACKGROUND_ORANGE
	mov bmp_Theme_Orange, eax

	; 加载图标
	invoke LoadBitmap, hInstance, IDB_ADD_SONG_BLUE
	mov bmp_Add_Song_Blue, eax
	invoke LoadBitmap, hInstance, IDB_ADD_SONG_ORANGE
	mov bmp_Add_Song_Orange, eax
	invoke LoadBitmap, hInstance, IDB_NEW_LIST
	mov bmp_New_List, eax
	invoke LoadBitmap, hInstance, IDB_REMOVE_LIST
	mov bmp_Remove_List, eax
	invoke LoadBitmap, hInstance, IDB_REMOVE_SONG
	mov bmp_Remove_Song, eax

	invoke LoadIcon, hInstance, IDI_PLAY_BLUE
	mov ico_Play_Blue, eax
	invoke LoadIcon, hInstance, IDI_PLAY_ORANGE
	mov ico_Play_Orange, eax
	invoke LoadIcon, hInstance, IDI_SUSPEND_BLUE
	mov ico_Suspend_Blue, eax
	invoke LoadIcon, hInstance, IDI_SUSPEND_ORANGE
	mov ico_Suspend_Orange, eax
	invoke LoadImage, hInstance, IDI_FORWARD_BLUE, IMAGE_ICON, 23, 23, NULL
	mov ico_Forward_Blue, eax
	invoke LoadImage, hInstance, IDI_FORWARD_ORANGE, IMAGE_ICON, 23, 23, NULL
	mov ico_Forward_Orange, eax
	invoke LoadImage, hInstance, IDI_BACKWARD_BLUE, IMAGE_ICON, 23, 23, NULL
	mov ico_Backward_Blue, eax
	invoke LoadImage, hInstance, IDI_BACKWARD_ORANGE, IMAGE_ICON, 23, 23, NULL
	mov ico_Backward_Orange, eax
	invoke LoadImage, hInstance, IDI_NEXT_BLUE, IMAGE_ICON, 20, 20, NULL
	mov ico_Next_Blue, eax
	invoke LoadImage, hInstance, IDI_NEXT_ORANGE, IMAGE_ICON, 20, 20, NULL
	mov ico_Next_Orange, eax
	invoke LoadImage, hInstance, IDI_PRE_BLUE, IMAGE_ICON, 20, 20, NULL
	mov ico_Pre_Blue, eax
	invoke LoadImage, hInstance, IDI_PRE_ORANGE, IMAGE_ICON, 20, 20, NULL
	mov ico_Pre_Orange, eax
	invoke LoadImage, hInstance, IDI_VOLUM_BLUE, IMAGE_ICON, 20, 20, NULL
	mov ico_Volum_Blue, eax
	invoke LoadImage, hInstance, IDI_VOLUM_ORANGE, IMAGE_ICON, 20, 20, NULL
	mov ico_Volum_Orange, eax
	invoke LoadImage, hInstance, IDI_MUTE_BLUE, IMAGE_ICON, 20, 20, NULL
	mov ico_Mute_Blue, eax
	invoke LoadImage, hInstance, IDI_MUTE_ORANGE, IMAGE_ICON, 20, 20, NULL
	mov ico_Mute_Orange, eax
	invoke LoadImage, hInstance, IDI_RANDOM_BLUE, IMAGE_ICON, 20, 20, NULL
	mov ico_Random_Blue, eax
	invoke LoadImage, hInstance, IDI_RANDOM_ORANGE, IMAGE_ICON, 20, 20, NULL
	mov ico_Random_Orange, eax
	invoke LoadImage, hInstance, IDI_SINGLE_BLUE, IMAGE_ICON, 20, 20, NULL
	mov ico_Single_Blue, eax
	invoke LoadImage, hInstance, IDI_SINGLE_ORANGE, IMAGE_ICON, 20, 20, NULL
	mov ico_Single_Orange, eax
	invoke LoadImage, hInstance, IDI_LOOP_BLUE, IMAGE_ICON, 20, 20, NULL
	mov ico_Loop_Blue, eax
	invoke LoadImage, hInstance, IDI_LOOP_ORANGE, IMAGE_ICON, 20, 20, NULL
	mov ico_Loop_Orange, eax
	invoke LoadImage, hInstance, IDI_ADD_SONG_BLUE, IMAGE_ICON, 90, 25, NULL
	mov ico_Add_Song_Blue, eax
	invoke LoadImage, hInstance, IDI_ADD_SONG_ORANGE, IMAGE_ICON, 90, 25, NULL
	mov ico_Add_Song_Orange, eax
	invoke LoadImage, hInstance, IDI_NEW_LIST, IMAGE_ICON, 85, 22, NULL
	mov ico_New_List, eax
	invoke LoadImage, hInstance, IDI_REMOVE_LIST, IMAGE_ICON, 85, 22, NULL
	mov ico_Remove_List, eax
	invoke LoadImage, hInstance, IDI_REMOVE_SONG, IMAGE_ICON, 95, 25, NULL
	mov ico_Remove_Song, eax
	invoke LoadImage, hInstance, IDI_CLEAN_SONG, IMAGE_ICON, 120, 25, NULL
	mov ico_Clean_Song, eax

	invoke LoadImage, hInstance, IDI_CHANGE_BLUE, IMAGE_ICON, 20, 20, NULL
	mov ico_Change_Blue, eax
	invoke LoadImage, hInstance, IDI_CHANGE_ORANGE, IMAGE_ICON, 20, 20, NULL
	mov ico_Change_Orange, eax
	invoke LoadImage, hInstance, IDI_CROSS_BLUE, IMAGE_ICON, 20, 20, NULL
	mov ico_Cross_Blue, eax
	invoke LoadImage, hInstance, IDI_CROSS_ORANGE, IMAGE_ICON, 20, 20, NULL
	mov ico_Cross_Orange, eax

	; 加载相同资源到控件
	invoke SendDlgItemMessage, hWin, IDC_BACKGROUND, STM_SETIMAGE, IMAGE_BITMAP, bmp_Theme_Blue
	invoke SendDlgItemMessage, hWin, IDC_BACKGROUND_ORANGE, STM_SETIMAGE, IMAGE_BITMAP, bmp_Theme_Orange
	invoke SendDlgItemMessage, hWin, IDC_ADD_NEW_GROUP, BM_SETIMAGE, IMAGE_ICON, ico_New_List
	invoke SendDlgItemMessage, hWin, IDC_DELETE_CURRENT_GROUP, BM_SETIMAGE, IMAGE_ICON, ico_Remove_List
	invoke SendDlgItemMessage, hWin, IDC_DELETE_INVALID_SONGS, BM_SETIMAGE, IMAGE_ICON, ico_Clean_Song
	invoke SendDlgItemMessage, hWin, IDC_DELETE_CURRENT_SONG, BM_SETIMAGE, IMAGE_ICON, ico_Remove_Song
	ret
InitUI endp

; 变更主题
ChangeTheme proc, 
	hWin : dword
	; 计算当前主题号
	mov ax, curTheme
	inc ax
	mov	bl, 2
	div	bl
	movzx ax, ah
	mov curTheme, ax

	; 显示背景并把当前设置为不可见
	.if curTheme == 0
		; 隐藏当前背景
		invoke GetDlgItem, hWin, IDC_BACKGROUND
		invoke ShowWindow, eax, SW_SHOW
		; 显示目标背景
		invoke GetDlgItem, hWin, IDC_BACKGROUND_ORANGE
		invoke ShowWindow, eax, SW_HIDE
		; 对应图标放置到控件
		.if playState == STATE_PLAY
			invoke SendDlgItemMessage, hWin, IDC_PLAY_BUTTON, BM_SETIMAGE, IMAGE_ICON, ico_Suspend_Blue
		.else
			invoke SendDlgItemMessage, hWin, IDC_PLAY_BUTTON, BM_SETIMAGE, IMAGE_ICON, ico_Play_Blue
		.endif
		.if isMuted == 0
			invoke SendDlgItemMessage, hWin, IDC_MUTE_SONG, BM_SETIMAGE, IMAGE_ICON, ico_Volum_Blue
		.else
			invoke SendDlgItemMessage, hWin, IDC_MUTE_SONG, BM_SETIMAGE, IMAGE_ICON, ico_Mute_Blue
		.endif
		invoke SendDlgItemMessage, hWin, IDC_FILE_SYSTEM, BM_SETIMAGE, IMAGE_ICON, ico_Add_Song_Blue
		invoke SendDlgItemMessage, hWin, IDC_NEXT_BUTTON, BM_SETIMAGE, IMAGE_ICON, ico_Next_Blue
		invoke SendDlgItemMessage, hWin, IDC_PRE_BUTTON, BM_SETIMAGE, IMAGE_ICON, ico_Pre_Blue
		invoke SendDlgItemMessage, hWin, IDC_FAST_BACKWARD, BM_SETIMAGE, IMAGE_ICON, ico_Backward_Blue
		invoke SendDlgItemMessage, hWin, IDC_FAST_FORWARD, BM_SETIMAGE, IMAGE_ICON, ico_Forward_Blue
		invoke SendDlgItemMessage, hWin, IDC_CHANGE_MODE, BM_SETIMAGE, IMAGE_ICON, ico_Loop_Blue
		invoke SendDlgItemMessage, hWin, IDC_THEME, BM_SETIMAGE, IMAGE_ICON, ico_Change_Blue
		invoke SendDlgItemMessage, hWin, IDC_CLOSE, BM_SETIMAGE, IMAGE_ICON, ico_Cross_Blue
		; 固定背景bitmap
		invoke GetWindowRect, hWin, addr rect
		invoke GetDlgItem, hWin, IDC_BACKGROUND
		mov	ecx, rect.right
		sub ecx, rect.left
		mov ebx, rect.bottom
		sub ebx, rect.top
	.else
		; 隐藏当前背景
		invoke GetDlgItem, hWin, IDC_BACKGROUND_ORANGE
		invoke ShowWindow, eax, SW_SHOW
		; 显示目标背景
		invoke GetDlgItem, hWin, IDC_BACKGROUND
		invoke ShowWindow, eax, SW_HIDE
		; 对应图标放置到控件
		.if playState == STATE_PLAY
			invoke SendDlgItemMessage, hWin, IDC_PLAY_BUTTON, BM_SETIMAGE, IMAGE_ICON, ico_Suspend_Orange
		.else
			invoke SendDlgItemMessage, hWin, IDC_PLAY_BUTTON, BM_SETIMAGE, IMAGE_ICON, ico_Play_Orange
		.endif
		.if isMuted == 0
			invoke SendDlgItemMessage, hWin, IDC_MUTE_SONG, BM_SETIMAGE, IMAGE_ICON, ico_Volum_Orange
		.else
			invoke SendDlgItemMessage, hWin, IDC_MUTE_SONG, BM_SETIMAGE, IMAGE_ICON, ico_Mute_Orange
		.endif
		invoke SendDlgItemMessage, hWin, IDC_FILE_SYSTEM, BM_SETIMAGE, IMAGE_ICON, ico_Add_Song_Orange
		invoke SendDlgItemMessage, hWin, IDC_NEXT_BUTTON, BM_SETIMAGE, IMAGE_ICON, ico_Next_Orange
		invoke SendDlgItemMessage, hWin, IDC_PRE_BUTTON, BM_SETIMAGE, IMAGE_ICON, ico_Pre_Orange
		invoke SendDlgItemMessage, hWin, IDC_FAST_BACKWARD, BM_SETIMAGE, IMAGE_ICON, ico_Backward_Orange
		invoke SendDlgItemMessage, hWin, IDC_FAST_FORWARD, BM_SETIMAGE, IMAGE_ICON, ico_Forward_Orange
		invoke SendDlgItemMessage, hWin, IDC_CHANGE_MODE, BM_SETIMAGE, IMAGE_ICON, ico_Loop_Orange
		invoke SendDlgItemMessage, hWin, IDC_THEME, BM_SETIMAGE, IMAGE_ICON, ico_Change_Orange
		invoke SendDlgItemMessage, hWin, IDC_CLOSE, BM_SETIMAGE, IMAGE_ICON, ico_Cross_Orange
		; 固定背景bitmap
		invoke GetWindowRect, hWin, addr rect
		invoke GetDlgItem, hWin, IDC_BACKGROUND_ORANGE
		mov	ecx, rect.right
		sub ecx, rect.left
		mov ebx, rect.bottom
		sub ebx, rect.top
	.endif

	; 获得并调整窗口位置
	invoke MoveWindow, eax, 0, 0, ecx, ebx, 0
	ret
ChangeTheme endp

; 绘图函数
Paint proc, 
	hWin : dword
	local @ps : PAINTSTRUCT
	local @hdc_window : HDC
	local @hdc_memBuffer : HDC
	local @hdc_loadBmp : HDC
	local @blankBmp : HBITMAP
	
	; 准备画家和画布
	invoke RtlZeroMemory, addr @ps, sizeof @ps ; 将@ps结构体清0
	invoke BeginPaint, hWin, addr @ps
	mov @hdc_window, eax
	invoke CreateCompatibleDC, @hdc_window
	mov @hdc_memBuffer, eax
	invoke CreateCompatibleDC, @hdc_window
	mov @hdc_loadBmp, eax

	; 初始化缓存
	invoke CreateCompatibleBitmap, @hdc_window, WINDOW_WIDTH, WINDOW_HEIGHT
	mov @blankBmp, eax
	invoke SelectObject, @hdc_memBuffer, @blankBmp

	; 绘制各种资源到缓存
	; invoke SelectObject, @hdc_loadBmp, <target Bitmap>
	; invoke BitBlt, @hdc_memBuffer, posX, posY, width, height, @hdc_loadBmp, 0, 0, SRCCOPY
	
	; 将缓存信息绘制到屏幕
	invoke BitBlt, @hdc_window, 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, @hdc_memBuffer, 0, 0, SRCCOPY

	; 回收资源所占内存
	invoke DeleteObject, @blankBmp
	invoke DeleteDC, @hdc_memBuffer
	invoke DeleteDC, @hdc_loadBmp

	; 结束绘制
	invoke EndPaint, hWin, addr @ps
	ret
Paint endp

PauseCurrentSong proc
	.if playState == STATE_PAUSE ; 若已暂停则返回
		ret
	.endif 

	mov playState, STATE_PAUSE ; 转变为暂停态
	invoke mciExecute, ADDR cmd_pause
	ret
	;修改图标
PauseCurrentSong endp 

StopCurrentSong proc,
	hWin : dword
	.if playState != STATE_STOP
		invoke mciExecute, ADDR cmd_close ; 关闭设备
	.endif

	mov playState, STATE_STOP ; 变为停止态

	;初始化歌曲进度条
	invoke SendDlgItemMessage, hWin, IDC_SONG_LOCATE, TBM_SETRANGEMIN, 0, 0
	invoke SendDlgItemMessage, hWin, IDC_SONG_LOCATE, TBM_SETRANGEMAX, 0, 1
	invoke SendDlgItemMessage, hWin, IDC_SONG_LOCATE, TBM_SETPOS, 1, 0

	;初始化歌曲时间
	invoke wsprintf, ADDR mciCommand, ADDR timeFormat, 0, 0
	invoke SendDlgItemMessage, hWin, IDC_COMPLETE_TIME_TEXT, WM_SETTEXT, 0, ADDR mciCommand
	invoke SendDlgItemMessage, hWin, IDC_PLAY_TIME_TEXT, WM_SETTEXT, 0, ADDR mciCommand

	;初始化歌词文本
	invoke SendDlgItemMessage, hWin, IDC_LYRICS, WM_SETTEXT, 0, NULL
	ret
StopCurrentSong endp

ResumeCurrentSong proc
	.if playState == STATE_PLAY ; 若正在播放则返回
		ret
	.endif

	mov playState, STATE_PLAY ; 转变为播放态
	invoke mciExecute, ADDR cmd_resume
	ret
	;修改图标
ResumeCurrentSong endp

PlayCurrentSong proc,
    hWin : dword
	; test
	invoke CheckPlayCurrentSong, hWin
	.if eax == 0
		ret
	.endif
	; end test

	.if playState != STATE_STOP
		invoke mciExecute, ADDR cmd_close
	.endif

	mov playState, STATE_PLAY ; 转变为播放态
	invoke wsprintf, ADDR mciCommand, ADDR cmd_open, ADDR currentPlaySingleSongPath
	invoke mciExecute, ADDR mciCommand
	invoke mciExecute, ADDR cmd_play
	invoke AlterVolume, hWin

	;设置进度

	invoke mciSendString, ADDR cmd_getLen, ADDR curLen, 32, NULL ; 获取歌曲长度
	invoke StrToInt, ADDR curLen
	mov currentPlaySingleSongLength, eax

	;设置进度条
	invoke SendDlgItemMessage, hWin, IDC_SONG_LOCATE, TBM_SETRANGEMIN, 0, 0
	invoke SendDlgItemMessage, hWin, IDC_SONG_LOCATE, TBM_SETRANGEMAX, 0, currentPlaySingleSongLength
	invoke SendDlgItemMessage, hWin, IDC_SONG_LOCATE, TBM_SETPOS, 1, 0
	
	;设置文本
	invoke wsprintf, ADDR mciCommand, ADDR timeFormat, 0, 0
	invoke SendDlgItemMessage, hWin, IDC_PLAY_TIME_TEXT, WM_SETTEXT, 0, ADDR mciCommand

	mov eax, currentPlaySingleSongLength
	mov edx, 0
	mov ebx, 1000 ;
	div ebx ; eax 为秒数
	mov edx, 0
	mov ebx, 60 ; eax 为分钟数, edx为秒数 
	div ebx
	invoke wsprintf, ADDR mciCommand, ADDR timeFormat, eax, edx
	invoke SendDlgItemMessage, hWin, IDC_COMPLETE_TIME_TEXT, WM_SETTEXT, 0, ADDR mciCommand
	;修改图标

	;设置歌词
	invoke SendDlgItemMessage, hWin, IDC_LYRICS, WM_SETTEXT, 0, addr currentPlayLyricStr 
	ret
PlayCurrentSong endp

PlayMusic proc,
    hWin : dword 
	invoke CheckPlayCurrentSong, hWin ; 查看要播放的歌曲是否存在
	.if eax == 0
		ret
	.endif

	.if playState == STATE_STOP ; 当前为停止状态
		invoke SendDlgItemMessage, hWin, IDC_PLAY_BUTTON, BM_SETIMAGE, IMAGE_ICON, ico_Suspend_Blue
		invoke PlayCurrentSong, hWin
	.elseif playState == STATE_PLAY ; 当前为播放态
		invoke SendDlgItemMessage, hWin, IDC_PLAY_BUTTON, BM_SETIMAGE, IMAGE_ICON, ico_Play_Blue
		invoke PauseCurrentSong
	.elseif playState == STATE_PAUSE ; 当前为暂停态
		invoke SendDlgItemMessage, hWin, IDC_PLAY_BUTTON, BM_SETIMAGE, IMAGE_ICON, ico_Suspend_Blue
		invoke ResumeCurrentSong
	.endif
	ret 
PlayMusic endp

AlterVolume proc,
	hWin : dword
	invoke SendDlgItemMessage, hWin, IDC_SOUND, TBM_GETPOS, 0, 0	;获取当前Slider位置
	mov volume, eax

	;在static text中显示音量数值
	mov edx, 0
	mov ebx, 10 
	div ebx ; eax = volume / 10
	invoke wsprintf, addr mciCommand, addr intFormat, eax
	invoke SendDlgItemMessage, hWin, IDC_SOUND_TEXT, WM_SETTEXT, 0, addr mciCommand
	.if playState != STATE_STOP ; 没有音乐播放时，不改变MCI设备
		.if isMuted == 0 ;当前是否静音
			invoke wsprintf, addr mciCommand, addr cmd_setVol, volume
		.else
			invoke wsprintf, addr mciCommand, addr cmd_setVol, 0
		.endif
		invoke mciExecute, addr mciCommand ; 在MCI中改变音量
	.endif
	ret
AlterVolume endp

SetTimeText proc,
	hWin : dword
	mov eax, currentPlaySingleSongPos
	mov edx, 0
	mov ebx, 1000 ;
	div ebx ; eax 为秒数
	mov edx, 0
	mov ebx, 60 ; eax 为分钟数, edx为秒数 
	div ebx
	invoke wsprintf, addr mciCommand, addr timeFormat, eax, edx
	invoke SendDlgItemMessage, hWin, IDC_PLAY_TIME_TEXT, WM_SETTEXT, 0, addr mciCommand

	ret
SetTimeText endp

GetPlayPosition proc,
	hWin : dword
	
	invoke AlterVolume, hWin

	.if playState == STATE_STOP
		ret
	.endif
	
	;获取当前播放位置
	invoke mciSendString, addr cmd_getPos, addr curPos, 32, NULL
	invoke StrToInt, addr curPos
	mov currentPlaySingleSongPos, eax

	;设置进度条
	.if isDragging == 0 ; 未拖动
		invoke SendDlgItemMessage, hWin, IDC_SONG_LOCATE, TBM_SETPOS, 1, eax
	.else ; 拖动
		invoke SendDlgItemMessage, hWin, IDC_SONG_LOCATE, TBM_GETPOS, 0, 0
		mov currentPlaySingleSongPos, eax
		invoke wsprintf, addr mciCommand, addr cmd_setPos, eax
		invoke mciExecute, addr mciCommand
		invoke mciExecute, addr cmd_play
	.endif

	;设置PLAY_TIME_TEXT
	invoke SetTimeText, hWin

	;设置歌词
	invoke FindLyricAtTime, currentPlaySingleSongPos
	invoke SendDlgItemMessage, hWin, IDC_LYRICS, WM_SETTEXT, 0, addr currentPlayLyricStr 

	;检查歌曲是否结束
	.if playState != STATE_STOP
		mov eax, currentPlaySingleSongPos
		.if eax >= currentPlaySingleSongLength
			invoke PlayNextSong, hWin
		.endif
	.endif 

	ret
GetPlayPosition endp

FastForward proc,
	hWin : dword

	.if playState == STATE_STOP
		ret
	.endif

	;快进5s
	mov eax, currentPlaySingleSongPos
	add eax, 5000
	.if eax > currentPlaySingleSongLength
		mov eax, currentPlaySingleSongLength
	.endif
	mov currentPlaySingleSongPos, eax

	;设置进度条
	invoke SendDlgItemMessage, hWin, IDC_SONG_LOCATE, TBM_SETPOS, 1, eax

	;设置PLAY_TIME_TEXT
	invoke SetTimeText, hWin
	
	;获取当前播放位置
	invoke mciSendString, addr cmd_getPos, addr curPos, 32, NULL
	invoke StrToInt, addr curPos

	;MCI跳转播放
	.if eax != currentPlaySingleSongPos
		invoke wsprintf, addr mciCommand, addr cmd_setPos, currentPlaySingleSongPos
		invoke mciExecute, addr mciCommand
		invoke mciExecute, addr cmd_play
	.endif	
	ret
FastForward endp

FastBackward proc,
	hWin : dword

	.if playState == STATE_STOP
		ret
	.endif

	mov eax, currentPlaySingleSongPos
	.if eax >= 5000
		sub eax, 5000
	.else
		mov eax, 0
	.endif
	mov currentPlaySingleSongPos, eax
	;设置进度条
	invoke SendDlgItemMessage, hWin, IDC_SONG_LOCATE, TBM_SETPOS, 1, eax

	;设置PLAY_TIME_TEXT
	invoke SetTimeText, hWin
	
	;获取当前播放位置
	invoke mciSendString, addr cmd_getPos, addr curPos, 32, NULL
	invoke StrToInt, addr curPos

	;MCI跳转播放
	.if eax != currentPlaySingleSongPos
		invoke wsprintf, addr mciCommand, addr cmd_setPos, currentPlaySingleSongPos
		invoke mciExecute, addr mciCommand
		invoke mciExecute, addr cmd_play
	.endif
	ret
FastBackward endp

CollectSongName proc,
	songPath : dword,
	targetPath : dword ; 将songPath复制到targetPath，其复制的内容是歌曲name最大长度-1
	
	mov	esi, songPath
	mov	edi, targetPath
	mov	ecx, MAX_SONG_NAME_LEN - 1
	cld
	mov ax, curTheme
	rep movsb
	ret
CollectSongName endp

CheckPlayCurrentSong proc,
	hWin : dword
	.if currentPlaySingleSongIndex == DEFAULT_PLAY_SONG ; 判断要播放的歌是否选中
		invoke MessageBox, hWin, addr playSongNone, 0, MB_OK
		mov	eax, 0
		ret
	.endif
	
	invoke CheckFileExist, addr currentPlaySingleSongPath ; 判断要播放的歌是否路径存在
	.if eax == FILE_NOT_EXIST
		invoke DeleteInvalidSongs, hWin
		invoke ShowMainDialogView, hWin
		invoke MessageBox, hWin, addr playSongInvalid, 0, MB_OK
		mov eax, 0
		ret
	.endif

	mov	eax, 1
	ret
CheckPlayCurrentSong endp

PlayNextSong proc,
	hWin : dword
	invoke GetPreNxtSong, hWin, PLAY_NEXT
	ret
PlayNextSong endp

PlayPreviousSong proc,
	hWin : dword
	invoke GetPreNxtSong, hWin, PLAY_PREVIOUS
	ret
PlayPreviousSong endp

GetPreNxtSong proc,
	hWin : dword,
	method : dword ; 播放前一首还是后一首

	local indexToPlay : dword

	.if currentPlaySingleSongIndex == DEFAULT_PLAY_SONG ; 如果当前没有选中歌曲，返回错误
		invoke MessageBox, hWin, addr playPreNxtNone, 0, MB_OK
		ret
	.endif

;	invoke SendDlgItemMessage, hWin, IDC_MAIN_GROUP, LB_GETCURSEL, 0, 0 
;	mov	indexToPlay, eax ; indexToPlay = i 
	push currentPlaySingleSongIndex
	pop indexToPlay
;	mov	currentPlaySingleIndex, indexToPlay

	.if modePlay == MODE_LOOP
		invoke SendDlgItemMessage, hWin, IDC_MAIN_GROUP, LB_GETCOUNT, 0, 0
		add indexToPlay, eax; indexToPlay = i + n
		.if method == PLAY_NEXT 
			add	indexToPlay, 1; indexToPlay = i + n + 1
		.elseif method == PLAY_PREVIOUS
			sub indexToPlay, 1; indexToPlay = i + n - 1
		.endif
	
		.if indexToPlay >= eax  
			sub indexToPlay, eax ; indexToPlay %= n
			.if indexToPlay >= eax ; indexToPlay %= n
				sub indexToPlay, eax
			.endif
		.endif
	.elseif modePlay == MODE_ONE
		; do nothing
	.elseif modePlay == MODE_RANDOM
		invoke SendDlgItemMessage, hWin, IDC_MAIN_GROUP, LB_GETCOUNT, 0, 0
		mov ebx, eax
		invoke GetSystemTime, addr randomTime ; 使用系统时间生成伪随机数

		mov eax, 0
		mov	ax, randomTime.wMilliseconds 
		div bl ; 取模以获取合法的下一首歌的index

		mov al, ah
		mov ah, 0
		mov dx, 0
		mov	indexToPlay, eax
	.endif

	invoke SendDlgItemMessage, hWin, IDC_MAIN_GROUP, LB_SETCURSEL, indexToPlay, 0
	invoke SelectPlaySong, hWin

	invoke PlayCurrentSong, hWin ; 播放

	ret
GetPreNxtSong endp

ChangeMode proc,
	hWin : dword

	.if modePlay == MODE_ONE
		mov modePlay, MODE_RANDOM
		; icon
	.elseif modePlay == MODE_RANDOM
		mov modePlay, MODE_LOOP
		; icon
	.elseif modePlay == MODE_LOOP
		mov modePlay, MODE_ONE
		; icon
	.endif

	ret
ChangeMode endp

FindLyricAtTime proc,
	timeStamp : dword
	.if hasLyric == LYRIC_NOT_EXIST
;		invoke RtlZeroMemory, addr currentPlayLyricStr, sizeof currentPlayLyricStr
		ret
	.endif
	mov eax, currentLyricTime
	mov ebx, currentPlayLyricIndex
	mov esi, currentPlayLyricPos

	.if timeStamp < eax 
REPEAT_PRE_FIND:
		.if timeStamp >= eax 
			mov currentLyricTime, eax
			mov currentPlayLyricIndex, ebx
			mov currentPlayLyricPos, esi
			add esi, size dword
			invoke CollectLyricStr, esi, addr currentPlayLyricStr
			jmp END_PRE_FIND
		.endif
		sub ebx, 1
		sub esi, size lyric
		mov nextLyricTime, eax
		mov eax, (lyric ptr [esi]).timeStamp
		jmp REPEAT_PRE_FIND
END_PRE_FIND:
	.endif

	mov eax, nextLyricTime
	mov ebx, currentPlayLyricIndex
	mov esi, currentPlayLyricPos
	.if timeStamp >= eax 
REPEAT_NEXT_FIND:
		.if timeStamp < eax 
			mov nextLyricTime, eax
			mov currentPlayLyricIndex, ebx
			mov currentPlayLyricPos, esi
			add esi, size dword
			invoke CollectLyricStr, esi, addr currentPlayLyricStr
			jmp END_NEXT_FIND
		.endif
		add ebx, 1
		add esi, size lyric
		mov currentLyricTime, eax
		add esi, size lyric
		mov eax, (lyric ptr [esi]).timeStamp
		sub esi, size lyric
		jmp  REPEAT_NEXT_FIND
END_NEXT_FIND:
	.endif

	ret
FindLyricAtTime endp

SetInitLyric proc
	invoke ReadLyric
	.if hasLyric ==  LYRIC_NOT_EXIST
		mov esi, offset lyricNone
		mov edi, offset currentPlayLyricStr
		mov ecx, lengthof lyricNone
		cld
		rep movsb
		ret
	.endif
	mov currentPlayLyricIndex, 0
	mov esi, offset currentLyrics
	add esi, size dword
	invoke CollectLyricStr, esi, addr currentPlayLyricStr ; 将第0个lyric交给currentPlayLyricStr

	mov esi, offset currentLyrics
	mov currentPlayLyricPos, esi ; 记录当前播放的lyric的位置
	add esi, size lyric
	push (lyric ptr [esi]).timeStamp ; 记录下一个lyric的时间
	pop nextLyricTime
	ret
SetInitLyric endp

CollectLyricStr proc,
	sourceStr : dword,
	targetStr : dword

	mov esi, sourceStr
	mov edi, targetStr
	mov ecx, MAX_SINGLE_LYRIC_LEN - 1
	cld
	rep movsb
	ret
CollectLyricStr endp

ReadLyric proc

	local BytesRead : dword
	local timeMinute : dword
	local timeSecond : dword
	local timeMillisecond : dword
	local lyricSavePos : dword
	local strPos : dword
	local strConter : dword
	local const10 : dword
	local const60 : dword
	local const1000 : dword
	local counter : dword
	local scounter : sdword

	mov counter, 0
	mov scounter, 0

	mov const10, 10
	mov const60, 60
	mov const1000, 1000

	mov  currentLyricTime, 0
	mov currentPlayLyricIndex, DEFAULT_PLAY_LYRIC
	mov nextLyricTime,INF
	invoke RtlZeroMemory, addr currentPlayLyricStr, sizeof currentPlayLyricStr
	invoke RtlZeroMemory, addr currentLyrics, sizeof currentLyrics
	invoke GetLyricPath
	.if hasLyric == LYRIC_NOT_EXIST ; 如果歌词文件不存在，那么设置这首歌没有歌曲文件
		ret
	.endif

	push offset currentLyrics
	pop lyricSavePos

	mov esi, lyricSavePos
	mov (lyric  ptr [esi]).timeStamp, 0
	add esi, size dword
	invoke GetFileTitle, addr currentPlaySingleSongPath, esi, MAX_SINGLE_LYRIC_LEN - 1
	mov esi, lyricSavePos
	add esi, size lyric
	mov lyricSavePos, esi
	add lyricCounter, 1
;	invoke CollectLyricStr, 

	invoke SetFileApisToANSI
	invoke CreateFile, offset currentPlayLyricPath, GENERIC_READ,0 ,0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
	mov handler, eax


REPEAT_READ:
	invoke ReadFile, handler, addr buffer, 1, addr BytesRead, 0 ; 读[
	.if BytesRead == 0
		jmp END_READ
	.endif
	.if buffer != '['
		jmp END_READ
	.endif
	add lyricCounter, 1

	mov timeMinute, 0
	mov timeSecond, 0
	mov timeMillisecond, 0
FIND_MINUTE: ; 读分钟
	invoke ReadFile, handler, addr buffer, 1, addr BytesRead, 0 
	.if [buffer] != ':'
		push eax
		mov eax, timeMinute
		mul const10
		mov timeMinute, eax
		invoke atol, addr buffer
		add timeMinute, eax
		pop eax
		jmp FIND_MINUTE
	.endif

FIND_SECOND: ; 读秒钟位
	invoke ReadFile, handler, addr buffer, 1, addr BytesRead, 0 
	.if [buffer] != '.'
		push eax
		mov eax, timeSecond
		mul const10
		mov timeSecond, eax
		invoke atol, addr buffer
		add timeSecond, eax
		pop eax
		jmp FIND_SECOND
	.endif

FIND_MILLISECOND:
	invoke ReadFile, handler, addr buffer, 1, addr BytesRead, 0 
	.if [buffer] != ']'
		push eax
		mov eax, timeMillisecond
		mul const10
		mov timeMillisecond, eax
		invoke atol, addr buffer
		add timeMillisecond, eax
		pop eax
		jmp FIND_MILLISECOND
	.endif

	push eax
	mov eax, timeMinute
	mul const60
	mul const1000
	add timeMillisecond, eax
	mov eax,timeSecond
	mul const1000
	add timeMillisecond, eax
	pop eax

	push esi
	mov esi, lyricSavePos
	push timeMillisecond
	pop (lyric ptr [esi]).timeStamp
	mov esi, lyricSavePos
	add esi, size dword
	mov strPos, esi
	pop esi

	mov scounter, 0
	mov counter, 0
READ_STR:
	invoke ReadFile, handler, addr buffer, 1, addr BytesRead, 0 
	sub scounter, 1
	add counter, 1
	.if BytesRead == 0
		invoke SetFilePointer, handler, scounter, 0, FILE_CURRENT
		invoke ReadFile, handler, strPos, counter, addr BytesRead, 0
		jmp END_READ
	.endif
	mov dl, [buffer]
	.if dl != 0ah
		jmp READ_STR
	.endif

	invoke RtlZeroMemory, strPos, MAX_SINGLE_LYRIC_LEN
	invoke SetFilePointer, handler, scounter, 0, FILE_CURRENT
	invoke ReadFile, handler, strPos, counter, addr BytesRead, 0

	mov esi, lyricSavePos
	add esi, size lyric
	mov lyricSavePos, esi
	jmp REPEAT_READ
END_READ:
	invoke CloseHandle, handler

	mov esi, lyricSavePos
	mov (lyric  ptr [esi]).timeStamp, INF
	add esi, size lyric
	mov lyricSavePos, esi
	add lyricCounter, 1

	ret
ReadLyric endp

GetLyricPath proc

	local pointPos : dword

	.if currentPlaySingleSongIndex == DEFAULT_PLAY_SONG
		mov	hasLyric, LYRIC_NOT_EXIST
		ret
	.endif

	invoke CollectSongPath, addr currentPlaySingleSongPath, addr currentPlayLyricPath
	mov	ecx, offset currentPlayLyricPath
	mov pointPos, ecx



REPEAT_READ:
	mov al, [ecx]
	.if al == '.'
		mov pointPos, ecx
	.endif
	.if eax != 0
		add ecx, size byte
		jmp REPEAT_READ
	.endif

	mov	esi, offset lyricSuffix
	mov	edi, pointPos
	add edi, size byte
;	mov edi, offset currentPlayLyricPath
	mov ecx, 4
	cld
	rep movsb


	invoke CheckFileExist, addr currentPlayLyricPath
	.if eax == FILE_NOT_EXIST
		mov hasLyric, LYRIC_NOT_EXIST
		ret
	.endif
	mov hasLyric, LYRIC_DO_EXIST
	ret
GetLyricPath endp

END WinMain