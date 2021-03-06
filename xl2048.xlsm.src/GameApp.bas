Attribute VB_Name = "GameApp"
Option Explicit

Public Const GRID_SIZE = 4
Public Const GRID_STYLE = "DefaultSkin"

Public Type tGameState
    Grid As Grid
    Score As Long
    BestScore As Long
    Continue As Boolean
    GameOver As Boolean
    GameWon As Boolean
End Type

Public Enum tDirection
    toUp = xlUp
    toDown = xlDown
    toLeft = xlToLeft
    toRight = xlToRight
End Enum

Public Type tCoordinates
    Top As Integer
    Left As Integer
End Type

Dim mManager As IGameManager
Dim mKBController As KeyboardControl
Dim mDefaultStorage As IStorageProvider

Public Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)

Public Property Get Manager() As IGameManager
Dim Control As IControlProvider
If mManager Is Nothing Then
    Set mManager = New GameManager
    Set Control = KBController
    Control.Register mManager
End If
Set Manager = mManager
End Property

Private Property Get KBController() As KeyboardControl
If mKBController Is Nothing Then
    Set mKBController = New KeyboardControl
End If
Set KBController = mKBController
End Property

Private Property Get DefaultStorage() As IStorageProvider
If mDefaultStorage Is Nothing Then
    Set mDefaultStorage = New LocalStorage
End If
Set DefaultStorage = mDefaultStorage
End Property

Public Property Get Style() As Object
Set Style = ThisWorkbook.Sheets(GRID_STYLE)
End Property

Sub newGame()
Manager.newGame
End Sub

Sub Continue()
Manager.Continue
End Sub

Sub Clear()
Manager.Clear
End Sub

Sub Save()
DefaultStorage.Save Manager.Save()
End Sub

Sub Load()
Manager.Load DefaultStorage.Load()
End Sub

Sub KBdoMove(Direction As tDirection)
KBController.Callback_DoMove Direction
End Sub
