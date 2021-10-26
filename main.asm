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
IDC_BACKGROUND					equ 2001 ; 背景图层
;--------------- image & icon ----------------
IDB_BITMAP_START				equ 111
IDB_BACKGROUND_BLUE             equ 115
IDB_BACKGROUND_ORANGE           equ 116
;---------------- process --------------------
DO_NOTHING			equ 0 ; 特定的返回值标识
DEFAULT_SONG_GROUP  equ 99824 ; 默认组别被分配到的编号 ; todo : change 99824 to 0
DEFAULT_PLAY_SONG   equ 21474 ; 默认的第index首歌 ; todo : change 21474 to a larger num

FILE_DO_EXIST		equ 0 ; 文件存在
FILE_NOT_EXIST		equ 1 ; 文件不存在

DELETE_ALL_SONGS_IN_GROUP	equ 0 ;删除songGroup(dword)里的所有歌
DELETE_CURRENT_PLAY_SONG	equ 1 ;删除选中的那首歌（current play song）
DELETE_INVALID				equ 2 ;删除所有不存在的路径对应的歌

MAX_FILE_LEN equ 1000 ; 最长文件长度
MAX_GROUP_DETAIL_LEN equ 32 ; 组别编号的最长长度
MAX_GROUP_NAME_LEN equ 20 ; 歌单名称的最长长度
MAX_GROUP_SONG equ 30 ; 歌单内歌曲的最大数
MAX_GROUP_NUM equ 10 ; 最大的歌单数量

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

GetCurrentGroupSong proto

GetTargetGroupSong proto,
	songGroup : dword,
	saveTo: dword

song struct ; 歌曲信息结构体
	path byte MAX_FILE_LEN dup(0)
;	songname byte 10 dup(0) ; TODO: 歌曲名称
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

ShowMainDialogView proto,
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
;toodo

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

; 界面布局
InitUI proto, 
	hWin : dword, 
	wParam : dword,
	lParam : dword

Paint proto, 
	hWin :dword
; +++++++++++++++++++ data +++++++++++++++++++++
.data

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

	mov	eax, wParam
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

	.if currentPlayGroup == DEFAULT_SONG_GROUP
		invoke MessageBox, hWin, addr addNone, 0, MB_OK
		ret
	.endif

	invoke  RtlZeroMemory, addr ofn, sizeof ofn ; fill with 0

	mov ofn.lStructSize, sizeof OPENFILENAME

	push hWin
	pop ofn.hwndOwner ; hwndOwner = hWin

	mov ofn.lpstrTitle, OFFSET ofnTitle
	mov ofn.lpstrInitialDir, OFFSET ofnInitialDir
	mov	ofn.nMaxFile, MAX_FILE_LEN
	mov	ofn.lpstrFile, OFFSET currentSongNameOFN
	mov	ofn.lpstrFilter, offset ofnFilter
	mov ofn.Flags, OFN_HIDEREADONLY

	invoke GetOpenFileName, addr ofn

	.if eax == DO_NOTHING
		jmp EXIT_IMPORT
	.endif

	invoke AddSingleSongOFN, currentPlayGroup

EXIT_IMPORT:
	xor eax, eax ; eax = 0
	ret
ImportSingleFile endp

AddSingleSongOFN proc,
	songGroup : dword

	LOCAL BytesWritten : dword
	LOCAL handler_saved : dword
	LOCAL lpstrLength : dword


	invoke GetGroupDetailInStr, songGroup

    INVOKE  CreateFile,offset songData,GENERIC_WRITE, 0, 0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	mov		handler, eax
	mov		handler_saved, eax

	invoke SetFilePointer, handler, 0, 0, FILE_END

	invoke lstrlen, ofn.lpstrFile
	mov	 lpstrLength, eax

	invoke WriteFile, handler, addr divideLine, length divideLine,  addr BytesWritten, NULL
	invoke WriteFile, handler, addr groupDetailStr, MAX_GROUP_DETAIL_LEN , addr BytesWritten, NULL

	invoke WriteFile, handler, addr divideLine, length divideLine,  addr BytesWritten, NULL
	invoke WriteFile, handler, ofn.lpstrFile, MAX_FILE_LEN, addr BytesWritten, NULL

	invoke CloseHandle, handler_saved

	ret
