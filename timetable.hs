-- Antonín Teichmann
-- Zápočtový program z neprocedurálního programování
-- LS 2018/2019, MFF UK

-- Zadání:
-- Generátor MFF-like rozvrhu, v Haskellu.
-- Vstup: seznam přednášek (přednášející, předmět) a místností (číslo místnosti, budova, dostupné časové sloty) 
-- Výstup: rozvrh splňující všechna omezení.
-- Omezení: Intuitivně, běžný rozvrh. Formálně: Max 1 přednáška v 1 hodinu na 1 místnost, max 1 přednáška v 1 hodinu na 1 přednášejícího, přednášející nemá po sobě jdoucí přednášky v různých budovách.

-- Following code is in English

-- Assignment: time-table generator in Haskell
-- Input: Lecture list (teacher, subject) and rooms list (room number, building, available time slots)
-- Output: a timetable satisfying all constraints.
-- Constraints: intuitive, just a timetable. Formally: max 1 lecture per timeslot per room, max 1 lecture per timeslot per teacher, teacher does NOT have planned two successive  lectures in different buildings.

-- Used algorithm: backtracking
--      Implemented via: the List monad and the StateT monad

import qualified Data.List as List
import GHC.Exts (sortWith)
import Control.Monad
import Control.Monad.Trans.State
import System.Environment (getArgs)

data Lecture = Lecture { getTeacher :: String, getName :: String } deriving (Show, Eq)
emptyLecture = let e = "empty" in Lecture e e

data Slot = Slot { getRoom :: Room, getTime :: TimeSlot } deriving (Show, Eq)
emptySlot = Slot emptyRoom 0

data Room = Room { getNo :: Int, getBuilding :: Int } deriving (Show, Eq)
emptyRoom = Room 0 0

data UsedSlot = UsedSlot { getSlot :: Slot, getLecture :: Lecture } deriving (Show, Eq)
emptyUsedSlot = UsedSlot emptySlot emptyLecture

-- Concise version of Show, for debugging:
--instance Show UsedSlot where
--    show (UsedSlot (Slot (Room roomNo building) time) (Lecture teacher name)) = "US{ r:" ++ (show roomNo) ++ ", b:" ++ (show building) ++ ", t:" ++ (show time) ++ ", " ++ (show teacher) ++ ", " ++ (show name) ++ " }"

type TimeTable = [UsedSlot]

type TimeSlot = Int

mkLecture :: Int -> Int -> Lecture
mkLecture i j = Lecture ("teacher_" ++ show i) ("lectureName_" ++ show j)

mkSlot :: Int -> Int -> Int -> Slot
mkSlot building roomNo time = Slot (Room roomNo building) time


-- user input:

allLectures = pepca ++ jezek ++ mj ++ vituscze
  where
    pepca = let teacher = "Josef Pelikan" in [Lecture teacher name | name <- names ] where
        names = ["PG1","PG2","3D Rendering","2D grafika"]

    jezek = let teacher = "Pavel Jezek" in [Lecture teacher name | name <- names ] where
        names = [".NET I",".NET II",".NET III",".NET IV","Principy pocitacu"]

    mj = let teacher = "Martin Mares" in [Lecture teacher name | name <- names ] where
        names = ["ADS I","ADS II","Programovani v C","IPS","Datove struktury"]

    vituscze = let teacher = "Vit Sefl" in [Lecture teacher name | name <- names ] where
        names = ["Neproceduralni programovani - cviceni"]

-- alternative way of setting lectures:        
--allLectures = [mkLecture i j | i<-[1..4], j<-[1..6]]

customSlots = let timeSlots = 5; in
    [mkSlot 1 j k  | j<-[1..2], k<-[1..timeSlots]] ++   -- building 1 has 2 classrooms
        [mkSlot 2 j k  | j<-[1..4], k<-[1..timeSlots]] ++ -- building 2 has 4 classrooms
        [mkSlot 3 1 1, mkSlot 3 1 2, mkSlot 3 2 1] -- building 3 has some clasrooms available only sometimes

-- code:

-- 1) main:

main = do
    let slots = customSlots
    --  alternative way of input is via arguments:
    -- [buildings, rooms, timeSlots] <- getArgs
    -- let slots = [mkSlot i j k  | i<-[1..(read buildings)], j<-[1..(read rooms)], k<-[1..(read timeSlots)]]
    let lectures = allLectures
    let timeTable = take 1 $ createTimeTables lectures slots
    let output = if (length timeTable == 1) then (showTimeTable (timeTable!!0)) else ("no solution found")
    putStrLn output


-- 2) search functions:

createTimeTables:: [Lecture] -> [Slot] -> [TimeTable]
createTimeTables l s = List.nub $ evalStateT e ([],s) where
    e = evaluatingChain (length s) l

-- create chain of List monads (inside a StateT monad) that will go through available time slots, trying to find slots that satisfy the constraints
evaluatingChain :: Int -> [Lecture] -> StateT ([Slot], [Slot]) [] TimeTable       
evaluatingChain n lectures = init >> foldl1 (>>) (replicate n searchStep) >> finalize where
    init = guard $ (length lectures) <= n
    searchStep = selectSlot >> cutBranch
    selectSlot = (StateT selectAndKeep)
    cutBranch = do 
        slots <- StateT extractKeptState
        guard $ isValid $ buildTimetable slots
    finalize = do
        slots <- StateT extractKeptState
        return $ buildTimetable slots
    buildTimetable slots =
        -- lectures are fixed, time slots are iterated (searched) and then assigned to lectures:
        let count = length slots in zipWith (\l s -> (UsedSlot s l)) lectures $ reverse slots

