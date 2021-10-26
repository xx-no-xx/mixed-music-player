.386
.model flat, stdcall
option casemap:none

include windows.inc
include user32.inc
include kernel32.inc
include masm32.inc
; include comctl32.inc
include comdlg32.inc ; 文件操作
include winmm.inc

; irvine32.inc

includelib masm32.lib
includelib user32.lib
includelib kernel32.lib
includelib comdlg32.lib
includelib Winmm.lib

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
<<<<<<< HEAD
IDC_BACKGROUND					equ 2001 ; 背景图层
;--------------- image & icon ----------------
IDB_BITMAP_START				equ 111
IDB_BACKGROUND_BLUE             equ 115
IDB_BACKGROUND_ORANGE           equ 116
;---------------- process --------------------
=======
IDC_PLAY_BUTTON                 equ 1030 ; 播放/暂停按钮
IDC_PRE_BUTTON                  equ 1032 ; 上一首
IDC_NEXT_BUTTON                 equ 1033 ; 下一首


;---------------- process -------------
>>>>>>> origin
DO_NOTHING			equ 0 ; 特定的返回值标识
DEFAULT_SONG_GROUP  equ 99824 ; 默认组别被分配到的编号 ; todo : change 99824 to 0
DEFAULT_PLAY_SONG   equ 21474 ; 默认的第index首歌 ; todo : change 21474 to a larger num

FILE_DO_EXIST		equ 0 ; 文件存在
FILE_NOT_EXIST		equ 1 ; 文件不存在

STATE_PAUSE equ 0 ; 暂停播放
STATE_PLAY equ 1 ; 正在播放
STATE_STOP equ 2 ; 停止播放


DELETE_ALL_SONGS_IN_GROUP	equ 0 ;删除songGroup(dword)里的所有歌
DELETE_CURRENT_PLAY_SONG	equ 1 ;删除选中的那首歌（current play song）
DELETE_INVALID				equ 2 ;删除所有不存在的路径对应的歌

MAX_FILE_LEN equ 1000 ; 最长文件长度
MAX_GROUP_DETAIL_LEN equ 32 ; 组别编号的最长长度
MAX_GROUP_NAME_LEN equ 20 ; 歌单名称的最长长度
MAX_GROUP_SONG equ 30 ; 歌单内歌曲的最大数
MAX_GROUP_NUM equ 10 ; 最大的歌单数量
MAX_SONG_NAME_LEN equ 100; 最大歌曲的名字的长度 ;todotodotodo

MAX_ALL_SONG_NUM equ 300 ; 全体歌曲的最大数目（=MAX_GROUP_SONG * MAX_GROUP_NUM）

; 实际最大LEN应该-1， 这是因为str最后需要为0，否则输出时会跨越到别的存储区域。

SAVE_TO_MAIN_DIALOG_GROUP		equ 1 ; 主界面展示用：保存至当前歌单
SAVE_TO_TARGET_GROUP		equ 2 ; 歌曲管理用：保存至管理页的当前歌单
SAVE_TO_DEFAULT_GROUP		equ 3 ; 歌单管理用：保存至管理页的默认歌单


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

SelectSong proto, ; 选中当前播放的歌曲
	hWin : dword
; todo
	
DeleteTargetSong proto, ; 删除目标歌曲
	hWin : dword,
	method : dword, 
	songGroup : dword
; 分为三种删除的method: 
; DELETE_ALL_SONGS_IN_GROUP	:删除songGroup(dword)里的所有歌, 需要指定songGroup
; DELETE_CURRENT_PLAY_SONG	:删除选中的那首歌（current play song）
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
	
<<<<<<< HEAD
ChangeTheme proto,	; 更换皮肤
	hWin : dword
; 鼠标左键事件
LButtonDown proto, 
	hWin : dword, 
	wParam : dword, 
	lParam : dword

; 界面布局
InitUI proto, 
	hWin : dword, 
	wParam : dword,
	lParam : dword
=======
PlayMusic proto, ; 播放/暂停音乐	
	hWin : dword

CheckPlayCurrentSong proto, ; 试图播放当前的歌曲currentPlaySingleSongPath
	hWin : dword