AddSingleSongOFN endp

GetGroupDetailInStr proc,
	songGroup : dword
	invoke  RtlZeroMemory, addr groupDetailStr, sizeof groupDetailStr
	invoke dw2a, songGroup, addr groupDetailStr
	ret
GetGroupDetailInStr endp

GetCurrentGroupSong proc
	invoke GetTargetGroupSong, currentPlayGroup, SAVE_TO_MAIN_DIALOG_GROUP
	ret
GetCurrentGroupSong endp

GetTargetGroupSong proc,
	songGroup : dword,
	saveTo : dword

	LOCAL BytesRead : dword
	LOCAL handler_saved : dword
	LOCAL lpstrLength : dword

	LOCAL counter : dword

    invoke  CreateFile,offset songData,GENERIC_READ, 0, 0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	mov		handler, eax

	.if saveTo == SAVE_TO_MAIN_DIALOG_GROUP
		mov	 esi, offset currentGroupSongs
	.endif

	mov	counter, 0
REPEAT_READ:
	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL
	.if BytesRead == 0
		jmp END_READ
	.endif
	invoke ReadFile, handler, addr readGroupDetailStr, MAX_GROUP_DETAIL_LEN , addr BytesRead, NULL

	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL
	invoke ReadFile, handler, addr readFilePathStr, MAX_FILE_LEN, addr BytesRead, NULL

	invoke atol, addr readGroupDetailStr
	.if eax > maxGroupId ; todo: may move to GetAllGroups
		mov maxGroupId, eax
	.endif
	.if eax == songGroup
		push esi
		invoke CollectSongPath, addr readFilePathStr, addr (song ptr [esi]).path
		push songGroup
		pop	(song ptr [esi]).groupid
		pop esi
		add	esi, SIZE song
		inc counter
	.endif
	

	jmp REPEAT_READ
END_READ:
	invoke CloseHandle, handler

	.if saveTo == SAVE_TO_MAIN_DIALOG_GROUP 
		push counter
		pop numCurrentGroupSongs
	.endif

	ret
GetTargetGroupSong endp

CollectSongPath proc,
	songPath : dword,
	targetPath : dword
	
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

;	invoke SendDlgItemMessage, hWin, IDC_GROUPS, CB_ADDSTRING, 0, addr simpleText

	invoke SendDlgItemMessage, hWin, IDC_MAIN_GROUP, LB_RESETCONTENT, 0, 0
	invoke GetCurrentGroupSong

	push numCurrentGroupSongs
	pop	 counter

	mov		esi, offset currentGroupSongs

PRINT_LIST:
	.if counter == 0
		jmp END_PRINT
	.endif

	push esi
	invoke SendDlgItemMessage, hWin, IDC_MAIN_GROUP, LB_ADDSTRING, 0, addr (song ptr [esi]).path 
	pop esi
	add	esi, size song
	dec counter
	jmp PRINT_LIST

END_PRINT:
	ret
ShowMainDialogView endp

SelectGroup proc,
	hWin : dword
	local indexToSet : dword
	local BytesRead : dword
	local handler_saved : dword
	local counter : dword

	invoke SendDlgItemMessage, hWin, IDC_GROUPS, CB_GETCURSEL, 0, 0
	mov	indexToSet, eax

	.if eax == CB_ERR
		mov currentPlayGroup, DEFAULT_SONG_GROUP
		invoke SelectSong, hWin
		ret
	.endif

    invoke  CreateFile,offset groupData,GENERIC_READ, 0, 0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	mov		handler, eax

	mov		esi, 0

REPEAT_READ:
	push esi
	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL
	.if BytesRead == 0
		jmp END_READ
	.endif
	invoke ReadFile, handler, addr readGroupDetailStr, MAX_GROUP_DETAIL_LEN , addr BytesRead, NULL

	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL
	invoke ReadFile, handler, addr readGroupNameStr, MAX_GROUP_NAME_LEN, addr BytesRead, NULL
	pop esi

	.if esi == indexToSet
		invoke atol, addr readGroupDetailStr
		mov currentPlayGroup, eax
		jmp END_READ
	.endif
	inc esi
	jmp REPEAT_READ
