---
name: TogetherRide
colors:
  surface: '#f8fafa'
  surface-dim: '#d8dada'
  surface-bright: '#f8fafa'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f4'
  surface-container: '#eceeee'
  surface-container-high: '#e6e8e9'
  surface-container-highest: '#e1e3e3'
  on-surface: '#191c1d'
  on-surface-variant: '#414849'
  inverse-surface: '#2e3131'
  inverse-on-surface: '#eff1f1'
  outline: '#71787a'
  outline-variant: '#c0c8c9'
  surface-tint: '#3c656b'
  primary: '#002429'
  on-primary: '#ffffff'
  primary-container: '#0d3b41'
  on-primary-container: '#7ca5ac'
  inverse-primary: '#a3ced5'
  secondary: '#a53b22'
  on-secondary: '#ffffff'
  secondary-container: '#fe7d5e'
  on-secondary-container: '#711601'
  tertiary: '#2d1d00'
  on-tertiary: '#ffffff'
  tertiary-container: '#483100'
  on-tertiary-container: '#cd9400'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#bfeaf1'
  primary-fixed-dim: '#a3ced5'
  on-primary-fixed: '#001f24'
  on-primary-fixed-variant: '#234d53'
  secondary-fixed: '#ffdad2'
  secondary-fixed-dim: '#ffb4a3'
  on-secondary-fixed: '#3d0700'
  on-secondary-fixed-variant: '#84240d'
  tertiary-fixed: '#ffdea8'
  tertiary-fixed-dim: '#ffba20'
  on-tertiary-fixed: '#271900'
  on-tertiary-fixed-variant: '#5e4200'
  background: '#f8fafa'
  on-background: '#191c1d'
  surface-variant: '#e1e3e3'
typography:
  headline-lg:
    fontFamily: Hanken Grotesk
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Hanken Grotesk
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Hanken Grotesk
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-sm:
    fontFamily: Hanken Grotesk
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Hanken Grotesk
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Hanken Grotesk
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Hanken Grotesk
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: JetBrains Mono
    fontSize: 10px
    fontWeight: '500'
    lineHeight: 14px
    letterSpacing: 0.03em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  margin-mobile: 1.25rem
  margin-desktop: 2.5rem
  gutter: 1rem
  stack-sm: 0.5rem
  stack-md: 1rem
  stack-lg: 1.5rem
---

## Brand & Style
The design system is built on the principles of mutual support, reliability, and urban efficiency. It targets daily commuters in Mumbai who prioritize safety and community over the chaos of solo travel. 

The visual style is **Minimalist-Modern** with a focus on high-legibility and spatial clarity. By utilizing expansive whitespace and a restrained color palette, the UI reduces cognitive load in high-stress transit environments. The emotional response should be one of "calm amidst the rush"—a professional, structured environment that feels inherently safe and verified.

## Colors
The palette is anchored by **Deep Teal** (#0D3B41), chosen to evoke institutional trust, authority, and depth—essential for a safety-first ride-sharing service.

**Coral** (#FF7E5F) serves as the primary action color, providing a warm, high-visibility contrast for CTAs and critical navigation points. **Warm Amber** (#FFB800) is reserved specifically for safety-related statuses, verified badges, and live-tracking indicators. The background uses a soft, cool-toned neutral to keep the interface feeling airy and hygienic.

## Typography
This design system utilizes **Hanken Grotesk** for all primary communication. Its sharp, contemporary geometry provides a professional and technical feel that mirrors modern urban infrastructure. 

A strong typographic hierarchy is established by using heavy weights for headlines to ground the user. For technical metadata, such as vehicle numbers, ETA timestamps, and "Verified" statuses, **JetBrains Mono** is employed to provide a distinct, utilitarian aesthetic that suggests precision and data-integrity.

## Layout & Spacing
The layout follows a **Fluid Grid** model optimized for one-handed mobile use. 

- **Mobile:** 4-column grid with 20px (1.25rem) side margins. Primary actions (booking, safety tools) are anchored to the bottom "thumb zone."
- **Desktop/Tablet:** 12-column grid centered in a max-width container of 1200px.
- **Rhythm:** An 8px linear scale governs all padding and margins. Vertical stacks prioritize generous breathing room between information cards to prevent the UI from feeling cluttered during the high-stress period of finding a ride.

## Elevation & Depth
Depth is communicated through **Soft Ambient Shadows** rather than lines, creating a sense of physical layering. 

- **Surface Level 0 (Base):** Neutral-50 background.
- **Surface Level 1 (Cards):** White background with a subtle 12% opacity shadow (Y: 4px, Blur: 20px) using the Primary color as a tint.
- **Surface Level 2 (Modals/Overlays):** Elevated with a 15% opacity shadow (Y: 8px, Blur: 32px).

The use of "Ghost Borders" (0.5px stroke at 10% opacity) is preferred for internal card divisions to maintain a minimal, clean appearance.

## Shapes
The shape language is defined by **Large Radii**, conveying a friendly and approachable brand character. 

- **Standard Cards:** 16px (rounded-lg) for secondary info.
- **Primary Containers:** 24px (rounded-xl) for main booking interfaces and map-pinned sheets.
- **Interactive Elements:** Buttons and input fields use an 8px radius to maintain a structural, reliable feel amidst the softer card containers.

## Components

### Buttons
- **Primary:** Coral background, white text. No gradients. High-contrast and bold.
- **Secondary:** Deep Teal outline (1.5px) with Deep Teal text. 
- **Safety CTA:** Floating Action Button (FAB) with a subtle pulse animation for the SOS/Live Track feature, using the Deep Teal color.

### Cards
All cards must use the 16px or 24px corner radius. Group information logically: Driver Profile, Vehicle Details, and Pricing should be separated by whitespace or a 0.5px divider, never heavy borders.

### Input Fields
Soft-gray backgrounds with an 8px radius. On focus, the border transitions to a 2px Deep Teal stroke.

### Safety Indicators (Verified Badges)
Small, circular badges using the Warm Amber color. Icons within badges should be minimal line-art (shield, checkmark, or pulse).

### Map Styling
The map interface must be stripped of commercial "Points of Interest" to reduce clutter. Roads are light gray, parks are muted mint, and the active route is a thick, solid Deep Teal line with a Coral "Current Location" pulse.