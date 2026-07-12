# duckmapR

`duckmapR` provides Mallard-inspired color maps for scientific data visualization. The package includes perceptually structured sequential palettes, true-white-center divergent palettes, and a color-vision-deficiency-evaluated categorical palette.

The core API is compact:

```r
duckmap()
duckmap_summary()
duckmap_custom()
scale_fill_duckmap()
scale_color_duckmap()
```

## Installation

You can install the development version of `duckmapR` from GitHub:

```r
# install.packages("pak")
pak::pak("travismallard/duckmapR")
```

You can also install from a local source tarball:

```r
install.packages("duckmapR_0.1.0.tar.gz", repos = NULL, type = "source")
```

## Generate colors

Palettes can be called directly by name. You do not need to specify `type` unless you want the default palette for a palette class.

```r
library(duckmapR)

# Sequential palettes
cols_seq <- duckmap("full_plumage")
cols_seq_9 <- duckmap("viriduck", n = 9)

# Vivid sequential style
cols_vivid <- duckmap("full_plumage", n = 9, style = "vivid")

# Divergent palettes
cols_div <- duckmap("umber_teal")
cols_div_11 <- duckmap("copper_blue", n = 11)

# Categorical palette
cols_cat <- duckmap("archetype")
cols_cat_4 <- duckmap(type = "cat", n = 4)
cols_cat_subset <- duckmap(
  type = "categorical",
  colors = c("mallard_teal", "soft_gold", "slate_blue")
)
```

## Defaults by palette class

```r
# Default sequential palette: full_plumage, n = 256
duckmap(type = "seq")
duckmap(type = "sequential")

# Default divergent palette: umber_teal, n = 257
duckmap(type = "div")
duckmap(type = "divergent")

# Default categorical palette: archetype
duckmap(type = "cat")
duckmap(type = "categorical")
duckmap("archetype")
```

Divergent palettes use an exact white midpoint when `n` is odd. The default `n = 257` is therefore intentional. If an even `n` is requested for a divergent palette, `duckmapR` warns that the exact midpoint color will not be sampled.

## Palette inventory

`duckmap_summary()` draws a visual summary of the available palettes and invisibly returns palette metadata.

```r
duckmap_summary()
duckmap_summary(type = "sequential")
duckmap_summary(type = "divergent")
duckmap_summary(type = "categorical")
duckmap_summary(style = "vivid")
```

For structured palette metadata (without drawing), use:

```r
duckmap_summary(plot = FALSE)
duckmap_summary(type = "divergent", plot = FALSE)
```

## ggplot2 scales

`duckmapR` includes ggplot2 helpers for continuous and discrete color scales.

```r
library(ggplot2)

ggplot(faithfuld, aes(waiting, eruptions, fill = density)) +
  geom_raster() +
  scale_fill_duckmap("viriduck") +
  theme_minimal()
```

```r
ggplot(faithfuld, aes(waiting, eruptions, fill = density - mean(density))) +
  geom_raster() +
  scale_fill_duckmap("copper_blue") +
  theme_minimal()
```

```r
ggplot(mtcars, aes(wt, mpg, color = factor(cyl))) +
  geom_point(size = 3) +
  scale_color_duckmap(type = "categorical") +
  theme_minimal()
```

Categorical colors can also be subset in the ggplot2 helpers:

```r
scale_color_duckmap(
  type = "categorical",
  colors = c("mallard_teal", "soft_gold", "slate_blue")
)
```

## Custom palettes

Define your own palette from CIELAB anchors with `duckmap_custom()`. The result is interpolated in Lab space exactly like the built-in palettes, and the returned object works directly with `duckmap()` and the ggplot2 scale helpers.

```r
map <- duckmap_custom(
  anchors = data.frame(
    t = c(0, 0.333, 0.667, 1),
    L = c(20, 51, 70, 95),
    a = c(38, 21, 24, -1),
    b = c(-51, -25, 19, 3)
  ),
  name = "custom"
)

# Generate colors
duckmap(map, n = 11)

# Use with ggplot2 (continuous by default; discrete = TRUE for discrete data)
ggplot(faithfuld, aes(waiting, eruptions, fill = density)) +
  geom_raster() +
  scale_fill_duckmap(map)
```

The optional `t` column sets each anchor's relative position (rescaled to `[0, 1]`); omit it for evenly spaced anchors. The `name` is a cosmetic label — the palette is used via the object itself, so a name is not required.

## Notes

Palette design matrices are stored as CSV files in `inst/extdata` and are converted to sRGB hex colors when requested.
