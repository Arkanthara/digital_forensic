CC1 on all lectures
 Questions are posted on moodle

- Traces left in image acquisition
- Traces left in image storage
- Traces left in image editing:
  - inconsistency in lighting
  - local filtering Traces
  - detection of copy-move attacks
  - resampling detection
  - blind image-splicing detection

## inconsistency in lighting

inconsistencies in lighting, shadows, perspective etc...

Lighting environment is complex.
multiple light sources...

=>

- Lambertian assumption of the surface of interest
- constant assumption of the objects reflectance
- assumption that light source is located infinitely far away.

## Local filtering

median filtering detection ... Structure uniform is not natural => image filtered...

local filtering traces

smooth filter, then sharpened image filter (lowpass filter then highpass filter) => give overshoot artifact in top and bottom of the line

## Copy-move / Image editing

Scaling / rotating etc... are usually applied before the modification of the image...

## Resampling

traces

## Blind image-splicing detection

ON artificial images are artifacts that are not in real images...


# Inconsistent shadows

## Types of shadows

- cast shadows (appears on other objects)
- attached shadows (attached to the object)

In general, attached shadows are represented by half-plane
Then, normal of line, and then range of possible light positions...

Cast shadows... Difficult case, we give some range of light shadows...Can make it for each points of the shadow....

Attached shadow... half-plane that 


We need to make a model of our plane (for each plane or range...)

if <n, x> - <n, p> >= 0 => on the plane, else not on the plane....

For a range, it's a combination of 2 range planes....

Final: N \times x - P + s >= 0 with s a slack variable added to have a solution...

N \times x  - P >= -s

- If slack variables are 0 => unique position for light source 
- Else, one or more shadows is inconsistent with the single light source.

Due to adopted projective model, there is an inherent sign ambiguity when specifying the shadow constraints
- if the light source in the real 3D world is behind the camera:
  - its position is inversely projected onto the image plane
  - all constraint normals should be negated

Working with colors etc... We don't know where are the shadows.... So try to solve 2 systems with shadows in one side and then in other side...

Difficulties => images with multiple light sources...

Can make this analysis on videos...

In case of negative answer, we must make additive checks...

More smooth shadows are more complex to detect...

No assumption about scene geometry or photometry
lens distortion may be a problem...
Depens on the user (select good details to get good detection !!!)
Counter forensics
  - using this technique to ensure that all shadows are consistent.
  - combine with other techniques for estimating lighting from a single image.
