# CIS 566 Homework 1: Noisy Terrain

## Varun Jain (javarun)

## Sources

The source that I found the most helpful is using [Making Maps with noise functions by Red Blob Games](https://www.redblobgames.com/maps/terrain-from-noise/). I referred to the source to create a dual elevation and moisture noise map, as well as making the mountains elevation more prominent with other distributions such as exponential and smoothstep. I also divided my input to my FBM by a large number to get farther apart mountains with help from Adam Mally.  

## Demo

https://ivarun987.github.io/hw01-noisy-terrain/

![Screenshot](screenshot.png)

## Techniques

I used two FBM functions with different seeds to generate elevation and moisture that are later changed by different exponential functions. The elevation FBM weights the earlier large shapes more than the detailed noise. I also used another FBM noise function, which is then used as an input for an FBM function to generate the noise on the mountain texture. Otherwise, the colors are generated using FBM and the mix() function to create a gradient based on its height or moisture.

I have two sliders for the density of the map, which is changed by dividing the position with inversely decreasing value while the density increases. I have another slider for the exponential distribution which is used in the mountain making. I have one more slider for the color of the texture and how much it should mix with a random color.
