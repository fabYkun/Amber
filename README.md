# Amber
 Amber Shader which can also be used a some jelly or "alien-egg" shader.  
 ![amber](https://user-images.githubusercontent.com/2204781/28931565-db66154e-7876-11e7-8502-03295e7ee84f.gif)


#### The shader is located in Assets/Shaders/Amber.shader

	Properties
	{
	_MainTex("Texture", 2D) = "white" {}	        // texture applied to the front-face of the mesh, alpha is its opacity
	_Tint("Tint", Color) = (1,1,1,1)		// tint applied to the texture
	_Color("Color", Color) = (1,1,1,1)		// primary color of the material, heavilly related to the thickness parameter
	_Thickness("Thickness", Range(0,1)) = 0.2		        // thickness of the material, the more thick it is the more the color will be applied on objects inside and backface-specular highlights
	_FaceSmoothness("FaceSmoothness", Range(0.001,1)) = 0.5		// front-face smoothness used for the specular highlights, it's color will be the same as the scene's predominent directionnal light
	_BackSmoothness("BackSmoothness", Range(0.001,1)) = 0.5		// back-face smoothness used for the back face of the material (specular highlights), the color of the highlights is a mix between the color and the color of the scene's predominent directionnal light and it depends on the thickness
	_Blur("Blur", Range(0, 5)) = 1.0		// gaussian blur applied to the extremities of the mesh
	}
 
It is best use with an other object inside of it, some examples :

![egg](https://user-images.githubusercontent.com/2204781/28899689-ed4e1890-77ec-11e7-9140-e79edb5acb80.png)
![egganim2](https://user-images.githubusercontent.com/2204781/28899688-ed4afb42-77ec-11e7-99bb-56b1610dfbd6.gif)
![egganim](https://user-images.githubusercontent.com/2204781/28899690-ed51201c-77ec-11e7-8dea-16d1c8e5a2c3.gif)
