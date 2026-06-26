.duckmaps_extdata <- function(file) {
  path <- system.file("extdata", file, package = "duckmapR")
  if (!nzchar(path)) stop("Could not find packaged palette data file: ", file, call. = FALSE)
  path
}

.duckmaps_normalize_type <- function(type = "all") {
  if (is.null(type)) type <- "all"
  if (!is.character(type) || length(type) != 1L || is.na(type)) {
    stop("`type` must be one of: all, seq, sequential, div, divergent, cat, categorical.", call. = FALSE)
  }

  type <- tolower(type)
  choices <- c("all", "seq", "sequential", "div", "divergent", "cat", "categorical")

  if (!type %in% choices) {
    stop("`type` must be one of: all, seq, sequential, div, divergent, cat, categorical.", call. = FALSE)
  }

  switch(
    type,
    sequential = "seq",
    divergent = "div",
    categorical = "cat",
    type
  )
}

.duckmaps_match_style <- function(style = c("standard", "vivid")) {
  match.arg(style)
}

.duckmaps_default_palette <- function(type) {
  switch(
    type,
    seq = .duckmaps_seq_names[[1]],
    div = .duckmaps_div_names[[1]],
    cat = "archetype",
    stop("Unknown normalized palette type: ", type, call. = FALSE)
  )
}

.duckmaps_default_n <- function(type, colors = NULL) {
  switch(
    type,
    seq = 256L,
    div = 257L,
    cat = if (is.null(colors)) length(.duckmaps_cat) else length(colors),
    stop("Unknown normalized palette type: ", type, call. = FALSE)
  )
}

.duckmap_type_label <- function(type) {
  switch(
    type,
    seq = "sequential",
    div = "divergent",
    cat = "categorical",
    all = "all",
    type
  )
}

.duckmaps_info <- function(type = "all") {
  type <- .duckmaps_normalize_type(type)

  info <- data.frame(
    palette = c(.duckmaps_seq_names, .duckmaps_div_names, "archetype"),
    type = c(
      rep("sequential", length(.duckmaps_seq_names)),
      rep("divergent", length(.duckmaps_div_names)),
      "categorical"
    ),
    default = c(
      .duckmaps_seq_names == .duckmaps_default_palette("seq"),
      .duckmaps_div_names == .duckmaps_default_palette("div"),
      TRUE
    ),
    default_n = c(
      rep(.duckmaps_default_n("seq"), length(.duckmaps_seq_names)),
      rep(.duckmaps_default_n("div"), length(.duckmaps_div_names)),
      .duckmaps_default_n("cat")
    ),
    styles = c(
      rep("standard, vivid", length(.duckmaps_seq_names)),
      rep("standard", length(.duckmaps_div_names)),
      "standard"
    ),
    stringsAsFactors = FALSE
  )

  if (type == "all") return(info)

  type_label <- .duckmap_type_label(type)
  info[info$type == type_label, , drop = FALSE]
}

.duckmaps_available_palettes <- function() {
  c(.duckmaps_seq_names, .duckmaps_div_names, "archetype")
}