; eax = 0 代表不能够播放（1.没选中歌曲，2.歌曲不存在）
; eax = 1 代表当前选中了歌曲且歌曲存在

>>>>>>> origin

Paint proto, 
	hWin :dword
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

mciCommand BYTE ?
playState BYTE 0

handler HANDLE ? ; 文件句柄
divideLine byte 0ah ; 换行divideLine

currentPlaySingleSongIndex dword DEFAULT_PLAY_SONG; 目前正在播放的歌曲信息
currentPlaySingleSongPath byte MAX_FILE_LEN dup(0); 目前正在播放歌曲的路径

currentPlayGroup dword DEFAULT_SONG_GROUP ; 目前正在播放的歌单编号
groupDetailStr byte MAX_GROUP_DETAIL_LEN dup("a") ; 目前正在播放的歌单编号的str格式。 需要访问GetGroupDetailInStr以更新

; 歌单分为自定义歌单和默认歌单。默认歌单包括全部歌曲。

numCurrentGroupSongs dword 0 ; 当前播放歌单的歌曲数量
currentGroupSongs song MAX_GROUP_SONG dup(<,>) ; 当前播放歌单的所有歌曲信息

maxGroupId dword 0

; ++++++++++++++删除功能引入的临时存储变量++++++++++++++
; ++++ 你不应在除了删除功能之外的函数访问这些变量 +++++++
delAllGroups songgroup MAX_GROUP_NUM dup(<,>)
delAllSongs song MAX_ALL_SONG_NUM dup(<,>)

; ++++++++++++++导入文件OPpenFileName结构++++++++++++++
ofn OPENFILENAME <>
ofnTitle BYTE '导入音乐', 0	
ofnFilter byte "Media Files(*mp3, *wav)", 0, "*.mp3;*.wav", 0, 0

; ++++++++++++++Message Box 提示信息++++++++++++++++++
deleteNone byte "您没有选中歌单，不能删除。",0
addNone byte "您没有选中歌单，不能导入歌曲。", 0
deleteSongNone byte "您没有选中歌曲，不能删除。", 0
playSongNone byte "您没有选中歌曲，不能播放。", 0
playSongInvalid byte "您选中的歌曲不存在，已自动为您删除不存在的歌曲。"


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
buffer byte 0

readGroupNameStr byte MAX_GROUP_NAME_LEN dup(0)

inputGroupNameStr byte MAX_GROUP_NAME_LEN dup("1")
; to change "1" -> 0

; ++++++++++++++测试专用+++++++++++++ 
; ++++++++请根据自己的机器路径修改+++++++++
; TODO-TODO-TODO-TODO-TODO-TODO-TODO
simpleText byte "somethingrighthere", 0ah, 0
ofnInitialDir BYTE "D:\music", 0 ; default open C only for test
songData BYTE "C:\Users\dell\Desktop\data\data.txt", 0 
testint byte "TEST INT: %d", 0ah, 0dh, 0
groupData byte "C:\Users\dell\Desktop\data\groupdata.txt", 0

; 图像资源数据
bmp_Start				dword	?
bmp_Theme_Blue			dword	?	; 蓝色主题背景
bmp_Theme_Orange		dword	?	; 橙色主题背景

curTheme	word	0	; 当前主题编号
; +++++++++++++++code++++++++++++++++++
.code

WinMain PROC
	INVOKE GetModuleHandle, NULL
	mov hInstance, eax
	invoke DialogBoxParam, hInstance, IDD_DIALOG, 0, addr DialogMain, 0
	invoke ExitProcess, 0
WinMain ENDP

DialogMain proc,
	hWin : dword,
	uMsg : dword,
	wParam : dword,
	lParam : dword

	local loword : word
	local hiword : word

	mov	eax, wParam ; WParam = (hiword, lowrd) : 详见notification code
	mov	loword, ax
;	mov	hiword, 
	shrd eax, ebx, 16
	mov	hiword, ax

	.if	uMsg == WM_INITDIALOG
		invoke InitUI, hWin, wParam, lParam
		push hWin
		pop hMainDialog
		invoke GetAllGroups, hWin
		invoke ShowMainDialogView, hWin
		; do something
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
	.else
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

	invoke SendDlgItemMessage, hWin, IDC_MAIN_GROUP, LB_RESETCONTENT, 0, 0 ; clear listbox里的内容
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
	invoke SelectSong, hWin ; 选择对应的song
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

