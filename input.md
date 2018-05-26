# About input and output

## Input: 

To set user input, you have to edit the `source .hs` file. Don't worry, it is easy and there are expressive examples provided. Basic knowledge of Haskell syntax will ease you the task, but is not necessary.

Edit the section `-- user input:`, on lines 54 and following.

### Lectures:

You have to set the variables `allLectures`, containing the lectures that will be planned. The given example is very expressive.
To add a new teacher, just create him an alias (same as for `pepca` or `jezek`, copy paste some other alias, edit the strings, and add `++ alias` to end of line 56

### Slots:

You have to set the variable `customSlots`, containing the time slots that will be available. Each time slot is a triple, containing (building number, room number, time).
For simplicity, time is just an integer in this program. It can represent different time slots in real time, e.g. times 1 - 7 can mean different days, or times 1 - 5 can mean 
Monday 1 pm, 2 pm, ... 5 pm, where times 6 - 10 would mean Tuesday 1 pm ... 5 pm. This way, you can set as many different time slots as you desire and map them to your real-life needs.

Using the function `[mkSlot i j k  | i <-[1..buildings] , j<-[1..rooms], k<-[1..timeSlots]]` you can make regular grid of timeslots, where all buildings have same number of rooms
and all rooms have the same number of available time slots.


## Output:

To see the result, simply type `main` in ghci or run the program using ghc. The output format is rather expressive.

To see more than first found timetable, simply call `showTimeTable((createTimeTables lectures slots)!!n)` where `n` means that n-th found timetable will be shown.

To check how many timetables there are, use `length (createTimeTables lectures slots)`. Beware, this can take very long (up to hours) with bigger inputs (e.g. when number of all slots is bigger than 50) - because not just one, but all possibilities will be searched.

