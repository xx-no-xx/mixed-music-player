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

includelib masm32.lib
includelib user32.lib
includelib kernel32.lib
includelib comdlg32.lib

;---------------- control -------------
IDD_DIALOG 			equ	101 ; 主播放对话框
IDD_GROUP_MANAGE	equ 103 ; 管理歌单对话框
IDC_FILE_SYSTEM 	equ	1001 ; 导入歌单的按钮
IDC_MANAGE_CURRENT_GROUP       equ  1012 ; 进入管理歌单对话框的按钮
IDC_ALL_GROUP_LIST             equ  1013 ; TODO
IDC_CURRENT_GROUP_LIST         equ  1015 ; TODO


;---------------- process -------------
DO_NOTHING			equ 0 ; 特定的返回值标识
DEFAULT_SONG_GROUP  equ 99824 ; 默认组别被分配到的编号

MAX_FILE_LEN equ 8000 ; 最长文件长度
MAX_GROUP_DETAIL_LEN equ 64 ; 组别编号的最长长度
MAX_GROUP_SONG equ 50 ; 歌单内歌曲的最大数


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

StartGroupManage proto, ; TODO: 管理当前选择的歌单
	hWin : dword

GroupManageMain proto, ; TODO : 管理当前歌单的主逻辑
	hWin : dword,
	uMsg : dword,
	wParam : dword,
	lParam : dword

GetCurrentGroupSong proto ; TODO : 更新currentPlaySong的歌曲信息

GetTargetGroupSong proto, ; TODO : 获得songGroup的所有歌曲信息
	songGroup : dword
	; TODO : 制定被保存在哪一个内部结构里

song struct ; 歌曲信息结构体
	path byte 1000 dup(0)
;	songname byte 10 dup(0) ; TODO: 歌曲名称
; TODO : 其他歌曲信息
song ends

; +++++++++++++++++++ data +++++++++++++++++++++
.data

handler HANDLE ? ; 文件句柄
divideLine byte 0ah ; 换行divideLine

currentPlaySong song <> ; 目前正在播放的歌曲信息
currentPlayGroup dword DEFAULT_SONG_GROUP ; 目前正在播放的歌单编号
groupDetailStr byte MAX_GROUP_DETAIL_LEN dup("a") ; 目前正在播放的歌单编号的str格式。 需要访问GetGroupDetailInStr以更新

; 歌单分为自定义歌单和默认歌单。默认歌单包括全部歌曲。

numCurrentGroupSongs dword 0 ; 目前拥有的自定义歌单数
currentGroupSongs song MAX_GROUP_SONG dup(<>) ; 当前播放歌单的所有歌曲信息

; ++++++++++++++导入文件OPpenFileName结构++++++++++++++
ofn OPENFILENAME <>
ofnTitle BYTE '导入音乐', 0	

; +++++++++++++++程序所需部分窗口变量+++++++++++++++
hInstance dword ?
hGroupManager dword ?

; +++++++++++++++配置信息+++++++++++(因为测试而注释)
;songData BYTE ".\data.txt", 0
;	ofnInitialDir BYTE "C:", 0 ; default open C

; +++++++++++++函数辅助变量++++++++++++（可能可以被local替代）

readGroupDetailStr byte MAX_GROUP_DETAIL_LEN   dup(0)
currentSongNameOFN byte MAX_FILE_LEN dup(0)
readFilePathStr byte MAX_FILE_LEN  dup(0)
buffer byte 0

; ++++++++++++++测试专用+++++++++++++ 
; ++++++++请根据自己的机器路径修改+++++++++
; TODO-TODO-TODO-TODO-TODO-TODO-TODO
simpleText byte "somethingrighthere", 0ah
ofnInitialDir BYTE "C:\Users\gassq\Desktop", 0 ; default open C only for test
songData BYTE "C:\Users\gassq\Desktop\data.txt", 0 
testint byte "TEST INT: %d", 0ah, 0dh, 0

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

	.if	uMsg == WM_INITDIALOG
		; do something
	.elseif	uMsg == WM_COMMAND
		.if wParam == IDC_FILE_SYSTEM
			invoke ImportSingleFile, hWin
		.elseif wParam == IDC_MANAGE_CURRENT_GROUP
			invoke StartGroupManage, hWin
		.endif
		invoke GetCurrentGroupSong
	.elseif	uMsg == WM_CLOSE
		invoke EndDialog,hWin,0
		.if hGroupManager != 0
			invoke EndDialog, hGroupManager, 0
		.endif
	.else
	.endif

	xor eax, eax ; eax = 0
	ret
DialogMain endp

ImportSingleFile proc,
	hWin : dword

	invoke  RtlZeroMemory, addr ofn, sizeof ofn ; fill with 0

	mov ofn.lStructSize, sizeof OPENFILENAME

	push hWin
	pop ofn.hwndOwner ; hwndOwner = hWin

	mov ofn.lpstrTitle, OFFSET ofnTitle
	mov ofn.lpstrInitialDir, OFFSET ofnInitialDir
	mov	ofn.nMaxFile, MAX_FILE_LEN
	mov	ofn.lpstrFile, OFFSET currentSongNameOFN

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

StartGroupManage proc,
	hWin : dword
	invoke DialogBoxParam, hInstance, IDD_GROUP_MANAGE, 0, addr GroupManageMain, 0
	ret
StartGroupManage endp

GroupManageMain proc,
	hWin : dword,
	uMsg : dword,
	wParam : dword,
	lParam : dword

	.if	uMsg == WM_INITDIALOG
		push hWin
		pop hGroupManager
		; do something
	.elseif	uMsg == WM_COMMAND
	.elseif	uMsg == WM_CLOSE
		mov hGroupManager, 0
		invoke EndDialog,hWin,0
	.else
	.endif

	xor eax, eax ; eax = 0
	ret
GroupManageMain endp

GetCurrentGroupSong proc
	invoke GetTargetGroupSong, currentPlayGroup
	ret
GetCurrentGroupSong endp

GetTargetGroupSong proc,
	songGroup : dword

	LOCAL BytesRead : dword
	LOCAL handler_saved : dword
	LOCAL lpstrLength : dword

	invoke GetGroupDetailInStr, songGroup

    INVOKE  CreateFile,offset songData,GENERIC_READ, 0, 0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	mov		handler, eax

	mov	numCurrentGroupSongs, 0
REPEAT_READ:
	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL
	.if BytesRead == 0
		jmp END_READ
	.endif

	invoke ReadFile, handler, addr readGroupDetailStr, MAX_GROUP_DETAIL_LEN , addr BytesRead, NULL
	
	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL
	invoke ReadFile, handler, addr readFilePathStr, MAX_FILE_LEN, addr BytesRead, NULL

	inc numCurrentGroupSongs
	jmp REPEAT_READ
END_READ:
	invoke CloseHandle, handler

	ret
GetTargetGroupSong endp

END WinMain