.duckmaps_resolve_palette <- function(palette = NULL, type = "all") {
  type <- .duckmaps_normalize_type(type)

  if (type == "all") {
    if (is.null(palette)) {
      return(list(type = "seq", palette = .duckmaps_default_palette("seq")))
    }

    if (!is.character(palette) || length(palette) != 1L || is.na(palette)) {
      stop("`palette` must be a single palette name when supplied.", call. = FALSE)
    }

    if (palette %in% .duckmaps_seq_names) return(list(type = "seq", palette = palette))
    if (palette %in% .duckmaps_div_names) return(list(type = "div", palette = palette))
    if (palette %in% c("archetype")) return(list(type = "cat", palette = "archetype"))

    stop(
      "Unknown duckmapR palette: `", palette, "`.\n",
      "Available palettes are: ", paste(.duckmaps_available_palettes(), collapse = ", "), ".",
      call. = FALSE
    )
  }

  if (type == "seq") {
    if (is.null(palette)) palette <- .duckmaps_default_palette("seq")
    if (!palette %in% .duckmaps_seq_names) {
      stop(
        "Unknown sequential palette: `", palette, "`.\n",
        "Available sequential palettes are: ", paste(.duckmaps_seq_names, collapse = ", "), ".",
        call. = FALSE
      )
    }
    return(list(type = "seq", palette = palette))
  }

  if (type == "div") {
    if (is.null(palette)) palette <- .duckmaps_default_palette("div")
    if (!palette %in% .duckmaps_div_names) {
      stop(
        "Unknown divergent palette: `", palette, "`.\n",
        "Available divergent palettes are: ", paste(.duckmaps_div_names, collapse = ", "), ".",
        call. = FALSE
      )
    }
    return(list(type = "div", palette = palette))
  }

  if (type == "cat") {
    if (is.null(palette) || palette %in% c("archetype")) {
      return(list(type = "cat", palette = "archetype"))
    }

    if (palette %in% names(.duckmaps_cat)) {
      stop(
        "`", palette, "` is an individual categorical color, not a standalone palette.\n",
        "Use `duckmap(type = \"categorical\", colors = \"", palette, "\")` to select it.",
        call. = FALSE
      )
    }

    stop(
      "Unknown categorical palette: `", palette, "`. The default categorical palette is called `archetype`.",
      call. = FALSE
    )
  }

  stop("Unknown normalized palette type: ", type, call. = FALSE)
}

.duckmaps_validate_n <- function(n) {
  if (is.null(n)) return(NULL)
  if (!is.numeric(n) || length(n) != 1L || is.na(n)) {
    stop("`n` must be a single non-negative numeric value or NULL.", call. = FALSE)
  }
  n <- as.integer(n)
  if (n < 0L) stop("`n` must be non-negative.", call. = FALSE)
  n
}

.duckmaps_load_lab <- function(file, cache_name) {
  if (!exists(cache_name, envir = .duckmaps_cache, inherits = FALSE)) {
    dat <- utils::read.csv(.duckmaps_extdata(file), stringsAsFactors = FALSE)
    required <- c("palette", "index", "L", "a", "b")
    missing <- setdiff(required, names(dat))
    if (length(missing) > 0) {
      stop("Palette data file is missing required columns: ", paste(missing, collapse = ", "), call. = FALSE)
    }
    split_dat <- split(dat, dat$palette)
    lab_list <- lapply(split_dat, function(x) {
      x <- x[order(x$index), , drop = FALSE]
      as.matrix(x[, c("L", "a", "b")])
    })
    assign(cache_name, lab_list, envir = .duckmaps_cache)
  }
  get(cache_name, envir = .duckmaps_cache, inherits = FALSE)
}

.duckmaps_load_seq_lab <- function(style = c("standard", "vivid")) {
  style <- .duckmaps_match_style(style)
  file <- switch(
    style,
    standard = "sequential_lab_design_4096.csv",
    vivid = "sequential_vivid_lab_design_4096.csv"
  )
  .duckmaps_load_lab(file, paste0("seq_lab_", style))
}

.duckmaps_load_div_lab <- function() .duckmaps_load_lab("diverging_lab_design_4097.csv", "div_lab")

.duckmaps_lab_to_hex <- function(lab) {
  rgb <- grDevices::convertColor(lab, from = "Lab", to = "sRGB", scale.in = 1)
  rgb <- pmin(pmax(rgb, 0), 1)
  grDevices::rgb(rgb[, 1], rgb[, 2], rgb[, 3])
}

.duckmaps_interp_lab <- function(lab, n) {
  if (is.null(n)) n <- nrow(lab)
  n <- .duckmaps_validate_n(n)
  if (n == 0L) return(character(0))
  if (n == nrow(lab)) return(.duckmaps_lab_to_hex(lab))
  x_old <- seq(0, 1, length.out = nrow(lab))
  x_new <- seq(0, 1, length.out = n)
  out <- cbind(
    stats::approx(x_old, lab[, 1], xout = x_new, ties = "ordered")$y,
    stats::approx(x_old, lab[, 2], xout = x_new, ties = "ordered")$y,
    stats::approx(x_old, lab[, 3], xout = x_new, ties = "ordered")$y
  )
  .duckmaps_lab_to_hex(out)
}