END_READ:
	invoke CloseHandle, handler
	
	invoke SelectSong, hWin
	xor eax, eax
	ret
SelectGroup endp

AddNewGroup proc,
	hWin : dword

	local handler_saved : dword
	local BytesWritten : dword

    invoke  CreateFile,offset groupData,GENERIC_WRITE, 0, 0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	mov		handler, eax
	mov		handler_saved, eax

	invoke SetFilePointer, handler, 0, 0, FILE_END

	invoke RtlZeroMemory, addr readGroupNameStr, sizeof readGroupNameStr
	mov	readGroupNameStr, MAX_GROUP_NAME_LEN - 1
	invoke SendDlgItemMessage, hWin, IDC_NEW_GROUP_NAME, EM_GETLINE, 0, addr readGroupNameStr

	add		maxGroupId, 1
	invoke GetGroupDetailInStr, maxGroupId

	invoke WriteFile, handler, addr divideLine, length divideLine,  addr BytesWritten, NULL
	invoke WriteFile, handler, addr groupDetailStr, MAX_GROUP_DETAIL_LEN, addr BytesWritten, NULL

	invoke WriteFile, handler, addr divideLine, length divideLine,  addr BytesWritten, NULL
	invoke WriteFile, handler, addr readGroupNameStr, MAX_GROUP_NAME_LEN, addr BytesWritten, NULL

	invoke CloseHandle, handler_saved

	invoke SendDlgItemMessage, hMainDialog, IDC_GROUPS, CB_ADDSTRING, 0, addr readGroupNameStr

	invoke SendDlgItemMessage, hMainDialog, IDC_GROUPS, CB_GETCOUNT, 0, 0
	dec eax
	invoke SendDlgItemMessage, hMainDialog, IDC_GROUPS, CB_SETCURSEL, eax, 0

	invoke SelectGroup, hMainDialog
	ret
AddNewGroup endp

GetAllGroups proc,
	hWin : dword

	local BytesRead : dword

    invoke  CreateFile,offset groupData,GENERIC_READ, 0, 0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	mov		handler, eax

	invoke SendDlgItemMessage, hWin, IDC_GROUPS, CB_RESETCONTENT, 0, 0
REPEAT_READ:
	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL
	.if BytesRead == 0
		jmp END_READ
	.endif
	invoke ReadFile, handler, addr readGroupDetailStr, MAX_GROUP_DETAIL_LEN , addr BytesRead, NULL

	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL
	invoke ReadFile, handler, addr readGroupNameStr, MAX_GROUP_NAME_LEN, addr BytesRead, NULL

	invoke SendDlgItemMessage, hWin, IDC_GROUPS, CB_ADDSTRING, 0, addr readGroupNameStr

	jmp REPEAT_READ
END_READ:
	invoke CloseHandle, handler

	invoke SendDlgItemMessage, hWin, IDC_GROUPS, CB_SETCURSEL, 0, 0
	invoke SelectGroup, hWin

	ret
GetAllGroups endp

StartAddNewGroup proc
	invoke DialogBoxParam, hInstance, IDD_DIALOG_ADD_NEW_GROUP, 0, addr NewGroupMain, 0
	ret
StartAddNewGroup endp

NewGroupMain proc,
	hWin : dword,
	uMsg : dword,
	wParam : dword,
	lParam : dword

	.if	uMsg == WM_INITDIALOG
		push hWin
		pop hNewGroup
		invoke SendDlgItemMessage, hWin, IDC_NEW_GROUP_NAME, EM_LIMITTEXT, MAX_GROUP_NAME_LEN - 1, 0
	.elseif	uMsg == WM_COMMAND
		.if wParam == IDC_BUTTON_ADD_NEW_GROUP
			invoke AddNewGroup, hWin
			invoke EndDialog, hWin, 0
		.endif
	.elseif	uMsg == WM_CLOSE
		mov hNewGroup, 0
		invoke EndDialog,hWin,0
	.else
	.endif

	xor eax, eax ; eax = 0
	ret
