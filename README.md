# Dust
Dust is a GPU-based particle simulation and rendering system for Unity.   

[Here's a video](https://youtu.be/h9JKPuK_LAo) of it in action.

### Usage
Add `DustParticleSystem` and a DustRenderer, either `DustPointRenderer` or `DustInstanceRenderer` to a game object.    

All simulation is done in world space.   

### Requirements
* \>=Unity 2018.3
* GPU with compute shader support

### Features
* Rendering modes:
    * Point cloud
    * Mesh instancing
* Emission shapes:
    - Sphere
    - Mesh renderer
* 2D, 3D, 4D animated noise
* Color by life and by velocity gradients
* Mass, momentum, and lifespan random value range
* Size and rotation over lifetime
* Cast- and self-shadowing
* Inherit velocity Rigidboy or Transform component
* Align to direction

### Description

The particle system kernel handles simulation state via a structured buffer containing several attributes. Structures can be found in `DustParticleSystemCommon.cginc`. Rendering components send the particle system buffer to shaders for rendering. Rendering components can be stacked on the same game object for layering effects.

### To Do
* Depth buffer collision
* Emission shapes:
    - Cone
    - Skinned mesh renderer
* Rendering modes:
    - Sprite
    - Trails
* Optimization:
    - Precompute static random fields
    - Make noise a separate kernel, static whenever possble
* Reload compute shader at runtime/live coding
