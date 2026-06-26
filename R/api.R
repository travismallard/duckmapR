duckmap <- function(palette = NULL,
                    type = "all",
                    n = NULL,
                    reverse = FALSE,
                    style = c("standard", "vivid"),
                    colors = NULL,
                    warn_even_divergent = TRUE) {
  style <- .duckmaps_match_style(style)
  resolved <- .duckmaps_resolve_palette(palette = palette, type = type)
  type <- resolved$type
  palette <- resolved$palette

  if (type != "seq" && style != "standard") {
    stop(
      "`style = \"vivid\"` is only available for sequential palettes. ",
      "Palette `", palette, "` is ", .duckmap_type_label(type), ". ",
      "Use `style = \"standard\"` or omit `style`.",
      call. = FALSE
    )
  }

  if (type != "cat" && !is.null(colors)) {
    stop("`colors` is only available for the categorical palette.", call. = FALSE)
  }

  if (is.null(n)) n <- .duckmaps_default_n(type, colors = colors)
  n <- .duckmaps_validate_n(n)

  if (type == "cat") {
    return(.duckmaps_categorical(n = n, reverse = reverse, colors = colors))
  }

  if (type == "seq") {
    lab <- .duckmaps_load_seq_lab(style = style)[[palette]]
  } else {
    if (isTRUE(warn_even_divergent) && n > 0L && n %% 2L == 0L) {
      warning(
        "`n` is even for divergent palette `", palette, "`; no sampled color will be exactly the white midpoint. ",
        "Use an odd `n` (the default is 257) if the exact midpoint color is important.",
        call. = FALSE
      )
    }
    lab <- .duckmaps_load_div_lab()[[palette]]
  }

  if (isTRUE(reverse)) lab <- lab[nrow(lab):1, , drop = FALSE]
  .duckmaps_interp_lab(lab, n)
}

duckmap_summary <- function(type = "all",
                            plot = TRUE,
                            style = c("standard", "vivid")) {
  type <- .duckmaps_normalize_type(type)
  style <- .duckmaps_match_style(style)

  if (type %in% c("div", "cat") && style != "standard") {
    stop(
      "`style = \"vivid\"` is only available for sequential palettes. ",
      "Use `style = \"standard\"` or omit `style` for ", .duckmap_type_label(type), " palettes.",
      call. = FALSE
    )
  }

  info <- .duckmaps_info(type)

  if (isTRUE(plot)) {
    .duckmaps_visual_summary(type, style = style)
    return(invisible(info))
  }

  info
}

scale_fill_duckmap <- function(palette = NULL,
                                type = "all",
                                discrete = NULL,
                                reverse = FALSE,
                                style = c("standard", "vivid"),
                                colors = NULL,
                                ...) {
  style <- .duckmaps_match_style(style)
  resolved <- .duckmaps_resolve_palette(palette = palette, type = type)
  type <- resolved$type
  palette <- resolved$palette

  if (type != "seq" && style != "standard") {
    stop(
      "`style = \"vivid\"` is only available for sequential palettes. ",
      "Palette `", palette, "` is ", .duckmap_type_label(type), ". ",
      "Use `style = \"standard\"` or omit `style`.",
      call. = FALSE
    )
  }

  if (is.null(discrete)) discrete <- identical(type, "cat")

  if (type == "cat") {
    return(ggplot2::scale_fill_manual(values = duckmap(type = "cat", reverse = reverse, n = NULL, colors = colors), ...))
  }

  if (!is.null(colors)) stop("`colors` is only available for the categorical palette.", call. = FALSE)

  if (isTRUE(discrete)) {
    return(ggplot2::discrete_scale(
      aesthetics = "fill",
      scale_name = paste0("duckmap_", type, if (type == "seq" && style != "standard") paste0("_", style) else ""),
      palette = function(n) duckmap(palette = palette, type = type, n = n, reverse = reverse, style = style, warn_even_divergent = FALSE),
      ...
    ))
  }

  n_gradient <- if (type == "div") 257L else 256L
  ggplot2::scale_fill_gradientn(colours = duckmap(palette = palette, type = type, n = n_gradient, reverse = reverse, style = style, warn_even_divergent = FALSE), ...)
}

scale_color_duckmap <- function(palette = NULL,
                                 type = "all",
                                 discrete = NULL,
                                 reverse = FALSE,
                                 style = c("standard", "vivid"),
                                 colors = NULL,
                                 ...) {
  style <- .duckmaps_match_style(style)
  resolved <- .duckmaps_resolve_palette(palette = palette, type = type)
  type <- resolved$type
  palette <- resolved$palette

  if (type != "seq" && style != "standard") {
    stop(
      "`style = \"vivid\"` is only available for sequential palettes. ",
      "Palette `", palette, "` is ", .duckmap_type_label(type), ". ",
      "Use `style = \"standard\"` or omit `style`.",
      call. = FALSE
    )
  }

  if (is.null(discrete)) discrete <- identical(type, "cat")

  if (type == "cat") {
    return(ggplot2::scale_color_manual(values = duckmap(type = "cat", reverse = reverse, n = NULL, colors = colors), ...))
  }

  if (!is.null(colors)) stop("`colors` is only available for the categorical palette.", call. = FALSE)

  if (isTRUE(discrete)) {
    return(ggplot2::discrete_scale(
      aesthetics = "colour",
      scale_name = paste0("duckmap_", type, if (type == "seq" && style != "standard") paste0("_", style) else ""),
      palette = function(n) duckmap(palette = palette, type = type, n = n, reverse = reverse, style = style, warn_even_divergent = FALSE),
      ...
    ))
  }

  n_gradient <- if (type == "div") 257L else 256L
  ggplot2::scale_color_gradientn(colours = duckmap(palette = palette, type = type, n = n_gradient, reverse = reverse, style = style, warn_even_divergent = FALSE), ...)
}

scale_colour_duckmap <- scale_color_duckmap
