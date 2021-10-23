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
IDC_MAIN_GROUP				   equ  1017 ; 展示当前选择歌单的所有歌曲
IDC_GROUPS						equ 1009 ; 选择当前歌单
IDC_ADD_NEW_GROUP				equ 1023; 加入新的歌单


;---------------- process -------------
DO_NOTHING			equ 0 ; 特定的返回值标识
DEFAULT_SONG_GROUP  equ 99824 ; 默认组别被分配到的编号

MAX_FILE_LEN equ 8000 ; 最长文件长度
MAX_GROUP_DETAIL_LEN equ 64 ; 组别编号的最长长度
MAX_GROUP_NAME_LEN equ 20 ; 歌单名称的最长长度
MAX_GROUP_SONG equ 50 ; 歌单内歌曲的最大数

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

StartGroupManage proto, ; TODO: 管理当前选择的歌单
	hWin : dword

GroupManageMain proto, ; TODO : 管理当前歌单的主逻辑
	hWin : dword,
	uMsg : dword,
	wParam : dword,
	lParam : dword

GetCurrentGroupSong proto ; TODO : 更新currentGroupSongs的歌曲信息

GetTargetGroupSong proto, ; TODO : 获得songGroup的所有歌曲信息
	songGroup : dword,
	saveTo: dword
	; TODO : 制定被保存在哪一个内部结构里

song struct ; 歌曲信息结构体
	path byte MAX_FILE_LEN dup(0)
;	songname byte 10 dup(0) ; TODO: 歌曲名称
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
; TODO

GetAllGroups proto, ; 查询所有的group
	hWin : dword
; TODO

AddNewGroup proto ; 加入一个新的group
; TODO

DeleteOldGroup proto ; 删除一个group， 但不会删除其中的歌曲
; TODO
	
; TODO
; DeleteSongFromCurrentGroup proto, 
;	hWin : dword 

GetInputGroupName proto, ; 从用户的输入获取readGroupName
	readGroupName : dword 
; todo
	

; +++++++++++++++++++ data +++++++++++++++++++++
.data

handler HANDLE ? ; 文件句柄
divideLine byte 0ah ; 换行divideLine

currentPlaySingleSong song <> ; 目前正在播放的歌曲信息

currentPlayGroup dword DEFAULT_SONG_GROUP ; 目前正在播放的歌单编号
groupDetailStr byte MAX_GROUP_DETAIL_LEN dup("a") ; 目前正在播放的歌单编号的str格式。 需要访问GetGroupDetailInStr以更新

; 歌单分为自定义歌单和默认歌单。默认歌单包括全部歌曲。

numCurrentGroupSongs dword 0 ; 当前播放歌单的歌曲数量
currentGroupSongs song MAX_GROUP_SONG dup(<"#">) ; 当前播放歌单的所有歌曲信息

; ++++++++++++++导入文件OPpenFileName结构++++++++++++++
ofn OPENFILENAME <>
ofnTitle BYTE '导入音乐', 0	

; +++++++++++++++程序所需部分窗口变量+++++++++++++++
hInstance dword ?
hGroupManager dword ?

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
ofnInitialDir BYTE "C:\Users\gassq\Desktop", 0 ; default open C only for test
songData BYTE "C:\Users\gassq\Desktop\data.txt", 0 
testint byte "TEST INT: %d", 0ah, 0dh, 0
groupData byte "C:\Users\gassq\Desktop\groupdata.txt", 0

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
		invoke ShowMainDialogView, hWin
		; do something
	.elseif	uMsg == WM_COMMAND
		.if wParam == IDC_FILE_SYSTEM
			invoke ImportSingleFile, hWin
			invoke ShowMainDialogView, hWin
		.elseif wParam == IDC_MANAGE_CURRENT_GROUP
			invoke StartGroupManage, hWin
			invoke ShowMainDialogView, hWin
		.elseif wParam == IDC_GROUPS
			invoke SelectGroup, hWin ; TODO
		.elseif wParam == IDC_ADD_NEW_GROUP
			invoke AddNewGroup
			invoke ShowMainDialogView, hWin
		.endif
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

	invoke GetGroupDetailInStr, songGroup

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
	.if eax == songGroup
		push esi
		invoke CollectSongPath, addr readFilePathStr, addr (song ptr [esi]).path
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

	invoke GetAllGroups, hWin
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
	add		esi, size song
	dec counter
	jmp PRINT_LIST

END_PRINT:
	ret
ShowMainDialogView endp

SelectGroup proc,
	hWin : dword
; TODO
	ret
SelectGroup endp

AddNewGroup proc
	local handler_saved : dword
	local BytesWritten : dword

    invoke  CreateFile,offset groupData,GENERIC_WRITE, 0, 0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	mov		handler, eax
	mov		handler_saved, eax

	invoke SetFilePointer, handler, 0, 0, FILE_END

	invoke RtlZeroMemory, addr readGroupNameStr, sizeof readGroupNameStr
	invoke GetInputGroupName, addr readGroupNameStr

;	users can modify add name
	invoke GetGroupDetailInStr, eax
; todo : add limit to id so that they are not equal

	invoke WriteFile, handler, addr divideLine, length divideLine,  addr BytesWritten, NULL
	invoke WriteFile, handler, addr groupDetailStr, MAX_GROUP_DETAIL_LEN, addr BytesWritten, NULL

	invoke WriteFile, handler, addr divideLine, length divideLine,  addr BytesWritten, NULL
	invoke WriteFile, handler, addr readGroupNameStr, MAX_GROUP_NAME_LEN, addr BytesWritten, NULL

	invoke CloseHandle, handler_saved
	ret
AddNewGroup endp

GetAllGroups proc,
	hWin : dword

	local BytesRead : dword
	local handler_saved : dword
	local lpstrLength : dword

    invoke  CreateFile,offset groupData,GENERIC_READ, 0, 0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	mov		handler, eax

	invoke SendDlgItemMessage, hWin, IDC_GROUPS, CB_RESETCONTENT, 0, 0
REPEAT_READ:
	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL
	.if BytesRead == 0
		jmp END_READ
	.endif
	invoke ReadFile, handler, addr readGroupDetailStr, MAX_GROUP_DETAIL_LEN , addr BytesRead, NULL
	; todo : manage group id in a data structure 

	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL
	invoke ReadFile, handler, addr readGroupNameStr, MAX_GROUP_NAME_LEN, addr BytesRead, NULL

	invoke SendDlgItemMessage, hWin, IDC_GROUPS, CB_ADDSTRING, 0, addr readGroupNameStr

	jmp REPEAT_READ
END_READ:
	invoke CloseHandle, handler
	ret
GetAllGroups endp

GetInputGroupName proc,
	targetStr : dword
; todo
	mov esi, offset inputGroupNameStr
	mov	edi, targetStr
	mov	ecx, MAX_GROUP_NAME_LEN - 1
	cld
	rep	movsb
	ret
GetInputGroupName endp

END WinMain
