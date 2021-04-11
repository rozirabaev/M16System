# multi-drones-game
A multi-threading assignment in assembly.
Suppose a 100x100 game board. 
Suppose group of N drones which see the same target from different points of view and from different distance. Each drone tries to detect where is the target on the game board, in order to destroy it. Drones may destroy the target only if the target is in drone’s field-of-view, and if the target is no more than some maximal distance from the drone. When the current target is destroyed, some new target appears on the game board in some randomly chosen place. The first drone that destroys T targets is the winner of the game. Each drone has three-dimensional position on the game board: coordinate x, coordinate y, and direction (angle from x-axis). Drones move randomly chosen distance in randomly chosen angle from their current place.
After each movement, a drone calls mayDestroy(…) function with its new position on the board. mayDestroy(…) function returns TRUE if the caller drone may destroy the target, otherwise returns FALSE. If the current target is destroyed, new target is created at random position on the game board.
When a drone moves from its current position to a new position, it may happen that the distance move makes the drone cross the game field border. We treat drone motion as if on a torus. That is, when the next location is greater than the board width or height, or is negative in either axis (this requires checking 4 conditions), subtract or add the torus cycle (100 in this example) if needed. On the first figure below, we see a simple movement of the drone, and on the second figure we may see the movement that would move the drone out of the right border, and instead it is "wrapped around" to the left border of the game board.



----------------------------------------
Command line arguments
Note that the game border size is pre-defined to be 100 x 100.
Your program should get the following command-line arguments (written in ASCII as usual):

N – number of drones
T - number of targest needed to destroy in order to win the game
K – how many drone steps between game board printings
β – angle of drone field-of-view
d – maximum distance that allows to destroy a target
seed - seed for initialization of LFSR shift register

> ass3 <N> <T> <K> <β> <d> <seed>
For example: > ass3 5 3 10 15 30 15019
