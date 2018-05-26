# Example inputs

1) two lectures at the same time
```Haskell
allLectures = [mkLecture teacher subject | teacher<-[1..1], subject<-[1..2]]
customSlots = [mkSlot building room time  | building <-[1..1], room<-[1..2], time<-[1..1]]
```
expected: no solution, because one teacher cannot have two lectures in different rooms at the same time


1) b) same as 1, with more teachers and slots
```Haskell
allLectures = [mkLecture teacher subject | teacher<-[1..3], subject<-[1..2]]
customSlots = [mkSlot building room time  | building <-[1..2], room<-[1..3], time<-[1..1]]
```
expected: same as 1)


2) same lecture and slot count, enough time
```Haskell
allLectures = [mkLecture teacher subject | teacher<-[1..3], subject<-[1..2]]
customSlots = [mkSlot building room time  | building <-[1..1], room<-[1..3], time<-[1..2]]
```
expected: soloution exists, e.g. put each teacher in a romm and let them have two consecutive lectures    


3) more lectures that slots
```Haskell
allLectures = [mkLecture teacher subject | teacher<-[1..3], subject<-[1..2]]
customSlots = [mkSlot building room time  | building <-[1..1], room<-[1..2], time<-[1..2]]
```
expected: no solution, because cannot put 6 lectures in 4 slots


4) many available slots, just few lectures
```Haskell
allLectures = [mkLecture teacher subject | teacher<-[1..4], subject<-[1..4]]
customSlots = [mkSlot building room time  | building <-[1..10], room<-[1..20], time<-[1..20]]
```
expected: there are many solutions, find some


5) two slots at different times, but different at building
```Haskell
allLectures = [mkLecture teacher subject | teacher<-[1..1], subject<-[1..2]]
customSlots = [ mkSlot 1 1 1, mkSlot 2 1 2]
```
expected: no solution, because a teacher cannot have two consecutive lectures in different buildings

5) b) same as 5, but times not consecutive
```Haskell
allLectures = [mkLecture teacher subject | teacher<-[1..1], subject<-[1..2]]
customSlots = [ mkSlot 1 1 1, mkSlot 2 1 3]
```
expected: solution found

5) c) same as 5, but different teachers
```Haskell
allLectures = [mkLecture teacher subject | teacher<-[1..2], subject<-[1..1]]
customSlots = [ mkSlot 1 1 1, mkSlot 2 1 2]
```
expected: solution found


6) bigger input, with existing solution
```Haskell
allLectures = [mkLecture teacher subject | teacher<-[1..10], subject<-[1..10]]
customSlots = [mkSlot building room time  | building <-[1..1], room<-[1..10], time<-[1..10]]
```
expected: find solution, each teacher in its room (other solutions also possible)

6) b) same as 6, but different buildings 
```Haskell
allLectures = [mkLecture teacher subject | teacher<-[1..10], subject<-[1..10]]
customSlots = [mkSlot building room time  | building <-[1..10], room<-[1..1], time<-[1..10]]
```
expected: find solution, each teacher in its room (only possible solution)


7) big one
```Haskell
allLectures = [mkLecture teacher subject | teacher<-[1..80], subject<-[1..10]]
customSlots = [mkSlot building room time  | building <-[1..5], room<-[1..10], time<-[1..20]]
```
expected: soloution found (this may take few minutes to compute)
