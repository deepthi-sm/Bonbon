---
name: Bonbon Literacy System
colors:
  surface: '#f8f9ff'
  surface-dim: '#d0dbed'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e6eeff'
  surface-container-high: '#dee9fc'
  surface-container-highest: '#d9e3f6'
  on-surface: '#121c2a'
  on-surface-variant: '#3e4948'
  inverse-surface: '#27313f'
  inverse-on-surface: '#eaf1ff'
  outline: '#6f7979'
  outline-variant: '#bec9c8'
  surface-tint: '#066969'
  primary: '#005151'
  on-primary: '#ffffff'
  primary-container: '#0a6b6b'
  on-primary-container: '#9ae9e8'
  inverse-primary: '#85d4d3'
  secondary: '#b70a45'
  on-secondary: '#ffffff'
  secondary-container: '#da2f5c'
  on-secondary-container: '#fffbff'
  tertiary: '#674000'
  on-tertiary: '#ffffff'
  tertiary-container: '#875500'
  on-tertiary-container: '#ffd4a2'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#a1f0ef'
  primary-fixed-dim: '#85d4d3'
  on-primary-fixed: '#002020'
  on-primary-fixed-variant: '#004f50'
  secondary-fixed: '#ffd9dd'
  secondary-fixed-dim: '#ffb2bb'
  on-secondary-fixed: '#400012'
  on-secondary-fixed-variant: '#910033'
  tertiary-fixed: '#ffddb8'
  tertiary-fixed-dim: '#ffb95f'
  on-tertiary-fixed: '#2a1700'
  on-tertiary-fixed-variant: '#653e00'
  background: '#f8f9ff'
  on-background: '#121c2a'
  surface-variant: '#d9e3f6'
typography:
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '800'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 22px
    fontWeight: '700'
    lineHeight: 30px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 19px
    fontWeight: '500'
    lineHeight: 30px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 17px
    fontWeight: '500'
    lineHeight: 26px
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 15px
    fontWeight: '500'
    lineHeight: 22px
  label-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '700'
    lineHeight: 24px
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '700'
    lineHeight: 22px
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '700'
    lineHeight: 18px
    letterSpacing: 0.02em
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1.25rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2.25rem
---

## Brand & Style

This design system is tailored for adolescent girls and young women in West Africa acquiring initial French literacy. The aesthetic pairs dignity and celebratory empowerment with extreme functional clarity. Because users may possess emerging or non-existent textual literacy alongside varied digital fluency, the interface eliminates cognitive friction by relying on visual affordances, high-contrast separation, tactile feedback, and universal dual-coding (pairing every critical word with an illustrative glyph and persistent audio narration trigger).

The design style is a warm, tactile, high-clarity modern interface. It combines substantial rounded card surfaces, deep comforting colors reminiscent of local textiles and foliage, and chunky, highly responsive interactive touch targets. The experience must feel optimistic, respectful, sisterly, and non-infantilizing—honoring adult agency while providing gentle, patient guidance.

## Colors

The palette is engineered for high daylight legibility and emotional warmth. 

- **Primary (`#0A6B6B`)**: Deep teal represents growth, stability, and structure. Used for app navigation bars, primary actions, base borders, and primary card backgrounds.
- **Secondary / Accent (`#C51C4E`)**: Warm magenta/pink provides vibrant emphasis. Used for progression celebrations, rewards, audio playback states, and high-priority learning CTA triggers.
- **Tertiary (`#F59E0B`)**: Warm gold used sparingly for praise badges, star tokens, and streak celebrations.
- **Neutrals**:
  - Light Backgrounds: Pure White (`#FFFFFF`) for elevated cards, Warm Tint Light Gray (`#F8F9FA` / `#F5F5F5`) for canvas containers to avoid harsh glare.
  - Borders and Dividers: Light Slate (`#E2E8F0`) and Medium Neutral (`#CCCCCC`) ensure crisp demarcation between interactive zones.
  - Typography & Iconography: Deep Slate Near-Black (`#1F2937`) provides AAA contrast against light backgrounds. A softer Charcoal (`#4B5563`) is used for secondary descriptive subtext.

## Typography

Plus Jakarta Sans is selected across all tiers for its open counters, distinct letterforms (crucial for differentiating similar Latin characters like 'b', 'd', 'p', 'q'), and welcoming, modern geometry. 