SelectSong proc, ; 设置当前播放的歌曲
	hWin : dword

	local indexToPlay : dword ; 当前应该播放歌曲的index

	invoke SendDlgItemMessage, hWin, IDC_MAIN_GROUP, LB_GETCURSEL, 0, 0 ; 获取当前选中的歌曲
	.if eax == LB_ERR ; 如果没有选中，那么返回
		mov currentPlaySingleSongIndex, DEFAULT_PLAY_SONG
		ret
	.endif

	mov	currentPlaySingleSongIndex, eax ; 将index记录在currentPlaySingleSongIndex上

	mov	ebx, size song 
	mul	ebx ;计算目标song在currentGroupSongs中的偏移量

	mov	esi, offset currentGroupSongs ; 设置songGroup的指针
	add	esi, eax

	invoke CollectSongPath, addr (song ptr [esi]).path, addr currentPlaySingleSongPath ;复制当前歌曲的路径到currentPlaySingleSongPath
	ret
SelectSong endp

DeleteTargetSong proc,
	hWin : dword, 
	method : dword, ; 支持几种删除的method
	songGroup : dword ; 指定DELETE_ALL_SONGS_IN_GROUP方法中删除哪一个group

	local counter : dword
	local BytesWrite : dword
;	index : dword

; 分为三种删除的method: 
; DELETE_ALL_SONGS_IN_GROUP	:删除songGroup(dword)里的所有歌, 需要指定songGroup
; DELETE_CURRENT_PLAY_SONG	:删除选中的那首歌（current play song）
; DELETE_INVALID			:删除所有不存在的路径对应的歌

	.if method == DELETE_CURRENT_PLAY_SONG ; 
		.if currentPlaySingleSongIndex == DEFAULT_PLAY_SONG
			invoke MessageBox, hWin, addr deleteSongNone, 0, MB_OK ;如果删除当前播放的歌曲，且当前没有播放的歌曲，报错
			ret
		.endif
	.endif

	.if method == DELETE_ALL_SONGS_IN_GROUP
		.if songGroup == DEFAULT_SONG_GROUP
			ret ; 如果删除一个组，且这个组不存在，返回
		.endif
	.endif

	invoke GetAllSongInData ; 获取所有data.txt中的歌曲信息，存储在delAllSongs之中
	mov		counter, eax

    invoke  CreateFile,offset songData,GENERIC_WRITE, 0, 0,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0 ; 读取所有的歌曲
	mov		handler, eax
	mov		esi, offset delAllSongs

	invoke SetFilePointer, handler, 0, 0, FILE_BEGIN ; 将文件指针移动到开头
	mov		ecx, 0 ; ecx记录目前是songGroup的第ecx首歌

REPEAT_WRITE:
	.if counter == 0
		jmp END_WRITE
	.endif
	dec counter

	mov edx, (song ptr [esi]).groupid ; 获取当前歌曲的group
	
	.if edx == currentPlayGroup 
		.if method == DELETE_CURRENT_PLAY_SONG  ; 如果当前歌曲属于currentPlayGroup, 且method时DELETE_CURRENT_PLAY_SONG
			.if ecx == currentPlaySingleSongIndex ; 如果是当前播放的歌曲
				add	esi, size song 
				inc ecx ; 计数器+1
				jmp REPEAT_WRITE
			.endif
			inc ecx ; 计数器+1
		.endif
	.endif

	.if edx == songGroup  
		.if method == DELETE_ALL_SONGS_IN_GROUP ; 如果当前歌曲属于songGroup，且method是DELETE_ALL_SONGS_IN_GROUP
			add esi, size song
			jmp REPEAT_WRITE
		.endif
	.endif

	push ecx ; 保存ecx
	.if method == DELETE_INVALID
		push eax
		invoke CheckFileExist, addr (song ptr [esi]).path
		.if eax == FILE_NOT_EXIST ; 如果method是DELETE_INVALID且当前文件不存在
			pop eax
			add esi, size song
			jmp REPEAT_WRITE
		.endif
		pop eax
	.endif

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
	invoke DeleteTargetSong, hWin, DELETE_CURRENT_PLAY_SONG, 0 ; 删除当前播放的歌曲
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
	.if @mouseX > 1033 && @mouseX < 1063 && @mouseY > 32 && @mouseY < 55
		invoke EndDialog,hWin,0
		.if hNewGroup != 0
			invoke EndDialog, hNewGroup, 0
		.endif
	.elseif @mouseX > 989 && @mouseX < 1019 && @mouseY > 32 && @mouseY < 55
		invoke ChangeTheme, hWin
	.endif
	ret
