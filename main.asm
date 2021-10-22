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
IDD_DIALOG 			equ	101
IDD_GROUP_MANAGE	equ 103
IDC_FILE_SYSTEM 	equ	1001
IDC_MANAGE_CURRENT_GROUP       equ  1012
IDC_ALL_GROUP_LIST             equ  1013
IDC_CURRENT_GROUP_LIST         equ  1015


;---------------- process -------------
DO_NOTHING			equ 0
DEFAULT_SONG_GROUP  equ 99824

;---------------- function -------------
DialogMain proto, ; 对话框主逻辑
	hWin : dword,
	uMsg : dword,
	wParam : dword,
	lParam : dword

ImportSingleFile proto, ; 导入单个文件
	hWin : dword

AddSingleSongOFN proto,  ; add ofn's song into songGroup
	songGroup : dword
	; default songGroup = 0


GetGroupDetailInStr proto,
	songGroup : dword

StartGroupManage proto,
	hWin : dword

GroupManageMain proto,
	hWin : dword,
	uMsg : dword,
	wParam : dword,
	lParam : dword

;==================== DATA =======================
.data

handler HANDLE ?
divideLine byte 0ah

;songData BYTE ".\data.txt", 0
songData BYTE "C:\Users\gassq\Desktop\data.txt", 0 ; only for test
; TODO !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

simpleText byte "somethingrighthere", 0ah

ofn OPENFILENAME <>
ofnTitle BYTE '导入音乐', 0	

ofnInitialDir BYTE "C:\Users\gassq\Desktop", 0 ; default open C only for test
;	ofnInitialDir BYTE "C:", 0 ; default open C

currentSongNameOFN byte 8000 dup(0)
nameMaxLength = SIZEOF currentSongNameOFN

groupDetailStr byte 64 dup("a")

	
;-------------------------------------------------- only for test

testint byte "TEST INT: %d", 0ah, 0dh, 0

;-------------------------------------------------- end for test

hInstance DWORD ?
hGroupManager dword ?

;=================== CODE =========================
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
	mov	ofn.nMaxFile, nameMaxLength
	mov	ofn.lpstrFile, OFFSET currentSongNameOFN

	invoke GetOpenFileName, addr ofn

	.if eax == DO_NOTHING
		jmp EXIT_IMPORT
	.endif

	invoke AddSingleSongOFN, DEFAULT_SONG_GROUP

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

;	invoke WriteFile, handler, addr simpleText, lengthof simpleText, addr BytesWritten, NULL
	invoke lstrlen, ofn.lpstrFile
	mov	 lpstrLength, eax

	invoke WriteFile, handler, ofn.lpstrFile, lpstrLength, addr BytesWritten, NULL
	invoke WriteFile, handler, addr divideLine, length divideLine,  addr BytesWritten, NULL
	invoke WriteFile, handler, addr groupDetailStr, length groupDetailStr, addr BytesWritten, NULL
	invoke WriteFile, handler, addr divideLine, length divideLine,  addr BytesWritten, NULL

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



END WinMain
