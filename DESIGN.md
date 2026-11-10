
# AirScope Design System

## 1. Product Identity

Product Name: AirScope
Product Type: Air Quality Monitoring Application
Platform: Android
Framework: Flutter
Design System: Material Design 3

## 2. Design Direction

Visual Style:
- Modern
- Minimalist
- Clean
- Informative
- Professional

Design Objective:

Menyajikan informasi kualitas udara secara cepat, jelas, dan mudah dipahami oleh pengguna.

## 3. Color Palette

### Primary Colors

| Token | Hex | Usage |
|---|---|---|
| Primary | #2563EB | Primary buttons |
| Primary Dark | #1D4ED8 | Active elements |
| Background | #F8FAFC | Main background |
| Surface | #FFFFFF | Cards and panels |
| Text Primary | #0F172A | Main text |
| Text Secondary | #64748B | Secondary text |
| Border | #E2E8F0 | Dividers |
| Success | #16A34A | Success state |
| Warning | #EAB308 | Warning state |
| Error | #DC2626 | Error state |

### AQI Color Classification

Use the US AQI scale.

| AQI | Category | Color |
|---|---|---|
| 0–50 | Good | #16A34A |
| 51–100 | Moderate | #EAB308 |
| 101–150 | Unhealthy for Sensitive Groups | #F97316 |
| 151–200 | Unhealthy | #DC2626 |
| 201–300 | Very Unhealthy | #9333EA |
| 301–500 | Hazardous | #7F1D1D |

Always display the AQI category label.
Do not communicate AQI status using color alone.

## 4. Typography

Use Flutter Material typography.

Hierarchy:

- Display: Main AQI value.
- Headline: Main page heading.
- Title: Section and card titles.
- Body: General information.
- Label: Metadata and supporting information.

Prioritize readability of numerical values.

## 5. Layout System

Design principles:

- Mobile-first.
- Responsive layout.
- Consistent spacing.
- Use SafeArea.
- Avoid horizontal overflow.
- Use scrollable layouts when necessary.

Spacing scale:

- 4 px
- 8 px
- 12 px
- 16 px
- 24 px
- 32 px

## 6. Main Screen Structure

The main screen should contain:

1. AppBar with AirScope identity.
2. City search field.
3. Search action button.
4. City information.
5. Main AQI indicator.
6. Air quality category.
7. PM2.5 information card.
8. PM10 information card.
9. Data source information.
10. Last searched city information.

## 7. UI States

### Loading State

- Display a progress indicator.
- Explain that air quality data is being retrieved.
- Avoid blank screens.

### Success State

- Display the AQI value prominently.
- Display the AQI category.
- Display PM2.5 and PM10 values.
- Display the selected city.

### Error State

- Display understandable error messages.
- Provide a Retry action.
- Never expose raw exception messages to users.

### Empty State

- Provide instructions for searching a city.
- Avoid displaying meaningless placeholder data.

## 8. Accessibility

- Maintain readable text contrast.
- Use appropriate touch target sizes.
- Provide semantic labels.
- Avoid excessively small text.
- Never rely exclusively on color to communicate AQI status.

## 9. Anti-Slop Guidelines

- Every UI component must have a clear purpose.
- Avoid generic layouts without functional value.
- Avoid excessive gradients and decorative elements.
- Maintain consistent spacing and typography.
- Prefer reusable components.
- Avoid duplicated UI code.
- Ensure every button performs a meaningful action.
- Review the actual UI at different screen sizes.
- Prioritize usability over visual decoration.

## 10. Quality Standard

A feature is not complete until:

- Its visual implementation follows this document.
- Its interactions work correctly.
- Its layout has no overflow.
- Its states are handled.
- Its code passes Flutter analysis.
