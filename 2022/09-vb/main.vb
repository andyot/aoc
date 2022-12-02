Imports System.Linq

Module Aoc
  Function Move(
      ByVal x As Int32,
      ByVal y As Int32,
      ByVal tx As Int32,
      ByVal ty As Int32
    ) As Tuple(Of Int32, Int32)

    If Math.Abs(x - tx) >= 2 Then
      If x > tx Then
        tx += 1
      Else
        tx -= 1
      End If
      If ty <> y Then
        ty += Math.Max(-1, Math.Min(1, y - ty))
      End If
    End If
    If Math.Abs(y - ty) >= 2 Then
      If y > ty Then
        ty += 1
      Else
        ty -= 1
      End If
      If tx <> x Then
        tx += Math.Max(-1, Math.Min(1, x - tx))
      End If
    End If
    Return New Tuple(Of Int32, Int32)(tx, ty)
  End Function

  Function CountTailPositions(
      ByRef lines As List(Of String),
      ByVal knot_count As Int32
    ) As Int32
    
    Dim hx as Int32
    Dim hy as Int32
    Dim tx as Int32
    Dim ty as Int32
    
    Dim new_tail as Tuple(Of Int32, Int32)
    Dim tail_positions As New List(Of Tuple(Of Int32, Int32))
    Dim knots As New List(Of Tuple(Of Int32, Int32))

    For i as Int32 = 1 To knot_count
      knots.Add(New Tuple(Of Int32, Int32)(0, 0))
    Next

    For Each line As String In lines
      Dim components() as String = Split(line, " ")
      Dim direction as String = components(0)
      Dim distance as Int32 = CInt(components(1))
      
      For i As Int32 = 1 To distance
        Select Case direction
        Case "R"
          hx += 1
        Case "U"
          hy -= 1
        Case "D"
          hy += 1
        Case "L"
          hx -= 1
        End Select

        new_tail = Move(hx, hy, tx, ty)
        tx = new_tail.Item1
        ty = new_tail.Item2
        knots(0) = new_tail

        For j As Int32 = 1 to knot_count - 1
          knots(j) = Move(
            knots(j-1).Item1,
            knots(j-1).Item2,
            knots(j).Item1,
            knots(j).Item2
          )
        Next
        
        tail_positions.Add(knots.Last)
      Next
    Next
    
    return tail_positions.Distinct().Count
  End Function

  Sub Main()
    Dim lines As New List(Of String)
    Dim line as String
    Do
      line = Console.ReadLine()
      If line = "" Then
        Exit Do
      End If
      lines.Add(line)
    Loop Until line Is Nothing
    
    Console.WriteLine("A: {0}", CountTailPositions(lines, 1))
    Console.WriteLine("B: {0}", CountTailPositions(lines, 9))
  End Sub
End Module
