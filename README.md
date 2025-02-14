# FNA-Effects
This is a test project I made for seeing how to work with different simple Effects in FNA.
I learned quite a bit from this little "test". And would love to share the code and the effects themselves with people who are trying to do the same!

# Shaders
## Effects.fx
These are just some small effects I made as a start(not even sure if they work 😅). 

**They include:**

	- Bevel
 	- Sin Inverted function???
	- Heat Distortion
 	- Water Distortion
	- Vignette

## Crt.fx
This is a CRT effect with multiple different variables to change and to play around with(it has water and heat distortion implemented into it with booleans).

![image](https://github.com/user-attachments/assets/2d4f9b1d-b621-4907-8ce1-7c76f7e285ed)

## Background.fx
This includes 4 different background styles which all move and some rotate.

Them being:

	- Cool clouds(copied from shadertoy) TYPE 1
 	- Cool Squares			     TYPE 2
	- Even Cooler Squares?!?!?           TYPE 3
 	- MORE SQUARES	                     TYPE 4

![image](https://github.com/user-attachments/assets/95190955-ff93-4d9d-b13a-6d3e3d55f063)
![image](https://github.com/user-attachments/assets/191e6806-3b48-46d9-a853-3076c6ce9854)
![image](https://github.com/user-attachments/assets/8500e6f2-e81e-466d-8746-0cc27b1debef)
![image](https://github.com/user-attachments/assets/b9f6bacf-962b-4ba8-971d-72a84b5b3954)

## Light.fx
A very simple implementation of lights, nothing more to say.

![image](https://github.com/user-attachments/assets/9f537936-cb87-47e7-bddc-f3e0ad8dd9b0)

# Other stuff
Other than the **AMAZING** effects, there are also some small additions:

	- CompileShaders() // Compiles shaders :0
 	- CreateTexture() // Creates a blank 1 color Texture
	- Dynamic resizing of the area the render target is being drawn on to, you can find it in the Draw() function

That is about it, if you found at least something useful I will be very happy, **otherwise have a great day my friend!**

*a lot of the code does suck, but it was made for testing purposes so don't judge :)*