NewGroupMain endp

DeleteCurrentGroup proc,
	hWin : dword

	local BytesRead : dword
	local BytesWritten : dword
	local currentSelect : dword
	local counter : dword

	invoke SelectGroup, hWin ; get current select group
	.if currentPlayGroup == DEFAULT_SONG_GROUP
		invoke MessageBox, hWin, addr deleteNone, 0, MB_OK
		ret
	.endif

	invoke DeleteTargetSong, hWin, DELETE_ALL_SONGS_IN_GROUP, currentPlayGroup

    invoke  CreateFile,offset groupData,GENERIC_READ, 0, 0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	mov		handler, eax
	mov		esi, offset delAllGroups
	mov		counter, 0
REPEAT_READ:
	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL
	.if BytesRead == 0
		jmp END_READ
	.endif
	invoke ReadFile, handler, addr readGroupDetailStr, MAX_GROUP_DETAIL_LEN , addr BytesRead, NULL

	invoke atol, addr readGroupDetailStr
	mov (songgroup ptr [esi]).groupid, eax

	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL
	invoke ReadFile, handler, addr (songgroup ptr [esi]).groupname, MAX_GROUP_NAME_LEN, addr BytesRead, NULL

	add esi, size songgroup
	add counter, 1
	jmp REPEAT_READ
END_READ:
	invoke CloseHandle, handler

	mov		esi, offset delAllGroups

	invoke SendDlgItemMessage, hWin, IDC_GROUPS, CB_RESETCONTENT, 0, 0
    invoke  CreateFile,offset groupData,GENERIC_WRITE, 0, 0,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	mov		handler, eax
	invoke SetFilePointer, handler, 0, 0, FILE_BEGIN

REPEAT_WRITE:
	mov	ebx, (songgroup ptr [esi]).groupid
	.if ebx != currentPlayGroup
		invoke WriteFile, handler, addr divideLine, length divideLine,  addr BytesWritten, NULL

		invoke GetGroupDetailInStr, (songgroup ptr [esi]).groupid
		invoke WriteFile, handler, addr groupDetailStr, MAX_GROUP_DETAIL_LEN, addr BytesWritten, NULL

		invoke WriteFile, handler, addr divideLine, length divideLine,  addr BytesWritten, NULL
		invoke WriteFile, handler, addr (songgroup ptr [esi]).groupname, MAX_GROUP_NAME_LEN, addr BytesWritten, NULL

		invoke SendDlgItemMessage, hWin, IDC_GROUPS, CB_ADDSTRING, 0, addr (songgroup ptr [esi]).groupname
	.endif

	sub counter, 1
	add	esi, size songgroup
	.if counter ==  0
		jmp END_WRITE
	.endif
	jmp REPEAT_WRITE
END_WRITE:
	invoke CloseHandle, handler

	invoke SendDlgItemMessage, hWin, IDC_GROUPS, CB_SETCURSEL, 0, 0
	invoke SelectGroup, hWin


	ret
DeleteCurrentGroup endp

SelectSong proc,
	hWin : dword

	local indexToPlay : dword

	invoke SendDlgItemMessage, hWin, IDC_MAIN_GROUP, LB_GETCURSEL, 0, 0
	.if eax == LB_ERR
		mov currentPlaySingleSongIndex, DEFAULT_PLAY_SONG
		ret
	.endif

	mov	currentPlaySingleSongIndex, eax

	mov	ebx, size song
	mul	ebx

	mov	esi, offset currentGroupSongs
	add	esi, eax

	invoke CollectSongPath, addr (song ptr [esi]).path, addr currentPlaySingleSongPath
	ret
SelectSong endp

DeleteTargetSong proc,
	hWin : dword,
	method : dword,
	songGroup : dword

	local counter : dword
	local BytesWrite : dword