LButtonDown endp
;// 鼠标左键按下事件处理函数
;void LButtonDown(HWND hWnd, WPARAM wParam, LPARAM lParam) {
; mouseX = LOWORD(lParam);
; mouseY = HIWORD(lParam);
; mouseDown = true;
; 界面布局函数
InitUI proc, 
	hWin : dword, 
	wParam : dword, 
	lParam : dword
	; 加载测试图片
	invoke LoadBitmap, hInstance, IDB_BITMAP_START
	mov bmp_Start, eax
	; 加载主题背景图片
	invoke LoadBitmap, hInstance, IDB_BACKGROUND_BLUE
	mov bmp_Theme_Blue, eax
	invoke LoadBitmap, hInstance, IDB_BACKGROUND_ORANGE
	mov bmp_Theme_Orange, eax

	; 测试图片放置到测试元件
	invoke SendDlgItemMessage, hWin, IDC_BACKGROUND, STM_SETIMAGE, IMAGE_BITMAP, bmp_Theme_Blue
;	mov eax, IMG_START
;	invoke LoadImage, hInstance, eax,IMAGE_ICON,32,32,NULL
;	invoke SendDlgItemMessage,hWin,IDC_paly_btn, BM_SETIMAGE, IMAGE_ICON, eax
	ret
InitUI endp

; 变更主题
ChangeTheme proc, 
	hWin : dword
	mov ax, curTheme
	inc ax
	mov	bl, 2
	div	bl
	movzx ax, ah
	mov curTheme, ax
	.if curTheme == 1
		invoke SendDlgItemMessage, hWin, IDC_BACKGROUND, STM_SETIMAGE, IMAGE_BITMAP, bmp_Theme_Orange
	.else
		invoke SendDlgItemMessage, hWin, IDC_BACKGROUND, STM_SETIMAGE, IMAGE_BITMAP, bmp_Theme_Blue
	.endif
	ret
ChangeTheme endp

; 绘图函数
Paint proc, 
	hWin : dword
	local @ps : dword ;PAINTSTRUCT <>
	ret
Paint endp


PlayMusic proc,
	hWin : dword
	; test
	invoke CheckPlayCurrentSong, hWin
	.if eax == 0
		ret
	.endif
	; end test

	.if playState == STATE_STOP ; 当前为停止状态
		mov playState, STATE_PLAY ; 转变为播放态
	.elseif playState == STATE_PLAY ; 当前为播放态
		mov playState, STATE_PAUSE ; 转变为暂停态
	.else ; 当前为暂停态
		mov playState, STATE_PLAY ; 转变为播放态
	.endif
	ret 
PlayMusic endp

CollectSongName proc,
	songPath : dword,
	targetPath : dword ; 将songPath复制到targetPath，其复制的内容是歌曲name最大长度-1
	
	mov	esi, songPath
	mov	edi, targetPath
	mov	ecx, MAX_SONG_NAME_LEN - 1
	cld
	rep movsb
	ret
CollectSongName endp

CheckPlayCurrentSong proc,
	hWin : dword
	.if currentPlaySingleSongIndex == DEFAULT_PLAY_SONG
		invoke MessageBox, hWin, addr playSongNone, 0, MB_OK
		mov	eax, 0
		ret
	.endif
	
	invoke CheckFileExist, addr currentPlaySingleSongPath
	.if eax == FILE_NOT_EXIST
		invoke DeleteInvalidSongs, hWin
		invoke MessageBox, hWin, addr playSongInvalid, 0, MB_OK
		mov eax, 0
		ret
	.endif

	mov	eax, 1
	ret
CheckPlayCurrentSong endp
END WinMain