.duckmaps_categorical <- function(n = NULL, reverse = FALSE, colors = NULL) {
  cols <- .duckmaps_cat

  if (!is.null(colors)) {
    if (!is.character(colors) || anyNA(colors)) {
      stop("`colors` must be a character vector of categorical color names.", call. = FALSE)
    }

    missing <- setdiff(colors, names(.duckmaps_cat))
    if (length(missing) > 0L) {
      stop(
        "Unknown categorical color name(s): ", paste(missing, collapse = ", "), ".\n",
        "Available categorical colors are: ", paste(names(.duckmaps_cat), collapse = ", "), ".",
        call. = FALSE
      )
    }

    cols <- .duckmaps_cat[colors]
  }

  if (isTRUE(reverse)) cols <- rev(cols)

  if (is.null(n)) return(cols)
  n <- .duckmaps_validate_n(n)
  if (n == 0L) return(stats::setNames(character(0), character(0)))
  if (n <= length(cols)) return(cols[seq_len(n)])
  rep(cols, length.out = n)
}

.duckmaps_plot_palette_rows <- function(rows, title = "duckmapR palettes") {
  n <- length(rows)
  if (n < 1L) return(invisible(NULL))

  old_par <- graphics::par(no.readonly = TRUE)
  on.exit(graphics::par(old_par), add = TRUE)

  label_space <- max(nchar(names(rows))) * 0.018 + 0.05
  label_space <- min(max(label_space, 0.26), 0.40)

  graphics::par(
    mar = c(0.8, 0.4, 2.0, 0.4),
    xaxs = "i",
    yaxs = "i"
  )

  graphics::plot.new()
  graphics::plot.window(
    xlim = c(-label_space, 1),
    ylim = c(0, n)
  )

  for (i in seq_len(n)) {
    y <- n - i
    nm <- names(rows)[[i]]
    cols <- rows[[i]]
    k <- length(cols)

    graphics::text(
      x = -0.025,
      y = y + 0.5,
      labels = nm,
      adj = c(1, 0.5),
      cex = 0.72
    )

    bar_right <- 0.965
    dx <- bar_right / k

    graphics::rect(
      xleft = dx * (seq_len(k) - 1),
      ybottom = y + 0.16,
      xright = dx * seq_len(k),
      ytop = y + 0.84,
      col = cols,
      border = NA
    )
  }

  graphics::title(main = title, cex.main = 1.0)
  invisible(NULL)
}

.duckmaps_visual_summary <- function(type = "all", style = c("standard", "vivid")) {
  type <- .duckmaps_normalize_type(type)
  style <- .duckmaps_match_style(style)

  if (type %in% c("div", "cat") && style != "standard") {
    stop(
      "`style = \"vivid\"` is only available for sequential palettes. ",
      "Use `style = \"standard\"` or omit `style` for ", .duckmap_type_label(type), " palettes.",
      call. = FALSE
    )
  }

  rows <- list()

  if (type %in% c("all", "seq")) {
    seq_rows <- stats::setNames(
      lapply(.duckmaps_seq_names, function(x) duckmap(x, type = "seq", n = 256, style = style, warn_even_divergent = FALSE)),
      if (style == "standard") .duckmaps_seq_names else paste0(.duckmaps_seq_names, " (vivid)")
    )
    rows <- c(rows, seq_rows)
  }

  if (type %in% c("all", "div")) {
    div_rows <- stats::setNames(
      lapply(.duckmaps_div_names, function(x) duckmap(x, type = "div", n = 257, warn_even_divergent = FALSE)),
      .duckmaps_div_names
    )
    rows <- c(rows, div_rows)
  }

  if (type %in% c("all", "cat")) {
    rows <- c(rows, list(archetype = duckmap(type = "cat", n = NULL)))
  }

  title_style <- if (type %in% c("all", "seq") && style != "standard") paste0(" (", style, " sequential)") else ""
  .duckmaps_plot_palette_rows(rows, title = paste0("duckmapR ", if (type == "all") "palettes" else paste(.duckmap_type_label(type), "palettes"), title_style))
  invisible(NULL)
}