;	index : dword

	.if method == DELETE_CURRENT_PLAY_SONG 
		.if currentPlaySingleSongIndex == DEFAULT_PLAY_SONG
			invoke MessageBox, hWin, addr deleteSongNone, 0, MB_OK
			ret
		.endif
	.endif

	.if method == DELETE_ALL_SONGS_IN_GROUP
		.if songGroup == DEFAULT_SONG_GROUP
			ret
		.endif
	.endif

	invoke GetAllSongInData
	mov		counter, eax

    invoke  CreateFile,offset songData,GENERIC_WRITE, 0, 0,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	mov		handler, eax
	mov		esi, offset delAllSongs

	invoke SetFilePointer, handler, 0, 0, FILE_BEGIN
	mov		ecx, 0 ; ecx = indexcounter

REPEAT_WRITE:
	.if counter == 0
		jmp END_WRITE
	.endif
	dec counter

	mov edx, (song ptr [esi]).groupid
	
	.if edx == currentPlayGroup 
		.if method == DELETE_CURRENT_PLAY_SONG 
			.if ecx == currentPlaySingleSongIndex
				add	esi, size song
				inc ecx
				jmp REPEAT_WRITE
			.endif
			inc ecx
		.endif
	.endif

	.if edx == songGroup 
		.if method == DELETE_ALL_SONGS_IN_GROUP
			add esi, size song
			jmp REPEAT_WRITE
		.endif
	.endif

	push ecx
	.if method == DELETE_INVALID
		push eax
		invoke CheckFileExist, addr (song ptr [esi]).path
		.if eax == FILE_NOT_EXIST
			pop eax
			add esi, size song
			jmp REPEAT_WRITE
		.endif
		pop eax
	.endif

	invoke WriteFile, handler, addr buffer, length divideLine,  addr BytesWrite, NULL
	invoke GetGroupDetailInStr, (song ptr [esi]).groupid
	invoke WriteFile, handler, addr groupDetailStr, MAX_GROUP_DETAIL_LEN , addr BytesWrite, NULL

	invoke WriteFile, handler, addr buffer, length divideLine,  addr BytesWrite, NULL
	invoke WriteFile, handler, addr (song ptr [esi]).path, MAX_FILE_LEN, addr BytesWrite, NULL
	pop ecx

	add	esi, size song
	jmp REPEAT_WRITE
END_WRITE:
	invoke CloseHandle, handler
	ret
DeleteTargetSong endp

GetAllSongInData proc

	local BytesRead : dword
	local counter : dword

    invoke  CreateFile,offset songData,GENERIC_READ, 0, 0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	mov		handler, eax
	mov		esi, offset delAllSongs

	mov	counter, 0
REPEAT_READ:
	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL
	.if BytesRead == 0
		jmp END_READ
	.endif
	invoke ReadFile, handler, addr readGroupDetailStr, MAX_GROUP_DETAIL_LEN , addr BytesRead, NULL
	invoke atol, addr readGroupDetailStr
	mov	(song ptr [esi]).groupid, eax

	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL
	invoke ReadFile, handler, addr readFilePathStr, MAX_FILE_LEN, addr BytesRead, NULL

	push esi
	invoke CollectSongPath, addr readFilePathStr, addr (song ptr [esi]).path
	pop esi

	add	esi, size song
	inc counter
	jmp REPEAT_READ
END_READ:
	invoke CloseHandle, handler

	mov	eax, counter
	ret
GetAllSongInData endp

DeleteCurrentPlaySong proc,
	hWin : dword
	invoke DeleteTargetSong, hWin, DELETE_CURRENT_PLAY_SONG, 0
	ret
DeleteCurrentPlaySong endp

CheckFileExist proc,
	targetPath : dword

	invoke GetFileAttributes, targetPath
	.if eax == INVALID_FILE_ATTRIBUTES
		mov eax, FILE_NOT_EXIST
	.else
		mov eax, FILE_DO_EXIST
	.endif

	ret
CheckFileExist endp

DeleteInvalidSongs proc,
	hWin : dword
	invoke DeleteTargetSong, hWin, DELETE_INVALID, 0
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

END WinMain