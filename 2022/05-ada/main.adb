-- Day 5: Ada

with Text_IO;                 use Text_IO;
with Ada.Containers.Indefinite_Vectors;
with Ada.Containers.Vectors;
with Ada.strings.unbounded;   use Ada.strings.unbounded;
with Ada.Strings.Fixed;       use Ada.Strings.Fixed;
with Ada.Characters.Handling; use Ada.Characters.Handling;

procedure Main is
  package Line_Vectors is new Ada.Containers.Indefinite_Vectors
   (Natural, String);

  subtype Crate_Type is Character;

  package Crate_Vectors is new Ada.Containers.Vectors (Positive, Crate_Type);
  use Crate_Vectors;

  package Stack_Vectors is new Ada.Containers.Indefinite_Vectors
   (Positive, Crate_Vectors.Vector);

  type Instruction_Type is array (1 .. 3) of Natural;
  package Instruction_Vectors is new Ada.Containers.Vectors
   (Positive, Instruction_Type);

  procedure Read_Stacks
   (Lines : Line_Vectors.Vector; Stacks : out Stack_Vectors.Vector)
  is
    function Is_Crate (Location : Positive) return Boolean is
    begin
      return (Location - 2) mod 4 = 0;
    end Is_Crate;

    function Stack_Number (Location : Positive) return Positive is
    begin
      return (Location - 2) / 4 + 1;
    end Stack_Number;

    function Stack_Count (Line_Size : Positive) return Positive is
    begin
      return (Line_Size / 4 + 1);
    end Stack_Count;
  begin
    for Line of Lines loop
      if Stack_Vectors.Is_Empty (Stacks) then
        for I in 1 .. Stack_Count (Line'Length) loop
          Stacks.Append (Crate_Vectors.Empty_Vector);
        end loop;
      end if;

      exit when Line = "";

      for I in Line'Range loop
        if Is_Crate (I) and Line (I) /= ' ' and not Is_Digit (Line (I)) then
          Stacks (Stack_Number (I)).Prepend (Line (I));
        end if;
      end loop;
    end loop;
  end Read_Stacks;

  procedure Read_Instructions
   (Lines : Line_Vectors.Vector; Instructions : out Instruction_Vectors.Vector)
  is
    Count, From, To         : Natural := 0;
    Text                    : Unbounded_String;
    After_Count, After_From : Natural;
  begin
    for Line of Lines loop
      if Head (Line, 4) = "move" then
        Text        := To_Unbounded_String (Line);
        After_Count := Index (Line, " from ");
        After_From  := Index (Line, " to ");

        Count := Natural'Value (Slice (Text, 6, After_Count - 1));
        From  := Natural'Value (Slice (Text, After_Count + 6, After_From - 1));
        To    := Natural'Value (Slice (Text, After_From + 4, Line'Length));

        Instructions.Append ((Count, From, To));
      end if;
    end loop;
  end Read_Instructions;

  procedure Move_Crates
   (Stacks       : out Stack_Vectors.Vector;
    Instructions :     Instruction_Vectors.Vector; Upgraded_Crane : Boolean)
  is
  begin
    for Instruction of Instructions loop
      declare
        Count     : Natural := Instruction (1);
        From      : Natural := Instruction (2);
        To        : Natural := Instruction (3);
        From_Size : Integer;
      begin
        for I in 1 .. Count loop
          if Upgraded_Crane then
            From_Size := Integer'Value (Stacks (From).Length'Image);
            Stacks (To).Append (Stacks (From) (From_Size - Count + I));
            Stacks (From).Delete (From_Size - Count + I);
          else
            Stacks (To).Append (Stacks (From).Last_Element);
            Stacks (From).Delete_Last;
          end if;
        end loop;
      end;
    end loop;
  end Move_Crates;

  procedure Print_Top_Crates (Stacks : Stack_Vectors.Vector) is
  begin
    for Stack of Stacks loop
      Put ("" & Stack.Last_Element);
    end loop;
    New_Line;
  end Print_Top_Crates;

  procedure Solve (Lines : Line_Vectors.Vector; Upgraded_Crane : Boolean) is
    Stacks       : Stack_Vectors.Vector;
    Instructions : Instruction_Vectors.Vector;
  begin
    Read_Stacks (Lines, Stacks);
    Read_Instructions (Lines, Instructions);
    Move_Crates (Stacks, Instructions, Upgraded_Crane);
    Print_Top_Crates (Stacks);
  end Solve;

  Lines : Line_Vectors.Vector := Line_Vectors.Empty_Vector;
begin
  while not End_Of_File loop
    Lines.Append (Text_IO.Get_Line);
  end loop;

  Put ("A: ");
  Solve (Lines, Upgraded_Crane => False);

  Put ("B: ");
  Solve (Lines, Upgraded_Crane => True);
end Main;