Because the target audience is building reading fluency in French, generous line-heights (140%–160%) and distinct word separation prevent line-jumping. Standard body copy never scales below 15px. Key instructional text and phonics exercises leverage `body-lg` (19px) and `label-lg` (18px) to optimize scanning on budget mobile screens under bright outdoor sunlight.

## Layout & Spacing

The layout is strictly mobile-first with a single-column fluid flow optimized for one-handed portrait use on 360dp to 430dp wide devices.

- **Margins & Safe Zones**: A standard outer canvas margin of `1.25rem` (20px) ensures that interactable elements do not ride too close to hardware edges or protective phone cases.
- **Rhythm & Touch Density**: Vertically stacked elements follow a generous 8pt base grid (`space-md` = 16px, `space-lg` = 24px). Spacing prioritizes breathing room between adjacent interactive buttons to prevent accidental taps.
- **Touch Targets**: All actionable buttons, options, and playback toggles enforce an absolute minimum dimension of 56×56dp (scaled via `3.5rem` minimum height).

## Elevation & Depth

This design system uses a tactile, low-blur "physical button" depth model rather than diffuse floating shadows. This provides unmistakable clarity on budget LCD screens where subtle gradients or light blur layers wash out:

- **Level 0 (Flat / Canvas)**: Background canvas `#F8F9FA` without elevation.
- **Level 1 (Resting Cards & Surfaces)**: Pure white `#FFFFFF` surface with a 1.5px solid boundary (`#E2E8F0`) and a subtle downward contact shadow (`0 2px 4px rgba(31, 41, 55, 0.06)`).
- **Level 2 (Interactive Buttons / 3D Bevel)**: Interactive buttons possess a physical base: a solid 3px bottom edge border in a 20% darkened tone of the element's fill (e.g., `#074C4C` under `#0A6B6B`, or `#8E1236` under `#C51C4E`).
- **Active / Pressed State**: Upon tap, the element shifts 2px downwards along the Y-axis while its lower edge border reduces to 1px, providing instant, gratifying mechanical feedback even before sound plays.

## Shapes

The interface embraces organic, friendly pill and ultra-rounded geometries (`roundedness: 3`). 

- Interactive buttons and input pills feature full pill radii (`9999px` or `2rem`).
- Module cards, exercise tiles, and modal sheets use `1.5rem` to `2rem` (`rounded-2xl` to `rounded-3xl`), evoking smooth handheld chalkboards and natural forms.
- Audio badges and avatar emblems are rendered as pure circles (`rounded-full`). Sharp 90-degree corners are systematically eliminated to avoid an intimidating, bureaucratic, or institutional feel.

## Components

### Buttons & Primary Actions
- **Primary CTA**: Deep teal (`#0A6B6B`) background, white text (`label-lg`), pill-shaped, min-height 56px. Displays a leading icon (e.g., arrow, checkmark) alongside clear text. Bottom 3px edge in `#074C4C`.
- **Secondary CTA**: Warm magenta (`#C51C4E`) background, white text, pill-shaped. Used for celebratory moments, progression, or "Écouter" (Listen) triggers.
- **Ghost / Tertiary Button**: White background, 2px border in `#0A6B6B`, teal text.

### Audio Narration Pill (Speaker Affordance)
- Universal accessibility component pinned alongside any text prompt or syllable card.
- Features a high-visibility speaker glyph (`28px`) inside a warm pill container. When tapped, emits an active pulse ring in `#C51C4E` and visual audio-wave indicators so users can replay spoken French phrases at will.

### Learning & Phonics Cards
- Sized generously to house a large visual icon/illustration, the written French word or letter in `headline-md`, and an embedded audio trigger button.
- Resting on white surface with a 2px `#E2E8F0` border. Selected state swaps border to 2.5px `#0A6B6B` with a soft teal tint background (`#E6F2F2`).

### Form Inputs & Selection Chips
- Text inputs provide a minimum 56px height, rounded pill geometry, with large 18px text and a microphone / speech input option.
- Radio and selection options are constructed as full-width tap cards (never tiny bare radio circles) containing both a descriptive icon, large bold text, and a distinct checked state.

### Bottom Navigation
- Fixed mobile navigation with large 64px touch slots. Icons are paired directly with concise labels. Active item is highlighted with an pill container badge in `#0A6B6B` with white icon fill.