-- decide whether given (partial) timetable (i.e. slots assigned to lectures) is valid
isValid :: TimeTable -> Bool
isValid timeTable =
    -- condition to have max 1 lecture per 1 slot is satisfied trivially, thanks to the way the slots are assigned to the lectures
    teacherTimeCondition timeTable
    -- && other possible future conditions

teacherTimeCondition :: TimeTable -> Bool
teacherTimeCondition timeTable = allTrue $ do  
    let teachers = List.nub $ map (getTeacher . getLecture) timeTable
    t <- teachers
    let allLectures = filter (\x -> (getTeacher . getLecture) x == t) timeTable
    let lectureTimes = map (getTime . getSlot) allLectures
    let buildingsInTime = map (\x -> let s = getSlot x in (getTime s, (getBuilding . getRoom) s)) allLectures
    return $ isDistinct lectureTimes && isAccessible buildingsInTime

-- decide whether input satisfies the condition "teacher does NOT have planned two sucessive lectures in different buildings"  
--semantics: (Time, Building)
isAccessible :: [(TimeSlot, Int)] -> Bool
isAccessible x = isAccessible' (List.sortBy (\(time1, _) (time2, _) -> compare time1 time2) x) where
    isAccessible' [] = True
    isAccessible' (x:[]) = True
    isAccessible' (x:y:ys) = sameBuilding x y && isAccessible' (y:ys) where
        sameBuilding (t1, b1) (t2, b2) = (t1 + 1) /= t2 || b1 == b2 -- i.e. if the slots follow each other, then the building must be the same


-- 3) helper functions

allTrue :: (Foldable t) => t Bool -> Bool
allTrue = foldl1 (&&)

-- Whether given list contains only distinct elements
isDistinct :: (Ord a, Eq a) => [a] -> Bool
isDistinct list = isDistinct' (List.sort list) where
    isDistinct' [] = True
    isDistinct' (x:[]) = True
    isDistinct' (x:y:ys) = x /= y && isDistinct' (y:ys)

-- Takes two lists and returns all the things in the second list that are not in the first list. O(N^2) implementaion.
remove :: (Eq a) => [a] -> [a] -> [a]
remove rs ls = foldl remove' ls rs
      where remove' ls x = filter (/= x) ls


-- picking dependently from a sample
--      author: Justin Le, Cale, originally from https://github.com/mstksg/inCode/blob/5863554dc6054ffbf2601839b79464d4d37d7a6b/code-samples/misc/send-more-money.hs#L7-L9       
select :: [a] -> [(a, [a])]
select []     = []
select (x:xs) = (x,xs) : [(y,x:ys) | (y,ys) <- select xs]

-- picking dependently from a sample, keeping previously picked values as part of the state
selectAndKeep :: ([a], [a]) -> [(a, ([a], [a]))]     
selectAndKeep (u, x:[]) = [(x,(x:u, []))]
selectAndKeep (u,(x:xs)) = (x,((x:u),xs)) : [(y,((y:u),(x:ys))) | (y,(u',ys)) <- selectAndKeep (u, xs)]   

-- returns a fst of given state as result, while keeping the state the same
extractKeptState :: ([a], [a]) -> [([a], ([a], [a]))]
extractKeptState (x,y) = [(x,(x,y))]


-- 4) output:

-- just a pretty printer
showTimeTable :: TimeTable -> String
showTimeTable tt = "possible timetable:\n" ++ header ++ content ++ "____\n" where
    header = "build.\troom\ttime\tteacher\t\tlecture name\n____\n"
    content = concat $ do
        building <- List.nub $ map (getBuilding . getRoom . getSlot) tt
        let ttInBuilding = filter (\x -> (getBuilding . getRoom . getSlot) x == building) tt
        room <- List.nub $ map (getNo . getRoom . getSlot) ttInBuilding
        let ttInRoom = GHC.Exts.sortWith (getTime . getSlot) $ filter (\x -> (getNo . getRoom . getSlot) x == room) ttInBuilding
        lecture <-  ttInRoom
        return $ let
            b = (show building) ++ "\t"
            r = (show room) ++ "\t"
            t = (show . getTime . getSlot $ lecture) ++ "\t"
            l = show (getTeacher . getLecture $ lecture) ++ "\t"
            n = show (getName . getLecture $ lecture) ++ "\t"
            in
                b ++ r ++ t ++ l ++ n ++ "\n" 

-- 5) tests:

-- commuting test:

-- *Main> s1 = mkSlot 1 1 1
-- *Main> s2 = mkSlot 1 2 2
-- *Main> s3 = mkSlot 1 2 3
-- *Main> l1 = mkLecture 1 1
-- *Main> l2 = mkLecture 1 2
-- *Main> l3 = mkLecture 2 1
-- *Main>
-- *Main> t = [ (UsedSlot s1 l1), UsedSlot s2 l2 ]
-- *Main> isValid t --False expected
-- False
-- *Main> t = [ (UsedSlot s1 l1), UsedSlot s3 l2 ]
-- *Main> isValid t --True expected
-- True
-- *Main> t = [ (UsedSlot s1 l1), UsedSlot s2 l3 ]
-- *Main> isValid t --True expected
-- True
