VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "GameManager"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit
Implements IGameManager

''
' Types
'
'
Private Type tVector
    Top As Integer
    Left As Integer
End Type

Private Type tIterator
    Vector As tVector
    Start As Integer
    Cell As tCoordinates
End Type

Private Type tScout
    Next As Tile
    Farthest As tCoordinates
End Type

''
' Members
'
'
Private Grid As Grid
Private Score As Long
Private BestScore As Long
Private GameWon As Boolean
Private GameOver As Boolean
Dim mContinue As Boolean

''
' Interface
'
'
Private Sub IGameManager_newGame()
Application.ScreenUpdating = False

Clear

PopNew
PopNew
ThisWorkbook.Controls = True
End Sub

Private Sub IGameManager_Continue()
GameWon = False
mContinue = True
Board.updateBoard GameState
PopNew
ThisWorkbook.Controls = True
End Sub

Private Sub IGameManager_doMove(Direction As tDirection)
Dim hasMoved As Boolean

If GameOver Then Exit Sub
If GameWon Then Exit Sub

Dim Vector As tVector, Iterator As tIterator, Scout As tScout
Dim Cell As tCoordinates, Tile As Tile

Vector = getVector(Direction)
Iterator = buildIterator(Vector)

Do While nextCell(Iterator, Cell)
    If Grid.hasTile(Cell) Then
        Set Tile = Grid.getTile(Cell)
        Scout = getScout(Cell, Vector)
        If Not Scout.Next Is Nothing Then
            If Tile.Value = Scout.Next.Value Then
                Tile.Value = Tile.Value + Scout.Next.Value
                addScore Tile.Value
                Grid.delTile Scout.Next
                hasMoved = True
            End If
        End If
        If Not positionsEqual(Tile.Cell, Scout.Farthest) Then
            Grid.moveTile Tile, Scout.Farthest
            hasMoved = True
        End If
    End If
Loop

If GameWon Then
    Board.updateBoard GameState
ElseIf hasMoved Then
    Board.updateBoard GameState
    PopNew
Else
    GameOver = checkGameOver()
    Board.updateBoard GameState
End If
End Sub

Private Sub IGameManager_Clear()
Set Grid = Nothing
Set Grid = New Grid
mContinue = False
GameOver = False
GameWon = False
Score = 0
Board.updateBoard GameState
End Sub

Private Sub IGameManager_Load(GameState As tGameState)
' TODO
End Sub

Private Function IGameManager_Save() As tGameState
' TODO
End Function

''
' Private methods
'
'
Private Property Get GameState() As tGameState
Set GameState.Grid = Grid
GameState.Score = Score
GameState.BestScore = BestScore
GameState.GameOver = GameOver
GameState.GameWon = GameWon
End Property

Private Sub PopNew()
Dim popCell As tCoordinates, Value As Long

popCell = Grid.getRandomEmptyCell()

If Rnd > 0.9 Then
    Value = 4
Else
    Value = 2
End If

Grid.addTile popCell, Value
Board.updateScreen 15
Board.updateBoard GameState
End Sub

Private Function checkGameOver() As Boolean
' TODO
End Function

Private Function getVector(Direction As tDirection) As tVector
Dim Val As Integer
If Direction = toUp Or Direction = toleft Then
    Val = -1
Else
    Val = 1
End If
If Direction = toDown Or Direction = toUp Then
    getVector.Top = Val
Else
    getVector.Left = Val
End If
End Function

Private Function buildIterator(Vector As tVector) As tIterator
With buildIterator
    .Vector = Vector
    If Vector.Top + Vector.Left > 0 Then
        .Start = GRID_SIZE
    Else
        .Start = 1
    End If
End With
End Function

Private Function nextCell(Iterator As tIterator, ByRef Cell As tCoordinates) As Boolean
nextCell = True
With Iterator.Cell
    If Not inGridBoundaries(Iterator.Cell) Then
        .Top = Iterator.Start
        .Left = Iterator.Start
    Else
        .Top = .Top - Iterator.Vector.Left
        .Left = .Left - Iterator.Vector.Top
        If .Top < 1 Or .Top > GRID_SIZE Then
            .Top = Iterator.Start
            .Left = .Left - Iterator.Vector.Left
        ElseIf .Left < 1 Or .Left > GRID_SIZE Then
            .Left = Iterator.Start
            .Top = .Top - Iterator.Vector.Top
        End If
        
        If Not inGridBoundaries(Iterator.Cell) Then
            nextCell = False
        End If
    End If
    Cell.Top = .Top
    Cell.Left = .Left
End With
End Function

Private Function getScout(Cell As tCoordinates, Vector As tVector) As tScout
Dim testCell As tCoordinates
testCell = Cell
With testCell
Do
    .Top = .Top - Vector.Top
    .Left = .Left - Vector.Left
    If Not inGridBoundaries(testCell) Then Exit Do
    If Grid.hasTile(testCell) Then
        Set getScout.Next = Grid.getTile(testCell)
        Exit Do
    End If
Loop
End With

testCell = Cell
With testCell
    getScout.Farthest = Cell
    Do
        .Top = .Top + Vector.Top
        .Left = .Left + Vector.Left
        If Not inGridBoundaries(testCell) Then Exit Do
        If Grid.hasTile(testCell) Then Exit Do
        getScout.Farthest = testCell
    Loop
End With
End Function

Private Function inGridBoundaries(Cell As tCoordinates) As Boolean
With Cell
    inGridBoundaries = .Top >= 1 And .Top <= GRID_SIZE And .Left >= 1 And .Left <= GRID_SIZE
End With
End Function

Private Function positionsEqual(Cell1 As tCoordinates, Cell2 As tCoordinates) As Boolean
positionsEqual = Cell1.Top = Cell2.Top And Cell1.Left = Cell2.Left
End Function

Private Sub addScore(ByVal Points As Long)
Score = Score + Points
BestScore = WorksheetFunction.Max(Score, BestScore)
If Points = 2048 Then GameWon = True
End Sub